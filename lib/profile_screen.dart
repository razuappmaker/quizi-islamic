// profile_screen.dart - উন্নত প্রোফাইল সিস্টেম (আপডেটেড)
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../utils/point_manager.dart';
import 'ad_helper.dart';
import '../screens/premium_screen.dart';
import '../screens/reward_screen.dart';
import 'mcq_page.dart';
import '../providers/language_provider.dart'; // ✅ Language Provider import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ==================== ভাষা টেক্সট ডিক্লেয়ারেশন ====================
  static const Map<String, Map<String, String>> _texts = {
    'pageTitle': {'en': 'Profile', 'bn': 'প্রোফাইল'},
    'loadingProfile': {
      'en': 'Loading profile...',
      'bn': 'প্রোফাইল লোড হচ্ছে...',
    },
    'premiumFeatures': {'en': 'Premium Features', 'bn': 'প্রিমিয়াম ফিচার'},
    'rewardHistory': {'en': 'Reward History', 'bn': 'রিওয়ার্ড হিস্ট্রি'},
    'editProfile': {'en': 'Edit Profile', 'bn': 'প্রোফাইল এডিট করুন'},
    'yourName': {'en': 'Your Name', 'bn': 'আপনার নাম'},
    'mobileNumber': {'en': 'Mobile Number', 'bn': 'মোবাইল নম্বর'},
    'cancel': {'en': 'Cancel', 'bn': 'বাতিল'},
    'save': {'en': 'Save', 'bn': 'সেভ করুন'},
    'profileSaved': {'en': '✅ Profile saved', 'bn': '✅ প্রোফাইল সেভ করা হয়েছে'},
    'profileSaveError': {
      'en': '❌ Problem saving profile:',
      'bn': '❌ প্রোফাইল সেভ করতে সমস্যা:',
    },
    'enterMobile': {'en': 'Enter Mobile Number', 'bn': 'মোবাইল নম্বর দিন'},
    'mobileHint': {'en': '01XXXXXXXXX', 'bn': '01XXXXXXXXX'},
    'mobileLabel': {'en': 'Mobile Number', 'bn': 'মোবাইল নম্বর'},
    'mobileInstruction': {
      'en': 'Enter your mobile number for gift delivery:',
      'bn': 'গিফট পাঠানোর জন্য আপনার মোবাইল নম্বরটি দিন:',
    },
    'mobileValidation': {
      'en': 'Please enter valid mobile number (11 digits)',
      'bn': 'দয়া করে সঠিক মোবাইল নম্বর দিন (11 ডিজিট)',
    },
    'next': {'en': 'Next', 'bn': 'পরবর্তী'},
    'confirmation': {'en': 'Confirmation', 'bn': 'নিশ্চিত করুন'},
    'confirmRequest': {
      'en': 'Are you sure you want to request reward?',
      'bn': 'আপনি কি নিশ্চিত যে রিওয়ার্ড রিকোয়েস্ট করতে চান?',
    },
    'pointsDeducted': {
      'en': 'Points deducted: 5000 points',
      'bn': 'পয়েন্ট ব্যয়: ৫০০০ পয়েন্ট',
    },
    'warning': {
      'en': '⚠️ Once requested, it cannot be cancelled',
      'bn': '⚠️ একবার রিকোয়েস্ট করলে এটি বাতিল করা যাবে না',
    },
    'confirm': {'en': 'Confirm', 'bn': 'নিশ্চিত করুন'},
    'close': {'en': 'Close', 'bn': 'বন্ধ করুন'},
    'myRewardHistory': {
      'en': 'My Reward History',
      'bn': 'আমার রিওয়ার্ড হিস্ট্রি',
    },
    'noRewardRequests': {
      'en': 'No reward requests',
      'bn': 'কোন রিওয়ার্ড রিকোয়েস্ট নেই',
    },
    'rewardInstruction': {
      'en': 'Collect 5000 points to request reward',
      'bn': '৫০০০ পয়েন্ট জমা করে রিওয়ার্ড রিকোয়েস্ট করুন',
    },
    'pending': {'en': 'Pending', 'bn': 'বিচারাধীন'},
    'completed': {'en': 'Completed', 'bn': 'সম্পন্ন'},
    'rejected': {'en': 'Rejected', 'bn': 'বাতিল'},
    'status': {'en': 'Status:', 'bn': 'স্ট্যাটাস:'},
    'date': {'en': 'Date:', 'bn': 'তারিখ:'},
    'noDate': {'en': 'No date', 'bn': 'তারিখ নেই'},
    'earnPointsFromCategories': {
      'en': 'Choose a favorite category',
      'bn': 'ক্যাটাগরি বেছে নিন',
    },
    'playQuiz': {'en': 'Play Quiz', 'bn': 'কুইজ খেলুন'},
    'increaseIslamicKnowledge': {
      'en': 'Increase your Points',
      'bn': 'পয়েন্ট বৃদ্ধি করুন',
    },
    'myStatistics': {'en': '📊 My Statistics', 'bn': '📊 আমার স্ট্যাটিস্টিক্স'},
    'pendingPoints': {'en': 'Pending Points', 'bn': 'জমাকৃত পয়েন্ট'},
    'totalPointsEarned': {
      'en': 'Total Points Earned',
      'bn': 'মোট অর্জিত পয়েন্ট',
    },
    'totalQuizzesTaken': {'en': 'Total Quizzes Taken', 'bn': 'মোট কুইজ দেওয়া'},
    'totalCorrectAnswers': {
      'en': 'Total Correct Answers',
      'bn': 'মোট সঠিক উত্তর',
    },
    'getRealGifts': {'en': '🎁 Apply for Gifts', 'bn': '🎁 গিফট এর জন্য আবেদন'},
    'giftDescription': {
      'en': 'Collect 5000 points to win attractive gifts',
      'bn': '৫০০০ পয়েন্ট জমা করে আকর্ষণীয় গিফট জিতুন',
    },
    'getGift': {'en': 'Get Gift', 'bn': 'গিফট নিন'},
    'getGiftReady': {'en': 'Get Gift (Ready)', 'bn': 'গিফট নিন (প্রস্তুত)'},
    'pointsRemaining': {'en': 'points remaining', 'bn': 'পয়েন্ট বাকি'},
    'pointsCollected': {'en': 'points collected', 'bn': 'পয়েন্ট সংগ্রহ হয়েছে'},
    'earnPointsByWatchingVideos': {
      'en': '🎬 Earn Points by Watching Ads',
      'bn': '🎬 অ্যাডস দেখে পয়েন্ট',
    },
    'videoDescription': {
      'en': 'Watch short videos to earn extra points',
      'bn': 'সংক্ষিপ্ত ভিডিও অ্যাডস দেখে অতিরিক্ত পয়েন্ট অর্জন করুন',
    },
    'watchVideos': {'en': 'Watch Videos', 'bn': 'ভিডিও দেখুন'},
    'premiumExperience': {
      'en': '⭐ Premium Experience',
      'bn': '⭐ প্রিমিয়াম এক্সপেরিয়েন্স',
    },
    'premiumDescription': {
      'en': 'Exclusive features and ad-free experience',
      'bn': 'এক্সক্লুসিভ ফিচার এবং এড-ফ্রি এক্সপেরিয়েন্স',
    },
    'adFreeUsage': {'en': 'Ad-free usage', 'bn': 'এড-ফ্রি ব্যবহার'},
    'exclusiveQuizzes': {'en': 'Exclusive quizzes', 'bn': 'এক্সক্লুসিভ কুইজ'},
    'prioritySupport': {'en': 'Priority support', 'bn': 'প্রায়োরিটি সাপোর্ট'},
    'doublePoints': {'en': 'Double points', 'bn': 'ডাবল পয়েন্ট'},
    'viewPremium': {'en': 'View Premium', 'bn': 'প্রিমিয়াম দেখুন'},
    'infoTitle': {
      'en':
          '5000 points will be deducted for gift request. Your gift will be delivered  within 24 hours InshaAllah.',
      'bn':
          'গিফট এর জন্য রিকোয়েস্ট করলে ৫০০০ পয়েন্ট কাটা হবে। এবং ২৪ ঘন্টার মধ্যে আপনার গিফট পৌঁছে দেয়া হবে ইনশাআল্লাহ ।',
    },
    'insufficientPoints': {
      'en': '❌ Insufficient points! Need {points} more points.',
      'bn': '❌ পর্যাপ্ত পয়েন্ট নেই! আরও {points} পয়েন্ট প্রয়োজন।',
    },
    'requestAccepted': {
      'en':
          '✅ Your gift request has been accepted! It will be notify immediate  InshaAllah.',
      'bn':
          '✅ আপনার গিফটের জন্য রিকোয়েস্টটি গ্রহণ করা হয়েছে! কিছুক্ষণের মধ্যে আপনাকে নোটিফাই করা হবে ইনশাল্লাহ ।',
    },
    'requestError': {
      'en': '❌ Problem requesting:',
      'bn': '❌ রিকোয়েস্ট করতে সমস্যা:',
    },

    'defaultUserName': {
      'en': 'Islamic Day Quiz User',
      'bn': 'ইসলামিক ডে কুইজ ইউজার',
    },
    'defaultUserEmail': {
      'en': 'Islamic Day Quiz User',
      'bn': 'ইসলামিক ডে কুইজ ইউজার',
    },
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

  // ডাইনামিক টেক্সট হেল্পার মেথড
  String _getInsufficientPointsText(BuildContext context) {
    final baseText = _text('insufficientPoints', context);
    final pointsNeeded = 5000 - _pendingPoints;
    return baseText.replaceFirst('{points}', pointsNeeded.toString());
  }

  int _pendingPoints = 0;
  int _totalPoints = 0;
  int _totalQuizzes = 0;
  int _totalCorrectAnswers = 0;
  String _userEmail = "";
  String _userName = "";
  String _userMobile = "";
  bool _isLoading = true;
  bool _isRequesting = false;
  bool _isEditingProfile = false;

  // ✅ নতুন ভেরিয়েবল যোগ করুন
  //int _profileCompleteness = 0;

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

  // ✅ CORRECTED: _loadUserData মেথড - ভাষা অনুযায়ী ডিফল্ট ভ্যালু
  Future<void> _loadUserData() async {
    try {
      final userData = await PointManager.getUserData();

      setState(() {
        _pendingPoints = userData['pendingPoints'] ?? 0;
        _totalPoints = userData['totalPoints'] ?? 0;
        _totalQuizzes = userData['totalQuizzes'] ?? 0;
        _totalCorrectAnswers = userData['totalCorrectAnswers'] ?? 0;

        // ✅ ভাষা অনুযায়ী ডিফল্ট ভ্যালু সেট করুন
        final defaultName = _text('defaultUserName', context);
        final defaultEmail = _text('defaultUserEmail', context);

        _userEmail = userData['userEmail'] ?? defaultEmail;
        _userName = userData['userName'] ?? defaultName;
        _userMobile = userData['userMobile'] ?? '';
        _isLoading = false;

        // ❌ এই লাইনটি ডিলিট করুন
        // _profileCompleteness = _calculateProfileCompleteness(userData, defaultName);
      });
    } catch (e) {
      print("Data load error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ প্রফাইল কমপ্লিটনেস ক্যালকুলেশন মেথড

  // ✅ ADDED: _formatDate মেথড
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return _text('noDate', context);
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
          category: _text('defaultUserName', context),
          // ভাষা অনুযায়ী ক্যাটাগরি
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
          content: Text(_getInsufficientPointsText(context)),
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
        title: Text(_text('editProfile', context)),
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
                decoration: InputDecoration(
                  labelText: _text('yourName', context),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  labelText: _text('mobileNumber', context),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  counterText: "",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_text('cancel', context)),
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
            child: Text(_text('save', context)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfileData() async {
    try {
      await PointManager.saveProfileData(_userName, _userMobile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_text('profileSaved', context)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_text('profileSaveError', context)} $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔥 গিফট রিকোয়েস্ট ফাংশন
  Future<void> _requestRecharge() async {
    if (_pendingPoints < 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getInsufficientPointsText(context)),
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
      await PointManager.saveGiftRequest(mobileNumber, _userEmail);
      await _loadUserData(); // ✅ আবার ডাটা লোড করুন যাতে আপডেটেড ভ্যালু দেখায়

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_text('requestAccepted', context)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_text('requestError', context)} $e"),
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
          title: Text(
            _text('enterMobile', context),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _text('mobileInstruction', context),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  hintText: _text('mobileHint', context),
                  labelText: _text('mobileLabel', context),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
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
              Text(
                _text('mobileValidation', context),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_text('cancel', context)),
            ),
            ElevatedButton(
              onPressed: () {
                String mobile = mobileController.text.trim();
                if (mobile.length == 11 && mobile.startsWith("01")) {
                  Navigator.pop(context, mobile);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_text('mobileValidation', context)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
              ),
              child: Text(_text('next', context)),
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
              title: Text(_text('confirmation', context)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_text('confirmRequest', context)),
                  const SizedBox(height: 10),
                  Text(
                    "${_text('mobileNumber', context)}: $mobileNumber",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _text('pointsDeducted', context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _text('warning', context),
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(_text('cancel', context)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                  child: Text(_text('confirm', context)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // 🔥 গিফট হিস্ট্রি দেখানোর ফাংশন
  Future<void> _showRechargeHistory() async {
    final history = await PointManager.getGiftHistory();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.history),
            const SizedBox(width: 8),
            Text(_text('myRewardHistory', context)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(_text('noRewardRequests', context)),
                      Text(
                        _text('rewardInstruction', context),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    var request = history[index];
                    return _buildRechargeHistoryItem(request, context);
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_text('close', context)),
          ),
        ],
      ),
    );
  }

  // 🔥 গিফট হিস্ট্রি আইটেম
  Widget _buildRechargeHistoryItem(
    Map<String, dynamic> request,
    BuildContext context,
  ) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending;
    String statusText = _text('pending', context);

    if (request['status'] == 'completed') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = _text('completed', context);
    } else if (request['status'] == 'rejected') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = _text('rejected', context);
    }

    final pointsUsed = request['pointsUsed'];
    final pointsText = pointsUsed != null ? pointsUsed.toString() : '0';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          "5000 ${_text('pointsEarned', context)} - ${request['mobileNumber'] ?? 'N/A'}",
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${_text('status', context)} $statusText"),
            Text(
              "${_text('date', context)} ${_formatDate(request['requestedAt'])}",
            ),
          ],
        ),
        trailing: Text(
          "$pointsText ${_text('pointsEarned', context).contains('পয়েন্ট') ? 'পয়েন্ট' : 'Points'}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  // 🔥 NEW: Additional Features Section Widget
  Widget _buildAdditionalFeaturesSection(bool isSmallScreen) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
        child: Column(
          children: [
            // কমপ্যাক্ট হেডার
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.green[700], size: 18),
                const SizedBox(width: 6),
                Text(
                  _text('earnPointsFromCategories', context),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // প্রফেশনাল বাটন
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[600]!, Colors.green[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 16,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.quiz, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _text('playQuiz', context),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 15 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _text('increaseIslamicKnowledge', context),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
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
        title: Text(
          _text('pageTitle', context),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        //centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
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
              tooltip: _text('premiumFeatures', context),
              splashRadius: 20,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.history, color: Colors.white, size: 20),
              onPressed: _showRechargeHistory,
              tooltip: _text('rewardHistory', context),
              splashRadius: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_text('loadingProfile', context)),
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
                          _buildUserProfileSection(
                            isTablet,
                            isSmallScreen,
                            context,
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 2: পয়েন্ট ও স্ট্যাটাস
                          _buildPointsStatsSection(
                            isTablet,
                            isSmallScreen,
                            context,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 3: মুল গিফট সেকশন
                          _buildGiftSection(isTablet, isSmallScreen, context),
                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 4: ভিডিও রিওয়ার্ড সেকশন
                          _buildVideoRewardSection(
                            isTablet,
                            isSmallScreen,
                            context,
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 5: ADDITIONAL FEATURES SECTION
                          _buildAdditionalFeaturesSection(isSmallScreen),
                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 6: প্রিমিয়াম সেকশন
                          _buildPremiumSection(
                            isTablet,
                            isSmallScreen,
                            context,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // SECTION 7: তথ্য বক্স
                          _buildInfoSection(isTablet, isSmallScreen, context),

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
  Widget _buildUserProfileSection(
    bool isTablet,
    bool isSmallScreen,
    BuildContext context,
  ) {
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

            // ✅ প্রফাইল কমপ্লিটনেস প্রোগ্রেস বার যোগ করুন
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
  Widget _buildPointsStatsSection(
    bool isTablet,
    bool isSmallScreen,
    BuildContext context,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(
          isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0),
        ),
        child: Column(
          children: [
            Text(
              _text('myStatistics', context),
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              _text('pendingPoints', context),
              _pendingPoints.toString(),
              Icons.monetization_on,
              Colors.green,
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
            ),
            const Divider(height: 1),
            _buildStatItem(
              _text('totalPointsEarned', context),
              _totalPoints.toString(),
              Icons.attach_money,
              Colors.blue,
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
            ),
            const Divider(height: 1),
            _buildStatItem(
              _text('totalQuizzesTaken', context),
              _totalQuizzes.toString(),
              Icons.quiz,
              Colors.orange,
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
            ),
            const Divider(height: 1),
            _buildStatItem(
              _text('totalCorrectAnswers', context),
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

  // SECTION 3: মুল গিফট সেকশন
  Widget _buildGiftSection(
    bool isTablet,
    bool isSmallScreen,
    BuildContext context,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*Icon(
                  Icons.card_giftcard,
                  color: Colors.purple,
                  size: isSmallScreen ? 20 : 24,
                ),*/
                const SizedBox(width: 8),
                Text(
                  _text('getRealGifts', context),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _text('giftDescription', context),
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.purple.shade800,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pendingPoints >= 5000 ? _requestRecharge : null,
                //icon: const Icon(Icons.redeem),
                label: Text(
                  _pendingPoints >= 5000
                      ? _text('getGiftReady', context)
                      : "${_text('getGift', context)} (${5000 - _pendingPoints} ${_text('pointsRemaining', context)})",
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
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _pendingPoints / 5000,
                backgroundColor: Colors.purple.shade200,
                color: Colors.purple,
                minHeight: 6,
              ),
              const SizedBox(height: 4),
              Text(
                "$_pendingPoints/5000 ${_text('pointsCollected', context)}",
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECTION 4: ভিডিও রিওয়ার্ড সেকশন
  Widget _buildVideoRewardSection(
    bool isTablet,
    bool isSmallScreen,
    BuildContext context,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            Row(
              children: [
                /*Icon(
                  Icons.video_library,
                  color: Colors.red,
                  size: isSmallScreen ? 20 : 24,
                ),*/
                const SizedBox(width: 8),
                Text(
                  _text('earnPointsByWatchingVideos', context),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _text('videoDescription', context),
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToReward,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  _text('watchVideos', context),
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

  // SECTION 6: প্রিমিয়াম সেকশন
  Widget _buildPremiumSection(
    bool isTablet,
    bool isSmallScreen,
    BuildContext context,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
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
                const SizedBox(width: 8),
                Text(
                  _text('premiumExperience', context),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _text('premiumDescription', context),
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // প্রিমিয়াম ফিচার লিস্ট
            Column(
              children: [
                _buildPremiumFeature(
                  _text('adFreeUsage', context),
                  Icons.block,
                  isSmallScreen,
                ),
                _buildPremiumFeature(
                  _text('exclusiveQuizzes', context),
                  Icons.quiz,
                  isSmallScreen,
                ),
                _buildPremiumFeature(
                  _text('prioritySupport', context),
                  Icons.support_agent,
                  isSmallScreen,
                ),
                _buildPremiumFeature(
                  _text('doublePoints', context),
                  Icons.bolt,
                  isSmallScreen,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToPremium,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  _text('viewPremium', context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  // SECTION 7: তথ্য বক্স
  Widget _buildInfoSection(
    bool isTablet,
    bool isSmallScreen,
    BuildContext context,
  ) {
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
              _text('infoTitle', context),
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
          const SizedBox(width: 8),
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
}
