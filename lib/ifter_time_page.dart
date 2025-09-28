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

  // ---------- New variables for time adjustment ----------
  int iftarTimeAdjustment = 0; // মিনিটে অ্যাডজাস্টমেন্ট
  bool _showAdjustmentDialog = false;

  // Animation controller for countdown pulse effect
  late AnimationController _animationController;
  late Animation<double> _animation;

  // ---------- Ads ----------
  BannerAd? _bannerAd; // ✅ Nullable করুন adaptive banner-এর জন্য
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
    "রমজান হলো ধৈর্যের মাস, আর ধৈর্যের প্রতিদান হলো জান্নাত। সুনান ইবনে খুযাইমাহ, হাদিস: ১৮৮৭",
    "তোমাদের মধ্যে যে ব্যক্তি এ মাস (রমজান) পাবে, সে যেন এ মাসে রোযা রাখে।সূরা আল-বাকারাহ ২:১৮৫",
    "যে ব্যক্তি ঈমান ও সওয়াবের আশায় রমজানের রোযা রাখবে, তার পূর্বেকার গুনাহ মাফ করে দেওয়া হবে। সহিহ বুখারি, হাদিস: ৩৮; সহিহ মুসলিম, হাদিস: ৭৬০",
  ];

  String _currentHadith = "";

  @override
  void initState() {
    super.initState();
    _loadAd(); // ✅ Adaptive banner load
    _loadSavedData();
    _selectRandomHadith();
    _initializeAds(); // অ্যাড সিস্টেম ইনিশিয়ালাইজ করুন
    _loadAdjustmentSettings(); // 🔹 নতুন মেথড কল করুন

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
    _bannerAd?.dispose(); // ✅ Null safety সহ dispose
    _animationController.dispose();
    super.dispose();
  }

  // 🔹 নতুন মেথড: অ্যাডজাস্টমেন্ট সেটিংস লোড করুন
  Future<void> _loadAdjustmentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      iftarTimeAdjustment = prefs.getInt('ifter_time_adjustment') ?? 0;
    });
    print(
      '🕒 ইফতার সময় অ্যাডজাস্টমেন্ট লোড করা হয়েছে: $iftarTimeAdjustment মিনিট',
    );
  }

  // 🔹 নতুন মেথড: অ্যাডজাস্টমেন্ট সেভ করুন
  Future<void> _saveAdjustmentSettings(int adjustment) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ifter_time_adjustment', adjustment);
    setState(() {
      iftarTimeAdjustment = adjustment;
    });

    // ইফতার কাউন্টডাউন রিক্যালকুলেট করুন
    if (prayerTimes.isNotEmpty) {
      _calculateIftarCountdown();
    }

    print('💾 ইফতার সময় অ্যাডজাস্টমেন্ট সেভ করা হয়েছে: $adjustment মিনিট');
  }

  // 🔹 নতুন মেথড: অ্যাডজাস্টমেন্ট ডায়ালগ শো করুন
  void _showTimeAdjustmentDialog() {
    setState(() {
      _showAdjustmentDialog = true;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    "ইফতারের সময় সামঞ্জস্য করুন (+/- মিনিট)",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),

                  // Adjustment display
                  Container(
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
                  ),
                  SizedBox(height: 20),

                  // Adjustment buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decrease button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            iftarTimeAdjustment -= 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.remove, color: Colors.white),
                      ),

                      // Reset button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            iftarTimeAdjustment = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.refresh, color: Colors.white),
                      ),

                      // Increase button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            iftarTimeAdjustment += 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Quick adjustment buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            iftarTimeAdjustment -= 5;
                          });
                        },
                        child: Text(
                          "-৫ মিনিট",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            iftarTimeAdjustment += 5;
                          });
                        },
                        child: Text(
                          "+৫ মিনিট",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
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

                    // স্ন্যাকবারে মেসেজ দেখান
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text("সংরক্ষণ করুন"),
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      setState(() {
        _showAdjustmentDialog = false;
      });
    });
  }

  // 🔹 নতুন মেথড: ইফতার সময় অ্যাডজাস্ট করুন
  String _adjustIftarTime(String time, int adjustmentMinutes) {
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

      final adjustedTime =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

      return adjustedTime;
    } catch (e) {
      print('❌ ইফতার সময় অ্যাডজাস্ট করতে ত্রুটি: $e');
      return time;
    }
  }

  // 🔹 নতুন মেথড: অ্যাডজাস্টমেন্ট ইন্ডিকেটর
  Widget _buildAdjustmentIndicator(bool isDarkMode) {
    if (iftarTimeAdjustment == 0) return SizedBox();

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: iftarTimeAdjustment > 0
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: iftarTimeAdjustment > 0 ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iftarTimeAdjustment > 0 ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14,
            color: iftarTimeAdjustment > 0 ? Colors.green : Colors.red,
          ),
          SizedBox(width: 4),
          Text(
            "${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment মিনিট",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: iftarTimeAdjustment > 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Adaptive Banner Ad লোড করা - অন্যান্য পেইজের মতোই
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

      // 🔹 Priority 1: Adjusted prayer times (যদি থাকে)
      String? savedAdjustedTimes = prefs.getString("adjusted_prayer_times");
      if (savedAdjustedTimes != null) {
        try {
          prayerTimes = Map<String, String>.from(
            jsonDecode(savedAdjustedTimes),
          );
          print('✅ ইফতার পেজ - অ্যাডজাস্টেড নামাজের সময় ব্যবহার করা হচ্ছে');

          // 🔹 ডিবাগিং: মাগরিব সময় প্রিন্ট করুন
          if (prayerTimes.containsKey("মাগরিব")) {
            print('🕒 অ্যাডজাস্টেড মাগরিব সময়: ${prayerTimes["মাগরিব"]}');
          }
        } catch (e) {
          print('❌ অ্যাডজাস্টেড টাইমস পার্স করতে ত্রুটি: $e');
        }
      }

      // 🔹 Priority 2: Original prayer times (যদি Adjusted না থাকে)
      if (prayerTimes.isEmpty) {
        String? savedOriginalTimes = prefs.getString("prayerTimes");
        if (savedOriginalTimes != null) {
          try {
            prayerTimes = Map<String, String>.from(
              jsonDecode(savedOriginalTimes),
            );
            print('ℹ️ ইফতার পেজ - অরিজিনাল নামাজের সময় ব্যবহার করা হচ্ছে');

            if (prayerTimes.containsKey("মাগরিব")) {
              print('🕒 অরিজিনাল মাগরিব সময়: ${prayerTimes["মাগরিব"]}');
            }
          } catch (e) {
            print('❌ অরিজিনাল টাইমস পার্স করতে ত্রুটি: $e');
          }
        }
      }

      // 🔹 অ্যাডজাস্টমেন্টস লোড করুন (ইনফোর জন্য)
      String? savedAdjustments = prefs.getString('prayer_time_adjustments');
      if (savedAdjustments != null) {
        try {
          Map<String, dynamic> adjustments = Map<String, dynamic>.from(
            jsonDecode(savedAdjustments),
          );
          print('📝 ইফতার পেজ - লোড করা অ্যাডজাস্টমেন্টস: $adjustments');

          // 🔹 মাগরিব অ্যাডজাস্টমেন্ট চেক করুন
          if (adjustments.containsKey("মাগরিব")) {
            print(
              '🎯 মাগরিব অ্যাডজাস্টমেন্ট: ${adjustments["মাগরিব"]} minutes',
            );
          }
        } catch (e) {
          print('❌ অ্যাডজাস্টমেন্টস পার্স করতে ত্রুটি: $e');
        }
      }

      if (prayerTimes.isNotEmpty) {
        _calculateIftarCountdown();
      } else {
        print('⚠️ ইফতার পেজ - কোন নামাজের সময় পাওয়া যায়নি');
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

  // 🔹 আপডেট করা মেথড: ইফতারের সময় ক্যালকুলেশন (অ্যাডজাস্টমেন্ট সহ)
  void _calculateIftarCountdown() {
    if (prayerTimes.containsKey("মাগরিব")) {
      String maghribTime = prayerTimes["মাগরিব"]!;

      // 🔹 অ্যাডজাস্টমেন্ট প্রয়োগ করুন
      if (iftarTimeAdjustment != 0) {
        maghribTime = _adjustIftarTime(maghribTime, iftarTimeAdjustment);
        print(
          '🕒 অ্যাডজাস্টেড ইফতার সময়: $maghribTime ($iftarTimeAdjustment মিনিট)',
        );
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

  // 🔹 আপডেট করা মেথড: ইফতারের সময় ফরম্যাট করা (অ্যাডজাস্টমেন্ট সহ)
  String _getIftarTime() {
    if (prayerTimes.containsKey("মাগরিব")) {
      String maghribTime = prayerTimes["মাগরিব"]!;

      // 🔹 অ্যাডজাস্টমেন্ট প্রয়োগ করুন
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

  // প্রোগ্রেস ক্যালকুলেশন
  double _calculateProgress(Duration remainingTime) {
    // Assuming iftar is at sunset (adjust according to your logic)
    // This calculates progress based on remaining time (0 = time's up, 1 = full time remaining)
    const totalDaylightHours = 12; // Adjust based on your calculation
    final totalSeconds = totalDaylightHours * 3600;
    final remainingSeconds = remainingTime.inSeconds;

    return remainingSeconds / totalSeconds;
  }

  // কাউন্টডাউন কালার নির্ধারণ
  Color _getCountdownColor(Duration remainingTime) {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    if (hours > 1) {
      return Colors.greenAccent; // Plenty of time - green
    } else if (hours == 1) {
      return Colors.orangeAccent; // Getting close - orange
    } else if (minutes > 30) {
      return Colors.orange; // Less than an hour - dark orange
    } else if (minutes > 10) {
      return Colors.deepOrange; // Less than 30 minutes - red-orange
    } else {
      return Colors.redAccent; // Very close - red
    }
  }

  // প্রোগ্রেস টেক্সট
  String _getProgressText(Duration remainingTime) {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    if (hours > 1) {
      return "ইফতারের সময় আসছে";
    } else if (hours == 1) {
      return "প্রস্তুত হোন";
    } else if (minutes > 30) {
      return "অল্প সময় বাকি";
    } else if (minutes > 10) {
      return "শীঘ্রই ইফতার";
    } else {
      return "ইফতারের সময় কাছাকাছি";
    }
  }

  // সময় ইউনিট বিল্ড করার হেল্পার মেথড - আপডেট করা
  Widget _buildTimeUnit(String label, int value, bool isDarkMode, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5), width: 1),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  // কোলন সেপারেটর - আপডেট করা
  Widget _buildColon(Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        ":",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
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
        // 🔹 সেটিং আইকন যোগ করুন
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: _showTimeAdjustmentDialog,
            tooltip: "ইফতার সময় সামঞ্জস্য করুন",
          ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$cityName, $countryName",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        // 🔹 অ্যাডজাস্টমেন্ট ইন্ডিকেটর যোগ করুন
                        _buildAdjustmentIndicator(isDarkMode),
                      ],
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

            // ইফতার কাউন্টডাউন সেকশন - আপডেট করা
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
                  // Header with icon and adjustment info
                  Column(
                    children: [
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
                      // 🔹 অ্যাডজাস্টমেন্ট তথ্য
                      if (iftarTimeAdjustment != 0) ...[
                        SizedBox(height: 8),
                        Text(
                          "(${iftarTimeAdjustment >= 0 ? '+' : ''}$iftarTimeAdjustment মিনিট অ্যাডজাস্টেড)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Countdown timer with circular progress border
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular progress background
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),

                      // Animated circular progress border
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: TweenAnimationBuilder(
                          duration: const Duration(seconds: 1),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, double value, child) {
                            return CircularProgressIndicator(
                              value: _calculateProgress(iftarCountdown),
                              strokeWidth: 6,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCountdownColor(iftarCountdown),
                              ),
                            );
                          },
                        ),
                      ),

                      // Countdown content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main countdown numbers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTimeUnit(
                                "ঘণ্টা",
                                iftarCountdown.inHours,
                                isDarkMode,
                                _getCountdownColor(iftarCountdown),
                              ),
                              const SizedBox(width: 8),
                              _buildColon(_getCountdownColor(iftarCountdown)),
                              const SizedBox(width: 8),
                              _buildTimeUnit(
                                "মিনিট",
                                iftarCountdown.inMinutes % 60,
                                isDarkMode,
                                _getCountdownColor(iftarCountdown),
                              ),
                              const SizedBox(width: 8),
                              _buildColon(_getCountdownColor(iftarCountdown)),
                              const SizedBox(width: 8),
                              _buildTimeUnit(
                                "সেকেন্ড",
                                iftarCountdown.inSeconds % 60,
                                isDarkMode,
                                _getCountdownColor(iftarCountdown),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Progress text
                          Text(
                            _getProgressText(iftarCountdown),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Iftar time with improved styling
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
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

      // ✅ Adaptive Banner Ad - অন্যান্য পেইজের মতোই
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
