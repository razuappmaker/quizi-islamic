// lib/pages/ifter_time_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'ad_helper.dart'; // AdHelper ইম্পোর্ট যোগ করুন

class IfterTimePage extends StatefulWidget {
  const IfterTimePage({Key? key}) : super(key: key);

  @override
  State<IfterTimePage> createState() => _IfterTimePageState();
}

class _IfterTimePageState extends State<IfterTimePage>
    with SingleTickerProviderStateMixin {
  // ---------- Prayer Times from SharedPreferences ----------
  String? cityName = "Loading...";
  String? countryName = "Loading...";
  Map<String, String> prayerTimes = {};
  Duration iftarCountdown = Duration.zero;
  Timer? iftarTimer;

  // Animation controller for countdown pulse effect
  late AnimationController _animationController;
  late Animation<double> _animation;

  // ---------- Ads ----------
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  Timer? _interstitialTimer; // Interstitial অ্যাডের টাইমার
  bool _interstitialAdShownToday =
      false; // আজকে interstitial অ্যাড দেখানো হয়েছে কিনা
  bool _showInterstitialAds =
      true; // interstitial অ্যাড দেখানো হবে কিনা (সেটিংস থেকে কন্ট্রোল করা যাবে)

  // ---------- Hadith List ----------
  final List<String> _ramadanHadiths = [
    "রমযান মাস, এতে নাযিল করা হয়েছে কুরআন, যা মানুষের জন্য হিদায়াত এবং সৎপথের দিক-নির্দেশনা ও সত্যাসত্যের পার্থক্যকারী। সূরা আল-বাকারাহ ২:১৮৫",
    "হে ঈমানদারগণ! তোমাদের উপর রোযা ফরয করা হয়েছে, যেমন ফরয করা হয়েছিল তোমাদের পূর্ববর্তীদের উপর, যাতে তোমরা মুত্তাকী হতে পার। সূরা আল-বাকারাহ ২:১৮৩",
    "আর যে কেউ অসুস্থ অথবা সফরে থাকবে, সে যেন অন্য দিনে সংখ্যাটি পূর্ণ করে। আল্লাহ তোমাদের জন্য সহজ চান এবং তোমাদের জন্য কঠোরতা চান না। সূরা আল-বাকারাহ ২:১৮৫",
    "যখন রমজান মাস প্রবেশ করে, জান্নাতের দরজাগুলো খুলে দেওয়া হয়, জাহান্নামের দরজাগুলো বন্ধ করে দেওয়া হয় এবং শয়তানদের শিকলবদ্ধ করা হয়। সহিহ বুখারি, হাদিস: ১৮৯৯; সহিহ মুসলিম, হাদিস: ১০৭৯",
    "মানুষের প্রত্যেকটি আমল বহু গুণ বৃদ্ধি করা হয়। আল্লাহ বলেন: রোযা ছাড়া। নিশ্চয় রোযা আমার জন্য, আর আমি নিজেই এর প্রতিদান দিব। সহিহ বুখারি, হাদিস: ১৯০৪; সহিহ মুসলিম, হাদিস: ১১৫১",
    "রমজান হলো ধৈর্যের মাস, আর ধৈর্যের প্রতিদান হলো জান্নাত। সুনান ইবনে খুযাইমাহ, হাদিস: ১৮৮৭",
    "তোমাদের মধ্যে যে ব্যক্তি এ মাস (রমজান) পাবে, সে যেন এ মাসে রোযা রাখে।সূরা আল-বাকারাহ ২:১৮৫",
    "যে ব্যক্তি ঈমান ও সওয়াবের আশায় রমজানের রোযা রাখবে, তার পূর্বেকার গুনাহ মাফ করে দেওয়া হবে। সহিহ বুখারি, হাদিস: ৩৮; সহিহ মুসলিম, হাদিস: ৭৬০",
  ];

  String _currentHadith = "";

  @override
  void initState() {
    super.initState();
    _loadAd();
    _loadSavedData();
    _selectRandomHadith();
    _initializeAds(); // অ্যাড সিস্টেম ইনিশিয়ালাইজ করুন

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    iftarTimer?.cancel();
    _interstitialTimer?.cancel(); // interstitial টাইমার বাতিল করুন
    _bannerAd.dispose();
    _animationController.dispose();
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
      final lastShownDate = prefs.getString('last_interstitial_date_ifter');
      final today = DateTime.now().toIso8601String().split('T')[0];

      setState(() {
        _interstitialAdShownToday = (lastShownDate == today);
      });

      // ১০ সেকেন্ড পর interstitial অ্যাড শো করার টাইমার সেট করুন
      _startInterstitialTimer();

      print(
        'ইফতার পেজ - অ্যাড সিস্টেম ইনিশিয়ালাইজড: interstitial অ্যাড = $_showInterstitialAds, আজকে দেখানো হয়েছে = $_interstitialAdShownToday',
      );
    } catch (e) {
      print('ইফতার পেজ - অ্যাড ইনিশিয়ালাইজেশনে ত্রুটি: $e');
    }
  }

  // Interstitial অ্যাড টাইমার শুরু করুন
  void _startInterstitialTimer() {
    _interstitialTimer?.cancel(); // বিদ্যমান টাইমার বাতিল করুন

    _interstitialTimer = Timer(Duration(seconds: 10), () {
      _showInterstitialAdIfNeeded();
    });

    print(
      'ইফতার পেজ - Interstitial অ্যাড টাইমার শুরু হয়েছে (১০ সেকেন্ড পর শো হবে)',
    );
  }

  // Interstitial অ্যাড শো করুন যদি প্রয়োজন হয়
  Future<void> _showInterstitialAdIfNeeded() async {
    try {
      // interstitial অ্যাড বন্ধ থাকলে স্কিপ করুন
      if (!_showInterstitialAds) {
        print('ইফতার পেজ - Interstitial অ্যাড ইউজার বন্ধ রেখেছেন');
        return;
      }

      // যদি আজকে ইতিমধ্যে interstitial অ্যাড দেখানো হয়ে থাকে তবে স্কিপ করুন
      if (_interstitialAdShownToday) {
        print('ইফতার পেজ - ইতিমধ্যে আজ interstitial অ্যাড দেখানো হয়েছে');
        return;
      }

      print('ইফতার পেজ - Interstitial অ্যাড শো করার চেষ্টা করা হচ্ছে...');

      // AdHelper এর মাধ্যমে interstitial অ্যাড শো করুন
      await AdHelper.showInterstitialAd(
        onAdShowed: () {
          print('ইফতার পেজ - Interstitial অ্যাড শো করা হলো');
          _recordInterstitialShown();
        },
        onAdDismissed: () {
          print('ইফতার পেজ - Interstitial অ্যাড ডিসমিস করা হলো');
        },
        onAdFailedToShow: () {
          print('ইফতার পেজ - Interstitial অ্যাড শো করতে ব্যর্থ');
        },
        adContext: 'IfterTimePage',
      );
    } catch (e) {
      print('ইফতার পেজ - Interstitial অ্যাড শো করতে ত্রুটি: $e');
    }
  }

  // Interstitial অ্যাড দেখানো রেকর্ড করুন
  void _recordInterstitialShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      await prefs.setString('last_interstitial_date_ifter', today);

      setState(() {
        _interstitialAdShownToday = true;
      });

      print(
        'ইফতার পেজ - আজকের interstitial অ্যাড দেখানো রেকর্ড করা হলো: $today',
      );
    } catch (e) {
      print('ইফতার পেজ - Interstitial অ্যাড রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // interstitial অ্যাড সেটিংস টগল করুন (সেটিংস পেজ থেকে কল করতে পারবেন)
  Future<void> _toggleInterstitialAds(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_interstitial_ads', value);

    setState(() {
      _showInterstitialAds = value;
    });

    print('ইফতার পেজ - Interstitial অ্যাড সেটিংস পরিবর্তন: $value');

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

  // SharedPreferences থেকে ডেটা লোড করা
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      cityName = prefs.getString("cityName") ?? "অজানা";
      countryName = prefs.getString("countryName") ?? "অজানা";

      String? savedPrayerTimes = prefs.getString("prayerTimes");
      if (savedPrayerTimes != null) {
        prayerTimes = Map<String, String>.from(jsonDecode(savedPrayerTimes));
        _calculateIftarCountdown();
      }
    });
  }

  // র্যান্ডম হাদিস নির্বাচন
  void _selectRandomHadith() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _ramadanHadiths.length;
    setState(() {
      _currentHadith = _ramadanHadiths[random];
    });
  }

  // ইফতারের কাউন্টডাউন ক্যালকুলেশন
  void _calculateIftarCountdown() {
    if (prayerTimes.containsKey("মাগরিব")) {
      final maghribTime = prayerTimes["মাগরিব"]!;
      final parts = maghribTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      final maghribDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (maghribDateTime.isAfter(now)) {
        setState(() {
          iftarCountdown = maghribDateTime.difference(now);
        });

        iftarTimer?.cancel();
        iftarTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            iftarCountdown = maghribDateTime.difference(DateTime.now());
            if (iftarCountdown.isNegative) {
              _calculateIftarCountdown();
            }
          });
        });
      } else {
        // If maghrib time has passed for today, calculate for tomorrow
        final tomorrowMaghrib = maghribDateTime.add(const Duration(days: 1));
        setState(() {
          iftarCountdown = tomorrowMaghrib.difference(now);
        });

        iftarTimer?.cancel();
        iftarTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            iftarCountdown = tomorrowMaghrib.difference(DateTime.now());
          });
        });
      }
    }
  }

  // সেহরির সময় ক্যালকুলেশন (ফজরের ৩ মিনিট আগে)
  String _calculateSehriTime() {
    if (prayerTimes.containsKey("ফজর")) {
      final fajrTime = prayerTimes["ফজর"]!;
      final parts = fajrTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // ফজরের ৩ মিনিট আগে
      int sehriMinute = minute - 3;
      int sehriHour = hour;
      if (sehriMinute < 0) {
        sehriHour -= 1;
        sehriMinute += 60;
      }

      // Convert to 12-hour format
      final time = TimeOfDay(hour: sehriHour, minute: sehriMinute);
      return "${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
    }
    return "--:--";
  }

  // ইফতারের সময় ফরম্যাট করা
  String _getIftarTime() {
    if (prayerTimes.containsKey("মাগরিব")) {
      final maghribTime = prayerTimes["মাগরিব"]!;
      final parts = maghribTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final time = TimeOfDay(hour: hour, minute: minute);
      return "${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
    }
    return "--:--";
  }

  // সময় ইউনিট বিল্ড করার হেল্পার মেথড
  Widget _buildTimeUnit(String label, int value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Time value container
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for colon separator
  Widget _buildColon() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ":",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  // অ্যাড স্ট্যাটাস ইন্ডিকেটর (ডিবাগিং/ইনফোর জন্য)
  Widget _buildAdStatusIndicator(bool isDarkMode) {
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = Colors.green;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          "ইফতার ও সেহরির সময়",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        // অ্যাড স্ট্যাটাস ইন্ডিকেটর (অপশনাল - ডিবাগিং এর জন্য)
        actions: [
          // এই অংশটি প্রোডাকশনে কমেন্ট আউট করে দিতে পারেন
          // _buildAdStatusIndicator(isDarkMode),
          // SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // লোকেশন তথ্য
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.green[900] : Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: isDarkMode ? Colors.green[300] : Colors.green[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "$cityName, $countryName",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: isDarkMode ? Colors.green[300] : Colors.green[700],
                    ),
                    onPressed: _loadSavedData,
                    tooltip: "ডেটা রিফ্রেশ করুন",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ইফতার কাউন্টডাউন সেকশন
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [Colors.green[900]!, Colors.green[700]!]
                      : [Colors.green[600]!, Colors.green[400]!],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.nightlight_round,
                        color: Colors.white.withOpacity(0.9),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "ইফতারের সময় বাকি",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Countdown timer with improved design
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeUnit(
                        "ঘণ্টা",
                        iftarCountdown.inHours,
                        isDarkMode,
                      ),
                      const SizedBox(width: 12),
                      _buildColon(),
                      const SizedBox(width: 12),
                      _buildTimeUnit(
                        "মিনিট",
                        iftarCountdown.inMinutes % 60,
                        isDarkMode,
                      ),
                      const SizedBox(width: 12),
                      _buildColon(),
                      const SizedBox(width: 12),
                      _buildTimeUnit(
                        "সেকেন্ড",
                        iftarCountdown.inSeconds % 60,
                        isDarkMode,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Iftar time with improved styling
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "ইফতারের সময়: ${_getIftarTime()}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // হাদিস সেকশন
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blue[900] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.blue[700]! : Colors.blue[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "রমজানের হাদিস",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentHadith,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _selectRandomHadith,
                      child: Text(
                        "পরবর্তী হাদিস",
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.blue[200]
                              : Colors.blue[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // সেহরি ও ইফতার সময় সেকশন
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                  // সেহরির সময়
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.nights_stay,
                          size: 32,
                          color: isDarkMode
                              ? Colors.orange[300]
                              : Colors.orange[700],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "পরবর্তী সাহরির শেষ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _calculateSehriTime(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.orange[300]
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ডিভাইডার
                  Container(
                    width: 1,
                    height: 80,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),

                  // ইফতারের সময়
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          size: 32,
                          color: isDarkMode
                              ? Colors.green[300]
                              : Colors.green[700],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "আজকের ইফতার শুরু",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getIftarTime(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.green[300]
                                : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // তথ্য সেকশন
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💡 তথ্য",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "• 🍽️ ইফতারের দোয়া- আল্লাহুম্মা ইন্নি লাকা সুমতু, ওয়া বিকা আমানতু, ওয়া 'আলাইকা তাওয়াক্কালতু, ওয়া 'আলা রিজকিকা আফতারতু।\n"
                    "• 👉 রাসূল ﷺ বলেছেন- রোজা রাখার জন্য সাহ্‌রি খাও; নিশ্চয়ই সাহরিতে বরকত আছে। (সহিহ বুখারি 1923, সহিহ মুসলিম 1095)\n"
                    "• 👉 রোজার আদব হলো— শুধু খাবার-পানাহার থেকে বিরত থাকা নয়, বরং চোখ, কান, জিহ্বা ও সব অঙ্গ-প্রত্যঙ্গকে পাপ থেকে সংযত রাখা।\n",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isBannerAdReady
          ? Container(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              alignment: Alignment.center,
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            )
          : null,
    );
  }
}
