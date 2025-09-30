// MCQ Page
// mcq_page.dart - ফাইনাল ভার্সন (এরর-ফ্রি)
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'result_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ad_helper.dart';
import 'network_json_loader.dart';
import '../utils/point_manager.dart';

class MCQPage extends StatefulWidget {
  final String category;
  final String quizId; // ✅ কুইজ আইডি প্যারামিটার যোগ করুন

  const MCQPage({
    required this.category,
    required this.quizId, // ✅ কুইজ আইডি রিকোয়ার্ড
    Key? key,
  }) : super(key: key);

  @override
  State<MCQPage> createState() => _MCQPageState();
}

class _MCQPageState extends State<MCQPage> with WidgetsBindingObserver {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  String? selectedOption;

  int get totalTime => 20;
  int _timeLeft = 20;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ব্যানার এড
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // ইন্টারস্টিশিয়াল এড ফ্ল্যাগ
  bool _hasShownHalfwayAd = false;
  bool _hasShownFinalAd = false;
  Orientation _currentOrientation = Orientation.portrait;

  // পয়েন্ট সিস্টেমের জন্য ভেরিয়েবল
  int earnedPoints = 0;
  bool pointsAdded = false;
  int _totalEarnedPoints = 0;

  // পয়েন্ট নোটিফিকেশন সিস্টেম
  bool _showPointsNotification = false;
  Timer? _pointsNotificationTimer;

  // কুইজ স্টার্ট স্ট্যাটাস
  bool _quizStarted = true; // ✅ ডিফল্টভাবে true সেট করুন

  // কনস্ট্যান্ট ভ্যালু
  static const double _optionCardMinHeight = 48.0;
  static const double _optionCardMaxHeight = 65.0;
  static const double _optionCardHeightFactor = 0.065;
  static const double _optionCardMarginBottom = 12.0;
  static const double _optionCardBorderRadius = 14.0;
  static const double _optionFontSize = 16.0;
  static const double _optionSelectedBorderWidth = 1.8;

  // ছোট মোবাইলের জন্য কম্প্যাক্ট কনস্ট্যান্ট
  static const double _optionCardMinHeightCompact = 40.0;
  static const double _optionCardMaxHeightCompact = 52.0;
  static const double _optionCardHeightFactorCompact = 0.05;
  static const double _optionCardPaddingRatioVertical = 0.20;
  static const double _optionCardPaddingRatioHorizontal = 0.25;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer.setVolume(1.0);

    loadQuestions();
    AdHelper.loadInterstitialAd();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdaptiveBanner();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pointsNotificationTimer?.cancel(); // ✅ পয়েন্ট টাইমার ক্যানসেল
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

