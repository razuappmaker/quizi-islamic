import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'ad_helper.dart';
import 'profile_screen.dart';
import '../screens/reward_screen.dart';
import '../providers/language_provider.dart'; // ✅ Language Provider import

class ResultPage extends StatefulWidget {
  final int total;
  final int correct;
  final int totalPoints;

  const ResultPage({
    Key? key,
    required this.total,
    required this.correct,
    required this.totalPoints,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  // ==================== ভাষা টেক্সট ডিক্লেয়ারেশন ====================
  static const Map<String, Map<String, String>> _texts = {
    'pageTitle': {'en': 'Your Result', 'bn': 'আপনার ফলাফল'},
    'score': {'en': 'Score', 'bn': 'স্কোর'},
    'excellent': {
      'en': "🌟 Excellent! You're perfect!",
      'bn': "🌟 অসাধারণ! আপনি একদম নিখুঁত!",
    },
    'veryGood': {'en': "✅ Very well done!", 'bn': "✅ খুব ভালো করেছেন!"},
    'good': {
      'en': "👍 Good job, but more practice needed.",
      'bn': "👍 ভালো করেছেন, তবে আরও চর্চা দরকার।",
    },
    'keepPracticing': {
      'en': "📚 Keep practicing!",
      'bn': "📚 অনুশীলন চালিয়ে যান!",
    },
    'totalQuestions': {'en': 'Total Questions', 'bn': 'মোট প্রশ্ন'},
    'correctAnswers': {'en': 'Correct Answers', 'bn': 'সঠিক উত্তর'},
    'wrongAnswers': {'en': 'Wrong Answers', 'bn': 'ভুল উত্তর'},
    'successRate': {'en': 'Success Rate', 'bn': 'সাফল্যের হার'},
    'pointsEarned': {'en': 'Points Earned', 'bn': 'অর্জিত পয়েন্ট'},
    'pointsInfo': {
      'en':
          'Congratulations! You earned {points} points from this quiz. You can collect points from your profile and get gifts.',
      'bn':
          'অভিনন্দন! আপনি এই কুইজ থেকে {points} পয়েন্ট অর্জন করেছেন। প্রোফাইল থেকে পয়েন্ট জমা করে গিফট নিতে পারবেন।',
    },
    'tryAgain': {'en': 'Try Again', 'bn': 'আবার চেষ্টা করুন'},
    'viewProfile': {'en': 'View Profile', 'bn': 'প্রোফাইল দেখুন'},
    'videoRewardTitle': {
      'en': '🎬 Earn Points by Watching Ads',
      'bn': '🎬 ভিডিও দেখে পয়েন্ট অর্জন করুন',
    },
    'videoRewardDescription': {
      'en':
          'Watch short videos to earn extra points and get ready to receive gifts faster.',
      'bn':
          'সংক্ষিপ্ত ভিডিও দেখে অতিরিক্ত পয়েন্ট অর্জন করুন এবং দ্রুত গিফট পেতে প্রস্তুত হোন।',
    },
    'watchVideos': {'en': 'Watch Videos', 'bn': 'ভিডিও দেখুন'},
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

  // পয়েন্ট ইনফো টেক্সট (ডাইনামিক)
  String _getPointsInfoText(BuildContext context) {
    final baseText = _text('pointsInfo', context);
    return baseText.replaceFirst('{points}', widget.totalPoints.toString());
  }

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    if (await AdHelper.canShowBannerAd()) {
      final ad = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) async {
            await AdHelper.recordBannerAdShown();
            setState(() {
              _isBannerAdReady = true;
              _bannerAd = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            print("Banner Ad failed: $error");
          },
        ),
      );

      ad.load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _navigateToReward() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RewardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    int wrong = widget.total - widget.correct;
    double percentage = (widget.correct / widget.total) * 100;
    String feedback;
    Color feedbackColor;

    if (percentage == 100) {
      feedback = _text('excellent', context);
      feedbackColor = Colors.amber[700]!;
    } else if (percentage >= 80) {
      feedback = _text('veryGood', context);
      feedbackColor = Colors.green[700]!;
    } else if (percentage >= 50) {
      feedback = _text('good', context);
      feedbackColor = Colors.blue[700]!;
    } else {
      feedback = _text('keepPracticing', context);
      feedbackColor = Colors.orange[700]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text('pageTitle', context),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Score Badge
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green[300]!, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          Text(
                            _text('score', context),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feedback Message
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: feedbackColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: feedbackColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        feedback,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: feedbackColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Results Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Colors.grey[50]!],
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildStatRow(
                              _text('totalQuestions', context),
                              widget.total.toString(),
                              Icons.assignment,
                              Colors.blue,
                              context,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              _text('correctAnswers', context),
                              widget.correct.toString(),
                              Icons.check_circle,
                              Colors.green,
                              context,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              _text('wrongAnswers', context),
                              wrong.toString(),
                              Icons.cancel,
                              Colors.red,
                              context,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              _text('successRate', context),
                              '${percentage.toStringAsFixed(1)}%',
                              Icons.emoji_events,
                              Colors.orange,
                              context,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              _text('pointsEarned', context),
                              '${widget.totalPoints} ${_text('pointsEarned', context).contains('পয়েন্ট') ? 'পয়েন্ট' : 'Points'}',
                              Icons.monetization_on,
                              Colors.purple,
                              context,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔥 NEW: ভিডিও রিওয়ার্ড সেকশন
                    _buildVideoRewardSection(context),

                    const SizedBox(height: 24),

                    // পয়েন্ট ইনফো বক্স
                    if (widget.totalPoints > 0)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purple[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.purple[700],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getPointsInfoText(context),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.purple[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Column(
                      children: [
                        // 🔥 UPDATED: আবার চেষ্টা করুন বাটন
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh, size: 22),
                          label: Text(
                            _text('tryAgain', context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: Colors.green.withOpacity(0.4),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 🔥 UPDATED: প্রোফাইল বাটন
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person, size: 22),
                          label: Text(
                            _text('viewProfile', context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Banner Ad with safe area
            if (_isBannerAdReady && _bannerAd != null)
              SafeArea(
                top: false,
                child: Container(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔥 NEW: ভিডিও রিওয়ার্ড সেকশন
  Widget _buildVideoRewardSection(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red[50]!, Colors.orange[50]!],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!, width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library, color: Colors.red[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  _text('videoRewardTitle', context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _text('videoRewardDescription', context),
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToReward,
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text(
                  _text('watchVideos', context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: Colors.red.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
