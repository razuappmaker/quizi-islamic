// reward_screen.dart - PREMIUM REDESIGN WITH DUAL LANGUAGE
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../ad_helper.dart';
import '../utils/point_manager.dart';
import 'package:islamicquiz/mcq_page.dart';
import '../providers/language_provider.dart';

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

  // Language Texts - Now initialized in initState
  late Map<String, Map<String, String>> _texts;

  @override
  void initState() {
    super.initState();
    _initializeTexts();
    _loadUserData();
    _loadRewardedAd();
  }

  void _initializeTexts() {
    _texts = {
      'title': {'en': 'Earn Free Points', 'bn': 'ফ্রি পয়েন্ট জিতুন'},
      'headerTitle': {
        'en': 'Watch Ads & Earn Points!',
        'bn': 'অ্যাড দেখে ফ্রি পয়েন্ট পান!',
      },
      'headerSubtitle': {
        'en': 'Earn $_pointsPerReward points for each ad',
        'bn': 'প্রতিটি অ্যাড দেখে পান $_pointsPerReward পয়েন্ট',
      },
      'todayAds': {'en': "Today's Ads", 'bn': "আজকের অ্যাড দেখা"},
      'limitReached': {'en': "Limit Reached", 'bn': "লিমিট শেষ"},
      'remaining': {'en': "remaining", 'bn': "টি বাকি"},
      'totalPoints': {'en': "Total Points", 'bn': "মোট পয়েন্ট"},
      'todayEarnings': {'en': "Today's Earnings", 'bn': "আজকের আয়"},
      'collectPoints': {'en': "Collect Points", 'bn': "পয়েন্ট সংগ্রহ করুন"},
      'adLoading': {'en': "Loading Ad...", 'bn': "অ্যাড লোড হচ্ছে..."},
      'adPreparing': {'en': "Preparing Ad...", 'bn': "অ্যাড প্রস্তুত হচ্ছে..."},
      'getPoints': {
        'en': "Get $_pointsPerReward Points",
        'bn': "$_pointsPerReward পয়েন্ট পান",
      },
      'dailyLimit': {'en': "Daily Limit Reached", 'bn': "আজকের লিমিট শেষ"},
      'watchAdDesc': {
        'en': "Watch a 30-second ad to earn points",
        'bn': "৩০ সেকেন্ডের অ্যাড দেখে পয়েন্ট সংগ্রহ করুন",
      },
      'bonusPoints': {
        'en': "Earn Bonus Points",
        'bn': "বোনাস পয়েন্ট অর্জন করুন",
      },
      'playQuiz': {'en': "Play Islamic Quiz", 'bn': "ইসলামী কুইজ খেলুন"},
      'quizTip': {
        'en': "Test your Islamic knowledge and earn bonus points & gifts!",
        'bn': "ইসলামী জ্ঞান যাচাই করুন এবং বোনাস পয়েন্ট ও গিফট পান!",
      },
      'nextReset': {'en': "Next Reset", 'bn': "পরবর্তী রিসেট"},
      'dailyOpportunity': {
        'en': "$_maxDailyRewards ad views daily",
        'bn': "প্রতিদিন $_maxDailyRewards টি অ্যাড দেখার সুযোগ",
      },
      'adNotLoaded': {
        'en': "❌ Ad not loaded yet, please wait",
        'bn': "❌ অ্যাড এখনো লোড হয়নি, অনুগ্রহ করে অপেক্ষা করুন",
      },
      'maxAdsWatched': {
        'en': "❌ You've watched maximum $_maxDailyRewards ads today",
        'bn': "❌ আপনি আজ সর্বোচ্চ $_maxDailyRewards টি অ্যাড দেখেছেন",
      },
      'adError': {
        'en': "❌ Error showing ad",
        'bn': "❌ অ্যাড দেখাতে সমস্যা হয়েছে",
      },
      'pointsAdded': {
        'en':
            "✅ $_pointsPerReward points added! Today $_todayRewards/$_maxDailyRewards ads",
        'bn':
            "✅ $_pointsPerReward পয়েন্ট যোগ হয়েছে! আজ $_todayRewards/$_maxDailyRewards অ্যাড দেখেছেন",
      },
      'pointsError': {
        'en': "❌ Error adding points",
        'bn': "❌ পয়েন্ট যোগ করতে সমস্যা হয়েছে",
      },
    };
  }

  // Update texts when data changes
  void _updateTexts() {
    setState(() {
      _texts['headerSubtitle'] = {
        'en': 'Earn $_pointsPerReward points for each ad',
        'bn': 'প্রতিটি অ্যাড দেখে পান $_pointsPerReward পয়েন্ট',
      };
      _texts['getPoints'] = {
        'en': "Get $_pointsPerReward Points",
        'bn': "$_pointsPerReward পয়েন্ট পান",
      };
      _texts['dailyOpportunity'] = {
        'en': "$_maxDailyRewards ad views daily",
        'bn': "প্রতিদিন $_maxDailyRewards টি অ্যাড দেখার সুযোগ",
      };
      _texts['maxAdsWatched'] = {
        'en': "❌ You've watched maximum $_maxDailyRewards ads today",
        'bn': "❌ আপনি আজ সর্বোচ্চ $_maxDailyRewards টি অ্যাড দেখেছেন",
      };
      _texts['pointsAdded'] = {
        'en':
            "✅ $_pointsPerReward points added! Today $_todayRewards/$_maxDailyRewards ads",
        'bn':
            "✅ $_pointsPerReward পয়েন্ট যোগ হয়েছে! আজ $_todayRewards/$_maxDailyRewards অ্যাড দেখেছেন",
      };
    });
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
      _updateTexts(); // Update texts after loading data
    } catch (e) {
      print("Data load error: $e");
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
      _showSnackBar(_text('adNotLoaded'), Colors.red);
      return;
    }

    if (_todayRewards >= _maxDailyRewards) {
      _showSnackBar(_text('maxAdsWatched'), Colors.orange);
      return;
    }

    try {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          _addRewardPoints();
        },
      );
    } catch (e) {
      _showSnackBar(_text('adError'), Colors.red);
    }
  }

  Future<void> _addRewardPoints() async {
    try {
      await PointManager.addPoints(_pointsPerReward);
      await PointManager.updateTodayRewards(_todayRewards + 1);
      await _loadUserData();

      _showSnackBar(
        _text('pointsAdded'),
        Colors.green,
        duration: const Duration(seconds: 3),
      );

      setState(() {
        _isRewardedAdLoaded = false;
      });
      _loadRewardedAd();
    } catch (e) {
      _showSnackBar(_text('pointsError'), Colors.red);
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

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    if (languageProvider.isEnglish) {
      return '$hours hours $minutes minutes';
    } else {
      return '$hours ঘন্টা $minutes মিনিট';
    }
  }

  void _navigateToQuiz() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MCQPage(
          category: languageProvider.isEnglish
              ? 'Basic Islamic Knowledge'
              : 'ইসলামী প্রাথমিক জ্ঞান',
          quizId: 'islamic_basic_knowledge',
        ),
      ),
    );
  }

  String _text(String key) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text('title'),
          style: const TextStyle(
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Premium Header Section
                    _buildPremiumHeader(isEnglish),

                    const SizedBox(height: 20),

                    // Compact Progress & Stats Row
                    _buildCompactProgressRow(isEnglish),

                    const SizedBox(height: 20),

                    // Main Reward Button
                    _buildPremiumRewardButton(isEnglish),

                    const SizedBox(height: 20),

                    // Quiz Section
                    _buildPremiumQuizSection(isEnglish),

                    const SizedBox(height: 20),

                    // Info & Reset Section
                    _buildPremiumInfoSection(isEnglish),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPremiumHeader(bool isEnglish) {
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
                  _text('headerTitle'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _text('headerSubtitle'),
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
            child: const Icon(
              Icons.emoji_events,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProgressRow(bool isEnglish) {
    final remainingText = isEnglish
        ? "${_maxDailyRewards - _todayRewards} ${_text('remaining')}"
        : "${_maxDailyRewards - _todayRewards} ${_text('remaining')}";

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
                      _text('todayAds'),
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
                      ? _text('limitReached')
                      : remainingText,
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
                      _text('totalPoints'),
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
                      _text('todayEarnings'),
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

  Widget _buildPremiumRewardButton(bool isEnglish) {
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
            _text('collectPoints'),
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
                    const Icon(Icons.play_arrow_rounded, size: 24),
                  const SizedBox(width: 12),
                  _isLoadingAd
                      ? Text(
                          _text('adLoading'),
                          style: const TextStyle(fontSize: 16),
                        )
                      : !_isRewardedAdLoaded
                      ? Text(
                          _text('adPreparing'),
                          style: const TextStyle(fontSize: 16),
                        )
                      : isMaxReached
                      ? Text(
                          _text('dailyLimit'),
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(
                          _text('getPoints'),
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
            _text('watchAdDesc'),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumQuizSection(bool isEnglish) {
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
                _text('bonusPoints'),
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
              label: Text(
                _text('playQuiz'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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
                    _text('quizTip'),
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

  Widget _buildPremiumInfoSection(bool isEnglish) {
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
                  "${_text('nextReset')}: $_nextResetTime",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _text('dailyOpportunity'),
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
