import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'result_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ad_helper.dart'; // ✅ আপনার Ad Helper ফাইল ইমপোর্ট

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

  // Banner Ad ভেরিয়েবল
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  // ইন্টারস্টিশিয়াল দেখানো হয়েছে কিনা চেক করার ফ্ল্যাগ
  bool _hasShownInterstitial = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setVolume(1.0);

    // Banner Ad লোড
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();

    loadQuestions();

    // ✅ Interstitial শুরুতে শুধু লোড হবে
    AdHelper.loadInterstitialAd();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _bannerAd.dispose();
    super.dispose();
  }

  // JSON থেকে প্রশ্ন লোড
  Future<void> loadQuestions() async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final data = json.decode(response);
    setState(() {
      questions = data[widget.category] ?? [];
      startTimer();
    });
  }

  // টাইমার চালু
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

  // সঠিক উত্তর সাউন্ড
  void playCorrectSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  // ভুল উত্তর সাউন্ড
  void playWrongSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
  }

  // উত্তর চেক করা
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

  // পরবর্তী প্রশ্নে যাওয়া
  void goToNextQuestion() {
    _timer?.cancel();

    if (currentQuestionIndex < questions.length - 1) {
      // প্রশ্ন বাকি থাকলে
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedOption = null;
        _timeLeft = 20;
      });
      startTimer();
    } else {
      // ✅ ক্যাটাগরি শেষে শুধু একবার অ্যাড দেখাবে
      if (!_hasShownInterstitial) {
        _hasShownInterstitial = true;
        _showAdThenNavigate();
      } else {
        _navigateToResult();
      }
    }
  }

  // ✅ অ্যাড দেখানোর পর রেজাল্ট পেজে যাওয়ার লজিক
  void _showAdThenNavigate() {
    if (AdHelper.isAdReady()) {
      AdHelper.showAd(() {
        _navigateToResult();
      });
    } else {
      _navigateToResult();
    }
  }


  // রেজাল্ট পেজে যাওয়া
  void _navigateToResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          total: questions.length,
          correct: score,
        ),
      ),
    );
  }

  // টাইম শেষ হলে ডায়লগ
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

  // ব্যাক প্রেস করলে সরাসরি পপ
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'সময় বাকি: $_timeLeft সেকেন্ড',
                          style: const TextStyle(fontSize: 18, color: Colors.red),
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
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ...(question['options'] as List<dynamic>).map((option) {
                      Color optionColor = isDarkMode ? Colors.grey[800]! : Colors.white;
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
                          child: Text(option, style: const TextStyle(fontSize: 18)),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isAnswered ? goToNextQuestion : null,
                      child: const Text('পরবর্তী প্রশ্ন'),
                    ),
                  ],
                ),
              ),
            ),
            if (_isBannerAdReady)
              Container(
                alignment: Alignment.center,
                height: _bannerAd.size.height.toDouble(),
                width: _bannerAd.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
          ],
        ),
      ),
    );
  }
}
