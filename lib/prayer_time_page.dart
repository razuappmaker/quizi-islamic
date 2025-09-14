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

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time,
                color: Colors.green.shade700,
                size: 24,
              ),
            ),
            title: Text(
              prayerName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              formatTimeTo12Hour(time),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "আজান",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: enabled,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: Colors.grey.shade300,
                    onChanged: (value) => _setAzanEnabled(prayerName, value),
                  ),
                ],
              ),
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
        // Header with location and refresh button
        // Header with location and refresh button
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      Colors.green.shade900,
                      Colors.green.shade800,
                      Colors.green.shade700,
                    ]
                  : [
                      Colors.green.shade600,
                      Colors.green.shade500,
                      Colors.green.shade400,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.green.shade800.withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Location and refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "বর্তমান অবস্থান",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "$cityName, $countryName",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: fetchLocationAndPrayerTimes,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: "রিফ্রেশ করুন",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Next prayer countdown - New modern design
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "পরবর্তী ওয়াক্ত",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      nextPrayer,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 0),
                    // Modern countdown design
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTimeUnit("ঘণ্টা", countdown.inHours),
                          _buildDivider(),
                          _buildTimeUnit("মিনিট", countdown.inMinutes % 60),
                          _buildDivider(),
                          _buildTimeUnit("সেকেন্ড", countdown.inSeconds % 60),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Prayer times list
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "নামাজের সময়সমূহ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    children: [
                      ...prayerTimes.entries
                          .map((e) => prayerRow(e.key, e.value))
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Test buttons
        //_buildTestButtons(),//------------
      ],
    );
  }

  /*
  // ---------- টেস্ট বাটন উইজেট ---------------------
  Widget _buildTestButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
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

                  // Show success snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('নোটিফিকেশন টেস্ট করা হয়েছে'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  print("Notification permission denied");
                  AwesomeNotifications().requestPermissionToSendNotifications();
                }
              } catch (e) {
                print("Notification error: $e");
              }
            },
            icon: const Icon(Icons.notifications_active, size: 20),
            label: const Text("নোটিফিকেশন টেস্ট করুন"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                    backgroundColor: Colors.green,
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
            icon: const Icon(Icons.volume_up, size: 20),
            label: const Text("আযান সাউন্ড টেস্ট করুন"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }*/
  // Helper method for time units
  Widget _buildTimeUnit(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  // Helper method for divider
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          "আজকের নামাজের সময়",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: _buildPrayerTab(),
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
    );
  }
}
