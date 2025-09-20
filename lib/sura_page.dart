import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'json_loader.dart';
import 'ad_helper.dart';

class SuraPage extends StatefulWidget {
  const SuraPage({Key? key}) : super(key: key);

  @override
  State<SuraPage> createState() => _SuraPageState();
}

class _SuraPageState extends State<SuraPage> {
  List<Map<String, dynamic>> dailySuras = [];
  Set<int> expandedIndices = {};
  bool _isLoading = true;
  bool _showWarning = true; // সতর্কবার্তা শুরুতে দেখাবে

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadSuraData();

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

  Future<void> _loadSuraData() async {
    try {
      final loadedData = await JsonLoader.loadJsonList(
        'assets/daily_suras.json',
      );

      final List<Map<String, dynamic>> convertedData = loadedData
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();

      setState(() {
        dailySuras = convertedData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading sura data: $e');
      setState(() {
        _isLoading = false;
        dailySuras = [
          {
            'title': 'সূরা আল ফাতিহা - الفاتحة',
            'ayat': [
              {
                'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
                'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
                'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
              },
            ],
            'reference': 'কুরআন, সূরা আল ফাতিহা, আয়াত ১-৭',
          },
        ];
      });
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    expandedIndices.clear();
    super.dispose();
  }

  // সুন্দর UI সহ সতর্কবার্তা
  Widget buildWarningBox() {
    return Dismissible(
      key: const ValueKey("warning"),
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        setState(() {
          _showWarning = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.orange.shade50],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "আরবি আয়াত বাংলায় সম্পূর্ণ সুদ্ধভাবে প্রকাশ করা যায় না। বাংলা উচ্চারণ সহায়ক মাত্র, সঠিক তিলাওয়াতের জন্য আরবিতেই পড়ুন।",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showWarning = false;
                });
              },
              child: const Icon(Icons.close, size: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSura(Map<String, dynamic> sura, int index) {
    final bool isExpanded = expandedIndices.contains(index);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 6,
        shadowColor: Colors.green.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                tileColor: isExpanded
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.green[900]
                          : Colors.green[100])
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.green[800]
                          : Colors.green[50]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  sura['title'] ?? '',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.greenAccent
                      : Colors.green[800],
                  size: 28,
                ),
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      expandedIndices.remove(index);
                    } else {
                      expandedIndices.add(index);
                    }
                  });
                },
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isExpanded
                    ? Padding(
                        key: ValueKey('expanded_$index'),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...List<Widget>.from(
                              (sura['ayat'] as List<dynamic>).map(
                                (ay) => Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: SelectableText(
                                        ay['arabic'] ?? '',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontFamily: 'Amiri',
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                          height: 1.6,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ay['transliteration'] ?? '',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontStyle: FontStyle.italic,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.green[200]
                                            : Colors.green[900],
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'অর্থ: ${ay['meaning'] ?? ''}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ),
                            if ((sura['reference'] ?? '').isNotEmpty)
                              Text(
                                'সূত্র: ${sura['reference']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.deepPurple[400],
                                ),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'আরবি, বাংলা ও অর্থসহ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          if (_showWarning) buildWarningBox(), // সতর্ক বার্তা
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: dailySuras.length,
                    itemBuilder: (context, index) =>
                        buildSura(dailySuras[index], index),
                  ),
          ),
          if (_isBannerAdReady)
            SafeArea(
              top: false,
              child: Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
