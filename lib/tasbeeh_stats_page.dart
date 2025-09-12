import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart'; // তোমার AdHelper ফাইল import

class TasbeehStatsPage extends StatefulWidget {
  final int subhanallahCount;
  final int alhamdulillahCount;
  final int allahuakbarCount;

  const TasbeehStatsPage({
    Key? key,
    required this.subhanallahCount,
    required this.alhamdulillahCount,
    required this.allahuakbarCount,
  }) : super(key: key);

  @override
  State<TasbeehStatsPage> createState() => _TasbeehStatsPageState();
}

class _TasbeehStatsPageState extends State<TasbeehStatsPage> {
  late int subhanallahCount;
  late int alhamdulillahCount;
  late int allahuakbarCount;

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  // উপকারিতা map
  final Map<String, String> benefits = {
    "সুখ ও মনের প্রশান্তি লাভ":
        "রাসূলুল্লাহ ﷺ বলেছেন: ‘নিশ্চয়ই আল্লাহর স্মরণ (জিকির) হৃদয়কে শান্ত করে।’ অর্থাৎ, আল্লাহর নাম স্মরণ করা (যেমন: সুবহানাল্লাহ, আলহামদুলিল্লাহা, আল্লাহু আকবার) হৃদয়কে শান্তি দেয়।’ (সহীহ মুসলিম, হাদিস: 2697)",
    "সুবহানাল্লাহ":
        "রাসূলুল্লাহ ﷺ বলেছেন যে ব্যক্তি প্রতিদিন একশবার ‘সুবহানাল্লাহ’ বলে, তার জন্য একশটি পাপ মাফ করা হবে। (সহীহ বুখারি, হাদিস: 6406)",
    "আলহামদুলিল্লাহা":
        "রাসূলুল্লাহ ﷺ বলেছেন: যে ব্যক্তি একশবার ‘আলহামদুলিল্লাহা’ বলে, তার জন্য একশটি ধন্যবাদ আল্লাহর কাছে গ্রহণযোগ্য হবে। (সহীহ মুসলিম, হাদিস: 2713)",
    "আল্লাহু আকবার":
        "রাসূলুল্লাহ ﷺ বলেছেন: ‘সকালে ও বিকেলে ‘আল্লাহু আকবার’ বলা হৃদয়কে আল্লাহর সাথে সংযুক্ত রাখে এবং দৈনন্দিন পাপগুলো মুছে দেয়।’ (সহীহ মুসলিম, হাদিস: 2721)",
  };

  @override
  void initState() {
    super.initState();

    subhanallahCount = widget.subhanallahCount;
    alhamdulillahCount = widget.alhamdulillahCount;
    allahuakbarCount = widget.allahuakbarCount;

    // Banner Ad Load
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
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

    // Fullscreen Ad দেখানো
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AdHelper.isAdReady()) {
        AdHelper.showAd(() {});
      }
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  Widget _buildStatCard(
    String title,
    int count,
    MaterialColor color,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      color: isDark ? Colors.grey[850] : color.withOpacity(0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : color.shade800,
          ),
        ),
        trailing: Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : color.shade900,
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard(String title, String benefit, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: isDark ? Colors.grey[800] : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              benefit,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MaterialColor subColor = Colors.green;
    final MaterialColor alhamColor = Colors.blue;
    final MaterialColor akbarColor = Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text("তসবীহ স্ট্যাটস"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildStatCard("সুবহানাল্লাহ", subhanallahCount, subColor, context),
            _buildStatCard(
              "আলহামদুলিল্লাহা",
              alhamdulillahCount,
              alhamColor,
              context,
            ),
            _buildStatCard(
              "আল্লাহু আকবার",
              allahuakbarCount,
              akbarColor,
              context,
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    subhanallahCount = 0;
                    alhamdulillahCount = 0;
                    allahuakbarCount = 0;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text("সম্পূর্ণ রিসেট"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            // Benefits Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "উপকারিতা",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.green.shade800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildBenefitCard(
              "সুখ ও মনের প্রশান্তি লাভ",
              benefits["সুখ ও মনের প্রশান্তি লাভ"] ?? "",
              context,
            ),
            _buildBenefitCard(
              "সুবহানাল্লাহ",
              benefits["সুবহানাল্লাহ"] ?? "",
              context,
            ),
            _buildBenefitCard(
              "আলহামদুলিল্লাহা",
              benefits["আলহামদুলিল্লাহা"] ?? "",
              context,
            ),
            _buildBenefitCard(
              "আল্লাহু আকবার",
              benefits["আল্লাহু আকবার"] ?? "",
              context,
            ),
            const SizedBox(height: 60), // Bottom spacing for banner
          ],
        ),
      ),
      bottomNavigationBar: _isBannerAdReady
          ? SafeArea(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                alignment: Alignment.center,
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            )
          : null,
    );
  }
}
