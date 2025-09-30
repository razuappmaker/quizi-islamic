// profile_screen.dart - রিচার্জ সিস্টেম সহ
import 'package:flutter/material.dart';
import '../utils/point_manager.dart';
import 'ad_helper.dart'; // AdHelper import
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _pendingPoints = 0;
  int _totalPoints = 0;
  int _totalQuizzes = 0;
  int _totalCorrectAnswers = 0;
  String _userEmail = "";
  bool _isLoading = true;
  bool _isRequesting = false;

  // Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdShown = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeAds();
    _scheduleInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    AdHelper.disposeInterstitialAd();
    super.dispose();
  }

  // 🔥 Ads initialization
  Future<void> _initializeAds() async {
    try {
      await AdHelper.initialize();
      _loadBannerAd();
    } catch (e) {
      print("Ad initialization error: $e");
    }
  }

  // 🔥 Load adaptive banner ad - COMPATIBLE WITH YOUR AD_HELPER
  Future<void> _loadBannerAd() async {
    try {
      final canShowAd = await AdHelper.canShowBannerAd();
      if (!canShowAd) {
        print('Cannot show banner ad due to limits');
        return;
      }

      // Use the existing method from your AdHelper
      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Banner ad loaded successfully');
            setState(() {
              _isBannerAdLoaded = true;
            });
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Banner ad failed to load: $error');
            ad.dispose();
            setState(() {
              _isBannerAdLoaded = false;
              _bannerAd = null;
            });
          },
          onAdOpened: (Ad ad) => print('Banner ad opened'),
          onAdClosed: (Ad ad) => print('Banner ad closed'),
        ),
      );

      // Load the ad after creation
      _bannerAd?.load();
    } catch (e) {
      print('Error loading banner ad: $e');
      setState(() {
        _isBannerAdLoaded = false;
        _bannerAd = null;
      });
    }
  }

  // 🔥 Schedule interstitial ad after 5 seconds
  void _scheduleInterstitialAd() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isInterstitialAdShown && mounted) {
        _showInterstitialAd();
      }
    });
  }

  // 🔥 Show interstitial ad
  Future<void> _showInterstitialAd() async {
    try {
      await AdHelper.showInterstitialAd(
        onAdShowed: () {
          setState(() {
            _isInterstitialAdShown = true;
          });
          print('Interstitial ad showed on profile screen');
        },
        onAdDismissed: () {
          print('Interstitial ad dismissed from profile screen');
        },
        onAdFailedToShow: () {
          print('Interstitial ad failed to show on profile screen');
        },
        adContext: 'profile_screen',
      );
    } catch (e) {
      print('Error showing interstitial ad: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await PointManager.getUserData();

      setState(() {
        _pendingPoints = userData['pendingPoints'] ?? 0;
        _totalPoints = userData['totalPoints'] ?? 0;
        _totalQuizzes = userData['totalQuizzes'] ?? 0;
        _totalCorrectAnswers = userData['totalCorrectAnswers'] ?? 0;
        _userEmail = userData['userEmail'] ?? 'ইসলামিক কুইজ ইউজার';
        _isLoading = false;
      });
    } catch (e) {
      print("ডাটা লোড করতে ত্রুটি: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔥 রিচার্জ রিকোয়েস্ট ফাংশন
  Future<void> _requestRecharge() async {
    if (_pendingPoints < 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ পর্যাপ্ত পয়েন্ট নেই! আরও ${200 - _pendingPoints} পয়েন্ট প্রয়োজন।",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // মোবাইল নম্বর ইনপুট ডায়ালগ
    String? mobileNumber = await _showMobileNumberDialog();
    if (mobileNumber == null || mobileNumber.isEmpty) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      // কনফার্মেশন ডায়ালগ
      bool confirmed = await _showConfirmationDialog(mobileNumber);
      if (!confirmed) {
        setState(() {
          _isRequesting = false;
        });
        return;
      }

      // পয়েন্ট কাটুন
      await PointManager.deductPoints(200);

      // রিচার্জ রিকোয়েস্ট সেভ করুন
      await PointManager.saveRechargeRequest(mobileNumber, _userEmail);

      // UI আপডেট করুন
      await _loadUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "✅ আপনার রিচার্জ রিকোয়েস্টটি গ্রহণ করা হয়েছে! ২৪ ঘন্টার মধ্যে রিচার্জ করে দেয়া হবে।",
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ রিকোয়েস্ট করতে সমস্যা: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isRequesting = false;
      });
    }
  }

  // 🔥 মোবাইল নম্বর ডায়ালগ
  Future<String?> _showMobileNumberDialog() async {
    TextEditingController mobileController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "মোবাইল নম্বর দিন",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "রিচার্জ পাঠানোর জন্য আপনার মোবাইল নম্বরটি দিন:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: "01XXXXXXXXX",
                  labelText: "মোবাইল নম্বর",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  counterText: "",
                ),
                onChanged: (value) {
                  // শুধুমাত্র নাম্বার allow করবে
                  if (value.length > 11) {
                    mobileController.text = value.substring(0, 11);
                    mobileController.selection = TextSelection.fromPosition(
                      TextPosition(offset: mobileController.text.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              const Text(
                "নম্বরটি সঠিকভাবে দিন, এই নম্বরেই রিচার্জ পাঠানো হবে",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("বাতিল"),
            ),
            ElevatedButton(
              onPressed: () {
                String mobile = mobileController.text.trim();
                if (mobile.length == 11 && mobile.startsWith("01")) {
                  Navigator.pop(context, mobile);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "❌ দয়া করে সঠিক মোবাইল নম্বর দিন (11 ডিজিট)",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
              ),
              child: const Text("পরবর্তী"),
            ),
          ],
        );
      },
    );
  }

  // 🔥 কনফার্মেশন ডায়ালগ
  Future<bool> _showConfirmationDialog(String mobileNumber) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("নিশ্চিত করুন"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("আপনি কি নিশ্চিত যে রিচার্জ রিকোয়েস্ট করতে চান?"),
                  const SizedBox(height: 10),
                  Text(
                    "মোবাইল নম্বর: $mobileNumber",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "পয়েন্ট ব্যয়: ৫০০০ পয়েন্ট",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "⚠️ একবার রিকোয়েস্ট করলে এটি বাতিল করা যাবে না",
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("বাতিল"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                  child: const Text("নিশ্চিত করুন"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // 🔥 রিচার্জ হিস্ট্রি দেখানোর ফাংশন
  Future<void> _showRechargeHistory() async {
    final history = await PointManager.getRechargeHistory();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.history),
            SizedBox(width: 8),
            Text("আমার রিচার্জ হিস্ট্রি"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("কোন রিচার্জ রিকোয়েস্ট নেই"),
                      Text(
                        "৫০০০ পয়েন্ট জমা করে রিচার্জ রিকোয়েস্ট করুন",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    var request = history[index];
                    return _buildRechargeHistoryItem(request);
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("বন্ধ করুন"),
          ),
        ],
      ),
    );
  }

  // 🔥 রিচার্জ হিস্ট্রি আইটেম
  // 🔥 রিচার্জ হিস্ট্রি আইটেম - FIXED VERSION
  Widget _buildRechargeHistoryItem(Map<String, dynamic> request) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending;
    String statusText = "বিচারাধীন";

    if (request['status'] == 'completed') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = "সম্পন্ন";
    } else if (request['status'] == 'rejected') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = "বাতিল";
    }

    // 🔥 FIX: Convert points to String properly
    final pointsUsed = request['pointsUsed'];
    final pointsText = pointsUsed != null
        ? pointsUsed is int
              ? '$pointsUsed' // Convert int to String
              : pointsUsed
                    .toString() // Convert any other type to String
        : '0';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text("২০০ পয়েন্ট - ${request['mobileNumber'] ?? 'নাই'}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("স্ট্যাটাস: $statusText"),
            Text("তারিখ: ${_formatDate(request['requestedAt'])}"),
          ],
        ),
        trailing: Text(
          "$pointsText পয়েন্ট", // 🔥 FIXED: Use converted string
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "তারিখ নেই";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text("আমার প্রোফাইল"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showRechargeHistory,
            tooltip: "রিচার্জ হিস্ট্রি",
          ),
        ],
      ),
      body: SafeArea(
        bottom: true, // Enable bottom safe area
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("প্রোফাইল লোড হচ্ছে..."),
                  ],
                ),
              )
            : Column(
                children: [
                  // Main content - Scrollable with compact design for small screens
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.0 : 16.0,
                        vertical: isSmallScreen ? 12.0 : 16.0,
                      ),
                      child: Column(
                        children: [
                          // ইউজার ইনফো কার্ড - Compact for small screens
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 16.0 : (isTablet ? 24.0 : 20.0),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: isSmallScreen
                                        ? 35
                                        : (isTablet ? 50 : 40),
                                    backgroundColor: Colors.green,
                                    child: Icon(
                                      Icons.person,
                                      size: isSmallScreen
                                          ? 35
                                          : (isTablet ? 50 : 40),
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: isSmallScreen
                                        ? 12
                                        : (isTablet ? 20 : 16),
                                  ),
                                  Text(
                                    _userEmail,
                                    style: TextStyle(
                                      fontSize: isSmallScreen
                                          ? 16
                                          : (isTablet ? 22 : 18),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "ইসলামিক কুইজ ইউজার",
                                    style: TextStyle(
                                      fontSize: isSmallScreen
                                          ? 12
                                          : (isTablet ? 16 : 14),
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: isSmallScreen ? 16 : (isTablet ? 24 : 20),
                          ),

                          // পয়েন্ট ও স্ট্যাটাস কার্ড - Compact for small screens
                          Card(
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0),
                              ),
                              child: Column(
                                children: [
                                  _buildStatItem(
                                    "জমাকৃত পয়েন্ট",
                                    _pendingPoints.toString(),
                                    Icons.monetization_on,
                                    Colors.green,
                                    isTablet: isTablet,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                  const Divider(height: 1),
                                  _buildStatItem(
                                    "মোট অর্জিত পয়েন্ট",
                                    _totalPoints.toString(),
                                    Icons.attach_money,
                                    Colors.blue,
                                    isTablet: isTablet,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                  const Divider(height: 1),
                                  _buildStatItem(
                                    "মোট কুইজ দেওয়া",
                                    _totalQuizzes.toString(),
                                    Icons.quiz,
                                    Colors.orange,
                                    isTablet: isTablet,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                  const Divider(height: 1),
                                  _buildStatItem(
                                    "মোট সঠিক উত্তর",
                                    _totalCorrectAnswers.toString(),
                                    Icons.check_circle,
                                    Colors.purple,
                                    isTablet: isTablet,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: isSmallScreen ? 16 : (isTablet ? 24 : 20),
                          ),

                          // 🔥 রিচার্জ সেকশন - Compact for small screens
                          Card(
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "💰 মোবাইল রিচার্জ",
                                    style: TextStyle(
                                      fontSize: isSmallScreen
                                          ? 16
                                          : (isTablet ? 20 : 18),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    value: _pendingPoints / 200,
                                    backgroundColor: Colors.grey[300],
                                    color: _pendingPoints >= 200
                                        ? Colors.green
                                        : Colors.orange,
                                    minHeight: isSmallScreen
                                        ? 8
                                        : (isTablet ? 12 : 10),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "$_pendingPoints/200 পয়েন্ট",
                                    style: TextStyle(
                                      fontSize: isSmallScreen
                                          ? 12
                                          : (isTablet ? 16 : 14),
                                      fontWeight: FontWeight.bold,
                                      color: _pendingPoints >= 200
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _pendingPoints >= 200
                                        ? "✅ রিচার্জের জন্য প্রস্তুত!"
                                        : "⚠️ আরও ${200 - _pendingPoints} পয়েন্ট প্রয়োজন",
                                    style: TextStyle(
                                      fontSize: isSmallScreen
                                          ? 10
                                          : (isTablet ? 14 : 12),
                                      color: _pendingPoints >= 200
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: isSmallScreen
                                        ? 12
                                        : (isTablet ? 20 : 16),
                                  ),

                                  if (_pendingPoints >= 200)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _isRequesting
                                            ? null
                                            : _requestRecharge,
                                        icon: const Icon(Icons.mobile_friendly),
                                        label: _isRequesting
                                            ? SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Text(
                                                "৫০ টাকা রিচার্জ নিন",
                                                style: TextStyle(
                                                  fontSize: isSmallScreen
                                                      ? 14
                                                      : (isTablet ? 18 : 16),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[800],
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: isSmallScreen
                                                ? 12
                                                : (isTablet ? 18 : 15),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: EdgeInsets.all(
                                        isSmallScreen
                                            ? 10
                                            : (isTablet ? 16 : 12),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.orange[200]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info,
                                            color: Colors.orange[800],
                                            size: isSmallScreen ? 18 : 24,
                                          ),
                                          SizedBox(
                                            width: isSmallScreen
                                                ? 8
                                                : (isTablet ? 12 : 8),
                                          ),
                                          Expanded(
                                            child: Text(
                                              "রিচার্জ পেতে কমপক্ষে ৫০০০ পয়েন্ট জমা করতে হবে। আরও ${200 - _pendingPoints} পয়েন্ট প্রয়োজন।",
                                              style: TextStyle(
                                                fontSize: isSmallScreen
                                                    ? 10
                                                    : (isTablet ? 14 : 12),
                                                color: Colors.orange[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: isSmallScreen ? 16 : (isTablet ? 24 : 20),
                          ),

                          // তথ্য বক্স - Compact for small screens
                          Container(
                            padding: EdgeInsets.all(
                              isSmallScreen ? 10 : (isTablet ? 16 : 12),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.blue,
                                  size: isSmallScreen ? 18 : 24,
                                ),
                                SizedBox(
                                  width: isSmallScreen
                                      ? 8
                                      : (isTablet ? 12 : 8),
                                ),
                                Expanded(
                                  child: Text(
                                    "রিচার্জ রিকোয়েস্ট করলে ৫০০০ পয়েন্ট কাটা হবে। ২৪ ঘন্টার মধ্যে আপনার মোবাইলে ৫০ টাকা রিচার্জ করে দেয়া হবে।",
                                    style: TextStyle(
                                      fontSize: isSmallScreen
                                          ? 10
                                          : (isTablet ? 14 : 12),
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom spacer for banner ad - Adjusted for safe area
                          SizedBox(
                            height: _isBannerAdLoaded
                                ? (isSmallScreen ? 12 : 16)
                                : (isSmallScreen ? 8 : 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔥 Adaptive Banner Ad at bottom with safe area padding
                  if (_isBannerAdLoaded && _bannerAd != null)
                    Container(
                      width: double.infinity,
                      height: _bannerAd!.size.height.toDouble(),
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(
                          context,
                        ).padding.bottom, // Add safe area bottom padding
                      ),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color, {
    required bool isTablet,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 6.0 : (isTablet ? 12.0 : 8.0),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: isSmallScreen ? 20 : (isTablet ? 28 : 24),
          ),
          SizedBox(width: isSmallScreen ? 8 : (isTablet ? 16 : 12)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : (isTablet ? 20 : 18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
