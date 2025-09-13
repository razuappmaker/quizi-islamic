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
    });
  }

  int _getCurrentCount() {
    if (selectedPhrase == "সুবহানাল্লাহ") return subhanallahCount;
    if (selectedPhrase == "আলহামদুলিল্লাহা") return alhamdulillahCount;
    if (selectedPhrase == "আল্লাহু আকবার") return allahuakbarCount;
    return 0;
  }

  Future<void> _incrementCount(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPhrase = phrase;
      if (phrase == "সুবহানাল্লাহ") {
        subhanallahCount++;
        prefs.setInt("subhanallahCount", subhanallahCount);
      }
      if (phrase == "আলহামদুলিল্লাহা") {
        alhamdulillahCount++;
        prefs.setInt("alhamdulillahCount", alhamdulillahCount);
      }
      if (phrase == "আল্লাহু আকবার") {
        allahuakbarCount++;
        prefs.setInt("allahuakbarCount", allahuakbarCount);
      }
    });
  }

  Future<void> _resetCounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subhanallahCount = 0;
      alhamdulillahCount = 0;
      allahuakbarCount = 0;
      prefs.setInt("subhanallahCount", 0);
      prefs.setInt("alhamdulillahCount", 0);
      prefs.setInt("allahuakbarCount", 0);
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

    // Scaffold সরিয়ে দিন এবং সরাসরি Column রিটার্ন করুন
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          "তসবীহ কাউন্টার",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.green.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              children: [
                Text(
                  selectedPhrase,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  _getCurrentCount().toString(),
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: tasbeehPhrases.length,
            itemBuilder: (context, index) {
              String phrase = tasbeehPhrases[index];
              Color color = colors[index % colors.length];
              return GestureDetector(
                onTap: () => _incrementCount(phrase),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      phrase,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton.icon(
          onPressed: _resetCounts,
          icon: const Icon(Icons.refresh),
          label: const Text("রিসেট"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TasbeehStatsPage(
                  subhanallahCount: subhanallahCount,
                  alhamdulillahCount: alhamdulillahCount,
                  allahuakbarCount: allahuakbarCount,
                ),
              ),
            );
          },
          icon: const Icon(Icons.bar_chart),
          label: const Text("স্ট্যাটস দেখুন"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
