// sura_page.dart (আপডেটেড - শুধু ডার্ক মুড সাপোর্ট)
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'json_loader.dart';
import 'ad_helper.dart';
import 'word_by_word_quran_page.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';

class SuraPage extends StatefulWidget {
  const SuraPage({Key? key}) : super(key: key);

  @override
  State<SuraPage> createState() => _SuraPageState();
}

class _SuraPageState extends State<SuraPage> {
  List<Map<String, dynamic>> dailySuras = [];
  Set<int> expandedIndices = {};
  bool _isLoading = true;
  Map<int, bool> _showFullWarning = {};
  double _fontSize = 16.0;
  final double _minFontSize = 12.0;
  final double _maxFontSize = 28.0;
  final double _fontSizeStep = 2.0;

  // Anchor Ads related variables
  BannerAd? _anchorAd;
  bool _isAnchorAdReady = false;
  bool _showAnchorAd = true;

  // ==================== ভাষা টেক্সট ডিক্লেয়ারেশন ====================
  static const Map<String, Map<String, String>> _texts = {
    'pageTitle': {'en': 'Holy Surahs', 'bn': 'পবিত্র সুরাসমূহ'},
    'loading': {'en': 'Loading Surahs...', 'bn': 'সুরা লোড হচ্ছে...'},
    'noSuraFound': {'en': 'No Surahs Found', 'bn': 'কোন সুরা পাওয়া যায়নি'},
    'wordByWordQuran': {'en': 'Word by Word Quran', 'bn': 'শব্দে শব্দে কুরআন'},
    'fontSize': {'en': 'Font Size', 'bn': 'ফন্ট সাইজ'},
    'decreaseFont': {'en': 'Decrease font', 'bn': 'ফন্ট ছোট করুন'},
    'defaultFont': {'en': 'Default font size', 'bn': 'ডিফল্ট ফন্ট সাইজ'},
    'increaseFont': {'en': 'Increase font', 'bn': 'ফন্ট বড় করুন'},
    'importantWarning': {
      'en': 'Important Warning',
      'bn': 'গুরুত্বপূর্ণ সতর্কবার্তা',
    },
    'warningTitle': {'en': 'English Pronunciation', 'bn': 'বাংলা উচ্চরণ'},
    'warningContent1': {
      'en':
          'When reading Quranic verses or Arabic prayers in English pronunciation, ',
      'bn': 'কুরআনের আয়াত বা আরবি দুআ বাংলায় উচ্চারণ করে পড়লে ',
    },
    'warningContent2': {
      'en': 'meaning distortion often occurs',
      'bn': 'অনেক সময় অর্থের বিকৃতি ঘটে',
    },
    'warningContent3': {
      'en': '. So take this pronunciation only as a helper.',
      'bn': '। তাই এ উচ্চারণকে শুধু সহায়ক হিসেবে গ্রহণ করুন।',
    },
    'warningContent4': {
      'en':
          'Let us learn to read the Quran correctly. Learning to read the Quran correctly is obligatory for every Muslim.',
      'bn':
          'আসুন, আমরা শুদ্ধভাবে কুরআন পড়া শিখি। শুদ্ধ করে কুরআন শিক্ষা করা প্রত্যেক মুসলিমের উপর ফরজ।',
    },
    'understoodThanks': {'en': 'Understood, Thanks', 'bn': 'বুঝেছি, ধন্যবাদ'},
    'meaning': {'en': 'Meaning', 'bn': 'অর্থ'},
    'source': {'en': 'Source', 'bn': 'সূত্র'},
    'makki': {'en': 'Makki', 'bn': 'মাক্কি'},
    'madani': {'en': 'Madani', 'bn': 'মাদিনী'},
    'verses': {'en': 'verses', 'bn': 'আয়াত'},
    'close': {'en': 'Close', 'bn': 'বন্ধ'},
  };

  // হেল্পার মেথড - ভাষা অনুযায়ী টেক্সট পাওয়ার জন্য
  String _text(String key, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadSuraData();
    _loadAnchorAd();
  }

