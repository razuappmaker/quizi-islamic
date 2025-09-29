// word_by_word_quran_page.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'json_loader.dart';
import 'ad_helper.dart';
import 'utils/responsive_utils.dart';
import 'network_json_loader.dart';

class WordByWordQuranPage extends StatefulWidget {
  const WordByWordQuranPage({Key? key}) : super(key: key);

  @override
  State<WordByWordQuranPage> createState() => _WordByWordQuranPageState();
}

class _WordByWordQuranPageState extends State<WordByWordQuranPage> {
  List<Map<String, dynamic>> wordSuras = [];
  Set<int> expandedIndices = {};
  bool _isLoading = true;
  double _fontSize = 16.0;
  final double _minFontSize = 12.0;
  final double _maxFontSize = 28.0;
  final double _fontSizeStep = 2.0;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadWordQuranData();
    _loadAd();
  }

  Future<void> _loadWordQuranData() async {
    try {
      // NetworkJsonLoader ব্যবহার করে ডেটা লোড করুন
      final loadedData = await NetworkJsonLoader.loadJsonList(
        'assets/wordquran.json',
      );

      final List<Map<String, dynamic>> convertedData = loadedData
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();

      setState(() {
        wordSuras = convertedData;
        _isLoading = false;
      });

      print('✅ Word Quran data loaded successfully from network/assets');
    } catch (e) {
      debugPrint('Error loading word by word Quran data: $e');

      // Fallback ডেটা - NetworkJsonLoader ইতিমধ্যে ডিফল্ট ডেটা দিয়েছে,
      // কিন্তু যদি তাও ব্যর্থ হয়, তাহলে এই ডিফল্ট ডেটা ব্যবহার করুন
      setState(() {
        _isLoading = false;
        wordSuras = [
          {
            'title': 'সূরা আল ফাতিহা - الفاتحة',
            'ayat': [
              {
                'arabic_words': [
                  {'word': 'بِسْمِ', 'meaning': 'নামে'},
                  {'word': 'ٱللَّٰهِ', 'meaning': 'আল্লাহর'},
                  {'word': 'ٱلرَّحْمَٰنِ', 'meaning': 'পরম করুণাময়'},
                  {'word': 'ٱلرَّحِيمِ', 'meaning': 'অতি দয়ালু'},
                ],
                'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
                'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
              },
            ],
            'reference': 'কুরআন, সূরা আল ফাতিহা, আয়াত ১-৭',
          },
        ];
      });

      print('⚠️ Using fallback default data for word Quran');
    }
  }

  Future<void> _loadAd() async {
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

  // রেসপনসিভ ফন্ট সাইজ ক্যালকুলেটর
  double _getResponsiveFontSize(double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    double scaleFactor = mediaQuery.textScaleFactor;

    if (isTablet(context)) {
      scaleFactor *= 1.3;
    }

    return baseSize * scaleFactor;
  }

  // রেসপনসিভ প্যাডিং ক্যালকুলেটর
  double _getResponsivePadding(double basePadding) {
    if (isTablet(context)) {
      return basePadding * 1.5;
    }
    return basePadding;
  }

  _buildWordByWordSection(List<dynamic> arabicWords) {
    final bool tablet = isTablet(context);
    final double cardPadding = _getResponsivePadding(12);
    final double wordSpacing = _getResponsivePadding(8);

    // Color ভেরিয়েবল তৈরি করুন
    final Color titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.green[200]!
        : Colors.green[800]!;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      margin: EdgeInsets.only(bottom: _getResponsivePadding(16)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.green[900]?.withOpacity(0.1)
            : Colors.green[50],
        borderRadius: BorderRadius.circular(_getResponsivePadding(12)),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: tablet ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* ResponsiveText(
            'শব্দে শব্দে অর্থ:',
            fontSize: tablet ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: titleColor, // ✅ ভেরিয়েবল ব্যবহার করুন
          ),*/
          ResponsiveSizedBox(height: 8),
          // রেসপনসিভ RTL Wrap
          Container(
            width: double.infinity,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                spacing: wordSpacing,
                runSpacing: wordSpacing,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: arabicWords.map<Widget>((wordData) {
                  final word = wordData['word'] ?? '';
                  final meaning = wordData['meaning'] ?? '';

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getResponsivePadding(12),
                      vertical: _getResponsivePadding(6),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.green[800]?.withOpacity(0.3)
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(
                        _getResponsivePadding(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          word,
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(
                              _fontSize + (tablet ? 6 : 4),
                            ),
                            fontFamily: 'ScheherazadeNew',
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        ResponsiveSizedBox(height: 4),
                        Text(
                          meaning,
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(
                              _fontSize - (tablet ? 0 : 2),
                            ),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.green[200]
                                : Colors.green[800],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWordSura(Map<String, dynamic> sura, int index) {
    final bool isExpanded = expandedIndices.contains(index);
    final bool tablet = isTablet(context);
    final double cardPadding = _getResponsivePadding(12);

    return ResponsivePadding(
      horizontal: tablet ? 16 : 12,
      vertical: tablet ? 8 : 4,
      child: Material(
        borderRadius: BorderRadius.circular(_getResponsivePadding(16)),
        elevation: tablet ? 8 : 6,
        shadowColor: Colors.green.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(_getResponsivePadding(16)),
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
                  borderRadius: BorderRadius.circular(
                    _getResponsivePadding(16),
                  ),
                ),
                title: ResponsiveText(
                  sura['title'] ?? '',
                  fontSize: tablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
                trailing: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueAccent
                      : Colors.green[800],
                  size: _getResponsiveFontSize(tablet ? 32 : 28),
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
                        key: ValueKey('word_expanded_$index'),
                        padding: EdgeInsets.all(_getResponsivePadding(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // রেসপনসিভ ফন্ট কন্ট্রোল
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: _getResponsivePadding(8),
                                horizontal: _getResponsivePadding(12),
                              ),
                              margin: EdgeInsets.only(
                                bottom: _getResponsivePadding(16),
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(
                                  _getResponsivePadding(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ResponsiveText(
                                    'ফন্ট সাইজ:',
                                    fontSize: tablet ? 16 : 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                  Row(
                                    children: [
                                      ResponsiveIconButton(
                                        icon: Icons.zoom_out,
                                        iconSize: tablet ? 24 : 20,
                                        onPressed: _decreaseFontSize,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white70
                                            : Colors.black87,
                                        semanticsLabel: 'ফন্ট ছোট করুন',
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: _getResponsivePadding(12),
                                          vertical: _getResponsivePadding(4),
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[700]
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            _getResponsivePadding(6),
                                          ),
                                        ),
                                        child: ResponsiveText(
                                          '${_fontSize.toInt()}',
                                          fontSize: tablet ? 16 : 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      ResponsiveIconButton(
                                        icon: Icons.zoom_in,
                                        iconSize: tablet ? 24 : 20,
                                        onPressed: _increaseFontSize,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white70
                                            : Colors.black87,
                                        semanticsLabel: 'ফন্ট বড় করুন',
                                      ),
                                      ResponsiveIconButton(
                                        icon: Icons.restart_alt,
                                        iconSize: tablet ? 24 : 20,
                                        onPressed: _resetFontSize,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white70
                                            : Colors.black87,
                                        semanticsLabel: 'ডিফল্ট ফন্ট সাইজ',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            ...List<Widget>.from(
                              (sura['ayat'] as List<dynamic>).map(
                                (ay) => Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // সম্পূর্ণ আয়াত
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: SelectableText(
                                        (ay['arabic_words'] as List<dynamic>)
                                            .map<String>(
                                              (word) => word['word'] ?? '',
                                            )
                                            .join(' '),
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(
                                            tablet ? 30 : 26,
                                          ),
                                          fontFamily: 'ScheherazadeNew',
                                          fontWeight: FontWeight.bold,
                                          wordSpacing: tablet ? 3.0 : 2.5,
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
                                    ResponsiveSizedBox(height: 12),

                                    // শব্দে শব্দে অর্থ সেকশন
                                    if (ay['arabic_words'] != null)
                                      _buildWordByWordSection(
                                        ay['arabic_words'],
                                      ),

                                    // বাংলা উচ্চারণ
                                    SelectableText(
                                      ay['transliteration'] ?? '',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(
                                          _fontSize,
                                        ),
                                        fontStyle: FontStyle.italic,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.green[200]
                                            : Colors.green[900],
                                        height: 1.4,
                                      ),
                                    ),
                                    ResponsiveSizedBox(height: 8),

                                    // সম্পূর্ণ অর্থ
                                    SelectableText(
                                      'সম্পূর্ণ অর্থ: ${ay['meaning'] ?? ''}',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(
                                          _fontSize,
                                        ),
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[300]
                                            : Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                    ResponsiveSizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            if ((sura['reference'] ?? '').isNotEmpty)
                              SelectableText(
                                'সূত্র: ${sura['reference']}',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(
                                    tablet ? 15 : 13,
                                  ),
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
  void dispose() {
    _bannerAd?.dispose();
    expandedIndices.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = isTablet(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        centerTitle: true,
        title: ResponsiveText(
          'শব্দে শব্দে কুরআন',
          fontSize: tablet ? 22 : 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.text_fields,
              color: Colors.white,
              size: _getResponsiveFontSize(tablet ? 28 : 24),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'increase',
                child: ListTile(
                  leading: Icon(
                    Icons.zoom_in,
                    size: _getResponsiveFontSize(20),
                  ),
                  title: ResponsiveText('ফন্ট বড় করুন', fontSize: 14),
                  onTap: _increaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'decrease',
                child: ListTile(
                  leading: Icon(
                    Icons.zoom_out,
                    size: _getResponsiveFontSize(20),
                  ),
                  title: ResponsiveText('ফন্ট ছোট করুন', fontSize: 14),
                  onTap: _decreaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(
                    Icons.restart_alt,
                    size: _getResponsiveFontSize(20),
                  ),
                  title: ResponsiveText('ডিফল্ট ফন্ট সাইজ', fontSize: 14),
                  onTap: _resetFontSize,
                ),
              ),
            ],
          ),
          ResponsiveSizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        // ✅ SafeArea দিয়ে wrap করলাম
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green[700]!,
                        ),
                        strokeWidth: tablet ? 3.0 : 2.0,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: tablet ? 16 : 8),
                      itemCount: wordSuras.length,
                      itemBuilder: (context, index) =>
                          buildWordSura(wordSuras[index], index),
                    ),
            ),
            if (_isBannerAdReady && _bannerAd != null)
              Container(
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
