// reward_screen.dart - PREMIUM REDESIGN
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';
import '../utils/point_manager.dart';
import 'package:islamicquiz/mcq_page.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({Key? key}) : super(key: key);

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isLoadingAd = false;
  int _todayRewards = 0;
  int _maxDailyRewards = 5;
  int _pointsPerReward = 10;
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
            setState(() {
              _rewardedAd = ad;
              _isRewardedAdLoaded = true;
              _isLoadingAd = false;
            });

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                ad.dispose();
                _loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent:
                  (RewardedAd ad, AdError error) {
                    ad.dispose();
                    _loadRewardedAd();
                  },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            setState(() {
              _isRewardedAdLoaded = false;
              _isLoadingAd = false;
              _rewardedAd = null;
            });

            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) _loadRewardedAd();
            });
          },
        ),
      );
    } catch (e) {
      setState(() {
        _isLoadingAd = false;
        _isRewardedAdLoaded = false;
      });
    }
  }

  Future<void> _showRewardedAd() async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      _showSnackBar(
        '❌ অ্যাড এখনো লোড হয়নি, অনুগ্রহ করে অপেক্ষা করুন',
        Colors.red,
      );
      return;
    }

    if (_todayRewards >= _maxDailyRewards) {
      _showSnackBar(
        '❌ আপনি আজ সর্বোচ্চ $_maxDailyRewards টি অ্যাড দেখেছেন',
        Colors.orange,
      );
      return;
    }

    try {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          _addRewardPoints();
        },
      );
    } catch (e) {
      _showSnackBar('❌ অ্যাড দেখাতে সমস্যা হয়েছে', Colors.red);
    }
  }

  Future<void> _addRewardPoints() async {
    try {
      await PointManager.addPoints(_pointsPerReward);
      await PointManager.updateTodayRewards(_todayRewards + 1);
      await _loadUserData();

      _showSnackBar(
        '✅ $_pointsPerReward পয়েন্ট যোগ হয়েছে! আজ $_todayRewards/$_maxDailyRewards অ্যাড দেখেছেন',
        Colors.green,
        duration: const Duration(seconds: 3),
      );

      setState(() {
        _isRewardedAdLoaded = false;
      });
      _loadRewardedAd();
    } catch (e) {
      _showSnackBar('❌ পয়েন্ট যোগ করতে সমস্যা হয়েছে', Colors.red);
    }
  }

  void _showSnackBar(
    String message,
    Color color, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration,
      ),
    );
  }

  String get _nextResetTime {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    return '$hours ঘন্টা $minutes মিনিট';
  }

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ফ্রি পয়েন্ট জিতুন",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Premium Header Section
                    _buildPremiumHeader(),

                    const SizedBox(height: 20),

                    // Compact Progress & Stats Row
                    _buildCompactProgressRow(),

                    const SizedBox(height: 20),

                    // Main Reward Button
                    _buildPremiumRewardButton(),

                    const SizedBox(height: 20),

                    // Quiz Section
                    _buildPremiumQuizSection(),

                    const SizedBox(height: 20),

                    // Info & Reset Section
                    _buildPremiumInfoSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange[800]!, Colors.orange[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "অ্যাড দেখে ফ্রি পয়েন্ট পান!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "প্রতিটি অ্যাড দেখে পান $_pointsPerReward পয়েন্ট",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events, size: 32, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProgressRow() {
    return Row(
      children: [
        // Today's Progress
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "আজকের অ্যাড দেখা",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      "$_todayRewards/$_maxDailyRewards",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _todayRewards / _maxDailyRewards,
                  backgroundColor: Colors.grey[200],
                  color: _todayRewards >= _maxDailyRewards
                      ? Colors.green
                      : Colors.orange,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 6),
                Text(
                  _todayRewards >= _maxDailyRewards
                      ? "লিমিট শেষ"
                      : "${_maxDailyRewards - _todayRewards} টি বাকি",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Points Stats
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      "মোট পয়েন্ট",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _pendingPoints.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.today, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      "আজকের আয়",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${_todayRewards * _pointsPerReward}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumRewardButton() {
    final isMaxReached = _todayRewards >= _maxDailyRewards;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Text(
            "পয়েন্ট সংগ্রহ করুন",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isMaxReached || _isLoadingAd || !_isRewardedAdLoaded
                  ? null
                  : _showRewardedAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: isMaxReached
                    ? Colors.grey
                    : Colors.orange[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.orange.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoadingAd)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(Icons.play_arrow_rounded, size: 24),
                  const SizedBox(width: 12),
                  _isLoadingAd
                      ? const Text(
                          'অ্যাড লোড হচ্ছে...',
                          style: TextStyle(fontSize: 16),
                        )
                      : !_isRewardedAdLoaded
                      ? const Text(
                          'অ্যাড প্রস্তুত হচ্ছে...',
                          style: TextStyle(fontSize: 16),
                        )
                      : isMaxReached
                      ? const Text(
                          'আজকের লিমিট শেষ',
                          style: TextStyle(fontSize: 16),
                        )
                      : Text(
                          '$_pointsPerReward পয়েন্ট পান',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "৩০ সেকেন্ডের অ্যাড দেখে পয়েন্ট সংগ্রহ করুন",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumQuizSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[50]!, Colors.lightGreen[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                "বোনাস পয়েন্ট অর্জন করুন",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToQuiz,
              icon: const Icon(Icons.quiz_rounded, size: 20),
              label: const Text(
                "ইসলামী কুইজ খেলুন",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100]!.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.green[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "ইসলামী জ্ঞান যাচাই করুন এবং বোনাস পয়েন্ট ও গিফট পান!",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
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

  Widget _buildPremiumInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_filled_rounded,
            color: Colors.blue[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "পরবর্তী রিসেট: $_nextResetTime",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "প্রতিদিন $_maxDailyRewards টি অ্যাড দেখার সুযোগ",
                  style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
