// profile_screen.dart - উন্নত প্রোফাইল সিস্টেম (আপডেটেড)
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../core/managers/point_manager.dart';
import '../../core/constants/ad_helper.dart';
import 'premium_screen.dart';
import 'reward_screen.dart';
import '../features/knowledge/mcq_page.dart';
import '../providers/language_provider.dart';
import '../../core/constants/app_colors.dart'; // ✅ AppColors import

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
    'videoDescription': {
      'en': 'Complete short activities to earn bonus points',
      'bn': 'বোনাস পয়েন্ট অর্জন করতে সংক্ষিপ্ত অ্যাক্টিভিটি সম্পন্ন করুন',
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
    'totalQuizzesTaken': {
      'en': 'Total Categories Attempted',
      'bn': 'মোট কুইজ দেওয়া',
    },
    'totalCorrectAnswers': {
      'en': 'Total Correct Answers',
      'bn': 'মোট সঠিক উত্তর',
    },
    'getRealGifts': {'en': '🎁 Apply for Gifts', 'bn': '🎁 গিফট এর জন্য আবেদন'},
    'giftDescription': {
      'en': 'Collect 5000 points to redeem exciting rewards',
      'bn': '৫০০০ পয়েন্ট জমা করে আকর্ষণীয় রিওয়ার্ড রিডিম করুন',
    },
    'getGift': {'en': 'Get Gift', 'bn': 'গিফট নিন'},
    'getGiftReady': {'en': 'Get Gift (Ready)', 'bn': 'গিফট নিন (প্রস্তুত)'},
    'pointsRemaining': {'en': 'points remaining', 'bn': 'পয়েন্ট বাকি'},
    'pointsCollected': {'en': 'points collected', 'bn': 'পয়েন্ট সংগ্রহ হয়েছে'},
    'earnPointsFromRewards': {
      'en': '🎬 Earn Points from Rewards',
      'bn': '🎬 রিওয়ার্ড থেকে পয়েন্ট',
    },
    'rewardDescription': {
      'en': 'Complete tasks to earn extra points',
      'bn': 'অতিরিক্ত পয়েন্ট অর্জন করতে টাস্কগুলি সম্পন্ন করুন',
    },
    'viewRewards': {'en': 'View Rewards', 'bn': 'রিওয়ার্ড দেখুন'},
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
      });
    } catch (e) {
      print("Data load error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

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
          backgroundColor: AppColors.getErrorColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      );
    }
  }

  // 🔥 প্রোফাইল এডিট ফাংশন
  Future<void> _editProfile() async {
    _nameController.text = _userName;
    _mobileController.text = _userMobile;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardColor(isDark),
        title: Text(
          _text('editProfile', context),
          style: TextStyle(color: AppColors.getTextColor(isDark)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.getPrimaryColor(isDark),
                child: Icon(Icons.person, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: TextStyle(color: AppColors.getTextColor(isDark)),
                decoration: InputDecoration(
                  labelText: _text('yourName', context),
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDark),
                  ),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.person,
                    color: AppColors.getPrimaryColor(isDark),
                  ),
                  filled: true,
                  fillColor: AppColors.getSurfaceColor(isDark),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                style: TextStyle(color: AppColors.getTextColor(isDark)),
                decoration: InputDecoration(
                  labelText: _text('mobileNumber', context),
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDark),
                  ),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.phone,
                    color: AppColors.getPrimaryColor(isDark),
                  ),
                  counterText: "",
                  filled: true,
                  fillColor: AppColors.getSurfaceColor(isDark),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimaryColor(isDark),
            ),
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
          backgroundColor: AppColors.getErrorColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
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
          backgroundColor: AppColors.getErrorColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
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
      await _loadUserData();

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
          backgroundColor: AppColors.getErrorColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.getCardColor(isDark),
          title: Text(
            _text('enterMobile', context),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(isDark),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _text('mobileInstruction', context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextSecondaryColor(isDark),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                style: TextStyle(color: AppColors.getTextColor(isDark)),
                decoration: InputDecoration(
                  hintText: _text('mobileHint', context),
                  hintStyle: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDark),
                  ),
                  labelText: _text('mobileLabel', context),
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDark),
                  ),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.phone,
                    color: AppColors.getPrimaryColor(isDark),
                  ),
                  counterText: "",
                  filled: true,
                  fillColor: AppColors.getSurfaceColor(isDark),
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
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondaryColor(isDark),
                ),
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
                      backgroundColor: AppColors.getErrorColor(isDark),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor(isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.getCardColor(isDark),
              title: Text(
                _text('confirmation', context),
                style: TextStyle(color: AppColors.getTextColor(isDark)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _text('confirmRequest', context),
                    style: TextStyle(color: AppColors.getTextColor(isDark)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${_text('mobileNumber', context)}: $mobileNumber",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  Text(
                    _text('pointsDeducted', context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _text('warning', context),
                    style: TextStyle(color: Colors.orange),
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
                    backgroundColor: AppColors.getPrimaryColor(isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardColor(isDark),
        title: Row(
          children: [
            Icon(Icons.history, color: AppColors.getPrimaryColor(isDark)),
            const SizedBox(width: 8),
            Text(
              _text('myRewardHistory', context),
              style: TextStyle(color: AppColors.getTextColor(isDark)),
            ),
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
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: AppColors.getTextSecondaryColor(isDark),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _text('noRewardRequests', context),
                        style: TextStyle(color: AppColors.getTextColor(isDark)),
                      ),
                      Text(
                        _text('rewardInstruction', context),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextSecondaryColor(isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      color: AppColors.getSurfaceColor(isDark),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          "5000 ${_text('pointsEarned', context)} - ${request['mobileNumber'] ?? 'N/A'}",
          style: TextStyle(color: AppColors.getTextColor(isDark)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_text('status', context)} $statusText",
              style: TextStyle(color: AppColors.getTextSecondaryColor(isDark)),
            ),
            Text(
              "${_text('date', context)} ${_formatDate(request['requestedAt'])}",
              style: TextStyle(color: AppColors.getTextSecondaryColor(isDark)),
            ),
          ],
        ),
        trailing: Text(
          "$pointsText ${_text('pointsEarned', context).contains('পয়েন্ট') ? 'পয়েন্ট' : 'Points'}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.getPrimaryColor(isDark),
          ),
        ),
      ),
    );
  }

  // 🔥 NEW: Additional Features Section Widget
  Widget _buildAdditionalFeaturesSection(bool isSmallScreen) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.getCardColor(isDark),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.getPrimaryColor(isDark),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  _text('earnPointsFromCategories', context),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? AppColors.darkHeaderGradient
                      : [Colors.green[600]!, Colors.green[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getPrimaryColor(isDark).withOpacity(0.4),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.getAppBarColor(isDark),
        title: Text(
          _text('pageTitle', context),
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
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
                    CircularProgressIndicator(
                      color: AppColors.getPrimaryColor(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _text('loadingProfile', context),
                      style: TextStyle(color: AppColors.getTextColor(isDark)),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.0 : 16.0,
                        vertical: isSmallScreen ? 12.0 : 16.0,
                      ),
                      child: Column(
                        children: [
                          _buildUserProfileSection(
                            isTablet,
                            isSmallScreen,
                            context,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          _buildPointsStatsSection(
                            isTablet,
                            isSmallScreen,
                            context,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          _buildGiftSection(isTablet, isSmallScreen, context),
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          _buildVideoRewardSection(
                            isTablet,
                            isSmallScreen,
                            context,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          _buildAdditionalFeaturesSection(isSmallScreen),
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          _buildPremiumSection(
                            isTablet,
                            isSmallScreen,
                            context,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          _buildInfoSection(isTablet, isSmallScreen, context),
                          SizedBox(
                            height: _isBannerAdLoaded
                                ? (isSmallScreen ? 12 : 16)
                                : (isSmallScreen ? 8 : 12),
                          ),
                        ],
                      ),
                    ),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      color: AppColors.getCardColor(isDark),
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
                  backgroundColor: AppColors.getPrimaryColor(isDark),
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
                      color: AppColors.getAccentColor('blue', isDark),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.getCardColor(isDark),
                        width: 2,
                      ),
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
                      color: AppColors.getTextColor(isDark),
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
                color: AppColors.getTextSecondaryColor(isDark),
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
                  color: AppColors.getAccentColor('blue', isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      color: AppColors.getCardColor(isDark),
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
                color: AppColors.getAccentColor('purple', isDark),
              ),
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              _text('pendingPoints', context),
              _pendingPoints.toString(),
              Icons.monetization_on,
              AppColors.getAccentColor('green', isDark),
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
              isDark: isDark,
            ),
            Divider(height: 1, color: AppColors.getBorderColor(isDark)),
            _buildStatItem(
              _text('totalPointsEarned', context),
              _totalPoints.toString(),
              Icons.attach_money,
              AppColors.getAccentColor('blue', isDark),
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
              isDark: isDark,
            ),
            Divider(height: 1, color: AppColors.getBorderColor(isDark)),
            _buildStatItem(
              _text('totalQuizzesTaken', context),
              _totalQuizzes.toString(),
              Icons.quiz,
              AppColors.getAccentColor('orange', isDark),
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
              isDark: isDark,
            ),
            Divider(height: 1, color: AppColors.getBorderColor(isDark)),
            _buildStatItem(
              _text('totalCorrectAnswers', context),
              _totalCorrectAnswers.toString(),
              Icons.check_circle,
              AppColors.getAccentColor('purple', isDark),
              isTablet: isTablet,
              isSmallScreen: isSmallScreen,
              isDark: isDark,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      color: AppColors.getCardColor(isDark),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Text(
                  _text('getRealGifts', context),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getAccentColor('purple', isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _text('giftDescription', context),
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: AppColors.getTextColor(isDark),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pendingPoints >= 5000 ? _requestRecharge : null,
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
                  backgroundColor: AppColors.getAccentColor('purple', isDark),
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
                backgroundColor: AppColors.getSurfaceColor(isDark),
                color: AppColors.getAccentColor('purple', isDark),
                minHeight: 6,
              ),
              const SizedBox(height: 4),
              Text(
                "$_pendingPoints/5000 ${_text('pointsCollected', context)}",
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: AppColors.getTextSecondaryColor(isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      color: AppColors.getCardColor(isDark),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: AppColors.getAccentColor('orange', isDark),
                  size: isSmallScreen ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _text('earnPointsFromRewards', context),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getAccentColor('orange', isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _text('rewardDescription', context),
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: AppColors.getTextSecondaryColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToReward,
                icon: const Icon(Icons.card_giftcard),
                label: Text(
                  _text('viewRewards', context),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getAccentColor('orange', isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      color: AppColors.getCardColor(isDark),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: AppColors.getAccentColor('orange', isDark),
                  size: isSmallScreen ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _text('premiumExperience', context),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _text('premiumDescription', context),
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: AppColors.getTextSecondaryColor(isDark),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _buildPremiumFeature(
                  _text('adFreeUsage', context),
                  Icons.block,
                  isSmallScreen,
                  isDark: isDark,
                ),
                _buildPremiumFeature(
                  _text('exclusiveQuizzes', context),
                  Icons.quiz,
                  isSmallScreen,
                  isDark: isDark,
                ),
                _buildPremiumFeature(
                  _text('prioritySupport', context),
                  Icons.support_agent,
                  isSmallScreen,
                  isDark: isDark,
                ),
                _buildPremiumFeature(
                  _text('doublePoints', context),
                  Icons.bolt,
                  isSmallScreen,
                  isDark: isDark,
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
                  foregroundColor: AppColors.getPrimaryColor(isDark),
                  side: BorderSide(color: AppColors.getPrimaryColor(isDark)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : (isTablet ? 16 : 12)),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.getBorderColor(isDark)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info,
            color: AppColors.getPrimaryColor(isDark),
            size: isSmallScreen ? 18 : 24,
          ),
          SizedBox(width: isSmallScreen ? 8 : (isTablet ? 12 : 8)),
          Expanded(
            child: Text(
              _text('infoTitle', context),
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : (isTablet ? 14 : 12),
                color: AppColors.getTextColor(isDark),
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
    required bool isDark,
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
                color: AppColors.getTextColor(isDark),
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
    bool isSmallScreen, {
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.getPrimaryColor(isDark),
            size: isSmallScreen ? 16 : 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: AppColors.getTextColor(isDark),
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.getPrimaryColor(isDark),
            size: isSmallScreen ? 16 : 18,
          ),
        ],
      ),
    );
  }
}
