import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'ad_helper.dart';
import '../providers/language_provider.dart';

class ProphetBiographyPage extends StatefulWidget {
  const ProphetBiographyPage({super.key});

  @override
  State<ProphetBiographyPage> createState() => _ProphetBiographyPageState();
}

class _ProphetBiographyPageState extends State<ProphetBiographyPage> {
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
      final lastShownDate = prefs.getString('last_interstitial_shown_date');
      final today = DateTime.now().toString().split(' ')[0];

      if (lastShownDate != today) {
        await prefs.setString('last_interstitial_shown_date', today);
        setState(() {
          _hasShownInterstitialToday = false;
        });

        Future.delayed(const Duration(seconds: 5), () {
          _showInterstitialAdIfAllowed();
        });
      } else {
        setState(() {
          _hasShownInterstitialToday = true;
        });
      }
    } catch (e) {
      print('Error checking interstitial daily limit: $e');
      Future.delayed(const Duration(seconds: 5), () {
        _showInterstitialAdIfAllowed();
      });
    }
  }

  void _showInterstitialAdIfAllowed() {
    if (!_hasShownInterstitialToday) {
      AdHelper.showInterstitialAd(
        adContext: 'ProphetBiographyPage',
        onAdShowed: () {
          _markInterstitialAsShown();
        },
        onAdDismissed: () {
          print('Interstitial ad dismissed in ProphetBiographyPage');
        },
        onAdFailedToShow: () {
          print('Interstitial ad failed to show in ProphetBiographyPage');
        },
      );
    }
  }

  Future<void> _markInterstitialAsShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_interstitial_shown_date',
        DateTime.now().toString().split(' ')[0],
      );
      setState(() {
        _hasShownInterstitialToday = true;
      });
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
        title: Text(
          isEnglish ? 'Prophet\'s Seerah' : 'নবী সীরাত',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.green[800] : Colors.green[700],
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
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // পরিচিতি
                      _buildSectionHeader(
                        isEnglish
                            ? 'Mercy to the Worlds ﷺ'
                            : 'রাহমাতুল্লিল আলামীন ﷺ',
                        Icons.lightbulb_outline,
                        isDarkMode,
                      ),
                      _buildContentCard(
                        isEnglish
                            ? 'Prophet Muhammad (Peace Be Upon Him) is the final Prophet and Messenger of Islam. '
                                  'Allah sent him as a mercy to all mankind and the entire universe.\n\n'
                                  'His way of life is the best example for humanity. '
                                  'Truthfulness, justice, mercy, gentleness, forgiveness, and complete obedience to Allah—'
                                  'these qualities made his character unique and eternally exemplary.\n\n'
                                  '✨ Therefore, for a Muslim, following the life of Prophet Muhammad (PBUH) '
                                  'is the true path to success in this world and the hereafter.'
                            : 'হযরত মুহাম্মদ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) ইসলামের সর্বশেষ নবী ও রাসূল। '
                                  'আল্লাহ তাঁকে সমগ্র মানবজাতি ও বিশ্বজগতের জন্য রহমত স্বরূপ প্রেরণ করেছেন।\n\n'
                                  'তাঁর জীবনধারা মানবতার জন্য সর্বোত্তম আদর্শ। '
                                  'সত্যবাদিতা, ন্যায়পরায়ণতা, দয়া, নম্রতা, ক্ষমাশীলতা এবং আল্লাহর প্রতি পূর্ণ আনুগত্য—'
                                  'এই গুণাবলী তাঁর চরিত্রকে করে তুলেছে অনন্য ও চিরন্তন শিক্ষণীয়।\n\n'
                                  '✨ তাই, একজন মুসলমানের জন্য হযরত মুহাম্মদ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম)-এর জীবনকে '
                                  'অনুসরণ করা হলো দুনিয়া ও আখিরাতে সফলতার প্রকৃত পথ।',
                        isDarkMode,
                      ),

                      // জন্ম ও শৈশব
                      _buildBiographyCategory(
                        isEnglish ? 'Birth & Childhood' : 'জন্ম ও শৈশব',
                        Icons.child_care,
                        [
                          _buildEventItem(
                            isEnglish ? '570 CE' : '৫৭০ খ্রিস্টাব্দ',
                            isEnglish
                                ? 'Born in the noble Quraysh tribe of Mecca'
                                : 'মক্কার মর্যাদাপূর্ণ কুরাইশ বংশে জন্মগ্রহণ করেন।',
                            isEnglish
                                ? 'This year is called **Amul Fil** (Year of the Elephant). \n'
                                      'Father: Abdullah ibn Abdul Muttalib \n'
                                      'Mother: Amina bint Wahb \n'
                                      '✨ From birth, he was a symbol of Allah\'s special mercy.'
                                : 'এই বছরকে **আমুল ফীল** (হাতির বছর) বলা হয়। \n'
                                      'পিতা: আবদুল্লাহ ইবনে আবদুল মুত্তালিব \n'
                                      'মাতা: আমিনা বিনতে ওয়াহাব \n'
                                      '✨ জন্ম থেকেই তিনি ছিলেন আল্লাহর বিশেষ রহমতের প্রতীক।',
                            isDarkMode,
                          ),

                          _buildEventItem(
                            isEnglish ? 'Before Birth' : 'জন্মের পূর্বেই',
                            isEnglish ? 'Father\'s Demise' : 'পিতার ইন্তেকাল',
                            isEnglish
                                ? 'Prophet Muhammad (PBUH)\'s father Abdullah ibn Abdul Muttalib passed away about 6 months before his birth. \n'
                                      '✨ Thus, he grew up fatherless from birth.'
                                : 'হযরত মুহাম্মদ (সা.) জন্মগ্রহণের প্রায় ৬ মাস পূর্বে তাঁর পিতা '
                                      'আবদুল্লাহ ইবনে আবদুল মুত্তালিব ইন্তেকাল করেন। \n'
                                      '✨ ফলে জন্মের পর থেকেই তিনি পিতৃহীন অবস্থায় বেড়ে ওঠেন।',
                            isDarkMode,
                          ),

                          _buildEventItem(
                            isEnglish ? 'After Birth' : 'জন্মের পর',
                            isEnglish
                                ? 'Raised by Halima Saadia'
                                : 'হালিমা সাদিয়ার তত্ত্বাবধানে লালন-পালন',
                            isEnglish
                                ? 'According to Arab tradition, infant Muhammad (PBUH) was entrusted to Halima Saadia for upbringing in a Bedouin family. \n'
                                      'There he grew up in the pure desert environment and learned **pure Arabic language** and healthy lifestyle.'
                                : 'আরবের প্রচলিত রীতি অনুযায়ী শিশু মুহাম্মদ (সা.)-কে '
                                      'বেদুইন পরিবারে লালন-পালনের জন্য হালিমা সাদিয়ার কাছে অর্পণ করা হয়। \n'
                                      'সেখানে তিনি নির্মল মরুভূমির পরিবেশে বেড়ে ওঠেন এবং '
                                      '**খাঁটি আরবি ভাষা** ও সুস্থ-সবল জীবনযাপনের শিক্ষা লাভ করেন।',
                            isDarkMode,
                          ),
                        ],
                        isDarkMode,
                      ),

                      // নামকরণ ও বাল্যকাল
                      _buildBiographyCategory(
                        isEnglish
                            ? 'Naming & Early Childhood'
                            : 'নামকরণ ও বাল্যকাল',
                        Icons.assignment_ind,
                        [
                          _buildEventItem(
                            isEnglish ? '7th Day After Birth' : 'জন্মের ৭ম দিন',
                            isEnglish
                                ? 'Grandfather names him "Muhammad"'
                                : 'দাদা আবদুল মুত্তালিব নাম রাখেন "মুহাম্মদ"',
                            isEnglish
                                ? 'On the seventh day after birth, his grandfather Abdul Muttalib named him **"Muhammad"**. \n'
                                      'The meaning of this name is — "Praised", "Worthy of high praise". \n'
                                      '✨ Allah\'s special miracle was that although such a name was rare in Arab society, '
                                      'it later became the most spoken and beloved name in the whole world.'
                                : 'জন্মের সপ্তম দিনে দাদা আবদুল মুত্তালিব তাঁর নাম রাখেন **"মুহাম্মদ"**। \n'
                                      'এ নামের অর্থ হলো — "প্রশংসিত", "উচ্চ প্রশংসার যোগ্য"। \n'
                                      '✨ আল্লাহর বিশেষ কুদরত ছিল যে, এমন নাম আরব সমাজে বিরল হলেও '
                                      'পরবর্তীতে সমগ্র বিশ্বে সর্বাধিক উচ্চারিত ও ভালোবাসার নাম হয়ে ওঠে।',
                            isDarkMode,
                          ),

                          _buildEventItem(
                            isEnglish ? '6 Years Old' : '৬ বছর বয়স',
                            isEnglish
                                ? 'Mother\'s Demise'
                                : 'মাতা হযরত আমিনা বিনতে ওয়াহাবের ইন্তেকাল',
                            isEnglish
                                ? 'Prophet Muhammad (PBUH) lost his mother at the age of 6. '
                                      'After that, he stayed under the care of his grandfather Abdul Muttalib. \n'
                                      '✨ This event is considered the first major loss in his life.'
                                : 'হযরত মুহাম্মদ (সা.) ৬ বছর বয়সে মাতার ইন্তেকাল ঘটে। '
                                      'এরপর তিনি দাদা আবদুল মুত্তালিবের তত্ত্বাবধানে থাকেন。 \n'
                                      '✨ এই সময়ের ঘটনা তাঁর জীবনে প্রথম বড় ক্ষতি হিসেবে বিবেচিত।',
                            isDarkMode,
                          ),

                          _buildEventItem(
                            isEnglish ? '8 Years Old' : '৮ বছর বয়স',
                            isEnglish
                                ? 'Grandfather\'s Demise'
                                : 'দাদা আবদুল মুত্তালিবের ইন্তেকাল',
                            isEnglish
                                ? 'Prophet Muhammad (PBUH) lost his grandfather at the age of 8. '
                                      'After that, he was raised under the care of his uncle Abu Talib. \n'
                                      '✨ His uncle\'s affection and protection kept his childhood safe and stable.'
                                : 'হযরত মুহাম্মদ (সা.) ৮ বছর বয়সে দাদার ইন্তেকাল ঘটে। '
                                      'এরপর চাচা হযরত আবু তালিবের তত্ত্বাবধানে লালিত-পালিত হন। \n'
                                      '✨ চাচার স্নেহ ও রক্ষা তাঁর শৈশবকে নিরাপদ এবং স্থিতিশীল রাখে।',
                            isDarkMode,
                          ),
                        ],
                        isDarkMode,
                      ),

                      // যৌবন ও বিবাহ
                      _buildBiographyCategory(
                        isEnglish ? 'Youth & Marriage' : 'যৌবন ও বিবাহ',
                        Icons.people,
                        [
                          _buildEventItem(
                            isEnglish ? 'Teenage Years' : 'কিশোর বয়স',
                            isEnglish
                                ? 'Trade journeys with uncle Abu Talib'
                                : 'চাচা হযরত আবু তালিবের সাথে বাণিজ্যিক যাত্রা',
                            isEnglish
                                ? 'Business trips to Syria and other countries. During this time, Muhammad (PBUH) '
                                      'earned the title **"Al-Amin"** (The Trustworthy), which reflected his honesty and credibility.'
                                : 'সিরিয়া ও অন্যান্য দেশগুলোতে ব্যবসায়িক সফর। এই সময় মুহাম্মদ (সা.) '
                                      '"আল-আমিন" (বিশ্বস্ত) উপাধি অর্জন করেন, যা তাঁর সততা ও বিশ্বাসযোগ্যতার পরিচায়ক।',
                            isDarkMode,
                          ),
                          _buildEventItem(
                            isEnglish ? '25 Years Old' : '২৫ বছর বয়স',
                            isEnglish
                                ? 'Marriage to Khadija (RA)'
                                : 'হযরত খাদীজা (রাঃ)-এর সাথে বিবাহ',
                            isEnglish
                                ? 'Khadija was a famous and wealthy businesswoman, aged 40. '
                                      'This marriage is an example of an ideal marital relationship in Islamic history.'
                                : 'হযরত খাদীজা ছিলেন প্রখ্যাত ও সমৃদ্ধ ব্যবসায়ী মহিলা, বয়স ৪০ বছর। '
                                      'এই বিবাহ ইসলামী ইতিহাসে একটি আদর্শ দাম্পত্য সম্পর্কের উদাহরণ।',
                            isDarkMode,
                          ),
                          _buildEventItem(
                            isEnglish
                                ? 'Life After Marriage'
                                : 'বিবাহ পরবর্তী জীবন',
                            isEnglish
                                ? 'Happy Married Life'
                                : 'সুখী দাম্পত্য জীবন',
                            isEnglish
                                ? 'Prophet Muhammad (PBUH) and Khadija had 6 children: '
                                      'Qasim, Abdullah, Zainab, Ruqayyah, Umm Kulthum, and Fatima. '
                                      '✨ Family life was peaceful and exemplary.'
                                : 'হযরত মুহাম্মদ (সা.) এবং হযরত খাদীজার সংসারে ৬ সন্তান জন্মগ্রহণ করেন: '
                                      'কাসিম, আবদুল্লাহ, জয়নব, রুকাইয়া, উম্মে কুলসুম এবং ফাতিমা। '
                                      '✨ পরিবারিক জীবন ছিল শান্তিময় এবং আদর্শমূলক।',
                            isDarkMode,
                          ),
                        ],
                        isDarkMode,
                      ),

                      // নবুয়াতের সূচনা
                      _buildBiographyCategory(
                        isEnglish
                            ? 'Beginning of Prophethood'
                            : 'নবুয়াতের সূচনা',
                        Icons.auto_awesome,
                        [
                          _buildEventItem(
                            isEnglish ? '40 Years Old' : '৪০ বছর বয়স',
                            isEnglish
                                ? 'Meditation in Cave of Hira'
                                : 'হেরা গুহায় ধ্যান ও তাত্ত্বিক চিন্তাভাবনা',
                            isEnglish
                                ? 'Prophet Muhammad (PBUH) regularly sat in solitude seeking Allah\'s truth and '
                                      'meditating. This was mental and spiritual preparation for prophethood.'
                                : 'হযরত মুহাম্মদ (সা.) নিয়মিত একাকীত্বে বসে আল্লাহর সত্য অনুসন্ধান ও '
                                      'ধ্যান করতেন। এটি ছিল নবুওতের জন্য মানসিক ও আধ্যাত্মিক প্রস্তুতি।',
                            isDarkMode,
                          ),
                          _buildEventItem(
                            isEnglish ? '610 CE' : '৬১০ খ্রিস্টাব্দ',
                            isEnglish
                                ? 'First Revelation'
                                : 'প্রথম ওহী প্রাপ্তি',
                            isEnglish
                                ? 'The first revelation was sent through Angel Jibril (AS), through which Allah '
                                      'sent Prophet Muhammad (PBUH) the **"Iqra" (Read)** verse.\n'
                                      '✨ This marked the beginning of prophethood in Islam.'
                                : 'জিবরাঈল (আ.)-এর মাধ্যমে প্রথম ওহী নাযিল হয়, যার মাধ্যমে আল্লাহ তাআলা '
                                      'হযরত মুহাম্মদ (সা.)-কে পাঠিয়েছিলেন **"ইকরা" (পড়)** আয়াত।\n'
                                      '✨ এটি ইসলামের নবুওতের সূচনা।',
                            isDarkMode,
                          ),
                          _buildEventItem(
                            isEnglish ? 'After Revelation' : 'ওহী প্রাপ্তির পর',
                            isEnglish
                                ? 'Informing Khadija (RA) about the event'
                                : 'হযরত খাদীজা (রাঃ)-কে ঘটনা অবহিত করা',
                            isEnglish
                                ? 'The first person to accept Islam was Khadija (RA), who gave the Prophet '
                                      'full support and courage.\n'
                                      '✨ Her support played a very important role on the first day of prophethood.'
                                : 'প্রথম ইসলাম গ্রহণকারী ছিলেন হযরত খাদীজা (রাঃ), যিনি নবীজিকে '
                                      'পূর্ণ সমর্থন ও সাহস প্রদান করেন।\n'
                                      '✨ তাঁর সমর্থন নবুওতের প্রথম দিনে অত্যন্ত গুরুত্বপূর্ণ ভূমিকা পালন করে।',
                            isDarkMode,
                          ),
                        ],
                        isDarkMode,
                      ),

                      // বাকি অংশগুলো একইভাবে translation করতে হবে...
                      // মি'রাজ, দাওয়াতের পর্যায়, তায়েফ গমন, হিজরত, মদিনার জীবন,
                      // গুরুত্বপূর্ণ যুদ্ধসমূহ, মক্কা বিজয়, বিদায় হজ্জ, ওফাত
                      const SizedBox(height: 30),

                      // শেষ আয়াত
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            isEnglish
                                ? '"Indeed, Allah and His angels send blessings upon the Prophet. '
                                      'O you who believe! Send blessings upon him and greet him with peace."\n\n'
                                      '(Surah Al-Ahzab: 56)'
                                : '"আল্লাহ ও তাঁর ফেরেশতাগণ নবীর উপর দরূদ প্রেরণ করেন। '
                                      'হে মুমিনগণ! তোমরাও তাঁর উপর দরূদ প্রেরণ কর এবং বিশেষভাবে সালাম পেশ কর।"\n\n'
                                      '(সূরা আল-আহযাব: ৫৬)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                              color: isDarkMode
                                  ? Colors.green[200]
                                  : Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
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

  // সেকশন হেডার widget
  Widget _buildSectionHeader(String title, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDarkMode ? Colors.green[300] : Colors.green[700],
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.green[900],
          ),
        ),
      ],
    );
  }

  // কন্টেন্ট কার্ড widget
  Widget _buildContentCard(String content, bool isDarkMode) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDarkMode ? Colors.white70 : Colors.grey[800],
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  // জীবনী ক্যাটাগরি widget
  Widget _buildBiographyCategory(
    String title,
    IconData icon,
    List<Widget> events,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildSectionHeader(title, icon, isDarkMode),
        const SizedBox(height: 12),
        Column(children: events),
      ],
    );
  }

  // ইভেন্ট আইটেম widget
  Widget _buildEventItem(
    String year,
    String title,
    String description,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.green[900]!.withOpacity(0.2)
            : Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDarkMode
              ? Colors.green[700]!.withOpacity(0.3)
              : Colors.green[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[700] : Colors.green[600],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  year,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.green[100] : Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
