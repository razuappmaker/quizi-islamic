import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../core/constants/ad_helper.dart';
import '../../providers/language_provider.dart';
import '../../../core/constants/app_colors.dart'; // AppColors ইম্পোর্ট যোগ

class KalemaPage extends StatefulWidget {
  const KalemaPage({super.key});

  @override
  State<KalemaPage> createState() => _KalemaPageState();
}

class _KalemaPageState extends State<KalemaPage> {
  // Font size control
  double _arabicFontSize = 28.0;
  double _textFontSize = 16.0;
  final double _minFontSize = 14.0;
  final double _maxFontSize = 36.0;
  final double _fontSizeStep = 2.0;

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isAdInitialized = false;

  // কালেমা ডেটা - এখন JSON থেকে লোড হবে
  List<Map<String, String>> kalemaList = [];

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _loadKalemaData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Language change listener
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    languageProvider.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) {
      _loadKalemaData();
    }
  }

  Future<void> _loadKalemaData() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final isEnglish = languageProvider.isEnglish;

      final jsonFile = isEnglish
          ? 'assets/en_kalema.json'
          : 'assets/kalema.json';

      final String response = await DefaultAssetBundle.of(
        context,
      ).loadString(jsonFile);
      final List<dynamic> data = json.decode(response);

      if (mounted) {
        setState(() {
          kalemaList = data
              .map<Map<String, String>>(
                (item) => {
                  "title": item['title'] ?? '',
                  "text": item['text'] ?? '',
                  "transliteration": item['transliteration'] ?? '',
                  "meaning": item['meaning'] ?? '',
                },
              )
              .toList();
        });
      }
    } catch (e) {
      print('Error loading kalema data: $e');
      _setDefaultData();
    }
  }

  void _setDefaultData() {
    // Fallback data
    setState(() {
      kalemaList = [
        {
          "title": "কালেমা তাইয়্যেবা",
          "text": "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ مُحَمَّدٌ رَسُولُ ٱللَّٰهِ",
          "transliteration": "লা-ইলাহা ইল্লাল্লাহু মুহাম্মাদুর রাসূলুল্লাহ।",
          "meaning":
              "আল্লাহ ছাড়া আর কোন ইলাহ নেই, মুহাম্মদ (সা.) আল্লাহর রাসূল।",
        },
        {
          "title": "কালেমা শাহাদাত",
          "text":
              "أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا ٱللَّٰهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
          "transliteration":
              "আশহাদু আল্লা-ইলাহা ইল্লাল্লাহু ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসূলুহু।",
          "meaning":
              "আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া আর কোন ইলাহ নেই এবং আমি সাক্ষ্য দিচ্ছি মুহাম্মদ (সা.) আল্লাহর বান্দা ও রাসূল।",
        },
        {
          "title": "কালেমা তামজীদ",
          "text":
              "سُبْحَانَ ٱللَّٰهِ وَٱلْحَمْدُ لِلَّٰهِ وَلَا إِلَٰهَ إِلَّا ٱللَّٰهُ وَٱللَّٰهُ أَكْبَرُ",
          "transliteration":
              "সুবহানাল্লাহি ওয়াল হামদুলিল্লাহি ওয়ালা-ইলাহা ইল্লাল্লাহু ওয়াল্লাহু আকবার।",
          "meaning":
              "পবিত্র আল্লাহ, সমস্ত প্রশংসা আল্লাহর জন্য, আল্লাহ ছাড়া আর কোন ইলাহ নেই এবং আল্লাহ মহান।",
        },
        {
          "title": "কালেমা তাওহীদ",
          "text":
              "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ ٱلْمُلْكُ وَلَهُ ٱلْحَمْدُ، يُحْيِي وَيُمِيتُ، وَهُوَ حَيٌّ لَا يَمُوتُ أَبَدًا، ذُو ٱلْجَلَالِ وَٱلْإِكْرَامِ، بِيَدِهِ ٱلْخَيْرُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ",
          "transliteration":
              "লা-ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকালাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ইউহ্ই ওয়া ইউমীতু, ওয়াহুয়া হাইয়্যুন লা ইয়ামুতু আবাদান, যুল জালালি ওয়াল ইকরাম, বিয়াদিহিল খাইর, ওয়াহুয়া আলা কুল্লি শাইইন কদীর।",
          "meaning":
              "আল্লাহ ছাড়া আর কোন ইলাহ নেই, তিনি এক, তার কোন অংশীদার নেই। রাজত্ব ও প্রশংসা তার জন্য। তিনিই জীবন দান করেন, মৃত্যু ঘটান। তিনি সর্বদা জীবিত, কখনো মরবেন না। তিনি মর্যাদা ও সম্মানের অধিকারী। কল্যাণ তাঁর হাতে, এবং তিনি সব কিছুর উপর ক্ষমতাবান।",
        },
        {
          "title": "কালেমা রুদ্দে কুফর",
          "text":
              "ٱللَّٰهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ أَنْ أُشْرِكَ بِكَ شَيْئًا وَأَنَا أَعْلَمُ بِهِ، وَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُ بِهِ، تُبْتُ عَنْهُ، وَتَبَرَّأْتُ مِنَ ٱلْكُفْرِ وَٱلشِّرْكِ وَٱلْكَذِبِ وَٱلْغِيبَةِ وَٱلْبِدْعَةِ وَٱلْنَمِيمَةِ وَٱلْفَوَاحِشِ وَٱلْبُهْتَانِ وَٱلْمَعَاصِي كُلِّهَا، أَسْلَمْتُ وَآمَنْتُ وَأَقُولُ لَا إِلَٰهَ إِلَّا ٱللَّٰهُ مُحَمَّدٌ رَسُولُ ٱللَّٰهِ",
          "transliteration":
              "আল্লাহুম্মা ইন্নি আউযু বিকা মিন আন উশরিকা বিকা শাইয়্যান ওয়া আনা আ'লামু বিহি... লা-ইলাহা ইল্লাল্লাহু মুহাম্মাদুর রাসূলুল্লাহ।",
          "meaning":
              "হে আল্লাহ! আমি আপনার কাছে আশ্রয় চাই এমন শিরক থেকে যা আমি জানি। এবং যা আমি জানি না, তার জন্য আপনার কাছে ক্ষমা চাই। আমি তা থেকে তওবা করলাম এবং কুফর, শিরক, মিথ্যা, গীবত, বিদআত, নামিমা, অশ্লীলতা, অপবাদ ও সকল গোনাহ থেকে আলাদা হলাম। আমি ইসলাম গ্রহণ করলাম, ঈমান আনলাম এবং বললাম: আল্লাহ ছাড়া আর কোন ইলাহ নেই, মুহাম্মদ (সা.) আল্লাহর রাসূল।",
        },
        {
          "title": "কালেমা ছাদ্দিকীন",
          "text":
              "آمَنْتُ بِٱللَّٰهِ كَمَا هُوَ بِأَسْمَائِهِ وَصِفَاتِهِ وَقَبِلْتُ جَمِيعَ أَحْكَامِهِ",
          "transliteration":
              "আমান্তু বিল্লাহি কামা হুয়া বি আসমা-ইহি ওয়া সিফাতিহi ওয়া কাবিল্তু জামিআ আহকামিহi।",
          "meaning":
              "আমি আল্লাহর প্রতি ঈমান আনলাম, যেমন তিনি তার নাম ও গুণাবলী দ্বারা আছেন এবং আমি তার সকল বিধান মেনে নিলাম।",
        },
      ];
    });
  }

  Future<void> _initializeAds() async {
    try {
      await AdHelper.initialize();
      setState(() {
        _isAdInitialized = true;
      });
      _loadBannerAd();
    } catch (e) {
      debugPrint('Failed to initialize ads: $e');
    }
  }

  void _loadBannerAd() async {
    if (!_isAdInitialized) return;

    try {
      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Adaptive banner ad loaded successfully');
            setState(() {
              _isBannerAdLoaded = true;
            });
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('Adaptive Banner Ad failed to load: $error');
            ad.dispose();
            setState(() {
              _isBannerAdLoaded = false;
            });
          },
          onAdClicked: (ad) {
            AdHelper.recordAdClick();
          },
        ),
      );
      _bannerAd!.load();
    } catch (e) {
      debugPrint('Error creating adaptive banner: $e');
      _isBannerAdLoaded = false;
    }
  }

  void _increaseFontSize() {
    setState(() {
      if (_arabicFontSize < _maxFontSize && _textFontSize < _maxFontSize) {
        _arabicFontSize += _fontSizeStep;
        _textFontSize += _fontSizeStep;
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_arabicFontSize > _minFontSize && _textFontSize > _minFontSize) {
        _arabicFontSize -= _fontSizeStep;
        _textFontSize -= _fontSizeStep;
      }
    });
  }

  void _resetFontSize() {
    setState(() {
      _arabicFontSize = 28.0;
      _textFontSize = 16.0;
    });
  }

  void _showWarningDialog() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isEnglish = languageProvider.isEnglish;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode
              ? AppColors.darkCard
              : AppColors.lightCard,
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isDarkMode
                    ? AppColors.getAccentColor('orange', isDarkMode)
                    : AppColors.getAccentColor('orange', isDarkMode),
              ),
              const SizedBox(width: 8),
              Text(
                isEnglish ? "Warning" : "সতর্কবার্তা",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          content: Text(
            isEnglish
                ? "Arabic verses cannot be fully accurately represented in English. The transliteration is only a guide, please recite in Arabic for proper pronunciation."
                : "আরবি আয়াত- বাংলায় সম্পূর্ণ সুদ্ধভাবে প্রকাশ করা যায় না। উচ্চারণ শুধুমাত্র সহায়ক মাত্র, সঠিক তিলাওয়াতের জন্য আরবিতেই পড়ুন।",
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: isDarkMode ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                isEnglish ? "OK" : "ঠিক আছে",
                style: TextStyle(
                  color: isDarkMode
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    languageProvider.removeListener(_onLanguageChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  Widget _buildAdaptiveBannerWidget(BannerAd banner) {
    return Container(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: banner),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.isEnglish;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          isEnglish ? "The Kalemas" : "কালেমা সমূহ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDarkMode
            ? AppColors.darkAppBar
            : AppColors.lightAppBar,
        elevation: 2,
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
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showWarningDialog,
            tooltip: isEnglish ? "Show Warning" : "সতর্কবার্তা দেখুন",
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'increase',
                child: ListTile(
                  leading: Icon(
                    Icons.zoom_in,
                    color: isDarkMode
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                  ),
                  title: Text(
                    isEnglish ? 'Increase Font' : 'ফন্ট বড় করুন',
                    style: TextStyle(
                      color: isDarkMode
                          ? AppColors.darkText
                          : AppColors.lightText,
                    ),
                  ),
                  onTap: _increaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'decrease',
                child: ListTile(
                  leading: Icon(
                    Icons.zoom_out,
                    color: isDarkMode
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                  ),
                  title: Text(
                    isEnglish ? 'Decrease Font' : 'ফন্ট ছোট করুন',
                    style: TextStyle(
                      color: isDarkMode
                          ? AppColors.darkText
                          : AppColors.lightText,
                    ),
                  ),
                  onTap: _decreaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(
                    Icons.restart_alt,
                    color: isDarkMode
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                  ),
                  title: Text(
                    isEnglish ? 'Default Font Size' : 'ডিফল্ট ফন্ট সাইজ',
                    style: TextStyle(
                      color: isDarkMode
                          ? AppColors.darkText
                          : AppColors.lightText,
                    ),
                  ),
                  onTap: _resetFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: kalemaList.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            )
          : SafeArea(
              bottom: true,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...List<Widget>.generate(kalemaList.length, (index) {
                          final kalema = kalemaList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // কালেমার নাম
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: primaryColor.withOpacity(
                                              0.3,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          kalema["title"]!,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // আরবি টেক্সট সেকশন
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? AppColors.darkSurface
                                          : AppColors.lightSurface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? AppColors.darkBorder
                                            : AppColors.lightBorder,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: CustomPaint(
                                                  painter: _ArabicLinePainter(
                                                    lineColor: isDarkMode
                                                        ? AppColors.darkBorder
                                                        : AppColors.lightBorder,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                kalema["text"]!,
                                                style: TextStyle(
                                                  fontSize: _arabicFontSize,
                                                  fontFamily: 'ScheherazadeNew',
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode
                                                      ? AppColors.darkText
                                                      : AppColors.lightText,
                                                  height: 2.2,
                                                  wordSpacing: 3.0,
                                                  letterSpacing: 1.0,
                                                ),
                                                textAlign: TextAlign.center,
                                                textDirection:
                                                    TextDirection.rtl,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // উচ্চারণ টেক্সট
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? AppColors.getAccentColor(
                                                    'blue',
                                                    isDarkMode,
                                                  ).withOpacity(0.15)
                                                : AppColors.getAccentColor(
                                                    'blue',
                                                    isDarkMode,
                                                  ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isDarkMode
                                                  ? AppColors.getAccentColor(
                                                      'blue',
                                                      isDarkMode,
                                                    )
                                                  : AppColors.getAccentColor(
                                                      'blue',
                                                      isDarkMode,
                                                    ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            kalema["transliteration"]!,
                                            style: TextStyle(
                                              fontSize: _textFontSize,
                                              fontStyle: FontStyle.italic,
                                              color: isDarkMode
                                                  ? AppColors.getAccentColor(
                                                      'blue',
                                                      isDarkMode,
                                                    )
                                                  : AppColors.getAccentColor(
                                                      'blue',
                                                      isDarkMode,
                                                    ),
                                              height: 1.6,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // অর্থ সেকশন
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? AppColors.getAccentColor(
                                              'purple',
                                              isDarkMode,
                                            ).withOpacity(0.15)
                                          : AppColors.getAccentColor(
                                              'purple',
                                              isDarkMode,
                                            ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? AppColors.getAccentColor(
                                                'purple',
                                                isDarkMode,
                                              )
                                            : AppColors.getAccentColor(
                                                'purple',
                                                isDarkMode,
                                              ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isEnglish ? "Meaning:" : "অর্থ:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? AppColors.getAccentColor(
                                                    'purple',
                                                    isDarkMode,
                                                  )
                                                : AppColors.getAccentColor(
                                                    'purple',
                                                    isDarkMode,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          kalema["meaning"]!,
                                          style: TextStyle(
                                            fontSize: _textFontSize,
                                            color: isDarkMode
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // নিচের adaptive ব্যানার অ্যাড
                  if (_isBannerAdLoaded && _bannerAd != null)
                    Container(
                      width: screenWidth,
                      height: _bannerAd!.size.height.toDouble(),
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: _buildAdaptiveBannerWidget(_bannerAd!),
                    ),
                ],
              ),
            ),
    );
  }
}

// কাস্টম পেইন্টার ফর আরবি লাইন গাইড
class _ArabicLinePainter extends CustomPainter {
  final Color lineColor;

  _ArabicLinePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final lineSpacing = 40.0;
    final lineCount = (size.height / lineSpacing).ceil();

    for (int i = 1; i < lineCount; i++) {
      final y = i * lineSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
