import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_helper.dart'; // ✅ AdHelper import

class TasbeehStatsPage extends StatefulWidget {
  const TasbeehStatsPage({Key? key}) : super(key: key);

  @override
  State<TasbeehStatsPage> createState() => _TasbeehStatsPageState();
}

class _TasbeehStatsPageState extends State<TasbeehStatsPage> {
  int subhanallahCount = 0;
  int alhamdulillahCount = 0;
  int allahuakbarCount = 0;

  // ✅ Banner Ad variables - AdHelper ব্যবহার করে
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // উপকারিতা map
  final Map<String, String> benefits = {
    "সুবহানাল্লাহ":
        "রাসূলুল্লাহ ﷺ বলেছেন যে ব্যক্তি প্রতিদিন একশবার 'সুবহানাল্লাহ' বলে, তার জন্য একশটি পাপ মাফ করা হবে। (সহীহ বুখারি, হাদিস: 6406)",
    "আলহামদুলিল্লাহা":
        "রাসূলুল্লাহ ﷺ বলেছেন: যে ব্যক্তি একশবার 'আলহামদুলিল্লাহা' বলে, তার জন্য একশটি ধন্যবাদ আল্লাহর কাছে গ্রহণযোগ্য হবে। (সহীহ মুসলিম, হাদিস: 2713)",
    "আল্লাহু আকবার":
        "রাসূলুল্লাহ ﷺ বলেছেন: 'সকালে ও বিকেলে 'আল্লাহু আকবার' বলা হৃদয়কে আল্লাহর সাথে সংযুক্ত রাখে এবং দৈনন্দিন পাপগুলো মুছে দেয়।' (সহীহ মুসলিম, হাদিস: 2721)",
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _loadBannerAd(); // ✅ AdHelper ব্যবহার করে banner load

    // Fullscreen Ad দেখানো
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdHelper.showInterstitialAd(
        onAdShowed: () => print('Interstitial ad showed'),
        onAdDismissed: () => print('Interstitial ad dismissed'),
        onAdFailedToShow: () => print('Interstitial ad failed to show'),
        adContext: 'TasbeehStatsPage',
      );
    });
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subhanallahCount = prefs.getInt("subhanallahCount") ?? 0;
      alhamdulillahCount = prefs.getInt("alhamdulillahCount") ?? 0;
      allahuakbarCount = prefs.getInt("allahuakbarCount") ?? 0;
    });
  }

  Future<void> _loadBannerAd() async {
    try {
      // ✅ প্রথমে check করুন আমরা banner ad show করতে পারবো কিনা
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('Banner ad limit reached, not showing ad');
        return;
      }

      // ✅ AdHelper ব্যবহার করে adaptive banner তৈরি করুন
      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() => _isBannerAdReady = true);
            // ✅ Banner ad shown রেকর্ড করুন
            AdHelper.recordBannerAdShown();
            print('Banner ad loaded successfully.');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Banner ad failed to load: $error');
            ad.dispose();
            _isBannerAdReady = false;
          },
          onAdOpened: (Ad ad) {
            // ✅ Ad click রেকর্ড করুন (limit check সহ)
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

      // ✅ Banner লোড করুন
      await _bannerAd?.load();
    } catch (e) {
      print('Error loading banner ad: $e');
      _isBannerAdReady = false;
    }
  }

  Future<void> _resetAllCounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subhanallahCount = 0;
      alhamdulillahCount = 0;
      allahuakbarCount = 0;
      prefs.setInt("subhanallahCount", 0);
      prefs.setInt("alhamdulillahCount", 0);
      prefs.setInt("allahuakbarCount", 0);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("সব গণনা রিসেট করা হয়েছে"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // ✅ Null safety সহ dispose
    super.dispose();
  }

  //--------------------------------

  Widget _buildStatCard(
    String title,
    int count,
    MaterialColor color,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: screenWidth > 600 ? 24 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      color: isDark ? Colors.grey[850] : color.withOpacity(0.1),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: screenWidth > 600 ? 24 : 20,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.favorite, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: screenWidth > 600 ? 22 : 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : color.shade800,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: screenWidth > 600 ? 26 : 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : color.shade900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard(String title, String benefit, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: screenWidth > 600 ? 24 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: isDark ? Colors.grey[800] : Colors.green.shade50,
      child: Padding(
        padding: EdgeInsets.all(screenWidth > 600 ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: isDark ? Colors.amber : Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              benefit,
              style: TextStyle(
                fontSize: screenWidth > 600 ? 17 : 16,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "মোট তাসবিহ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ),
      ),

      body: SafeArea(
        bottom: true, // সবসময় bottom safe area maintain করবে
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green.shade50, Colors.green.shade100],
                  ),
                ),
                child: SingleChildScrollView(
                  // ব্যানার না থাকলে extra bottom padding যোগ করুন
                  padding: EdgeInsets.only(
                    bottom: _isBannerAdReady ? 0 : bottomPadding + 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildStatCard(
                        "সুবহানাল্লাহ",
                        subhanallahCount,
                        subColor,
                        context,
                      ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth > 600 ? 24 : 16,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _resetAllCounts,
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            "সম্পূর্ণ রিসেট",
                            style: TextStyle(
                              fontSize: screenWidth > 600 ? 18 : 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: screenWidth > 600 ? 16 : 14,
                              horizontal: screenWidth > 600 ? 24 : 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: Size(
                              screenWidth > 600
                                  ? screenWidth * 0.4
                                  : double.infinity,
                              50,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      // Benefits Section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth > 600 ? 24 : 16,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "উপকারিতা",
                            style: TextStyle(
                              fontSize: screenWidth > 600 ? 26 : 22,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey
                                  : Colors.green.shade800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Banner Ad (যদি থাকে)
            if (_isBannerAdReady && _bannerAd != null)
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                alignment: Alignment.center,
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
