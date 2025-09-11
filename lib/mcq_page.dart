import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'result_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ad_helper.dart';

class MCQPage extends StatefulWidget {
  final String category;

  const MCQPage({required this.category, Key? key}) : super(key: key);

  @override
  State<MCQPage> createState() => _MCQPageState();
}

class _MCQPageState extends State<MCQPage> {
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

  @override
  void initState() {
    super.initState();
    _audioPlayer.setVolume(1.0);

    loadQuestions();
    AdHelper.loadInterstitialAd();

    // Load adaptive banner after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdaptiveBanner();
    });
  }

  // Load adaptive Banner
  void _loadAdaptiveBanner() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          MediaQuery.of(context).size.width.truncate(),
        );

    if (size == null) return;

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('BannerAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  // Load questions from JSON
  Future<void> loadQuestions() async {
    final String response = await rootBundle.loadString(
      'assets/questions.json',
    );
    final data = json.decode(response);
    setState(() {
      questions = data[widget.category] ?? [];
      startTimer();
    });
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

      // ✅ 50% questions finished -> show Interstitial
      if (!_hasShownHalfwayAd &&
          currentQuestionIndex >= (questions.length / 2).floor()) {
        _hasShownHalfwayAd = true;
        _showInterstitialAd();
      }
    } else {
      // ✅ Last question finished -> show final Interstitial
      if (!_hasShownFinalAd) {
        _hasShownFinalAd = true;
        _showAdThenNavigate();
      } else {
        _navigateToResult();
      }
    }
  }

  void _showInterstitialAd() {
    if (AdHelper.isAdReady()) {
      AdHelper.showAd(() {
        // Nothing extra needed; just continue quiz
      });
    }
  }

  void _showAdThenNavigate() {
    if (AdHelper.isAdReady()) {
      AdHelper.showAd(() {
        _navigateToResult();
      });
    } else {
      _navigateToResult();
    }
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

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('লোড হচ্ছে...'),
          backgroundColor: Colors.green[800],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    var question = questions[currentQuestionIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('প্রশ্ন ${currentQuestionIndex + 1}/${questions.length}'),
          backgroundColor: Colors.green[800],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / questions.length,
                      backgroundColor: Colors.grey[300],
                      color: Colors.green,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'প্রশ্ন ${currentQuestionIndex + 1} এর ${questions.length} টি',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'সময় বাকি: $_timeLeft সেকেন্ড',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (question['image'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Image.asset(
                          'assets/images/${question['image']}',
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Text(
                      question['question'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...(question['options'] as List<dynamic>).map((option) {
                      Color optionColor = isDarkMode
                          ? Colors.grey
                          : Colors.white;
                      if (isAnswered) {
                        if (option == question['answer']) {
                          optionColor = Colors.greenAccent;
                        } else if (option == selectedOption) {
                          optionColor = Colors.redAccent;
                        }
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: optionColor,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => checkAnswer(option),
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isAnswered ? goToNextQuestion : null,
                      child: const Text('পরবর্তী প্রশ্ন'),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ Full-width adaptive Banner
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
