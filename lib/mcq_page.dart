// mcq_page.dart - Main UI Component
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamicquiz/utils/point_manager.dart';
import 'result_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ad_helper.dart';
import 'mcq_security_manager.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart'; // ✅ Language Provider import

class MCQPage extends StatefulWidget {
  final String category;
  final String quizId;

  const MCQPage({required this.category, required this.quizId, Key? key})
    : super(key: key);

  @override
  State<MCQPage> createState() => _MCQPageState();
}

class _MCQPageState extends State<MCQPage> with WidgetsBindingObserver {
  // ==================== ভাষা টেক্সট ডিক্লেয়ারেশন ====================
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

  // হেল্পার মেথড - ভাষা অনুযায়ী টেক্সট পাওয়ার জন্য
  String _text(String key, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

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

  // Constants - Increased heights by 10% for non-small screens
  static const double _optionCardMinHeight = 39.6;
  static const double _optionCardMaxHeight = 52.8;
  static const double _optionCardHeightFactor = 0.055;
  static const double _optionCardMarginBottom = 8.8;
  static const double _optionCardBorderRadius = 13.2;
  static const double _optionFontSize = 15.4;
  static const double _optionSelectedBorderWidth = 1.65;
  static const double _optionCardPaddingRatioVertical = 0.165;
  static const double _optionCardPaddingRatioHorizontal = 0.22;

  // Primary Color - Fixed non-nullable
  final Color primaryColor = Colors.green[800] ?? Colors.green;

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
    _securityManager.dispose(); // ✅ Security manager dispose করুন
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

  // ==================== TIMER METHODS ====================
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

  void _cancelAllTimers() {
    _timer?.cancel();
    _timer = null;
    _pointsNotificationTimer?.cancel();
    _pointsNotificationTimer = null;
  }

  // ==================== AUDIO METHODS ====================
  void playCorrectSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print('Audio play error: $e');
    }
  }

  void playWrongSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      print('Audio play error: $e');
    }
  }

  // ==================== ANSWER HANDLING ====================
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
    if (_isBannerAdReady && _bannerAd != null) {
      _bannerAd?.dispose();
      _isBannerAdReady = false;
      await _loadAdaptiveBanner();
    }
  }

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

  // ==================== NAVIGATION & DIALOGS ====================
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

  void showTimeUpDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_text('timeUp', context)),
        content: Text(_text('timeUpMessage', context)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              goToNextQuestion();
            },
            child: Text(_text('nextQuestion', context)),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!mounted) return true;

    Navigator.of(context).pop();
    return false;
  }

  // ==================== POINTS NOTIFICATION ====================
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

  // ==================== UI BUILD METHODS ====================
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
        appBar: AppBar(
          title: Text(
            '${_text('questionProgress', context)} ${currentQuestionIndex + 1}/${_securityManager.questions.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth < 360 ? 14 : 17.6,
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
                      padding: EdgeInsets.all(screenWidth * 0.033),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Progress Bar Section - Increased by 10%
                          _buildProgressSection(
                            context,
                            isDarkMode,
                            screenWidth,
                            screenHeight,
                            responsiveFontSize,
                            isTablet,
                          ),

                          SizedBox(height: screenHeight * 0.022),

                          // Question Image - Increased by 10%
                          if (question['image'] != null)
                            _buildQuestionImage(question, screenHeight),

                          // Question Container - Increased by 10%
                          _buildQuestionContainer(
                            question,
                            isDarkMode,
                            isTablet,
                            isSmallPhone,
                            screenHeight,
                            screenWidth,
                            responsiveFontSize,
                          ),

                          SizedBox(height: screenHeight * 0.022),

                          // Options - Increased by 10%
                          _buildOptionsSection(
                            question,
                            isDarkMode,
                            screenHeight,
                            screenWidth,
                            isTablet,
                            isSmallPhone,
                            responsiveFontSize,
                          ),

                          SizedBox(height: screenHeight * 0.022),

                          // Next Button - Increased by 10%
                          _buildNextButton(
                            screenHeight,
                            responsiveFontSize,
                            context,
                          ),

                          SizedBox(height: screenHeight * 0.022),

                          // Google Search Button - Increased by 10%
                          if (isAnswered)
                            _buildGoogleSearchButton(
                              isDarkMode,
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

            // Points Notification - Increased by 10%
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

  Future<void> _initializeQuiz() async {
    try {
      // ✅ PointManager কে current language সেট করুন
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      await PointManager().setLanguage(languageProvider.currentLanguage);

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
            color: Colors.white,
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
                  color: Colors.orange[50],
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
                        color: Colors.orange[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: Colors.orange,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _text('pleaseWait', context),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
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
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),

                    // Progress Indicator
                    SizedBox(
                      height: 4,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange[400]!,
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
                  color: Colors.grey[50],
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
                          backgroundColor: Colors.orange,
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

  // ==================== UI COMPONENT METHODS ====================
  Widget _buildLoadingScreen() {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 13.2),
            Text(
              _text('loadingQuiz', context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text('loadingQuiz', context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 13.2),
            Text(
              _text('loadingQuestions', context),
              style: const TextStyle(fontSize: 15.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    bool isDarkMode,
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
        color: Colors.white,
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
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        '${((currentQuestionIndex + 1) / _securityManager.questions.length * 100).toStringAsFixed(0)}% of ${_securityManager.questions.length}',
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
                  height: 3.3,
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

  Widget _buildTimerSection(
    double screenHeight,
    double screenWidth,
    bool isTablet,
    double responsiveFontSize,
    BuildContext context,
  ) {
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
                      color: Colors.grey[500],
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
              color: Colors.grey[200],
              child: const Icon(Icons.error_outline, color: Colors.grey),
            );
          },
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
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
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
              color: isDarkMode ? Colors.green[800] : Colors.green[100],
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
                color: isDarkMode ? Colors.green[100] : Colors.green[800],
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
                color: isDarkMode ? Colors.white : Colors.black87,
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

  Widget _buildOptionsSection(
    dynamic question,
    bool isDarkMode,
    double screenHeight,
    double screenWidth,
    bool isTablet,
    bool isSmallPhone,
    double responsiveFontSize,
  ) {
    // Language provider থেকে ভাষা চেক করুন
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
                              isEnglish
                                  ? [
                                      'A',
                                      'B',
                                      'C',
                                      'D',
                                    ][index] // English: A, B, C, D
                                  : ['ক', 'খ', 'গ', 'ঘ'][index],
                              // Bengali: ক, খ, গ, ঘ
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
          backgroundColor: primaryColor,
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

  Widget _buildGoogleSearchButton(
    bool isDarkMode,
    double screenHeight,
    double screenWidth,
    double responsiveFontSize,
    dynamic question,
    BuildContext context,
  ) {
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
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
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
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
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
                foregroundColor: isDarkMode
                    ? Colors.blue[300]
                    : Colors.blue[600],
                side: BorderSide(
                  color: isDarkMode ? Colors.blue[400]! : Colors.blue[300]!,
                  width: 1.32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.8),
                ),
                backgroundColor: isDarkMode
                    ? Colors.blue[900]!.withOpacity(0.1)
                    : Colors.blue[50]!.withOpacity(0.5),
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
                color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
              ),
              label: Text(_text('searchGoogle', context)),
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
