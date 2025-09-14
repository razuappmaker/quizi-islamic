import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'tasbeeh_stats_page.dart';
import 'ad_helper.dart'; // AdHelper import

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({Key? key}) : super(key: key);

  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage> {
  String selectedPhrase = "সুবহানাল্লাহ";
  int subhanallahCount = 0;
  int alhamdulillahCount = 0;
  int allahuakbarCount = 0;

  int uiSubhanallahCount = 0;
  int uiAlhamdulillahCount = 0;
  int uiAllahuakbarCount = 0;

  final Map<String, String> benefits = {
    "সুখ ও মনের প্রশান্তি লাভ":
        "রাসূলুল্লাহ ﷺ বলেছেন: 'নিশ্চয়ই আল্লাহর স্মরণ (জিকির) হৃদয়কে শান্ত করে।'",
  };

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _loadBannerAd();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subhanallahCount = prefs.getInt("subhanallahCount") ?? 0;
      alhamdulillahCount = prefs.getInt("alhamdulillahCount") ?? 0;
      allahuakbarCount = prefs.getInt("allahuakbarCount") ?? 0;

      uiSubhanallahCount = subhanallahCount;
      uiAlhamdulillahCount = alhamdulillahCount;
      uiAllahuakbarCount = allahuakbarCount;
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) {
          debugPrint("Banner Ad Failed: $error");
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  int _getCurrentCount() {
    if (selectedPhrase == "সুবহানাল্লাহ") return uiSubhanallahCount;
    if (selectedPhrase == "আলহামদুলিল্লাহা") return uiAlhamdulillahCount;
    if (selectedPhrase == "আল্লাহু আকবার") return uiAllahuakbarCount;
    return 0;
  }

  Future<void> _incrementCount(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPhrase = phrase;
      if (phrase == "সুবহানাল্লাহ") {
        uiSubhanallahCount++;
        subhanallahCount++;
        prefs.setInt("subhanallahCount", subhanallahCount);
      }
      if (phrase == "আলহামদুলিল্লাহা") {
        uiAlhamdulillahCount++;
        alhamdulillahCount++;
        prefs.setInt("alhamdulillahCount", alhamdulillahCount);
      }
      if (phrase == "আল্লাহু আকবার") {
        uiAllahuakbarCount++;
        allahuakbarCount++;
        prefs.setInt("allahuakbarCount", allahuakbarCount);
      }
    });
  }

  void _resetUICounts() {
    setState(() {
      uiSubhanallahCount = 0;
      uiAlhamdulillahCount = 0;
      uiAllahuakbarCount = 0;
      selectedPhrase = "সুবহানাল্লাহ";
    });
  }

  int _getCountForPhrase(String phrase) {
    if (phrase == "সুবহানাল্লাহ") return uiSubhanallahCount;
    if (phrase == "আলহামদুলিল্লাহা") return uiAlhamdulillahCount;
    if (phrase == "আল্লাহু আকবার") return uiAllahuakbarCount;
    return 0;
  }

  int _getTotalCount() {
    return subhanallahCount + alhamdulillahCount + allahuakbarCount;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tasbeehPhrases = [
      "সুবহানাল্লাহ",
      "আলহামদুলিল্লাহা",
      "আল্লাহু আকবার",
    ];
    final List<Color> colors = [
      Colors.green.shade700,
      Colors.blue.shade700,
      Colors.orange.shade700,
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ডিজিটাল তসবীহ",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _resetUICounts,
            tooltip: "বর্তমান সেশন রিসেট",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Header Card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              selectedPhrase,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 28 : 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _getCurrentCount().toString(),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 48 : 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "বর্তমান সেশন",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "মোট: ${_getTotalCount()}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tasbeeh Buttons
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isSmallScreen ? 1 : 3,
                      childAspectRatio: isSmallScreen ? 3.5 : 2.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      padding: const EdgeInsets.all(8),
                      children: tasbeehPhrases.asMap().entries.map((entry) {
                        int index = entry.key;
                        String phrase = entry.value;
                        Color color = colors[index % colors.length];
                        return Material(
                          borderRadius: BorderRadius.circular(16),
                          elevation: 4,
                          child: InkWell(
                            onTap: () => _incrementCount(phrase),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: color.withOpacity(0.2),
                                    child: Icon(
                                      Icons.favorite,
                                      color: color,
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      phrase,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 18 : 20,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getCountForPhrase(phrase).toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    _buildBenefitCard(
                      "জিকিরের উপকারিতা",
                      benefits["সুখ ও মনের প্রশান্তি লাভ"] ?? "",
                      context,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.transparent,
            child: isSmallScreen
                ? Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _resetUICounts,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text(
                          "সেশন রিসেট",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TasbeehStatsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bar_chart, size: 20),
                        label: const Text(
                          "লাইফটাইম স্ট্যাটস",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _resetUICounts,
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text(
                            "সেশন রিসেট",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TasbeehStatsPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bar_chart, size: 20),
                          label: const Text(
                            "লাইফটাইম স্ট্যাটস",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Banner Ad at bottom
          if (_isBannerAdReady)
            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: isDark ? Colors.amber : Colors.green.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              benefit,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
