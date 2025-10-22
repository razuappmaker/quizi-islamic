// prayer time page
// prayer_time_page.dart - Final Clean Version
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../../core/constants/ad_helper.dart';
import '../../../core/services/prayer_time_service.dart';
import '../../../core/services/prohibited_time_service.dart';
import '../../../core/utils/notification_manager.dart';
import '../../widgets/common/prayer_header_section.dart';
import '../../widgets/prayer/prayer_list_section.dart';
import '../../widgets/prayer/prohibited_time_section.dart';
import '../../widgets/qibla/location_modal.dart';
import '../../widgets/prayer/prayer_time_adjustment_modal.dart';
import '../../../core/constants/app_colors.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({Key? key}) : super(key: key);

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage>
    with WidgetsBindingObserver {
  // ---------- Services ----------
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  late NotificationManager _notificationManager; // Updated
  ProhibitedTimeService? _prohibitedTimeService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // NotificationManager ইনিশিয়ালাইজ
    _notificationManager = NotificationManager();

    _initializeData();
    _loadAd();
    _initializeAds();
    _initializeNotificationSystem();
    _loadManualLocation();
    _loadPrayerTimeAdjustments();
    _startInterstitialTimer();
    _startNotificationMonitoring();

    // Context সেট করার জন্য PostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationManager.setContext(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prohibitedTimeService == null) {
      _prohibitedTimeService = ProhibitedTimeService(context);
    }

    // Language changes এর জন্য listener যোগ করুন
    final languageProvider = Provider.of<LanguageProvider>(context);
    languageProvider.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    print('🔄 Language changed, refreshing notifications...');
    if (mounted) {
      _notificationManager.setContext(context);
      _rescheduleNotifications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    _interstitialTimer?.cancel();
    _notificationCheckTimer?.cancel();
    _bannerAd?.dispose();
    AdHelper.disposeInterstitialAd();

    // Listener রিমুভ করুন
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      languageProvider.removeListener(_onLanguageChanged);
    } catch (e) {
      print('Error removing language listener: $e');
    }

    super.dispose();
  }

  // ---------- Prayer Times ----------
  String? cityName = "Loading...";
  String? countryName = "Loading...";
  Map<String, String> prayerTimes = {};
  String nextPrayer = "";
  Duration countdown = Duration.zero;
  Timer? timer;

  // ---------- Ads ----------
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  Timer? _interstitialTimer;
  DateTime? _lastInterstitialShownTime;
  bool _showInterstitialAds = true;

  // ---------- Permission Status ----------
  bool _locationPermissionGranted = false;
  bool _notificationPermissionGranted = false;

  // ---------- Internet Status ----------
  bool _isOnline = true;

  // ---------- Manual Location ----------
  bool _useManualLocation = false;
  double? _manualLatitude;
  double? _manualLongitude;
  String? _manualCityName;
  String? _manualCountryName;

  // ---------- Prayer Time Adjustments ----------
  Map<String, int> _prayerTimeAdjustments = {
    "ফজর": 0,
    "যোহর": 0,
    "আসর": 0,
    "মাগরিব": 0,
    "ইশা": 0,
  };

  // ---------- Timers ----------
  Timer? _notificationCheckTimer;

  // Language Texts
  final Map<String, Map<String, String>> _texts = {
    'title': {'en': 'Prayer Times', 'bn': 'নামাজের সময়'},
    'loading': {'en': 'Loading...', 'bn': 'লোড হচ্ছে...'},
    'unknown': {'en': 'Unknown', 'bn': 'অজানা'},
    'auto': {'en': 'Auto', 'bn': 'অটো'},
    'manual': {'en': 'Manual', 'bn': 'মানুয়াল'},
    'timeSettings': {'en': 'Time Settings', 'bn': 'সময় সেটিং'},
    'offlineMode': {
      'en': 'Offline Mode - Saved Data',
      'bn': 'অফলাইন মোড - সেভ করা ডেটা',
    },
    'noInternet': {
      'en': 'No internet connection. Showing saved times.',
      'bn': 'ইন্টারনেট সংযোগ নেই। সেভ করা সময় দেখানো হচ্ছে।',
    },
    'dataLoadError': {
      'en': 'Error loading data: ',
      'bn': 'ডেটা লোড করতে সমস্যা: ',
    },
    'resetSuccess': {
      'en': 'All adjustments reset',
      'bn': 'সব অ্যাডজাস্টমেন্ট রিসেট করা হয়েছে',
    },
    'interstitialShown': {
      'en': 'Fullscreen ad shown',
      'bn': 'পূর্ণস্ক্রিন অ্যাড দেখানো হয়েছে',
    },
    'fajr': {'en': 'Fajr', 'bn': 'ফজর'},
    'dhuhr': {'en': 'Dhuhr', 'bn': 'যোহর'},
    'asr': {'en': 'Asr', 'bn': 'আসর'},
    'maghrib': {'en': 'Maghrib', 'bn': 'মাগরিব'},
    'isha': {'en': 'Isha', 'bn': 'ইশা'},
    'ok': {'en': 'OK', 'bn': 'ঠিক আছে'},
    'manualLocation': {'en': 'Manual Location', 'bn': 'মানুয়াল লোকেশন'},
  };

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('App lifecycle state changed: $state');

    if (state == AppLifecycleState.resumed) {
      _checkAndRescheduleNotifications();
    } else if (state == AppLifecycleState.paused) {
      _ensureNotificationsScheduled();
    }
  }

  // নোটিফিকেশন সিস্টেম ইনিশিয়ালাইজেশন
  Future<void> _initializeNotificationSystem() async {
    await _notificationManager.initializeNotificationChannel();
  }

  // নোটিফিকেশন মনিটরিং শুরু করুন
  void _startNotificationMonitoring() {
    // ৫ সেকেন্ড পর প্রথম চেক
    Future.delayed(Duration(seconds: 5), () {
      _notificationManager.checkNotificationSystemHealth();
    });

    // প্রতি ১ ঘন্টা পর পর চেক
    _notificationCheckTimer = Timer.periodic(Duration(hours: 1), (timer) {
      _notificationManager.checkNotificationSystemHealth();
    });
  }

  Future<void> _ensureNotificationsScheduled() async {
    final shouldReschedule = await _notificationManager
        .shouldRescheduleNotifications();
    if (shouldReschedule) {
      await _scheduleAllNotifications();
    }
  }

  Future<void> _checkAndRescheduleNotifications() async {
    final shouldReschedule = await _notificationManager
        .shouldRescheduleNotifications();
    if (shouldReschedule) {
      await _scheduleAllNotifications();
    }
  }

  // সব নোটিফিকেশন শিডিউল করা
  Future<void> _scheduleAllNotifications() async {
    if (prayerTimes.isEmpty) return;

    await _notificationManager.scheduleAllPrayerNotifications(
      prayerTimes,
      _prayerTimeAdjustments,
    );
  }

  // নোটিফিকেশন রিশিডিউল করা
  Future<void> _rescheduleNotifications() async {
    await _scheduleAllNotifications();
    print('🔄 Notifications rescheduled with adjusted times');
  }

  // Helper method to get text based on current language
  String _text(String key) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

  // Get prayer name based on language
  String _getPrayerName(String prayerName) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    if (languageProvider.isEnglish) {
      switch (prayerName) {
        case 'ফজর':
          return 'Fajr';
        case 'যোহর':
          return 'Dhuhr';
        case 'আসর':
          return 'Asr';
        case 'মাগরিব':
          return 'Maghrib';
        case 'ইশা':
          return 'Isha';
        default:
          return prayerName;
      }
    }
    return prayerName;
  }

  // _initializeData মেথড
  Future<void> _initializeData() async {
    await _checkPermissions();
    await _loadSavedData();

    final hasInternet = await _prayerTimeService.checkInternetConnection();
    setState(() {
      _isOnline = hasInternet;
    });

    if (_locationPermissionGranted && hasInternet) {
      await fetchLocationAndPrayerTimes();
    } else {
      await _scheduleAllNotifications();
    }
  }

  // ম্যানুয়াল লোকেশন লোড করা
  Future<void> _loadManualLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useManualLocation = prefs.getBool('use_manual_location') ?? false;
      _manualLatitude = prefs.getDouble('manual_latitude');
      _manualLongitude = prefs.getDouble('manual_longitude');
      _manualCityName = prefs.getString('manual_city_name');
      _manualCountryName = prefs.getString('manual_country_name');
    });
  }

  // নামাজের সময় অ্যাডজাস্টমেন্ট লোড করা
  Future<void> _loadPrayerTimeAdjustments() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prayerTimeAdjustments = {
        "ফজর": prefs.getInt('adjustment_fajr') ?? 0,
        "যোহর": prefs.getInt('adjustment_dhuhr') ?? 0,
        "আসর": prefs.getInt('adjustment_asr') ?? 0,
        "মাগরিব": prefs.getInt('adjustment_maghrib') ?? 0,
        "ইশা": prefs.getInt('adjustment_isha') ?? 0,
      };
    });
  }

  // নামাজের সময় অ্যাডজাস্টমেন্ট সেভ করা
  Future<void> _savePrayerTimeAdjustments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('adjustment_fajr', _prayerTimeAdjustments["ফজর"]!);
    await prefs.setInt('adjustment_dhuhr', _prayerTimeAdjustments["যোহর"]!);
    await prefs.setInt('adjustment_asr', _prayerTimeAdjustments["আসর"]!);
    await prefs.setInt('adjustment_maghrib', _prayerTimeAdjustments["মাগরিব"]!);
    await prefs.setInt('adjustment_isha', _prayerTimeAdjustments["ইশা"]!);
  }

  // অ্যাডজাস্ট করা নামাজের সময় পাওয়া
  Map<String, String> get adjustedPrayerTimes {
    if (prayerTimes.isEmpty) return {};

    final adjustedTimes = Map<String, String>.from(prayerTimes);

    for (final entry in _prayerTimeAdjustments.entries) {
      final prayerName = entry.key;
      final adjustment = entry.value;

      if (adjustedTimes.containsKey(prayerName) && adjustment != 0) {
        final originalTime = adjustedTimes[prayerName]!;
        final adjustedTime = _adjustPrayerTime(originalTime, adjustment);
        adjustedTimes[prayerName] = adjustedTime;
      }
    }

    return adjustedTimes;
  }

  // নামাজের সময় অ্যাডজাস্ট করা
  String _adjustPrayerTime(String time, int adjustmentMinutes) {
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
      print('Error adjusting prayer time: $e');
      return time;
    }
  }

  // লোকেশন মোড পরিবর্তন
  Future<void> _changeLocationMode(
    bool useManual, {
    double? lat,
    double? lng,
    String? city,
    String? country,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _useManualLocation = useManual;
      if (useManual && lat != null && lng != null) {
        _manualLatitude = lat;
        _manualLongitude = lng;
        _manualCityName = city;
        _manualCountryName = country;
      }
    });

    await prefs.setBool('use_manual_location', useManual);
    if (useManual) {
      await prefs.setDouble('manual_latitude', lat!);
      await prefs.setDouble('manual_longitude', lng!);
      await prefs.setString(
        'manual_city_name',
        city ?? _text('manualLocation'),
      );
      await prefs.setString('manual_country_name', country ?? '');
    }

    await fetchLocationAndPrayerTimes();
  }

  // নামাজের সময় অ্যাডজাস্ট করা
  void _adjustPrayerTimeByName(String prayerName, int adjustment) {
    setState(() {
      _prayerTimeAdjustments[prayerName] =
          (_prayerTimeAdjustments[prayerName] ?? 0) + adjustment;
    });
    _savePrayerTimeAdjustments();
    findNextPrayer();
  }

  // লোকেশন মডাল শো করা
  void _showLocationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationModal(
        currentLocationMode: _useManualLocation ? 'manual' : 'auto',
        onLocationModeChanged: (mode, lat, lng, city, country) {
          if (mode == 'auto') {
            _changeLocationMode(false);
          } else {
            _changeLocationMode(
              true,
              lat: lat,
              lng: lng,
              city: city,
              country: country,
            );
          }
        },
      ),
    );
  }

  // সেটিংস মডাল শো করা
  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrayerTimeAdjustmentModal(
        prayerTimeAdjustments: _prayerTimeAdjustments,
        onAdjustmentChanged: _adjustPrayerTimeByName,
        onResetAll: _resetAllAdjustments,
        onSaveAdjustments: _savePrayerTimeAdjustments,
        onRescheduleNotifications: _rescheduleNotifications,
      ),
    );
  }

  // সব অ্যাডজাস্টমেন্ট রিসেট করা
  void _resetAllAdjustments() {
    setState(() {
      _prayerTimeAdjustments = {
        "ফজর": 0,
        "যোহর": 0,
        "আসর": 0,
        "মাগরিব": 0,
        "ইশা": 0,
      };
    });
    _savePrayerTimeAdjustments();
    findNextPrayer();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_text('resetSuccess'))));
  }

  // ব্যানার অ্যাড লোড করা
  Future<void> _loadAd() async {
    try {
      bool canShowAd = await AdHelper.canShowBannerAd();
      if (!canShowAd) {
        print('Banner ad limit reached, not showing ad');
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
            Future.delayed(Duration(seconds: 30), () {
              if (!_isBannerAdReady) _loadAd();
            });
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

  // অ্যাডস ইনিশিয়ালাইজেশন
  Future<void> _initializeAds() async {
    try {
      await AdHelper.initialize();
      final prefs = await SharedPreferences.getInstance();

      _showInterstitialAds = prefs.getBool('show_interstitial_ads') ?? true;

      final lastShownTimestamp = prefs.getInt('last_interstitial_timestamp');
      if (lastShownTimestamp != null) {
        _lastInterstitialShownTime = DateTime.fromMillisecondsSinceEpoch(
          lastShownTimestamp,
        );
        print('Last interstitial ad shown: $_lastInterstitialShownTime');
      } else {
        print('No previous interstitial ad found');
      }

      print('Ads initialized successfully');
    } catch (e) {
      print('অ্যাড ইনিশিয়ালাইজেশনে ত্রুটি: $e');
    }
  }

  // প্রতি ১ মিনিটে interstitial ad চেক করার টাইমার
  void _startInterstitialTimer() {
    _interstitialTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkAndShowInterstitialAd();
    });
    print('Interstitial ad timer started (checks every 1 minute)');
  }

  // interstitial ad চেক এবং শো করা
  void _checkAndShowInterstitialAd() {
    try {
      if (_canShowInterstitialAd()) {
        print('🔄 2 hours passed - showing interstitial ad');
        _showInterstitialAd();
      }
    } catch (e) {
      print('Error checking interstitial ad: $e');
    }
  }

  // interstitial ad দেখানোর যোগ্য কিনা চেক করা
  bool _canShowInterstitialAd() {
    if (!_showInterstitialAds) {
      print('Interstitial ads disabled by user');
      return false;
    }

    if (_lastInterstitialShownTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastInterstitialShownTime!);
    final canShow = difference.inHours >= 2;

    if (!canShow) {
      final hoursLeft = 2 - difference.inHours;
      final minutesLeft = 60 - difference.inMinutes % 60;
      print('Next interstitial ad in: $hoursLeft hours $minutesLeft minutes');
    }

    return canShow;
  }

  // interstitial ad দেখানো
  Future<void> _showInterstitialAd() async {
    try {
      if (!_canShowInterstitialAd()) return;

      print('Attempting to show interstitial ad...');

      AdHelper.showInterstitialAd(
        onAdShowed: _recordInterstitialShown,
        adContext: 'PrayerTimePage_2Hour',
      );
    } catch (e) {
      print('Error showing interstitial ad: $e');
    }
  }

  // interstitial ad দেখানোর সময় রেকর্ড করা
  void _recordInterstitialShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      setState(() {
        _lastInterstitialShownTime = now;
      });

      await prefs.setInt(
        'last_interstitial_timestamp',
        now.millisecondsSinceEpoch,
      );

      print('✅ Interstitial ad shown and recorded at: $now');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_text('interstitialShown')),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('❌ Interstitial অ্যাড রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // পারমিশন চেক
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
    _notificationPermissionGranted = await _notificationManager
        .checkAndRequestNotificationPermission();

    await prefs.setBool('locationPermission', _locationPermissionGranted);
    await prefs.setBool(
      'notificationPermission',
      _notificationPermissionGranted,
    );
  }

  // সেভ করা ডেটা লোড করা
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cityName = prefs.getString("cityName") ?? _text('unknown');
      countryName = prefs.getString("countryName") ?? _text('unknown');
      _locationPermissionGranted = prefs.getBool('locationPermission') ?? false;
      _notificationPermissionGranted =
          prefs.getBool('notificationPermission') ?? false;

      String? savedPrayerTimes = prefs.getString("prayerTimes");
      if (savedPrayerTimes != null) {
        prayerTimes = Map<String, String>.from(jsonDecode(savedPrayerTimes));
        findNextPrayer();
      }
    });
  }

  // লোকেশন এবং নামাজের সময় ফেচ করা
  Future<void> fetchLocationAndPrayerTimes() async {
    final hasInternet = await _prayerTimeService.checkInternetConnection();
    if (!hasInternet) {
      setState(() {
        _isOnline = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_text('noInternet'))));
      await _scheduleAllNotifications();
      return;
    }

    setState(() {
      _isOnline = true;
    });

    try {
      final result = await _prayerTimeService.fetchPrayerTimes(
        useManualLocation: _useManualLocation,
        manualLatitude: _manualLatitude,
        manualLongitude: _manualLongitude,
        manualCityName: _manualCityName,
        manualCountryName: _manualCountryName,
      );

      if (result != null) {
        setState(() {
          if (_useManualLocation && _manualCityName != null) {
            cityName = _manualCityName;
            countryName = _manualCountryName;
          } else {
            cityName = result['cityName'];
            countryName = result['countryName'];
          }
          prayerTimes = result['prayerTimes'];
        });

        findNextPrayer();
        _saveData();
        await _scheduleAllNotifications();
      }
    } catch (e) {
      print("Location fetch error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${_text('dataLoadError')}$e")));
    }
  }

  // ডেটা সেভ করা
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cityName", cityName ?? "");
    await prefs.setString("countryName", countryName ?? "");
    await prefs.setString("prayerTimes", jsonEncode(prayerTimes));
  }

  // পরবর্তী নামাজ খুঁজে বের করা
  void findNextPrayer() {
    final result = _prayerTimeService.findNextPrayer(adjustedPrayerTimes);

    if (result != null) {
      setState(() {
        nextPrayer = result['nextPrayer'];
        countdown = result['countdown'];
      });

      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final updatedResult = _prayerTimeService.findNextPrayer(
          adjustedPrayerTimes,
        );
        if (updatedResult != null) {
          setState(() {
            countdown = updatedResult['countdown'];
          });
        }
      });
    } else {
      setState(() {
        nextPrayer = _text('loading');
        countdown = Duration.zero;
      });
    }
  }

  Widget _buildOfflineIndicator() {
    if (_isOnline) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: AppColors.getAccentColor(
        'orange',
        Theme.of(context).brightness == Brightness.dark,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            _text('offlineMode'),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.getAppBarColor(isDarkMode),
        title: Text(
          _text('title'),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
        ),
        centerTitle: false,
        elevation: 0,
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
          // লোকেশন - ব্যাজ স্টাইল
          Container(
            margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showLocationModal,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.getPrimaryColor(isDarkMode),
                        AppColors.getPrimaryColor(isDarkMode).withOpacity(0.8),
                      ],
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
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _useManualLocation
                            ? Icons.location_off
                            : Icons.location_on,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _useManualLocation ? _text('manual') : _text('auto'),
                        style: TextStyle(
                          fontSize: 12,
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

          // সেটিংস - ফ্লোটিং একশন বাটন
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showSettingsModal,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.getPrimaryColor(isDarkMode),
                        AppColors.getPrimaryColor(isDarkMode).withOpacity(0.8),
                      ],
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
                      color: Colors.white.withOpacity(0.3),
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
                        _text('timeSettings'),
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
      ),
      body: _buildPrayerTab(),
      bottomNavigationBar: _buildBannerAd(),
    );
  }

  // Banner Ad Widget
  Widget _buildBannerAd() {
    if (_isBannerAdReady && _bannerAd != null) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return SafeArea(
        top: false,
        child: Container(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          alignment: Alignment.center,
          color: AppColors.getBackgroundColor(isDarkMode),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      return SafeArea(top: false, child: Container(height: 0));
    }
  }

  Widget _buildPrayerTab() {
    if (_prohibitedTimeService == null) {
      return Center(child: CircularProgressIndicator());
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final maxWidth = constraints.maxWidth;

        final bool isSmallScreen = maxHeight < 700;
        final bool isVerySmallScreen = maxHeight < 600;
        final bool isTablet = maxWidth > 600;
        final bool isSmallPhone = maxHeight < 600 || maxWidth < 360;

        return Column(
          children: [
            _buildOfflineIndicator(),

            PrayerHeaderSection(
              cityName: cityName,
              countryName: countryName,
              nextPrayer: nextPrayer,
              countdown: countdown,
              prayerTimes: adjustedPrayerTimes,
              isSmallScreen: isSmallScreen,
              isVerySmallScreen: isVerySmallScreen,
              isTablet: isTablet,
              isSmallPhone: isSmallPhone,
              prayerTimeService: _prayerTimeService,
              onRefresh: fetchLocationAndPrayerTimes,
              useManualLocation: _useManualLocation,
            ),

            Expanded(
              child: Container(
                color: AppColors.getBackgroundColor(isDarkMode),
                child: Column(
                  children: [
                    Expanded(
                      child: PrayerListSection(
                        prayerTimes: adjustedPrayerTimes,
                        nextPrayer: nextPrayer,
                        isSmallScreen: isSmallScreen,
                        isVerySmallScreen: isVerySmallScreen,
                        isTablet: isTablet,
                        isSmallPhone: isSmallPhone,
                        prayerTimeService: _prayerTimeService,
                        onRefresh: fetchLocationAndPrayerTimes,
                        onPrayerTap: _showPrayerTimeDetail,
                        prayerTimeAdjustments: _prayerTimeAdjustments,
                      ),
                    ),

                    ProhibitedTimeSection(
                      isSmallScreen: isSmallScreen,
                      isVerySmallScreen: isVerySmallScreen,
                      isTablet: isTablet,
                      isSmallPhone: isSmallPhone,
                      prayerTimes: adjustedPrayerTimes,
                      prohibitedTimeService: _prohibitedTimeService!,
                      onShowInfo: _showFloatingInfo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Prayer time detail dialog
  void _showPrayerTimeDetail(String prayerName, String time) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDarkMode),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _prayerTimeService.getPrayerIcon(prayerName),
                size: 48,
                color: AppColors.getPrimaryColor(isDarkMode),
              ),
              const SizedBox(height: 16),
              Text(
                _getPrayerName(prayerName),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _prayerTimeService.formatTimeTo12Hour(time),
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Monospace',
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimaryColor(isDarkMode),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  _text('ok'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFloatingInfo(BuildContext context, String title, String message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.getSurfaceColor(isDarkMode),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(isDarkMode),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.getTextColor(isDarkMode),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