  Future<void> _loadAnchorAd() async {
    try {
      _anchorAd = await AdHelper.createAnchoredBannerAd(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() {
              _isAnchorAdReady = true;
              _showAnchorAd = true;
            });
            print('Anchor Banner ad loaded successfully.');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Anchor Banner ad failed to load: $error');
            setState(() {
              _isAnchorAdReady = false;
              _showAnchorAd = false;
            });
          },
        ),
      );
    } catch (e) {
      print('Error loading anchor ad: $e');
      setState(() {
        _isAnchorAdReady = false;
        _showAnchorAd = false;
      });
    }
  }

  void _closeAnchorAd() {
    setState(() {
      _showAnchorAd = false;
    });
  }

  //-----------------------------------------
  Future<void> _loadSuraData() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );

      // ভাষা অনুযায়ী JSON ফাইল সিলেক্ট করুন
      final String jsonFile = languageProvider.isEnglish
          ? 'assets/en_daily_suras.json'
          : 'assets/daily_suras.json';

      final loadedData = await JsonLoader.loadJsonList(jsonFile);

      final List<Map<String, dynamic>> convertedData = loadedData
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();

      setState(() {
        dailySuras = convertedData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading sura data: $e');
      // Fallback data
      setState(() {
        _isLoading = false;
        dailySuras = _getFallbackData();
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackData() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isEnglish = languageProvider.isEnglish;

    return [
      {
        'title': isEnglish
            ? 'Surah Al-Fatihah - الفاتحة'
            : 'সূরা আল ফাতিহা - الفاتحة',
        'serial': 1,
        'type': isEnglish ? 'Makki' : 'মাক্কি',
        'ayat_count': 7,
        'ayat': [
          {
            'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
            'transliteration': isEnglish
                ? 'Bismillahir Rahmanir Rahim'
                : 'বিসমিল্লাহির রাহমানির রাহিম',
            'meaning': isEnglish
                ? 'In the name of Allah, the Most Gracious, the Most Merciful.'
                : 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
          },
        ],
        'reference': isEnglish
            ? 'Quran, Surah Al-Fatihah, Verses 1-7'
            : 'কুরআন, সূরা আল ফাতিহা, আয়াত ১-৭',
      },
    ];
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

  void _navigateToWordByWordQuran() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WordByWordQuranPage()),
    );
  }

  @override
  void dispose() {
    _anchorAd?.dispose();
    expandedIndices.clear();
    _showFullWarning.clear();
    super.dispose();
  }

  // কালার হেল্পার মেথড - শুধু ডার্ক মুডের জন্য আপডেট
  Color _getPrimaryColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors
              .darkPrimary // ডার্ক মুডে প্রাইমারী কালার
        : Color(0xFF2E7D32); // লাইট মুডে আগের কালার
  }

  Color _getBackgroundColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors
              .darkBackground // ডার্ক মুডে ব্যাকগ্রাউন্ড
        : Color(0xFFFAFAFA); // লাইট মুডে আগের কালার
  }

  Color _getCardColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors
              .darkCard // ডার্ক মুডে কার্ড কালার
        : Colors.white70; // লাইট মুডে আগের কালার
  }

  Color _getHeaderColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors
              .darkSurface // ডার্ক মুডে হেডার কালার
        : Colors.white10; // লাইট মুডে আগের কালার
  }

  Color _getTextColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors
              .darkText // ডার্ক মুডে টেক্সট কালার
        : Color(0xFF37474F); // লাইট মুডে আগের কালার
  }

  Color _getSecondaryTextColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors
              .darkTextSecondary // ডার্ক মুডে সেকেন্ডারী টেক্সট
        : Color(0xFF546E7A); // লাইট মুডে আগের কালার
  }

  Color _getBorderColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors
              .darkBorder // ডার্ক মুডে বর্ডার কালার
        : Color(0xFFE0E0E0); // লাইট মুডে আগের কালার
  }

  Color _getHeaderTextColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? Colors
              .white // ডার্ক মুডে হেডার টেক্সট
        : Color(0xFF2E7D32); // লাইট মুডে আগের কালার
  }

  Color _getHeaderIconColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? Colors
              .white // ডার্ক মুডে হেডার আইকন
        : Color(0xFF2E7D32); // লাইট মুডে আগের কালার
  }

  Widget _buildWarningWidget(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final bool showFull = _showFullWarning[index] ?? false;

    return showFull
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCard : Color(0xFFFFF8E1),
              border: Border.all(
                color: isDarkMode ? AppColors.darkBorder : Color(0xFFFFD54F),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: isDarkMode ? Color(0xFFFFB74D) : Color(0xFFF57C00),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _text('importantWarning', context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode
                            ? Color(0xFFFFB74D)
                            : Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.6,
                      color: _getSecondaryTextColor(context),
                    ),
                    children: [
                      TextSpan(text: _text('warningContent1', context)),
                      TextSpan(
                        text: _text('warningContent2', context),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: _text('warningContent3', context)),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 8),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDarkMode
                            ? Color(0xFFFFB74D)
                            : Color(0xFFF57C00),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _text('warningContent4', context),
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.6,
                          color: _getSecondaryTextColor(context),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
                          colors: [
                            isDarkMode ? Color(0xFFFFB74D) : Color(0xFFFFB300),
                            isDarkMode ? Color(0xFFFF9800) : Color(0xFFF57C00),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Color(0xFFFFB74D).withOpacity(0.3)
                                : Color(0xFFFFB300).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _text('understoodThanks', context),
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
                  color: isDarkMode ? AppColors.darkCard : Color(0xFFFFF8E1),
                  border: Border.all(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : Color(0xFFFFD54F),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: isDarkMode ? Color(0xFFFFB74D) : Color(0xFFF57C00),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _text('warningTitle', context),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Color(0xFFFFB74D)
                            : Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildSuraHeader(Map<String, dynamic> sura, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final serial = sura['serial'] ?? (index + 1);
    final type = sura['type'] ?? 'মাক্কি';
    final ayatCount =
        sura['ayat_count'] ?? (sura['ayat'] as List?)?.length ?? 0;
    final title = sura['title'] ?? '';
    final bool isExpanded = expandedIndices.contains(index);

    // Convert type based on language
    String displayType = type;
    if (type == 'মাক্কি') {
      displayType = _text('makki', context);
    } else if (type == 'মাদিনী') {
      displayType = _text('madani', context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: _getHeaderColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(color: _getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          // সিরিয়াল নং
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : _getPrimaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.3)
                    : _getPrimaryColor(context).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '$serial',
              style: TextStyle(
                color: _getHeaderTextColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // সূরা টাইটেল এবং তথ্য
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _getHeaderTextColor(context),
                    fontFamily: 'ScheherazadeNew',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // মাক্কি/মাদিনা ব্যাজ
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: type == 'মাক্কি' || type == 'Makki'
                            ? (isDarkMode
                                  ? Color(0xFFFFB74D)
                                  : Color(0xFFFFA000))
                            : (isDarkMode
                                  ? Color(0xFF4FC3F7)
                                  : Color(0xFF1976D2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        displayType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // আয়াত সংখ্যা
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : _getPrimaryColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.3)
                              : _getPrimaryColor(context).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.library_books_rounded,
                            color: _getHeaderIconColor(context),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$ayatCount ${_text('verses', context)}',
                            style: TextStyle(
                              color: _getHeaderTextColor(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // এক্সপ্যান্ড আইকন
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : _getPrimaryColor(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.expand_more_rounded,
                color: _getHeaderIconColor(context),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSura(Map<String, dynamic> sura, int index) {
    final bool isExpanded = expandedIndices.contains(index);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: Theme.of(context).brightness == Brightness.dark ? 1 : 2,
        shadowColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.5)
            : Colors.grey.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            color: _getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBorderColor(context), width: 1),
          ),
          child: Column(
            children: [
              // হেডার সেকশন
              GestureDetector(
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
                child: _buildSuraHeader(sura, index),
              ),

              // কন্টেন্ট সেকশন
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isExpanded
                    ? Padding(
                        key: ValueKey('expanded_$index'),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // সতর্কবার্তা
                            _buildWarningWidget(index),

                            // ফন্ট কন্ট্রোল
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: _getBackgroundColor(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getBorderColor(context),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.text_fields_rounded,
                                        color: _getPrimaryColor(context),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _text('fontSize', context),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: _getTextColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Slider(
                                          value: _fontSize,
                                          min: _minFontSize,
                                          max: _maxFontSize,
                                          divisions:
                                              ((_maxFontSize - _minFontSize) /
                                                      _fontSizeStep)
                                                  .round(),
                                          onChanged: (value) {
                                            setState(() {
                                              _fontSize = value;
                                            });
                                          },
                                          activeColor: _getPrimaryColor(
                                            context,
                                          ),
                                          inactiveColor:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Color(0xFF404040)
                                              : Color(0xFFBDBDBD),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getPrimaryColor(
                                            context,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: _getPrimaryColor(
                                              context,
                                            ).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          '${_fontSize.toInt()}px',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: _getPrimaryColor(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildFontSizeButton(
                                        icon: Icons.zoom_out_rounded,
                                        onPressed: _decreaseFontSize,
                                        tooltip: _text('decreaseFont', context),
                                      ),
                                      _buildFontSizeButton(
                                        icon: Icons.restart_alt_rounded,
                                        onPressed: _resetFontSize,
                                        tooltip: _text('defaultFont', context),
                                      ),
                                      _buildFontSizeButton(
                                        icon: Icons.zoom_in_rounded,
                                        onPressed: _increaseFontSize,
                                        tooltip: _text('increaseFont', context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // আয়াতসমূহ
                            ...List<Widget>.from(
                              (sura['ayat'] as List<dynamic>).map(
                                (ay) => Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: _getBackgroundColor(context),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getBorderColor(context),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // আরবি টেক্সট (সবসময় আরবি থাকে)
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: SelectableText(
                                          ay['arabic'] ?? '',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontFamily: 'ScheherazadeNew',
                                            fontWeight: FontWeight.bold,
                                            wordSpacing: 2.5,
                                            color: _getTextColor(context),
                                            height: 1.6,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // সেপারেটর
                                      Container(
                                        height: 1,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              _getPrimaryColor(
                                                context,
                                              ).withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // উচ্চারণ (ভাষা অনুযায়ী পরিবর্তন হবে)
                                      SelectableText(
                                        ay['transliteration'] ?? '',
                                        style: TextStyle(
                                          fontSize: _fontSize,
                                          fontStyle: FontStyle.italic,
                                          color: _getPrimaryColor(context),
                                          height: 1.4,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // অর্থ (ভাষা অনুযায়ী পরিবর্তন হবে)
                                      SelectableText(
                                        '${_text('meaning', context)}: ${ay['meaning'] ?? ''}',
                                        style: TextStyle(
                                          fontSize: _fontSize,
                                          color: _getSecondaryTextColor(
                                            context,
                                          ),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // রেফারেন্স
                            if ((sura['reference'] ?? '').isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _getHeaderColor(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getBorderColor(context),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.source_rounded,
                                      color: _getPrimaryColor(context),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SelectableText(
                                        '${_text('source', context)}: ${sura['reference']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: _getPrimaryColor(context),
                                        ),
                                      ),
                                    ),
                                  ],
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

  Widget _buildFontSizeButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: isDarkMode ? AppColors.darkSurface : Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkAppBar : Color(0xFF2E7D32),
        // শুধু ডার্ক মুডে আপডেট
        title: Text(
          _text('pageTitle', context),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
        ),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton.icon(
              onPressed: _navigateToWordByWordQuran,
              icon: const Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                _text('wordByWordQuran', context),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? AppColors.darkPrimary
                    : Colors.green[800]!,
                // শুধু ডার্ক মুডে আপডেট
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                elevation: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          color: _getBackgroundColor(context), // কালার হেল্পার মেথড ব্যবহার
          child: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: _getPrimaryColor(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _text('loading', context),
                              style: TextStyle(
                                color: _getSecondaryTextColor(context),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : dailySuras.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: _getSecondaryTextColor(context),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _text('noSuraFound', context),
                              style: TextStyle(
                                color: _getSecondaryTextColor(context),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: dailySuras.length,
                        itemBuilder: (context, index) =>
                            buildSura(dailySuras[index], index),
                      ),
              ),

              // Anchor Ad Section
              if (_isAnchorAdReady && _showAnchorAd && _anchorAd != null)
                Container(
                  width: double.infinity,
                  color: _getCardColor(context), // কালার হেল্পার মেথড ব্যবহার
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: _anchorAd!.size.height.toDouble(),
                        alignment: Alignment.center,
                        child: AdWidget(ad: _anchorAd!),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _closeAnchorAd,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.black54
                                  : Colors.white54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
