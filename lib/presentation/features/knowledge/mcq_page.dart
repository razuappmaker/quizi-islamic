// mcq_page.dart - PRODUCTION READY FINAL VERSION
// Author: Islamic Quiz App Development Team
// Version: 1.0.0
// Last Updated: 2024

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamicquiz/core/managers/point_manager.dart';
import '../../screens/result_page.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/ad_helper.dart';
import '../../../core/managers/mcq_security_manager.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../../core/constants/app_colors.dart';

/// Main MCQ Quiz Page - Handles the complete quiz experience including:
/// - Question display and navigation
/// - Answer checking and scoring
/// - Timer management
/// - Multi-language support
/// - Ad integration
/// - Points and statistics tracking
class MCQPage extends StatefulWidget {
  final String category;
  final String quizId;

  const MCQPage({required this.category, required this.quizId, Key? key})
    : super(key: key);

  @override
  State<MCQPage> createState() => _MCQPageState();
}

class _MCQPageState extends State<MCQPage> with WidgetsBindingObserver {
  // ==================== MULTI-LANGUAGE TEXT DICTIONARY ====================
  static const Map<String, Map<String, String>> _texts = {
    'questionProgress': {'en': 'Question', 'bn': 'প্রশ্ন'},
    'time': {'en': 'Time', 'bn': 'সময়'},
    'seconds': {'en': 'seconds', 'bn': 'সেকেন্ড'},
    'questionLabel': {'en': 'Question:', 'bn': 'প্রশ্ন:'},
    'nextQuestion': {'en': 'Next Question', 'bn': 'পরবর্তী প্রশ্ন'},
    'viewResults': {'en': 'View Results', 'bn': 'ফলাফল দেখুন'},
    'verifyAnswer': {'en': 'To verify the answer', 'bn': 'উত্তরটি যাচাই করতে'},
    'searchGoogle': {'en': 'Search on Google', 'bn': 'গুগলে তথ্য যাচাই করুন'},
    'timeUp': {'en': 'Time Up', 'bn': 'সময় শেষ'},
    'timeUpMessage': {
      'en': 'You could not answer in time.',
      'bn': 'আপনি সময়মতো উত্তর দিতে পারেননি।',
    },
    'pointsEarned': {'en': 'points', 'bn': 'পয়েন্ট'},
    'loadingQuiz': {'en': 'Loading quiz...', 'bn': 'কুইজ লোড হচ্ছে...'},
    'loadingQuestions': {
      'en': 'Loading questions...',
      'bn': 'প্রশ্নগুলি লোড হচ্ছে...',
    },
    'pleaseWait': {'en': 'Please Wait', 'bn': 'অপেক্ষা করুন'},
    'ok': {'en': 'OK', 'bn': 'ঠিক আছে'},
  };

  /// Returns translated text based on current language setting
  String _text(String key, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

  // ==================== QUIZ MANAGEMENT ====================
  final MCQSecurityManager _securityManager = MCQSecurityManager();

  // ==================== UI STATE VARIABLES ====================
  int currentQuestionIndex = 0;
  bool isAnswered = false;
  String? selectedOption;
  int _timeLeft = 20;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Orientation _currentOrientation = Orientation.portrait;

  // ==================== ADVERTISEMENT MANAGEMENT ====================
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _hasShownHalfwayAd = false;
  bool _hasShownFinalAd = false;

  // ==================== POINTS NOTIFICATION SYSTEM ====================
  bool _showPointsNotification = false;
  Timer? _pointsNotificationTimer;
  int _earnedPointsForNotification = 0;

  // ==================== UI CONSTANTS (Responsive Design) ====================
  static const double _optionCardMinHeight = 39.6;
  static const double _optionCardMaxHeight = 52.8;
  static const double _optionCardHeightFactor = 0.055;
  static const double _optionCardMarginBottom = 8.8;
  static const double _optionCardBorderRadius = 13.2;
  static const double _optionFontSize = 15.4;
  static const double _optionSelectedBorderWidth = 1.65;
  static const double _optionCardPaddingRatioVertical = 0.165;
  static const double _optionCardPaddingRatioHorizontal = 0.22;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer.setVolume(1.0);
    _initializeQuiz();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelAllTimers();
    _audioPlayer.dispose();
    _bannerAd?.dispose();
    AdHelper.disposeInterstitialAd();
    _securityManager.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final newOrientation = MediaQuery.of(context).orientation;
    if (newOrientation != _currentOrientation) {
      _currentOrientation = newOrientation;
      _reloadBannerOnOrientationChange();
    }
  }

