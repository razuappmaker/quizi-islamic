import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tasbeeh_page.dart';
import 'qiblah_page.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({Key? key}) : super(key: key);

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {
  // ---------- Prayer Times ----------
  String? cityName = "Loading...";
  String? countryName = "Loading...";
  Map<String, String> prayerTimes = {};
  String nextPrayer = "";
  Duration countdown = Duration.zero;
  Timer? timer;

  // ---------- Banner Ad ----------
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  // ---------- Audio ----------
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ---------- MP3 Timer & Notification IDs ----------
  Map<String, Timer> _mp3Timers = {};

  @override
  void initState() {
    super.initState();

    _initializeData();

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
        //soundSource: 'resource://raw/azan',  // এজন্য মোবাইলের ডিফল্ট সাউন্ড প্লে হবে
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
    _bannerAd.dispose();
    _mp3Timers.forEach((key, t) => t.cancel());
    super.dispose();
  }

  // নতুন মেথড: ডেটা ইনিশিয়ালাইজেশন
  Future<void> _initializeData() async {
    await _loadSavedData();
    fetchLocationAndPrayerTimes();
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

    // Restore schedule for each prayer (always schedule notifications)
    prayerTimes.forEach((prayer, time) async {
      bool soundEnabled = prefs.getBool("azan_sound_$prayer") ?? true;
      _schedulePrayerNotification(prayer, time, soundEnabled);
    });
  }

  // 👉 এখানে রাখবেন এই কোড টিকু হল যদি পুরবের নোটিফিকেশন বার বার না আসে -----
  Future<void> _cancelAllPrayerNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
      print("All previous prayer notifications cancelled.");
    } catch (e) {
      print("Error cancelling notifications: $e");
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cityName", cityName ?? "");
    await prefs.setString("countryName", countryName ?? "");
    await prefs.setString("prayerTimes", jsonEncode(prayerTimes));
  }

  Future<void> fetchLocationAndPrayerTimes() async {
    try {
      // Check location services
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // Get city/country name
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          cityName = placemarks[0].locality ?? "Unknown City";
          countryName = placemarks[0].country ?? "Unknown Country";
        });
      }

      // Build API URL with today's date
      final today = DateTime.now();
      final formattedDate =
          "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";
      final url =
          "https://api.aladhan.com/v1/timings/$formattedDate?latitude=${position.latitude}&longitude=${position.longitude}&method=2";

      // Fetch data
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

        // Find next prayer
        findNextPrayer();

        // Save locally
        _saveData();

        // Cancel existing notifications before rescheduling
        _cancelAllPrayerNotifications(); // আগের নোটিফিকেশন যদি আসে তাহিলে মুছে যাবে এটার জন্য

        // Schedule notifications
        final prefs = await SharedPreferences.getInstance();
        for (final entry in prayerTimes.entries) {
          final prayer = entry.key;
          final time = entry.value;
          final soundEnabled = prefs.getBool("azan_sound_$prayer") ?? true;
          _schedulePrayerNotification(prayer, time, soundEnabled);
        }
      } else {
        print("Failed to load prayer times: ${response.statusCode}");
      }
    } catch (e, stack) {
      print("Location fetch error: $e");
      print(stack);
    }
  }

  /*Future<void> fetchLocationAndPrayerTimes() async {
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
          //"http://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=2";
          //"https://api.aladhan.com/timingsByAddress/09-03-2015?address=Dubai,UAE&method=8";
          "https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=2";

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

        // Schedule notifications for all prayers
        final prefs = await SharedPreferences.getInstance();
        prayerTimes.forEach((prayer, time) async {
          bool soundEnabled = prefs.getBool("azan_sound_$prayer") ?? true;
          _schedulePrayerNotification(prayer, time, soundEnabled);
        });
      }
    } catch (e) {
      print("Location fetch error: $e");
    }
  }*/

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

  Future<void> _setAzanEnabled(String prayerName, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("azan_sound_$prayerName", enabled);

    // Cancel previous mp3 timer if disabled
    if (!enabled) {
      _mp3Timers[prayerName]?.cancel();
      _mp3Timers.remove(prayerName);
    } else {
      // Re-schedule mp3 if enabled
      if (prayerTimes[prayerName] != null) {
        _scheduleMp3ForPrayer(prayerName, prayerTimes[prayerName]!);
      }
    }

    setState(() {});
  }

  // ---------- Schedule MP3 for Prayer (only if enabled) ----------
  Future<void> _scheduleMp3ForPrayer(String prayerName, String time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool soundEnabled = prefs.getBool("azan_sound_$prayerName") ?? true;

      if (!soundEnabled) return; // Skip if disabled

      final now = DateTime.now();
      final parts = time.split(":");

      DateTime prayerDate = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // যদি সময় already passed হয়ে যায়, তাহলে আগামীকালের জন্য
      if (prayerDate.isBefore(now)) {
        prayerDate = prayerDate.add(const Duration(days: 1));
      }

      // ৫ মিনিট আগে mp3 play
      final mp3Time = prayerDate.subtract(const Duration(minutes: 5));
      if (mp3Time.isAfter(now)) {
        _mp3Timers[prayerName]?.cancel(); // Cancel existing timer

        _mp3Timers[prayerName] = Timer(mp3Time.difference(now), () async {
          await _audioPlayer.play(AssetSource('assets/sounds/azan.mp3'));

          // পরের দিনের জন্য আবার সেট করুন
          Timer(const Duration(hours: 24), () {
            _scheduleMp3ForPrayer(prayerName, time);
          });
        });
      }
    } catch (e) {
      print("Error scheduling MP3: $e");
    }
  }

  // ---------- Schedule Prayer Notification (always) ----------
  Future<void> _schedulePrayerNotification(
    String prayerName,
    String time,
    bool soundEnabled,
  ) async {
    try {
      // Cancel any existing notification for this prayer
      await AwesomeNotifications().cancel(prayerName.hashCode);

      final now = DateTime.now();
      final parts = time.split(":");

      DateTime prayerDate = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // যদি সময় already passed হয়ে যায়, তাহলে আগামীকালের জন্য
      if (prayerDate.isBefore(now)) {
        prayerDate = prayerDate.add(const Duration(days: 1));
      }

      // ১০ মিনিট আগে notification (always schedule)
      final notificationTime = prayerDate.subtract(const Duration(minutes: 10));
      if (notificationTime.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: prayerName.hashCode,
            channelKey: 'azan_channel',
            title: 'নামাজের সময়',
            body: '$prayerName নামাজ শুরু হওয়ার ১০ মিনিট বাকি',
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            hour: notificationTime.hour,
            minute: notificationTime.minute,
            second: 0,
            repeats: true, // Daily repeat
          ),
        );
      }

      // Also schedule MP3 if enabled
      if (soundEnabled) {
        _scheduleMp3ForPrayer(prayerName, time);
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
                  onChanged: (value) => _setAzanEnabled(prayerName, value),
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
          // margin: const EdgeInsets.all(16), // পরবর্তী ওয়াক্ত ছোট করর জন্য -----
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          color: Colors.green[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(10),
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
        _buildTestButtons(), // টেস্ট বাটন যোগ করা হলো------------
      ],
    );
  }

  // ---------- টেস্ট বাটন উইজেট ---------------------
  Widget _buildTestButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // নোটিফিকেশন টেস্ট বাটন
          ElevatedButton.icon(
            onPressed: () async {
              print("Test Notification button pressed");

              try {
                bool isAllowed = await AwesomeNotifications()
                    .isNotificationAllowed();
                print("Notification allowed: $isAllowed");

                if (isAllowed) {
                  final testNotificationId = DateTime.now()
                      .millisecondsSinceEpoch
                      .remainder(100000);

                  await AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: testNotificationId,
                      channelKey: 'azan_channel',
                      title: 'পরীক্ষামূলক নোটিফিকেশন',
                      body:
                          'এটি একটি টেস্ট নোটিফিকেশন। নামাজের সময় হলে এমন নোটিফিকেশন পাবেন।',
                      notificationLayout: NotificationLayout.Default,
                    ),
                  );
                  print("Test notification created");
                } else {
                  print("Notification permission denied");
                  AwesomeNotifications().requestPermissionToSendNotifications();
                }
              } catch (e) {
                print("Notification error: $e");
              }
            },
            icon: const Icon(Icons.notifications),
            label: const Text("নোটিফিকেশন টেস্ট করুন"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // আযান সাউন্ড টেস্ট বাটন
          ElevatedButton.icon(
            onPressed: () async {
              print("Test Azan Sound button pressed");

              try {
                await _audioPlayer.play(AssetSource('assets/sounds/azan.mp3'));
                print("Azan audio play called");

                // সাফল্য বার্তা দেখান
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('আযানের সাউন্ড টেস্ট করা হচ্ছে...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                print("Audio play error: $e");

                // ত্রুটি বার্তা দেখান
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'সাউন্ড ফাইল লোড করতে সমস্যা হচ্ছে। assets/sounds/azan.mp3 চেক করুন।',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.volume_up),
            label: const Text("আযান সাউন্ড টেস্ট করুন"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  } //-------------------------------Test===========

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: const Text(
            "আজকের সময়",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: "নামাজ"),
              Tab(icon: Icon(Icons.fingerprint), text: "তসবিহ"),
              Tab(icon: Icon(Icons.explore), text: "কেবলা"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPrayerTab(),

            // তসবিহ ট্যাব
            Padding(padding: const EdgeInsets.all(12.0), child: TasbeehPage()),

            // কেবলা ট্যাব
            Padding(padding: const EdgeInsets.all(12.0), child: QiblaPage()),
          ],
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
