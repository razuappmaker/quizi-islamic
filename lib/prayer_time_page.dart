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

  // ডিলিট করবো না ====== যদি নামাজের টাইম নরমাল চাই নিচের এই সেকশন নিব ।  নিচের ২ টা হেল্পার বাদ দিব । নিচে - কমেন্ট করা আছে ----------ডিলিট করবো না --------------
  // =============================Dont Delet ==========Be cearfull==============

  /*  Widget prayerRow(String prayerName, String time) {
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time,
                color: Colors.green.shade700,
                size: 22,
              ),
            ),
            title: Text(
              prayerName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              formatTimeTo12Hour(time),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                      fontSize: 13,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: enabled,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                      onChanged: (value) => _setAzanEnabled(prayerName, value),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }*/ // এই পর্যন্ত ======================

  //  prayerRow widget -নামাজের সময় দেখানোতে এই রং বাভহার হয়েছে ------ ভাল না লাগলে বাদ দিয়ে উপরের কমেন্ট করা অংশ নিলে নরমাল হবে সাথে নিচের ২ টা হেল্পার বাদ দিব ===
  Widget prayerRow(String prayerName, String time) {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance().then(
        (prefs) => prefs.getBool("azan_sound_$prayerName") ?? true,
      ),
      builder: (context, snapshot) {
        bool enabled = snapshot.data ?? true;
        Color prayerColor = getPrayerColor(prayerName);
        IconData prayerIcon = getPrayerIcon(prayerName);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [prayerColor.withOpacity(0.1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: prayerColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: prayerColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                prayerIcon, // এখানে পরিবর্তিত আইকন
                color: prayerColor,
                size: 22,
              ),
            ),
            title: Text(
              prayerName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: prayerColor,
              ),
            ),
            subtitle: Text(
              formatTimeTo12Hour(time),
              style: TextStyle(
                fontSize: 15,
                color: prayerColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: prayerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "আজান",
                    style: TextStyle(
                      fontSize: 13,
                      color: prayerColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: enabled,
                      activeColor: prayerColor,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                      onChanged: (value) => _setAzanEnabled(prayerName, value),
                    ),
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
    return Column(
      children: [
        // Header with location and refresh button
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.green.shade800.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Location and refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              //const SizedBox(width: 5),
                              /*Text(
                                "বর্তমান অবস্থান",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "$cityName, $countryName",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: fetchLocationAndPrayerTimes,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                      iconSize: 20,
                      padding: const EdgeInsets.all(6),
                      tooltip: "রিফ্রেশ করুন",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Next prayer countdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "পরবর্তী ওয়াক্ত",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextPrayer.isNotEmpty ? nextPrayer : "লোড হচ্ছে...",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Modern countdown design
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
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
        const SizedBox(height: 12),
        // Prayer times list
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.green.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "নামাজের সময়সমূহ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
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
      ],
    );
  }

  //-------------নামাজের সময় রঙ করার জন্য ব্যাবহার করেছি ভাল না লাগলে বাদ দিব এই ২ টা হেল্পার বাদ দিয়ে উপরের কমেন্ট অংশ নিবো ।
  // প্রথমে এই দুটি হেল্পার মেথড ক্লাসের বাইরে (build মেথডের বাইরে) যোগ করুন
  Color getPrayerColor(String prayerName) {
    switch (prayerName) {
      case "ফজর":
        return Colors.orange.shade700;
      case "যোহর":
        return Colors.blue.shade700;
      case "আসর":
        return Colors.green.shade700;
      case "মাগরিব":
        return Colors.purple.shade700;
      case "ইশা":
        return Colors.indigo.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // ------------নামাজের সময় রঙ করার জন্য ব্যাবহার করেছি ভাল না লাগলে বাদ দিব এই ২ টা হেল্পার বাদ দিয়ে উপরের কমেন্ট অংশ নিবো ।
  IconData getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case "ফজর":
        return Icons.wb_twilight;
      case "যোহর":
        return Icons.wb_sunny;
      case "আসর":
        return Icons.brightness_4;
      case "মাগরিব":
        return Icons.nights_stay;
      case "ইশা":
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  //-----------
  // Helper method for time units
  Widget _buildTimeUnit(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  // Helper method for divider
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 6),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        //elevation: 3,
        //shape: const RoundedRectangleBorder(
        // borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        //),
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
