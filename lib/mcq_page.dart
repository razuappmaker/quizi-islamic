// MCQ Page
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'result_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ad_helper.dart';
import 'network_json_loader.dart'; // নেটওয়ার্ক লোডার import করুন

class MCQPage extends StatefulWidget {
  final String category;

  const MCQPage({required this.category, Key? key}) : super(key: key);

  @override
  State<MCQPage> createState() => _MCQPageState();
}

class _MCQPageState extends State<MCQPage> with WidgetsBindingObserver {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  String? selectedOption;
  int _timeLeft = 20;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // Interstitial Ad flags
  bool _hasShownHalfwayAd = false;
  bool _hasShownFinalAd = false;
  Orientation _currentOrientation = Orientation.portrait;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer.setVolume(1.0);

    loadQuestions();
    // AdHelper.initialize() main.dart এ হয়ে গেছে, শুধু interstitial লোড করুন
    AdHelper.loadInterstitialAd();

    // Adaptive banner লোড করার জন্য প্রথম frame এর পর call করুন
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdaptiveBanner();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
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

  // Orientation change হলে banner reload
  Future<void> _reloadBannerOnOrientationChange() async {
    if (_bannerAd != null) {
      _bannerAd?.dispose();
      _isBannerAdReady = false;
    }
    await _loadAdaptiveBanner();
  }

