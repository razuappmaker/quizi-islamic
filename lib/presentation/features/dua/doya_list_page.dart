// Doya List Page - Multi-language Support সহ
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart'; // Clipboard এর জন্য
import 'package:provider/provider.dart';
import '../../../core/constants/ad_helper.dart';
import '../../../core/services/network_json_loader.dart'; // নতুন নেটওয়ার্ক লোডার
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart'; // নতুন ইম্পোর্ট
import '../../../core/constants/app_colors.dart'; // নতুন ইম্পোর্ট

class DoyaListPage extends StatefulWidget {
  final String categoryTitle;
  final String jsonFile;
  final Color categoryColor;
  final String? initialSearchQuery;
  final String? preSelectedDoyaTitle; // নতুন প্যারামিটার
  final VoidCallback? onDoyaCardOpen; // দোয়া কার্ড ওপেন কলব্যাক

  const DoyaListPage({
    Key? key,
    required this.categoryTitle,
    required this.jsonFile,
    required this.categoryColor,
    this.initialSearchQuery,
    this.preSelectedDoyaTitle, // নতুন প্যারামিটার
    this.onDoyaCardOpen,
  }) : super(key: key);

  @override
  State<DoyaListPage> createState() => _DoyaListPageState();
}

class _DoyaListPageState extends State<DoyaListPage> {
  // ==================== ভাষা টেক্সট ডিক্লেয়ারেশন ====================
  static const Map<String, Map<String, String>> _texts = {
    'loading': {'en': 'Loading duas...', 'bn': 'দোয়া লোড হচ্ছে...'},
    'noDuaFound': {'en': 'No duas found', 'bn': 'কোন দোয়া পাওয়া যায়নি'},
    'searchHint': {'en': 'Search duas...', 'bn': 'দোয়া অনুসন্ধান করুন...'},
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
    'reference': {'en': 'Reference', 'bn': 'রেফারেন্স'},
    'copy': {'en': 'Copy', 'bn': 'কপি'},
    'share': {'en': 'Share', 'bn': 'শেয়ার'},
    'copied': {'en': 'copied', 'bn': 'কপি করা হয়েছে'},
    'increaseFont': {'en': 'Increase font', 'bn': 'ফন্ট বড় করুন'},
    'decreaseFont': {'en': 'Decrease font', 'bn': 'ফন্ট ছোট করুন'},
    'defaultFont': {'en': 'Default font size', 'bn': 'ডিফল্ট ফন্ট সাইজ'},
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

  // কালার হেল্পার মেথড - SuraPage এর মতোই
  Color _getPrimaryColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors.darkPrimary
        : widget.categoryColor;
  }

