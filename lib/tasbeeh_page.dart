import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'tasbeeh_stats_page.dart';
import 'ad_helper.dart';

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

  BannerAd? _bannerAd;
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

  Future<void> _loadBannerAd() async {
    try {
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('Banner ad limit reached, not showing ad');
        return;
      }

      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() => _isBannerAdReady = true);
            AdHelper.recordBannerAdShown();
            print('Adaptive Banner ad loaded successfully.');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Adaptive Banner ad failed to load: $error');
            ad.dispose();
            _isBannerAdReady = false;
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Adaptive Banner ad clicked.');
              } else {
                print('Ad click limit reached');
              }
            });
          },
        ),
      );

      await _bannerAd?.load();
    } catch (e) {
      print('Error loading adaptive banner ad: $e');
      _isBannerAdReady = false;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
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

  Future<void> _resetAllCounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      uiSubhanallahCount = 0;
      uiAlhamdulillahCount = 0;
      uiAllahuakbarCount = 0;

      subhanallahCount = 0;
      alhamdulillahCount = 0;
      allahuakbarCount = 0;

      prefs.setInt("subhanallahCount", 0);
      prefs.setInt("alhamdulillahCount", 0);
      prefs.setInt("allahuakbarCount", 0);

      selectedPhrase = "সুবহানাল্লাহ";
      _updateBackgroundColor("সুবহানাল্লাহ");
    });
  }

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
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    // Responsive width calculations
    final double contentWidth = isSmallScreen
        ? screenWidth * 0.92
        : screenWidth * 0.85;

    final double cardWidth = isSmallScreen
        ? screenWidth * 0.9
        : screenWidth * 0.75;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.green[800],
              scaffoldBackgroundColor: Colors.grey[900],
              cardColor: Colors.grey[800],
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.green[800],
                elevation: 0,
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green[800],
          centerTitle: true,
          elevation: 2,
          leading: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded, // একই আইকন
                color: Colors.white,
                size: 20, // একই সাইজ
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              splashRadius: 20, // একই স্প্ল্যাশ রেডিয়াস
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
                size: 22,
              ),
              onPressed: _toggleDarkMode,
              tooltip: _isDarkMode ? "লাইট মোড" : "ডার্ক মোড",
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white, size: 22),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: "reset_session",
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text("বর্তমান সেশন রিসেট"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "reset_all",
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, size: 20, color: Colors.red),
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
        body: Container(
          color: _backgroundColor,
          child: Column(
            children: [
              // Main Content - SafeArea ব্যবহার করে
              Expanded(
                child: SafeArea(
                  bottom: false, // নিচের SafeArea বন্ধ
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: _backgroundColor,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: (screenWidth - contentWidth) / 2,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          // Header Display Card
                          Container(
                            width: cardWidth,
                            margin: EdgeInsets.only(bottom: 20),
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: _isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Text(
                                      selectedPhrase,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 26 : 30,
                                        fontWeight: FontWeight.bold,
                                        color: _isDarkMode
                                            ? Colors.green[300]
                                            : Colors.green[700],
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _getCurrentCount().toString(),
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 52 : 60,
                                        fontWeight: FontWeight.w800,
                                        color: _isDarkMode
                                            ? Colors.green[300]
                                            : Colors.green[700],
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: _isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "বর্তমান সেশন",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "মোট জিকির: ${_getTotalCount()}",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _isDarkMode
                                            ? Colors.green[300]
                                            : Colors.green[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Tasbeeh Buttons
                          Container(
                            width: contentWidth,
                            margin: EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: tasbeehPhrases.asMap().entries.map((
                                entry,
                              ) {
                                int index = entry.key;
                                String phrase = entry.value;
                                Color color = colors[index % colors.length];
                                Color darkColor = index == 0
                                    ? Colors.green[300]!
                                    : index == 1
                                    ? Colors.blue[300]!
                                    : Colors.orange[300]!;

                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: _buildTasbeehButton(
                                    phrase: phrase,
                                    color: color,
                                    darkColor: darkColor,
                                    count: _getCountForPhrase(phrase),
                                    isSelected: selectedPhrase == phrase,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Benefits Card
                          Container(
                            width: contentWidth,
                            child: _buildBenefitCard(
                              "জিকিরের ফজিলত",
                              benefits["সুখ ও মনের প্রশান্তি লাভ"] ?? "",
                              context,
                            ),
                          ),

                          // Extra space for bottom buttons and ad
                          SizedBox(height: _isBannerAdReady ? 80 : 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Section (Buttons + Ad) - SafeArea ব্যবহার করে
              SafeArea(
                top: false, // উপরের SafeArea বন্ধ
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Action Buttons Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: (screenWidth - contentWidth) / 2,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.grey[900] : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: isSmallScreen
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionButton(
                                        icon: Icons.refresh,
                                        text: "সেশন রিসেট",
                                        color: Colors.orange,
                                        onPressed: _resetUICounts,
                                        isSmall: true,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: _buildActionButton(
                                        icon: Icons.bar_chart,
                                        text: "লাইফটাইম স্ট্যাটস",
                                        color: Colors.blue,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TasbeehStatsPage(),
                                            ),
                                          );
                                        },
                                        isSmall: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.refresh,
                                    text: "সেশন রিসেট",
                                    color: Colors.orange,
                                    onPressed: _resetUICounts,
                                    isSmall: false,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.bar_chart,
                                    text: "লাইফটাইম স্ট্যাটস",
                                    color: Colors.blue,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TasbeehStatsPage(),
                                        ),
                                      );
                                    },
                                    isSmall: false,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    // ✅ Adaptive Banner Ad
                    if (_isBannerAdReady && _bannerAd != null)
                      Container(
                        width: double.infinity,
                        height: _bannerAd!.size.height.toDouble(),
                        alignment: Alignment.center,
                        color: _isDarkMode ? Colors.grey[900] : Colors.white,
                        child: AdWidget(ad: _bannerAd!),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasbeehButton({
    required String phrase,
    required Color color,
    required Color darkColor,
    required int count,
    required bool isSelected,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 6 : 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: InkWell(
        onTap: () => _incrementCount(phrase),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: _isDarkMode ? darkColor : color, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isDarkMode
                      ? darkColor.withOpacity(0.15)
                      : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: _isDarkMode ? darkColor : color,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  phrase,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _isDarkMode ? darkColor : color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isDarkMode
                      ? darkColor.withOpacity(0.1)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? darkColor : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
    required bool isSmall,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text, style: TextStyle(fontSize: isSmall ? 14 : 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isDarkMode ? color.withOpacity(0.8) : color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildBenefitCard(String title, String benefit, BuildContext context) {
    final isDark = _isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? Colors.grey[800] : Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Section
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.green[800]!.withOpacity(0.3)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: isDark ? Colors.green[300] : Colors.green.shade700,
                  size: 22,
                ),
              ),

              // Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.green[300]
                            : Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark
                            ? Colors.green[100]
                            : Colors.green.shade900,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
