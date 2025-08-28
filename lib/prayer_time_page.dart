
import 'dart:async';
import 'dart:convert';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'qibla_page.dart';

import 'package:flutter_compass/flutter_compass.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({Key? key}) : super(key: key);

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage>
    with SingleTickerProviderStateMixin {
  // Prayer Times
  String? cityName = "Loading...";
  String? countryName = "Loading...";
  Map<String, String> prayerTimes = {};
  String nextPrayer = "";
  Duration countdown = Duration.zero;
  Timer? timer;

  // Tasbeeh Counter
  int tasbeehCount = 0;

  // Tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchLocationAndPrayerTimes();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> fetchLocationAndPrayerTimes() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          cityName = placemarks[0].locality ?? "Unknown City";
          countryName = placemarks[0].country ?? "Unknown Country";
        });
      }

      final url =
          "http://api.aladhan.com/v1/timings?latitude=${position
          .latitude}&longitude=${position.longitude}&method=2";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = data["data"]["timings"];

        setState(() {
          prayerTimes = {
            "ফজর": timings["Fajr"],
            "যোহর": timings["Dhuhr"],
            "আসর": timings["Asr"],
            "মাগরিব": timings["Maghrib"],
            "ইশা": timings["Isha"],
          };
        });

        findNextPrayer();
      }
    } catch (e) {
      setState(() {
        cityName = "Error";
        countryName = "Error";
      });
    }
  }

  void findNextPrayer() {
    final now = DateTime.now();
    DateTime? nextPrayerTime;
    String? nextName;

    prayerTimes.forEach((name, time) {
      final parts = time.split(":");
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (prayerTime.isAfter(now) &&
          (nextPrayerTime == null || prayerTime.isBefore(nextPrayerTime!))) {
        nextPrayerTime = prayerTime;
        nextName = name;
      }
    });

    if (nextPrayerTime != null) {
      setState(() {
        nextPrayer = nextName!;
        countdown = nextPrayerTime!.difference(now);
      });

      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          countdown = nextPrayerTime!.difference(DateTime.now());
          if (countdown.isNegative) {
            findNextPrayer();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: const Text("ইসলামিক টুলস"),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.access_time), text: "নামাজ"),
              Tab(icon: Icon(Icons.fingerprint), text: "তসবীহ"),
              Tab(icon: Icon(Icons.explore), text: "কিবলা"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPrayerTab(),
            _buildTasbeehTab(),
            _buildQiblaTab(),
          ],
        ),
      ),
    );
  }

  // ---------- Prayer Tab ----------
  Widget _buildPrayerTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe8f5e9), Color(0xFFc8e6c9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "$cityName, $countryName",
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: prayerTimes.entries.map((entry) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.access_time,
                        color: Colors.green, size: 28),
                    title: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    trailing: Text(entry.value,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.green[100],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text("পরবর্তী ওয়াক্ত: $nextPrayer",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    "${countdown.inHours.toString().padLeft(
                        2, '0')}:${(countdown.inMinutes % 60)
                        .toString()
                        .padLeft(2, '0')}:${(countdown.inSeconds % 60)
                        .toString()
                        .padLeft(2, '0')}",
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tasbeeh Tab ----------
  // State class member
  String selectedPhrase = "সুবহানাল্লাহ"; // <-- এখানে declare করুন

// Tasbeeh Tab
  Widget _buildTasbeehTab() {
    final List<String> tasbeehPhrases = [
      "সুবহানাল্লাহ ( سبحان الل )",
      "আলহামদুলিল্লাহা ( الحمد لله )",
      "আল্লাহু আকবার ( الله أكبر )",
    ];

    final List<Color> colors = [
      Colors.green.shade700,
      Colors.blue.shade700,
      Colors.orange.shade700,
    ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            "তসবীহ কাউন্টার",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.green.shade100,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  Text(
                    selectedPhrase,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$tasbeehCount",
                    style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          Column(
            children: List.generate(tasbeehPhrases.length, (index) {
              String phrase = tasbeehPhrases[index];
              Color color = colors[index % colors.length];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() { // <-- এখানে StatefulWidget এর setState ব্যবহার করুন
                      selectedPhrase = phrase;
                      tasbeehCount++;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Center(
                      child: Text(
                        phrase,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                tasbeehCount = 0;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text("রিসেট"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }






  // ---------- Qibla Tab (Professional Version) ----------
  Widget _buildQiblaTab() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // City & Country Display
          Text(
            "$cityName, $countryName",
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 20),
          // Compass Container
          StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  "কম্পাস পাওয়া যাচ্ছে না",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                );
              }

              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              double? direction = snapshot.data!.heading;

              if (direction == null) {
                return const Text(
                  "কম্পাস চালু করুন",
                  style: TextStyle(fontSize: 18),
                );
              }

              // কিবলা এঙ্গেল মক্কা (21.4225, 39.8262)
              double qiblaDirection = 294; // Approximate angle from most places

              return Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade100.withOpacity(0.3),
                    border: Border.all(color: Colors.green.shade400, width: 4),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: ((direction - qiblaDirection) * (pi / 180) * -1),
                      child: Image.asset(
                        'assets/images/compass.png',
                        height: 250,
                        width: 250,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            "🔺 নীচের সূচক দেখাবে কিবলা দিক",
            style: TextStyle(fontSize: 16, color: Colors.green.shade700),
          ),
        ],
      ),
    );
  }


}
