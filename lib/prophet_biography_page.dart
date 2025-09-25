import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart'; // তোমার ad_helper.dart ফাইল import

class ProphetBiographyPage extends StatefulWidget {
  const ProphetBiographyPage({super.key});

  @override
  State<ProphetBiographyPage> createState() => _ProphetBiographyPageState();
}

class _ProphetBiographyPageState extends State<ProphetBiographyPage> {
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

    // পেইজ খোলার সাথে সাথে Interstitial Ad দেখার চেষ্টা
    Future.delayed(const Duration(seconds: 5), () {
      AdHelper.showInterstitialAd(adContext: 'ProphetBiographyPage');
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
        title: const Text(
          'মহানবী (সা.)-এর জীবনী',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.green[800] : Colors.green[700],
      ),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.only(
              bottom: _isBannerAdLoaded ? _bannerAd!.size.height.toDouble() : 0,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // পরিচিতি
                  _buildSectionHeader(
                    'রাহমাতুল্লিল আলামীন ﷺ',
                    Icons.lightbulb_outline,
                    isDarkMode,
                  ),
                  _buildContentCard(
                    'হযরত মুহাম্মদ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) ইসলামের সর্বশেষ নবী ও রাসূল। '
                    'আল্লাহ তাঁকে সমগ্র মানবজাতি ও বিশ্বজগতের জন্য রহমত স্বরূপ প্রেরণ করেছেন।\n\n'
                    'তাঁর জীবনধারা মানবতার জন্য সর্বোত্তম আদর্শ। '
                    'সত্যবাদিতা, ন্যায়পরায়ণতা, দয়া, নম্রতা, ক্ষমাশীলতা এবং আল্লাহর প্রতি পূর্ণ আনুগত্য—'
                    'এই গুণাবলী তাঁর চরিত্রকে করে তুলেছে অনন্য ও চিরন্তন শিক্ষণীয়।\n\n'
                    '✨ তাই, একজন মুসলমানের জন্য হযরত মুহাম্মদ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম)-এর জীবনকে '
                    'অনুসরণ করা হলো দুনিয়া ও আখিরাতে সফলতার প্রকৃত পথ।',
                    isDarkMode,
                  ),

                  // এখানে তোমার সমস্ত _buildBiographyCategory() ও _buildEventItem() যুক্ত থাকবে
                  // জন্ম ও শৈশব
                  _buildBiographyCategory('জন্ম ও শৈশব', Icons.child_care, [
                    _buildEventItem(
                      '৫৭০ খ্রিস্টাব্দ',
                      'মক্কার মর্যাদাপূর্ণ কুরাইশ বংশে জন্মগ্রহণ করেন।',
                      'এই বছরকে **আমুল ফীল** (হাতির বছর) বলা হয়। \n'
                          'পিতা: আবদুল্লাহ ইবনে আবদুল মুত্তালিব \n'
                          'মাতা: আমিনা বিনতে ওয়াহাব \n'
                          '✨ জন্ম থেকেই তিনি ছিলেন আল্লাহর বিশেষ রহমতের প্রতীক।',
                      isDarkMode,
                    ),

                    _buildEventItem(
                      'জন্মের পূর্বেই',
                      'পিতার ইন্তেকাল',
                      'হযরত মুহাম্মদ (সা.) জন্মগ্রহণের প্রায় ৬ মাস পূর্বে তাঁর পিতা '
                          'আবদুল্লাহ ইবনে আবদুল মুত্তালিব ইন্তেকাল করেন। \n'
                          '✨ ফলে জন্মের পর থেকেই তিনি পিতৃহীন অবস্থায় বেড়ে ওঠেন।',
                      isDarkMode,
                    ),

                    _buildEventItem(
                      'জন্মের পর',
                      'হালিমা সাদিয়ার তত্ত্বাবধানে লালন-পালন',
                      'আরবের প্রচলিত রীতি অনুযায়ী শিশু মুহাম্মদ (সা.)-কে '
                          'বেদুইন পরিবারে লালন-পালনের জন্য হালিমা সাদিয়ার কাছে অর্পণ করা হয়। \n'
                          'সেখানে তিনি নির্মল মরুভূমির পরিবেশে বেড়ে ওঠেন এবং '
                          '**খাঁটি আরবি ভাষা** ও সুস্থ-সবল জীবনযাপনের শিক্ষা লাভ করেন।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // নামকরণ ও বাল্যকাল
                  _buildBiographyCategory('নামকরণ ও বাল্যকাল', Icons.assignment_ind, [
                    _buildEventItem(
                      'জন্মের ৭ম দিন',
                      'দাদা আবদুল মুত্তালিব নাম রাখেন “মুহাম্মদ”',
                      'জন্মের সপ্তম দিনে দাদা আবদুল মুত্তালিব তাঁর নাম রাখেন **“মুহাম্মদ”**। \n'
                          'এ নামের অর্থ হলো — “প্রশংসিত”, “উচ্চ প্রশংসার যোগ্য”। \n'
                          '✨ আল্লাহর বিশেষ কুদরত ছিল যে, এমন নাম আরব সমাজে বিরল হলেও '
                          'পরবর্তীতে সমগ্র বিশ্বে সর্বাধিক উচ্চারিত ও ভালোবাসার নাম হয়ে ওঠে।',
                      isDarkMode,
                    ),

                    _buildEventItem(
                      '৬ বছর বয়স',
                      'মাতা হযরত আমিনা বিনতে ওয়াহাবের ইন্তেকাল',
                      'হযরত মুহাম্মদ (সা.) ৬ বছর বয়সে মাতার ইন্তেকাল ঘটে। '
                          'এরপর তিনি দাদা আবদুল মুত্তালিবের তত্ত্বাবধানে থাকেন। \n'
                          '✨ এই সময়ের ঘটনা তাঁর জীবনে প্রথম বড় ক্ষতি হিসেবে বিবেচিত।',
                      isDarkMode,
                    ),

                    _buildEventItem(
                      '৮ বছর বয়স',
                      'দাদা আবদুল মুত্তালিবের ইন্তেকাল',
                      'হযরত মুহাম্মদ (সা.) ৮ বছর বয়সে দাদার ইন্তেকাল ঘটে। '
                          'এরপর চাচা হযরত আবু তালিবের তত্ত্বাবধানে লালিত-পালিত হন। \n'
                          '✨ চাচার স্নেহ ও রক্ষা তাঁর শৈশবকে নিরাপদ এবং স্থিতিশীল রাখে।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // যৌবন ও বিবাহ
                  _buildBiographyCategory('যৌবন ও বিবাহ', Icons.people, [
                    _buildEventItem(
                      'কিশোর বয়স',
                      'চাচা হযরত আবু তালিবের সাথে বাণিজ্যিক যাত্রা',
                      'সিরিয়া ও অন্যান্য দেশগুলোতে ব্যবসায়িক সফর। এই সময় মুহাম্মদ (সা.) '
                          '“আল-আমিন” (বিশ্বস্ত) উপাধি অর্জন করেন, যা তাঁর সততা ও বিশ্বাসযোগ্যতার পরিচায়ক।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      '২৫ বছর বয়স',
                      'হযরত খাদীজা (রাঃ)-এর সাথে বিবাহ',
                      'হযরত খাদীজা ছিলেন প্রখ্যাত ও সমৃদ্ধ ব্যবসায়ী মহিলা, বয়স ৪০ বছর। '
                          'এই বিবাহ ইসলামী ইতিহাসে একটি আদর্শ দাম্পত্য সম্পর্কের উদাহরণ।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'বিবাহ পরবর্তী জীবন',
                      'সুখী দাম্পত্য জীবন',
                      'হযরত মুহাম্মদ (সা.) এবং হযরত খাদীজার সংসারে ৬ সন্তান জন্মগ্রহণ করেন: '
                          'কাসিম, আবদুল্লাহ, জয়নব, রুকাইয়া, উম্মে কুলসুম এবং ফাতিমা। '
                          '✨ পরিবারিক জীবন ছিল শান্তিময় এবং আদর্শমূলক।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // নবুয়াতের সূচনা
                  _buildBiographyCategory('নবুয়াতের সূচনা', Icons.auto_awesome, [
                    _buildEventItem(
                      '৪০ বছর বয়স',
                      'হেরা গুহায় ধ্যান ও তাত্ত্বিক চিন্তাভাবনা',
                      'হযরত মুহাম্মদ (সা.) নিয়মিত একাকীত্বে বসে আল্লাহর সত্য অনুসন্ধান ও '
                          'ধ্যান করতেন। এটি ছিল নবুওতের জন্য মানসিক ও আধ্যাত্মিক প্রস্তুতি।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      '৬১০ খ্রিস্টাব্দ',
                      'প্রথম ওহী প্রাপ্তি',
                      'জিবরাঈল (আ.)-এর মাধ্যমে প্রথম ওহী নাযিল হয়, যার মাধ্যমে আল্লাহ তাআলা '
                          'হযরত মুহাম্মদ (সা.)-কে পাঠিয়েছিলেন **“ইকরা” (পড়)** আয়াত।\n'
                          '✨ এটি ইসলামের নবুওতের সূচনা।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'ওহী প্রাপ্তির পর',
                      'হযরত খাদীজা (রাঃ)-কে ঘটনা অবহিত করা',
                      'প্রথম ইসলাম গ্রহণকারী ছিলেন হযরত খাদীজা (রাঃ), যিনি নবীজিকে '
                          'পূর্ণ সমর্থন ও সাহস প্রদান করেন।\n'
                          '✨ তাঁর সমর্থন নবুওতের প্রথম দিনে অত্যন্ত গুরুত্বপূর্ণ ভূমিকা পালন করে।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // মি'রাজ
                  _buildBiographyCategory('মি\'রাজ', Icons.flight_takeoff, [
                    _buildEventItem(
                      '৬২০ খ্রিস্টাব্দ',
                      'ইসরা ও মি\'রাজ',
                      'হযরত মুহাম্মদ (সা.) মসজিদুল হারাম থেকে মসজিদুল আকসা পর্যন্ত এবং এরপর সপ্তম আসমান পর্যন্ত যাত্রা করেন। '
                          'এটি ইসলামী ইতিহাসের একটি বিস্ময়কর আধ্যাত্মিক যাত্রা।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'মি\'রাজের রাত',
                      'সর্বোচ্চ আধ্যাত্মিক অভিজ্ঞতা',
                      'হযরত মুহাম্মদ (সা.) আল্লাহর সঙ্গে সরাসরি সংযোগ স্থাপন করেন। এই যাত্রায় পাঁচ ওয়াক্ত নামাজ ফরজ হয়। '
                          '✨ এটি মুসলিম উম্মাহর জন্য অত্যন্ত গুরুত্বপূর্ণ ঘটনা।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'ফজরের পর',
                      'মি\'রাজের ঘটনা বর্ণনা',
                      'নবীজি (সা.) কুরাইশ নেতাদের মি\'রাজের ঘটনা জানান। তারা বিশ্বাস না করলেও হযরত আবু বকর (রাঃ) দৃঢ়ভাবে নিশ্চিত হন এবং নবীজিকে সমর্থন দেন।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // দাওয়াতের পর্যায়
                  _buildBiographyCategory('দাওয়াতের পর্যায়', Icons.mic, [
                    _buildEventItem(
                      '৬১০–৬১৩ খ্রিস্টাব্দ',
                      'গোপনে ইসলামের দাওয়াত',
                      'হযরত মুহাম্মদ (সা.) প্রথম তিন বছর নিকটস্থ পরিবার ও ঘনিষ্ঠ বন্ধুদের মধ্যে ইসলাম প্রচার করেন। '
                          'এই সময়ের মূল লক্ষ্য ছিল মানুষের ঈমান ও চরিত্রের প্রস্তুতি। ✨ প্রাথমিক দাওয়াত ছিল গোপন এবং সংক্ষিপ্ত।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      '৬১৩ খ্রিস্টাব্দ',
                      'প্রকাশ্যে ইসলামের দাওয়াত',
                      'হযরত মুহাম্মদ (সা.) সাফা পাহাড় থেকে সকলের জন্য প্রকাশ্যে ইসলামের বার্তা প্রচার শুরু করেন। '
                          'এর ফলে কুরাইশ নেতাদের মধ্যে বিরোধ সৃষ্টি হয় এবং প্রতিক্রিয়া শুরু হয়। '
                          '✨ এটি ইসলামের সার্বজনীন দাওয়াতের সূচনা।',
                      isDarkMode,
                    ),

                    _buildEventItem(
                      'বিরোধিতা',
                      'কুরাইশদের বিরোধ ও নিপীড়ন',
                      'হযরত মুহাম্মদ (সা.)-এর অনুসারীদের উপর কুরাইশরা নানা ধরণের অত্যাচার চালায়। '
                          'এর মধ্যে অন্তর্ভুক্ত ছিল শারীরিক নির্যাতন, অর্থনৈতিক বয়কট এবং সামাজিক বয়কট। '
                          '✨ এই সময় মুসলমানদের ধৈর্য ও স্থিরতা পরীক্ষার সময় ছিল।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // তায়েফ গমন
                  _buildBiographyCategory('তায়েফ গমন', Icons.landscape, [
                    _buildEventItem(
                      '৬১৯ খ্রিস্টাব্দ',
                      'তায়েফে দাওয়াত',
                      'হযরত মুহাম্মদ (সা.) মক্কার বাইরের অঞ্চল তায়েফে ইসলামের বার্তা প্রচার করার জন্য যান, '
                          'নতুন সমর্থক খোঁজার উদ্দেশ্যে। ✨ কিন্তু কঠোর প্রত্যাখ্যানের মুখোমুখি হন।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'তায়েফবাসীর প্রতিক্রিয়া',
                      'কঠোর প্রত্যাখ্যান',
                      'স্থানীয় মানুষরা নবীজিকে পাথর মারেন এবং গুরুতর আঘাতের সম্মুখীন হন, '
                          'তবুও হযরত মুহাম্মদ (সা.) ধৈর্য এবং সহনশীলতার দৃষ্টান্ত স্থাপন করেন।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'প্রার্থনা',
                      'আল্লাহর কাছে দোয়া',
                      'হযরত মুহাম্মদ (সা.) তায়েফের জনগণের জন্য আল্লাহর দয়া ও হেদায়েত কামনা করেন। '
                          'এটি ইসলামের ইতিহাসে একটি পরিচিত ও শিক্ষণীয় প্রার্থনা।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // হিজরত
                  _buildBiographyCategory('হিজরত', Icons.travel_explore, [
                    _buildEventItem(
                      '৬২২ খ্রিস্টাব্দ',
                      'মদিনায় হিজরত',
                      'হযরত মুহাম্মদ (সা.) মক্কা থেকে মদিনায় হিজরত করেন। '
                          'এটি ইসলামী ইতিহাসে এক গুরুত্বপূর্ণ ঘটনা এবং ইসলামী ক্যালেন্ডারের সূচনা হিসেবে গণ্য হয়। ✨',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'হিজরতের রাত',
                      'আলী (রা.)-কে সুরক্ষায় রেখে যাত্রা',
                      'হযরত মুহাম্মদ (সা.) আবু বকর (রা.)-এর সাথে সাওর গুহায় আশ্রয় নেন। '
                          'এই রাতটি সাহস, সতর্কতা এবং ঈমানের গুরুত্বপূর্ণ পাঠের উদাহরণ।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'মদিনায় আগমন',
                      'স্নেহময় অভ্যর্থনা',
                      'Ansar (সহায়ক) এবং Muhajireen (হিজরকারী) উভয়ের মধ্যে ভ্রাতৃত্বের বন্ধন প্রতিষ্ঠিত হয়। '
                          'মদিনায় নবীজির আগমন ইসলামী সমাজের নতুন সূচনা চিহ্নিত করে।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // মদিনার জীবন
                  _buildBiographyCategory('মদিনার জীবন', Icons.mosque, [
                    _buildEventItem(
                      'মসজিদ নির্মাণ',
                      'মসজিদে নববী প্রতিষ্ঠা',
                      'হযরত মুহাম্মদ (সা.) মদিনায় মসজিদ নির্মাণ করেন, যা শুধু ইবাদতের স্থান নয়, বরং '
                          'সামাজিক ও শিক্ষামূলক কার্যক্রমের কেন্দ্রবিন্দু হিসেবেও ব্যবহৃত হয়।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'মদিনা সনদ',
                      'মদিনার সংবিধান প্রণয়ন',
                      'হযরত মুহাম্মদ (সা.) বহু ধর্মীয় সম্প্রদায়ের জন্য **মদিনা সনদ** প্রণয়ন করেন, '
                          'যার মাধ্যমে ন্যায়, শান্তি এবং সমাজের সুসংহত ব্যবস্থা নিশ্চিত হয়।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'নতুন সমাজ গঠন',
                      'ইসলামী রাষ্ট্র প্রতিষ্ঠা',
                      'মদিনায় হযরত মুহাম্মদ (সা.) সামাজিক, অর্থনৈতিক এবং রাজনৈতিক কাঠামোর ভিত্তি স্থাপন করেন। '
                          'এর ফলে একটি সুসংহত ও ন্যায়পরায়ণ ইসলামী সমাজ প্রতিষ্ঠিত হয়।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // গুরুত্বপূর্ণ যুদ্ধসমূহ
                  _buildBiographyCategory('গুরুত্বপূর্ণ যুদ্ধসমূহ', Icons.shield, [
                    _buildEventItem(
                      '৬২৪ খ্রিস্টাব্দ',
                      'বদরের যুদ্ধ',
                      'বদরের যুদ্ধ ইসলামের ইতিহাসে প্রথম গুরুত্বপূর্ণ সংঘর্ষ। মুসলিমরা সংখ্যায় কম হলেও সাহস, কৌশল এবং ঈমানের শক্তিতে বিজয় অর্জন করেন।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      '৬২৫ খ্রিস্টাব্দ',
                      'উহুদ যুদ্ধ',
                      'উহুদ যুদ্ধের মাধ্যমে মুসলিমরা সামরিক কৌশল ও প্রতিরক্ষা পরিকল্পনায় গুরুত্বপূর্ণ শিক্ষা গ্রহণ করেন। যুদ্ধ চলাকালীন সাহস এবং একতা প্রদর্শিত হয়।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      '৬২৭ খ্রিস্টাব্দ',
                      'খন্দকের যুদ্ধ',
                      'খন্দক বা গর্ত যুদ্ধের কৌশল ব্যবহার করে মুসলিমরা মক্কার মিত্র বাহিনীর বিরুদ্ধে সফল প্রতিরক্ষা সম্পন্ন করেন। এটি সাহস, একতা এবং কৌশলের চমৎকার উদাহরণ।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // মক্কা বিজয়
                  _buildBiographyCategory('মক্কা বিজয়', Icons.flag, [
                    _buildEventItem(
                      '৬৩০ খ্রিস্টাব্দ',
                      'মক্কা বিজয়',
                      'মক্কা বিজয় ছিল এক শান্তিপূর্ণ বিজয়। মুসলিমরা নগরীকে রক্তক্ষয়ী সংঘর্ষ ছাড়াই দখল করেন এবং সাধারণ জনগণের জন্য দয়া ও ক্ষমার ঘোষণা দেন।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'কাবা পরিশুদ্ধকরণ',
                      'প্রতিমা ধ্বংস',
                      'হযরত মুহাম্মদ (সা.) কাবা থেকে সকল প্রতিমা ও মূর্তি দূর করেন এবং একমাত্র আল্লাহর উপাসনার জন্য কাবা পুনঃপরিশুদ্ধ করেন।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'ক্ষমা প্রদর্শন',
                      'সাধারণ ক্ষমা',
                      'যুদ্ধের পূর্ববর্তী শত্রুদের উপর হযরত মুহাম্মদ (সা.) অসীম দয়া ও ক্ষমা প্রদর্শন করেন, যা ইসলামের ন্যায় ও মানবিকতার চমৎকার উদাহরণ।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // বিদায় হজ্জ
                  _buildBiographyCategory('বিদায় হজ্জ', Icons.celebration, [
                    _buildEventItem(
                      '৬৩২ খ্রিস্টাব্দ',
                      'বিদায় হজ্জ',
                      'হযরত মুহাম্মদ (সা.) কর্তৃক সম্পন্ন প্রথম ও একমাত্র হজ্জ। ইসলামী উম্মাহর জন্য শিক্ষা ও নৈতিকতার চমৎকার দৃষ্টান্ত।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'আরাফার ভাষণ',
                      'ঐতিহাসিক ভাষণ',
                      'মানবাধিকার, সামাজিক ন্যায় এবং সমতার গুরুত্ব বর্ণনা করা হয়। মুসলিম উম্মাহর জন্য নৈতিক ও সামাজিক দিক নির্দেশিত।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'কুরআনের পূর্ণতা',
                      'ওহী সমাপ্তি',
                      '"আল-ইয়াওমা আকমালতু লাকুম দীনাকুম" আয়াত নাযিল হয় এবং ইসলামের ধর্ম পূর্ণতা লাভ করে।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  // ওফাত
                  _buildBiographyCategory('ওফাত', Icons.invert_colors, [
                    _buildEventItem(
                      '৬৩২ খ্রিস্টাব্দ',
                      'শেষ রোগকাল',
                      'হযরত মুহাম্মদ (সা.)-এর শেষ দিনগুলোতে তীব্র জ্বর ও দুর্বলতা দেখা দেয়।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      '৬৩২ খ্রিস্টাব্দ, জুন ৮',
                      'ওফাত',
                      '৬৩ বছর বয়সে ইন্তেকাল, বাগদাদের আয়েশা (রা.)-এর কক্ষে।',
                      isDarkMode,
                    ),
                    _buildEventItem(
                      'সমাধি',
                      'রওজা-এ-মুবারক',
                      'মসজিদে নববীতে সমাহিত, যা আজও দর্শনার্থীদের জন্য পবিত্র স্থান হিসেবে পরিচিত।',
                      isDarkMode,
                    ),
                  ], isDarkMode),

                  const SizedBox(height: 30),

                  // শেষ আয়াত
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        '“আল্লাহ ও তাঁর ফেরেশতাগণ নবীর উপর দরূদ প্রেরণ করেন। '
                        'হে মুমিনগণ! তোমরাও তাঁর উপর দরূদ প্রেরণ কর এবং বিশেষভাবে সালাম পেশ কর।”\n\n'
                        '(সূরা আল-আহযাব: ৫৬)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          // readability বৃদ্ধি করে
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
