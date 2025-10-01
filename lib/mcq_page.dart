// MCQ Page
// mcq_page.dart - Main UI Component
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'result_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ad_helper.dart';
import 'mcq_security_manager.dart';

class MCQPage extends StatefulWidget {
  final String category;
  final String quizId;

  const MCQPage({required this.category, required this.quizId, Key? key})
    : super(key: key);

  @override
  State<MCQPage> createState() => _MCQPageState();
}

class _MCQPageState extends State<MCQPage> with WidgetsBindingObserver {
  // Security and Data Manager
  final MCQSecurityManager _securityManager = MCQSecurityManager();

  // UI State Variables
  int currentQuestionIndex = 0;
  bool isAnswered = false;
  String? selectedOption;
  int _timeLeft = 20;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Orientation _currentOrientation = Orientation.portrait;

  // Ads
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _hasShownHalfwayAd = false;
  bool _hasShownFinalAd = false;

  // Points Notification
  bool _showPointsNotification = false;
  Timer? _pointsNotificationTimer;
  int _earnedPointsForNotification = 0;

  // Constants
  static const double _optionCardMinHeight = 36.0;
  static const double _optionCardMaxHeight = 48.0;
  static const double _optionCardHeightFactor = 0.05;
  static const double _optionCardMarginBottom = 8.0;
  static const double _optionCardBorderRadius = 12.0;
  static const double _optionFontSize = 14.0;
  static const double _optionSelectedBorderWidth = 1.5;
  static const double _optionCardMinHeightCompact = 32.0;
  static const double _optionCardMaxHeightCompact = 40.0;
  static const double _optionCardHeightFactorCompact = 0.04;
  static const double _optionCardPaddingRatioVertical = 0.15;
  static const double _optionCardPaddingRatioHorizontal = 0.20;

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
    _timer?.cancel();
    _pointsNotificationTimer?.cancel();
    _audioPlayer.dispose();
    _bannerAd?.dispose();
    AdHelper.disposeInterstitialAd();
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

