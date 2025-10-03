// reward_screen.dart - UPDATED WITH NEW FEATURE BUTTONS
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';
import '../utils/point_manager.dart';
import 'package:islamicquiz/mcq_page.dart'; // MCQPage import করুন

class RewardScreen extends StatefulWidget {
  const RewardScreen({Key? key}) : super(key: key);

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  // Ad variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isLoadingAd = false;

  // Reward tracking
  int _todayRewards = 0;
  int _maxDailyRewards = 5;
  int _pointsPerReward = 10;

  // User stats
  int _pendingPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await PointManager.getUserData();
      setState(() {
        _pendingPoints = userData['pendingPoints'] ?? 0;
        _todayRewards = userData['todayRewards'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print("ডাটা লোড করতে ত্রুটি: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔥 রিওয়ার্ডেড অ্যাড লোড করুন
  Future<void> _loadRewardedAd() async {
    try {
      setState(() {
        _isLoadingAd = true;
      });

      await RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('রিওয়ার্ডেড অ্যাড লোড হয়েছে');
            setState(() {
              _rewardedAd = ad;
              _isRewardedAdLoaded = true;
              _isLoadingAd = false;
            });

            // অ্যাড ডিসমিস হলে আবার লোড করুন
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                print('অ্যাড ডিসমিস হয়েছে');
                ad.dispose();
                _loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent:
                  (RewardedAd ad, AdError error) {
                    print('অ্যাড দেখাতে ব্যর্থ: $error');
                    ad.dispose();
                    _loadRewardedAd();
                  },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('রিওয়ার্ডেড অ্যাড লোড হতে ব্যর্থ: $error');
            setState(() {
              _isRewardedAdLoaded = false;
              _isLoadingAd = false;
              _rewardedAd = null;
            });

            // ৫ সেকেন্ড পর আবার চেষ্টা করুন
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) _loadRewardedAd();
            });
          },
        ),
      );
    } catch (e) {
      print('রিওয়ার্ডেড অ্যাড লোড করতে ত্রুটি: $e');
      setState(() {
        _isLoadingAd = false;
        _isRewardedAdLoaded = false;
      });
    }
  }

  // 🔥 অ্যাড দেখান এবং পয়েন্ট দিন
  Future<void> _showRewardedAd() async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ অ্যাড এখনো লোড হয়নি, অনুগ্রহ করে অপেক্ষা করুন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_todayRewards >= _maxDailyRewards) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ আপনি আজ সর্বোচ্চ $_maxDailyRewards টি অ্যাড দেখেছেন',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('ইউজার পুরস্কার পেয়েছেন: ${reward.amount} ${reward.type}');

          // পয়েন্ট যোগ করুন
          _addRewardPoints();
        },
      );
    } catch (e) {
      print('অ্যাড দেখাতে ত্রুটি: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ অ্যাড দেখাতে সমস্যা হয়েছে'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔥 রিওয়ার্ড পয়েন্ট যোগ করুন
  Future<void> _addRewardPoints() async {
    try {
      // পয়েন্ট যোগ করুন
      await PointManager.addPoints(_pointsPerReward);

      // আজকের রিওয়ার্ড সংখ্যা আপডেট করুন
      await PointManager.updateTodayRewards(_todayRewards + 1);

      // UI আপডেট করুন
      await _loadUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ $_pointsPerReward পয়েন্ট যোগ হয়েছে! আজ $_todayRewards/$_maxDailyRewards অ্যাড দেখেছেন',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // পরবর্তী অ্যাডের জন্য প্রস্তুত করুন
      setState(() {
        _isRewardedAdLoaded = false;
      });
      _loadRewardedAd();
    } catch (e) {
      print('পয়েন্ট যোগ করতে ত্রুটি: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ পয়েন্ট যোগ করতে সমস্যা হয়েছে'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔥 রিসেট টাইমার (আগামী দিনের জন্য)
  String get _nextResetTime {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return '$hours ঘন্টা $minutes মিনিট';
  }

  // 🔥 UPDATED: কুইজ পেজে সরাসরি নেভিগেট
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

  // 🔥 NEW: গিফট পেজে নেভিগেট
  void _navigateToGift() {
    // প্রোফাইল পেজে নেভিগেট করুন (গিফট সেকশন থাকবে)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ফ্রি পয়েন্ট পান",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        centerTitle: true,
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.0 : 16.0,
                        vertical: isSmallScreen ? 12.0 : 16.0,
                      ),
                      child: Column(
                        children: [
                          // Header Section
                          Card(
                            elevation: 4,
                            color: Colors.orange[50],
                            child: Padding(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 16.0 : 20.0,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    size: isSmallScreen ? 50 : 60,
                                    color: Colors.orange[800],
                                  ),
                                  SizedBox(height: isSmallScreen ? 8 : 12),
                                  Text(
                                    "অ্যাড দেখে ফ্রি পয়েন্ট পান!",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isSmallScreen ? 4 : 8),
                                  Text(
                                    "প্রতিটি অ্যাড দেখে পান $_pointsPerReward পয়েন্ট",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Progress Section
                          Card(
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 12.0 : 16.0,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "আজকের অ্যাড দেখা",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "$_todayRewards/$_maxDailyRewards",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: _todayRewards / _maxDailyRewards,
                                    backgroundColor: Colors.grey[300],
                                    color: _todayRewards >= _maxDailyRewards
                                        ? Colors.green
                                        : Colors.orange,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _todayRewards >= _maxDailyRewards
                                        ? "✅ আজকের লিমিট শেষ"
                                        : "আরও ${_maxDailyRewards - _todayRewards} টি অ্যাড দেখতে পারেন",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Reward Button
                          Card(
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 12.0 : 16.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "পয়েন্ট সংগ্রহ করুন",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  _buildRewardButton(),
                                  SizedBox(height: 8),
                                  Text(
                                    "অ্যাড দেখে $_pointsPerReward পয়েন্ট পান",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // 🔥 NEW: ADDITIONAL FEATURE BUTTONS SECTION
                          _buildAdditionalFeaturesSection(isSmallScreen),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Info Section
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.blue,
                                  size: isSmallScreen ? 18 : 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "পরবর্তী রিসেট: $_nextResetTime",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "প্রতিদিন আপনি $_maxDailyRewards টি অ্যাড দেখতে পারেন",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 10 : 12,
                                          color: Colors.blue[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Current Points
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildPointsInfo(
                                    "জমাকৃত পয়েন্ট",
                                    _pendingPoints.toString(),
                                    Icons.monetization_on,
                                    Colors.green,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                  _buildPointsInfo(
                                    "আজকের আয়",
                                    "${_todayRewards * _pointsPerReward}",
                                    Icons.today,
                                    Colors.orange,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                ],
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
    );
  }

  // 🔥 NEW: ADDITIONAL FEATURES SECTION
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

  Widget _buildRewardButton() {
    final isMaxReached = _todayRewards >= _maxDailyRewards;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isMaxReached || _isLoadingAd || !_isRewardedAdLoaded
            ? null
            : _showRewardedAd,
        icon: _isLoadingAd
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow),
        label: _isLoadingAd
            ? const Text('অ্যাড লোড হচ্ছে...')
            : !_isRewardedAdLoaded
            ? const Text('অ্যাড প্রস্তুত হচ্ছে...')
            : isMaxReached
            ? const Text('আজকের লিমিট শেষ')
            : Text('$_pointsPerReward পয়েন্ট পান'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isMaxReached ? Colors.grey : Colors.orange[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsInfo(
    String title,
    String value,
    IconData icon,
    Color color, {
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