  // ==================== TIMER MANAGEMENT ====================

  /// Starts the countdown timer for the current question
  void startTimer() {
    _timer?.cancel();
    _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
        showTimeUpDialog();
      }
    });
  }

  /// Cancels all active timers to prevent memory leaks
  void _cancelAllTimers() {
    _timer?.cancel();
    _timer = null;
    _pointsNotificationTimer?.cancel();
    _pointsNotificationTimer = null;
  }

  // ==================== AUDIO FEEDBACK SYSTEM ====================

  /// Plays correct answer sound effect
  void playCorrectSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print('Audio play error: $e');
    }
  }

  /// Plays wrong answer sound effect
  void playWrongSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      print('Audio play error: $e');
    }
  }

  // ==================== ANSWER HANDLING & VALIDATION ====================

  /// Checks the user's selected answer and updates scores
  /// [selected] - The option selected by the user
  void checkAnswer(String selected) {
    if (isAnswered || !_securityManager.quizStarted || !mounted) return;

    final result = _securityManager.checkAnswer(
      selected: selected,
      currentQuestionIndex: currentQuestionIndex,
      timeLeft: _timeLeft,
    );

    setState(() {
      selectedOption = selected;
      isAnswered = true;
      _earnedPointsForNotification = result.earnedPoints;
    });

    // Provide audio feedback
    if (result.isCorrect) {
      playCorrectSound();
    } else {
      playWrongSound();
    }

    // Show points earned notification
    _showPointsEarnedNotification(result.earnedPoints);
  }

  /// Navigates to the next question or results page
  void goToNextQuestion() {
    if (!_securityManager.quizStarted || !mounted) return;

    _timer?.cancel();

    setState(() {
      _earnedPointsForNotification = 0;
    });

    final bool isLastQuestion =
        currentQuestionIndex >= _securityManager.questions.length - 1;

    if (!isLastQuestion) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedOption = null;
        _timeLeft = 20;
      });
      startTimer();
    } else {
      // Update final statistics and navigate to results
      _securityManager.updateFinalStats();

      // Show final ad before navigation
      if (!_hasShownFinalAd) {
        _hasShownFinalAd = true;
        _showAdThenNavigate();
      } else {
        _navigateToResult();
      }
    }
  }

  // ==================== ADVERTISEMENT MANAGEMENT ====================

  /// Reloads banner ad when orientation changes
  Future<void> _reloadBannerOnOrientationChange() async {
    if (_isBannerAdReady && _bannerAd != null) {
      _bannerAd?.dispose();
      _isBannerAdReady = false;
      await _loadAdaptiveBanner();
    }
  }

  /// Loads adaptive banner ad with fallback handling
  Future<void> _loadAdaptiveBanner() async {
    try {
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('Banner ad limit reached, not showing ad');
        return;
      }

      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (!mounted) return;
            setState(() => _isBannerAdReady = true);
            AdHelper.recordBannerAdShown();
            print('Banner ad loaded successfully');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Banner ad failed to load: $error');
            ad.dispose();
            if (mounted) {
              setState(() => _isBannerAdReady = false);
            }
            _loadRegularBanner();
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Banner ad clicked');
              } else {
                print('Ad click limit reached');
              }
            });
          },
        ),
        orientation: _currentOrientation,
      );

      await _bannerAd?.load();
    } catch (e) {
      print('Error loading adaptive banner: $e');
      _loadRegularBanner();
    }
  }

  /// Fallback method for loading regular banner ad
  void _loadRegularBanner() {
    try {
      _bannerAd = AdHelper.createBannerAd(
        AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (!mounted) return;
            setState(() => _isBannerAdReady = true);
            AdHelper.recordBannerAdShown();
            print('Regular banner ad loaded successfully');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Regular banner ad failed to load: $error');
            ad.dispose();
            if (mounted) {
              setState(() => _isBannerAdReady = false);
            }
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Banner ad clicked');
              } else {
                print('Ad click limit reached');
              }
            });
          },
        ),
      );

      _bannerAd?.load();
    } catch (e) {
      print('Error loading regular banner: $e');
    }
  }

  /// Shows interstitial ad at halfway point
  void _showInterstitialAd() {
    AdHelper.showInterstitialAd(
      onAdShowed: () {
        print('Halfway interstitial ad shown');
      },
      onAdDismissed: () {
        print('Interstitial ad dismissed');
        AdHelper.loadInterstitialAd();
      },
      onAdFailedToShow: () {
        print('Halfway interstitial ad failed to show');
        AdHelper.loadInterstitialAd();
      },
      adContext: 'MCQPage_Halfway',
    );
  }

  /// Shows interstitial ad before navigating to results
  void _showAdThenNavigate() {
    AdHelper.showInterstitialAd(
      onAdShowed: () {
        print('Final interstitial ad shown');
      },
      onAdDismissed: () {
        if (mounted) {
          _navigateToResult();
        }
        AdHelper.loadInterstitialAd();
      },
      onAdFailedToShow: () {
        if (mounted) {
          _navigateToResult();
        }
        AdHelper.loadInterstitialAd();
      },
      adContext: 'MCQPage_Final',
    );
  }

  // ==================== NAVIGATION & DIALOG MANAGEMENT ====================

  /// Navigates to results page with quiz statistics
  void _navigateToResult() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          total: _securityManager.questions.length,
          correct: _securityManager.score,
          totalPoints: _securityManager.calculateTotalPoints(),
        ),
      ),
    );
  }

  /// Shows time up dialog when timer expires
  void showTimeUpDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeHelper.card(context),
        title: Text(
          _text('timeUp', context),
          style: TextStyle(color: ThemeHelper.text(context)),
        ),
        content: Text(
          _text('timeUpMessage', context),
          style: TextStyle(color: ThemeHelper.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              goToNextQuestion();
            },
            child: Text(
              _text('nextQuestion', context),
              style: TextStyle(color: ThemeHelper.primary(context)),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles back button press with confirmation
  Future<bool> _onWillPop() async {
    if (!mounted) return true;

    Navigator.of(context).pop();
    return false;
  }

  // ==================== POINTS NOTIFICATION SYSTEM ====================

  /// Shows temporary points earned notification
  void _showPointsEarnedNotification(int points) {
    if (!mounted) return;

    setState(() {
      _showPointsNotification = true;
      _earnedPointsForNotification = points;
    });

    _pointsNotificationTimer?.cancel();
    _pointsNotificationTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showPointsNotification = false;
        });
      }
    });
  }

  // ==================== MAIN UI BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isTablet = screenWidth > 600;
    final bool isSmallPhone = screenHeight < 600 || screenWidth < 360;
    final double responsiveFontSize = screenWidth < 360
        ? 12.0
        : screenWidth < 400
        ? 15.4
        : 16.5;

    // Loading state
    if (!_securityManager.quizStarted) {
      return _buildLoadingScreen();
    }

    if (_securityManager.questions.isEmpty) {
      return _buildErrorScreen();
    }

    var question = _securityManager.questions[currentQuestionIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: ThemeHelper.background(context),
        appBar: AppBar(
          title: Text(
            '${_text('questionProgress', context)} ${currentQuestionIndex + 1}/${_securityManager.questions.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth < 360 ? 14 : 17.6,
              color: Colors.white,
            ),
          ),
          backgroundColor: ThemeHelper.appBar(context),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => _onWillPop(),
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(screenWidth * 0.033),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Progress Bar Section
                          _buildProgressSection(
                            context,
                            screenWidth,
                            screenHeight,
                            responsiveFontSize,
                            isTablet,
                          ),

                          SizedBox(height: screenHeight * 0.022),

                          // Question Image
                          if (question['image'] != null)
                            _buildQuestionImage(question, screenHeight),

                          // Question Container
                          _buildQuestionContainer(
                            question,
                            isTablet,
                            isSmallPhone,
                            screenHeight,
                            screenWidth,
                            responsiveFontSize,
                          ),

                          SizedBox(height: screenHeight * 0.022),

                          // Options Section
                          _buildOptionsSection(
                            question,
                            screenHeight,
                            screenWidth,
                            isTablet,
                            isSmallPhone,
                            responsiveFontSize,
                          ),

                          SizedBox(height: screenHeight * 0.022),

                          // Next Button
                          _buildNextButton(
                            screenHeight,
                            responsiveFontSize,
                            context,
                          ),

                          SizedBox(height: screenHeight * 0.022),

                          // Google Search Button
                          if (isAnswered)
                            _buildGoogleSearchButton(
                              screenHeight,
                              screenWidth,
                              responsiveFontSize,
                              question,
                              context,
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Banner Ad
                  if (_isBannerAdReady && _bannerAd != null)
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                ],
              ),
            ),

            // Points Notification Overlay
            if (_showPointsNotification)
              _buildPointsNotification(
                screenWidth,
                screenHeight,
                responsiveFontSize,
                question,
                context,
              ),
          ],
        ),
      ),
    );
  }

  // ==================== QUIZ INITIALIZATION ====================

  /// Initializes the quiz with security checks and question loading
  Future<void> _initializeQuiz() async {
    try {
      // Set language for PointManager
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      await PointManager().setLanguage(languageProvider.currentLanguage);

      // Reset quiz statistics for new session
      await _securityManager.resetQuizStats();

      await _securityManager.initialize(
        category: widget.category,
        quizId: widget.quizId,
        context: context,
      );

      AdHelper.loadInterstitialAd();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAdaptiveBanner();
      });

      if (_securityManager.questions.isNotEmpty &&
          _securityManager.quizStarted) {
        startTimer();
      }
    } catch (e) {
      print('❌ Quiz initialization error: $e');
      _showErrorDialog(e.toString(), context);
    }
  }

  /// Shows error dialog with retry option
  void _showErrorDialog(String message, BuildContext context) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: ThemeHelper.card(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ThemeHelper.primary(context).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: ThemeHelper.primary(context).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hourglass_top_rounded,
                        color: ThemeHelper.primary(context),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _text('pleaseWait', context),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.primary(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: ThemeHelper.text(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),

                    // Progress Indicator
                    SizedBox(
                      height: 4,
                      child: LinearProgressIndicator(
                        backgroundColor: ThemeHelper.textSecondary(
                          context,
                        ).withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeHelper.primary(context),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),

              // Button Section
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: ThemeHelper.background(context),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeHelper.primary(context),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          _text('ok', context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // ==================== UI COMPONENT BUILDERS ====================

  /// Builds loading screen while quiz initializes
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: ThemeHelper.background(context),
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeHelper.appBar(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelper.primary(context),
              ),
            ),
            const SizedBox(height: 13.2),
            Text(
              _text('loadingQuiz', context),
              style: TextStyle(
                color: ThemeHelper.text(context),
                fontSize: 15.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds error screen when questions fail to load
  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: ThemeHelper.background(context),
      appBar: AppBar(
        title: Text(
          _text('loadingQuiz', context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeHelper.appBar(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelper.primary(context),
              ),
            ),
            const SizedBox(height: 13.2),
            Text(
              _text('loadingQuestions', context),
              style: TextStyle(
                fontSize: 15.4,
                color: ThemeHelper.text(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds progress section with question counter and timer
  Widget _buildProgressSection(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    double responsiveFontSize,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.0165,
        horizontal: screenWidth * 0.033,
      ),
      decoration: BoxDecoration(
        color: ThemeHelper.card(context),
        borderRadius: BorderRadius.circular(13.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.6,
            offset: const Offset(0, 2.2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 13.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_text('questionProgress', context)} ${currentQuestionIndex + 1}',
                        style: TextStyle(
                          fontSize: responsiveFontSize,
                          fontWeight: FontWeight.bold,
                          color: ThemeHelper.text(context),
                        ),
                      ),
                      Text(
                        '${((currentQuestionIndex + 1) / _securityManager.questions.length * 100).toStringAsFixed(0)}% of ${_securityManager.questions.length}',
                        style: TextStyle(
                          fontSize: responsiveFontSize - 1,
                          color: ThemeHelper.primary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 3.3,
                  decoration: BoxDecoration(
                    color: ThemeHelper.textSecondary(context).withOpacity(0.3),
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width:
                            MediaQuery.of(context).size.width *
                            ((currentQuestionIndex + 1) /
                                _securityManager.questions.length),
                        decoration: BoxDecoration(
                          color: ThemeHelper.primary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildTimerSection(
            screenHeight,
            screenWidth,
            isTablet,
            responsiveFontSize,
            context,
          ),
        ],
      ),
    );
  }

  /// Builds timer section with circular progress indicator
  Widget _buildTimerSection(
    double screenHeight,
    double screenWidth,
    bool isTablet,
    double responsiveFontSize,
    BuildContext context,
  ) {
    final primaryColor = ThemeHelper.primary(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.0088,
        horizontal: screenWidth * 0.0275,
      ),
      decoration: BoxDecoration(
        color: _timeLeft <= 10
            ? Colors.red.withOpacity(0.06)
            : primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8.8),
        border: Border.all(
          color: _timeLeft <= 10
              ? Colors.red.withOpacity(0.15)
              : primaryColor.withOpacity(0.1),
          width: 0.88,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: _timeLeft <= 10 ? Colors.red : primaryColor,
                size: isTablet ? responsiveFontSize + 2 : responsiveFontSize,
              ),
              const SizedBox(width: 6.6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _text('time', context),
                    style: TextStyle(
                      fontSize: isTablet
                          ? responsiveFontSize - 2
                          : responsiveFontSize - 5,
                      color: ThemeHelper.textSecondary(context),
                    ),
                  ),
                  Text(
                    '$_timeLeft ${_text('seconds', context)}',
                    style: TextStyle(
                      fontSize: isTablet
                          ? responsiveFontSize
                          : responsiveFontSize - 2,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 10 ? Colors.red : primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: isTablet ? 35.2 : 28.6,
            height: isTablet ? 35.2 : 28.6,
            child: CircularProgressIndicator(
              value: _timeLeft / 20.0,
              strokeWidth: _timeLeft <= 10
                  ? (isTablet ? 5.5 : 4.4)
                  : (isTablet ? 4.4 : 3.3),
              backgroundColor: ThemeHelper.textSecondary(
                context,
              ).withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _timeLeft <= 10 ? Colors.red : primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds question image container
  Widget _buildQuestionImage(dynamic question, double screenHeight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.4,
            offset: const Offset(0, 2.2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.asset(
          'assets/images/${question['image']}',
          height: screenHeight * 0.165,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: screenHeight * 0.165,
              color: ThemeHelper.card(context),
              child: Icon(
                Icons.error_outline,
                color: ThemeHelper.textSecondary(context),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds question text container
  Widget _buildQuestionContainer(
    dynamic question,
    bool isTablet,
    bool isSmallPhone,
    double screenHeight,
    double screenWidth,
    double responsiveFontSize,
  ) {
    final bool isLargeScreen = isTablet || screenHeight > 700;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet
            ? screenHeight * 0.0198 * (isLargeScreen ? 1.25 : 1.0)
            : isSmallPhone
            ? screenHeight * 0.012
            : screenHeight * 0.0165 * (isLargeScreen ? 1.25 : 1.0),
        horizontal: isTablet
            ? screenWidth * 0.044
            : isSmallPhone
            ? screenWidth * 0.03
            : screenWidth * 0.0385,
      ),
      decoration: BoxDecoration(
        color: ThemeHelper.card(context),
        borderRadius: BorderRadius.circular(
          isTablet
              ? 13.2
              : isSmallPhone
              ? 8
              : 11,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.6,
            offset: const Offset(0, 2.2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 13.2 : (isSmallPhone ? 8 : 11),
              vertical: isTablet ? 6.6 : (isSmallPhone ? 4 : 5.5),
            ),
            margin: EdgeInsets.only(
              right: isTablet ? 17.6 : (isSmallPhone ? 10 : 13.2),
            ),
            decoration: BoxDecoration(
              color: ThemeHelper.primary(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.4,
                  offset: const Offset(0, 1.1),
                ),
              ],
            ),
            child: Text(
              _text('questionLabel', context),
              style: TextStyle(
                fontSize: isTablet
                    ? responsiveFontSize + 1
                    : isSmallPhone
                    ? responsiveFontSize - 1
                    : responsiveFontSize,
                fontWeight: FontWeight.w700,
                color: ThemeHelper.primary(context),
                height: isTablet
                    ? 1.4
                    : isSmallPhone
                    ? 1.2
                    : 1.3,
              ),
            ),
          ),
          Expanded(
            child: Text(
              question['question'] ?? 'Question not loaded',
              style: TextStyle(
                fontSize: isTablet
                    ? responsiveFontSize + 0.2
                    : isSmallPhone
                    ? responsiveFontSize - 3
                    : responsiveFontSize - 1,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.text(context),
                height: isTablet
                    ? 1.4
                    : isSmallPhone
                    ? 1.2
                    : 1.3,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds options section with dynamic layout
  Widget _buildOptionsSection(
    dynamic question,
    double screenHeight,
    double screenWidth,
    bool isTablet,
    bool isSmallPhone,
    double responsiveFontSize,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final bool isEnglish = languageProvider.isEnglish;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = constraints.maxHeight;
        final double screenWidth = MediaQuery.of(context).size.width;

        final bool isTablet = screenWidth > 600;
        final bool isSmallPhone = screenHeight < 600 || screenWidth < 360;
        final bool isLargePhone = screenHeight > 700 && screenWidth > 400;
        final bool isLargeScreen = isTablet || isLargePhone;

        final double optionCardHeight = math.max(
          isTablet
              ? _optionCardMinHeight * 0.8 * (isLargeScreen ? 1.25 : 1.0) * 1.1
              : isSmallPhone
              ? 32.0
              : isLargePhone
              ? _optionCardMinHeight * 0.75 * (isLargeScreen ? 1.25 : 1.0) * 1.1
              : _optionCardMinHeight * 0.7 * 1.1,
          math.min(
            screenHeight *
                (isTablet
                    ? _optionCardHeightFactor *
                          0.7 *
                          (isLargeScreen ? 1.25 : 1.0) *
                          1.1
                    : isSmallPhone
                    ? 0.04
                    : isLargePhone
                    ? _optionCardHeightFactor *
                          0.6 *
                          (isLargeScreen ? 1.25 : 1.0) *
                          1.1
                    : _optionCardHeightFactor * 0.5 * 1.1),
            isTablet
                ? _optionCardMaxHeight *
                      0.8 *
                      (isLargeScreen ? 1.25 : 1.0) *
                      1.1
                : isSmallPhone
                ? 40.0
                : isLargePhone
                ? _optionCardMaxHeight *
                      0.75 *
                      (isLargeScreen ? 1.25 : 1.0) *
                      1.1
                : _optionCardMaxHeight * 0.7 * 1.1,
          ),
        );

        final double optionFontSize = isTablet
            ? _optionFontSize * 0.9
            : isSmallPhone
            ? _optionFontSize * 0.75
            : isLargePhone
            ? _optionFontSize * 0.85
            : _optionFontSize * 0.8;

        final List<dynamic> options = question['options'] ?? [];

        return Column(
          children: options.asMap().entries.map((entry) {
            final int index = entry.key;
            final String option = entry.value as String;

            final double verticalPadding =
                optionCardHeight *
                (isSmallPhone ? 0.12 : _optionCardPaddingRatioVertical);
            final double horizontalPadding =
                optionCardHeight *
                (isSmallPhone ? 0.15 : _optionCardPaddingRatioHorizontal);

            Color optionColor = ThemeHelper.card(context);
            Color textColor = ThemeHelper.text(context);
            BoxBorder? border;
            Color? shadowColor;

            if (isAnswered) {
              if (option == question['answer']) {
                optionColor = Colors.green.withOpacity(0.16);
                textColor = Colors.green[700]!;
                border = Border.all(
                  color: Colors.green,
                  width: _optionSelectedBorderWidth,
                );
              } else if (option == selectedOption) {
                optionColor = Colors.red.withOpacity(0.16);
                textColor = Colors.red[700]!;
                border = Border.all(
                  color: Colors.red,
                  width: _optionSelectedBorderWidth,
                );
              }
            } else {
              shadowColor = Colors.black.withOpacity(0.06);
            }

            return Container(
              margin: EdgeInsets.only(
                bottom: isTablet
                    ? _optionCardMarginBottom * 0.9
                    : isSmallPhone
                    ? _optionCardMarginBottom * 0.6
                    : _optionCardMarginBottom * 0.75,
              ),
              height: optionCardHeight,
              child: Material(
                elevation: isAnswered
                    ? 0
                    : (isTablet ? 1.2 : (isSmallPhone ? 0.4 : 0.8)),
                color: optionColor,
                borderRadius: BorderRadius.circular(_optionCardBorderRadius),
                shadowColor: shadowColor,
                surfaceTintColor: Colors.transparent,
                child: InkWell(
                  onTap: () => checkAnswer(option),
                  borderRadius: BorderRadius.circular(_optionCardBorderRadius),
                  splashColor: isAnswered
                      ? Colors.transparent
                      : ThemeHelper.primary(context).withOpacity(0.1),
                  highlightColor: isAnswered
                      ? Colors.transparent
                      : ThemeHelper.primary(context).withOpacity(0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      vertical: verticalPadding,
                      horizontal: horizontalPadding,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        _optionCardBorderRadius,
                      ),
                      border: border,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: isSmallPhone ? 20 : (isTablet ? 26 : 22),
                          height: isSmallPhone ? 20 : (isTablet ? 26 : 22),
                          margin: EdgeInsets.only(
                            right: isSmallPhone ? 8 : (isTablet ? 12 : 10),
                          ),
                          decoration: BoxDecoration(
                            color: isAnswered
                                ? (option == question['answer']
                                      ? Colors.green.withOpacity(0.1)
                                      : option == selectedOption
                                      ? Colors.red.withOpacity(0.1)
                                      : ThemeHelper.background(context))
                                : ThemeHelper.background(context),
                            borderRadius: BorderRadius.circular(
                              isSmallPhone ? 5 : 6,
                            ),
                            border: isAnswered && option == question['answer']
                                ? Border.all(color: Colors.green, width: 1.2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              isEnglish
                                  ? ['A', 'B', 'C', 'D'][index]
                                  : ['ক', 'খ', 'গ', 'ঘ'][index],
                              style: TextStyle(
                                fontSize: isSmallPhone
                                    ? 10
                                    : (isTablet ? 12 : 11),
                                fontWeight: FontWeight.w600,
                                color: isAnswered
                                    ? (option == question['answer']
                                          ? Colors.green
                                          : option == selectedOption
                                          ? Colors.red
                                          : ThemeHelper.textSecondary(context))
                                    : ThemeHelper.text(context),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: optionFontSize,
                                color: textColor,
                                fontWeight:
                                    isAnswered && option == question['answer']
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                height: isSmallPhone
                                    ? 1.1
                                    : (isTablet ? 1.25 : 1.2),
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (isAnswered)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: isAnswered ? 1.0 : 0.0,
                            child: Icon(
                              option == question['answer']
                                  ? Icons.check_circle_rounded
                                  : option == selectedOption
                                  ? Icons.cancel_rounded
                                  : Icons.circle_outlined,
                              size: isSmallPhone ? 14 : (isTablet ? 18 : 16),
                              color: option == question['answer']
                                  ? Colors.green
                                  : option == selectedOption
                                  ? Colors.red
                                  : Colors.transparent,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Builds next question/results button
  Widget _buildNextButton(
    double screenHeight,
    double responsiveFontSize,
    BuildContext context,
  ) {
    final bool isLargeScreen =
        MediaQuery.of(context).size.width > 600 ||
        MediaQuery.of(context).size.height > 700;

    final double buttonHeight =
        screenHeight * 0.066 * (isLargeScreen ? 0.9 : 1.0);

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isAnswered ? goToNextQuestion : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeHelper.primary(context),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          elevation: 3.3,
          textStyle: TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.bold,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.8, vertical: 4.4),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            currentQuestionIndex < _securityManager.questions.length - 1
                ? _text('nextQuestion', context)
                : _text('viewResults', context),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Builds Google search button for answer verification
  Widget _buildGoogleSearchButton(
    double screenHeight,
    double screenWidth,
    double responsiveFontSize,
    dynamic question,
    BuildContext context,
  ) {
    final blueAccent = AppColors.getAccentColor(
      'blue',
      Theme.of(context).brightness == Brightness.dark,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 13.2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.6),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: ThemeHelper.textSecondary(context).withOpacity(0.3),
                    thickness: 1.1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  child: Text(
                    _text('verifyAnswer', context),
                    style: TextStyle(
                      fontSize: responsiveFontSize - 4,
                      fontWeight: FontWeight.w500,
                      color: ThemeHelper.textSecondary(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: ThemeHelper.textSecondary(context).withOpacity(0.3),
                    thickness: 1.1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.0495,
            child: OutlinedButton.icon(
              onPressed: () => _securityManager.searchOnGoogle(
                context: context,
                question: question['question'] ?? '',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: blueAccent,
                side: BorderSide(color: blueAccent, width: 1.32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.8),
                ),
                backgroundColor: blueAccent.withOpacity(0.1),
                textStyle: TextStyle(
                  fontSize: responsiveFontSize - 2,
                  fontWeight: FontWeight.w600,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.033,
                  vertical: screenHeight * 0.0132,
                ),
              ),
              icon: Icon(
                Icons.search,
                size: responsiveFontSize - 1,
                color: blueAccent,
              ),
              label: Text(_text('searchGoogle', context)),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds points earned notification overlay
  Widget _buildPointsNotification(
    double screenWidth,
    double screenHeight,
    double responsiveFontSize,
    dynamic question,
    BuildContext context,
  ) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 66,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.11),
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.011,
            horizontal: screenWidth * 0.055,
          ),
          decoration: BoxDecoration(
            color: selectedOption == question['answer']
                ? Colors.green.withOpacity(0.9)
                : Colors.orange.withOpacity(0.9),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8.8,
                offset: const Offset(0, 2.2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selectedOption == question['answer']
                    ? Icons.emoji_events
                    : Icons.thumb_up,
                color: Colors.white,
                size: responsiveFontSize,
              ),
              SizedBox(width: screenWidth * 0.0165),
              Text(
                selectedOption == question['answer']
                    ? '+$_earnedPointsForNotification ${_text('pointsEarned', context)} ✅'
                    : '+$_earnedPointsForNotification ${_text('pointsEarned', context)} 👍',
                style: TextStyle(
                  fontSize: responsiveFontSize - 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
