import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'json_loader.dart'; // JsonLoader ইম্পোর্ট করুন

class SuraPage extends StatefulWidget {
  const SuraPage({Key? key}) : super(key: key);

  @override
  State<SuraPage> createState() => _SuraPageState();
}

class _SuraPageState extends State<SuraPage> {
  List<Map<String, dynamic>> dailySuras = []; // খালি লিস্ট দিয়ে শুরু করুন
  Set<int> expandedIndices = {}; // multiple expand
  bool _isLoading = true; // লোডিং স্টেট ট্র্যাক করার জন্য

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadSuraData(); // JSON ডেটা লোড করার মেথড কল করুন

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  // JSON ডেটা লোড করার মেথড
  Future<void> _loadSuraData() async {
    try {
      final loadedData = await JsonLoader.loadJsonList(
        'assets/daily_suras.json',
      );

      // List<dynamic> কে List<Map<String, dynamic>> এ কনভার্ট করুন
      final List<Map<String, dynamic>> convertedData = loadedData
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();

      setState(() {
        dailySuras = convertedData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading sura data: $e');
      setState(() => _isLoading = false);

      // Fallback ডেটা (যদি JSON লোড করতে ব্যর্থ হয়)
      setState(() {
        dailySuras = [
          {
            'title': 'সূরা আল ফাতিহা - الفاتحة',
            'ayat': [
              {
                'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
                'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
                'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
              },
              {
                'arabic': 'الْحَمْدُ لِلّهِ رَبِّ الْعَالَمِينَ',
                'transliteration': 'আলহামদু লিল্লাহি রাব্বিল ‘আলামীন',
                'meaning':
                    'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি সমস্ত জগতের পালনকর্তা।',
              },
              {
                'arabic': 'الرَّحْمٰنِ الرَّحِيمِ',
                'transliteration': 'আর-রাহমানির রাহিম',
                'meaning': 'পরম করুণাময়, পরম দয়ালু।',
              },
              {
                'arabic': 'مَالِكِ يَوْمِ الدِّينِ',
                'transliteration': 'মালিকি ইয়াওমিদ-দ্বিন',
                'meaning': 'বিচার দিবসের মালিক।',
              },
              {
                'arabic': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
                'transliteration': 'ইয়্যাকা নাআবুদু ওয়া ইয়্যাকা নাস্তাইন',
                'meaning':
                    'আমরা কেবল আপনাকেই উপাসনা করি এবং কেবল আপনাকেই সাহায্য চাই।',
              },
              {
                'arabic': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
                'transliteration': 'ইহদিনাস-সিরাতাল মুস্তাকীম',
                'meaning': 'আমাদের সরল পথ প্রদর্শন করুন।',
              },
              {
                'arabic':
                    'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
                'transliteration':
                    'সিরাতাল লাযীনা আনআমতা আলাইহিম গাইরিল মাগদুবি আলাইহিম ওয়ালাদ-দাল্লীন',
                'meaning':
                    'তাদের পথ যাদের প্রতি আপনি কৃপা করেছেন, যারা অভিশাপপ্রাপ্ত নয়, এবং যারা পথভ্রষ্ট নয়।',
              },
            ],
            'reference': 'কুরআন, সূরা আল ফাতিহা, আয়াত ১-৭',
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    expandedIndices.clear(); // exit page -> collapse all
    super.dispose();
  }

  Widget buildSura(Map<String, dynamic> sura, int index) {
    final bool isExpanded = expandedIndices.contains(index);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 10,
        shadowColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.greenAccent.withOpacity(0.6)
            : Colors.green.withOpacity(0.5),
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
                    fontSize: 22,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                          fontSize: 28,
                                          fontFamily: 'Amiri',
                                          fontWeight: FontWeight.w700,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ay['transliteration'] ?? '',
                                      style: TextStyle(
                                        fontSize: 18,
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
                                        fontSize: 17,
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
                                  fontSize: 14,
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
              top: false, // সিস্টেম বার ঢেকে না যাওয়ার জন্য
              child: Container(
                width: double.infinity, // পুরো প্রস্থ
                color: Colors.transparent,
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width, // স্ক্রিন ফিল
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
