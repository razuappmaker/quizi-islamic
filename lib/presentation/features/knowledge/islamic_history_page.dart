import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/ad_helper.dart';
import '../../providers/language_provider.dart';
import '../../../core/constants/app_colors.dart'; // Import the AppColors class

class IslamicHistoryPage extends StatefulWidget {
  const IslamicHistoryPage({super.key});

  @override
  State<IslamicHistoryPage> createState() => _IslamicHistoryPageState();
}

class _IslamicHistoryPageState extends State<IslamicHistoryPage> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _hasShownInterstitialToday = false;

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _checkInterstitialDailyLimit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    languageProvider.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeAds() async {
    try {
      await AdHelper.initialize();
      _loadBannerAd();
    } catch (e) {
      print('Failed to initialize ads: $e');
    }
  }

  void _loadBannerAd() async {
    try {
      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (ad) async {
            print('Adaptive Banner Ad loaded successfully');
            await AdHelper.recordBannerAdShown();
            setState(() {
              _isBannerAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            print('Adaptive Banner Ad failed to load: $error');
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
      print('Error creating adaptive banner: $e');
      _isBannerAdLoaded = false;
    }
  }

  Future<void> _checkInterstitialDailyLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShownDate = prefs.getString(
        'islamic_history_interstitial_date',
      );
      final today = DateTime.now().toString().split(' ')[0];

      if (lastShownDate != today) {
        await prefs.setString('islamic_history_interstitial_date', today);
        setState(() {
          _hasShownInterstitialToday = false;
        });

        Future.delayed(const Duration(seconds: 10), () {
          _showInterstitialAdIfAllowed();
        });
      } else {
        setState(() {
          _hasShownInterstitialToday = true;
        });
        print('Interstitial already shown today for IslamicHistoryPage');
      }
    } catch (e) {
      print('Error checking interstitial daily limit: $e');
      Future.delayed(const Duration(seconds: 10), () {
        _showInterstitialAdIfAllowed();
      });
    }
  }

  void _showInterstitialAdIfAllowed() {
    if (!_hasShownInterstitialToday) {
      AdHelper.showInterstitialAd(
        adContext: 'IslamicHistoryPage',
        onAdShowed: () {
          _markInterstitialAsShown();
        },
        onAdDismissed: () {
          print('Interstitial ad dismissed in IslamicHistoryPage');
        },
        onAdFailedToShow: () {
          print('Interstitial ad failed to show in IslamicHistoryPage');
        },
      );
    } else {
      print('Interstitial not shown - already displayed today');
    }
  }

  Future<void> _markInterstitialAsShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'islamic_history_interstitial_date',
        DateTime.now().toString().split(' ')[0],
      );
      setState(() {
        _hasShownInterstitialToday = true;
      });
      print('Interstitial marked as shown for today');
    } catch (e) {
      print('Error marking interstitial as shown: $e');
    }
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
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: AppColors.getAppBarColor(isDarkMode),
        title: Text(
          isEnglish ? 'Brief History of Islam' : 'ইসলামের সংক্ষিপ্ত ইতিহাস',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.5,
            color: Colors.white, // Always white for AppBar title
          ),
        ),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            // White with opacity for circle
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white, // Always white for AppBar icons
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.getBackgroundGradient(isDarkMode),
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          isEnglish ? 'Beginning of Islam' : 'ইসলামের সূচনা',
                          Icons.lightbulb_outline,
                          isDarkMode,
                        ),
                        _buildContentCard(
                          isEnglish
                              ? 'The history of Islam began in the 7th century in the Arabian Peninsula. Allah Almighty perfected the religion of Islam through the final Prophet Muhammad (PBUH). '
                                    'He was born in Mecca in 570 CE, and the journey of Islam began with the first revelation in 610 CE in the Cave of Hira.'
                              : 'ইসলামের ইতিহাস শুরু হয় ৭ম শতাব্দীতে আরব উপদ্বীপে। আল্লাহ তাআলা শেষ নবী হযরত মুহাম্মদ (সা.)-এর মাধ্যমে ইসলাম ধর্মের পূর্ণতা দান করেন। '
                                    'মক্কা নগরীতে ৫৭০ খ্রিস্টাব্দে তাঁর জন্ম এবং ৬১০ খ্রিস্টাব্দে প্রথম ওহী প্রাপ্তির মাধ্যমে ইসলামের যাত্রা শুরু হয়।',
                          isDarkMode,
                        ),

                        const SizedBox(height: 20),

                        _buildSectionHeader(
                          isEnglish
                              ? 'Important Events'
                              : 'গুরুত্বপূর্ণ ঘটনাবলী',
                          Icons.event,
                          isDarkMode,
                        ),
                        _buildTimelineItem(
                          isEnglish ? '610 CE' : '৬১০ খ্রিস্টাব্দ',
                          isEnglish
                              ? 'First Revelation (in Cave of Hira)'
                              : 'প্রথম ওহী প্রাপ্তি (হেরা গুহায়)',
                          isDarkMode,
                        ),
                        _buildTimelineItem(
                          isEnglish ? '622 CE' : '৬২২ খ্রিস্টাব্দ',
                          isEnglish
                              ? 'Hijrah (Migration from Mecca to Medina)'
                              : 'হিজরত (মক্কা থেকে মদিনায়)',
                          isDarkMode,
                        ),
                        _buildTimelineItem(
                          isEnglish ? '630 CE' : '৬৩০ খ্রিস্টাব্দ',
                          isEnglish ? 'Conquest of Mecca' : 'মক্কা বিজয়',
                          isDarkMode,
                        ),
                        _buildTimelineItem(
                          isEnglish ? '632 CE' : '৬৩২ খ্রিস্টাব্দ',
                          isEnglish
                              ? 'Farewell Hajj and Demise of Prophet (PBUH)'
                              : 'বিদায় হজ ও নবী (সা.)-এর ওফাত',
                          isDarkMode,
                        ),

                        const SizedBox(height: 20),

                        _buildSectionHeader(
                          isEnglish
                              ? 'Rightly Guided Caliphs'
                              : 'খোলাফায়ে রাশেদীন',
                          Icons.people,
                          isDarkMode,
                        ),
                        _buildContentCard(
                          isEnglish
                              ? 'The Rightly Guided Caliphs: The Golden Age of Islam\n\n'
                                    'After the demise of Prophet Muhammad (PBUH), four pious and just caliphs led the Muslim Ummah. Their era is known as the era of the Rightly Guided Caliphs or "Khulafa-e-Rashideen." This period is considered the golden age of Islam for expansion and consolidation.\n\n'
                                    'List of Caliphs and Brief Description:\n\n'
                                    '1. ✨ Hazrat Abu Bakr (RA) - 632-634 CE\n'
                                    '    * Suppressed the Ridda Wars and reestablished unity.\n'
                                    '    * Initiated the compilation of the Holy Quran.\n\n'
                                    '2. ✨ Hazrat Umar (RA) - 634-644 CE\n'
                                    '    * Islamic empire expanded unprecedentedly (conquest of Syria, Egypt, Jerusalem).\n'
                                    '    * Established strong administrative structure and introduced Hijri calendar.\n\n'
                                    '3. ✨ Hazrat Uthman (RA) - 644-656 CE\n'
                                    '    * Compiled the standard version of the Quran (Mushaf-e-Uthmani).\n'
                                    '    * Established Islamic navy.\n\n'
                                    '4. ✨ Hazrat Ali (RA) - 656-661 CE\n'
                                    '    * First Fitna (civil war) occurred during his time.\n'
                                    '    * Moved capital from Medina to Kufa in Iraq.\n\n'
                                    'During these four caliphs, the foundation of the Islamic state was firmly established.'
                              : 'খোলাফায়ে রাশেদীন: ইসলামের সোনালি সময়\n\n'
                                    'ইসলামের মহানবী হজরত মুহাম্মদ (সা.)-এর ওফাতের পর মুসলিম উম্মাহকে নেতৃত্ব দিতে চারজন পুণ্যবান ও ন্যায়পরায়ণ খলিফা ইসলামী রাষ্ট্র পরিচালনা করেন। তাঁদের শাসনকালকে খোলাফায়ে রাশেদীন বা \'সঠিক নির্দেশিত খলিফাগণ\'-এর যুগ বলা হয়। এই সময়কালকে ইসলামের প্রসার এবং সংহতির সোনালি সময় (golden age) হিসেবে বিবেচনা করা হয়।\n\n'
                                    'খলিফাগণের তালিকা ও সংক্ষিপ্ত বিবরণ:\n\n'
                                    '১. ✨হযরত আবু বকর (রা.) - ৬৩২-৬৩৪ খ্রিস্টাব্দ\n'
                                    '    * রিদ্দার যুদ্ধ দমন করে ঐক্য পুনঃপ্রতিষ্ঠিত করেন।\n'
                                    '    * কুরআন মাজীদ একত্রিতকরণের প্রাথমিক কাজ শুরু হয়।\n\n'
                                    '২. ✨হযরত উমর (রা.) - ৬৩৪-৬৪৪ খ্রিস্টাব্দ\n'
                                    '    * ইসলামী সাম্রাজ্য অভূতপূর্ব প্রসার লাভ করে (সিরিয়া, মিশর, জেরুজালেম জয়)।\n'
                                    '    * শক্তিশালী প্রশাসনিক কাঠামো তৈরি এবং হিজরি সন প্রবর্তন করেন।\n\n'
                                    '৩. ✨হযরত উসমান (রা.)- ৬৪৪-৬৫৬ খ্রিস্টাব্দ\n'
                                    '    * কুরআন মাজীদের প্রামাণ্য সংস্করণ (মুসহাফ-ই-উসমানী) তৈরি করে বিতরণ করেন।\n'
                                    '    * ইসলামী নৌবহর গঠিত হয়।\n\n'
                                    '৪. ✨হযরত আলী (রা.) - ৬৫৬-৬৬১ খ্রিস্টাব্দ\n'
                                    '    * তাঁর সময়ে প্রথম **ফিতনা** (গৃহযুদ্ধ) সংঘটিত হয়।\n'
                                    '    * রাজধানী মদীনা থেকে ইরাকের কুফায় স্থানান্তর করেন।\n\n'
                                    'এই চার খলিফার শাসনকালে ইসলামী রাষ্ট্রের ভিত্তি দৃঢ়ভাবে প্রতিষ্ঠিত হয়।',
                          isDarkMode,
                        ),

                        const SizedBox(height: 20),

                        _buildSectionHeader(
                          isEnglish
                              ? 'Islamic Empires & Civilization'
                              : 'ইসলামী সাম্রাজ্য ও সভ্যতা',
                          Icons.architecture,
                          isDarkMode,
                        ),
                        _buildExpansionItem(
                          isEnglish
                              ? 'Umayyad Caliphate (661–750 CE)'
                              : 'উমাইয়া খিলাফত (৬৬১–৭৫০ খ্রিস্টাব্দ)',
                          isEnglish
                              ? 'The Umayyad Caliphate was the first hereditary caliphate in Islamic history, with its capital in Damascus. '
                                    'Caliph Muawiyah ibn Abi Sufyan (RA) established it in 661 CE. The Umayyads transformed the Islamic empire into a powerful state militarily, administratively, and culturally.\n\n'
                                    '### Geographical Expansion:\n'
                                    '• The empire expanded as far west as Spain (Al-Andalus).\n'
                                    '• Islam reached the Sindh region of the Indian subcontinent in the east.\n'
                                    '• North Africa, the Middle East, Persia, and Central Asia were under Umayyad rule.\n\n'
                                    '### Administration & Contributions:\n'
                                    '• Arabic was declared the official language, creating cultural unity in the Islamic world.\n'
                                    '• Currency reform was implemented (introduction of distinct Islamic dinars and dirhams).\n'
                                    '• Administrative structure was consolidated with governors appointed in provinces.\n'
                                    '• The **Dome of the Rock** was built in Jerusalem, a great example of Islamic architecture.\n\n'
                                    '### Historical Significance:\n'
                                    '• During the Umayyad Caliphate, the Islamic empire was one of the largest empires in history geographically.\n'
                                    '• Arabic language, culture, and Islamic civilization expanded rapidly.\n'
                                    '• Their strong military expansion deeply influenced European history.\n\n'
                                    '✨ Summary: The Umayyad Caliphate was an important chapter in Islamic history, where the foundation of the Muslim world was strengthened through state administration, cultural unity, and military expansion.'
                              : 'উমাইয়া খিলাফত ছিল ইসলামের ইতিহাসে প্রথম বংশানুক্রমিক (hereditary) খিলাফত, যার রাজধানী ছিল দামেস্ক। '
                                    'খলিফা মুয়াবিয়া ইবনে আবি সুফিয়ান (রাঃ) ৬৬১ খ্রিস্টাব্দে এটি প্রতিষ্ঠা করেন। উমাইয়ারা সামরিক, প্রশাসনিক ও সাংস্কৃতিক দিক থেকে '
                                    'ইসলামী সাম্রাজ্যকে বিশাল এক শক্তিধর রাষ্ট্রে রূপান্তরিত করেন।\n\n'
                                    '### ভৌগোলিক বিস্তার:\n'
                                    '• পশ্চিমে স্পেন (আল-আন্দালুস) পর্যন্ত সাম্রাজ্যের বিস্তার ঘটে।\n'
                                    '• পূর্বে ভারতীয় উপমহাদেশের সিন্ধু অঞ্চল পর্যন্ত ইসলাম পৌঁছে যায়।\n'
                                    '• উত্তর আফ্রিকা, মধ্যপ্রাচ্য, পারস্য এবং মধ্য এশিয়া উমাইয়া শাসনের অন্তর্ভুক্ত ছিল।\n\n'
                                    '### প্রশাসন ও অবদান:\n'
                                    '• আরবি ভাষাকে সরকারী ভাষা ঘোষণা করা হয়, যা ইসলামী বিশ্বের সাংস্কৃতিক ঐক্য গড়ে তোলে।\n'
                                    '• মুদ্রা সংস্কার (স্বতন্ত্র ইসলামী দিনার ও দিরহাম চালু) করা হয়।\n'
                                    '• প্রশাসনিক কাঠামো সুসংহত করে প্রদেশগুলোতে গভর্নর নিয়োগ করা হয়।\n'
                                    '• জেরুজালেমে **ডোম অব দ্য রক (Dome of the Rock)** নির্মাণ করা হয়, যা ইসলামী স্থাপত্যকলার এক মহৎ নিদর্শন।\n\n'
                                    '### ঐতিহাসিক গুরুত্ব:\n'
                                    '• উমাইয়া খিলাফতের সময় ইসলামী সাম্রাজ্য ভৌগোলিকভাবে ইতিহাসের বৃহত্তম সাম্রাজ্যগুলোর একটি ছিল।\n'
                                    '• আরবি ভাষা, সংস্কৃতি ও ইসলামী সভ্যতার প্রসার দ্রুতগতিতে বৃদ্ধি পায়।\n'
                                    '• তাদের শক্তিশালী সামরিক সম্প্রসারণ ইউরোপীয় ইতিহাসকেও গভীরভাবে প্রভাবিত করে।\n\n'
                                    '✨ সারাংশ: উমাইয়া খিলাফত ইসলামী ইতিহাসের এক গুরুত্বপূর্ণ অধ্যায়, যেখানে রাষ্ট্র পরিচালনা, সাংস্কৃতিক ঐক্য এবং সামরিক বিস্তারের মাধ্যমে মুসলিম বিশ্বের ভিত্তি আরও মজবুত হয়।',
                          isDarkMode,
                        ),

                        _buildExpansionItem(
                          isEnglish
                              ? 'Abbasid Caliphate (750–1258 CE)'
                              : 'আব্বাসীয় খিলাফত (৭৫০–১২৫৮ খ্রিস্টাব্দ)',
                          isEnglish
                              ? 'The Abbasid Caliphate marked the beginning of a golden age in Islamic history, with its capital in Baghdad. '
                                    'Caliph Abu al-Abbas al-Saffah established this caliphate in 750 CE after the fall of the Umayyads. '
                                    'During the Abbasid rule, Islamic civilization reached its peak in the Golden Age.\n\n'
                                    '### Geographical Expansion:\n'
                                    '• The Middle East, North Africa, Persia, and Central Asia were under Abbasid rule.\n'
                                    '• Islam spread to the Indian subcontinent, Central Asia, and trade routes to China.\n\n'
                                    '### Center of Knowledge & Culture:\n'
                                    '• **Bayt al-Hikmah (House of Wisdom)** established in Baghdad was the world\'s greatest center of knowledge, where Greek, Roman, Indian, and Persian texts were translated and preserved.\n'
                                    '• Scientists and philosophers like Ibn Sina, Al-Razi, Al-Khwarizmi, and Ibn Haytham made groundbreaking contributions to medicine, mathematics, optics, and philosophy.\n'
                                    '• Arabic language became established as the language of international knowledge and science.\n\n'
                                    '### Administration & Economy:\n'
                                    '• Efficient administrative systems developed, improving provincial governance.\n'
                                    '• Baghdad became one of the world\'s leading centers of trade, economy, and craftsmanship.\n'
                                    '• Islamic art, literature, calligraphy, and architecture gained worldwide fame.\n\n'
                                    '### Decline:\n'
                                    '• Central power weakened from the 10th century, with provincial governors and military forces claiming independence.\n'
                                    '• In 1258 CE, the Mongols captured Baghdad, leading to the political fall of the Abbasid Caliphate, although nominal Abbasid caliphs survived later in Cairo.\n\n'
                                    '✨ Summary: The Abbasid Caliphate was the symbol of the golden age of Islamic civilization. '
                                    'During their rule, the Islamic world reached the highest development in knowledge, science, culture, and philosophy.'
                              : 'আব্বাসীয় খিলাফত ছিল ইসলামের ইতিহাসে এক সোনালী যুগের সূচনা, যার রাজধানী ছিল বাগদাদ। '
                                    'খলিফা আবুল আব্বাস আস-সাফাহ ৭৫০ খ্রিস্টাব্দে উমাইয়াদের পতনের পর এই খিলাফত প্রতিষ্ঠা করেন। '
                                    'আব্বাসীয়দের শাসনকালে ইসলামী সভ্যতা তার সোনালি যুগের (Golden Age) -এর সর্বোচ্চ শিখরে পৌঁছে।\n\n'
                                    '### ভৌগোলিক বিস্তার:\n'
                                    '• মধ্যপ্রাচ্য, উত্তর আফ্রিকা, পারস্য এবং মধ্য এশিয়ার বিস্তৃত অঞ্চল আব্বাসীয় শাসনের অধীনে ছিল।\n'
                                    '• ইসলাম ভারতীয় উপমহাদেশ, মধ্য এশিয়া এবং চীনের বাণিজ্যপথ পর্যন্ত প্রভাব বিস্তার করে।\n\n'
                                    '### জ্ঞান-বিজ্ঞান ও সংস্কৃতির কেন্দ্র:\n'
                                    '• বাগদাদে প্রতিষ্ঠিত **বায়তুল হিকমাহ (House of Wisdom)** ছিল বিশ্বের শ্রেষ্ঠ জ্ঞানকেন্দ্র, যেখানে গ্রিক, রোমান, ভারতীয় ও ফারসি গ্রন্থ অনূদিত ও সংরক্ষিত হত।\n'
                                    '• ইবনে সিনা, আল-রাজি, আল-খাওয়ারিজমি, ইবনে হাইথাম প্রমুখ বিজ্ঞানী ও দার্শনিকরা চিকিৎসাবিজ্ঞান, গণিত, অপটিক্স ও দর্শনে যুগান্তকারী অবদান রাখেন।\n'
                                    '• আরবি ভাষা আন্তর্জাতিক জ্ঞান-বিজ্ঞানের ভাষা হিসেবে প্রতিষ্ঠিত হয়।\n\n'
                                    '### প্রশাসন ও অর্থনীতি:\n'
                                    '• দক্ষ প্রশাসনিক ব্যবস্থা গড়ে ওঠে, প্রদেশভিত্তিক শাসন ব্যবস্থার উন্নতি ঘটে।\n'
                                    '• বাগদাদ বাণিজ্য, অর্থনীতি ও কারুশিল্পে বিশ্বের অন্যতম প্রধান কেন্দ্র হয়ে ওঠে।\n'
                                    '• ইসলামী শিল্প, সাহিত্য, ক্যালিগ্রাফি ও স্থাপত্য বিশ্বব্যাপী খ্যাতি অর্জন করে।\n\n'
                                    '### পতন:\n'
                                    '• ১০ম শতক থেকে কেন্দ্রীয় ক্ষমতা দুর্বল হতে থাকে, প্রাদেশিক গভর্নর ও সামরিক বাহিনী স্বাধীনতা দাবি করে।\n'
                                    '• ১২৫৮ খ্রিস্টাব্দে মঙ্গোলরা বাগদাদ দখল করলে আব্বাসীয় খিলাফতের রাজনৈতিক পতন ঘটে, যদিও কায়রোতে পরবর্তীতে নামমাত্র আব্বাসীয় খলিফা টিকে থাকেন।\n\n'
                                    '✨সারাংশ: আব্বাসীয় খিলাফত ছিল ইসলামী সভ্যতার সোনালী যুগের প্রতীক। '
                                    'তাদের শাসনকালেই ইসলামি বিশ্ব জ্ঞান-বিজ্ঞান, সংস্কৃতি ও দর্শনের সর্বোচ্চ উন্নতিতে পৌঁছেছিল।',
                          isDarkMode,
                        ),

                        _buildExpansionItem(
                          isEnglish
                              ? 'Ottoman Empire (1299–1922 CE)'
                              : 'অটোমান সাম্রাজ্য (১২৯৯–১৯২২ খ্রিস্টাব্দ)',
                          isEnglish
                              ? 'The Ottoman Empire was the longest-lasting and last major caliphate in Islamic history. '
                                    'Osman I established it in 1299 CE. For over 600 years, the Ottomans ruled vast territories in Europe, Asia, and Africa. Their capital was first Bursa, then Edirne, and finally Istanbul (Constantinople).\n\n'
                                    '### Geographical Expansion:\n'
                                    '• Empire spanned three continents—from the Balkan region in Europe to the Middle East, North Africa, and the Arabian Peninsula.\n'
                                    '• In 1453, Sultan **Mehmed the Conqueror** conquered Constantinople and declared Istanbul the capital.\n'
                                    '• At its peak, the empire covered approximately 5 million square kilometers.\n\n'
                                    '### Administration & Social System:\n'
                                    '• The Ottomans created a highly efficient administrative structure, granting autonomy to various religious communities through the Millet System.\n'
                                    '• The Ottoman army, especially the Janissary corps, was known as one of the strongest military forces in the world.\n'
                                    '• The economy relied on agriculture, trade, and the Silk Road.\n\n'
                                    '### Knowledge, Science & Architecture:\n'
                                    '• Magnificent examples of Islamic architecture, such as the **Suleymaniye Mosque** and Blue Mosque, were built during the Ottoman era.\n'
                                    '• Ottoman contributions to literature, music, calligraphy, and crafts enriched the cultural heritage of the entire Islamic world.\n'
                                    '• Progress was made in medicine and science, especially in educational centers established in Istanbul.\n\n'
                                    '### Decline:\n'
                                    '• From the 17th century onwards, the Ottoman Empire gradually weakened due to the rise of European powers and internal weaknesses.\n'
                                    '• In the 19th century, the empire was called the "Sick Man of Europe."\n'
                                    '• After World War I, the Ottoman Caliphate officially ended in 1922, and the modern Republic of Turkey was established.\n\n'
                                    '✨ **Summary:** The Ottoman Empire was the last great empire in Islamic history, providing political, cultural, and religious leadership for nearly six centuries. '
                                    'Their architecture, administration, and cultural heritage continue to deeply influence the world today.'
                              : 'অটোমান সাম্রাজ্য ছিল ইসলামী ইতিহাসের সর্বাধিক দীর্ঘস্থায়ী ও সর্বশেষ বৃহৎ খিলাফত। '
                                    'ওসমান প্রথম (Osman I) ১২৯৯ খ্রিস্টাব্দে এটি প্রতিষ্ঠা করেন। প্রায় ৬০০ বছরেরও বেশি সময় ধরে '
                                    'অটোমানরা ইউরোপ, এশিয়া এবং আফ্রিকার বিস্তৃত অঞ্চলে শাসন করেছেন। তাদের রাজধানী প্রথমে বুরসা, পরে এদিরনে এবং অবশেষে ইস্তানবুল (কনস্টান্টিনোপল) হয়।\n\n'
                                    '### ভৌগোলিক বিস্তার:\n'
                                    '• তিন মহাদেশে বিস্তৃত সাম্রাজ্য— ইউরোপের বলকান অঞ্চল থেকে শুরু করে মধ্যপ্রাচ্য, উত্তর আফ্রিকা ও আরব উপদ্বীপ পর্যন্ত।\n'
                                    '• ১৪৫৩ সালে সুলতান **মেহমেদ দ্য কনকারার (Mehmed II) কনস্টান্টিনোপল বিজয় করে ইস্তানবুলকে রাজধানী ঘোষণা করেন।\n'
                                    '• সর্বোচ্চ সময়ে সাম্রাজ্যের আয়তন প্রায় ৫ মিলিয়ন বর্গকিলোমিটার ছিল।\n\n'
                                    '### প্রশাসন ও সমাজব্যবস্থা:\n'
                                    '• অটোমানরা অত্যন্ত দক্ষ প্রশাসনিক কাঠামো তৈরি করে, যেখানে মিল্লাত সিস্টেম এর মাধ্যমে বিভিন্ন ধর্মীয় সম্প্রদায়কে স্বায়ত্তশাসন দেওয়া হত।\n'
                                    '• অটোমান সেনাবাহিনী, বিশেষ করে জানিসারি বাহিনী, বিশ্বের অন্যতম শক্তিশалী সামরিক বাহিনী হিসেবে পরিচিত ছিল।\n'
                                    '• অর্থনীতি কৃষি, বাণিজ্য এবং সিল্ক রোডের উপর নির্ভরশীল ছিল।\n\n'
                                    '### জ্ঞান-বিজ্ঞান ও স্থাপত্য:\n'
                                    '• ইসলামী স্থাপত্যের অসাধারণ নিদর্শন, যেমন **সুলেইমানিয়া মসজিদ** ও নীল মসজিদ (Blue Mosque) অটোমান যুগে নির্মিত হয়।\n'
                                    '• সাহিত্য, সংগীত, ক্যালিগ্রাফি ও কারুশিল্পে অটোমানদের অবদান সমগ্র ইসলামী বিশ্বের সাংস্কৃতিক ঐতিহ্যকে সমৃদ্ধ করেছে।\n'
                                    '• চিকিৎসা ও বিজ্ঞানেও উন্নতি সাধিত হয়, বিশেষ করে ইস্তানবুলে প্রতিষ্ঠিত শিক্ষাকেন্দ্রগুলোতে।\n\n'
                                    '### পতন:\n'
                                    '• ১৭শ শতাব্দীর পর থেকে ইউরোপীয় শক্তির উত্থান ও অভ্যন্তরীণ দুর্বলতার কারণে অটোমান সাম্রাজ্য ক্রমশ দুর্বল হয়ে পড়ে।\n'
                                    '• ১৯শ শতাব্দীতে সাম্রাজ্যকে বলা হতো "Sick Man of Europe"।\n'
                                    '• প্রথম বিশ্বযুদ্ধের পর ১৯২২ সালে আনুষ্ঠানিকভাবে অটোমান খিলাফতের অবসান ঘটে এবং আধুনিক তুরস্ক প্রজাতন্ত্র প্রতিষ্ঠিত হয়।\n\n'
                                    '✨ **সারাংশ:** অটোমান সাম্রাজ্য ছিল ইসলামী ইতিহাসের শেষ মহান সাম্রাজ্য, যা প্রায় ছয় শতাব্দী ধরে রাজনৈতিক, সাংস্কৃতিক ও ধর্মীয় নেতৃত্ব দিয়েছে। '
                                    'তাদের স্থাপত্য, প্রশাসন ও সাংস্কৃতিক ঐতিহ্য আজও বিশ্বকে গভীরভাবে প্রভাবিত করছে।',
                          isDarkMode,
                        ),

                        const SizedBox(height: 20),

                        _buildSectionHeader(
                          isEnglish
                              ? 'Fundamentals of Islam'
                              : 'ইসলামের মৌলিক বিষয়',
                          Icons.book,
                          isDarkMode,
                        ),
                        _buildContentCard(
                          isEnglish
                              ? '### The Five Pillars of Islam:\n'
                                    '1. Shahadah – Declaration of Faith\n'
                                    '2. Salah – Five daily prayers\n'
                                    '3. Sawm – Fasting during Ramadan\n'
                                    '4. Zakat – Charity for the poor from the wealthy\n'
                                    '5. Hajj – Pilgrimage to Mecca for those who are able'
                              : '### ইসলামের পাঁচটি স্তম্ভ:\n'
                                    '১. শাহাদাহ – ঈমানের স্বীকৃতি\n'
                                    '২. সালাত – পাঁচ ওয়াক্ত নামাজ\n'
                                    '৩. সিয়াম – রমজান মাসে রোজা\n'
                                    '৪. যাকাত – ধনীদের থেকে দরিদ্রদের জন্য দান\n'
                                    '৫. হজ – সামর্থ্যবানদের জন্য মক্কা সফর',
                          isDarkMode,
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: Text(
                            isEnglish
                                ? '"Indeed, the religion in the sight of Allah is Islam."\n(Surah Al-Imran: 19)'
                                : '"নিশ্চয়ই আল্লাহর নিকট গ্রহণযোগ্য ধর্ম হল ইসলাম"\n(সূরা আলে ইমরান: ১৯)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AppColors.getPrimaryColor(isDarkMode),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                width: mediaQuery.size.width,
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                color: Colors.transparent,
                margin: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
                child: _buildAdaptiveBannerWidget(_bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.getPrimaryColor(isDarkMode), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(String content, bool isDarkMode) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.getBorderColor(isDarkMode).withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.getCardColor(isDarkMode),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.getTextColor(isDarkMode),
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String year, String event, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryColor(isDarkMode),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                year,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 2,
              height: 25,
              color: AppColors.getPrimaryColor(isDarkMode).withOpacity(0.6),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              event,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextColor(isDarkMode),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpansionItem(String title, String content, bool isDarkMode) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.getCardColor(isDarkMode),
      child: ExpansionTile(
        iconColor: AppColors.getPrimaryColor(isDarkMode),
        collapsedIconColor: AppColors.getPrimaryColor(isDarkMode),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.getPrimaryColor(isDarkMode),
          ),
        ),
        children: [
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextColor(isDarkMode),
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
