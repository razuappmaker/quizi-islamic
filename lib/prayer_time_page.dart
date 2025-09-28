// prayer_time_page.dart - Final Version

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'ad_helper.dart';
import 'prayer_time_service.dart';
import 'prohibited_time_service.dart';
import 'widgets/prayer_header_section.dart';
import 'widgets/prayer_list_section.dart';
import 'widgets/prohibited_time_section.dart';
import 'widgets/location_modal.dart';
import 'widgets/prayer_time_adjustment_modal.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({Key? key}) : super(key: key);

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {
  // ---------- Services ----------
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  final ProhibitedTimeService _prohibitedTimeService = ProhibitedTimeService();

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

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadAd();
    _initializeAds();
    _initializeNotificationChannel();
    _loadManualLocation();
    _loadPrayerTimeAdjustments();
    _startInterstitialTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    _interstitialTimer?.cancel();
    _bannerAd?.dispose();
    AdHelper.disposeInterstitialAd();
    super.dispose();
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

      // মিনিট অ্যাডজাস্ট করা
      minutes += adjustmentMinutes;

      // ঘণ্টা সামঞ্জস্য করা
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
      await prefs.setString('manual_city_name', city ?? 'মানুয়াল লোকেশন');
      await prefs.setString('manual_country_name', country ?? '');
    }

    // নতুন লোকেশনে নামাজের সময় আপডেট করুন
    await fetchLocationAndPrayerTimes();
  }

  // নামাজের সময় অ্যাডজাস্ট করা
  void _adjustPrayerTimeByName(String prayerName, int adjustment) {
    setState(() {
      _prayerTimeAdjustments[prayerName] =
          (_prayerTimeAdjustments[prayerName] ?? 0) + adjustment;
    });
    _savePrayerTimeAdjustments();

    // UI আপডেট করার জন্য
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("সব অ্যাডজাস্টমেন্ট রিসেট করা হয়েছে")),
    );
  }

  // নোটিফিকেশন চ্যানেল ইনিশিয়ালাইজেশন
  Future<void> _initializeNotificationChannel() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'prayer_reminder_channel',
        channelName: 'Prayer Reminders',
        channelDescription: 'Notifications for prayer times',
        defaultColor: Colors.green,
        ledColor: Colors.green,
        importance: NotificationImportance.High,
      ),
    ]);
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
            // ৩০ সেকেন্ড পর রিট্রাই
            Future.delayed(Duration(seconds: 30), () {
              if (!_isBannerAdReady) {
                _loadAd();
              }
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

      // শেষ interstitial ad দেখানোর সময় লোড করুন
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

    if (_lastInterstitialShownTime == null) {
      print('First interstitial ad - can show');
      return true;
    }

    final now = DateTime.now();
    final difference = now.difference(_lastInterstitialShownTime!);

    // ২ ঘণ্টার কম হলে দেখাবেন না
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

      // ইউজারকে জানানো (ঐচ্ছিক)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('পূর্ণস্ক্রিন অ্যাড দেখানো হয়েছে'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('❌ Interstitial অ্যাড রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // ডেটা ইনিশিয়ালাইজেশন
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
  }

  // লোকেশন এবং নামাজের সময় ফেচ করা
  Future<void> fetchLocationAndPrayerTimes() async {
    final hasInternet = await _prayerTimeService.checkInternetConnection();
    if (!hasInternet) {
      setState(() {
        _isOnline = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ইন্টারনেট সংযোগ নেই। সেভ করা সময় দেখানো হচ্ছে।"),
        ),
      );
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
      ).showSnackBar(SnackBar(content: Text("ডেটা লোড করতে সমস্যা: $e")));
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
        nextPrayer = "লোড হচ্ছে...";
        countdown = Duration.zero;
      });
    }
  }

  // সব নোটিফিকেশন শিডিউল করা
  Future<void> _scheduleAllNotifications() async {
    if (prayerTimes.isEmpty) return;

    for (final entry in prayerTimes.entries) {
      final prayerName = entry.key;
      final time = entry.value;

      if (["ফজর", "যোহর", "আসর", "মাগরিব", "ইশা"].contains(prayerName)) {
        await _schedulePrayerNotification(prayerName, time);
      }
    }
  }

  // নামাজের নোটিফিকেশন শিডিউল করা
  Future<void> _schedulePrayerNotification(
    String prayerName,
    String time,
  ) async {
    if (!_notificationPermissionGranted) return;

    try {
      await AwesomeNotifications().cancel(prayerName.hashCode);

      final prayerDate = _prayerTimeService.parsePrayerTime(time);
      if (prayerDate == null) return;

      final notificationTime = prayerDate.subtract(const Duration(minutes: 10));
      final now = DateTime.now();

      if (notificationTime.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: prayerName.hashCode,
            channelKey: 'prayer_reminder_channel',
            title: 'নামাজের সময়',
            body: '$prayerName নামাজ শুরু হওয়ার ১০ মিনিট বাকি',
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            year: notificationTime.year,
            month: notificationTime.month,
            day: notificationTime.day,
            hour: notificationTime.hour,
            minute: notificationTime.minute,
            second: 0,
          ),
        );
      } else {
        final tomorrowNotificationTime = notificationTime.add(
          const Duration(days: 1),
        );
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: prayerName.hashCode,
            channelKey: 'prayer_reminder_channel',
            title: 'নামাজের সময়',
            body: '$prayerName নামাজ শুরু হওয়ার ১০ মিনিট বাকি',
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            year: tomorrowNotificationTime.year,
            month: tomorrowNotificationTime.month,
            day: tomorrowNotificationTime.day,
            hour: tomorrowNotificationTime.hour,
            minute: tomorrowNotificationTime.minute,
            second: 0,
          ),
        );
      }
    } catch (e) {
      print("Error scheduling notification for $prayerName: $e");
    }
  }

  // Prayer time detail dialog
  void _showPrayerTimeDetail(String prayerName, String time) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _prayerTimeService.getPrayerIcon(prayerName),
                size: 48,
                color: _prayerTimeService.getPrayerColor(prayerName),
              ),
              const SizedBox(height: 16),
              Text(
                prayerName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _prayerTimeService.formatTimeTo12Hour(time),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Monospace',
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _prayerTimeService.getPrayerColor(
                    prayerName,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "ঠিক আছে",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    if (_isOnline) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            "অফলাইন মোড - সেভ করা ডেটা",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "আজকের ওয়াক্ত ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _useManualLocation ? Icons.location_off : Icons.location_on,
              color: Colors.white,
            ),
            onPressed: _showLocationModal,
            tooltip: "লোকেশন পরিবর্তন",
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsModal,
            tooltip: "সেটিংস",
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
      return SafeArea(
        top: false,
        child: Container(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          alignment: Alignment.center,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      return SafeArea(top: false, child: Container(height: 0));
    }
  }

  Widget _buildPrayerTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final bool isSmallScreen = maxHeight < 700;
        final bool isVerySmallScreen = maxHeight < 600;

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
              prayerTimeService: _prayerTimeService,
              onRefresh: fetchLocationAndPrayerTimes,
              useManualLocation: _useManualLocation,
            ),

            Expanded(
              child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    //? Colors.grey[900]
                    ? Colors.grey[900]
                    : Colors.grey.shade50,
                child: Column(
                  children: [
                    Expanded(
                      child: PrayerListSection(
                        prayerTimes: adjustedPrayerTimes,
                        nextPrayer: nextPrayer,
                        isSmallScreen: isSmallScreen,
                        isVerySmallScreen: isVerySmallScreen,
                        prayerTimeService: _prayerTimeService,
                        onRefresh: fetchLocationAndPrayerTimes,
                        onPrayerTap: _showPrayerTimeDetail,
                        prayerTimeAdjustments: _prayerTimeAdjustments,
                      ),
                    ),

                    ProhibitedTimeSection(
                      isSmallScreen: isSmallScreen,
                      prayerTimes: adjustedPrayerTimes,
                      prohibitedTimeService: _prohibitedTimeService,
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
}
