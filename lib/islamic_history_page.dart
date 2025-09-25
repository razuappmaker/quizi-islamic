import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart'; // তোমার ad_helper.dart ফাইল import

class IslamicHistoryPage extends StatefulWidget {
  const IslamicHistoryPage({super.key});

  @override
  State<IslamicHistoryPage> createState() => _IslamicHistoryPageState();
}

class _IslamicHistoryPageState extends State<IslamicHistoryPage> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    // AdMob initialize
    await AdHelper.initialize();

    // Banner Ad তৈরি এবং লোড
    _bannerAd = AdHelper.createBannerAd(
      AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
          print('Banner Ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner Ad failed: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();

    // ১০ সেকেন্ড পরে Interstitial Ad দেখাও
    Future.delayed(const Duration(seconds: 10), () {
      AdHelper.showInterstitialAd(adContext: 'IslamicHistoryPage');
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDarkMode ? Colors.green[900]! : Colors.green[700]!,
                isDarkMode ? Colors.green[700]! : Colors.green[500]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'ইসলামের সংক্ষিপ্ত ইতিহাস',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.only(
              bottom: _isBannerAdLoaded ? _bannerAd!.size.height.toDouble() : 0,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? LinearGradient(
                        colors: [Colors.black, Colors.green[900]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : LinearGradient(
                        colors: [Colors.green[50]!, Colors.white],
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
                      'ইসলামের সূচনা',
                      Icons.lightbulb_outline,
                      isDarkMode,
                    ),
                    _buildContentCard(
                      'ইসলামের ইতিহাস শুরু হয় ৭ম শতাব্দীতে আরব উপদ্বীপে। আল্লাহ তাআলা শেষ নবী হযরত মুহাম্মদ (সা.)-এর মাধ্যমে ইসলাম ধর্মের পূর্ণতা দান করেন। '
                      'মক্কা নগরীতে ৫৭০ খ্রিস্টাব্দে তাঁর জন্ম এবং ৬১০ খ্রিস্টাব্দে প্রথম ওহী প্রাপ্তির মাধ্যমে ইসলামের যাত্রা শুরু হয়।',
                      isDarkMode,
                    ),

                    const SizedBox(height: 20),

                    _buildSectionHeader(
                      'গুরুত্বপূর্ণ ঘটনাবলী',
                      Icons.event,
                      isDarkMode,
                    ),
                    _buildTimelineItem(
                      '৬১০ খ্রিস্টাব্দ',
                      'প্রথম ওহী প্রাপ্তি (হেরা গুহায়)',
                      isDarkMode,
                    ),
                    _buildTimelineItem(
                      '৬২২ খ্রিস্টাব্দ',
                      'হিজরত (মক্কা থেকে মদিনায়)',
                      isDarkMode,
                    ),
                    _buildTimelineItem(
                      '৬৩০ খ্রিস্টাব্দ',
                      'মক্কা বিজয়',
                      isDarkMode,
                    ),
                    _buildTimelineItem(
                      '৬৩২ খ্রিস্টাব্দ',
                      'বিদায় হজ ও নবী (সা.)-এর ওফাত',
                      isDarkMode,
                    ),

                    const SizedBox(height: 20),

                    _buildSectionHeader(
                      'খোলাফায়ে রাশেদীন',
                      Icons.people,
                      isDarkMode,
                    ),
                    _buildContentCard(
                      'খোলাফায়ে রাশেদীন: ইসলামের সোনালি সময়\n\n'
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
                      'ইসলামী সাম্রাজ্য ও সভ্যতা',
                      Icons.architecture,
                      isDarkMode,
                    ),
                    _buildExpansionItem(
                      'উমাইয়া খিলাফত (৬৬১–৭৫০ খ্রিস্টাব্দ)',
                      'উমাইয়া খিলাফত ছিল ইসলামের ইতিহাসে প্রথম বংশানুক্রমিক (hereditary) খিলাফত, যার রাজধানী ছিল দামেস্ক। '
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
                      'আব্বাসীয় খিলাফত (৭৫০–১২৫৮ খ্রিস্টাব্দ)',
                      'আব্বাসীয় খিলাফত ছিল ইসলামের ইতিহাসে এক সোনালী যুগের সূচনা, যার রাজধানী ছিল বাগদাদ। '
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
                      'অটোমান সাম্রাজ্য (১২৯৯–১৯২২ খ্রিস্টাব্দ)',
                      'অটোমান সাম্রাজ্য ছিল ইসলামী ইতিহাসের সর্বাধিক দীর্ঘস্থায়ী ও সর্বশেষ বৃহৎ খিলাফত। '
                          'ওসমান প্রথম (Osman I) ১২৯৯ খ্রিস্টাব্দে এটি প্রতিষ্ঠা করেন। প্রায় ৬০০ বছরেরও বেশি সময় ধরে '
                          'অটোমানরা ইউরোপ, এশিয়া এবং আফ্রিকার বিস্তৃত অঞ্চলে শাসন করেছেন। তাদের রাজধানী প্রথমে বুরসা, পরে এদিরনে এবং অবশেষে ইস্তানবুল (কনস্টান্টিনোপল) হয়।\n\n'
                          '### ভৌগোলিক বিস্তার:\n'
                          '• তিন মহাদেশে বিস্তৃত সাম্রাজ্য— ইউরোপের বলকান অঞ্চল থেকে শুরু করে মধ্যপ্রাচ্য, উত্তর আফ্রিকা ও আরব উপদ্বীপ পর্যন্ত।\n'
                          '• ১৪৫৩ সালে সুলতান **মেহমেদ দ্য কনকারার (Mehmed II) কনস্টান্টিনোপল বিজয় করে ইস্তানবুলকে রাজধানী ঘোষণা করেন।\n'
                          '• সর্বোচ্চ সময়ে সাম্রাজ্যের আয়তন প্রায় ৫ মিলিয়ন বর্গকিলোমিটার ছিল।\n\n'
                          '### প্রশাসন ও সমাজব্যবস্থা:\n'
                          '• অটোমানরা অত্যন্ত দক্ষ প্রশাসনিক কাঠামো তৈরি করে, যেখানে মিল্লাত সিস্টেম এর মাধ্যমে বিভিন্ন ধর্মীয় সম্প্রদায়কে স্বায়ত্তশাসন দেওয়া হত।\n'
                          '• অটোমান সেনাবাহিনী, বিশেষ করে জানিসারি বাহিনী, বিশ্বের অন্যতম শক্তিশালী সামরিক বাহিনী হিসেবে পরিচিত ছিল।\n'
                          '• অর্থনীতি কৃষি, বাণিজ্য এবং সিল্ক রোডের উপর নির্ভরশীল ছিল।\n\n'
                          '### জ্ঞান-বিজ্ঞান ও স্থাপত্য:\n'
                          '• ইসলামী স্থাপত্যের অসাধারণ নিদর্শন, যেমন **সুলেইমানিয়া মসজিদ** ও নীল মসজিদ (Blue Mosque) অটোমান যুগে নির্মিত হয়।\n'
                          '• সাহিত্য, সংগীত, ক্যালিগ্রাফি ও কারুশিল্পে অটোমানদের অবদান সমগ্র ইসলামী বিশ্বের সাংস্কৃতিক ঐতিহ্যকে সমৃদ্ধ করেছে।\n'
                          '• চিকিৎসা ও বিজ্ঞানেও উন্নতি সাধিত হয়, বিশেষ করে ইস্তানবুলে প্রতিষ্ঠিত শিক্ষাকেন্দ্রগুলোতে।\n\n'
                          '### পতন:\n'
                          '• ১৭শ শতাব্দীর পর থেকে ইউরোপীয় শক্তির উত্থান ও অভ্যন্তরীণ দুর্বলতার কারণে অটোমান সাম্রাজ্য ক্রমশ দুর্বল হয়ে পড়ে।\n'
                          '• ১৯শ শতাব্দীতে সাম্রাজ্যকে বলা হতো “Sick Man of Europe”।\n'
                          '• প্রথম বিশ্বযুদ্ধের পর ১৯২২ সালে আনুষ্ঠানিকভাবে অটোমান খিলাফতের অবসান ঘটে এবং আধুনিক তুরস্ক প্রজাতন্ত্র প্রতিষ্ঠিত হয়।\n\n'
                          '✨ **সারাংশ:** অটোমান সাম্রাজ্য ছিল ইসলামী ইতিহাসের শেষ মহান সাম্রাজ্য, যা প্রায় ছয় শতাব্দী ধরে রাজনৈতিক, সাংস্কৃতিক ও ধর্মীয় নেতৃত্ব দিয়েছে। '
                          'তাদের স্থাপত্য, প্রশাসন ও সাংস্কৃতিক ঐতিহ্য আজও বিশ্বকে গভীরভাবে প্রভাবিত করছে।',
                      isDarkMode,
                    ),

                    const SizedBox(height: 20),

                    _buildSectionHeader(
                      'ইসলামের মৌলিক বিষয়',
                      Icons.book,
                      isDarkMode,
                    ),
                    _buildContentCard(
                      '### ইসলামের পাঁচটি স্তম্ভ:\n'
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
                        '"নিশ্চয়ই আল্লাহর নিকট গ্রহণযোগ্য ধর্ম হল ইসলাম"\n(সূরা আলে ইমরান: ১৯)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: isDarkMode
                              ? Colors.green[200]
                              : Colors.green[700],
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

          // Positioned Banner Ad নিচে
          if (_isBannerAdLoaded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDarkMode ? Colors.green[300] : Colors.green[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.green[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Content Card
  Widget _buildContentCard(String content, bool isDarkMode) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
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

  // Timeline Item
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
                color: isDarkMode ? Colors.green[700] : Colors.green[500],
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
              color: isDarkMode ? Colors.green[700] : Colors.green[300],
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
                color: isDarkMode ? Colors.white70 : Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Expansion Item
Widget _buildExpansionItem(String title, String content, bool isDarkMode) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    color: isDarkMode ? Colors.grey[850] : Colors.white,
    child: ExpansionTile(
      iconColor: isDarkMode ? Colors.green[300] : Colors.green[700],
      collapsedIconColor: isDarkMode ? Colors.green[200] : Colors.green[600],
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.green[300] : Colors.green[700],
        ),
      ),
      children: [
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    ),
  );
}
