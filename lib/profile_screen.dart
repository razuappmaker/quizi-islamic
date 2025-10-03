// profile_screen.dart - উন্নত প্রোফাইল সিস্টেম (আপডেটেড)
import 'package:flutter/material.dart';
import '../utils/point_manager.dart';
import 'ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../screens/premium_screen.dart';
import '../screens/reward_screen.dart'; // RewardScreen import
import 'mcq_page.dart'; // MCQPage import

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
  String _userEmail = "ইসলামিক কুইজ ইউজার";
  String _userName = "ইসলামিক কুইজ ইউজার";
  String _userMobile = "";
  bool _isLoading = true;
  bool _isRequesting = false;
  bool _isEditingProfile = false;

  // Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdShown = false;

  // Editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

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
    _nameController.dispose();
    _mobileController.dispose();
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

  // 🔥 Load adaptive banner ad
  Future<void> _loadBannerAd() async {
    try {
      final canShowAd = await AdHelper.canShowBannerAd();
      if (!canShowAd) {
        print('Cannot show banner ad due to limits');
        return;
      }

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
        _userName = userData['userName'] ?? 'ইসলামিক কুইজ ইউজার';
        _userMobile = userData['userMobile'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print("ডাটা লোড করতে ত্রুটি: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToPremium() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
  }

  void _navigateToReward() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RewardScreen()),
    );
  }

  // 🔥 NEW: কুইজ নেভিগেশন ফাংশন
  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MCQPage(
          category: 'ইসলামী প্রাথমিক জ্ঞান',
          quizId: 'islamic_basic_knowledge',
        ),
      ),
    );
  }

  // 🔥 NEW: গিফট নেভিগেশন ফাংশন
  void _navigateToGift() {
    if (_pendingPoints >= 5000) {
      _requestRecharge();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ পর্যাপ্ত পয়েন্ট নেই! আরও ${5000 - _pendingPoints} পয়েন্ট প্রয়োজন।",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔥 প্রোফাইল এডিট ফাংশন
  Future<void> _editProfile() async {
    _nameController.text = _userName;
    _mobileController.text = _userMobile;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("প্রোফাইল এডিট করুন"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "আপনার নাম",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  labelText: "মোবাইল নম্বর",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  counterText: "",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("বাতিল"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                setState(() {
                  _userName = _nameController.text.trim();
                  _userMobile = _mobileController.text.trim();
                });
                _saveProfileData();
                Navigator.pop(context);
              }
            },
            child: const Text("সেভ করুন"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfileData() async {
    try {
      await PointManager.saveProfileData(_userName, _userMobile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ প্রোফাইল সেভ করা হয়েছে"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ প্রোফাইল সেভ করতে সমস্যা: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔥 রিচার্জ রিকোয়েস্ট ফাংশন
  Future<void> _requestRecharge() async {
    if (_pendingPoints < 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ পর্যাপ্ত পয়েন্ট নেই! আরও ${5000 - _pendingPoints} পয়েন্ট প্রয়োজন।",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? mobileNumber = await _showMobileNumberDialog();
    if (mobileNumber == null || mobileNumber.isEmpty) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      bool confirmed = await _showConfirmationDialog(mobileNumber);
      if (!confirmed) {
        setState(() {
          _isRequesting = false;
        });
        return;
      }

      await PointManager.deductPoints(5000);
      await PointManager.saveRechargeRequest(mobileNumber, _userEmail);
      await _loadUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "✅ আপনার গিফটের জন্য রিকোয়েস্টটি গ্রহণ করা হয়েছে! ২৪ ঘন্টার মধ্যে আপনার কাছে পাঠানো হবে ইনশাল্লাহ ।",
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
                "গিফট পাঠানোর জন্য আপনার মোবাইল নম্বরটি দিন:",
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
                "নম্বরটি সঠিকভাবে দিন, এই নম্বরেই রিওয়ার্ড পাঠানো হবে",
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
                  const Text("আপনি কি নিশ্চিত যে রিওয়ার্ড রিকোয়েস্ট করতে চান?"),
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
            Text("আমার রিওয়ার্ড হিস্ট্রি"),
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
                      Text("কোন রিওয়ার্ড রিকোয়েস্ট নেই"),
                      Text(
                        "৫০০০ পয়েন্ট জমা করে রিওয়ার্ড রিকোয়েস্ট করুন",
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

    final pointsUsed = request['pointsUsed'];
    final pointsText = pointsUsed != null ? pointsUsed.toString() : '0';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text("৫০০০ পয়েন্ট - ${request['mobileNumber'] ?? 'নাই'}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("স্ট্যাটাস: $statusText"),
            Text("তারিখ: ${_formatDate(request['requestedAt'])}"),
          ],
        ),
        trailing: Text(
          "$pointsText পয়েন্ট",
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

  // 🔥 NEW: Additional Features Section Widget
  Widget _buildAdditionalFeaturesSection(bool isSmallScreen) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            Text(
              "🚀 আরও পয়েন্ট নিতে",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 12),

            // ইসলামী কুইজ বাটন
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToQuiz,
                icon: const Icon(Icons.quiz, size: 20),
                label: Text(
                  "ইসলামী জ্ঞানের কুইজ খেলুন",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 14 : 16,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 8),

            // বাটন ডেস্ক্রিপশন
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.green[700],
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "নিজের ইসলামী জ্ঞান যাচাই করে নিন। সাথে রয়েছে রিয়েল গিফট!",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 13,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // গিফট বাটন
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToGift,
                icon: const Icon(Icons.card_giftcard, size: 20),
                label: Text(
                  "রিয়েল গিফট নিন",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple[700],
                  side: BorderSide(color: Colors.purple[400]!),
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 14 : 16,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),

            // গিফট ডেস্ক্রিপশন
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.purple[700], size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "৫০০০ পয়েন্ট জমা করে আকর্ষণীয় গিফট পান। এখনই শুরু করুন!",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 13,
                        color: Colors.purple[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text(
          "আমার প্রোফাইল",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
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
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _navigateToPremium,
              tooltip: "প্রিমিয়াম ফিচার",
              splashRadius: 20,
            ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.history, color: Colors.white, size: 20),
              onPressed: _showRechargeHistory,
              tooltip: "রিওয়ার্ড হিস্ট্রি",
              splashRadius: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
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
                  // Main content - Scrollable with compact design
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.0 : 16.0,
                        vertical: isSmallScreen ? 12.0 : 16.0,
                      ),
                      child: Column(
                        children: [
                          // SECTION 1: ইউজার প্রোফাইল কার্ড
                          _buildUserProfileSection(isTablet, isSmallScreen),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 2: পয়েন্ট ও স্ট্যাটাস
                          _buildPointsStatsSection(isTablet, isSmallScreen),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 3: ভিডিও রিওয়ার্ড সেকশন
                          _buildVideoRewardSection(isTablet, isSmallScreen),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // 🔥 SECTION 4: ADDITIONAL FEATURES SECTION
                          _buildAdditionalFeaturesSection(isSmallScreen),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 5: প্রিমিয়াম ও গিফট সেকশন
                          _buildPremiumGiftSection(isTablet, isSmallScreen),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 6: তথ্য বক্স
                          _buildInfoSection(isTablet, isSmallScreen),

                          // Bottom spacer for banner ad
                          SizedBox(
                            height: _isBannerAdLoaded
                                ? (isSmallScreen ? 12 : 16)
                                : (isSmallScreen ? 8 : 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔥 Adaptive Banner Ad at bottom
                  if (_isBannerAdLoaded && _bannerAd != null)
                    Container(
                      width: double.infinity,
                      height: _bannerAd!.size.height.toDouble(),
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                ],
              ),
      ),
    );
  }

  // SECTION 1: ইউজার প্রোফাইল সেকশন
  Widget _buildUserProfileSection(bool isTablet, bool isSmallScreen) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(
          isSmallScreen ? 16.0 : (isTablet ? 24.0 : 20.0),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 25 : (isTablet ? 40 : 30),
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.person,
                    size: isSmallScreen ? 25 : (isTablet ? 40 : 30),
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: GestureDetector(
                      onTap: _editProfile,
                      child: Icon(
                        Icons.edit,
                        size: isSmallScreen ? 12 : 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : (isTablet ? 20 : 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _userName,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : (isTablet ? 22 : 18),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _userEmail,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_userMobile.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _userMobile,
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : (isTablet ? 14 : 12),
                  color: Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECTION 2: পয়েন্ট ও স্ট্যাটাস সেকশন
  Widget _buildPointsStatsSection(bool isTablet, bool isSmallScreen) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(
          isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0),
        ),
        child: Column(
          children: [
            Text(
              "📊 আমার স্ট্যাটিস্টিক্স",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
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
    );
  }

  // SECTION 3: ভিডিও রিওয়ার্ড সেকশন
  Widget _buildVideoRewardSection(bool isTablet, bool isSmallScreen) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.video_library,
                  color: Colors.red,
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(width: 8),
                Text(
                  "🎬 ভিডিও দেখে পয়েন্ট অর্জন করুন",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "সংক্ষিপ্ত ভিডিও দেখে অতিরিক্ত পয়েন্ট অর্জন করুন",
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToReward,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  "ভিডিও দেখুন",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION 4: প্রিমিয়াম ও গিফট সেকশন
  Widget _buildPremiumGiftSection(bool isTablet, bool isSmallScreen) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            // 🔥 গিফট সেকশন - সম্পূর্ণ আলাদা
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.purple.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        color: Colors.purple,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "🎁 রিয়েল গিফট পান",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "৫০০০ পয়েন্ট জমা করে আকর্ষণীয় গিফট জিতুন",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.purple.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pendingPoints >= 5000
                          ? _requestRecharge
                          : null,
                      icon: const Icon(Icons.redeem),
                      label: Text(
                        _pendingPoints >= 5000
                            ? "গিফট নিন (প্রস্তুত)"
                            : "গিফট নিন (${5000 - _pendingPoints} পয়েন্ট বাকি)",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  if (_pendingPoints < 5000) ...[
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _pendingPoints / 5000,
                      backgroundColor: Colors.purple.shade200,
                      color: Colors.purple,
                      minHeight: 6,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${_pendingPoints}/5000 পয়েন্ট সংগ্রহ হয়েছে",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // 🔥 প্রিমিয়াম সেকশন - সম্পূর্ণ আলাদা
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.cyan.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "⭐ প্রিমিয়াম এক্সপেরিয়েন্স",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "এক্সক্লুসিভ ফিচার এবং এড-ফ্রি এক্সপেরিয়েন্স",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  // প্রিমিয়াম ফিচার লিস্ট
                  Column(
                    children: [
                      _buildPremiumFeature(
                        "এড-ফ্রি ব্যবহার",
                        Icons.block,
                        isSmallScreen,
                      ),
                      _buildPremiumFeature(
                        "এক্সক্লুসিভ কুইজ",
                        Icons.quiz,
                        isSmallScreen,
                      ),
                      _buildPremiumFeature(
                        "প্রায়োরিটি সাপোর্ট",
                        Icons.support_agent,
                        isSmallScreen,
                      ),
                      _buildPremiumFeature(
                        "ডাবল পয়েন্ট",
                        Icons.bolt,
                        isSmallScreen,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _navigateToPremium,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text(
                        "প্রিমিয়াম দেখুন",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade800,
                        side: BorderSide(color: Colors.blue.shade600),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 প্রিমিয়াম ফিচার আইটেম উইজেট
  Widget _buildPremiumFeature(
    String feature,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: isSmallScreen ? 16 : 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: isSmallScreen ? 16 : 18,
          ),
        ],
      ),
    );
  }

  // SECTION 6: তথ্য বক্স
  Widget _buildInfoSection(bool isTablet, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : (isTablet ? 16 : 12)),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue, size: isSmallScreen ? 18 : 24),
          SizedBox(width: isSmallScreen ? 8 : (isTablet ? 12 : 8)),
          Expanded(
            child: Text(
              "গিফট এর জন্য রিকোয়েস্ট করলে ৫০০০ পয়েন্ট কাটা হবে। ২৪ ঘন্টার মধ্যে আপনার গিফট পাঠিয়ে দেয়া হবে ইনশাআল্লাহ ।",
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : (isTablet ? 14 : 12),
                color: Colors.blue,
              ),
            ),
          ),
        ],
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