  Future<void> _initializeQuiz() async {
    // Initialize security manager and load questions
    await _securityManager.initialize(
      category: widget.category,
      quizId: widget.quizId,
    );

    // Load ads
    AdHelper.loadInterstitialAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdaptiveBanner();
    });

    // Start timer if questions are loaded
    if (_securityManager.questions.isNotEmpty && _securityManager.quizStarted) {
      startTimer();
    }

    setState(() {});
  }

  // ==================== TIMER METHODS ====================
  void startTimer() {
    _timer?.cancel();
    _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
        showTimeUpDialog();
      }
    });
  }

  // ==================== AUDIO METHODS ====================
  void playCorrectSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  void playWrongSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
  }

  // ==================== ANSWER HANDLING ====================
  void checkAnswer(String selected) {
    if (isAnswered || !_securityManager.quizStarted) return;

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

    // Play sound
    if (result.isCorrect) {
      playCorrectSound();
    } else {
      playWrongSound();
    }

    // Show points notification
    _showPointsEarnedNotification(result.earnedPoints);
  }

  void goToNextQuestion() {
    if (!_securityManager.quizStarted) return;

    _timer?.cancel();

    setState(() {
      _earnedPointsForNotification = 0;
    });

    if (currentQuestionIndex < _securityManager.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedOption = null;
        _timeLeft = 20;
      });
      startTimer();

      // Show ad at halfway point
      if (!_hasShownHalfwayAd &&
          currentQuestionIndex >=
              (_securityManager.questions.length / 2).floor()) {
        _hasShownHalfwayAd = true;
        _showInterstitialAd();
      }
    } else {
      // Quiz completed
      if (!_hasShownFinalAd) {
        _hasShownFinalAd = true;
        _showAdThenNavigate();
      } else {
        _navigateToResult();
      }
    }
  }

  // ==================== ADS METHODS ====================
  Future<void> _reloadBannerOnOrientationChange() async {
    if (_bannerAd != null) {
      _bannerAd?.dispose();
      _isBannerAdReady = false;
    }
    await _loadAdaptiveBanner();
  }

  Future<void> _loadAdaptiveBanner() async {
    try {
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('ব্যানার এড লিমিট রিচড, এড দেখানো হবে না');
        return;
      }

      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() => _isBannerAdReady = true);
            AdHelper.recordBannerAdShown();
            print('ব্যানার এড সফলভাবে লোড হয়েছে');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('ব্যানার এড লোড হতে ব্যর্থ: $error');
            ad.dispose();
            _isBannerAdReady = false;
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('ব্যানার এড ক্লিক করা হয়েছে');
              } else {
                print('এড ক্লিক লিমিট রিচড');
              }
            });
          },
        ),
        orientation: _currentOrientation,
      );

      await _bannerAd?.load();
    } catch (e) {
      print('অ্যাডাপ্টিভ ব্যানার লোড করতে ত্রুটি: $e');
      _loadRegularBanner();
    }
  }

  void _loadRegularBanner() {
    try {
      _bannerAd = AdHelper.createBannerAd(
        AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() => _isBannerAdReady = true);
            AdHelper.recordBannerAdShown();
            print('নিয়মিত ব্যানার এড সফলভাবে লোড হয়েছে');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('নিয়মিত ব্যানার এড লোড হতে ব্যর্থ: $error');
            ad.dispose();
            _isBannerAdReady = false;
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('ব্যানার এড ক্লিক করা হয়েছে');
              } else {
                print('এড ক্লিক লিমিট রিচড');
              }
            });
          },
        ),
      );

      _bannerAd?.load();
    } catch (e) {
      print('নিয়মিত ব্যানার লোড করতে ত্রুটি: $e');
    }
  }

  void _showInterstitialAd() {
    AdHelper.showInterstitialAd(
      onAdShowed: () {
        print('অর্ধেক পথে ইন্টারস্টিশিয়াল এড দেখানো হয়েছে');
      },
      onAdDismissed: () {
        print('ইন্টারস্টিশিয়াল এড dismiss করা হয়েছে');
        AdHelper.loadInterstitialAd();
      },
      onAdFailedToShow: () {
        print('অর্ধেক পথে ইন্টারস্টিশিয়াল এড দেখাতে ব্যর্থ');
        AdHelper.loadInterstitialAd();
      },
      adContext: 'MCQPage_Halfway',
    );
  }

  void _showAdThenNavigate() {
    AdHelper.showInterstitialAd(
      onAdShowed: () {
        print('ফাইনাল ইন্টারস্টিশিয়াল এড দেখানো হয়েছে');
      },
      onAdDismissed: () {
        _navigateToResult();
        AdHelper.loadInterstitialAd();
      },
      onAdFailedToShow: () {
        _navigateToResult();
        AdHelper.loadInterstitialAd();
      },
      adContext: 'MCQPage_Final',
    );
  }

  // ==================== NAVIGATION & DIALOGS ====================
  void _navigateToResult() {
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

  void showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("সময় শেষ"),
        content: const Text("আপনি সময়মতো উত্তর দিতে পারেননি।"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              goToNextQuestion();
            },
            child: const Text("পরবর্তী প্রশ্ন"),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop();
    return false;
  }

  // ==================== POINTS NOTIFICATION ====================
  void _showPointsEarnedNotification(int points) {
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

  // ==================== UI BUILD METHODS ====================
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.green[800];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isTablet = screenWidth > 600;
    final bool isSmallPhone = screenHeight < 600 || screenWidth < 360;
    final double responsiveFontSize = screenWidth < 360
        ? 12.0
        : screenWidth < 400
        ? 14.0
        : 15.0;

    // Loading state
    if (!_securityManager.quizStarted) {
      return _buildLoadingScreen(primaryColor);
    }

    if (_securityManager.questions.isEmpty) {
      return _buildErrorScreen(primaryColor);
    }

    var question = _securityManager.questions[currentQuestionIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'প্রশ্ন ${currentQuestionIndex + 1}/${_securityManager.questions.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth < 360 ? 14 : 16,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryColor,
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
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Progress Bar Section
                          _buildProgressSection(
                            context,
                            isDarkMode,
                            primaryColor!,
                            screenWidth,
                            screenHeight,
                            responsiveFontSize,
                            isTablet,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Question Image
                          if (question['image'] != null)
                            _buildQuestionImage(question, screenHeight),

                          // Question Container
                          _buildQuestionContainer(
                            question,
                            isDarkMode,
                            isTablet,
                            isSmallPhone,
                            screenHeight,
                            screenWidth,
                            responsiveFontSize,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Options
                          _buildOptionsSection(
                            question,
                            isDarkMode,
                            screenHeight,
                            screenWidth,
                            isTablet,
                            isSmallPhone,
                            responsiveFontSize,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Next Button
                          _buildNextButton(
                            primaryColor!,
                            screenHeight,
                            responsiveFontSize,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Google Search Button
                          if (isAnswered)
                            _buildGoogleSearchButton(
                              isDarkMode,
                              screenHeight,
                              screenWidth,
                              responsiveFontSize,
                              question,
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

            // Points Notification
            if (_showPointsNotification)
              _buildPointsNotification(
                screenWidth,
                screenHeight,
                responsiveFontSize,
                question,
              ),
          ],
        ),
      ),
    );
  }

  // ==================== UI COMPONENT METHODS ====================
  Widget _buildLoadingScreen(Color? primaryColor) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'কুইজ লোড হচ্ছে...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Color? primaryColor) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'লোড হচ্ছে...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 12),
            Text('প্রশ্নগুলি লোড হচ্ছে...', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    bool isDarkMode,
    Color primaryColor,
    double screenWidth,
    double screenHeight,
    double responsiveFontSize,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.015,
        horizontal: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'প্রশ্ন ${currentQuestionIndex + 1}',
                        style: TextStyle(
                          fontSize: responsiveFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        '${_securityManager.questions.length} এর ${((currentQuestionIndex + 1) / _securityManager.questions.length * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: responsiveFontSize - 1,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 3,
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width:
                            MediaQuery.of(context).size.width *
                            ((currentQuestionIndex + 1) /
                                _securityManager.questions.length),
                        decoration: BoxDecoration(color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildTimerSection(
            primaryColor,
            screenHeight,
            screenWidth,
            isTablet,
            responsiveFontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(
    Color primaryColor,
    double screenHeight,
    double screenWidth,
    bool isTablet,
    double responsiveFontSize,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.008,
        horizontal: screenWidth * 0.025,
      ),
      decoration: BoxDecoration(
        color: _timeLeft <= 10
            ? Colors.red.withOpacity(0.06)
            : primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _timeLeft <= 10
              ? Colors.red.withOpacity(0.15)
              : primaryColor.withOpacity(0.1),
          width: 0.8,
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
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'সময়',
                    style: TextStyle(
                      fontSize: isTablet
                          ? responsiveFontSize - 2
                          : responsiveFontSize - 5,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    '$_timeLeft সেকেন্ড',
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
            width: isTablet ? 32 : 26,
            height: isTablet ? 32 : 26,
            child: CircularProgressIndicator(
              value: _timeLeft / 20.0,
              strokeWidth: _timeLeft <= 10
                  ? (isTablet ? 5 : 4)
                  : (isTablet ? 4 : 3),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _timeLeft <= 10 ? Colors.red : primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionImage(dynamic question, double screenHeight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/${question['image']}',
          height: screenHeight * 0.15,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildQuestionContainer(
    dynamic question,
    bool isDarkMode,
    bool isTablet,
    bool isSmallPhone,
    double screenHeight,
    double screenWidth,
    double responsiveFontSize,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet
            ? screenHeight * 0.018
            : isSmallPhone
            ? screenHeight * 0.012
            : screenHeight * 0.015,
        horizontal: isTablet
            ? screenWidth * 0.04
            : isSmallPhone
            ? screenWidth * 0.03
            : screenWidth * 0.035,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(
          isTablet
              ? 12
              : isSmallPhone
              ? 8
              : 10,
        ),
      ),
      child: Text(
        question['question'],
        style: TextStyle(
          fontSize: isTablet
              ? responsiveFontSize + 1
              : isSmallPhone
              ? responsiveFontSize - 1
              : responsiveFontSize,
          fontWeight: FontWeight.w600,
          height: isTablet
              ? 1.4
              : isSmallPhone
              ? 1.2
              : 1.3,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptionsSection(
    dynamic question,
    bool isDarkMode,
    double screenHeight,
    double screenWidth,
    bool isTablet,
    bool isSmallPhone,
    double responsiveFontSize,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = constraints.maxHeight;
        final double screenWidth = MediaQuery.of(context).size.width;

        final bool isTablet = screenWidth > 600;
        final bool isSmallPhone = screenHeight < 600 || screenWidth < 360;
        final bool isLargePhone = screenHeight > 700 && screenWidth > 400;

        final double optionCardHeight = math.max(
          isTablet
              ? _optionCardMinHeight * 0.8
              : isSmallPhone
              ? _optionCardMinHeightCompact
              : isLargePhone
              ? _optionCardMinHeight * 0.75
              : _optionCardMinHeight * 0.7,
          math.min(
            screenHeight *
                (isTablet
                    ? _optionCardHeightFactor * 0.7
                    : isSmallPhone
                    ? _optionCardHeightFactorCompact
                    : isLargePhone
                    ? _optionCardHeightFactor * 0.6
                    : _optionCardHeightFactor * 0.5),
            isTablet
                ? _optionCardMaxHeight * 0.8
                : isSmallPhone
                ? _optionCardMaxHeightCompact
                : isLargePhone
                ? _optionCardMaxHeight * 0.75
                : _optionCardMaxHeight * 0.7,
          ),
        );

        final double optionFontSize = isTablet
            ? _optionFontSize * 0.9
            : isSmallPhone
            ? _optionFontSize * 0.75
            : isLargePhone
            ? _optionFontSize * 0.85
            : _optionFontSize * 0.8;

        return Column(
          children: (question['options'] as List<dynamic>).map((option) {
            final double verticalPadding =
                optionCardHeight *
                (isSmallPhone ? 0.12 : _optionCardPaddingRatioVertical);
            final double horizontalPadding =
                optionCardHeight *
                (isSmallPhone ? 0.15 : _optionCardPaddingRatioHorizontal);

            Color optionColor = isDarkMode ? Colors.grey[800]! : Colors.white;
            Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
            BoxBorder? border;
            Color? shadowColor;

            if (isAnswered) {
              if (option == question['answer']) {
                optionColor = isDarkMode
                    ? Colors.green.withOpacity(0.16)
                    : Colors.green.withOpacity(0.10);
                textColor = isDarkMode
                    ? Colors.green[400]!
                    : Colors.green[700]!;
                border = Border.all(
                  color: Colors.green,
                  width: _optionSelectedBorderWidth,
                );
              } else if (option == selectedOption) {
                optionColor = isDarkMode
                    ? Colors.red.withOpacity(0.16)
                    : Colors.red.withOpacity(0.10);
                textColor = isDarkMode ? Colors.red[400]! : Colors.red[700]!;
                border = Border.all(
                  color: Colors.red,
                  width: _optionSelectedBorderWidth,
                );
              }
            } else {
              shadowColor = isDarkMode
                  ? Colors.black.withOpacity(0.20)
                  : Colors.black.withOpacity(0.06);
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
                      : (isDarkMode
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.04)),
                  highlightColor: isAnswered
                      ? Colors.transparent
                      : (isDarkMode
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.02)),
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
                        // Option Indicator
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
                                      : isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[200])
                                : (isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(
                              isSmallPhone ? 5 : 6,
                            ),
                            border: isAnswered && option == question['answer']
                                ? Border.all(color: Colors.green, width: 1.2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              ['ক', 'খ', 'গ', 'ঘ'][(question['options']
                                      as List<dynamic>)
                                  .indexOf(option)],
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
                                          : isDarkMode
                                          ? Colors.white60
                                          : Colors.black54)
                                    : (isDarkMode
                                          ? Colors.white70
                                          : Colors.black87),
                              ),
                            ),
                          ),
                        ),

                        // Option Text - Fixed for small screens
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
                              maxLines: 3, // Increased from 2 to 3
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // Correct/Wrong Indicator Icon
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

  Widget _buildNextButton(
    Color primaryColor,
    double screenHeight,
    double responsiveFontSize,
  ) {
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.06, // আরও বাড়ানো হলো
      child: ElevatedButton(
        onPressed: isAnswered ? goToNextQuestion : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          textStyle: TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.bold,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ), // প্যাডিং যোগ করা হলো
        ),
        child: FittedBox(
          // FittedBox যোগ করা হলো
          fit: BoxFit.scaleDown,
          child: Text(
            currentQuestionIndex < _securityManager.questions.length - 1
                ? 'পরবর্তী প্রশ্ন'
                : 'ফলাফল দেখুন',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSearchButton(
    bool isDarkMode,
    double screenHeight,
    double screenWidth,
    double responsiveFontSize,
    dynamic question,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'উত্তরটি যাচাই করতে',
                    style: TextStyle(
                      fontSize: responsiveFontSize - 4,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.045,
            child: OutlinedButton.icon(
              onPressed: () => _securityManager.searchOnGoogle(
                context: context,
                question: question['question'],
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDarkMode
                    ? Colors.blue[300]
                    : Colors.blue[600],
                side: BorderSide(
                  color: isDarkMode ? Colors.blue[400]! : Colors.blue[300]!,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: isDarkMode
                    ? Colors.blue[900]!.withOpacity(0.1)
                    : Colors.blue[50]!.withOpacity(0.5),
                textStyle: TextStyle(
                  fontSize: responsiveFontSize - 2,
                  fontWeight: FontWeight.w600,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.012,
                ),
              ),
              icon: Icon(
                Icons.search,
                size: responsiveFontSize - 1,
                color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
              ),
              label: const Text('গুগলে তথ্য যাচাই করুন'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsNotification(
    double screenWidth,
    double screenHeight,
    double responsiveFontSize,
    dynamic question,
  ) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01,
            horizontal: screenWidth * 0.05,
          ),
          decoration: BoxDecoration(
            color: selectedOption == question['answer']
                ? Colors.green.withOpacity(0.9)
                : Colors.orange.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
              SizedBox(width: screenWidth * 0.015),
              Text(
                selectedOption == question['answer']
                    ? '+$_earnedPointsForNotification পয়েন্ট ✅'
                    : '+$_earnedPointsForNotification পয়েন্ট 👍',
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
