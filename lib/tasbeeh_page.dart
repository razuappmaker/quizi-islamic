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

  Color _backgroundColor = Colors.green.shade100;
  bool _isDarkMode = false;

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
    _updateBackgroundColor("সুবহানাল্লাহ");
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _updateBackgroundColor(selectedPhrase);
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
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

  void _updateBackgroundColor(String phrase) {
    setState(() {
      if (phrase == "সুবহানাল্লাহ") {
        _backgroundColor = _isDarkMode
            ? Colors.green.shade900.withOpacity(0.3)
            : Colors.green.shade100;
      } else if (phrase == "আলহামদুলিল্লাহা") {
        _backgroundColor = _isDarkMode
            ? Colors.blue.shade900.withOpacity(0.3)
            : Colors.blue.shade100;
      } else if (phrase == "আল্লাহু আকবার") {
        _backgroundColor = _isDarkMode
            ? Colors.orange.shade900.withOpacity(0.3)
            : Colors.orange.shade100;
      }
    });
  }

  Future<void> _incrementCount(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPhrase = phrase;
      _updateBackgroundColor(phrase);

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

  // নতুন মেথড: সম্পূর্ণ রিসেট (UI এবং SharedPreferences)
  Future<void> _resetAllCounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // UI কাউন্ট রিসেট
      uiSubhanallahCount = 0;
      uiAlhamdulillahCount = 0;
      uiAllahuakbarCount = 0;

      // SharedPreferences কাউন্ট রিসেট
      subhanallahCount = 0;
      alhamdulillahCount = 0;
      allahuakbarCount = 0;

      // SharedPreferences-এ সেভ করুন
      prefs.setInt("subhanallahCount", 0);
      prefs.setInt("alhamdulillahCount", 0);
      prefs.setInt("allahuakbarCount", 0);

      selectedPhrase = "সুবহানাল্লাহ";
      _updateBackgroundColor("সুবহানাল্লাহ");
    });
  }

  // পুরানো মেথড: শুধু UI রিসেট (নাম পরিবর্তন করে স্পষ্ট করা)
  void _resetUICounts() {
    setState(() {
      uiSubhanallahCount = 0;
      uiAlhamdulillahCount = 0;
      uiAllahuakbarCount = 0;
      selectedPhrase = "সুবহানাল্লাহ";
      _updateBackgroundColor("সুবহানাল্লাহ");
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

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveThemePreference(_isDarkMode);
      _updateBackgroundColor(selectedPhrase);
    });
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

    return MaterialApp(
      debugShowCheckedModeBanner: false, // ✅ Disable debug banner
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.green[800],
              scaffoldBackgroundColor: Colors.grey[900],
              cardColor: Colors.grey[800],
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.green[800],
                elevation: 0,
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.green[800],
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.green[800],
                elevation: 0,
              ),
            ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "ডিজিটাল তসবীহ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: Colors.green[800],
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                size: 20,
              ),
              onPressed: _toggleDarkMode,
              tooltip: _isDarkMode ? "লাইট মোড" : "ডার্ক মোড",
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: "reset_session",
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text("বর্তমান সেশন রিসেট"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "reset_all",
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, size: 20),
                      SizedBox(width: 8),
                      Text("সম্পূর্ণ রিসেট"),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == "reset_session") {
                  _resetUICounts();
                } else if (value == "reset_all") {
                  _resetAllCounts();
                }
              },
            ),
          ],
        ),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: _backgroundColor,
          child: Column(
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
                          color: _isDarkMode ? Colors.grey[800] : Colors.white,
                          child: Container(
                            width: isSmallScreen
                                ? MediaQuery.of(context).size.width * 0.9
                                : MediaQuery.of(context).size.width * 0.7,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  selectedPhrase,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 28 : 32,
                                    fontWeight: FontWeight.bold,
                                    color: _isDarkMode
                                        ? Colors.green[300]
                                        : Colors.green,
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
                                    color: _isDarkMode
                                        ? Colors.green[300]
                                        : Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "বর্তমান সেশন",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "মোট: ${_getTotalCount()}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _isDarkMode
                                        ? Colors.green[300]
                                        : Colors.green,
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
                            Color darkColor = index == 0
                                ? Colors.green[300]!
                                : index == 1
                                ? Colors.blue[300]!
                                : Colors.orange[300]!;

                            return Material(
                              borderRadius: BorderRadius.circular(16),
                              elevation: 4,
                              color: _isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              child: InkWell(
                                onTap: () => _incrementCount(phrase),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: isSmallScreen
                                      ? MediaQuery.of(context).size.width * 0.9
                                      : MediaQuery.of(context).size.width *
                                            0.28,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: _isDarkMode
                                            ? darkColor.withOpacity(0.2)
                                            : color.withOpacity(0.2),
                                        child: Icon(
                                          Icons.favorite,
                                          color: _isDarkMode
                                              ? darkColor
                                              : color,
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
                                            color: _isDarkMode
                                                ? darkColor
                                                : color,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _isDarkMode
                                              ? darkColor.withOpacity(0.1)
                                              : color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          _getCountForPhrase(phrase).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _isDarkMode
                                                ? darkColor
                                                : color,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.transparent,
                child: isSmallScreen
                    ? Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _resetUICounts,
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text(
                              "স্ক্রিন শূন্য (০) করুন",
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isDarkMode
                                  ? Colors.orange[800]
                                  : Colors.orangeAccent,
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
                              backgroundColor: _isDarkMode
                                  ? Colors.blue[800]
                                  : Colors.blueAccent,
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
                                backgroundColor: _isDarkMode
                                    ? Colors.orange[800]
                                    : Colors.orangeAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
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
                              onPressed:
                                  _resetAllCounts, // সম্পূর্ণ রিসেটের জন্য
                              icon: const Icon(Icons.delete_forever, size: 20),
                              label: const Text(
                                "সম্পূর্ণ রিসেট",
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isDarkMode
                                    ? Colors.red[800]
                                    : Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
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
                                backgroundColor: _isDarkMode
                                    ? Colors.blue[800]
                                    : Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
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
        ),
      ),
    );
  }

  Widget _buildBenefitCard(String title, String benefit, BuildContext context) {
    final isDark = _isDarkMode;
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