  Color _getBackgroundColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors.darkBackground
        : Color(0xFFFAFAFA);
  }

  Color _getCardColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode ? AppColors.darkCard : Colors.white70;
  }

  Color _getBorderColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode ? AppColors.darkBorder : Color(0xFFE0E0E0);
  }

  Color _getTextColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode ? AppColors.darkText : Color(0xFF37474F);
  }

  Color _getSecondaryTextColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? AppColors.darkTextSecondary
        : Color(0xFF546E7A);
  }

  List<Map<String, String>> doyas = [];
  List<Map<String, String>> filteredDoyas = [];
  bool _isSearching = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // একাধিক দোয়া একসাথে expand করার জন্য Set ব্যবহার করুন
  final Set<int> _expandedDoyaIndices = <int>{};
  final Map<int, bool> _showFullWarningStates = {};

  // ফন্ট সাইজ কন্ট্রোল
  double _arabicFontSize = 26.0;
  double _textFontSize = 16.0;
  final double _minFontSize = 12.0;
  final double _maxFontSize = 32.0;
  final double _fontSizeStep = 2.0;

  // ✅ Adaptive Bottom Banner Ad
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

  // ✅ Adaptive Inline Banner Ads (প্রতি ৬টি দোয়ার পর)
  final Map<String, BannerAd?> _inlineBannerAds = {};
  final Map<String, bool> _inlineBannerAdReady = {};

  // রেসপনসিভ লেআউট ভেরিয়েবল
  bool _isTablet = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceType();
    });

    _loadDoyaData();

    AdHelper.initialize();
    _loadBottomBannerAd();

    // initial search query থাকলে সেট করুন
    if (widget.initialSearchQuery != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchController.text = widget.initialSearchQuery!;
        _searchDoya(widget.initialSearchQuery!);
      });
    }

    // pre-selected doya থাকলে সেট করুন
    if (widget.preSelectedDoyaTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoExpandPreSelectedDoya();
      });
    }
  }

  // নতুন মেথড: প্রি-সিলেক্টেড দোয়া অটো এক্সপ্যান্ড করুন
  void _autoExpandPreSelectedDoya() {
    if (widget.preSelectedDoyaTitle == null) return;

    final index = doyas.indexWhere(
      (doya) => doya['title'] == widget.preSelectedDoyaTitle,
    );

    if (index != -1 && mounted) {
      setState(() {
        _expandedDoyaIndices.add(index);

        // স্ক্রল করে সেই দোয়ায় নিয়ে যান
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final key = GlobalKey();
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      });

      // দোয়া কার্ড ওপেন হলে parent কে নোটিফাই করুন
      if (widget.onDoyaCardOpen != null) {
        widget.onDoyaCardOpen!();
      }
    }
  }

  // ডিভাইস টাইপ চেক করার মেথড
  void _checkDeviceType() {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;

    setState(() {
      _isTablet = shortestSide >= 600; // ট্যাবলেটের থ্রেশহোল্ড
    });
  }

  // দোয়া ডেটা লোড করার মেথড
  Future<void> _loadDoyaData() async {
    try {
      // NetworkJsonLoader ব্যবহার করুন (নেটওয়ার্ক থেকে প্রথমে, তারপর লোকাল)
      final loadedData = await NetworkJsonLoader.loadJsonList(widget.jsonFile);

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
        doyas = convertedData;
        filteredDoyas = convertedData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      // Fallback data with more details
      setState(() {
        doyas = [
          {
            'title': _getFallbackTitle(),
            'bangla': _getFallbackBangla(),
            'arabic': 'اللهُ أَكْبَرُ',
            'transliteration': _getFallbackTransliteration(),
            'meaning': _getFallbackMeaning(),
            'reference': _getFallbackReference(),
            'error': 'Original file failed to load: $e',
          },
        ];
        filteredDoyas = doyas;
        _isLoading = false;
      });
    }
  }

  // Fallback data methods based on language
  String _getFallbackTitle() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.isEnglish ? 'Takbiratul Ihram' : 'তাকবিরাতুল ইহরাম';
  }

  String _getFallbackBangla() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.isEnglish ? 'Allahu Akbar' : 'আল্লাহু আকবার';
  }

  String _getFallbackTransliteration() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.isEnglish ? 'Allahu Akbar' : 'আল্লাহু আকবার';
  }

  String _getFallbackMeaning() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.isEnglish
        ? 'Allah is the Greatest'
        : 'আল্লাহ সর্বশ্রেষ্ঠ';
  }

  String _getFallbackReference() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.isEnglish
        ? 'Sahih Bukhari: 789'
        : 'সহীহ বুখারী: 789';
  }

  @override
  void dispose() {
    // পেইজ বন্ধ হলে সকল expanded state রিসেট করুন
    _expandedDoyaIndices.clear();
    _showFullWarningStates.clear();
    _bottomBannerAd?.dispose();

    // ✅ সকল inline banner ads dispose করুন
    _inlineBannerAds.forEach((key, ad) => ad?.dispose());
    _inlineBannerAds.clear();
    _inlineBannerAdReady.clear();

    _searchController.dispose();
    super.dispose();
  }

  // ✅ Adaptive Bottom Banner Ad লোড করার মেথড - FIXED VERSION
  Future<void> _loadBottomBannerAd() async {
    try {
      // ✅ AdHelper ব্যবহার করে adaptive banner তৈরি করুন
      _bottomBannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Adaptive Bottom banner ad loaded successfully');
            if (mounted) {
              setState(() {
                _isBottomBannerAdReady = true;
              });
            }
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Adaptive Bottom banner ad failed to load: $error');
            ad.dispose();
            _bottomBannerAd = null;
            if (mounted) {
              setState(() {
                _isBottomBannerAdReady = false;
              });
            }
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Adaptive Bottom Banner ad clicked.');
              } else {
                print('Ad click limit reached');
              }
            });
          },
        ),
      );

      // ✅ AdHelper এর ভিতরে ইতিমধ্যে load() কল করা হয়েছে, তাই এখানে আলাদা করে load() কল করার দরকার নেই
    } catch (e) {
      print('Error loading adaptive bottom banner ad: $e');
      _bottomBannerAd?.dispose();
      _bottomBannerAd = null;
      if (mounted) {
        setState(() {
          _isBottomBannerAdReady = false;
        });
      }
    }
  }

  // ✅ Adaptive Inline Banner Ad লোড করার মেথড (প্রতি ৬টি দোয়ার পর) - FIXED VERSION
  Future<void> _loadInlineBannerAd(String adKey) async {
    // Prevent duplicate loading
    if (_inlineBannerAds.containsKey(adKey) &&
        _inlineBannerAdReady[adKey] == true) {
      return;
    }

    try {
      // ✅ AdHelper ব্যবহার করে adaptive banner তৈরি করুন
      final inlineAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Inline Adaptive banner ad loaded for key $adKey');
            if (mounted) {
              setState(() {
                _inlineBannerAdReady[adKey] = true;
              });
            }
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print(
              'Inline Adaptive banner ad failed to load for key $adKey: $error',
            );
            ad.dispose();
            if (mounted) {
              setState(() {
                _inlineBannerAds.remove(adKey);
                _inlineBannerAdReady.remove(adKey);
              });
            }
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Inline Adaptive Banner ad clicked at key $adKey');
              } else {
                print('Ad click limit reached');
              }
            });
          },
        ),
      );

      if (mounted && inlineAd != null) {
        setState(() {
          _inlineBannerAds[adKey] = inlineAd;
          // AdHelper এর ভিতরে ইতিমধ্যে load() কল করা হয়েছে, তাই এখানে আলাদা করে load() কল করার দরকার নেই
        });
      }
    } catch (e) {
      print('Error loading adaptive inline banner ad for key $adKey: $e');
      if (mounted) {
        setState(() {
          _inlineBannerAds.remove(adKey);
          _inlineBannerAdReady.remove(adKey);
        });
      }
    }
  }

  // সার্চ শুরু করার মেথড
  void _startSearch() => setState(() => _isSearching = true);

  // সার্চ বন্ধ করার মেথড
  void _stopSearch() {
    setState(() {
      _isSearching = false;
      filteredDoyas = doyas;
      _searchController.clear();
    });
  }

  // দোয়া সার্চ করার মেথড
  void _searchDoya(String query) {
    final results = doyas.where((doya) {
      final titleLower = doya['title']!.toLowerCase();
      final banglaLower = doya['bangla']!.toLowerCase();
      return titleLower.contains(query.toLowerCase()) ||
          banglaLower.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredDoyas = results);
  }

  // ফন্ট সাইজ বড় করার মেথড
  void _increaseFontSize() {
    setState(() {
      if (_arabicFontSize < _maxFontSize && _textFontSize < _maxFontSize) {
        _arabicFontSize += _fontSizeStep;
        _textFontSize += _fontSizeStep;
      }
    });
  }

  // ফন্ট সাইজ ছোট করার মেথড
  void _decreaseFontSize() {
    setState(() {
      if (_arabicFontSize > _minFontSize && _textFontSize > _minFontSize) {
        _arabicFontSize -= _fontSizeStep;
        _textFontSize -= _fontSizeStep;
      }
    });
  }

  // ফন্ট সাইজ রিসেট করার মেথড
  void _resetFontSize() {
    setState(() {
      _arabicFontSize = 26.0;
      _textFontSize = 16.0;
    });
  }

  // ক্লিপবোর্ডে কপি করার মেথড
  Future<void> _copyToClipboard(
    Map<String, String> doya,
    BuildContext context,
  ) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isEnglish = languageProvider.isEnglish;

    final String duaTitle = doya['title'] ?? '';
    final String duaArabic = doya['arabic'] ?? '';
    final String duaTransliteration = doya['transliteration'] ?? '';
    final String duaMeaning = doya['meaning'] ?? '';
    final String duaReference = doya['reference'] ?? '';

    final String meaningLabel = isEnglish ? 'Meaning' : 'অর্থ';
    final String referenceLabel = isEnglish ? 'Reference' : 'রেফারেন্স';

    final String copyText =
        '$duaTitle\n\n$duaArabic\n\n$duaTransliteration\n\n$meaningLabel: $duaMeaning${duaReference.isNotEmpty ? '\n\n$referenceLabel: $duaReference' : ''}';

    await Clipboard.setData(ClipboardData(text: copyText));

    // Snackbar দেখান
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$duaTitle" ${_text('copied', context)}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ==================== সতর্কবার্তা উইজেট - SuraPage এর মতোই ====================
  Widget _buildWarningWidget(int index, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final bool showFull = _showFullWarningStates[index] ?? false;

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
                        _showFullWarningStates[index] = false;
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
                  _showFullWarningStates[index] = true;
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

  // দোয়া এক্সপ্যানশন টগল করার মেথড
  void _toggleDoyaExpansion(int index) {
    setState(() {
      if (_expandedDoyaIndices.contains(index)) {
        // Collapse this doya
        _expandedDoyaIndices.remove(index);
        _showFullWarningStates.remove(index);
      } else {
        // Expand this doya
        _expandedDoyaIndices.add(index);

        // দোয়া কার্ড ওপেন হলে parent কে নোটিফাই করুন
        if (widget.onDoyaCardOpen != null) {
          widget.onDoyaCardOpen!();
        }
      }
    });
  }

  // ✅ Adaptive Inline Banner Ad বিল্ড করার মেথড - FIXED VERSION
  Widget _buildInlineBanner(String adKey) {
    final bannerAd = _inlineBannerAds[adKey];
    final isReady = _inlineBannerAdReady[adKey] ?? false;

    // যদি অ্যাড ইতিমধ্যে লোড হয়ে থাকে এবং ready হয়
    if (bannerAd != null && isReady) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        height: bannerAd.size.height.toDouble(),
        alignment: Alignment.center,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        child: AdWidget(ad: bannerAd),
      );
    }

    // যদি অ্যাড এখনও লোড না হয়ে থাকে, তবে লোড শুরু করুন কিন্তু UI show না করুন
    if (bannerAd == null && !_inlineBannerAdReady.containsKey(adKey)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_inlineBannerAdReady.containsKey(adKey)) {
          _loadInlineBannerAd(adKey);
        }
      });
    }

    // লোডিং অবস্থায় অথবা অ্যাড না থাকলে সম্পূর্ণ hide করুন (সাইজ ০)
    return const SizedBox.shrink();
  }

  // দোয়া কার্ড বিল্ড করার মেথড - রেসপনসিভ
  Widget _buildDoyaCard(
    Map<String, String> doya,
    int index,
    BuildContext context,
  ) {
    final bool isExpanded = _expandedDoyaIndices.contains(index);
    final String duaTitle = doya['title'] ?? '';
    // প্রি-সিলেক্টেড দোয়ার জন্য key তৈরি করুন
    final Key? cardKey = widget.preSelectedDoyaTitle == duaTitle
        ? GlobalKey()
        : null;

    final String duaArabic = doya['arabic'] ?? '';
    final String duaTransliteration = doya['transliteration'] ?? '';
    final String duaMeaning = doya['meaning'] ?? '';
    final String duaReference = doya['reference'] ?? '';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      key: cardKey,
      // key যোগ করুন
      elevation: 3,
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: _isTablet ? 16 : 12, // ট্যাবলেটে বেশি horizontal margin
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _toggleDoyaExpansion(index),
        child: Container(
          padding: EdgeInsets.all(_isTablet ? 20 : 16),
          // ট্যাবলেটে বেশি padding
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: widget.categoryColor, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          duaTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _isTablet ? 20 : 18, // ট্যাবলেটে বড় ফন্ট
                            color: widget.categoryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doya['bangla'] ?? '',
                          style: TextStyle(
                            fontSize: _isTablet ? 18 : 16, // ট্যাবলেটে বড় ফন্ট
                          ),
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.categoryColor,
                    size: 24,
                  ),
                ],
              ),

              // Expanded content with warning and details
              if (isExpanded) ...[
                const SizedBox(height: 16),

                // Warning message - SuraPage এর মতোই
                _buildWarningWidget(index, context),

                const SizedBox(height: 16),

                // Arabic text - ট্যাবলেটে বড় ফন্ট
                SelectableText(
                  duaArabic,
                  style: TextStyle(
                    fontSize: _isTablet ? _arabicFontSize + 2 : _arabicFontSize,
                    fontFamily: 'ScheherazadeNew',
                    fontWeight: FontWeight.bold,
                    height: 2.0,
                    wordSpacing: 2.5,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 15),

                // Transliteration
                SelectableText(
                  duaTransliteration,
                  style: TextStyle(
                    fontSize: _textFontSize,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // Meaning
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    "${_text('meaning', context)}: $duaMeaning",
                    style: TextStyle(
                      fontSize: _textFontSize,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),

                // Reference
                if (duaReference.isNotEmpty)
                  SelectableText(
                    "${_text('reference', context)}: $duaReference",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.green[200] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 16),

                // Copy and Share buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Copy button
                    ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(doya, context),
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text(_text('copy', context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: _isTablet ? 20 : 16,
                          // ট্যাবলেটে বেশি padding
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Share button
                    ElevatedButton.icon(
                      onPressed: () {
                        final languageProvider = Provider.of<LanguageProvider>(
                          context,
                          listen: false,
                        );
                        final isEnglish = languageProvider.isEnglish;
                        final meaningLabel = isEnglish ? 'Meaning' : 'অর্থ';
                        final referenceLabel = isEnglish
                            ? 'Reference'
                            : 'রেফারেন্স';

                        Share.share(
                          '$duaTitle\n\n$duaArabic\n\n$duaTransliteration\n\n$meaningLabel: $duaMeaning\n\n$referenceLabel: $duaReference',
                        );
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(_text('share', context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.categoryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: _isTablet ? 20 : 16,
                          // ট্যাবলেটে বেশি padding
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // লোডিং ইন্ডিকেটর বিল্ড করার মেথড
  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_text('loading', context)),
        ],
      ),
    );
  }

  // এম্পটি স্টেট বিল্ড করার মেথড
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_text('noDuaFound', context), style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  // দোয়া লিস্ট বিল্ড করার মেথড
  Widget _buildDoyaList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: _isTablet ? 8 : 0,
      ),
      itemCount: filteredDoyas.length,
      itemBuilder: (context, index) {
        final doya = filteredDoyas[index];

        // Cache the widget to avoid rebuilds
        final doyaCard = _buildDoyaCard(doya, index, context);

        List<Widget> widgets = [doyaCard];

        // ✅ প্রতি ৬ টা দোয়ার পর Adaptive ব্যানার অ্যাড
        if ((index + 1) % 6 == 0) {
          // filtered list-এর জন্য unique key তৈরি করুন
          final adKey = '${doya['title']}_$index';
          final bannerAd = _buildInlineBanner(adKey);
          widgets.add(bannerAd);
        }

        return Column(children: widgets);
      },
    );
  }

  // বটম ব্যানার অ্যাড বিল্ড করার মেথড
  Widget _buildBottomBannerAd() {
    return Container(
      width: double.infinity,
      height: _bottomBannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      child: AdWidget(ad: _bottomBannerAd!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // বিল্ড করার সময় ডিভাইস টাইপ চেক করুন
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceType();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.categoryColor,
        title: !_isSearching
            ? Text(
                widget.categoryTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _isTablet ? 22 : 20,
                  color: Colors.white,
                ),
              )
            : TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: _text('searchHint', context),
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
                onChanged: _searchDoya,
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
          // Font size control in app bar
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.text_fields, color: Colors.white),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'increase',
                  child: ListTile(
                    leading: const Icon(Icons.zoom_in),
                    title: Text(_text('increaseFont', context)),
                    onTap: _increaseFontSize,
                  ),
                ),
                PopupMenuItem(
                  value: 'decrease',
                  child: ListTile(
                    leading: const Icon(Icons.zoom_out),
                    title: Text(_text('decreaseFont', context)),
                    onTap: _decreaseFontSize,
                  ),
                ),
                PopupMenuItem(
                  value: 'reset',
                  child: ListTile(
                    leading: const Icon(Icons.restart_alt),
                    title: Text(_text('defaultFont', context)),
                    onTap: _resetFontSize,
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
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
      body: SafeArea(
        bottom: true, // ✅ নিচের SafeArea চালু করুন
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator(context)
                  : filteredDoyas.isEmpty
                  ? _buildEmptyState(context)
                  : _buildDoyaList(context),
            ),

            // ✅ Adaptive Bottom Banner Ad - SafeArea এর ভিতরে
            if (_isBottomBannerAdReady && _bottomBannerAd != null)
              _buildBottomBannerAd(),
          ],
        ),
      ),
    );
  }
}
