// prayer page
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
            "সূর্যোদয়": timings["Sunrise"], // Add sunrise
            "সূর্যাস্ত": timings["Sunset"], // Add sunset
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
        Color prayerColor = getPrayerColor(prayerName);
        IconData prayerIcon = getPrayerIcon(prayerName);

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? Colors.grey[850] : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          // Reduced vertical margin
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ListTile(
            dense: true,
            // This makes the ListTile more compact
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4, // Reduced vertical padding
            ),
            leading: Container(
              padding: const EdgeInsets.all(6), // Reduced padding
              decoration: BoxDecoration(
                color: prayerColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                prayerIcon,
                color: prayerColor,
                size: 18, // Reduced icon size
              ),
            ),
            title: Text(
              prayerName,
              style: TextStyle(
                fontSize: 15, // Slightly reduced font size
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            subtitle: Text(
              formatTimeTo12Hour(time),
              style: TextStyle(
                fontSize: 13, // Slightly reduced font size
                color: subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              // Reduced padding
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
                      fontSize: 11, // Reduced font size
                      color: prayerColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2), // Reduced spacing
                  Transform.scale(
                    scale: 0.6, // Further reduced switch size
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

  Color getPrayerColor(String prayerName) {
    switch (prayerName) {
      case "ফজর":
        return Colors.orange.shade700;
      case "যোহর":
        return Colors.blue.shade700;
      case "আসর":
        return Colors.green.shade700;
      case "মাগরিব":
        return Colors.purple;
      case "ইশা":
        return Colors.indigo;
      default:
        return Colors.grey.shade700;
    }
  }

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

  Widget _buildPrayerTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header with location and refresh button
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
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
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.green.shade800.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
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
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "$cityName, $countryName",
                            style: const TextStyle(
                              fontSize: 16,
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
                    ),
                    child: IconButton(
                      onPressed: fetchLocationAndPrayerTimes,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
                      iconSize: 18,
                      padding: const EdgeInsets.all(5),
                      tooltip: "রিফ্রেশ করুন",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Next prayer and sunrise/sunset section
              Row(
                children: [
                  // Left side - Next prayer countdown (60%)
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.08),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "পরবর্তী ওয়াক্ত",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextPrayer.isNotEmpty ? nextPrayer : "লোড হচ্ছে...",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
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
                                _buildTimeUnit(
                                  "মিনিট",
                                  countdown.inMinutes % 60,
                                ),
                                _buildDivider(),
                                _buildTimeUnit(
                                  "সেকেন্ড",
                                  countdown.inSeconds % 60,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Right side - Sunrise/Sunset (40%)
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.3),
                            Colors.deepOrange.withOpacity(0.2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Sunrise - Top section with orange background
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.wb_sunny,
                                      color: Colors.yellow.shade200,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "সূর্যোদয়",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prayerTimes.containsKey("সূর্যোদয়")
                                      ? formatTimeTo12Hour(
                                          prayerTimes["সূর্যোদয়"]!,
                                        )
                                      : "--:--",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Divider with sun icon
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Container(
                                  width: 30,
                                  height: 1,
                                  color: Colors.white.withOpacity(0.5),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Sunset - Bottom section with deep orange background
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.nightlight_round,
                                      color: Colors.orange.shade200,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "সূর্যাস্ত",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prayerTimes.containsKey("সূর্যাস্ত")
                                      ? formatTimeTo12Hour(
                                          prayerTimes["সূর্যাস্ত"]!,
                                        )
                                      : "--:--",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), //-----------
                ],
              ),
            ],
          ),
        ),

        // Prayer times list section - এই অংশটি যোগ করুন
        Expanded(
          child: Container(
            color: isDark ? Colors.grey[900] : Colors.grey.shade50,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: isDark
                            ? Colors.green.shade400
                            : Colors.green.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "নামাজের সময়সমূহ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    children: [
                      // শুধুমাত্র নামাজের সময়গুলো দেখাবে (সূর্যোদয়/সূর্যাস্ত নয়)
                      if (prayerTimes.isNotEmpty)
                        ...prayerTimes.entries
                            .where(
                              (e) =>
                                  e.key != "সূর্যোদয়" && e.key != "সূর্যাস্ত",
                            )
                            .map((e) => prayerRow(e.key, e.value))
                            .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // সালাতের নিষিদ্ধ সময় সেকশন
        // সালাতের নিষিদ্ধ সময় সেকশন
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // বামে - নিষিদ্ধ সময় (প্রফেশনাল লুক)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12), // চারপাশে ফাঁকা জায়গা
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // হেডার
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "নিষিদ্ধ সময়",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showFloatingInfo(
                                context,
                                "সালাতের নিষিদ্ধ সময় সম্পর্কে",
                                "নবী করিম (সা.) তিন সময়ে নামাজ পড়তে নিষেধ করেছেন:\n\n"
                                    "১. সূর্যোদয়ের সময় থেকে পরবর্তী ১৫ মিনিট\n"
                                    "২. ঠিক দুপুরে যখন সূর্য মাথার উপরে থাকে\n"
                                    "৩. সূর্যাস্তের আগের ১৫ মিনিট\n\n"
                                    "এই সময়গুলোতে নফল নামাজ পড়া নিষিদ্ধ।",
                              );
                            },
                            child: Icon(
                              Icons.info_outline,
                              color: isDark
                                  ? Colors.blue[200]
                                  : Colors.blue[700],
                              size: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      // টাইম লিস্ট
                      Text(
                        "ভোর:  ${_calculateSunriseProhibitedTime()}",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "দুপুর:  ${_calculateDhuhrProhibitedTime()}",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "সন্ধ্যা:  ${_calculateSunsetProhibitedTime()}",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // const SizedBox(width: 4),

            // ডান পাশে ২ ভাগে ভাগ করা কলাম (নফল + বিশেষ ফ্যাক্ট)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  right: 12,
                  bottom: 12,
                  // left নেই
                ), // left বাদ // উপরে ফাঁকা
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // উপরে - নফল সালাত
                    GestureDetector(
                      onTap: () {
                        _showFloatingInfo(
                          context,
                          "নফল সালাতের ওয়াক্ত",
                          "নফল নামাজ পড়ার উত্তম সময়:\n\n"
                              "• তাহাজ্জুদ - রাতের শেষ তৃতীয়াংশ\n"
                              "• ইশরাক - সূর্যোদয়ের ১৫-২০ মিনিট পর\n"
                              "• চাশত - সূর্যোদয়ের ২-৩ ঘন্টা পর\n"
                              "• আউয়াবীন - মাগরিবের পর\n"
                              "• তাহিয়্যাতুল ওযু - ওযুর পর\n"
                              "• তাহিয়্যাতুল মসজিদ - মসজিদে প্রবেশের পর",
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.blue,
                              size: 18,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                "নফল সালাতের ওয়াক্ত",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),
                    //নফল সালাতের ওয়াক্ত আর বিশেষ ফ্যাক্ট—এই দুইটা কার্ড/সেকশনের মাঝের gap
                    // নিচে - বিশেষ ফ্যাক্ট
                    GestureDetector(
                      onTap: () {
                        _showFloatingInfo(
                          context,
                          "সালাত সম্পর্কে বিশেষ ফ্যাক্ট",
                          "সালাত সম্পর্কে কিছু বিশেষ তথ্য:\n\n"
                              "• দিনে ৫ ওয়াক্ত নামাজ ফরজ\n"
                              "• জুমার নামাজ সপ্তাহিক ফরজ\n"
                              "• নামাজ ইসলামের দ্বিতীয় স্তম্ভ\n"
                              "• নামাজ মুমিনের মিরাজ\n"
                              "• নামাজ আল্লাহর সাথে সংযোগ স্থাপনের মাধ্যম\n"
                              "• নামাজ গুনাহ মাফের কারণ\n"
                              "• নামাজ ধৈর্য্য ও শৃঙ্খলা শেখায়",
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                "বিশেষ ফ্যাক্ট",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ), //-------
      ],
    );
  }

  // ... rest of the existing code ...

  // Next prayer countdown

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

  // নিষিদ্ধ সময়ের row widget
  Widget _buildProhibitedTimeRow(String title, String time, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          "$title: ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // সূর্যোদয় নিষিদ্ধ সময় calculation মেথডটি পরিবর্তন করুন
  String _calculateSunriseProhibitedTime() {
    if (prayerTimes.containsKey("সূর্যোদয়")) {
      final sunriseTime = prayerTimes["সূর্যোদয়"]!;
      final parts = sunriseTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final startTime = TimeOfDay(hour: hour, minute: minute);

      // Calculate end time (15 minutes after sunrise)
      int endMinute = minute + 15;
      int endHour = hour;
      if (endMinute >= 60) {
        endHour += 1;
        endMinute -= 60;
      }
      final endTime = TimeOfDay(hour: endHour, minute: endMinute);

      return "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
    }
    return "--:-- - --:--";
  }

  // জোহর নিষিদ্ধ সময় calculation মেথডটি পরিবর্তন করুন
  String _calculateDhuhrProhibitedTime() {
    if (prayerTimes.containsKey("যোহর")) {
      final dhuhrTime = prayerTimes["যোহর"]!;
      final parts = dhuhrTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Calculate start time (6 minutes before dhuhr)
      int startMinute = minute - 6;
      int startHour = hour;
      if (startMinute < 0) {
        startHour -= 1;
        startMinute += 60;
      }
      final startTime = TimeOfDay(hour: startHour, minute: startMinute);

      final endTime = TimeOfDay(hour: hour, minute: minute);

      return "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
    }
    return "--:-- - --:--";
  }

  // সূর্যাস্ত নিষিদ্ধ সময় calculation মেথডটি পরিবর্তন করুন
  String _calculateSunsetProhibitedTime() {
    if (prayerTimes.containsKey("সূর্যাস্ত")) {
      final sunsetTime = prayerTimes["সূর্যাস্ত"]!;
      final parts = sunsetTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Calculate start time (15 minutes before sunset)
      int startMinute = minute - 15;
      int startHour = hour;
      if (startMinute < 0) {
        startHour -= 1;
        startMinute += 60;
      }
      final startTime = TimeOfDay(hour: startHour, minute: startMinute);

      final endTime = TimeOfDay(hour: hour, minute: minute);

      return "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
    }
    return "--:-- - --:--";
  }

  // TimeOfDay কে string format এ convert করার helper method
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('h:mm').format(dateTime);
  }

  // ফ্লোটিং তথ্য প্রদর্শন
  void _showFloatingInfo(BuildContext context, String title, String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
            color: Colors.white,
          ),
        ),
      ),
      body: _buildPrayerTab(),
      bottomNavigationBar: _isBannerAdReady
          ? SafeArea(
              child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
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