  // 🔥 পয়েন্ট নোটিফিকেশন শো করার ফাংশন
  void _showPointsEarnedNotification(int points) {
    setState(() {
      _showPointsNotification = true;
      earnedPoints = points;
    });

    // ২ সেকেন্ড পর অটোমেটিক হাইড
    _pointsNotificationTimer?.cancel();
    _pointsNotificationTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showPointsNotification = false;
        });
      }
    });
  }

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

  // ✅ পয়েন্ট যোগ করার মেথড
  Future<void> _addPointsToUser(int earnedPoints) async {
    try {
      await PointManager.addPoints(earnedPoints);
      print("$earnedPoints পয়েন্ট যোগ করা হয়েছে!");
      setState(() {
        pointsAdded = true;
      });
    } catch (e) {
      print("পয়েন্ট যোগ করতে ত্রুটি: $e");
    }
  }

  // ✅ কুইজ শেষ হলে ইউজার স্ট্যাটস আপডেট
  Future<void> _updateUserStats() async {
    try {
      await PointManager.updateQuizStats(score);
      print("কুইজ স্ট্যাটস আপডেট করা হয়েছে: $score সঠিক উত্তর");
    } catch (e) {
      print("স্ট্যাটস আপডেট করতে ত্রুটি: $e");
    }
  }

  // ✅ কুইজ সম্পন্ন হিসেবে মার্ক করুন
  Future<void> _markQuizAsCompleted() async {
    try {
      await PointManager.markQuizPlayed(widget.quizId, _totalEarnedPoints);
      print('কুইজ সম্পন্ন হিসেবে মার্ক করা হয়েছে: ${widget.quizId}');
    } catch (e) {
      print('কুইজ মার্ক করতে ত্রুটি: $e');
    }
  }

  int _calculateTotalPoints() {
    return _totalEarnedPoints;
  }

  // গুগল সার্চ ফাংশন
  Future<void> _searchOnGoogle() async {
    final question = questions[currentQuestionIndex]['question'];

    bool? shouldSearch = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'গুগলে সার্চ করুন',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'আপনি কি "$question" প্রশ্নটি গুগলে সার্চ করতে চান?',
          style: const TextStyle(fontSize: 14, height: 1.4),
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('সার্চ করুন'),
          ),
        ],
      ),
    );

    if (shouldSearch == true) {
      final encodedQuestion = Uri.encodeComponent('$question ইসলামিক প্রশ্ন');
      final url = 'https://www.google.com/search?q=$encodedQuestion';

      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('গুগল সার্চ খোলা যাচ্ছে না'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        print('URL লঞ্চ করতে ত্রুটি: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('গুগল সার্চ খুলতে ত্রুটি'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> loadQuestions() async {
    try {
      print('🔄 প্রশ্ন লোড শুরু: ${widget.category}');

      final List<dynamic> allQuestionsData =
          await NetworkJsonLoader.loadJsonList('assets/questions.json');

      if (allQuestionsData is List && allQuestionsData.isNotEmpty) {
        Map<String, dynamic> questionsMap = {};

        for (var item in allQuestionsData) {
          if (item is Map<String, dynamic>) {
            questionsMap.addAll(item);
          }
        }

        setQuestionsFromMap(questionsMap);
        print('✅ নেটওয়ার্ক থেকে প্রশ্ন সফলভাবে লোড হয়েছে');
        return;
      } else if (allQuestionsData is Map) {
        setQuestionsFromMap(allQuestionsData as Map<String, dynamic>);
        print('✅ নেটওয়ার্ক থেকে প্রশ্ন সফলভাবে লোড হয়েছে');
        return;
      }
    } catch (e) {
      print('❌ নেটওয়ার্ক থেকে লোড ব্যর্থ: $e');
    }

    try {
      print('🔄 লোকাল asset থেকে প্রশ্ন লোড করার চেষ্টা');
      final String localResponse = await rootBundle.loadString(
        'assets/questions.json',
      );
      final Map<String, dynamic> localData = json.decode(localResponse);
      setQuestionsFromMap(localData);
      print('✅ লোকাল asset থেকে প্রশ্ন সফলভাবে লোড হয়েছে');
    } catch (e) {
      print('❌ লোকাল asset থেকে লোড ব্যর্থ: $e');

      setState(() {
        questions = _getDefaultQuestions();
        if (questions.isNotEmpty && _quizStarted) {
          startTimer();
        }
      });
      print('⚠️ ডিফল্ট প্রশ্ন ব্যবহার করা হচ্ছে');
    }
  }

  void setQuestionsFromMap(Map<String, dynamic> questionsMap) {
    setState(() {
      questions = questionsMap[widget.category] ?? [];
      if (questions.isEmpty) {
        questions = _getDefaultQuestions();
      }

      if (questions.isNotEmpty && _quizStarted) {
        startTimer();
      }
    });
  }

  List<dynamic> _getDefaultQuestions() {
    return [
      {
        'question': 'ইসলামের প্রথম রুকন কী?',
        'options': ['নামাজ', 'রোজা', 'কালিমা', 'হজ্জ'],
        'answer': 'কালিমা',
        'image': null,
      },
      {
        'question': 'দৈনিক কত ওয়াক্ত নামাজ ফরজ?',
        'options': ['৩ ওয়াক্ত', '৪ ওয়াক্ত', '৫ ওয়াক্ত', '৬ ওয়াক্ত'],
        'answer': '৫ ওয়াক্ত',
        'image': null,
      },
      {
        'question': 'কুরআন মজীদে কতটি সূরা আছে?',
        'options': ['১০০ সূরা', '১১০ সূরা', '১১৪ সূরা', '১২০ সূরা'],
        'answer': '১১৪ সূরা',
        'image': null,
      },
    ];
  }

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

  void playCorrectSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  void playWrongSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
  }

  // ✅ চেক আন্সার ফাংশন - আপডেটেড
  void checkAnswer(String selected) {
    if (isAnswered || !_quizStarted) return;

    setState(() {
      selectedOption = selected;
      isAnswered = true;

      int pointsForThisQuestion = 0;

      if (selected == questions[currentQuestionIndex]['answer']) {
        score++;
        playCorrectSound();

        // সময়ের উপর ভিত্তি করে পয়েন্ট
        if (_timeLeft >= 15) {
          pointsForThisQuestion = 10;
        } else if (_timeLeft >= 10) {
          pointsForThisQuestion = 8;
        } else if (_timeLeft >= 5) {
          pointsForThisQuestion = 5;
        } else {
          pointsForThisQuestion = 3;
        }
      } else {
        playWrongSound();
        pointsForThisQuestion = 1;
      }

      earnedPoints = pointsForThisQuestion;
      _totalEarnedPoints += pointsForThisQuestion;

      _addPointsToUser(pointsForThisQuestion);

      // 🔥 পয়েন্ট নোটিফিকেশন শো করুন
      _showPointsEarnedNotification(pointsForThisQuestion);

      // কুইজ শেষ হলে মার্ক করুন
      if (currentQuestionIndex == questions.length - 1) {
        _markQuizAsCompleted();
      }
    });
  }

  void goToNextQuestion() {
    if (!_quizStarted) return;

    _timer?.cancel();

    // পরবর্তী প্রশ্নে যাওয়ার আগে পয়েন্ট রিসেট
    setState(() {
      earnedPoints = 0;
      pointsAdded = false;
    });

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedOption = null;
        _timeLeft = 20;
      });
      startTimer();

      if (!_hasShownHalfwayAd &&
          currentQuestionIndex >= (questions.length / 2).floor()) {
        _hasShownHalfwayAd = true;
        _showInterstitialAd();
      }
    } else {
      if (!_hasShownFinalAd) {
        _hasShownFinalAd = true;
        _showAdThenNavigate();
      } else {
        _navigateToResult();
      }
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

  // ✅ রেজাল্ট পেজে নেভিগেট
  void _navigateToResult() {
    _updateUserStats(); // ইউজার স্ট্যাটস আপডেট করুন

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          total: questions.length,
          correct: score,
          totalPoints: _calculateTotalPoints(),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.green[800];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isTablet = screenWidth > 600;
    final bool isSmallPhone = screenHeight < 600 || screenWidth < 360;
    final double responsiveFontSize = screenWidth < 360
        ? 14.0
        : screenWidth < 400
        ? 16.0
        : 17.0;

    // ✅ যদি কুইজ শুরু না হয়
    if (!_quizStarted) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.category),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('কুইজ লোড হচ্ছে...'),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('লোড হচ্ছে...'),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 16),
              Text('প্রশ্নগুলি লোড হচ্ছে...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    var question = questions[currentQuestionIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'প্রশ্ন ${currentQuestionIndex + 1}/${questions.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth < 360 ? 16 : 18,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // প্রোগ্রেস বার
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                              horizontal: screenWidth * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // প্রগ্রেস টেক্সট
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                              '${questions.length} এর ${((currentQuestionIndex + 1) / questions.length * 100).toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontSize:
                                                    responsiveFontSize - 1,
                                                color: primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // প্রগ্রেস বার
                                      Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Stack(
                                          children: [
                                            AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  ((currentQuestionIndex + 1) /
                                                      questions.length),
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // টাইমার সেকশন - মডার্ন ডিজাইন=================
                                // আল্ট্রা স্লিম টাইমার
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.01,
                                    horizontal: screenWidth * 0.03,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _timeLeft <= 10
                                        ? Colors.red.withOpacity(0.06)
                                        : primaryColor!.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _timeLeft <= 10
                                          ? Colors.red.withOpacity(0.15)
                                          : primaryColor!.withOpacity(0.1),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // আইকন এবং টেক্সট
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            color: _timeLeft <= 10
                                                ? Colors.red
                                                : primaryColor,
                                            size: isTablet
                                                ? responsiveFontSize + 4
                                                : responsiveFontSize,
                                          ),
                                          SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'সময়',
                                                style: TextStyle(
                                                  fontSize: isTablet
                                                      ? responsiveFontSize - 1
                                                      : responsiveFontSize - 4,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                              Text(
                                                '$_timeLeft সেকেন্ড',
                                                style: TextStyle(
                                                  fontSize: isTablet
                                                      ? responsiveFontSize + 2
                                                      : responsiveFontSize - 1,
                                                  fontWeight: FontWeight.bold,
                                                  color: _timeLeft <= 10
                                                      ? Colors.red
                                                      : primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // মিনিমাল ইন্ডিকেটর
                                      // মিডিয়াম থিক (ডিফল্টের চেয়ে থিক)
                                      // ভেরিয়েবল থিকনেস (টাইমের উপর ভিত্তি করে)
                                      Container(
                                        width: isTablet ? 40 : 30,
                                        height: isTablet ? 40 : 30,
                                        child: CircularProgressIndicator(
                                          value: _timeLeft / 20.0,
                                          strokeWidth: _timeLeft <= 10
                                              ? (isTablet ? 7 : 5)
                                              : (isTablet ? 5 : 3.5),
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _timeLeft <= 10
                                                    ? Colors.red
                                                    : primaryColor!,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // টাইমার সেকশন - মডার্ন ডিজাইন=================
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // প্রশ্ন ইমেজ
                          if (question['image'] != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/${question['image']}',
                                  height: screenHeight * 0.2,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                          // প্রশ্ন কন্টেইনার
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet
                                  ? screenHeight * 0.025
                                  : isSmallPhone
                                  ? screenHeight * 0.018
                                  : screenHeight * 0.022,
                              horizontal: isTablet
                                  ? screenWidth * 0.05
                                  : isSmallPhone
                                  ? screenWidth * 0.035
                                  : screenWidth * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(
                                isTablet
                                    ? 16
                                    : isSmallPhone
                                    ? 10
                                    : 12,
                              ),
                            ),
                            child: Text(
                              question['question'],
                              style: TextStyle(
                                fontSize: isTablet
                                    ? responsiveFontSize + 2
                                    : isSmallPhone
                                    ? responsiveFontSize - 1
                                    : responsiveFontSize + 1,
                                fontWeight: FontWeight.w600,
                                height: isTablet
                                    ? 1.5
                                    : isSmallPhone
                                    ? 1.3
                                    : 1.4,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.025),

                          // অপশনগুলি
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double screenHeight = constraints.maxHeight;
                              final double screenWidth = MediaQuery.of(
                                context,
                              ).size.width;

                              final bool isTablet = screenWidth > 600;
                              final bool isSmallPhone =
                                  screenHeight < 600 || screenWidth < 360;
                              final bool isLargePhone =
                                  screenHeight > 700 && screenWidth > 400;

                              final double optionCardHeight = math.max(
                                isTablet
                                    ? _optionCardMinHeight * 0.95
                                    : isSmallPhone
                                    ? _optionCardMinHeightCompact
                                    : isLargePhone
                                    ? _optionCardMinHeight * 0.9
                                    : _optionCardMinHeight * 0.85,
                                math.min(
                                  screenHeight *
                                      (isTablet
                                          ? _optionCardHeightFactor * 0.9
                                          : isSmallPhone
                                          ? _optionCardHeightFactorCompact
                                          : isLargePhone
                                          ? _optionCardHeightFactor * 0.8
                                          : _optionCardHeightFactor * 0.7),
                                  isTablet
                                      ? _optionCardMaxHeight * 0.95
                                      : isSmallPhone
                                      ? _optionCardMaxHeightCompact
                                      : isLargePhone
                                      ? _optionCardMaxHeight * 0.9
                                      : _optionCardMaxHeight * 0.85,
                                ),
                              );

                              final double optionFontSize = isTablet
                                  ? _optionFontSize * 1.05
                                  : isSmallPhone
                                  ? _optionFontSize * 0.82
                                  : isLargePhone
                                  ? _optionFontSize * 0.95
                                  : _optionFontSize * 0.88;

                              return Column(
                                children: (question['options'] as List<dynamic>).map((
                                  option,
                                ) {
                                  final double verticalPadding =
                                      optionCardHeight *
                                      (isSmallPhone
                                          ? 0.18
                                          : _optionCardPaddingRatioVertical);
                                  final double horizontalPadding =
                                      optionCardHeight *
                                      (isSmallPhone
                                          ? 0.22
                                          : _optionCardPaddingRatioHorizontal);

                                  Color optionColor = isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.white;
                                  Color textColor = isDarkMode
                                      ? Colors.white70
                                      : Colors.black87;
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
                                      textColor = isDarkMode
                                          ? Colors.red[400]!
                                          : Colors.red[700]!;
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
                                          ? _optionCardMarginBottom * 1.1
                                          : isSmallPhone
                                          ? _optionCardMarginBottom * 0.7
                                          : _optionCardMarginBottom * 0.85,
                                    ),
                                    height: optionCardHeight,
                                    child: Material(
                                      elevation: isAnswered
                                          ? 0
                                          : (isTablet
                                                ? 1.5
                                                : (isSmallPhone ? 0.5 : 1)),
                                      color: optionColor,
                                      borderRadius: BorderRadius.circular(
                                        _optionCardBorderRadius,
                                      ),
                                      shadowColor: shadowColor,
                                      surfaceTintColor: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => checkAnswer(option),
                                        borderRadius: BorderRadius.circular(
                                          _optionCardBorderRadius,
                                        ),
                                        splashColor: isAnswered
                                            ? Colors.transparent
                                            : (isDarkMode
                                                  ? Colors.white.withOpacity(
                                                      0.08,
                                                    )
                                                  : Colors.black.withOpacity(
                                                      0.04,
                                                    )),
                                        highlightColor: isAnswered
                                            ? Colors.transparent
                                            : (isDarkMode
                                                  ? Colors.white.withOpacity(
                                                      0.04,
                                                    )
                                                  : Colors.black.withOpacity(
                                                      0.02,
                                                    )),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // অপশন ইন্ডিকেটর
                                              Container(
                                                width: isSmallPhone
                                                    ? 24
                                                    : (isTablet ? 30 : 26),
                                                height: isSmallPhone
                                                    ? 24
                                                    : (isTablet ? 30 : 26),
                                                margin: EdgeInsets.only(
                                                  right: isSmallPhone
                                                      ? 10
                                                      : (isTablet ? 14 : 12),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isAnswered
                                                      ? (option ==
                                                                question['answer']
                                                            ? Colors.green
                                                                  .withOpacity(
                                                                    0.1,
                                                                  )
                                                            : option ==
                                                                  selectedOption
                                                            ? Colors.red
                                                                  .withOpacity(
                                                                    0.1,
                                                                  )
                                                            : isDarkMode
                                                            ? Colors.grey[700]
                                                            : Colors.grey[200])
                                                      : (isDarkMode
                                                            ? Colors.grey[700]
                                                            : Colors.grey[200]),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        isSmallPhone ? 6 : 8,
                                                      ),
                                                  border:
                                                      isAnswered &&
                                                          option ==
                                                              question['answer']
                                                      ? Border.all(
                                                          color: Colors.green,
                                                          width: 1.5,
                                                        )
                                                      : null,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    [
                                                      'ক',
                                                      'খ',
                                                      'গ',
                                                      'ঘ',
                                                    ][(question['options']
                                                            as List<dynamic>)
                                                        .indexOf(option)],
                                                    style: TextStyle(
                                                      fontSize: isSmallPhone
                                                          ? 11
                                                          : (isTablet
                                                                ? 13
                                                                : 12),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isAnswered
                                                          ? (option ==
                                                                    question['answer']
                                                                ? Colors.green
                                                                : option ==
                                                                      selectedOption
                                                                ? Colors.red
                                                                : isDarkMode
                                                                ? Colors.white60
                                                                : Colors
                                                                      .black54)
                                                          : (isDarkMode
                                                                ? Colors.white70
                                                                : Colors
                                                                      .black87),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // অপশন টেক্সট
                                              Expanded(
                                                child: Text(
                                                  option,
                                                  style: TextStyle(
                                                    fontSize: optionFontSize,
                                                    color: textColor,
                                                    fontWeight:
                                                        isAnswered &&
                                                            option ==
                                                                question['answer']
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                    height: isSmallPhone
                                                        ? 1.2
                                                        : (isTablet
                                                              ? 1.35
                                                              : 1.25),
                                                  ),
                                                  textAlign: TextAlign.left,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),

                                              // করেক্ট/রংগ ইন্ডিকেটর আইকন
                                              if (isAnswered)
                                                AnimatedOpacity(
                                                  duration: const Duration(
                                                    milliseconds: 250,
                                                  ),
                                                  opacity: isAnswered
                                                      ? 1.0
                                                      : 0.0,
                                                  child: Icon(
                                                    option == question['answer']
                                                        ? Icons
                                                              .check_circle_rounded
                                                        : option ==
                                                              selectedOption
                                                        ? Icons.cancel_rounded
                                                        : Icons.circle_outlined,
                                                    size: isSmallPhone
                                                        ? 16
                                                        : (isTablet ? 20 : 18),
                                                    color:
                                                        option ==
                                                            question['answer']
                                                        ? Colors.green
                                                        : option ==
                                                              selectedOption
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
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // পরবর্তী বাটন
                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.06,
                            child: ElevatedButton(
                              onPressed: isAnswered ? goToNextQuestion : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                textStyle: TextStyle(
                                  fontSize: responsiveFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Text(
                                currentQuestionIndex < questions.length - 1
                                    ? 'পরবর্তী প্রশ্ন'
                                    : 'ফলাফল দেখুন',
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // গুগল সার্চ বাটন
                          if (isAnswered)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: isDarkMode
                                                ? Colors.grey[700]
                                                : Colors.grey[300],
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            'উত্তরটি যাচাই করতে',
                                            style: TextStyle(
                                              fontSize: responsiveFontSize - 3,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: isDarkMode
                                                ? Colors.grey[700]
                                                : Colors.grey[300],
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: double.infinity,
                                    height: screenHeight * 0.055,
                                    child: OutlinedButton.icon(
                                      onPressed: _searchOnGoogle,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isDarkMode
                                            ? Colors.blue[300]
                                            : Colors.blue[600],
                                        side: BorderSide(
                                          color: isDarkMode
                                              ? Colors.blue[400]!
                                              : Colors.blue[300]!,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        backgroundColor: isDarkMode
                                            ? Colors.blue[900]!.withOpacity(0.1)
                                            : Colors.blue[50]!.withOpacity(0.5),
                                        textStyle: TextStyle(
                                          fontSize: responsiveFontSize - 1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.04,
                                          vertical: screenHeight * 0.015,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.search,
                                        size: responsiveFontSize,
                                        color: isDarkMode
                                            ? Colors.blue[300]
                                            : Colors.blue[600],
                                      ),
                                      label: const Text(
                                        'গুগলে তথ্য যাচাই করুন',
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

                  // ব্যানার এড
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

            // 🔥 পয়েন্ট নোটিফিকেশন (সবার উপরে ভাসমান)
            if (_showPointsNotification)
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.012,
                      horizontal: screenWidth * 0.06,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selectedOption ==
                              questions[currentQuestionIndex]['answer']
                          ? Colors.green.withOpacity(0.9)
                          : Colors.orange.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selectedOption ==
                                  questions[currentQuestionIndex]['answer']
                              ? Icons.emoji_events
                              : Icons.thumb_up,
                          color: Colors.white,
                          size: responsiveFontSize + 2,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          selectedOption ==
                                  questions[currentQuestionIndex]['answer']
                              ? '+$earnedPoints পয়েন্ট ✅'
                              : '+$earnedPoints পয়েন্ট 👍',
                          style: TextStyle(
                            fontSize: responsiveFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