  // Adaptive Banner লোড করার মেথড
  Future<void> _loadAdaptiveBanner() async {
    try {
      // প্রথমে check করুন আমরা banner ad show করতে পারবো কিনা
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('Banner ad limit reached, not showing ad');
        return;
      }

      // Adaptive banner তৈরি করুন with fallback mechanism
      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() => _isBannerAdReady = true);
            // Banner ad shown রেকর্ড করুন
            AdHelper.recordBannerAdShown();
            print('Banner ad loaded successfully.');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Banner ad failed to load: $error');
            ad.dispose();
            _isBannerAdReady = false;
          },
          onAdOpened: (Ad ad) {
            // Ad click রেকর্ড করুন
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Banner ad clicked.');
              } else {
                print('Ad click limit reached');
              }
            });
          },
        ),
        orientation: _currentOrientation,
      );

      // Banner লোড করুন
      await _bannerAd?.load();
    } catch (e) {
      print('Error loading adaptive banner: $e');
      // Fallback: regular banner লোড করার চেষ্টা করুন
      _loadRegularBanner();
    }
  }

  // Regular banner লোড করার fallback মেথড
  void _loadRegularBanner() {
    try {
      _bannerAd = AdHelper.createBannerAd(
        AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() => _isBannerAdReady = true);
            AdHelper.recordBannerAdShown();
            print('Regular banner ad loaded successfully.');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Regular banner ad failed to load: $error');
            ad.dispose();
            _isBannerAdReady = false;
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Banner ad clicked.');
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

  // ✅ আপডেটেড: JSON থেকে প্রশ্ন লোড করুন (নেটওয়ার্ক → লোকাল → ডিফল্ট)
  Future<void> loadQuestions() async {
    try {
      print('🔄 প্রশ্ন লোড শুরু: ${widget.category}');

      // ১ম চেষ্টা: নেটওয়ার্ক থেকে সম্পূর্ণ questions.json লোড করুন
      final List<dynamic> allQuestionsData =
          await NetworkJsonLoader.loadJsonList(
            'assets/questions.json', // এই path টি নেটওয়ার্কে থাকতে হবে
          );

      // নেটওয়ার্ক থেকে পাওয়া ডেটা process করুন
      if (allQuestionsData is List && allQuestionsData.isNotEmpty) {
        // যদি নেটওয়ার্ক ডেটা List হিসেবে আসে
        Map<String, dynamic> questionsMap = {};

        // List কে Map এ convert করুন (যদি প্রয়োজন হয়)
        for (var item in allQuestionsData) {
          if (item is Map<String, dynamic>) {
            questionsMap.addAll(item);
          }
        }

        setQuestionsFromMap(questionsMap);
        print('✅ নেটওয়ার্ক থেকে প্রশ্ন সফলভাবে লোড হয়েছে');
        return;
      } else if (allQuestionsData is Map) {
        // যদি নেটওয়ার্ক ডেটা সরাসরি Map হিসেবে আসে
        setQuestionsFromMap(allQuestionsData as Map<String, dynamic>);
        print('✅ নেটওয়ার্ক থেকে প্রশ্ন সফলভাবে লোড হয়েছে');
        return;
      }
    } catch (e) {
      print('❌ নেটওয়ার্ক থেকে লোড ব্যর্থ: $e');
    }

    // ২য় চেষ্টা: লোকাল asset থেকে লোড করুন
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

      // ৩য় চেষ্টা: ডিফল্ট প্রশ্ন ব্যবহার করুন
      setState(() {
        questions = _getDefaultQuestions();
        if (questions.isNotEmpty) {
          startTimer();
        }
      });
      print('⚠️ ডিফল্ট প্রশ্ন ব্যবহার করা হচ্ছে');
    }
  }

  // ✅ সহায়ক মেথড: Map থেকে প্রশ্ন সেট করুন
  void setQuestionsFromMap(Map<String, dynamic> questionsMap) {
    setState(() {
      questions = questionsMap[widget.category] ?? [];
      if (questions.isEmpty) {
        // যদি specific category না পাওয়া যায়, তবে ডিফল্ট প্রশ্ন ব্যবহার করুন
        questions = _getDefaultQuestions();
      }

      if (questions.isNotEmpty) {
        startTimer();
      }
    });
  }

  // ✅ ডিফল্ট প্রশ্ন (যদি সবকিছু ব্যর্থ হয়)
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

  void checkAnswer(String selected) {
    if (isAnswered) return;
    setState(() {
      selectedOption = selected;
      isAnswered = true;
      if (selected == questions[currentQuestionIndex]['answer']) {
        score++;
        playCorrectSound();
      } else {
        playWrongSound();
      }
    });
  }

  void goToNextQuestion() {
    _timer?.cancel();

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedOption = null;
        _timeLeft = 20;
      });
      startTimer();

      // ✅ 50% প্রশ্ন শেষ হলে interstitial ad show করুন
      if (!_hasShownHalfwayAd &&
          currentQuestionIndex >= (questions.length / 2).floor()) {
        _hasShownHalfwayAd = true;
        _showInterstitialAd();
      }
    } else {
      // ✅ শেষ প্রশ্ন শেষ হলে final interstitial ad show করুন
      if (!_hasShownFinalAd) {
        _hasShownFinalAd = true;
        _showAdThenNavigate();
      } else {
        _navigateToResult();
      }
    }
  }

  // Interstitial ad show করার মেথড
  void _showInterstitialAd() {
    AdHelper.showInterstitialAd(
      onAdShowed: () {
        print('Interstitial ad showed at halfway point');
      },
      onAdDismissed: () {
        print('Interstitial ad dismissed');
        // Ad dismiss হওয়ার পর পরবর্তী ad preload করুন
        AdHelper.loadInterstitialAd();
      },
      onAdFailedToShow: () {
        print('Interstitial ad failed to show at halfway point');
        // Failed হলে পরবর্তী ad load করার চেষ্টা করুন
        AdHelper.loadInterstitialAd();
      },
      adContext: 'MCQPage_Halfway', // ট্র্যাকিং এর জন্য
    );
  }

  // Ad show করার পর result page এ navigate করার মেথড
  void _showAdThenNavigate() {
    AdHelper.showInterstitialAd(
      onAdShowed: () {
        print('Final interstitial ad showed');
      },
      onAdDismissed: () {
        _navigateToResult();
        // Ad dismiss হওয়ার পর পরবর্তী ad preload করুন
        AdHelper.loadInterstitialAd();
      },
      onAdFailedToShow: () {
        _navigateToResult();
        // Failed হলে পরবর্তী ad load করার চেষ্টা করুন
        AdHelper.loadInterstitialAd();
      },
      adContext: 'MCQPage_Final', // ট্র্যাকিং এর জন্য
    );
  }

  void _navigateToResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultPage(total: questions.length, correct: score),
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress bar with percentage
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value:
                                  (currentQuestionIndex + 1) / questions.length,
                              backgroundColor: Colors.grey[300],
                              color: primaryColor,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${((currentQuestionIndex + 1) / questions.length * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Timer section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 5
                            ? Colors.red.withOpacity(0.1)
                            : primaryColor!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            color: _timeLeft <= 5 ? Colors.red : primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'সময় বাকি: $_timeLeft সেকেন্ড',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _timeLeft <= 5 ? Colors.red : primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Question image
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
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    // Question text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        question['question'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Options
                    ...(question['options'] as List<dynamic>).map((option) {
                      Color optionColor = isDarkMode
                          ? Colors.grey[800]!
                          : Colors.white;
                      Color textColor = isDarkMode
                          ? Colors.white70
                          : Colors.black87;
                      BoxBorder? border;

                      if (isAnswered) {
                        if (option == question['answer']) {
                          optionColor = Colors.green.withOpacity(0.2);
                          textColor = isDarkMode
                              ? Colors.green[300]!
                              : Colors.green;
                          border = Border.all(color: Colors.green, width: 1.5);
                        } else if (option == selectedOption) {
                          optionColor = Colors.red.withOpacity(0.2);
                          textColor = isDarkMode
                              ? Colors.red[300]!
                              : Colors.red;
                          border = Border.all(color: Colors.red, width: 1.5);
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: optionColor,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => checkAnswer(option),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: border,
                                boxShadow: [
                                  if (!isAnswered)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                  fontWeight:
                                      isAnswered && option == question['answer']
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 24),

                    // Next button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isAnswered ? goToNextQuestion : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          textStyle: const TextStyle(
                            fontSize: 16,
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
                  ],
                ),
              ),
            ),

            // ✅ Banner Ad (যদি লোড হয়ে থাকে এবং limit না থাকে)
            if (_isBannerAdReady && _bannerAd != null)
              SafeArea(
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
