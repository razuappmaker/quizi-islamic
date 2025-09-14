import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tasbeeh_stats_page.dart';

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

  // শুধুমাত্র UI-এর জন্য কাউন্টার (SharedPreferences-এ সেভ হবে না)
  int uiSubhanallahCount = 0;
  int uiAlhamdulillahCount = 0;
  int uiAllahuakbarCount = 0;

  // উপকারিতা map
  final Map<String, String> benefits = {
    "সুখ ও মনের প্রশান্তি লাভ":
        "রাসূলুল্লাহ ﷺ বলেছেন: 'নিশ্চয়ই আল্লাহর স্মরণ (জিকির) হৃদয়কে শান্ত করে।' অর্থাৎ, আল্লাহর নাম স্মরণ করা (যেমন: সুবহানাল্লাহ, আলহামদুলিল্লাহা, আল্লাহু আকবার) হৃদয়কে শান্তি দেয়।' (সহীহ মুসলিম, হাদিস: 2697)",
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subhanallahCount = prefs.getInt("subhanallahCount") ?? 0;
      alhamdulillahCount = prefs.getInt("alhamdulillahCount") ?? 0;
      allahuakbarCount = prefs.getInt("allahuakbarCount") ?? 0;

      // UI কাউন্টারও একই মান দিয়ে শুরু করুন
      uiSubhanallahCount = subhanallahCount;
      uiAlhamdulillahCount = alhamdulillahCount;
      uiAllahuakbarCount = allahuakbarCount;
    });
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

  // শুধুমাত্র UI কাউন্ট রিসেট (SharedPreferences-এ সেভ না)
  void _resetUICounts() {
    setState(() {
      uiSubhanallahCount = 0;
      uiAlhamdulillahCount = 0;
      uiAllahuakbarCount = 0;
      selectedPhrase = "সুবহানাল্লাহ";
    });
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

  // বানার অ্যাড উইজেট
  Widget _buildBannerAd() {
    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Center(
        child: Text(
          "বানার অ্যাড",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.green.shade100],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // Header Section
                      Card(
                        elevation: 6, // Elevation আগের মতো করুন
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // BorderRadius আগের মতো করুন
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          // Padding আগের মতো করুন
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            // BorderRadius আগের মতো করুন
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 10, // Blur radius আগের মতো করুন
                                offset: const Offset(
                                  0,
                                  4,
                                ), // Offset আগের মতো করুন
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                selectedPhrase,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 28 : 32,
                                  // ফন্ট সাইজ বড় করুন
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              // Spacing আগের মতো করুন
                              Text(
                                _getCurrentCount().toString(),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 48 : 64,
                                  // ফন্ট সাইজ বড় করুন
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Spacing আগের মতো করুন
                              const Text(
                                "বর্তমান সেশন",
                                style: TextStyle(
                                  fontSize: 16, // ফন্ট সাইজ বড় করুন
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Spacing আগের মতো করুন
                              Text(
                                "মোট: ${_getTotalCount()}",
                                style: const TextStyle(
                                  fontSize: 14, // ফন্ট সাইজ বড় করুন
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tasbeeh Buttons - GridView for better responsiveness
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isSmallScreen ? 1 : 3,
                        childAspectRatio: isSmallScreen ? 3.5 : 2.0,
                        // কার্ড আরও ছোট করতে কমিয়ে দিন
                        crossAxisSpacing: 10,
                        // Spacing আগের মতো করুন
                        mainAxisSpacing: 10,
                        // Spacing আগের মতো করুন
                        padding: const EdgeInsets.all(8),
                        // Padding আগের মতো করুন
                        children: tasbeehPhrases.asMap().entries.map((entry) {
                          int index = entry.key;
                          String phrase = entry.value;
                          Color color = colors[index % colors.length];
                          return Material(
                            borderRadius: BorderRadius.circular(16),
                            // BorderRadius আগের মতো করুন
                            elevation: 4,
                            // Elevation আগের মতো করুন
                            child: InkWell(
                              onTap: () => _incrementCount(phrase),
                              borderRadius: BorderRadius.circular(16),
                              // BorderRadius আগের মতো করুন
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                // Padding আগের মতো করুন
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ), // BorderRadius আগের মতো করুন
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      radius: 20, // আইকন সাইজ বড় করুন
                                      backgroundColor: color.withOpacity(0.2),
                                      child: Icon(
                                        Icons.favorite,
                                        color: color,
                                        size: 20, // আইকন সাইজ বড় করুন
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        phrase,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 18 : 20,
                                          // ফন্ট সাইজ বড় করুন
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
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ), // BorderRadius আগের মতো করুন
                                      ),
                                      child: Text(
                                        _getCountForPhrase(phrase).toString(),
                                        style: TextStyle(
                                          fontSize: 16, // ফন্ট সাইজ বড় করুন
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

                      // জিকিরের উপকারিতা কার্ড
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

            // Action Buttons - সবসময় নিচে দেখাবে
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              // Padding সামান্য বাড়ান
              color: Colors.transparent,
              child: isSmallScreen
                  ? Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _resetUICounts,
                          icon: const Icon(Icons.refresh, size: 20),
                          // আইকন সাইজ বড় করুন
                          label: const Text(
                            "সেশন রিসেট",
                            style: TextStyle(fontSize: 16), // ফন্ট সাইজ বড় করুন
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            // Padding সামান্য বাড়ান
                            minimumSize: const Size(double.infinity, 50),
                            // Height সামান্য বাড়ান
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // BorderRadius আগের মতো করুন
                            ),
                            elevation: 3, // Elevation আগের মতো করুন
                          ),
                        ),
                        const SizedBox(height: 12), // Spacing সামান্য বাড়ান
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
                          // আইকন সাইজ বড় করুন
                          label: const Text(
                            "লাইফটাইম স্ট্যাটস",
                            style: TextStyle(fontSize: 16), // ফন্ট সাইজ বড় করুন
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            // Padding সামান্য বাড়ান
                            minimumSize: const Size(double.infinity, 50),
                            // Height সামান্য বাড়ান
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // BorderRadius আগের মতো করুন
                            ),
                            elevation: 3, // Elevation আগের মতো করুন
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
                            // আইকন সাইজ বড় করুন
                            label: const Text(
                              "সেশন রিসেট",
                              style: TextStyle(
                                fontSize: 16,
                              ), // ফন্ট সাইজ বড় করুন
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              // Padding আগের মতো করুন
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // BorderRadius আগের মতো করুন
                              ),
                              elevation: 3, // Elevation আগের মতো করুন
                            ),
                          ),
                        ),
                        const SizedBox(width: 12), // Spacing আগের মতো করুন
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
                            // আইকন সাইজ বড় করুন
                            label: const Text(
                              "লাইফটাইম স্ট্যাটস",
                              style: TextStyle(
                                fontSize: 16,
                              ), // ফন্ট সাইজ বড় করুন
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              // Padding আগের মতো করুন
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // BorderRadius আগের মতো করুন
                              ),
                              elevation: 3, // Elevation আগের মতো করুন
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            // বানার অ্যাড - শুধুমাত্র নিচে
            _buildBannerAd(),
          ],
        ),
      ),
    );
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
}
