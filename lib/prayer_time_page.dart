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
import 'package:flutter/services.dart';
import 'ad_helper.dart'; // AdHelper ইম্পোর্ট যোগ করুন

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

  // ---------- Ads ----------
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  Timer? _interstitialTimer; // Interstitial অ্যাডের টাইমার
  bool _interstitialAdShownToday =
      false; // আজকে interstitial অ্যাড দেখানো হয়েছে কিনা
  bool _showInterstitialAds =
      true; // interstitial অ্যাড দেখানো হবে কিনা (সেটিংস থেকে কন্ট্রোল করা যাবে)

  // ---------- Audio ----------
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ---------- MP3 Timer & Notification IDs ----------
  Map<String, Timer> _mp3Timers = {};

  // ---------- Permission Status ----------
  bool _locationPermissionGranted = false;
  bool _notificationPermissionGranted = false;

  // ---------- Internet Status ----------
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadAd();
    _initializeAds(); // অ্যাড সিস্টেম ইনিশিয়ালাইজ করুন
  }

  @override
  void dispose() {
    timer?.cancel();
    _interstitialTimer?.cancel(); // interstitial টাইমার বাতিল করুন
    _bannerAd.dispose();
    _mp3Timers.forEach((key, t) => t.cancel());
    super.dispose();
  }

  // বিজ্ঞাপন লোড করা
  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  // অ্যাড সিস্টেম ইনিশিয়ালাইজেশন
  Future<void> _initializeAds() async {
    try {
      // AdMob SDK ইনিশিয়ালাইজ করুন
      await AdHelper.initialize();

      // সেটিংস লোড করুন
      final prefs = await SharedPreferences.getInstance();

      // interstitial অ্যাড সেটিংস লোড করুন (ডিফল্ট true)
      _showInterstitialAds = prefs.getBool('show_interstitial_ads') ?? true;

      // আজকে interstitial অ্যাড দেখানো হয়েছে কিনা চেক করুন
      final lastShownDate = prefs.getString('last_interstitial_date');
      final today = DateTime.now().toIso8601String().split('T')[0];

      setState(() {
        _interstitialAdShownToday = (lastShownDate == today);
      });

      // ১০ সেকেন্ড পর interstitial অ্যাড শো করার টাইমার সেট করুন
      _startInterstitialTimer();

      print(
        'অ্যাড সিস্টেম ইনিশিয়ালাইজড: interstitial অ্যাড = $_showInterstitialAds, আজকে দেখানো হয়েছে = $_interstitialAdShownToday',
      );
    } catch (e) {
      print('অ্যাড ইনিশিয়ালাইজেশনে ত্রুটি: $e');
    }
  }

  // Interstitial অ্যাড টাইমার শুরু করুন
  void _startInterstitialTimer() {
    _interstitialTimer?.cancel(); // বিদ্যমান টাইমার বাতিল করুন

    _interstitialTimer = Timer(Duration(seconds: 10), () {
      _showInterstitialAdIfNeeded();
    });

    print('Interstitial অ্যাড টাইমার শুরু হয়েছে (১০ সেকেন্ড পর শো হবে)');
  }

  // Interstitial অ্যাড শো করুন যদি প্রয়োজন হয়
  Future<void> _showInterstitialAdIfNeeded() async {
    try {
      // interstitial অ্যাড বন্ধ থাকলে স্কিপ করুন
      if (!_showInterstitialAds) {
        print('Interstitial অ্যাড ইউজার বন্ধ রেখেছেন');
        return;
      }

      // যদি আজকে ইতিমধ্যে interstitial অ্যাড দেখানো হয়ে থাকে তবে স্কিপ করুন
      if (_interstitialAdShownToday) {
        print('ইতিমধ্যে আজ interstitial অ্যাড দেখানো হয়েছে');
        return;
      }

      print('Interstitial অ্যাড শো করার চেষ্টা করা হচ্ছে...');

      // AdHelper এর মাধ্যমে interstitial অ্যাড শো করুন
      await AdHelper.showInterstitialAd(
        onAdShowed: () {
          print('Interstitial অ্যাড শো করা হলো');
          _recordInterstitialShown();
        },
        onAdDismissed: () {
          print('Interstitial অ্যাড ডিসমিস করা হলো');
        },
        onAdFailedToShow: () {
          print('Interstitial অ্যাড শো করতে ব্যর্থ');
        },
        adContext: 'PrayerTimePage',
      );
    } catch (e) {
      print('Interstitial অ্যাড শো করতে ত্রুটি: $e');
    }
  }

  // Interstitial অ্যাড দেখানো রেকর্ড করুন
  void _recordInterstitialShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      await prefs.setString('last_interstitial_date', today);

      setState(() {
        _interstitialAdShownToday = true;
      });

      print('আজকের interstitial অ্যাড দেখানো রেকর্ড করা হলো: $today');
    } catch (e) {
      print('Interstitial অ্যাড রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // interstitial অ্যাড সেটিংস টগল করুন (সেটিংস পেজ থেকে কল করতে পারবেন)
  Future<void> _toggleInterstitialAds(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_interstitial_ads', value);

    setState(() {
      _showInterstitialAds = value;
    });

    print('Interstitial অ্যাড সেটিংস পরিবর্তন: $value');

    // স্ন্যাকবারে মেসেজ দেখান
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'পূর্ণস্ক্রিন অ্যাড সক্রিয় করা হয়েছে'
              : 'পূর্ণস্ক্রিন অ্যাড বন্ধ করা হয়েছে',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ডেটা ইনিশিয়ালাইজেশন
  Future<void> _initializeData() async {
    await _checkPermissions();
    await _loadSavedData();

    // ইন্টারনেট চেক করুন
    final hasInternet = await _checkInternetConnection();
    setState(() {
      _isOnline = hasInternet;
    });

    if (_locationPermissionGranted && hasInternet) {
      fetchLocationAndPrayerTimes();
    }
  }

  // ইন্টারনেট কানেকশন চেক করার মেথড
  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // পারমিশন চেক করা
  Future<void> _checkPermissions() async {
    final prefs = await SharedPreferences.getInstance();

    // লোকেশন পারমিশন চেক
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    _locationPermissionGranted =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    // নোটিফিকেশন পারমিশন চেক
    bool isNotificationAllowed = await AwesomeNotifications()
        .isNotificationAllowed();
    if (!isNotificationAllowed) {
      isNotificationAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    _notificationPermissionGranted = isNotificationAllowed;

    await prefs.setBool('locationPermission', _locationPermissionGranted);
    await prefs.setBool(
      'notificationPermission',
      _notificationPermissionGranted,
    );
  }

  // সময় ফরম্যাট করা (24h to 12h)
  String formatTimeTo12Hour(String time24) {
    try {
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
    } catch (e) {
      return time24;
    }
  }

  // সেভ করা ডেটা লোড করা
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cityName = prefs.getString("cityName") ?? "অজানা";
      countryName = prefs.getString("countryName") ?? "অজানা";
      _locationPermissionGranted = prefs.getBool('locationPermission') ?? false;
      _notificationPermissionGranted =
          prefs.getBool('notificationPermission') ?? false;

      String? savedPrayerTimes = prefs.getString("prayerTimes");
      if (savedPrayerTimes != null) {
        prayerTimes = Map<String, String>.from(jsonDecode(savedPrayerTimes));
        findNextPrayer();
      }
    });

    // নোটিফিকেশন শিডিউল করা (সর্বদা)
    prayerTimes.forEach((prayer, time) async {
      bool soundEnabled = prefs.getBool("azan_sound_$prayer") ?? true;
      _schedulePrayerNotification(prayer, time, soundEnabled);
    });
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
    // প্রথমে ইন্টারনেট চেক করুন
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      setState(() {
        _isOnline = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ইন্টারনেট সংযোগ নেই। সেভ করা সময় দেখানো হচ্ছে।"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isOnline = true;
    });

    if (!_locationPermissionGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("লোকেশন এক্সেস প্রয়োজন")));
      return;
    }

    try {
      // লোকেশন সার্ভিস চেক
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("লোকেশন সার্ভিস সক্ষম করুন")));
        return;
      }

      // বর্তমান পজিশন পাওয়া
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // শহর/দেশের নাম পাওয়া
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          cityName = placemarks[0].locality ?? "অজানা শহর";
          countryName = placemarks[0].country ?? "অজানা দেশ";
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("ডেটা লোড করতে সমস্যা: $e")));
    }
  }

  // পরবর্তী নামাজ খুঁজে বের করা
  void findNextPrayer() {
    final now = DateTime.now();
    DateTime? nextPrayerTime;
    String? nextName;

    prayerTimes.forEach((name, time) {
      try {
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
      } catch (e) {
        print("Error parsing time for $name: $time");
      }
    });

    if (nextPrayerTime != null && nextName != null) {
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
    } else {
      setState(() {
        nextPrayer = "লোড হচ্ছে...";
        countdown = Duration.zero;
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
    if (!_notificationPermissionGranted) return;

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

  // অফলাইন ইন্ডিকেটর
  Widget _buildOfflineIndicator() {
    if (_isOnline) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "অফলাইন মোড - সেভ করা ডেটা",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // পারমিশন স্ট্যাটাস দেখানোর উইজেট
  Widget _buildPermissionStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_locationPermissionGranted)
          ListTile(
            leading: Icon(Icons.location_off, color: Colors.orange),
            title: Text("লোকেশন এক্সেস প্রয়োজন"),
            subtitle: Text("সঠিক নামাজের সময়ের জন্য লোকেশন এক্সেস দিন"),
            trailing: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          ),
        if (!_notificationPermissionGranted)
          ListTile(
            leading: Icon(Icons.notifications_off, color: Colors.orange),
            title: Text("নোটিফিকেশন প্রয়োজন"),
            subtitle: Text("নামাজের রিমাইন্ডার পেতে নোটিফিকেশন অন করুন"),
            trailing: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                AwesomeNotifications().requestPermissionToSendNotifications();
              },
            ),
          ),
      ],
    );
  }

  // অ্যাড স্ট্যাটাস ইন্ডিকেটর (ডিবাগিং/ইনফোর জন্য)
  Widget _buildAdStatusIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _interstitialAdShownToday ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _interstitialAdShownToday ? Icons.check : Icons.schedule,
            size: 12,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            _interstitialAdShownToday
                ? "আজকের অ্যাড দেখানো হয়েছে"
                : "অ্যাড প্রস্তুত",
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // নামাজ ট্যাব বিল্ড করা
  Widget _buildPrayerTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Column(
      children: [
        // অফলাইন ইন্ডিকেটর
        _buildOfflineIndicator(),

        // পারমিশন স্ট্যাটাস
        if (!_locationPermissionGranted || !_notificationPermissionGranted)
          _buildPermissionStatus(),

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
              // লোকেশন এবং রিফ্রেশ বাটন - আলাদা করা হয়েছে
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.green[900]!.withOpacity(0.3)
                      : Colors.grey[100]!,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.green[800]!.withOpacity(0.2)
                              : Colors.green[50]!,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.green[700]!.withOpacity(0.3)
                                    : Colors.green[700]!.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on,
                                size: 12,
                                color: isDark
                                    ? Colors.green[100]!
                                    : Colors.green[700]!,
                              ),
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child: Text(
                                "$cityName, $countryName",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.green[100]!
                                      : Colors.green[800]!,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.green[700]!.withOpacity(0.3)
                            : Colors.green[50]!,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          final hasInternet = await _checkInternetConnection();
                          if (!hasInternet) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "ইন্টারনেট সংযোগ নেই। রিফ্রেশ করা যাচ্ছে না।",
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                backgroundColor: isDark
                                    ? Colors.green[800]!
                                    : Colors.green[100]!,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          fetchLocationAndPrayerTimes();

                          try {
                            await HapticFeedback.lightImpact();
                          } catch (e) {
                            print('Haptic feedback error: $e');
                          }
                        },
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: isDark
                              ? Colors.green[100]!
                              : Colors.green[700]!,
                          size: 16,
                        ),
                        iconSize: 16,
                        padding: const EdgeInsets.all(5),
                        tooltip: "রিফ্রেশ করুন",
                      ),
                    ),
                  ],
                ),
              ),

              // পরবর্তী নামাজ এবং সূর্যোদয়/সূর্যাস্ত সেকশন
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    // বাম পাশ - পরবর্তী নামাজ কাউন্টডাউন
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: EdgeInsets.all(8),
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
                            SizedBox(height: 3),
                            Text(
                              nextPrayer.isNotEmpty
                                  ? nextPrayer
                                  : "লোড হচ্ছে...",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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

                    SizedBox(width: 8),

                    // ডান পাশ - সূর্যোদয়/সূর্যাস্ত
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: EdgeInsets.all(8),
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
                              padding: EdgeInsets.symmetric(
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
                                      SizedBox(width: 3),
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
                                  SizedBox(height: 3),
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
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Column(
                                children: [
                                  Container(
                                    width: 25,
                                    height: 1,
                                    color: Colors.white.withOpacity(0.5),
                                    margin: EdgeInsets.symmetric(vertical: 1),
                                  ),
                                ],
                              ),
                            ),

                            // সূর্যাস্ত
                            Container(
                              padding: EdgeInsets.symmetric(
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
                                      SizedBox(width: 3),
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
                                  SizedBox(height: 3),
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
                  padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: isDark
                            ? Colors.green.shade400
                            : Colors.green.shade700,
                        size: 16,
                      ),
                      SizedBox(width: 5),
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
                  child: prayerTimes.isNotEmpty
                      ? ListView(
                          padding: EdgeInsets.fromLTRB(6, 0, 6, 8),
                          children: prayerTimes.entries
                              .where(
                                (e) =>
                                    e.key != "সূর্যোদয়" &&
                                    e.key != "সূর্যাস্ত",
                              )
                              .map((e) => prayerRow(e.key, e.value))
                              .toList(),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "নামাজের সময় লোড হচ্ছে...",
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: fetchLocationAndPrayerTimes,
                                child: Text("রিফ্রেশ করুন"),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),

        // সালাতের নিষিদ্ধ সময় এবং তথ্য সেকশন
        Container(
          padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // নিষিদ্ধ সময় কার্ড
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
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
                                "ইসলামি শরীয়তে ৩টি সময়ে সালাত আদায় নিষিদ্ধ। আসর ও সূর্যাস্তের ব্যতিক্রমসহ নিষিদ্ধ সময় নির্ণয়ের পদ্ধতি ও মাসআলা নিম্নে দেওয়া হলোঃ \n\n"
                                    "১. সূর্যোদয়ের সময়ঃ সূর্য ওঠা শুরু করার সময় থেকে সম্পূর্ণ উদয় হওয়া পর্যন্ত। "
                                    "এই অ্যাপে সূর্যোদয়ের নিষিদ্ধ সময় ১৫ মিনিট হিসেবে দেখানো হয়েছে।\n\n"
                                    "২. ঠিক দুপুর বা মধ্যাহ্নের সময়ঃ যুহরের ওয়াক্ত শুরু হওয়ার আগের ৩ মিনিট পর্যন্ত। "
                                    "কিন্তু বাড়তি সতর্কতার জন্য ইসলামিক ফাউন্ডেশন যুহরের ওয়াক্তের আগের ৬ মিনিট নিষিদ্ধ সময় হিসেবে নির্ধারণ করেছে। "
                                    "এ সময় সূর্য ঠিক মাথার ওপরে থাকে।\n\n"
                                    "৩. সূর্যাস্তের সময়ঃ সূর্য অস্ত যেতে শুরু করার সময় থেকে পুরোপুরি অস্তমিত হওয়া পর্যন্ত। "
                                    "অ্যাপে এই নিষিদ্ধ সময়ও ১৫ মিনিট হিসেবে দেখানো হয়েছে।\n\n"
                                    "তবে, যদি কোন কারণে ঐ দিনের আসরের সালাত পড়া না হয়, তাহলে সূর্যাস্তের নিষিদ্ধ সময়ের মধ্যেও শুধু আসরের সালাত আদায় করা যাবে। "
                                    "তবে সালাত এত দেরি করে পড়া একেবারেই উচিত নয়।\n\n"
                                    "🔹 নিষিদ্ধ সময়ের ব্যাপারে বিস্তারিত জানতে প্রামাণ্য হাদিস গ্রন্থ পড়ুন।\n\n"
                                    "📌 প্রসঙ্গত উল্লেখঃ পূর্বে সূর্যোদয় ও সূর্যাস্তের নিষিদ্ধ সময় ২৩ মিনিট ধরা হত। "
                                    "কিন্তু আধুনিক বৈজ্ঞানিক গবেষণার আলোকে আলেমগণ মত দিয়েছেন যে এই সময়সীমা ১৫ মিনিটের বেশি নয়। "
                                    "তাই এই অ্যাপে নিষিদ্ধ সময় ২৩ মিনিটের পরিবর্তে ১৫ মিনিট দেখানো হয়েছে।\n\n"
                                    "👉 এই সময়গুলোতে নফল নামাজ পড়া নিষিদ্ধ।",
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

                      SizedBox(height: 4),

                      // সময়ের তালিকা
                      Text(
                        "ভোর:  ${_calculateSunriseProhibitedTime()}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "দুপুর:  ${_calculateDhuhrProhibitedTime()}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4),
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

              SizedBox(width: 8),

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
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 3,
                              offset: Offset(0, 1),
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
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "নফল সালাতের ওয়াক্ত",
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
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 3,
                              offset: Offset(0, 1),
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
                            SizedBox(width: 4),
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
        SizedBox(height: 1),
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
      margin: EdgeInsets.symmetric(horizontal: 4),
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

      // শুরু সময় গণনা করুন (সূর্যাস্তের 15 মিনিট  আগে)
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
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(message, style: TextStyle(fontSize: 14, height: 1.4)),
              SizedBox(height: 16),
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
        title: Text(
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
