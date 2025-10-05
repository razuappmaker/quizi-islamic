// Organaize Ifter Time page

// lib/pages/ifter_time_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'ad_helper.dart';

class IfterTimePage extends StatefulWidget {
  const IfterTimePage({Key? key}) : super(key: key);

  @override
  State<IfterTimePage> createState() => _IfterTimePageState();
}

class _IfterTimePageState extends State<IfterTimePage>
    with SingleTickerProviderStateMixin {
  // ==================== ভেরিয়েবল ডিক্লেয়ারেশন ====================

  // ---------- নামাজের সময় সম্পর্কিত ভেরিয়েবল ----------
  String? cityName = "লোড হচ্ছে...";
  String? countryName = "লোড হচ্ছে...";
  Map<String, String> prayerTimes = {};
  Duration iftarCountdown = Duration.zero;
  Timer? iftarTimer;

  // ---------- সময় অ্যাডজাস্টমেন্ট ভেরিয়েবল ----------
  int iftarTimeAdjustment = 0;
  bool _showAdjustmentDialog = false;

  // ---------- অ্যানিমেশন ভেরিয়েবল ----------
  late AnimationController _animationController;
  late Animation<double> _animation;

  // ---------- বিজ্ঞাপন ভেরিয়েবল ----------
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  Timer? _interstitialTimer;
  bool _interstitialAdShownToday = false;
  bool _showInterstitialAds = true;

  // ---------- হাদিস ভেরিয়েবল ----------
  final List<String> _ramadanHadiths = [
    "রমযান মাস, এতে নাযিল করা হয়েছে কুরআন, যা মানুষের জন্য হিদায়াত এবং সৎপথের দিক-নির্দেশনা ও সত্যাসত্যের পার্থক্যকারী। সূরা আল-বাকারাহ ২:১৮৫",
    "হে ঈমানদারগণ! তোমাদের উপর রোযা ফরয করা হয়েছে, যেমন ফরয করা হয়েছিল তোমাদের পূর্ববর্তীদের উপর, যাতে তোমরা মুত্তাকী হতে পার। সূরা আল-বাকারাহ ২:১৮৩",
    "আর যে কেউ অসুস্থ অথবা সফরে থাকবে, সে যেন অন্য দিনে সংখ্যাটি পূর্ণ করে। আল্লাহ তোমাদের জন্য সহজ চান এবং তোমাদের জন্য কঠোরতা চান না। সূরা আল-বাকারাহ ২:১৮৫",
    "যখন রমজান মাস প্রবেশ করে, জান্নাতের দরজাগুলো খুলে দেওয়া হয়, জাহান্নামের দরজাগুলো বন্ধ করে দেওয়া হয় এবং শয়তানদের শিকলবদ্ধ করা হয়। সহিহ বুখারি, হাদিস: ১৮৯৯; সহিহ মুসলিম, হাদিস: ১০৭৯",
    "রমজান হলো ধৈর্যের মাস, আর ধৈর্যের প্রতিদান হলো জান্নাত। সুনান ইবনে খুযাইমাহ, হাদিস: ১৮৮৭",
    "তোমাদের মধ্যে যে ব্যক্তি এ মাস (রমজান) পাবে, সে যেন এ মাসে রোযা রাখে।সূরা আল-বাকারাহ ২:১৮৫",
    "যে ব্যক্তি ঈমান ও সওয়াবের আশায় রমজানের রোযা রাখবে, তার পূর্বেকার গুনাহ মাফ করে দেওয়া হবে। সহিহ বুখারি, হাদিস: ৩৮; সহিহ মুসলিম, হাদিস: ৭৬০",
  ];

  String _currentHadith = "";

  @override
  void initState() {
    super.initState();
    _initializeAllComponents();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  // ==================== ইনিশিয়ালাইজেশন মেথড ====================

  // ---------- সব কম্পোনেন্ট ইনিশিয়ালাইজেশন ----------
  void _initializeAllComponents() {
    _initializeAnimation();
    _loadSavedData();
    _selectRandomHadith();
    _initializeAds();
    _loadAdjustmentSettings();
    _loadAd(); // ব্যানার অ্যাড লোড
  }

  // ---------- অ্যানিমেশন ইনিশিয়ালাইজেশন ----------
  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  // ---------- রিসোর্স ক্লিনআপ ----------
  void _cleanupResources() {
    iftarTimer?.cancel();
    _interstitialTimer?.cancel();
    _bannerAd?.dispose();
    _animationController.dispose();
  }

  // ==================== বিজ্ঞাপন মেথড ====================

  // ---------- ব্যানার অ্যাড লোড ----------
  Future<void> _loadAd() async {
    try {
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('ব্যানার অ্যাড লিমিট reached, অ্যাড দেখানো হবে না');
        return;
      }

      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() => _isBannerAdReady = true);
            AdHelper.recordBannerAdShown();
            print('Adaptive Banner ad loaded successfully.');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Adaptive Banner ad failed to load: $error');
            ad.dispose();
            _isBannerAdReady = false;
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Adaptive Banner ad clicked.');
              } else {
                print('Ad click limit reached');
              }
            });
          },
        ),
      );

      await _bannerAd?.load();
    } catch (e) {
      print('Error loading adaptive banner ad: $e');
      _isBannerAdReady = false;
    }
  }

  // ---------- অ্যাড সিস্টেম ইনিশিয়ালাইজেশন ----------
  Future<void> _initializeAds() async {
    try {
      await AdHelper.initialize();
      final prefs = await SharedPreferences.getInstance();

      _showInterstitialAds = prefs.getBool('show_interstitial_ads') ?? true;

      final lastShownDate = prefs.getString('last_interstitial_date_ifter');
      final today = DateTime.now().toIso8601String().split('T')[0];

      setState(() {
        _interstitialAdShownToday = (lastShownDate == today);
      });

      _startInterstitialTimer();

      print(
        'ইফতার পেজ - অ্যাড সিস্টেম ইনিশিয়ালাইজড: interstitial অ্যাড = $_showInterstitialAds, আজকে দেখানো হয়েছে = $_interstitialAdShownToday',
      );
    } catch (e) {
      print('ইফতার পেজ - অ্যাড ইনিশিয়ালাইজেশনে ত্রুটি: $e');
    }
  }

  // ---------- ইন্টারস্টিশিয়াল অ্যাড টাইমার শুরু ----------
  void _startInterstitialTimer() {
    _interstitialTimer?.cancel();
    _interstitialTimer = Timer(Duration(seconds: 10), () {
      _showInterstitialAdIfNeeded();
    });
  }

  // ---------- ইন্টারস্টিশিয়াল অ্যাড শো ----------
  Future<void> _showInterstitialAdIfNeeded() async {
    try {
      if (!_showInterstitialAds) return;
      if (_interstitialAdShownToday) return;

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

  // ---------- ইন্টারস্টিশিয়াল অ্যাড রেকর্ড ----------
  void _recordInterstitialShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      await prefs.setString('last_interstitial_date_ifter', today);

      setState(() {
        _interstitialAdShownToday = true;
      });
    } catch (e) {
      print('ইফতার পেজ - Interstitial অ্যাড রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // ==================== সময় অ্যাডজাস্টমেন্ট মেথড ====================

  // ---------- অ্যাডজাস্টমেন্ট সেটিংস লোড ----------
  Future<void> _loadAdjustmentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      iftarTimeAdjustment = prefs.getInt('ifter_time_adjustment') ?? 0;
    });
  }

  // ---------- অ্যাডজাস্টমেন্ট সেভ ----------
  Future<void> _saveAdjustmentSettings(int adjustment) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ifter_time_adjustment', adjustment);
    setState(() {
      iftarTimeAdjustment = adjustment;
    });

    if (prayerTimes.isNotEmpty) {
      _calculateIftarCountdown();
    }
  }

  // ---------- সময় অ্যাডজাস্টমেন্ট ডায়ালগ ----------
  void _showTimeAdjustmentDialog() {
    setState(() {
      _showAdjustmentDialog = true;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _buildAdjustmentDialog(setState);
          },
        );
      },
    ).then((value) {
      setState(() {
        _showAdjustmentDialog = false;
      });
    });
  }

  // ---------- অ্যাডজাস্টমেন্ট ডায়ালগ বিল্ড ----------
  Widget _buildAdjustmentDialog(void Function(void Function()) setState) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.schedule, color: Colors.green),
          SizedBox(width: 8),
          Text("ইফতার সময় সামঞ্জস্য করুন"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "স্থানীয় মসজিদের সময়ের সাথে মিলিয়ে নিন\n"
            "(+/-) বাটন দিয়ে ১ মিনিট করে প্রয়োজনমতো সামঞ্জস্য করুন",
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          _buildCurrentAdjustmentDisplay(),
          SizedBox(height: 20),
          _buildAdjustmentButtons(setState),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              _showAdjustmentDialog = false;
            });
          },
          child: Text("বাতিল"),
        ),
        ElevatedButton(
          onPressed: () {
            _saveAdjustmentSettings(iftarTimeAdjustment);
            Navigator.of(context).pop();
            setState(() {
              _showAdjustmentDialog = false;
            });
            _showAdjustmentSuccessSnackbar();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text("সংরক্ষণ করুন"),
        ),
      ],
    );
  }

  // ---------- বর্তমান অ্যাডজাস্টমেন্ট ডিসপ্লে ----------
  Widget _buildCurrentAdjustmentDisplay() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            "বর্তমান অ্যাডজাস্টমেন্ট",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 5),
          Text(
            "${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment মিনিট",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iftarTimeAdjustment == 0
                  ? Colors.grey
                  : iftarTimeAdjustment > 0
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- অ্যাডজাস্টমেন্ট বাটন ----------
  Widget _buildAdjustmentButtons(void Function(void Function()) setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAdjustmentButton(Icons.remove, Colors.red, () {
          setState(() => iftarTimeAdjustment -= 1);
        }),
        _buildAdjustmentButton(Icons.refresh, Colors.orange, () {
          setState(() => iftarTimeAdjustment = 0);
        }),
        _buildAdjustmentButton(Icons.add, Colors.green, () {
          setState(() => iftarTimeAdjustment += 1);
        }),
      ],
    );
  }

  // ---------- অ্যাডজাস্টমেন্ট বাটন বিল্ড ----------
  Widget _buildAdjustmentButton(
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  // ---------- অ্যাডজাস্টমেন্ট স্ন্যাকবার ----------
  void _showAdjustmentSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          iftarTimeAdjustment == 0
              ? "ইফতার সময় রিসেট করা হয়েছে"
              : "ইফতার সময় ${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment মিনিট অ্যাডজাস্ট করা হয়েছে",
        ),
        duration: Duration(seconds: 2),
        backgroundColor: iftarTimeAdjustment == 0
            ? Colors.orange
            : Colors.green,
      ),
    );
  }

  // ---------- ইফতার সময় অ্যাডজাস্ট ----------
  String _adjustIftarTime(String time, int adjustmentMinutes) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      minutes += adjustmentMinutes;

      while (minutes >= 60) {
        minutes -= 60;
        hours = (hours + 1) % 24;
      }

      while (minutes < 0) {
        minutes += 60;
        hours = (hours - 1) % 24;
        if (hours < 0) hours += 24;
      }

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      print('ইফতার সময় অ্যাডজাস্ট করতে ত্রুটি: $e');
      return time;
    }
  }

  // ==================== ডেটা লোডিং মেথড ====================

  // ---------- শেয়ার্ড প্রেফারেন্স থেকে ডেটা লোড ----------
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      cityName = prefs.getString("cityName") ?? "অজানা";
      countryName = prefs.getString("countryName") ?? "অজানা";
      _loadPrayerTimes(prefs);
    });
  }

  // ---------- নামাজের সময় লোড ----------
  void _loadPrayerTimes(SharedPreferences prefs) {
    String? savedAdjustedTimes = prefs.getString("adjusted_prayer_times");
    if (savedAdjustedTimes != null) {
      try {
        prayerTimes = Map<String, String>.from(jsonDecode(savedAdjustedTimes));
      } catch (e) {
        print('অ্যাডজাস্টেড টাইমস পার্স করতে ত্রুটি: $e');
      }
    }

    if (prayerTimes.isEmpty) {
      String? savedOriginalTimes = prefs.getString("prayerTimes");
      if (savedOriginalTimes != null) {
        try {
          prayerTimes = Map<String, String>.from(
            jsonDecode(savedOriginalTimes),
          );
        } catch (e) {
          print('অরিজিনাল টাইমস পার্স করতে ত্রুটি: $e');
        }
      }
    }

    if (prayerTimes.isNotEmpty) {
      _calculateIftarCountdown();
    }
  }

  // ==================== হাদিস মেথড ====================

  // ---------- র্যান্ডম হাদিস নির্বাচন ----------
  void _selectRandomHadith() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _ramadanHadiths.length;
    setState(() {
      _currentHadith = _ramadanHadiths[random];
    });
  }

  // ==================== সময় ক্যালকুলেশন মেথড ====================

  // ---------- ইফতার কাউন্টডাউন ক্যালকুলেশন ----------
  void _calculateIftarCountdown() {
    if (prayerTimes.containsKey("মাগরিব")) {
      String maghribTime = prayerTimes["মাগরিব"]!;

      if (iftarTimeAdjustment != 0) {
        maghribTime = _adjustIftarTime(maghribTime, iftarTimeAdjustment);
      }

      final parts = maghribTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      DateTime maghribDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (maghribDateTime.isAfter(now)) {
        _startCountdownTimer(maghribDateTime);
      } else {
        final tomorrowMaghrib = maghribDateTime.add(const Duration(days: 1));
        _startCountdownTimer(tomorrowMaghrib);
      }
    }
  }

  // ---------- কাউন্টডাউন টাইমার শুরু ----------
  void _startCountdownTimer(DateTime targetTime) {
    setState(() {
      iftarCountdown = targetTime.difference(DateTime.now());
    });

    iftarTimer?.cancel();
    iftarTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        iftarCountdown = targetTime.difference(DateTime.now());
        if (iftarCountdown.isNegative) {
          _calculateIftarCountdown();
        }
      });
    });
  }

  // ---------- সেহরির সময় ক্যালকুলেশন ----------
  String _calculateSehriTime() {
    if (prayerTimes.containsKey("ফজর")) {
      final fajrTime = prayerTimes["ফজর"]!;
      final parts = fajrTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      int sehriMinute = minute - 3;
      int sehriHour = hour;
      if (sehriMinute < 0) {
        sehriHour -= 1;
        sehriMinute += 60;
      }

      final time = TimeOfDay(hour: sehriHour, minute: sehriMinute);
      return "${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
    }
    return "--:--";
  }

  // ---------- ইফতারের সময় ফরম্যাট ----------
  String _getIftarTime() {
    if (prayerTimes.containsKey("মাগরিব")) {
      String maghribTime = prayerTimes["মাগরিব"]!;

      if (iftarTimeAdjustment != 0) {
        maghribTime = _adjustIftarTime(maghribTime, iftarTimeAdjustment);
      }

      final parts = maghribTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final time = TimeOfDay(hour: hour, minute: minute);
      return "${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
    }
    return "--:--";
  }

  // ---------- প্রোগ্রেস ক্যালকুলেশন ----------
  double _calculateProgress(Duration remainingTime) {
    const totalDaylightHours = 12;
    final totalSeconds = totalDaylightHours * 3600;
    final remainingSeconds = remainingTime.inSeconds;
    return remainingSeconds / totalSeconds;
  }

  // ---------- কাউন্টডাউন কালার নির্ধারণ ----------
  Color _getCountdownColor(Duration remainingTime) {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    if (hours > 1) return Colors.greenAccent;
    if (hours == 1) return Colors.orangeAccent;
    if (minutes > 30) return Colors.orange;
    if (minutes > 10) return Colors.deepOrange;
    return Colors.redAccent;
  }

  // ---------- প্রোগ্রেস টেক্সট ----------
  String _getProgressText(Duration remainingTime) {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    if (hours > 1) return "ইফতারের সময় আসছে";
    if (hours == 1) return "প্রস্তুত হোন";
    if (minutes > 30) return "অল্প সময় বাকি";
    if (minutes > 10) return "শীঘ্রই ইফতার";
    return "ইফতারের সময় কাছাকাছি";
  }

  // ==================== UI কম্পোনেন্ট বিল্ডার মেথড ====================

  // ---------- সময় ইউনিট বিল্ড ----------
  Widget _buildTimeUnit(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  // ---------- কোলন সেপারেটর ----------
  Widget _buildColon(Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        ":",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  // ==================== মূল UI বিল্ড মেথড ====================

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = Colors.green;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(primaryColor),
      body: _buildBody(isDarkMode, primaryColor),
      bottomNavigationBar: _buildBannerAd(),
    );
  }

  // ---------- অ্যাপবার বিল্ড ----------
  AppBar _buildAppBar(Color primaryColor) {
    return AppBar(
      backgroundColor: primaryColor,
      title: const Text(
        "ইফতার ও সেহরি",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 20,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showTimeAdjustmentDialog,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.green[100]!.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_calendar_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "সময় সেটিং",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- বডি বিল্ড ----------
  Widget _buildBody(bool isDarkMode, Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final padding = isTablet ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // লোকেশন UI সেকশন
              _buildLocationSection(isDarkMode, isTablet),
              SizedBox(height: isTablet ? 32 : 24),

              // কাউন্টডাউন UI সেকশন
              _buildCountdownSection(isDarkMode, isTablet),
              SizedBox(height: isTablet ? 32 : 24),

              // হাদিস UI সেকশন
              _buildHadithSection(isDarkMode, isTablet),
              SizedBox(height: isTablet ? 32 : 24),

              // সময় UI সেকশন
              _buildTimeSection(isDarkMode, isTablet),
              SizedBox(height: isTablet ? 32 : 24),

              // তথ্য UI সেকশন
              _buildInfoSection(isDarkMode, isTablet),
            ],
          ),
        );
      },
    );
  }

  // ---------- লোকেশন UI সেকশন ----------
  // ---------- লোকেশন UI সেকশন (কম উচ্চতা) ----------
  Widget _buildLocationSection(bool isDarkMode, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 8, // কম ভার্টিক্যাল প্যাডিং
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.green[900] : Colors.green[100],
        borderRadius: BorderRadius.circular(12), // ছোট বর্ডার রেডিয়াস
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6, // কম ব্লার
            offset: Offset(0, 2), // ছোট শ্যাডো
          ),
        ],
      ),
      child: Row(
        children: [
          // লোকেশন আইকন - ছোট সাইজ
          Container(
            padding: EdgeInsets.all(isTablet ? 6 : 4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.green[800] : Colors.green[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              size: isTablet ? 20 : 18, // ছোট আইকন
              color: isDarkMode ? Colors.green[300] : Colors.green[700],
            ),
          ),

          SizedBox(width: isTablet ? 10 : 8),

          // লোকেশন টেক্সট - কম্প্যাক্ট
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // মিনিমাম স্পেস নেয়
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$cityName, $countryName",
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14, // ছোট ফন্ট
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1, // এক লাইনে সীমিত
                  overflow: TextOverflow.ellipsis,
                ),

                // অ্যাডজাস্টমেন্ট ইন্ডিকেটর - ছোট সাইজ
                if (iftarTimeAdjustment != 0) ...[
                  SizedBox(height: 4), // কম গ্যাপ
                  _buildCompactAdjustmentIndicator(isDarkMode),
                ],
              ],
            ),
          ),

          // রিফ্রেশ বাটন - ছোট সাইজ
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.green[800] : Colors.green[200],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                size: isTablet ? 20 : 18, // ছোট আইকন
                color: isDarkMode ? Colors.green[300] : Colors.green[700],
              ),
              onPressed: _loadSavedData,
              tooltip: "ডেটা রিফ্রেশ করুন",
              padding: EdgeInsets.all(isTablet ? 6 : 4),
              // কম প্যাডিং
              constraints: BoxConstraints(
                minWidth: isTablet ? 36 : 32, // ছোট বাটন
                minHeight: isTablet ? 36 : 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- কম্প্যাক্ট অ্যাডজাস্টমেন্ট ইন্ডিকেটর ----------
  Widget _buildCompactAdjustmentIndicator(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // কম প্যাডিং
      decoration: BoxDecoration(
        color: iftarTimeAdjustment > 0
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iftarTimeAdjustment > 0 ? Colors.green : Colors.red,
          width: 0.5, // পাতলা বর্ডার
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iftarTimeAdjustment > 0 ? Icons.arrow_upward : Icons.arrow_downward,
            size: 10, // খুব ছোট আইকন
            color: iftarTimeAdjustment > 0 ? Colors.green : Colors.red,
          ),
          SizedBox(width: 2), // কম গ্যাপ
          Text(
            "${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment মিনিট",
            style: TextStyle(
              fontSize: 10, // ছোট ফন্ট
              fontWeight: FontWeight.w600,
              color: iftarTimeAdjustment > 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- কাউন্টডাউন UI সেকশন ----------
  // ---------- কাউন্টডাউন UI সেকশন (প্রফেশনাল ভার্সন) ----------
  Widget _buildCountdownSection(bool isDarkMode, bool isTablet) {
    final countdownSize = isTablet ? 260.0 : 180.0;
    final countdownColor = _getCountdownColor(iftarCountdown);
    final progressValue = _calculateProgress(iftarCountdown);

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.green[900]!, Colors.green[800]!, Colors.green[700]!]
              : [Colors.green[700]!, Colors.green[600]!, Colors.green[500]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: countdownColor.withOpacity(0.3),
            blurRadius: 30,
            offset: Offset(0, 0),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // হেডার সেকশন
          _buildEnhancedCountdownHeader(isTablet, countdownColor),
          SizedBox(height: isTablet ? 20 : 16),

          // মেইন কাউন্টডাউন কন্টেন্ট
          Stack(
            alignment: Alignment.center,
            children: [
              // ব্যাকগ্রাউন্ড ইফেক্ট
              _buildBackgroundEffects(
                countdownSize,
                countdownColor,
                progressValue,
              ),

              // কাউন্টডাউন টাইমার
              _buildEnhancedCountdownTimer(
                countdownSize,
                countdownColor,
                isTablet,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // ইফতার সময় ও প্রোগ্রেস বার
          _buildEnhancedIftarTimeDisplay(
            isTablet,
            countdownColor,
            progressValue,
          ),
        ],
      ),
    );
  }

  // ---------- এনহ্যান্সড কাউন্টডাউন হেডার ----------
  Widget _buildEnhancedCountdownHeader(bool isTablet, Color accentColor) {
    return Column(
      children: [
        // মেইন টাইটেল
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.nightlight_round,
                color: Colors.white.withOpacity(0.9),
                size: isTablet ? 22 : 18,
              ),
              SizedBox(width: 8),
              Text(
                "ইফতারের সময় বাকি",
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),

        // অ্যাডজাস্টমেন্ট ইন্ডিকেটর
        if (iftarTimeAdjustment != 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment মিনিট অ্যাডজাস্টেড",
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // ---------- ব্যাকগ্রাউন্ড ইফেক্টস ----------
  Widget _buildBackgroundEffects(
    double size,
    Color accentColor,
    double progress,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // আউটার গ্লো ইফেক্ট
          Container(
            width: size * 1.1,
            height: size * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.2),
                  accentColor.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: [0.1, 0.5, 1.0],
              ),
            ),
          ),

          // প্রোগ্রেস ব্যাকগ্রাউন্ড
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- এনহ্যান্সড কাউন্টডাউন টাইমার ----------
  Widget _buildEnhancedCountdownTimer(
    double size,
    Color accentColor,
    bool isTablet,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ডুয়েল প্রোগ্রেস ইন্ডিকেটর
          _buildDualProgressIndicator(size, accentColor),

          // কাউন্টডাউন কন্টেন্ট
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // সময় ইউনিট
              _buildCompactTimeUnits(accentColor, isTablet),
              SizedBox(height: 8),

              // প্রোগ্রেস টেক্সট
              _buildProgressStatus(accentColor, isTablet),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- ডুয়েল প্রোগ্রেস ইন্ডিকেটর ----------
  Widget _buildDualProgressIndicator(double size, Color accentColor) {
    final progress = _calculateProgress(iftarCountdown);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // আউটার প্রোগ্রেস বার
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                accentColor.withOpacity(0.6),
              ),
            ),
          ),

          // সেন্টার গ্লো
          Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.3),
                  accentColor.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- কম্প্যাক্ট টাইম ইউনিটস ----------
  Widget _buildCompactTimeUnits(Color accentColor, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildEnhancedTimeUnit(
          "ঘণ্টা",
          iftarCountdown.inHours,
          accentColor,
          isTablet,
        ),
        _buildTimeSeparator(accentColor, isTablet),
        _buildEnhancedTimeUnit(
          "মিনিট",
          iftarCountdown.inMinutes % 60,
          accentColor,
          isTablet,
        ),
        _buildTimeSeparator(accentColor, isTablet),
        _buildEnhancedTimeUnit(
          "সেকেন্ড",
          iftarCountdown.inSeconds % 60,
          accentColor,
          isTablet,
        ),
      ],
    );
  }

  // ---------- এনহ্যান্সড টাইম ইউনিট ----------
  Widget _buildEnhancedTimeUnit(
    String label,
    int value,
    Color color,
    bool isTablet,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 10 : 8,
            vertical: isTablet ? 8 : 6,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 11 : 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ---------- টাইম সেপারেটর ----------
  Widget _buildTimeSeparator(Color color, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
      child: Text(
        ":",
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w800,
          color: color.withOpacity(0.8),
          height: 1.2,
        ),
      ),
    );
  }

  // ---------- প্রোগ্রেস স্ট্যাটাস ----------
  Widget _buildProgressStatus(Color accentColor, bool isTablet) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
          ),
          child: Text(
            _getProgressText(iftarCountdown),
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- এনহ্যান্সড ইফতার সময় ডিসপ্লে ----------
  Widget _buildEnhancedIftarTimeDisplay(
    bool isTablet,
    Color accentColor,
    double progress,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ইফতার টাইম ইনফো
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time_filled,
                    color: Colors.white,
                    size: isTablet ? 20 : 18,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ইফতারের সময়",
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _getIftarTime(),
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // প্রোগ্রেস পার্সেন্টেজ
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.3),
                  accentColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.dining, // রমজান স্পেসিফিক আইকন
                  size: isTablet ? 16 : 14,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  "রোজার বাকি ${(progress * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- হাদিস UI সেকশন ----------
  Widget _buildHadithSection(bool isDarkMode, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blue[900] : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.blue[700]! : Colors.blue[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // হেডার
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: isTablet ? 28 : 24,
                color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
              ),
              SizedBox(width: 12),
              Text(
                "রমজানের হাদিস",
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // হাদিস টেক্সট
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blue[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentHadith,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(height: 16),

          // নেক্সট বাটন
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _selectRandomHadith,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Colors.blue[700]
                    : Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 12 : 10,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.autorenew,
                    size: isTablet ? 20 : 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "পরবর্তী হাদিস",
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- সময় UI সেকশন (সেহরি ও ইফতার) ----------
  Widget _buildTimeSection(bool isDarkMode, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "⏰ আজকের সময়সূচী",
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),

          Row(
            children: [
              // সেহরির সময়
              Expanded(
                child: _buildTimeCard(
                  icon: Icons.nights_stay,
                  title: "সাহরি শেষ",
                  time: _calculateSehriTime(),
                  color: Colors.orange,
                  isDarkMode: isDarkMode,
                  isTablet: isTablet,
                ),
              ),

              SizedBox(width: isTablet ? 20 : 16),

              // ইফতারের সময়
              Expanded(
                child: _buildTimeCard(
                  icon: Icons.wb_sunny,
                  title: "ইফতার",
                  time: _getIftarTime(),
                  color: Colors.green,
                  isDarkMode: isDarkMode,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- সময় কার্ড বিল্ড ----------
  Widget _buildTimeCard({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
    required bool isDarkMode,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: isTablet ? 32 : 28, color: color),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- তথ্য UI সেকশন ----------
  Widget _buildInfoSection(bool isDarkMode, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: 12),
              Text(
                "রমজানের গুরুত্বপূর্ণ তথ্য",
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          _buildInfoItem(
            "🍽️ ইফতারের দোয়া",
            "আল্লাহুম্মা ইন্নি লাকা সুমতু, ওয়া বিকা আমানতু, ওয়া 'আলাইকা তাওয়াক্কালতু, ওয়া 'আলা রিজকিকা আফতারতু।",
            isDarkMode,
            isTablet,
          ),
          SizedBox(height: 12),

          _buildInfoItem(
            "👉 রাসূল ﷺ বলেছেন",
            "রোজা রাখার জন্য সাহ্‌রি খাও; নিশ্চয়ই সাহরিতে বরকত আছে। (সহিহ বুখারি 1923, সহিহ মুসলিম 1095)",
            isDarkMode,
            isTablet,
          ),
          SizedBox(height: 12),

          _buildInfoItem(
            "👆 রোজার আদব",
            "শুধু খাবার-পানাহার থেকে বিরত থাকা নয়, বরং চোখ, কান, জিহ্বা ও সব অঙ্গ-প্রত্যঙ্গকে পাপ থেকে সংযত রাখা।",
            isDarkMode,
            isTablet,
          ),
          SizedBox(height: 12),

          _buildInfoItem(
            "💫 সওয়াবের কথা",
            "রমজানের প্রতিটি নেকির সওয়াব ৭০ গুণ বেশি। তাই বেশি বেশি নেক আমল করুন।",
            isDarkMode,
            isTablet,
          ),
        ],
      ),
    );
  }

  // ---------- তথ্য আইটেম বিল্ড ----------
  Widget _buildInfoItem(
    String title,
    String description,
    bool isDarkMode,
    bool isTablet,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
            ),
          ),
          SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.4,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // ---------- ব্যানার অ্যাড বিল্ড ----------
  Widget _buildBannerAd() {
    if (_isBannerAdReady && _bannerAd != null) {
      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: _bannerAd!.size.height.toDouble(),
          alignment: Alignment.center,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      // ব্যানার অ্যাড না থাকলে শুধু সিস্টেম ন্যাভিগেশন বার এর জন্য স্পেস রাখুন
      return SafeArea(child: Container(height: 0));
    }
  }
}
