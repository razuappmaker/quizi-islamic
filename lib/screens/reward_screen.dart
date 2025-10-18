// reward_screen.dart - PROFESSIONAL GREEN THEME VERSION
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../ad_helper.dart';
import '../utils/point_manager.dart';
import 'package:islamicquiz/mcq_page.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart'; // ✅ AppColors import

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

  // Language Texts - Policy Compliant
  late Map<String, Map<String, String>> _texts;

  // Color getters using AppColors
  Color _primaryColor(BuildContext context) => ThemeHelper.primary(context);

  Color _secondaryColor(BuildContext context) => AppColors.getAccentColor(
    'green',
    Theme.of(context).brightness == Brightness.dark,
  );

  Color _accentColor(BuildContext context) => AppColors.getAccentColor(
    'blue',
    Theme.of(context).brightness == Brightness.dark,
  );

  Color _successColor(BuildContext context) => Colors.green;

  Color _warningColor(BuildContext context) => Colors.amber[700]!;

  Color _cardColor(BuildContext context) => ThemeHelper.card(context);

  Color _textColor(BuildContext context) => ThemeHelper.text(context);

  Color _subtitleColor(BuildContext context) =>
      ThemeHelper.textSecondary(context);

  Color _backgroundColor(BuildContext context) =>
      ThemeHelper.background(context);

  @override
  void initState() {
    super.initState();
    _initializeTexts();
    _loadUserData();
    _loadRewardedAd();
  }

  void _initializeTexts() {
    _texts = {
      'title': {'en': 'Daily Rewards', 'bn': 'দৈনিক রিওয়ার্ড'},
      'headerTitle': {
        'en': 'Complete Tasks & Earn Rewards!',
        'bn': 'টাস্ক সম্পন্ন করে পুরস্কার অর্জন করুন!',
      },
      'headerSubtitle': {
        'en': 'Engage with activities and collect points',
        'bn': 'অ্যাক্টিভিটিতে অংশ নিয়ে পয়েন্ট সংগ্রহ করুন',
      },
      'todayTasks': {'en': "Today's Progress", 'bn': "আজকের অগ্রগতি"},
      'limitReached': {
        'en': "🎉 Daily Goal Achieved!",
        'bn': "🎉 দৈনিক লক্ষ্য অর্জিত!",
      },
      'remaining': {'en': "tasks left", 'bn': "টি টাস্ক বাকি"},
      'totalPoints': {'en': "Total Points", 'bn': "মোট পয়েন্ট"},
      'todayEarnings': {'en': "Today's Earnings", 'bn': "আজকের আয়"},
      'collectRewards': {'en': "Start Task", 'bn': "টাস্ক শুরু করুন"},
      'taskLoading': {'en': "🔄 Loading...", 'bn': "🔄 লোড হচ্ছে..."},
      'taskPreparing': {
        'en': "⚡ Preparing Task...",
        'bn': "⚡ টাস্ক প্রস্তুত হচ্ছে...",
      },
      'getReward': {
        'en': "🎯 Earn $_pointsPerReward Points",
        'bn': "🎯 $_pointsPerReward পয়েন্ট অর্জন করুন",
      },
      'dailyLimit': {'en': "✅ All Tasks Completed", 'bn': "✅ সব টাস্ক সম্পন্ন"},
      'taskDesc': {
        'en': "Complete short tasks to unlock amazing gifts",
        'bn': "সংক্ষিপ্ত টাস্ক সম্পন্ন করে আশ্চর্যজনক গিফট আনলক করুন",
      },
      'bonusPoints': {'en': "🚀 Boost Your Points", 'bn': "🚀 পয়েন্ট বাড়ান"},
      'playQuiz': {'en': "📚 Play Islamic Quiz", 'bn': "📚 ইসলামী কুইজ খেলুন"},
      'quizTip': {
        'en': "Enhance your Islamic knowledge while earning bonus rewards!",
        'bn': "ইসলামী জ্ঞান বাড়ান এবং বোনাস পুরস্কার অর্জন করুন!",
      },
      'nextReset': {'en': "🕐 Next Reset", 'bn': "🕐 পরবর্তী রিসেট"},
      'dailyOpportunity': {
        'en': "Complete $_maxDailyRewards tasks every day",
        'bn': "প্রতিদিন $_maxDailyRewards টি টাস্ক সম্পন্ন করুন",
      },
      'taskNotLoaded': {
        'en': "⏳ Task loading, please wait...",
        'bn': "⏳ টাস্ক লোড হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন...",
      },
      'maxTasksCompleted': {
        'en': "🎊 Amazing! You've completed all tasks today",
        'bn': "🎊 অসাধারণ! আপনি আজ সব টাস্ক সম্পন্ন করেছেন",
      },
      'taskError': {
        'en': "❌ Failed to load task",
        'bn': "❌ টাস্ক লোড করতে ব্যর্থ",
      },
      'pointsAdded': {
        'en':
            "🎉 +$_pointsPerReward Points! Progress: $_todayRewards/$_maxDailyRewards",
        'bn':
            "🎉 +$_pointsPerReward পয়েন্ট! অগ্রগতি: $_todayRewards/$_maxDailyRewards",
      },
      'pointsError': {
        'en': "⚠️ Points update failed",
        'bn': "⚠️ পয়েন্ট আপডেট ব্যর্থ",
      },
      'rewardNote': {
        'en': "🌟 Collect 5000 points to redeem exclusive Islamic gifts",
        'bn': "🌟 ৫০০০ পয়েন্ট সংগ্রহ করে এক্সক্লুসিভ ইসলামিক গিফট রিডিম করুন",
      },
      'completed': {'en': 'Completed', 'bn': 'সম্পন্ন'},
      'earned': {'en': 'Earned', 'bn': 'অর্জিত'},
    };
  }

  // Update texts when data changes
  void _updateTexts() {
    setState(() {
      _texts['getReward'] = {
        'en': "🎯 Earn $_pointsPerReward Points",
        'bn': "🎯 $_pointsPerReward পয়েন্ট অর্জন করুন",
      };
      _texts['pointsAdded'] = {
        'en':
            "🎉 +$_pointsPerReward Points! Progress: $_todayRewards/$_maxDailyRewards",
        'bn':
            "🎉 +$_pointsPerReward পয়েন্ট! অগ্রগতি: $_todayRewards/$_maxDailyRewards",
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
      _updateTexts();
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
      _showSnackBar(_text('taskNotLoaded'), _primaryColor(context));
      return;
    }

    if (_todayRewards >= _maxDailyRewards) {
      _showSnackBar(_text('maxTasksCompleted'), _successColor(context));
      return;
    }

    try {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          _addRewardPoints();
        },
      );
    } catch (e) {
      _showSnackBar(_text('taskError'), Colors.red);
    }
  }

  Future<void> _addRewardPoints() async {
    try {
      await PointManager.addPoints(_pointsPerReward);
      await PointManager.updateTodayRewards(_todayRewards + 1);
      await _loadUserData();

      _showSnackBar(
        _text('pointsAdded'),
        _successColor(context),
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
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      if (hours > 0) {
        return '$hours hr ${minutes} min';
      } else {
        return '$minutes min';
      }
    } else {
      if (hours > 0) {
        return '$hours ঘন্টা ${minutes} মিনিট';
      } else {
        return '$minutes মিনিট';
      }
    }
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _backgroundColor(context),
      appBar: AppBar(
        title: Text(
          _text('title'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: ThemeHelper.appBar(context),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadUserData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingShimmer(context)
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Premium Header Card
                    _buildPremiumHeaderCard(context),

                    const SizedBox(height: 20),

                    // Reward Note Card
                    _buildRewardNoteCard(context),

                    const SizedBox(height: 20),

                    // Stats Progress Section
                    _buildAdvancedTaskProgressBar(context),

                    const SizedBox(height: 20),

                    // Main Task Card
                    _buildMainTaskCard(context),

                    const SizedBox(height: 20),

                    // Quiz Section Card
                    _buildQuizSectionCard(context),

                    const SizedBox(height: 20),

                    // Info Card
                    _buildInfoCard(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: shimmerColor,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: shimmerColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: shimmerColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: shimmerColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: shimmerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeaderCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? AppColors.darkHeaderGradient
              : [_primaryColor(context), _secondaryColor(context)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor(context).withOpacity(isDarkMode ? 0.3 : 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Icon and Title Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: isSmallScreen ? 18 : 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Title - Responsive Text
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final title = _text('headerTitle');
                              final textStyle = TextStyle(
                                fontSize: isSmallScreen
                                    ? 16
                                    : (isTablet ? 22 : 20),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.3,
                              );

                              // Check if text fits in one line
                              final textPainter = TextPainter(
                                text: TextSpan(text: title, style: textStyle),
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                              )..layout(maxWidth: constraints.maxWidth);

                              if (textPainter.didExceedMaxLines) {
                                // If text is too long, use auto-size or ellipsis
                                return Text(
                                  title,
                                  style: textStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                );
                              } else {
                                // If text fits in one line
                                return Text(
                                  title,
                                  style: textStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 6),

                          // Subtitle - Responsive with smart truncation
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final subtitle = _text('headerSubtitle');
                              final textStyle = TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              );

                              return Text(
                                subtitle,
                                style: textStyle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Badge - Responsive
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: isSmallScreen ? 12 : 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "${_maxDailyRewards - _todayRewards} ${_text('remaining')}",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Additional Info for Tablet/Large Screens
                if (isTablet) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${_pointsPerReward} points per task",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: isSmallScreen ? 12 : 16),

          // Trophy Icon - Responsive
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: isSmallScreen ? 24 : 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardNoteCard(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkCard.withOpacity(0.6)
            : _accentColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? AppColors.darkBorder
              : _accentColor(context).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkBlueAccent.withOpacity(0.2)
                  : _accentColor(context).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: isDarkMode
                  ? AppColors.darkBlueAccent
                  : _accentColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _text('rewardNote'),
              style: TextStyle(
                fontSize: 14,
                color: _textColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTaskProgressBar(BuildContext context) {
    final completedTasks = _todayRewards;
    final totalTasks = _maxDailyRewards;
    final points = _pointsPerReward;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: _primaryColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _text('todayTasks'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textColor(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _primaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$completedTasks/$totalTasks",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Advanced 5-Segment Progress Bar
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkSurface.withOpacity(0.5)
                  : _backgroundColor(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _primaryColor(context).withOpacity(0.1),
              ),
            ),
            child: Row(
              children: List.generate(totalTasks, (index) {
                final isCompleted = index < completedTasks;
                final isCurrent = index == completedTasks;
                final taskNumber = index + 1;

                return Expanded(
                  child: _buildTaskSegment(
                    context: context,
                    taskNumber: taskNumber,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    points: points,
                    isLast: index == totalTasks - 1,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // Progress Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                icon: Icons.check_circle_rounded,
                value: completedTasks,
                label: _text('completed'),
                color: _successColor(context),
                context: context,
              ),
              _buildProgressStat(
                icon: Icons.pending_actions_rounded,
                value: totalTasks - completedTasks,
                label: _text('remaining'),
                color: _warningColor(context),
                context: context,
              ),
              _buildProgressStat(
                icon: Icons.emoji_events_rounded,
                value: completedTasks * points,
                label: _text('earned'),
                color: _accentColor(context),
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Individual Task Segment Widget
  Widget _buildTaskSegment({
    required BuildContext context,
    required int taskNumber,
    required bool isCompleted,
    required bool isCurrent,
    required int points,
    required bool isLast,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(right: isLast ? 0 : 4),
      decoration: BoxDecoration(
        color: _getSegmentColor(context, isCompleted, isCurrent),
        borderRadius: _getSegmentBorderRadius(isLast),
      ),
      child: Stack(
        children: [
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Task Number Icon
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getIconColor(isCompleted, isCurrent, context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getIconBorderColor(
                        isCompleted,
                        isCurrent,
                        context,
                      ),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : Text(
                            '$taskNumber',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _getTextColor(
                                isCompleted,
                                isCurrent,
                                context,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),

                // Points Label
                Text(
                  '+$points',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _getPointsTextColor(isCompleted, isCurrent, context),
                  ),
                ),
              ],
            ),
          ),

          // Progress Animation
          if (isCompleted)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkText : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  size: 10,
                  color: _accentColor(context),
                ),
              ),
            ),

          // Current Task Indicator
          if (isCurrent && !isCompleted)
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor(context), _secondaryColor(context)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods for segment styling
  Color _getSegmentColor(
    BuildContext context,
    bool isCompleted,
    bool isCurrent,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isCompleted) {
      return _successColor(context).withOpacity(0.15);
    } else if (isCurrent) {
      return _primaryColor(context).withOpacity(0.1);
    } else {
      return isDarkMode
          ? AppColors.darkSurface.withOpacity(0.3)
          : _backgroundColor(context).withOpacity(0.5);
    }
  }

  Color _getIconColor(bool isCompleted, bool isCurrent, BuildContext context) {
    if (isCompleted) {
      return _successColor(context);
    } else if (isCurrent) {
      return _primaryColor(context);
    } else {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return isDarkMode
          ? AppColors.darkTextSecondary
          : Colors.grey.withOpacity(0.3);
    }
  }

  Color _getIconBorderColor(
    bool isCompleted,
    bool isCurrent,
    BuildContext context,
  ) {
    if (isCompleted) {
      return _successColor(context).withOpacity(0.5);
    } else if (isCurrent) {
      return _primaryColor(context).withOpacity(0.5);
    } else {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return isDarkMode ? AppColors.darkBorder : Colors.grey.withOpacity(0.2);
    }
  }

  Color _getTextColor(bool isCompleted, bool isCurrent, BuildContext context) {
    if (isCompleted) {
      return Colors.white;
    } else if (isCurrent) {
      return _primaryColor(context);
    } else {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return isDarkMode
          ? AppColors.darkTextSecondary
          : Colors.grey.withOpacity(0.5);
    }
  }

  Color _getPointsTextColor(
    bool isCompleted,
    bool isCurrent,
    BuildContext context,
  ) {
    if (isCompleted) {
      return _successColor(context);
    } else if (isCurrent) {
      return _primaryColor(context);
    } else {
      return _subtitleColor(context);
    }
  }

  BorderRadius _getSegmentBorderRadius(bool isLast) {
    if (isLast) {
      return const BorderRadius.horizontal(right: Radius.circular(8));
    } else {
      return const BorderRadius.horizontal(left: Radius.circular(8));
    }
  }

  // Progress Stat Widget
  Widget _buildProgressStat({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
    required BuildContext context,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _subtitleColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTaskCard(BuildContext context) {
    final isMaxReached = _todayRewards >= _maxDailyRewards;
    final isDisabled = isMaxReached || _isLoadingAd || !_isRewardedAdLoaded;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: _primaryColor(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _text('collectRewards'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Task Button
          Container(
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? null
                  : LinearGradient(
                      colors: [
                        _primaryColor(context),
                        _secondaryColor(context),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: _primaryColor(context).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Material(
              color: isDisabled
                  ? (isDarkMode
                        ? AppColors.darkSurface
                        : Colors.grey.withOpacity(0.2))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: isDisabled ? null : _showRewardedAd,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoadingAd)
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(
                          isMaxReached
                              ? Icons.check_circle_rounded
                              : Icons.play_arrow_rounded,
                          size: 28,
                          color: isDisabled
                              ? (isDarkMode
                                    ? AppColors.darkTextSecondary
                                    : Colors.grey)
                              : Colors.white,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isLoadingAd
                            ? Text(
                                _text('taskLoading'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDisabled
                                      ? (isDarkMode
                                            ? AppColors.darkTextSecondary
                                            : Colors.grey)
                                      : Colors.white,
                                ),
                              )
                            : !_isRewardedAdLoaded
                            ? Text(
                                _text('taskPreparing'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDisabled
                                      ? (isDarkMode
                                            ? AppColors.darkTextSecondary
                                            : Colors.grey)
                                      : Colors.white,
                                ),
                              )
                            : isMaxReached
                            ? Text(
                                _text('dailyLimit'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDisabled
                                      ? (isDarkMode
                                            ? AppColors.darkTextSecondary
                                            : Colors.grey)
                                      : Colors.white,
                                ),
                              )
                            : Text(
                                _text('getReward'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      if (!isDisabled && !_isLoadingAd)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "+$_pointsPerReward",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _text('taskDesc'),
            style: TextStyle(
              fontSize: 13,
              color: _subtitleColor(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSectionCard(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  AppColors.darkSurface.withOpacity(0.8),
                  AppColors.darkCard.withOpacity(0.6),
                ]
              : [
                  _accentColor(context).withOpacity(0.1),
                  _accentColor(context).withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? AppColors.darkBorder
              : _accentColor(context).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.darkBlueAccent.withOpacity(0.2)
                      : _accentColor(context).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: isDarkMode
                      ? AppColors.darkBlueAccent
                      : _accentColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _text('bonusPoints'),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode
                      ? AppColors.darkBlueAccent
                      : _accentColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _text('quizTip'),
            style: TextStyle(
              fontSize: 14,
              color: _subtitleColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        AppColors.darkBlueAccent,
                        AppColors.darkBlueAccent.withOpacity(0.7),
                      ]
                    : [
                        _accentColor(context),
                        _accentColor(context).withOpacity(0.8),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color:
                      (isDarkMode
                              ? AppColors.darkBlueAccent
                              : _accentColor(context))
                          .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.quiz_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _text('playQuiz'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkSurface.withOpacity(0.6)
            : _primaryColor(context).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? AppColors.darkBorder
              : _primaryColor(context).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkPrimary.withOpacity(0.2)
                  : _primaryColor(context).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: isDarkMode
                  ? AppColors.darkPrimary
                  : _primaryColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${_text('nextReset')}: ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textColor(context),
                        ),
                      ),
                      TextSpan(
                        text: _nextResetTime,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode
                              ? AppColors.darkPrimary
                              : _primaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _text('dailyOpportunity'),
                  style: TextStyle(
                    fontSize: 12,
                    color: _subtitleColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
