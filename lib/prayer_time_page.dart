// update Prayer Time page
// prayer_page.dart - শুধু ইম্পোর্ট অংশ
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
import 'ad_helper.dart';
import 'prayer_time_service.dart';
import 'prohibited_time_service.dart';

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
  BannerAd? _bannerAd; // ✅ Nullable করুন adaptive banner-এর জন্য
  bool _isBannerAdReady = false;
  Timer? _interstitialTimer;
  bool _interstitialAdShownToday = false;
  bool _showInterstitialAds = true;

  // ---------- Audio ----------
  final AudioPlayer _audioPlayer = AudioPlayer();
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
    _loadAd(); // ✅ Adaptive banner load
    _initializeAds();
  }

  @override
  void dispose() {
    timer?.cancel();
    _interstitialTimer?.cancel();
    _bannerAd?.dispose(); // ✅ Null safety সহ dispose
    _mp3Timers.forEach((key, t) => t.cancel());
    super.dispose();
  }

  // ✅ Adaptive Banner Ad লোড করা - TasbeehPage-এর মতোই
  Future<void> _loadAd() async {
    try {
      // ✅ AdHelper ব্যবহার করে adaptive banner তৈরি করুন
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

  // অ্যাড সিস্টেম ইনিশিয়ালাইজেশন
  Future<void> _initializeAds() async {
    try {
      await AdHelper.initialize();
      final prefs = await SharedPreferences.getInstance();

      _showInterstitialAds = prefs.getBool('show_interstitial_ads') ?? true;

      final lastShownDate = prefs.getString('last_interstitial_date');
      final today = DateTime.now().toIso8601String().split('T')[0];

      setState(() {
        _interstitialAdShownToday = (lastShownDate == today);
      });

      _startInterstitialTimer();
    } catch (e) {
      print('অ্যাড ইনিশিয়ালাইজেশনে ত্রুটি: $e');
    }
  }

  void _startInterstitialTimer() {
    _interstitialTimer?.cancel();
    _interstitialTimer = Timer(Duration(seconds: 10), () {
      _showInterstitialAdIfNeeded();
    });
  }

  Future<void> _showInterstitialAdIfNeeded() async {
    try {
      if (!_showInterstitialAds || _interstitialAdShownToday) return;

      await AdHelper.showInterstitialAd(
        onAdShowed: () {
          _recordInterstitialShown();
        },
        onAdDismissed: () {},
        onAdFailedToShow: () {},
        adContext: 'PrayerTimePage',
      );
    } catch (e) {
      print('Interstitial অ্যাড শো করতে ত্রুটি: $e');
    }
  }

  void _recordInterstitialShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      await prefs.setString('last_interstitial_date', today);

      setState(() {
        _interstitialAdShownToday = true;
      });
    } catch (e) {
      print('Interstitial অ্যাড রেকর্ড করতে ত্রুটি: $e');
    }
  }

  Future<void> _toggleInterstitialAds(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_interstitial_ads', value);

    setState(() {
      _showInterstitialAds = value;
    });

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

    final hasInternet = await _prayerTimeService.checkInternetConnection();
    setState(() {
      _isOnline = hasInternet;
    });

    if (_locationPermissionGranted && hasInternet) {
      fetchLocationAndPrayerTimes();
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

    // নোটিফিকেশন শিডিউল করা
    prayerTimes.forEach((prayer, time) async {
      bool soundEnabled = prefs.getBool("azan_sound_$prayer") ?? true;
      _schedulePrayerNotification(prayer, time, soundEnabled);
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
      final result = await _prayerTimeService.fetchPrayerTimes();

      if (result != null) {
        setState(() {
          cityName = result['cityName'];
          countryName = result['countryName'];
          prayerTimes = result['prayerTimes'];
        });

        findNextPrayer();
        _saveData();

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

  // ডেটা সেভ করা
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cityName", cityName ?? "");
    await prefs.setString("countryName", countryName ?? "");
    await prefs.setString("prayerTimes", jsonEncode(prayerTimes));
  }

  // পরবর্তী নামাজ খুঁজে বের করা
  void findNextPrayer() {
    final result = _prayerTimeService.findNextPrayer(prayerTimes);

    if (result != null) {
      setState(() {
        nextPrayer = result['nextPrayer'];
        countdown = result['countdown'];
      });

      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final updatedResult = _prayerTimeService.findNextPrayer(prayerTimes);
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

  // আজান সক্ষম/অক্ষম সেট করা
  Future<void> _setAzanEnabled(String prayerName, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("azan_sound_$prayerName", enabled);

    if (!enabled) {
      _mp3Timers[prayerName]?.cancel();
      _mp3Timers.remove(prayerName);
    } else {
      if (prayerTimes[prayerName] != null) {
        _scheduleMp3ForPrayer(prayerName, prayerTimes[prayerName]!);
      }
    }

    setState(() {});
  }

  // নামাজের জন্য MP3 শিডিউল করা
  Future<void> _scheduleMp3ForPrayer(String prayerName, String time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool soundEnabled = prefs.getBool("azan_sound_$prayerName") ?? true;
      if (!soundEnabled) return;

      final prayerDate = _prayerTimeService.parsePrayerTime(time);
      if (prayerDate == null) return;

      final mp3Time = prayerDate.subtract(const Duration(minutes: 5));
      final now = DateTime.now();

      if (mp3Time.isAfter(now)) {
        _mp3Timers[prayerName]?.cancel();

        _mp3Timers[prayerName] = Timer(mp3Time.difference(now), () async {
          await _audioPlayer.play(AssetSource('assets/sounds/azan.mp3'));

          Timer(const Duration(hours: 24), () {
            _scheduleMp3ForPrayer(prayerName, time);
          });
        });
      }
    } catch (e) {
      print("Error scheduling MP3: $e");
    }
  }

  // নামাজের নোটিফিকেশন শিডিউল করা
  Future<void> _schedulePrayerNotification(
    String prayerName,
    String time,
    bool soundEnabled,
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
            channelKey: 'azan_channel',
            title: 'নামাজের সময়',
            body: '$prayerName নামাজ শুরু হওয়ার ১০ মিনিট বাকি',
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            hour: notificationTime.hour,
            minute: notificationTime.minute,
            second: 0,
            repeats: true,
          ),
        );
      }

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
        Color prayerColor = _prayerTimeService.getPrayerColor(prayerName);
        IconData prayerIcon = _prayerTimeService.getPrayerIcon(prayerName);

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
              _prayerTimeService.formatTimeTo12Hour(time),
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

  // অফলাইন ইন্ডিকেটর
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

  // নামাজ ট্যাব বিল্ড করা
  Widget _buildPrayerTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Column(
      children: [
        _buildOfflineIndicator(),

        // হেডার সেকশন
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
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.green[900]!.withOpacity(0.3)
                      : Colors.grey[100]!,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
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
                        onPressed: fetchLocationAndPrayerTimes,
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
                    // পরবর্তী নামাজ কাউন্টডাউন
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
                              nextPrayer.isNotEmpty
                                  ? nextPrayer
                                  : "লোড হচ্ছে...",
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
                    const SizedBox(width: 8),
                    // সূর্যোদয়/সূর্যাস্ত
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
                                        ? _prayerTimeService.formatTimeTo12Hour(
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
                                        ? _prayerTimeService.formatTimeTo12Hour(
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
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
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
                  child: prayerTimes.isNotEmpty
                      ? ListView(
                          padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
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
                              const SizedBox(height: 10),
                              Text(
                                "নামাজের সময় লোড হচ্ছে...",
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
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

        // নিষিদ্ধ সময় এবং তথ্য সেকশন
        _buildProhibitedTimeSection(),
      ],
    );
  }

  // নিষিদ্ধ সময় সেকশন বিল্ড করা
  Widget _buildProhibitedTimeSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // নিষিদ্ধ সময় কার্ড
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "নিষিদ্ধ সময়",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showFloatingInfo(
                            context,
                            "সালাতের নিষিদ্ধ সময় সম্পর্কে",
                            _prohibitedTimeService.getProhibitedTimeInfo(),
                          );
                        },
                        child: Icon(
                          Icons.info_outline,
                          color: isDark ? Colors.blue[200] : Colors.blue[700],
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ভোর: ${_prohibitedTimeService.calculateSunriseProhibitedTime(prayerTimes)}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "দুপুর: ${_prohibitedTimeService.calculateDhuhrProhibitedTime(prayerTimes)}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "সন্ধ্যা: ${_prohibitedTimeService.calculateSunsetProhibitedTime(prayerTimes)}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // নফল সালাত এবং বিশেষ ফ্যাক্ট কার্ড
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _showFloatingInfo(
                      context,
                      "নফল সালাতের ওয়াক্ত",
                      _prohibitedTimeService.getNafalPrayerInfo(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.blue,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            "নফল সালাত",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showFloatingInfo(
                      context,
                      "সালাত সম্পর্কে বিশেষ ফ্যাক্ট",
                      _prohibitedTimeService.getSpecialFacts(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.orange,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            "বিশেষ ফ্যাক্ট",
                            style: TextStyle(
                              fontSize: 11,
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
            fontFeatures: [const FontFeature.tabularFigures()],
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

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
      // ✅ Adaptive Banner Ad - TasbeehPage-এর মতোই
      bottomNavigationBar: _isBannerAdReady && _bannerAd != null
          ? SafeArea(
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
            )
          : // ব্যানার অ্যাড না থাকলে শুধু সিস্টেম ন্যাভিগেশন বার এর জন্য স্পেস রাখুন
            SafeArea(child: Container(height: 0)),
    );
  }
}
