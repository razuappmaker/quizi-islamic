import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'json_loader.dart'; // JsonLoader ইম্পোর্ট করুন

class DoyaPage extends StatefulWidget {
  const DoyaPage({Key? key}) : super(key: key);

  @override
  State<DoyaPage> createState() => _DoyaPageState();
}

class _DoyaPageState extends State<DoyaPage> {
  List<Map<String, String>> dailyDoyas = [];
  List<Map<String, String>> filteredDoyas = [];
  bool _isSearching = false;
  bool _isLoading = true; // লোডিং স্টেট যোগ করুন
  final TextEditingController _searchController = TextEditingController();

  // Banner Ad
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadDoyaData(); // JSON ডেটা লোড করার মেথড কল করুন

    // Banner Ad লোড
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  // JSON ডেটা লোড করার মেথড
  Future<void> _loadDoyaData() async {
    try {
      final loadedData = await JsonLoader.loadJsonList(
        'assets/dailydoyas.json',
      );

      // List<dynamic> কে List<Map<String, String>> এ কনভার্ট করুন
      final List<Map<String, String>> convertedData = loadedData
          .map<Map<String, String>>((item) {
            final Map<String, dynamic> dynamicItem = Map<String, dynamic>.from(
              item,
            );
            return dynamicItem.map(
              (key, value) => MapEntry(key, value.toString()),
            );
          })
          .toList();

      setState(() {
        dailyDoyas = convertedData;
        filteredDoyas = convertedData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading doya data: $e');
      setState(() => _isLoading = false);

      // Fallback ডেটা (যদি JSON লোড করতে ব্যর্থ হয়)
      setState(() {
        dailyDoyas = [
          {
            'title': 'বাসা থেকে বের হওয়ার দোয়া',
            'bangla':
                'বিসমিল্লাহি তাওয়াক্কালতু আলাল্লাহি, ওয়া লা হাওলা ওয়া লা কুওয়াতা ইল্লা বিল্লাহ।',
            'arabic':
                'بِسْمِ اللهِ تَوَكَّلْتُ عَلَى اللهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
            'transliteration':
                'বিসমিল্লাহি তাওয়াক্কালতু আলাল্লাহি, ওয়া লা হাওলা ওয়া লا কুওয়াতা ইল্লা বিল্লাহ।',
            'meaning':
                'আল্লাহর নামে বের হচ্ছি। আল্লাহর উপর ভরসা করলাম। আল্লাহর সাহায্য ছাড়া শক্তি ও ক্ষমতা নেই।',
            'reference': 'আবু দাউদ: 5095; তিরমিযি: 3426; নাসাঈ: 5539',
          },
        ];
        filteredDoyas = dailyDoyas;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      filteredDoyas = dailyDoyas;
      _searchController.clear();
    });
  }

  void _searchDoya(String query) {
    final results = dailyDoyas.where((doya) {
      final titleLower = doya['title']!.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredDoyas = results;
    });
  }

  void _showDoyaDetails(Map<String, String> doya) {
    final String duaTitle = doya['title'] ?? '';
    final String duaArabic = doya['arabic'] ?? '';
    final String duaTransliteration = doya['transliteration'] ?? '';
    final String duaMeaning = doya['meaning'] ?? '';
    final String duaReference = doya['reference'] ?? '';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          duaTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                duaArabic,
                style: const TextStyle(
                  fontSize: 26,
                  fontFamily: 'Amiri',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                duaTransliteration,
                style: const TextStyle(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                "অর্থ: $duaMeaning",
                style: const TextStyle(fontSize: 20, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              if (duaReference.isNotEmpty)
                Text(
                  "রেফারেন্স: $duaReference",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Share.share(
                '$duaTitle\n\n$duaArabic\n\n$duaTransliteration\n\nঅর্থ: $duaMeaning\n\nরেফারেন্স: $duaReference',
              );
            },
            icon: const Icon(Icons.share, color: Colors.blue),
            label: Text(
              'শেয়ার',
              style: TextStyle(
                color: isDark ? Colors.black : Colors.blue,
                fontSize: 18,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'বন্ধ করুন',
              style: TextStyle(
                color: isDark ? Colors.black : Colors.green,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: !_isSearching
            ? const Text(
                'দৈনন্দিন দোয়া',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'দোয়া অনুসন্ধান করুন...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
                onChanged: _searchDoya,
              ),

        actions: [
          !_isSearching
              ? IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _startSearch,
                )
              : IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _stopSearch,
                ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDoyas.isEmpty
                ? const Center(
                    child: Text(
                      'কোন দোয়া পাওয়া যায়নি।',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredDoyas.length,
                    itemBuilder: (context, index) {
                      final doya = filteredDoyas[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        shadowColor: Colors.greenAccent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doya['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                doya['bangla'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.green,
                          ),
                          onTap: () => _showDoyaDetails(doya),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _isBannerAdReady
          ? SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                height: _bannerAd.size.height.toDouble(),
                color: Colors.white,
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd),
              ),
            )
          : null,
    );
  }
}
