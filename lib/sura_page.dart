// Sura Page
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
  Map<int, bool> _showFullWarning =
      {}; // Track full warning state for each sura
  double _fontSize = 16.0; // Default font size
  final double _minFontSize = 12.0;
  final double _maxFontSize = 28.0;
  final double _fontSizeStep = 2.0;

  BannerAd? _bannerAd; // ✅ Nullable করুন adaptive banner-এর জন্য
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadSuraData();
    _loadAd(); // ✅ Adaptive banner load
  }

  // ✅ Adaptive Banner Ad লোড করা - অন্যান্য পেইজের মতোই
  Future<void> _loadAd() async {
    try {
      // ✅ AdHelper ব্যবহার করে adaptive banner তৈরি করুন
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

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < _maxFontSize) {
        _fontSize += _fontSizeStep;
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > _minFontSize) {
        _fontSize -= _fontSizeStep;
      }
    });
  }

  void _resetFontSize() {
    setState(() {
      _fontSize = 16.0;
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // ✅ Null safety সহ dispose
    expandedIndices.clear();
    _showFullWarning.clear();
    super.dispose();
  }

  ///============
  // Build the warning widget
  Widget _buildWarningWidget(int index) {
    final bool showFull = _showFullWarning[index] ?? false;

    return showFull
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.orange[900]?.withOpacity(0.15)
                  : Colors.orange[50],
              border: Border.all(
                color: Colors.orange.withOpacity(0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[700],
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'গুরুত্বপূর্ণ সতর্কবার্তা',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange[100]
                            : Colors.orange[900],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // First paragraph
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.6,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                    ),
                    children: const [
                      TextSpan(
                        text:
                            'কুরআনের আয়াত বা আরবি দুআ বাংলায় উচ্চারণ করে পড়লে ',
                      ),
                      TextSpan(
                        text: 'অনেক সময় অর্থের বিকৃতি ঘটে',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '। তাই এ উচ্চারণকে শুধু সহায়ক হিসেবে গ্রহণ করুন।',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 10),

                // Second paragraph with bullet point
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 8),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.orange[700],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'আসুন, আমরা শুদ্ধভাবে কুরআন পড়া শিখি। শুদ্ধ করে কুরআন শিক্ষা করা প্রত্যেক মুসলিমের উপর ফরজ।',
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.6,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showFullWarning[index] = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[600]!, Colors.orange[800]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'বুঝেছি, ধন্যবাদ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFullWarning[index] = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.orange[900]?.withOpacity(0.2)
                      : Colors.orange[50],
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange[700],
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'বাংলা উচ্চরণ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange[100]
                            : Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  //=============
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
                      _showFullWarning[index] = false;
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
                            // Warning message inside expanded sura
                            _buildWarningWidget(index),

                            // Font size controls
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ফন্ট সাইজ:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.zoom_out, size: 20),
                                        onPressed: _decreaseFontSize,
                                        tooltip: 'ফন্ট ছোট করুন',
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[700]
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '${_fontSize.toInt()}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.zoom_in, size: 20),
                                        onPressed: _increaseFontSize,
                                        tooltip: 'ফন্ট বড় করুন',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.restart_alt, size: 20),
                                        onPressed: _resetFontSize,
                                        tooltip: 'ডিফল্ট ফন্ট সাইজ',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            ...List<Widget>.from(
                              (sura['ayat'] as List<dynamic>).map(
                                (ay) => Column(
                                  // InteractiveViewer removed - 2 finger zoom disabled
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: SelectableText(
                                        ay['arabic'] ?? '',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontFamily: 'ScheherazadeNew',
                                          fontWeight: FontWeight.bold,
                                          wordSpacing: 2.5,
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
                                    SelectableText(
                                      ay['transliteration'] ?? '',
                                      style: TextStyle(
                                        fontSize: _fontSize,
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
                                    SelectableText(
                                      'অর্থ: ${ay['meaning'] ?? ''}',
                                      style: TextStyle(
                                        fontSize: _fontSize,
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
                              SelectableText(
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

  //=================
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        centerTitle: true, // শিরোনাম সেন্টারে
        title: const Text(
          'আরবি, বাংলা ও অর্থসহ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'increase',
                child: ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('ফন্ট বড় করুন'),
                  onTap: _increaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'decrease',
                child: ListTile(
                  leading: const Icon(Icons.zoom_out),
                  title: const Text('ফন্ট ছোট করুন'),
                  onTap: _decreaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('ডিফল্ট ফন্ট সাইজ'),
                  onTap: _resetFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: _isBannerAdReady ? 0 : bottomPadding,
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      // Main InteractiveViewer removed - 2 finger zoom disabled
                      itemCount: dailySuras.length,
                      itemBuilder: (context, index) =>
                          buildSura(dailySuras[index], index),
                    ),
            ),
          ),
          // ✅ Adaptive Banner Ad - অন্যান্য পেইজের মতোই
          if (_isBannerAdReady && _bannerAd != null)
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
