// lib/pages/ifter_time_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:intl/intl.dart';

class IfterTimePage extends StatefulWidget {
  const IfterTimePage({Key? key}) : super(key: key);

  @override
  State<IfterTimePage> createState() => _IfterTimePageState();
}

class _IfterTimePageState extends State<IfterTimePage> {
  // ---------- Prayer Times from SharedPreferences ----------
  String? cityName = "Loading...";
  String? countryName = "Loading...";
  Map<String, String> prayerTimes = {};
  Duration iftarCountdown = Duration.zero;
  Timer? iftarTimer;

  // ---------- Banner Ad ----------
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  // ---------- Hadith List ----------
  final List<String> _ramadanHadiths = [
    "রমজান মাসে যে ব্যক্তি একটি নফল আদায় করল, সে যেন অন্য মাসের একটি ফরজ আদায় করল। আর যে ব্যক্তি এই মাসে একটি ফরজ আদায় করল, সে যেন অন্য মাসের সত্তরটি ফরজ আদায় করল।",
    "রমজান মাস হলো ধৈর্য্যের মাস, আর ধৈর্য্যের প্রতিদান হলো জান্নাত।",
    "রমজান মাসে যদি লোকেরা জানত কী পরিমাণ কল্যাণ রয়েছে, তাহলে তারা আশা করত যে সমস্ত বছরই রমজান হোক।",
    "রোজাদারের জন্য দু'টি খুশি: এক. যখন সে ইফতার করে, দুই. যখন সে তার রবের সাথে meeting করবে।",
    "রমজান মাসের প্রথম দশক রহমত, মধ্যম দশক মাগফিরাত এবং শেষ দশক জাহান্নাম থেকে মুক্তির।",
    "যে ব্যক্তি ঈমানের সাথে এবং সওয়াবের আশায় রমজান মাসে রোজা রাখে, তার既往ের সমস্ত গুনাহ ক্ষমা করে দেওয়া হয়।",
  ];

  String _currentHadith = "";

  @override
  void initState() {
    super.initState();
    _loadAd();
    _loadSavedData();
    _selectRandomHadith();
  }

  @override
  void dispose() {
    iftarTimer?.cancel();
    _bannerAd.dispose();
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
  Widget _buildTimeUnit(String label, int value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.green[800] : Colors.green[500],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.green[800] : Colors.green[500],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "ইফতারের সময় বাকি",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // কাউন্টডাউন টাইমার
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimeUnit("ঘণ্টা", iftarCountdown.inHours),
                      _buildTimeUnit("মিনিট", iftarCountdown.inMinutes % 60),
                      _buildTimeUnit("সেকেন্ড", iftarCountdown.inSeconds % 60),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "ইফতারের সময়: ${_getIftarTime()}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
                  //color: isDarkMode ? Colors.blue[700] : Colors.blue[200],
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
                    "• সাহরির শেষ সময়: ফজরের আযানের ৩ মিনিট আগে\n"
                    "• ইফতারের সময়: মাগরিবের আযানের সাথে সাথে\n"
                    "• ডেটা: আপনার Prayer Time পেইজ থেকে নেওয়া হয়েছে",
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
