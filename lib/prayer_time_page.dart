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

  // ডেটা ইনিশিয়ালাইজেশন
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

  // লোড সেভ করা ডেটা
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

    // প্রতিটি নামাজের জন্য নোটিফিকেশন শিডিউল রাখা
    prayerTimes.forEach((prayer, time) async {
      bool soundEnabled = prefs.getBool("azan_sound_$prayer") ?? true;
      _schedulePrayerNotification(prayer, time, soundEnabled);
    });
  }

  // পুরনো নোটিফিকেশন বাতিল করা
  Future<void> _cancelAllPrayerNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
    } catch (e) {
      print("Error cancelling notifications: $e");
    }
  }

  // ডেটা সেভ করা
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cityName", cityName ?? "");
    await prefs.setString("countryName", countryName ?? "");
    await prefs.setString("prayerTimes", jsonEncode(prayerTimes));
  }

  // লোকেশন এবং নামাজের সময় ফেচ করা
  Future<void> fetchLocationAndPrayerTimes() async {
    try {
      // লোকেশন সার্ভিস চেক
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      // পারমিশন চেক
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // বর্তমান পজিশন পাওয়া
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // শহর/দেশের নাম পাওয়া
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

      // আজকের তারিখ সহ API URL বিল্ড করা
      final today = DateTime.now();
      final formattedDate =
          "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";
      final url =
          "https://api.aladhan.com/v1/timings/$formattedDate?latitude=${position.latitude}&longitude=${position.longitude}&method=2";

      // ডেটা ফেচ করা
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
            "সূর্যোদয়": timings["Sunrise"],
            "সূর্যাস্ত": timings["Sunset"],
          };
        });

        // পরবর্তী নামাজ খুঁজে বের করা
        findNextPrayer();

        // লোকালি সেভ করা
        _saveData();

        // পুনরায় শিডিউল করার আগে বিদ্যমান নোটিফিকেশন বাতিল করা
        _cancelAllPrayerNotifications();

        // নোটিফিকেশন শিডিউল করা
        final prefs = await SharedPreferences.getInstance();
        for (final entry in prayerTimes.entries) {
          final prayer = entry.key;
          final time = entry.value;
          final soundEnabled = prefs.getBool("azan_sound_$prayer") ?? true;
          _schedulePrayerNotification(prayer, time, soundEnabled);
        }
      }
    } catch (e) {
      print("Location fetch error: $e");
    }
  }

  // পরবর্তী নামাজ খুঁজে বের করা
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

  // আজান সক্ষম/অক্ষম সেট করা
  Future<void> _setAzanEnabled(String prayerName, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("azan_sound_$prayerName", enabled);

    // যদি অক্ষম করা হয় তবে পূর্ববর্তী mp3 টাইমার বাতিল করুন
    if (!enabled) {
      _mp3Timers[prayerName]?.cancel();
      _mp3Timers.remove(prayerName);
    } else {
      // যদি সক্ষম করা হয় তবে mp3 পুনরায় শিডিউল করুন
      if (prayerTimes[prayerName] != null) {
        _scheduleMp3ForPrayer(prayerName, prayerTimes[prayerName]!);
      }
    }

    setState(() {});
  }

  // নামাজের জন্য MP3 শিডিউল করা (শুধুমাত্র সক্ষম থাকলে)
  Future<void> _scheduleMp3ForPrayer(String prayerName, String time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool soundEnabled = prefs.getBool("azan_sound_$prayerName") ?? true;

      if (!soundEnabled) return; // যদি অক্ষম থাকে তবে স্কিপ করুন

      final now = DateTime.now();
      final parts = time.split(":");

      DateTime prayerDate = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // যদি সময় ইতিমধ্যেই পাস হয়ে যায়, তাহলে আগামীকালের জন্য
      if (prayerDate.isBefore(now)) {
        prayerDate = prayerDate.add(const Duration(days: 1));
      }

      // ৫ মিনিট আগে mp3 প্লে
      final mp3Time = prayerDate.subtract(const Duration(minutes: 5));
      if (mp3Time.isAfter(now)) {
        _mp3Timers[prayerName]?.cancel(); // বিদ্যমান টাইমার বাতিল করুন

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

  // নামাজের নোটিফিকেশন শিডিউল করা (সর্বদা)
  Future<void> _schedulePrayerNotification(
    String prayerName,
    String time,
    bool soundEnabled,
  ) async {
    try {
      // এই নামাজের জন্য বিদ্যমান কোনো নোটিফিকেশন বাতিল করুন
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

      // যদি সময় ইতিমধ্যেই পাস হয়ে যায়, তাহলে আগামীকালের জন্য
      if (prayerDate.isBefore(now)) {
        prayerDate = prayerDate.add(const Duration(days: 1));
      }

      // ১০ মিনিট আগে নোটিফিকেশন (সর্বদা শিডিউল করুন)
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
            repeats: true, // দৈনিক পুনরাবৃত্তি
          ),
        );
      }

      // সক্ষম থাকলে MP3 ও শিডিউল করুন
      if (soundEnabled) {
        _scheduleMp3ForPrayer(prayerName, time);
      }
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  // নামাজের সারি উইজেট
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
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            leading: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: prayerColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(prayerIcon, color: prayerColor, size: 16),
            ),
            title: Text(
              prayerName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            subtitle: Text(
              formatTimeTo12Hour(time),
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: prayerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "আজান",
                    style: TextStyle(
                      fontSize: 10,
                      color: prayerColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Transform.scale(
                    scale: 0.55,
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

  // নামাজের রং পাওয়া
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

  // নামাজের আইকন পাওয়া
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

  // নামাজ ট্যাব বিল্ড করা
  Widget _buildPrayerTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Column(
      children: [
        // হেডার - লোকেশন এবং রিফ্রেশ বাটন
        Container(
          padding: EdgeInsets.fromLTRB(14, isSmallScreen ? 12 : 14, 14, 10),
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
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.green.shade800.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // লোকেশন এবং রিফ্রেশ বাটন
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 11,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "$cityName, $countryName",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 15,
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
                        size: 16,
                      ),
                      iconSize: 16,
                      padding: const EdgeInsets.all(4),
                      tooltip: "রিফ্রেশ করুন",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // পরবর্তী নামাজ এবং সূর্যোদয়/সূর্যাস্ত সেকশন
              Row(
                children: [
                  // বাম পাশ - পরবর্তী নামাজ কাউন্টডাউন
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.08),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
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
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            nextPrayer.isNotEmpty ? nextPrayer : "লোড হচ্ছে...",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
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

                  const SizedBox(width: 8),

                  // ডান পাশ - সূর্যোদয়/সূর্যাস্ত
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.3),
                            Colors.deepOrange.withOpacity(0.2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // সূর্যোদয়
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.wb_sunny,
                                      color: Colors.yellow.shade200,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "সূর্যোদয়",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  prayerTimes.containsKey("সূর্যোদয়")
                                      ? formatTimeTo12Hour(
                                          prayerTimes["সূর্যোদয়"]!,
                                        )
                                      : "--:--",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ডিভাইডার
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Column(
                              children: [
                                Container(
                                  width: 25,
                                  height: 1,
                                  color: Colors.white.withOpacity(0.5),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // সূর্যাস্ত
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.nightlight_round,
                                      color: Colors.orange.shade200,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "সূর্যাস্ত",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  prayerTimes.containsKey("সূর্যাস্ত")
                                      ? formatTimeTo12Hour(
                                          prayerTimes["সূর্যাস্ত"]!,
                                        )
                                      : "--:--",
                                  style: TextStyle(
                                    fontSize: 10,
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
                  ),
                ],
              ),
            ],
          ),
        ),

        // নামাজের সময় তালিকা সেকশন
        Expanded(
          child: Container(
            color: isDark ? Colors.grey[900] : Colors.grey.shade50,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: isDark
                            ? Colors.green.shade400
                            : Colors.green.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "নামাজের সময়সমূহ",
                        style: TextStyle(
                          fontSize: 14,
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
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
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

        // সালাতের নিষিদ্ধ সময় এবং তথ্য সেকশন
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // নিষিদ্ধ সময় কার্ড
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
                              fontSize: 14,
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
                              size: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // সময়ের তালিকা
                      Text(
                        "ভোর:  ${_calculateSunriseProhibitedTime()}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "দুপুর:  ${_calculateDhuhrProhibitedTime()}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "সন্ধ্যা:  ${_calculateSunsetProhibitedTime()}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // নফল সালাত এবং বিশেষ ফ্যাক্ট কার্ড
              Expanded(
                child: Column(
                  children: [
                    // নফল সালাত
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
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "নফল সালাত",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // বিশেষ ফ্যাক্ট
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "বিশেষ ফ্যাক্ট",
                                style: TextStyle(
                                  fontSize: 13,
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
            ],
          ),
        ),
      ],
    );
  }

  // সময় ইউনিট বিল্ড করার হেল্পার মেথড
  Widget _buildTimeUnit(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height < 700 ? 18 : 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  // ডিভাইডার বিল্ড করার হেল্পার মেথড
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // সূর্যোদয় নিষিদ্ধ সময় ক্যালকুলেশন
  String _calculateSunriseProhibitedTime() {
    if (prayerTimes.containsKey("সূর্যোদয়")) {
      final sunriseTime = prayerTimes["সূর্যোদয়"]!;
      final parts = sunriseTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final startTime = TimeOfDay(hour: hour, minute: minute);

      // শেষ সময় গণনা করুন (সূর্যোদয়ের 15 মিনিট পর)
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

  // যোহর নিষিদ্ধ সময় ক্যালকুলেশন
  String _calculateDhuhrProhibitedTime() {
    if (prayerTimes.containsKey("যোহর")) {
      final dhuhrTime = prayerTimes["যোহর"]!;
      final parts = dhuhrTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // শুরু সময় গণনা করুন (যোহরের 6 মিনিট আগে)
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

  // সূর্যাস্ত নিষিদ্ধ সময় ক্যালকুলেশন
  String _calculateSunsetProhibitedTime() {
    if (prayerTimes.containsKey("সূর্যাস্ত")) {
      final sunsetTime = prayerTimes["সূর্যাস্ত"]!;
      final parts = sunsetTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // শুরু সময় গণনা করুন (সূর্যাস্তের 15 মিনিট আগে)
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

  // TimeOfDay কে স্ট্রিং ফরম্যাটে কনভার্ট করার হেল্পার মেথড
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
          padding: const EdgeInsets.all(16),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 16),
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
            fontSize: 17,
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
