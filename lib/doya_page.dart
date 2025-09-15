import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart'; // AdHelper ইম্পোর্ট
import 'json_loader.dart'; // JsonLoader ইম্পোর্ট

class DoyaPage extends StatefulWidget {
  const DoyaPage({Key? key}) : super(key: key);

  @override
  State<DoyaPage> createState() => _DoyaPageState();
}

class _DoyaPageState extends State<DoyaPage> {
  List<Map<String, String>> dailyDoyas = [];
  List<Map<String, String>> filteredDoyas = [];
  bool _isSearching = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Bottom Banner
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadDoyaData();

    // AdMob initialize
    AdHelper.initialize();

    // Bottom Banner Ad লোড
    _bottomBannerAd = AdHelper.createBannerAd(
      AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _loadDoyaData() async {
    try {
      final loadedData = await JsonLoader.loadJsonList(
        'assets/dailydoyas.json',
      );

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

      setState(() {
        dailyDoyas = [
          {
            'title': 'বাসা থেকে বের হওয়ার দোয়া',
            'bangla': 'বিসমিল্লাহি তাওয়াক্কালতু আলাল্লাহি...',
            'arabic': 'بِسْمِ اللهِ تَوَكَّلْتُ عَلَى اللهِ...',
            'transliteration': 'বিসমিল্লাহি তাওয়াক্কালতু আলাল্লাহি...',
            'meaning': 'আল্লাহর নামে বের হচ্ছি...',
            'reference': 'আবু দাউদ: 5095; তিরমিযি: 3426;',
          },
        ];
        filteredDoyas = dailyDoyas;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bottomBannerAd.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

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
      return titleLower.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredDoyas = results);
  }

  void _showDoyaDetails(Map<String, String> doya) {
    final String duaTitle = doya['title'] ?? '';
    final String duaArabic = doya['arabic'] ?? '';
    final String duaTransliteration = doya['transliteration'] ?? '';
    final String duaMeaning = doya['meaning'] ?? '';
    final String duaReference = doya['reference'] ?? '';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ডার্ক মোডের জন্য কালার সেট
    final backgroundColor = isDark ? Colors.grey[900] : Colors.green[50];
    final textColor = isDark ? Colors.white : Colors.black;
    final titleColor = isDark ? Colors.green[200] : Colors.green;
    final referenceColor = isDark ? Colors.purple[200] : Colors.deepPurple;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          duaTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                duaArabic,
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'Amiri',
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                duaTransliteration,
                style: TextStyle(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                "অর্থ: $duaMeaning",
                style: TextStyle(fontSize: 20, color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              if (duaReference.isNotEmpty)
                Text(
                  "রেফারেন্স: $duaReference",
                  style: TextStyle(
                    fontSize: 18,
                    color: referenceColor,
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
            icon: Icon(Icons.share, color: Colors.blue),
            label: Text('শেয়ার', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'বন্ধ করুন',
              style: TextStyle(
                color: isDark ? Colors.green[200] : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoyaCard(Map<String, String> doya) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            Text(doya['bangla'] ?? '', style: const TextStyle(fontSize: 18)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
        onTap: () => _showDoyaDetails(doya),
      ),
    );
  }

  Widget _buildInlineBanner() {
    final BannerAd inlineAd = AdHelper.createBannerAd(
      AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: inlineAd.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: inlineAd),
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
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredDoyas.length,
                    itemBuilder: (context, index) {
                      final doya = filteredDoyas[index];
                      List<Widget> widgets = [_buildDoyaCard(doya)];

                      // প্রতি ৫ টা দোয়ার পর ব্যানার অ্যাড
                      if ((index + 1) % 5 == 0) {
                        widgets.add(_buildInlineBanner());
                      }

                      return Column(children: widgets);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _isBottomBannerAdReady
          ? SafeArea(
              child: Container(
                width: double.infinity,
                height: _bottomBannerAd.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bottomBannerAd),
              ),
            )
          : null,
    );
  }
}
