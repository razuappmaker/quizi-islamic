import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'profile_screen.dart';
import '../screens/reward_screen.dart'; // RewardScreen importardScreen import করুন

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
      feedback = "🌟 অসাধারণ! আপনি একদম নিখুঁত!";
      feedbackColor = Colors.amber[700]!;
    } else if (percentage >= 80) {
      feedback = "✅ খুব ভালো করেছেন!";
      feedbackColor = Colors.green[700]!;
    } else if (percentage >= 50) {
      feedback = "👍 ভালো করেছেন, তবে আরও চর্চা দরকার।";
      feedbackColor = Colors.blue[700]!;
    } else {
      feedback = "📚 অনুশীলন চালিয়ে যান!";
      feedbackColor = Colors.orange[700]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'আপনার ফলাফল',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                            'স্কোর',
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
                              'মোট প্রশ্ন',
                              widget.total.toString(),
                              Icons.assignment,
                              Colors.blue,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'সঠিক উত্তর',
                              widget.correct.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'ভুল উত্তর',
                              wrong.toString(),
                              Icons.cancel,
                              Colors.red,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'সাফল্যের হার',
                              '${percentage.toStringAsFixed(1)}%',
                              Icons.emoji_events,
                              Colors.orange,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'অর্জিত পয়েন্ট',
                              '${widget.totalPoints} পয়েন্ট',
                              Icons.monetization_on,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔥 NEW: ভিডিও রিওয়ার্ড সেকশন
                    _buildVideoRewardSection(),

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
                                'অভিনন্দন! আপনি এই কুইজ থেকে ${widget.totalPoints} পয়েন্ট অর্জন করেছেন। প্রোফাইল থেকে পয়েন্ট জমা করে গিফট নিতে পারবেন।',
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
                          label: const Text(
                            'আবার চেষ্টা করুন',
                            style: TextStyle(
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
                          label: const Text(
                            'প্রোফাইল দেখুন',
                            style: TextStyle(
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
  Widget _buildVideoRewardSection() {
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
                  '🎬 ভিডিও দেখে পয়েন্ট অর্জন করুন',
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
              'সংক্ষিপ্ত ভিডিও দেখে অতিরিক্ত পয়েন্ট অর্জন করুন এবং দ্রুত গিফট পেতে প্রস্তুত হোন।',
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
                label: const Text(
                  'ভিডিও দেখুন',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildStatRow(String title, String value, IconData icon, Color color) {
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
