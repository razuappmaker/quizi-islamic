import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class ResultPage extends StatefulWidget {
  final int total;
  final int correct;

  ResultPage({required this.total, required this.correct});

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
        title: Text(
          'আপনার ফলাফল',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
                            offset: Offset(0, 4),
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
                    SizedBox(height: 24),

                    // Feedback Message
                    Container(
                      padding: EdgeInsets.symmetric(
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
                    SizedBox(height: 32),

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
                            Divider(height: 24),
                            _buildStatRow(
                              'সঠিক উত্তর',
                              widget.correct.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                            Divider(height: 24),
                            _buildStatRow(
                              'ভুল উত্তর',
                              wrong.toString(),
                              Icons.cancel,
                              Colors.red,
                            ),
                            Divider(height: 24),
                            _buildStatRow(
                              'সাফল্যের হার',
                              '${percentage.toStringAsFixed(1)}%',
                              Icons.emoji_events,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Action Buttons (উপরে স্থানান্তরিত)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.refresh, size: 22),
                          label: Text(
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: Colors.green.withOpacity(0.4),
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: Icon(Icons.home, size: 22),
                          label: Text(
                            'হোমে যান',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () => Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // ইসলাম সম্পর্কে জানা উচিত সেকশন (নিচে স্থানান্তরিত)
                    _buildIslamKnowledgeSection(),
                    SizedBox(height: 20),
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

  Widget _buildStatRow(String title, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 12),
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

  Widget _buildIslamKnowledgeSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[100]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // কলাম কনটেন্ট সেন্টার
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // রো কনটেন্ট সেন্টার
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber[700],
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  'ইসলাম সম্পর্কে জানুন',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'ইসলাম শুধুমাত্র ধর্ম নয়, এটি একটি পূর্ণাঙ্গ জীবনব্যবস্থা। '
              'ইসলামের পাঁচটি স্তম্ভ - ঈমান, নামায, রোজা, যাকাত ও হজ্জ - '
              'প্রতিটি মুসলিমের জানা এবং পালন করা আবশ্যক। '
              'কুরআন ও হাদিস অধ্যয়ন করে ইসলাম সম্পর্কে আরও জানুন এবং আপনার জ্ঞান বৃদ্ধি করুন।',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.left, // টেক্সট সেন্টার
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              // সমস্ত চিপ মাঝ বরাবর
              crossAxisAlignment: WrapCrossAlignment.center,
              // ক্রস অক্ষ বরাবর সেন্টার
              children: [
                _buildKnowledgeChip('কুরআন অধ্যয়ন', Icons.book, Colors.blue),
                _buildKnowledgeChip(
                  'হাদিস শিক্ষা',
                  Icons.library_books,
                  Colors.green,
                ),
                _buildKnowledgeChip(
                  'নামায শিক্ষা',
                  Icons.person_pin,
                  Colors.orange,
                ),
                _buildKnowledgeChip(
                  'ইসলামিক ইতিহাস',
                  Icons.history,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } //------

  Widget _buildKnowledgeChip(String text, IconData icon, Color color) {
    return Chip(
      label: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
      avatar: Icon(icon, size: 16, color: Colors.white),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      labelPadding: EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
