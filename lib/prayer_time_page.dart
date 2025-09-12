// Prayer page Done without kill app Alan play

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tasbeeh_stats_page.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({Key? key}) : super(key: key);

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage>
    with SingleTickerProviderStateMixin {
  // ---------- Prayer Times ----------
  String? cityName = "Loading...";
  String? countryName = "Loading...";
  Map<String, String> prayerTimes = {};
  String nextPrayer = "";
  Duration countdown = Duration.zero;
  Timer? timer;

  // ---------- Tasbeeh ----------
  String selectedPhrase = "সুবহানাল্লাহ";
  int subhanallahCount = 0;
  int alhamdulillahCount = 0;
  int allahuakbarCount = 0;

  // ---------- Tabs ----------
  late TabController _tabController;

  // ---------- Banner Ad ----------
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  // ---------- Audio ----------
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ---------- MP3 Timer & Notification IDs ----------
  Map<String, Timer> _mp3Timers = {};
  Map<String, int> _notificationIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _loadSavedData().then((_) {
      fetchLocationAndPrayerTimes();
    });

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();

    AwesomeNotifications().initialize('resource://drawable/res_app_icon', [
      NotificationChannel(
        channelKey: 'azan_channel',
        channelName: 'Azan Notifications',
        channelDescription: 'Prayer time reminders',
        defaultColor: Colors.green,
        importance: NotificationImportance.High,
        soundSource: 'resource://raw/azan',
        ledColor: Colors.white,
      ),
    ], debug: true);

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _tabController.dispose();
    _bannerAd.dispose();
    _mp3Timers.forEach((key, t) => t.cancel());
    super.dispose();
  }

  String formatTimeTo12Hour(String time24) {
    final parts = time24.split(":");
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return DateFormat('hh:mm a').format(dateTime);
  }

  // ---------- Load Saved Data ----------
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cityName = prefs.getString("cityName") ?? "Loading...";
      countryName = prefs.getString("countryName") ?? "Loading...";
      String? savedPrayerTimes = prefs.getString("prayerTimes");
      if (savedPrayerTimes != null) {
        prayerTimes = Map<String, String>.from(jsonDecode(savedPrayerTimes));
        findNextPrayer();
      }
    });

    // Restore schedule for each enabled prayer
    prayerTimes.forEach((prayer, time) async {
      bool enabled = prefs.getBool("azan_sound_$prayer") ?? true;
      if (enabled) {
        _schedulePrayerNotification(prayer, time);
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cityName", cityName ?? "");
    await prefs.setString("countryName", countryName ?? "");
    await prefs.setString("prayerTimes", jsonEncode(prayerTimes));
  }

  Future<void> fetchLocationAndPrayerTimes() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          cityName = placemarks[0].locality ?? "Unknown City";
          countryName = placemarks[0].country ?? "Unknown Country";
        });
      }

      final url =
          "http://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=2";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = data["data"]["timings"];
        setState(() {
          prayerTimes = {
            "ফজর": timings["Fajr"],
            "যোহর": timings["Dhuhr"],
            "আসর": timings["Asr"],
            "মাগরিব": timings["Maghrib"],
            "ইশা": timings["Isha"],
          };
        });
        findNextPrayer();
        _saveData();
      }
    } catch (e) {
      print("Location fetch error: $e");
    }
  }

  void findNextPrayer() {
    final now = DateTime.now();
    DateTime? nextPrayerTime;
    String? nextName;

    prayerTimes.forEach((name, time) {
      final parts = time.split(":");
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      if (prayerTime.isAfter(now) &&
          (nextPrayerTime == null || prayerTime.isBefore(nextPrayerTime!))) {
        nextPrayerTime = prayerTime;
        nextName = name;
      }
    });

    if (nextPrayerTime != null) {
      setState(() {
        nextPrayer = nextName!;
        countdown = nextPrayerTime!.difference(now);
      });

      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          countdown = nextPrayerTime!.difference(DateTime.now());
          if (countdown.isNegative) {
            findNextPrayer();
          }
        });
      });
    }
  }

  int _getCurrentCount() {
    if (selectedPhrase == "সুবহানাল্লাহ") return subhanallahCount;
    if (selectedPhrase == "আলহামদুলিল্লাহা") return alhamdulillahCount;
    if (selectedPhrase == "আল্লাহু আকবার") return allahuakbarCount;
    return 0;
  }

  /*// ---------- Set Azan Enabled ----------
  Future<void> _setAzanEnabled(String prayerName, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("azan_sound_$prayerName", enabled);

    // Cancel previous mp3 timer
    _mp3Timers[prayerName]?.cancel();
    _mp3Timers.remove(prayerName);

    // Cancel previous notification
    if (_notificationIds.containsKey(prayerName)) {
      await AwesomeNotifications().cancel(_notificationIds[prayerName]!);
      _notificationIds.remove(prayerName);
    }

    // Schedule new if enabled
    if (enabled && prayerTimes[prayerName] != null) {
      _schedulePrayerNotification(prayerName, prayerTimes[prayerName]!);
    }
  }*/
  Future<void> _setAzanEnabled(String prayerName, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("azan_sound_$prayerName", enabled);

    // Cancel previous mp3 timer
    _mp3Timers[prayerName]?.cancel();
    _mp3Timers.remove(prayerName);

    // শুধু MP3 এর জন্য toggle কাজ করবে
    if (enabled && prayerTimes[prayerName] != null) {
      _schedulePrayerNotification(prayerName, prayerTimes[prayerName]!);
    }
  }

  // ---------- Schedule Prayer Notification ----------
  Future<void> _schedulePrayerNotification(
    String prayerName,
    String time,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool soundEnabled = prefs.getBool("azan_sound_$prayerName") ?? true;

      final now = DateTime.now();
      final parts = time.split(":");
      final prayerDate = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // ৫ মিনিট আগে mp3 play
      final mp3Time = prayerDate.subtract(const Duration(minutes: 5));
      if (mp3Time.isAfter(now) && soundEnabled) {
        _mp3Timers[prayerName] = Timer(mp3Time.difference(now), () async {
          //await _audioPlayer.play(AssetSource('raw/azan.mp3'));
          await _audioPlayer.play(AssetSource('assets/sounds/azan.mp3'));
          ;
        });
      }

      // ১০ মিনিট আগে notification
      final notificationTime = prayerDate.subtract(const Duration(minutes: 10));
      if (notificationTime.isAfter(now)) {
        final notificationId = notificationTime.millisecondsSinceEpoch
            .remainder(100000);
        _notificationIds[prayerName] = notificationId;

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: 'azan_channel',
            title: 'নামাজের সময়',
            body: '$prayerName নামাজ শুরু হওয়ার ১০ মিনিট বাকি',
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            year: notificationTime.year,
            month: notificationTime.month,
            day: notificationTime.day,
            hour: notificationTime.hour,
            minute: notificationTime.minute,
            second: 0,
            repeats: false,
          ),
        );
      }
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  Widget prayerRow(String prayerName, String time) {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance().then(
        (prefs) => prefs.getBool("azan_sound_$prayerName") ?? true,
      ),
      builder: (context, snapshot) {
        bool enabled = snapshot.data ?? true;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.access_time,
              color: Colors.green,
              size: 28,
            ),
            title: Text(
              prayerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              formatTimeTo12Hour(time),
              style: const TextStyle(fontSize: 18),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("আজান", style: TextStyle(fontSize: 14)),
                Switch(
                  value: enabled,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  onChanged: (value) => _setAzanEnabled(
                    prayerName,
                    value,
                  ).then((_) => setState(() {})),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrayerTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          "$cityName, $countryName",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              ...prayerTimes.entries
                  .map((e) => prayerRow(e.key, e.value))
                  .toList(),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.all(16),
          color: Colors.green[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "পরবর্তী ওয়াক্ত: $nextPrayer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black54 : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${countdown.inHours.toString().padLeft(2, '0')}:${(countdown.inMinutes % 60).toString().padLeft(2, '0')}:${(countdown.inSeconds % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // prayer tab এর শেষে
        _buildTestAzanButton(), //-----line will delete
      ],
    );
  }

  Widget _buildTasbeehTab() {
    final List<String> tasbeehPhrases = [
      "সুবহানাল্লাহ",
      "আলহামদুলিল্লাহা",
      "আল্লাহু আকবার",
    ];
    final List<Color> colors = [
      Colors.green.shade700,
      Colors.blue.shade700,
      Colors.orange.shade700,
    ];

    Future<void> _incrementCount(String phrase) async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        selectedPhrase = phrase;
        if (phrase == "সুবহানাল্লাহ") {
          subhanallahCount++;
          prefs.setInt("subhanallahCount", subhanallahCount);
        }
        if (phrase == "আলহামদুলিল্লাহা") {
          alhamdulillahCount++;
          prefs.setInt("alhamdulillahCount", alhamdulillahCount);
        }
        if (phrase == "আল্লাহু আকবার") {
          allahuakbarCount++;
          prefs.setInt("allahuakbarCount", allahuakbarCount);
        }
      });
    }

    Future<void> _resetCounts() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        subhanallahCount = 0;
        alhamdulillahCount = 0;
        allahuakbarCount = 0;
        prefs.setInt("subhanallahCount", 0);
        prefs.setInt("alhamdulillahCount", 0);
        prefs.setInt("allahuakbarCount", 0);
      });
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          "তসবীহ কাউন্টার",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.green.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              children: [
                Text(
                  selectedPhrase,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  _getCurrentCount().toString(),
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: tasbeehPhrases.length,
            itemBuilder: (context, index) {
              String phrase = tasbeehPhrases[index];
              Color color = colors[index % colors.length];
              return GestureDetector(
                onTap: () => _incrementCount(phrase),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      phrase,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton.icon(
          onPressed: _resetCounts,
          icon: const Icon(Icons.refresh),
          label: const Text("রিসেট"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TasbeehStatsPage(
                  subhanallahCount: subhanallahCount,
                  alhamdulillahCount: alhamdulillahCount,
                  allahuakbarCount: allahuakbarCount,
                ),
              ),
            );
          },
          icon: const Icon(Icons.bar_chart),
          label: const Text("স্ট্যাটস দেখুন"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------- এক্সট্রা টেস্ট বাটন ----------
  Widget _buildTestAzanButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () async {
          // ডিবাগ চেক
          print("Test Azan button pressed");

          // ১. আযান MP3 প্লে
          try {
            await _audioPlayer.play(AssetSource('assets/sounds/azan.mp3'));
            print("Audio play called");
          } catch (e) {
            print("Audio play error: $e");
          }

          // ২. নোটিফিকেশন
          try {
            bool isAllowed = await AwesomeNotifications()
                .isNotificationAllowed();
            print("Notification allowed: $isAllowed");
            if (isAllowed) {
              final testNotificationId = DateTime.now().millisecondsSinceEpoch
                  .remainder(100000);
              await AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: testNotificationId,
                  channelKey: 'azan_channel',
                  title: 'নামাজের সময়',
                  body: 'এই নোটিফিকেশন টেস্ট। আযান শুনতে পাও।',
                  notificationLayout: NotificationLayout.Default,
                ),
              );
              print("Notification created");
            } else {
              print("Notification permission denied");
              AwesomeNotifications().requestPermissionToSendNotifications();
            }
          } catch (e) {
            print("Notification error: $e");
          }
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text("টেস্ট আযান"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ---------- এক্সট্রা টেস্ট বাটন 끝 ----------

  // ---------- Smooth Compass ----------
  double? _lastHeading;
  double _smoothHeading = 0.0;

  double _applySmoothing(double newHeading) {
    if (_lastHeading == null) {
      _lastHeading = newHeading;
      _smoothHeading = newHeading;
    } else {
      // 0.1 মানে ধীরে ধীরে পরিবর্তন হবে → লাফ বন্ধ
      _smoothHeading = _smoothHeading + 0.1 * (newHeading - _smoothHeading);
      _lastHeading = newHeading;
    }
    return _smoothHeading;
  }

  Widget _buildQiblaTab() {
    return FutureBuilder<Position>(
      future: Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("লোকেশন পাওয়া যায়নি"));
        } else {
          final position = snapshot.data!;
          // মক্কা (Kaaba) coordinates
          const double kaabaLat = 21.4225;
          const double kaabaLng = 39.8262;

          // কিবলা angle বের করা
          double deltaLng = (kaabaLng - position.longitude) * pi / 180;
          double lat1 = position.latitude * pi / 180;
          double lat2 = kaabaLat * pi / 180;

          double y = sin(deltaLng);
          double x = cos(lat1) * tan(lat2) - sin(lat1) * cos(deltaLng);
          double qiblaAngle = atan2(y, x) * 180 / pi;
          qiblaAngle = (qiblaAngle + 360) % 360; // Normalize to 0-360

          return StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              double? heading = snapshot.data?.heading;
              if (heading == null) {
                return const Center(child: Text("কম্পাস ডেটা পাওয়া যায়নি"));
              }

              // smooth heading apply
              double smoothHeading = _applySmoothing(heading);

              double rotation =
                  ((qiblaAngle - smoothHeading) * (pi / 180) * -1);

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$cityName, $countryName",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 4),
                          ),
                        ),
                        Transform.rotate(
                          angle: rotation,
                          child: const Icon(
                            Icons.navigation,
                            size: 80,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "কিবলা নির্দেশিকা দেখানো হচ্ছে",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: const Text("ইসলামিক টুলস"),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.access_time), text: "নামাজ"),
              Tab(icon: Icon(Icons.fingerprint), text: "তসবীহ"),
              Tab(icon: Icon(Icons.explore), text: "কিবলা"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildPrayerTab(), _buildTasbeehTab(), _buildQiblaTab()],
        ),
        bottomNavigationBar: _isBannerAdReady
            ? SafeArea(
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              )
            : null,
      ),
    );
  }
}
