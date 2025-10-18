// lib/pages/ifter_time_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart'; // নতুন কালার সিস্টেম ইম্পোর্ট
import 'ad_helper.dart';

class IfterTimePage extends StatefulWidget {
  const IfterTimePage({Key? key}) : super(key: key);

  @override
  State<IfterTimePage> createState() => _IfterTimePageState();
}

class _IfterTimePageState extends State<IfterTimePage>
    with SingleTickerProviderStateMixin {
  // ==================== ভাষা টেক্সট ডিক্লেয়ারেশন ====================
  static const Map<String, Map<String, String>> _texts = {
    'pageTitle': {'en': 'Iftar & Sehri', 'bn': 'ইফতার ও সেহরি'},
    'locationLoading': {'en': 'Loading...', 'bn': 'লোড হচ্ছে...'},
    'unknown': {'en': 'Unknown', 'bn': 'অজানা'},
    'timeSetting': {'en': 'Time Setting', 'bn': 'সময় সেটিং'},
    'adjustTime': {
      'en': 'Adjust Iftar Time',
      'bn': 'ইফতার সময় সামঞ্জস্য করুন',
    },
    'adjustDescription': {
      'en':
          'Adjust according to local mosque time\nUse (+) (-) buttons to adjust by 1 minute',
      'bn':
          'স্থানীয় মসজিদের সময়ের সাথে মিলিয়ে নিন\n(+) (-) বাটন দিয়ে ১ মিনিট করে প্রয়োজনমতো সামঞ্জস্য করুন',
    },
    'currentAdjustment': {
      'en': 'Current Adjustment',
      'bn': 'বর্তমান অ্যাডজাস্টমেন্ট',
    },
    'minutes': {'en': 'minutes', 'bn': 'মিনিট'},
    'cancel': {'en': 'Cancel', 'bn': 'বাতিল'},
    'save': {'en': 'Save', 'bn': 'সংরক্ষণ করুন'},
    'timeReset': {
      'en': 'Iftar time reset',
      'bn': 'ইফতার সময় রিসেট করা হয়েছে',
    },
    'timeAdjusted': {
      'en': 'Iftar time adjusted by',
      'bn': 'ইফতার সময় অ্যাডজাস্ট করা হয়েছে',
    },
    'refreshData': {'en': 'Refresh data', 'bn': 'ডেটা রিফ্রেশ করুন'},
    'remainingTime': {'en': 'Time until Iftar', 'bn': 'ইফতারের সময় বাকি'},
    'adjusted': {'en': 'minutes adjusted', 'bn': 'মিনিট অ্যাডজাস্টেড'},
    'comingSoon': {'en': 'Iftar time coming soon', 'bn': 'ইফতারের সময় আসছে'},
    'getReady': {'en': 'Get ready', 'bn': 'প্রস্তুত হোন'},
    'littleTimeLeft': {'en': 'Little time left', 'bn': 'অল্প সময় বাকি'},
    'soonIftar': {'en': 'Iftar soon', 'bn': 'শীঘ্রই ইফতার'},
    'nearIftar': {'en': 'Iftar time nearby', 'bn': 'ইফতারের সময় কাছাকাছি'},
    'ramadanHadith': {'en': 'Ramadan Hadith', 'bn': 'রমজানের হাদিস'},
    'nextHadith': {'en': 'Next Hadith', 'bn': 'পরবর্তী হাদিস'},
    'todaysSchedule': {'en': "Today's Schedule", 'bn': 'আজকের সময়সূচী'},
    'sehriEnd': {'en': 'Sehri End', 'bn': 'সাহরি শেষ'},
    'iftar': {'en': 'Iftar', 'bn': 'ইফতার'},
    'importantInfo': {
      'en': 'Important Ramadan Info',
      'bn': 'রমজানের গুরুত্বপূর্ণ তথ্য',
    },
    'iftarDua': {'en': 'Iftar Dua', 'bn': 'ইফতারের দোয়া'},
    'prophetSaid': {'en': 'Prophet ﷺ said', 'bn': 'রাসূল ﷺ বলেছেন'},
    'fastingEtiquette': {'en': 'Fasting Etiquette', 'bn': 'রোজার আদব'},
    'rewardInfo': {'en': 'About Rewards', 'bn': 'সওয়াবের কথা'},
    'fastingRemaining': {'en': 'Fasting remaining', 'bn': 'রোজার বাকি'},
    'refresh': {'en': 'Refresh', 'bn': 'রিফ্রেশ'},
    'hours': {'en': 'Hours', 'bn': 'ঘণ্টা'},
    'minutesShort': {'en': 'Min', 'bn': 'মিনিট'},
    'seconds': {'en': 'Sec', 'bn': 'সেকেন্ড'},
    'iftarTime': {'en': 'Iftar Time', 'bn': 'ইফতারের সময়'},

    // হাদিস টেক্সট
    'hadith1': {
      'en':
          "The month of Ramadan in which was revealed the Quran, a guidance for mankind and clear proofs for the guidance and the criterion (between right and wrong). Surah Al-Baqarah 2:185",
      'bn':
          "রমযান মাস, এতে নাযিল করা হয়েছে কুরআন, যা মানুষের জন্য হিদায়াত এবং সৎপথের দিক-নির্দেশনা ও সত্যাসত্যের পার্থক্যকারী। সূরা আল-বাকারাহ ২:১৮৫",
    },
    'hadith2': {
      'en':
          "O you who have believed, decreed upon you is fasting as it was decreed upon those before you that you may become righteous. Surah Al-Baqarah 2:183",
      'bn':
          "হে ঈমানদারগণ! তোমাদের উপর রোযা ফরয করা হয়েছে, যেমন ফরয করা হয়েছিল তোমাদের পূর্ববর্তীদের উপর, যাতে তোমরা মুত্তাকী হতে পার। সূরা আল-বাকারাহ ২:১৮৩",
    },
    'hadith3': {
      'en':
          "And whoever is ill or on a journey - then an equal number of other days. Allah intends for you ease and does not intend for you hardship. Surah Al-Baqarah 2:185",
      'bn':
          "আর যে কেউ অসুস্থ অথবা সফরে থাকবে, সে যেন অন্য দিনে সংখ্যাটি পূর্ণ করে। আল্লাহ তোমাদের জন্য সহজ চান এবং তোমাদের জন্য কঠোরতা চান না। সূরা আল-বাকারাহ ২:১৮৫",
    },
    'hadith4': {
      'en':
          "When the month of Ramadan enters, the gates of Paradise are opened, the gates of Hellfire are closed and the devils are chained. Sahih al-Bukhari 1899, Sahih Muslim 1079",
      'bn':
          "যখন রমজান মাস প্রবেশ করে, জান্নাতের দরজাগুলো খুলে দেওয়া হয়, জাহান্নামের দরজাগুলো বন্ধ করে দেওয়া হয় এবং শয়তানদের শিকলবদ্ধ করা হয়। সহিহ বুখারি ১৮৯৯, সহিহ মুসলিম ১০৭৯",
    },
    'hadith5': {
      'en':
          "Ramadan is the month of patience, and the reward of patience is Paradise. Sunan Ibn Khuzaymah 1887",
      'bn':
          "রমজান হলো ধৈর্যের মাস, আর ধৈর্যের প্রতিদান হলো জান্নাত। সুনান ইবনে খুযাইমাহ ১৮৮৭",
    },
    'hadith6': {
      'en':
          "Whoever witnesses the month of Ramadan should fast through it. Surah Al-Baqarah 2:185",
      'bn':
          "তোমাদের মধ্যে যে ব্যক্তি এ মাস (রমজান) পাবে, সে যেন এ মাসে রোযা রাখে। সূরা আল-বাকারাহ ২:১৮৫",
    },
    'hadith7': {
      'en':
          "Whoever fasts during Ramadan out of sincere faith and hoping for a reward from Allah, then all his previous sins will be forgiven. Sahih al-Bukhari 38, Sahih Muslim 760",
      'bn':
          "যে ব্যক্তি ঈমান ও সওয়াবের আশায় রমজানের রোযা রাখবে, তার পূর্বেকার গুনাহ মাফ করে দেওয়া হবে। সহিহ বুখারি ৩৮, সহিহ মুসলিম ৭৬০",
    },

    // তথ্য আইটেম কন্টেন্ট
    'iftarDuaContent': {
      'en':
          "O Allah! I fasted for You and I believe in You and I put my trust in You and I break my fast with Your sustenance.",
      'bn':
          "আল্লাহুম্মা ইন্নি লাকা সুমতু, ওয়া বিকা আমানতু, ওয়া 'আলাইকা তাওয়াক্কালতু, ওয়া 'আলা রিজকিকা আফতারতু।",
    },
    'prophetSaidContent': {
      'en':
          "Take Suhur (pre-dawn meal). Surely, there is a blessing in Suhur. (Sahih al-Bukhari 1923, Sahih Muslim 1095)",
      'bn':
          "রোজা রাখার জন্য সাহ্‌রি খাও; নিশ্চয়ই সাহরিতে বরকত আছে। (সহিহ বুখারি ১৯২৩, সহিহ মুসলিম ১০৯৫)",
    },
    'fastingEtiquetteContent': {
      'en':
          "Fasting is not just abstaining from food and drink, but also restraining the eyes, ears, tongue and all limbs from sins.",
      'bn':
          "শুধু খাবার-পানাহার থেকে বিরত থাকা নয়, বরং চোখ, কান, জিহ্বা ও সব অঙ্গ-প্রত্যঙ্গকে পাপ থেকে সংযত রাখা।",
    },
    'rewardInfoContent': {
      'en':
          "Every good deed in Ramadan is rewarded 70 times more. So perform as many good deeds as possible.",
      'bn':
          "রমজানের প্রতিটি নেকির সওয়াব ৭০ গুণ বেশি। তাই বেশি বেশি নেক আমল করুন।",
    },
    'fastingProgress': {'en': 'Fasting Progress', 'bn': 'রোজার অগ্রগতি'},
    'remaining': {'en': 'Remaining', 'bn': 'বাকি'},
    'completed': {'en': 'Completed', 'bn': 'সম্পন্ন'},
  };

  // হেল্পার মেথড - ভাষা অনুযায়ী টেক্সট পাওয়ার জন্য
  String _text(String key, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

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
  // ---------- বিজ্ঞাপন ভেরিয়েবল ----------
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  Timer? _interstitialTimer;
  int _interstitialAdCountToday = 0;
  bool _showInterstitialAds = true;
  final int _maxInterstitialPerDay = 3;
  List<DateTime> _interstitialShowTimes = []; // 👈 কখন কখন অ্যাড শো হয়েছে

  // ---------- হাদিস ভেরিয়েবল ----------
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
    _loadAd();
    _startInterstitialTimers(); // 👈 মাল্টিপল টাইমার শুরু
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
  // ---------- অ্যাড সিস্টেম ইনিশিয়ালাইজেশন ----------
  // ---------- অ্যাড সিস্টেম ইনিশিয়ালাইজেশন ----------
  Future<void> _initializeAds() async {
    try {
      await AdHelper.initialize();
      final prefs = await SharedPreferences.getInstance();

      _showInterstitialAds = prefs.getBool('show_interstitial_ads') ?? true;

      final lastShownDate = prefs.getString('last_interstitial_date_ifter');
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastShownDate == today) {
        _interstitialAdCountToday =
            prefs.getInt('interstitial_count_ifter') ?? 0;

        // 👈 পূর্বের শো টাইমস লোড করুন
        final savedTimes = prefs.getStringList('interstitial_times_ifter');
        if (savedTimes != null) {
          _interstitialShowTimes = savedTimes
              .map((timeStr) => DateTime.parse(timeStr))
              .toList();
        }
      } else {
        _interstitialAdCountToday = 0;
        _interstitialShowTimes = []; // 👈 নতুন দিন - টাইমস ক্লিয়ার
        await prefs.setInt('interstitial_count_ifter', 0);
        await prefs.setString('last_interstitial_date_ifter', today);
        await prefs.setStringList('interstitial_times_ifter', []);
      }

      print(
        'ইফতার পেজ - অ্যাড সিস্টেম ইনিশিয়ালাইজড: আজকে দেখানো হয়েছে = $_interstitialAdCountToday/$_maxInterstitialPerDay',
      );

      // 👈 অ্যাড শিডিউল শুরু করুন
      _scheduleInterstitialAds();
    } catch (e) {
      print('ইফতার পেজ - অ্যাড ইনিশিয়ালাইজেশনে ত্রুটি: $e');
    }
  }

  // ---------- অ্যাড শিডিউলিং ----------
  void _scheduleInterstitialAds() {
    if (_interstitialAdCountToday >= _maxInterstitialPerDay) {
      print('আজকের জন্য সব অ্যাড শো করা已完成');
      return;
    }

    final now = DateTime.now();

    // 👈 বিভিন্ন সময়ের জন্য শিডিউল
    final scheduledTimes = _calculateAdScheduleTimes();

    for (final scheduledTime in scheduledTimes) {
      if (scheduledTime.isAfter(now)) {
        final duration = scheduledTime.difference(now);

        print(
          'অ্যাড শিডিউলড: ${scheduledTime.hour}:${scheduledTime.minute} - ${duration.inMinutes} মিনিট পর',
        );

        Timer(duration, () {
          if (_interstitialAdCountToday < _maxInterstitialPerDay) {
            _showInterstitialAdIfNeeded();
          }
        });
      }
    }
  }

  // ---------- অ্যাড শিডিউল টাইমস ক্যালকুলেশন ----------
  List<DateTime> _calculateAdScheduleTimes() {
    final now = DateTime.now();
    final List<DateTime> scheduledTimes = [];

    // 👈 প্রথম অ্যাড - ১০ সেকেন্ড পর (যদি আজকে ০টি শো হয়ে থাকে)
    if (_interstitialAdCountToday == 0) {
      scheduledTimes.add(now.add(Duration(seconds: 10)));
    }

    // 👈 বাকি অ্যাডগুলোর জন্য র্যান্ডম/ফিক্সড টাইমস
    if (_interstitialAdCountToday < _maxInterstitialPerDay) {
      final remainingAds = _maxInterstitialPerDay - _interstitialAdCountToday;

      for (int i = 0; i < remainingAds; i++) {
        // র্যান্ডম সময় (৩০ মিনিট থেকে ২ ঘন্টার মধ্যে)
        final randomMinutes = 30 + (i * 90); // 30min, 2h, 3.5h
        scheduledTimes.add(now.add(Duration(minutes: randomMinutes)));
      }
    }

    return scheduledTimes;
  }

  // ---------- ইন্টারস্টিশিয়াল অ্যাড টাইমার শুরু ----------
  void _startInterstitialTimer() {
    _interstitialTimer?.cancel();
    _interstitialTimer = Timer(Duration(seconds: 10), () {
      _showInterstitialAdIfNeeded();
    });
  }

  // ---------- ইন্টারস্টিশিয়াল অ্যাড শো ----------
  // ---------- ইন্টারস্টিশিয়াল অ্যাড শো ----------
  // ---------- ইন্টারস্টিশিয়াল অ্যাড শো ----------
  Future<void> _showInterstitialAdIfNeeded() async {
    try {
      if (!_showInterstitialAds) return;

      if (_interstitialAdCountToday >= _maxInterstitialPerDay) {
        print(
          'ডেইলি interstitial লিমিট reached: $_interstitialAdCountToday/$_maxInterstitialPerDay',
        );
        return;
      }

      // 👈 শেষ অ্যাড শো হওয়ার কমপক্ষে ১৫ মিনিট পর চেক
      if (_interstitialShowTimes.isNotEmpty) {
        final lastShowTime = _interstitialShowTimes.last;
        final timeSinceLastAd = DateTime.now().difference(lastShowTime);

        if (timeSinceLastAd.inMinutes < 15) {
          print('অ্যাড শো করতে কমপক্ষে ১৫ মিনিট অপেক্ষা করুন');
          return;
        }
      }

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
        adContext: 'IfterTimePage',
      );
    } catch (e) {
      print('Interstitial অ্যাড শো করতে ত্রুটি: $e');
    }
  }

  // ---------- ইন্টারস্টিশিয়াল অ্যাড রেকর্ড ----------
  // ---------- ইন্টারস্টিশিয়াল অ্যাড রেকর্ড ----------
  // ---------- ইন্টারস্টিশিয়াল অ্যাড রেকর্ড ----------
  void _recordInterstitialShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentTime = DateTime.now();

      _interstitialAdCountToday++;
      _interstitialShowTimes.add(currentTime);

      await prefs.setString('last_interstitial_date_ifter', today);
      await prefs.setInt('interstitial_count_ifter', _interstitialAdCountToday);

      // 👈 টাইমস সেভ করুন
      final timeStrings = _interstitialShowTimes
          .map((time) => time.toIso8601String())
          .toList();
      await prefs.setStringList('interstitial_times_ifter', timeStrings);

      print(
        'Interstitial অ্যাড কাউন্ট আপডেট: $_interstitialAdCountToday/$_maxInterstitialPerDay',
      );
      print('শো টাইমস: $_interstitialShowTimes');

      // 👈 পরবর্তী অ্যাডের শিডিউল
      _scheduleNextAd();
    } catch (e) {
      print('Interstitial অ্যাড রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // ---------- পরবর্তী অ্যাড শিডিউল ----------
  void _scheduleNextAd() {
    if (_interstitialAdCountToday >= _maxInterstitialPerDay) {
      print('আজকের জন্য সব অ্যাড শো করা已完成');
      return;
    }

    final now = DateTime.now();

    // 👈 পরবর্তী অ্যাডের সময় (বর্তমান সময় + ২-৪ ঘন্টা)
    final nextAdMinutes = 120 + (Random().nextInt(120)); // ২-৪ ঘন্টা
    final nextAdTime = now.add(Duration(minutes: nextAdMinutes));

    print(
      'পরবর্তী অ্যাড শিডিউলড: ${nextAdTime.hour}:${nextAdTime.minute} - $nextAdMinutes মিনিট পর',
    );

    Timer(Duration(minutes: nextAdMinutes), () {
      if (_interstitialAdCountToday < _maxInterstitialPerDay) {
        _showInterstitialAdIfNeeded();
      }
    });
  }

  // ---------- মাল্টিপল ইন্টারস্টিশিয়াল টাইমার শুরু ----------
  void _startInterstitialTimers() {
    _interstitialTimer?.cancel();

    // 👈 ৩টি টাইমার - ভিন্ন ভিন্ন সময়ে
    _interstitialTimer = Timer(Duration(seconds: 10), () {
      _showInterstitialAdIfNeeded();
    });

    // দ্বিতীয় অ্যাড - ৩০ সেকেন্ড পর
    Timer(Duration(seconds: 30), () {
      _showInterstitialAdIfNeeded();
    });

    // তৃতীয় অ্যাড - ৬০ সেকেন্ড পর
    Timer(Duration(seconds: 60), () {
      _showInterstitialAdIfNeeded();
    });
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
            return _buildAdjustmentDialog(setState, context);
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
  Widget _buildAdjustmentDialog(
    void Function(void Function()) setState,
    BuildContext context,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: AppColors.getCardColor(isDarkMode),
      title: Row(
        children: [
          Icon(Icons.schedule, color: AppColors.getPrimaryColor(isDarkMode)),
          SizedBox(width: 8),
          Text(
            _text('adjustTime', context),
            style: TextStyle(color: AppColors.getTextColor(isDarkMode)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _text('adjustDescription', context),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          _buildCurrentAdjustmentDisplay(context),
          SizedBox(height: 20),
          _buildAdjustmentButtons(setState, context),
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
          child: Text(
            _text('cancel', context),
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _saveAdjustmentSettings(iftarTimeAdjustment);
            Navigator.of(context).pop();
            setState(() {
              _showAdjustmentDialog = false;
            });
            _showAdjustmentSuccessSnackbar(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.getPrimaryColor(isDarkMode),
          ),
          child: Text(_text('save', context)),
        ),
      ],
    );
  }

  // ---------- বর্তমান অ্যাডজাস্টমেন্ট ডিসপ্লে ----------
  Widget _buildCurrentAdjustmentDisplay(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
      ),
      child: Column(
        children: [
          Text(
            _text('currentAdjustment', context),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          SizedBox(height: 5),
          Text(
            "${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment ${_text('minutes', context)}",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iftarTimeAdjustment == 0
                  ? AppColors.getTextSecondaryColor(isDarkMode)
                  : iftarTimeAdjustment > 0
                  ? AppColors.getAccentColor('green', isDarkMode)
                  : AppColors.getErrorColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- অ্যাডজাস্টমেন্ট বাটন ----------
  Widget _buildAdjustmentButtons(
    void Function(void Function()) setState,
    BuildContext context,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAdjustmentButton(
          Icons.remove,
          AppColors.getErrorColor(isDarkMode),
          () {
            setState(() => iftarTimeAdjustment -= 1);
          },
          context,
        ),
        _buildAdjustmentButton(
          Icons.refresh,
          AppColors.getAccentColor('orange', isDarkMode),
          () {
            setState(() => iftarTimeAdjustment = 0);
          },
          context,
        ),
        _buildAdjustmentButton(
          Icons.add,
          AppColors.getAccentColor('green', isDarkMode),
          () {
            setState(() => iftarTimeAdjustment += 1);
          },
          context,
        ),
      ],
    );
  }

  // ---------- অ্যাডজাস্টমেন্ট বাটন বিল্ড ----------
  Widget _buildAdjustmentButton(
    IconData icon,
    Color color,
    VoidCallback onPressed,
    BuildContext context,
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
  void _showAdjustmentSuccessSnackbar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          iftarTimeAdjustment == 0
              ? _text('timeReset', context)
              : "${_text('timeAdjusted', context)} ${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment ${_text('minutes', context)}",
        ),
        duration: Duration(seconds: 2),
        backgroundColor: iftarTimeAdjustment == 0
            ? AppColors.getAccentColor('orange', isDarkMode)
            : AppColors.getAccentColor('green', isDarkMode),
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
      cityName = prefs.getString("cityName") ?? _text('unknown', context);
      countryName = prefs.getString("countryName") ?? _text('unknown', context);
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
    final random = DateTime.now().millisecondsSinceEpoch % 7; // 7টি হাদিস
    final hadithKey = 'hadith${random + 1}';

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';

    setState(() {
      _currentHadith = _texts[hadithKey]?[langKey] ?? "হাদিস লোড হচ্ছে...";
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
  Color _getCountdownColor(Duration remainingTime, bool isDarkMode) {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    if (hours > 1) return AppColors.getAccentColor('green', isDarkMode);
    if (hours == 1) return AppColors.getAccentColor('orange', isDarkMode);
    if (minutes > 30) return Colors.orange;
    if (minutes > 10) return Colors.deepOrange;
    return AppColors.getErrorColor(isDarkMode);
  }

  // ---------- প্রোগ্রেস টেক্সট ----------
  String _getProgressText(Duration remainingTime, BuildContext context) {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    if (hours > 1) return _text('comingSoon', context);
    if (hours == 1) return _text('getReady', context);
    if (minutes > 30) return _text('littleTimeLeft', context);
    if (minutes > 10) return _text('soonIftar', context);
    return _text('nearIftar', context);
  }

  // ==================== UI কম্পোনেন্ট বিল্ডার মেথড ====================

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = AppColors.getPrimaryColor(isDarkMode);
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context),
      body: _buildBody(isDarkMode, context),
      bottomNavigationBar: _buildBannerAd(),
    );
  }

  // ---------- অ্যাপবার বিল্ড ----------
  AppBar _buildAppBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: AppColors.getAppBarColor(isDarkMode),
      title: Text(
        _text('pageTitle', context),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white, // সবসময় সাদা টেক্সট
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
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
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_calendar_rounded,
                      size: 14,
                      color: AppColors.lightPrimary, // সবসময় প্রাইমারী কালার
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _text('timeSetting', context),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightPrimary, // সবসময় প্রাইমারী কালার
                        letterSpacing: 0.3,
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
  Widget _buildBody(bool isDarkMode, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final padding = isTablet ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              _buildLocationSection(isDarkMode, isTablet, context),
              SizedBox(height: isTablet ? 32 : 24),
              _buildCountdownSection(isDarkMode, isTablet, context),
              SizedBox(height: isTablet ? 32 : 24),
              _buildTimeSection(isDarkMode, isTablet, context),
              SizedBox(height: isTablet ? 32 : 24),
              _buildHadithSection(isDarkMode, isTablet, context),
              SizedBox(height: isTablet ? 32 : 24),
              _buildInfoSection(isDarkMode, isTablet, context),
            ],
          ),
        );
      },
    );
  }

  // ---------- লোকেশন UI সেকশন ----------
  Widget _buildLocationSection(
    bool isDarkMode,
    bool isTablet,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 6 : 4),
            decoration: BoxDecoration(
              color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              size: isTablet ? 20 : 18,
              color: AppColors.getPrimaryColor(isDarkMode),
            ),
          ),
          SizedBox(width: isTablet ? 10 : 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${cityName ?? _text('unknown', context)}, ${countryName ?? _text('unknown', context)}",
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (iftarTimeAdjustment != 0) ...[
                  SizedBox(height: 4),
                  _buildCompactAdjustmentIndicator(isDarkMode, context),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                size: isTablet ? 20 : 18,
                color: AppColors.getPrimaryColor(isDarkMode),
              ),
              onPressed: _loadSavedData,
              tooltip: _text('refreshData', context),
              padding: EdgeInsets.all(isTablet ? 6 : 4),
              constraints: BoxConstraints(
                minWidth: isTablet ? 36 : 32,
                minHeight: isTablet ? 36 : 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- কম্প্যাক্ট অ্যাডজাস্টমেন্ট ইন্ডিকেটর ----------
  Widget _buildCompactAdjustmentIndicator(
    bool isDarkMode,
    BuildContext context,
  ) {
    final adjustmentColor = iftarTimeAdjustment > 0
        ? AppColors.getAccentColor('green', isDarkMode)
        : AppColors.getErrorColor(isDarkMode);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: adjustmentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: adjustmentColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iftarTimeAdjustment > 0 ? Icons.arrow_upward : Icons.arrow_downward,
            size: 10,
            color: adjustmentColor,
          ),
          SizedBox(width: 2),
          Text(
            "${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment ${_text('minutes', context)}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: adjustmentColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- কাউন্টডাউন UI সেকশন ----------
  // ---------- কাউন্টডাউন UI সেকশন ----------
  Widget _buildCountdownSection(
    bool isDarkMode,
    bool isTablet,
    BuildContext context,
  ) {
    final countdownSize = isTablet ? 320.0 : 240.0; // বড় করা হয়েছে
    final countdownColor = _getCountdownColor(iftarCountdown, isDarkMode);
    final progressValue = _calculateProgress(iftarCountdown);

    return Container(
      padding: EdgeInsets.all(isTablet ? 28 : 20), // padding বড় করা
      margin: EdgeInsets.symmetric(vertical: 8), // margin যোগ করা
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? AppColors.darkHeaderGradient
              : [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(24), // borderRadius বড় করা
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25, // blurRadius বড় করা
            offset: Offset(0, 8), // offset বড় করা
            spreadRadius: 2,
          ),
          BoxShadow(
            color: countdownColor.withOpacity(0.3),
            blurRadius: 40, // blurRadius বড় করা
            offset: Offset(0, 0),
            spreadRadius: 3,
          ),
        ],
        border: Border.all(
          color: AppColors.getBorderColor(isDarkMode),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEnhancedCountdownHeader(
            isTablet,
            countdownColor,
            isDarkMode,
            context,
          ),
          SizedBox(height: isTablet ? 24 : 20), // spacing বড় করা
          Stack(
            alignment: Alignment.center,
            children: [
              _buildBackgroundEffects(
                countdownSize,
                countdownColor,
                progressValue,
                isDarkMode,
              ),
              _buildEnhancedCountdownTimer(
                countdownSize,
                countdownColor,
                isTablet,
                isDarkMode,
                context,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 20), // spacing বড় করা
          _buildEnhancedIftarTimeDisplay(
            isTablet,
            countdownColor,
            progressValue,
            isDarkMode,
            context,
          ),
        ],
      ),
    );
  }

  // ---------- এনহ্যান্সড কাউন্টডাউন হেডার ----------
  Widget _buildEnhancedCountdownHeader(
    bool isTablet,
    Color accentColor,
    bool isDarkMode,
    BuildContext context,
  ) {
    final textColor = isDarkMode
        ? Colors.white
        : Colors.white; // লাইট মুডেও সাদা টেক্সট

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(isDarkMode ? 0.3 : 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.nightlight_round,
                color: textColor.withOpacity(0.9),
                size: isTablet ? 22 : 18,
              ),
              SizedBox(width: 8),
              Text(
                _text('remainingTime', context),
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        if (iftarTimeAdjustment != 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDarkMode ? 0.15 : 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment ${_text('adjusted', context)}",
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                color: textColor.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // ---------- ব্যাকগ্রাউন্ড ইফেক্টস ----------
  // ---------- ব্যাকগ্রাউন্ড ইফেক্টস ----------
  Widget _buildBackgroundEffects(
    double size,
    Color accentColor,
    double progress,
    bool isDarkMode,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.15, // বড় করা
            height: size * 1.15, // বড় করা
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.25), // opacity বাড়ানো
                  accentColor.withOpacity(0.08), // opacity বাড়ানো
                  Colors.transparent,
                ],
                stops: [0.1, 0.6, 1.0], // stops সামঞ্জস্য করা
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(isDarkMode ? 0.08 : 0.15),
              // opacity বাড়ানো
              border: Border.all(
                color: Colors.white.withOpacity(isDarkMode ? 0.15 : 0.25),
                // opacity বাড়ানো
                width: 3, // border width বড় করা
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
    bool isDarkMode,
    BuildContext context,
  ) {
    final textColor = isDarkMode ? Colors.white : Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildDualProgressIndicator(size, accentColor, isDarkMode),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCompactTimeUnits(
                accentColor,
                isTablet,
                textColor,
                isDarkMode,
                context,
              ),
              // আপডেট
              SizedBox(height: 8),
              _buildProgressStatus(accentColor, isTablet, textColor, context),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- ডুয়েল প্রোগ্রেস ইন্ডিকেটর ----------
  Widget _buildDualProgressIndicator(
    double size,
    Color accentColor,
    bool isDarkMode,
  ) {
    final progress = _calculateProgress(iftarCountdown);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              // strokeWidth বড় করা
              backgroundColor: Colors.white.withOpacity(isDarkMode ? 0.2 : 0.3),
              // opacity বাড়ানো
              valueColor: AlwaysStoppedAnimation<Color>(
                accentColor.withOpacity(0.7), // opacity বাড়ানো
              ),
            ),
          ),
          Container(
            width: size * 0.65, // বড় করা
            height: size * 0.65, // বড় করা
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.4), // opacity বাড়ানো
                  accentColor.withOpacity(0.15), // opacity বাড়ানো
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
  // ---------- কম্প্যাক্ট টাইম ইউনিটস ----------
  // ---------- কম্প্যাক্ট টাইম ইউনিটস ----------
  Widget _buildCompactTimeUnits(
    Color accentColor,
    bool isTablet,
    Color textColor,
    bool isDarkMode,
    BuildContext context,
  ) {
    return IntrinsicHeight(
      // সব children এর height সমান করবে
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildEnhancedTimeUnit(
            _text('hours', context),
            iftarCountdown.inHours,
            accentColor,
            isTablet,
            textColor,
          ),
          _buildTimeSeparator(accentColor, isTablet, isDarkMode),
          _buildEnhancedTimeUnit(
            _text('minutesShort', context),
            iftarCountdown.inMinutes % 60,
            accentColor,
            isTablet,
            textColor,
          ),
          _buildTimeSeparator(accentColor, isTablet, isDarkMode),
          _buildEnhancedTimeUnit(
            _text('seconds', context),
            iftarCountdown.inSeconds % 60,
            accentColor,
            isTablet,
            textColor,
          ),
        ],
      ),
    );
  }

  // ---------- টাইম সেপারেটর ----------
  // ---------- টাইম সেপারেটর ----------
  Widget _buildTimeSeparator(Color color, bool isTablet, bool isDarkMode) {
    final separatorColor = isDarkMode ? color.withOpacity(0.9) : Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6),
      // left-right padding যোগ
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            ":",
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w900,
              color: separatorColor,
              height: 1.0,
              shadows: isDarkMode
                  ? null
                  : [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 3,
                        offset: Offset(1, 1),
                      ),
                    ],
            ),
          ),
          SizedBox(height: isTablet ? 32 : 28),
          Opacity(
            opacity: 0,
            child: Text(" ", style: TextStyle(fontSize: isTablet ? 14 : 12)),
          ),
        ],
      ),
    );
  }

  // ---------- এনহ্যান্সড টাইম ইউনিট ----------
  Widget _buildEnhancedTimeUnit(
    String label,
    int value,
    Color color,
    bool isTablet,
    Color textColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 10, // padding বড় করা
            vertical: isTablet ? 12 : 8, // padding বড় করা
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.4),
                color.withOpacity(0.15),
              ], // opacity বাড়ানো
            ),
            borderRadius: BorderRadius.circular(12),
            // borderRadius বড় করা
            border: Border.all(color: color.withOpacity(0.6), width: 2),
            // border width বড় করা
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3), // opacity বাড়ানো
                blurRadius: 12, // blurRadius বড় করা
                offset: Offset(0, 4), // offset বড় করা
              ),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              // ফন্ট সাইজ বড় করা
              fontWeight: FontWeight.w900,
              // ফন্ট ওয়েট বাড়ানো
              color: textColor,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: 1.0, // letter spacing যোগ করা
            ),
          ),
        ),
        SizedBox(height: 6), // spacing বড় করা
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12, // ফন্ট সাইজ বড় করা
            fontWeight: FontWeight.w700, // ফন্ট ওয়েট বাড়ানো
            color: textColor.withOpacity(0.9), // opacity বাড়ানো
            letterSpacing: 0.8, // letter spacing বাড়ানো
          ),
        ),
      ],
    );
  }

  // ---------- প্রোগ্রেস স্ট্যাটাস ----------
  Widget _buildProgressStatus(
    Color accentColor,
    bool isTablet,
    Color textColor,
    BuildContext context,
  ) {
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
            _getProgressText(iftarCountdown, context),
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.9), // সাদা টেক্সট ব্যবহার
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  //============
  // ---------- এনহ্যান্সড ইফতার সময় ডিসপ্লে ----------
  Widget _buildEnhancedIftarTimeDisplay(
    bool isTablet,
    Color accentColor,
    double progress,
    bool isDarkMode,
    BuildContext context,
  ) {
    final textColor = isDarkMode ? Colors.white : Colors.white;

    // Screen width based responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 360;
    final isMediumMobile = screenWidth < 400;
    final isLargeMobile = screenWidth < 480;

    // Calculate remaining fasting percentage with safety checks
    final remainingPercentage = (progress * 100)
        .clamp(0, 100)
        .toStringAsFixed(0);
    final completedPercentage = ((100 - progress * 100).clamp(
      0,
      100,
    )).toStringAsFixed(0);

    // Safe progress value (0 to 1)
    final safeProgress = progress.clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(
        isTablet
            ? 24
            : isSmallMobile
            ? 16
            : isMediumMobile
            ? 18
            : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDarkMode ? 0.12 : 0.2),
        borderRadius: BorderRadius.circular(
          isTablet
              ? 24
              : isSmallMobile
              ? 18
              : 20,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(isDarkMode ? 0.25 : 0.35),
          width: isTablet ? 2 : 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Circle with percentage
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: isTablet
                    ? 80
                    : isSmallMobile
                    ? 50
                    : isMediumMobile
                    ? 60
                    : 70,
                height: isTablet
                    ? 80
                    : isSmallMobile
                    ? 50
                    : isMediumMobile
                    ? 60
                    : 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.1),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: isTablet ? 3 : 2,
                  ),
                ),
              ),
              // Progress indicator
              SizedBox(
                width: isTablet
                    ? 80
                    : isSmallMobile
                    ? 50
                    : isMediumMobile
                    ? 60
                    : 70,
                height: isTablet
                    ? 80
                    : isSmallMobile
                    ? 50
                    : isMediumMobile
                    ? 60
                    : 70,
                child: CircularProgressIndicator(
                  value: 1 - safeProgress, // Show completed progress
                  strokeWidth: isTablet ? 4 : 3,
                  backgroundColor: accentColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              // Percentage text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$remainingPercentage%',
                    style: TextStyle(
                      fontSize: isTablet
                          ? 18
                          : isSmallMobile
                          ? 12
                          : isMediumMobile
                          ? 14
                          : 16,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  Text(
                    _text('remaining', context),
                    style: TextStyle(
                      fontSize: isTablet
                          ? 10
                          : isSmallMobile
                          ? 6
                          : isMediumMobile
                          ? 8
                          : 9,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(
            width: isTablet
                ? 20
                : isSmallMobile
                ? 12
                : isMediumMobile
                ? 15
                : 18,
          ),

          // Progress details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _text('fastingProgress', context),
                  style: TextStyle(
                    fontSize: isTablet
                        ? 18
                        : isSmallMobile
                        ? 12
                        : isMediumMobile
                        ? 14
                        : 16,
                    fontWeight: FontWeight.w700,
                    color: textColor.withOpacity(0.9),
                  ),
                ),
                SizedBox(
                  height: isTablet
                      ? 8
                      : isSmallMobile
                      ? 4
                      : isMediumMobile
                      ? 5
                      : 6,
                ),

                // Progress bar - FIXED
                Container(
                  height: isTablet
                      ? 12
                      : isSmallMobile
                      ? 6
                      : isMediumMobile
                      ? 8
                      : 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Progress - FIXED WIDTH CALCULATION
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Safe width calculation
                          final maxWidth = constraints.maxWidth;
                          final progressWidth = maxWidth * (1 - safeProgress);

                          // Ensure width is not negative and within bounds
                          final safeWidth = progressWidth.clamp(0.0, maxWidth);

                          return AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            width: safeWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor,
                                  accentColor.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: isTablet
                      ? 8
                      : isSmallMobile
                      ? 4
                      : isMediumMobile
                      ? 5
                      : 6,
                ),

                // Progress stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_text('completed', context)}: $completedPercentage%',
                      style: TextStyle(
                        fontSize: isTablet
                            ? 12
                            : isSmallMobile
                            ? 8
                            : isMediumMobile
                            ? 10
                            : 11,
                        color: textColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_text('remaining', context)}: $remainingPercentage%',
                      style: TextStyle(
                        fontSize: isTablet
                            ? 12
                            : isSmallMobile
                            ? 8
                            : isMediumMobile
                            ? 10
                            : 11,
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //====================
  // ---------- হাদিস UI সেকশন ----------
  Widget _buildHadithSection(
    bool isDarkMode,
    bool isTablet,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getBorderColor(isDarkMode),
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
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: isTablet ? 28 : 24,
                color: AppColors.getAccentColor('blue', isDarkMode),
              ),
              SizedBox(width: 12),
              Text(
                _text('ramadanHadith', context),
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(isDarkMode),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentHadith,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppColors.getTextColor(isDarkMode),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _selectRandomHadith,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getAccentColor('blue', isDarkMode),
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
                    _text('nextHadith', context),
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
  Widget _buildTimeSection(
    bool isDarkMode,
    bool isTablet,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
      ),
      child: Column(
        children: [
          Text(
            "⏰ ${_text('todaysSchedule', context)}",
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  icon: Icons.nights_stay,
                  title: _text('sehriEnd', context),
                  time: _calculateSehriTime(),
                  color: AppColors.getAccentColor('orange', isDarkMode),
                  isDarkMode: isDarkMode,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: _buildTimeCard(
                  icon: Icons.wb_sunny,
                  title: _text('iftar', context),
                  time: _getIftarTime(),
                  color: AppColors.getPrimaryColor(isDarkMode),
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
        color: AppColors.getSurfaceColor(isDarkMode),
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
              color: AppColors.getTextColor(isDarkMode),
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
  Widget _buildInfoSection(
    bool isDarkMode,
    bool isTablet,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.getBorderColor(isDarkMode)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.getAccentColor('blue', isDarkMode),
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: 12),
              Text(
                _text('importantInfo', context),
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoItem(
            _text('iftarDua', context),
            _text('iftarDuaContent', context),
            isDarkMode,
            isTablet,
          ),
          SizedBox(height: 12),
          _buildInfoItem(
            _text('prophetSaid', context),
            _text('prophetSaidContent', context),
            isDarkMode,
            isTablet,
          ),
          SizedBox(height: 12),
          _buildInfoItem(
            _text('fastingEtiquette', context),
            _text('fastingEtiquetteContent', context),
            isDarkMode,
            isTablet,
          ),
          SizedBox(height: 12),
          _buildInfoItem(
            _text('rewardInfo', context),
            _text('rewardInfoContent', context),
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
        color: AppColors.getSurfaceColor(isDarkMode),
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
              color: AppColors.getAccentColor('blue', isDarkMode),
            ),
          ),
          SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: AppColors.getTextColor(isDarkMode),
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
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      return SafeArea(child: Container(height: 0));
    }
  }
}
