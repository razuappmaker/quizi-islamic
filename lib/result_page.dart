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

      ad.load(); // ✅ লোড এখানে করতে হবে
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

    if (percentage == 100) {
      feedback = "🌟 অসাধারণ! আপনি একদম নিখুঁত!";
    } else if (percentage >= 80) {
      feedback = "✅ খুব ভালো করেছেন!";
    } else if (percentage >= 50) {
      feedback = "👍 ভালো করেছেন, তবে আরও চর্চা দরকার।";
    } else {
      feedback = "📚 অনুশীলন চালিয়ে যান!";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('আপনার ফলাফল'),
        backgroundColor: Colors.green[800],
      ),
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.amber[800],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'আপনার স্কোর',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 20),

                      // ফলাফল কার্ড
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              resultRow(
                                'মোট প্রশ্ন',
                                widget.total.toString(),
                                Colors.blue,
                              ),
                              resultRow(
                                'সঠিক উত্তর',
                                widget.correct.toString(),
                                Colors.green,
                              ),
                              resultRow(
                                'ভুল উত্তর',
                                wrong.toString(),
                                Colors.red,
                              ),
                              resultRow(
                                'শতকরা হার',
                                '${percentage.toStringAsFixed(1)}%',
                                Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // মন্তব্য
                      Text(
                        feedback,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 30),

                      // আবার চেষ্টা করুন
                      ElevatedButton.icon(
                        icon: Icon(Icons.refresh),
                        label: Text(
                          'আবার চেষ্টা করুন',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // হোমে যান
                      OutlinedButton.icon(
                        icon: Icon(Icons.home),
                        label: Text('হোমে যান', style: TextStyle(fontSize: 16)),
                        onPressed: () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ Banner Ad নিচে বসানো হলো
          if (_isBannerAdReady && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget resultRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
      ),
    );
  }
}
