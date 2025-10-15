import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'ad_helper.dart';
import '../providers/language_provider.dart';

class AllahName {
  final String arabic;
  final String bangla;
  final String english;
  final String meaningBn;
  final String meaningEn;
  final String fazilatBn;
  final String fazilatEn;

  AllahName({
    required this.arabic,
    required this.bangla,
    required this.english,
    required this.meaningBn,
    required this.meaningEn,
    required this.fazilatBn,
    required this.fazilatEn,
  });
}

class NameOfAllahPage extends StatefulWidget {
  const NameOfAllahPage({super.key});

  @override
  State<NameOfAllahPage> createState() => _NameOfAllahPageState();
}

class _NameOfAllahPageState extends State<NameOfAllahPage> {
  List<AllahName> allahNames = [];
  List<AllahName> filteredNames = [];
  final List<BannerAd?> _bannerAds = [];
  BannerAd? _bottomBanner;
  TextEditingController searchController = TextEditingController();
  bool _isBottomBannerAdReady = false;

  double _arabicFontSize = 28.0;
  double _textFontSize = 16.0;
  final double _minFontSize = 14.0;
  final double _maxFontSize = 36.0;
  final double _fontSizeStep = 2.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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
      _loadAllahNames();
    }
  }

  Future<void> _loadInitialData() async {
    await _loadAllahNames();
    _loadAds();
  }

  Future<void> _loadAllahNames() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final isEnglish = languageProvider.isEnglish;

      final jsonFile = isEnglish
          ? 'assets/en_name_of_allah.json'
          : 'assets/name_of_allah.json';

      final String response = await DefaultAssetBundle.of(
        context,
      ).loadString(jsonFile);
      final List<dynamic> data = json.decode(response);

      if (mounted) {
        setState(() {
          allahNames = data
              .map(
                (item) => AllahName(
                  arabic: item['arabic'] ?? '',
                  bangla: item['bangla'] ?? '',
                  english: item['english'] ?? '',
                  meaningBn: item['meaningBn'] ?? '',
                  meaningEn: item['meaningEn'] ?? '',
                  fazilatBn: item['fazilatBn'] ?? '',
                  fazilatEn: item['fazilatEn'] ?? '',
                ),
              )
              .toList();

          filteredNames = List.from(allahNames);
        });
      }
    } catch (e) {
      print('Error loading Allah names: $e');
      _setDefaultData();
    }
  }

  void _setDefaultData() {
    setState(() {
      allahNames = [
        AllahName(
          arabic: "ٱللَّهُ",
          bangla: "আল্লাহ",
          english: "Allah",
          meaningBn: "সর্বশক্তিমান, স্রষ্টা",
          meaningEn: "The God",
          fazilatBn:
              "প্রতিদিন ৫ ওয়াক্ত ফরজ নামাজের পর 'আল্লাহ' নামটি ১০০ বার পাঠ করলে, ইনশাআল্লাহ, আল্লাহর নৈকট্য লাভ হবে, মন শান্ত হবে, পাপ মাফ হবে এবং জীবন বরকতময় হবে।",
          fazilatEn:
              "Reciting 'Allah' 100 times after the 5 daily obligatory prayers will bring you closer to Allah, peace of mind, forgiveness of sins, and a blessed life.",
        ),
      ];
      filteredNames = List.from(allahNames);
    });
  }

  void _loadAds() async {
    await AdHelper.initialize();

    int adCount = (allahNames.length / 6).ceil();
    for (int i = 0; i < adCount; i++) {
      try {
        final banner = await AdHelper.createAdaptiveBannerAdWithFallback(
          context,
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              print('In-list adaptive banner ad loaded successfully');
              if (mounted) setState(() {});
            },
            onAdFailedToLoad: (ad, error) {
              print('In-list adaptive banner ad failed to load: $error');
              ad.dispose();
              _bannerAds[i] = null;
            },
          ),
        );
        // ✅ AdHelper এর ভিতরে ইতিমধ্যে load() কল করা হয়েছে, তাই এখানে আলাদা করে load() কল করার দরকার নেই
        _bannerAds.add(banner);
      } catch (e) {
        print('Error creating in-list adaptive banner: $e');
        _bannerAds.add(null);
      }
    }

    try {
      _bottomBanner = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('Bottom adaptive banner ad loaded successfully');
            if (mounted) {
              setState(() {
                _isBottomBannerAdReady = true;
              });
            }
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (ad, error) {
            print('Bottom adaptive banner ad failed to load: $error');
            ad.dispose();
            _isBottomBannerAdReady = false;
          },
          onAdClicked: (ad) {
            AdHelper.recordAdClick();
          },
        ),
      );
      // ✅ AdHelper এর ভিতরে ইতিমধ্যে load() কল করা হয়েছে, তাই এখানে আলাদা করে load() কল করার দরকার নেই
    } catch (e) {
      print('Error creating bottom adaptive banner: $e');
      _isBottomBannerAdReady = false;
    }
  }

  // Info Dialog Show Function
  void _showInfoDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isEnglish = languageProvider.isEnglish;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green[800]),
              SizedBox(width: 8),
              Text(
                isEnglish ? "Important Note" : "গুরুত্বপূর্ণ নোট",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              isEnglish
                  ? "References from Quranic verses or authentic Hadiths have been mentioned for the virtues (Fazilat) of each name.\n\nSome virtues are related to specific numbers of Dhikr, which are mentioned in various Hadith books and Islamic literature. These are essentially devotional practices.\n\nBefore performing any devotional act, intention (Niyyah) should be pure and it should be done solely for the pleasure of Allah."
                  : "প্রতিটি নামের ফাজিলাতের জন্য কুরআনের আয়াত বা সহীহ হাদিসের রেফারেন্স উল্লেখ করা হয়েছে।\n\nকিছু ফাজিলাত নির্দিষ্ট সংখ্যক জিকিরের সাথে সম্পর্কিত, যা বিভিন্ন হাদিসের বই ও ইসলামিক গ্রন্থে বর্ণিত আছে। এগুলো মূলত প্রার্থনামূলক আমল।\n\nযে কোনো আমল করার আগে নিয়্যাত খালেস করতে হবে এবং শুধুমাত্র আল্লাহর সন্তুষ্টির জন্য করতে হবে।",
              style: TextStyle(fontSize: 16, height: 1.5),
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
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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

    for (var ad in _bannerAds) {
      ad?.dispose();
    }
    _bottomBanner?.dispose();
    searchController.dispose();
    super.dispose();
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
    final primaryColor = Colors.green[800];
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    //int totalItems = filteredNames.length + (filteredNames.length / 6).floor();
    // totalItems ক্যালকুলেশন ঠিক করুন
    int totalItems = filteredNames.length + ((filteredNames.length - 1) ~/ 6);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEnglish ? "99 Names of Allah" : "আল্লাহর ৯৯ নাম",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16, // ফন্ট সাইজ ছোট করা হয়েছে
            color: Colors.white,
            height: 1.2, // লাইন হাইট কম করা হয়েছে
          ),
          maxLines: 2, // সর্বোচ্চ ২ লাইন
          overflow: TextOverflow.ellipsis, // ২ লাইনের বেশি হলে ... দেখাবে
          textAlign: TextAlign.start, // টেক্সট অ্যালাইনমেন্ট
        ),
        backgroundColor: primaryColor,
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
          // Info Icon Button
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AllahNameSearchDelegate(filteredNames, isEnglish),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'increase',
                child: ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: Text(isEnglish ? 'Increase Font' : 'ফন্ট বড় করুন'),
                  onTap: _increaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'decrease',
                child: ListTile(
                  leading: const Icon(Icons.zoom_out),
                  title: Text(isEnglish ? 'Decrease Font' : 'ফন্ট ছোট করুন'),
                  onTap: _decreaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: Text(
                    isEnglish ? 'Default Font Size' : 'ডিফল্ট ফন্ট সাইজ',
                  ),
                  onTap: _resetFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: totalItems,
                itemBuilder: (context, index) {
                  // এড পজিশন ক্যালকুলেশন
                  int totalAdsBefore = (index + 1) ~/ 7;
                  bool isAdPosition = (index + 1) % 7 == 0;

                  if (isAdPosition && totalAdsBefore <= _bannerAds.length) {
                    int adIndex = totalAdsBefore - 1;
                    if (adIndex >= 0 &&
                        adIndex < _bannerAds.length &&
                        _bannerAds[adIndex] != null) {
                      final banner = _bannerAds[adIndex]!;
                      return Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildAdaptiveBannerWidget(banner),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  // ✅ সঠিক নাম ইন্ডেক্স ক্যালকুলেশন
                  // নাম ইন্ডেক্স ক্যালকুলেশন
                  int nameIndex = index - totalAdsBefore;
                  if (nameIndex >= filteredNames.length) {
                    return const SizedBox.shrink();
                  }

                  final name = filteredNames[nameIndex];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor!.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  "${nameIndex + 1}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEnglish ? name.english : name.bangla,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      isEnglish ? name.bangla : name.english,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[900]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                name.arabic,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _arabicFontSize,
                                  fontFamily: 'ScheherazadeNew',
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  height: 1.8,
                                  wordSpacing: 2.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.green[900]!.withOpacity(0.2)
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: isEnglish
                                            ? "Meaning: "
                                            : "অর্থ: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: _textFontSize,
                                          color: isDarkMode
                                              ? Colors.green[200]
                                              : Colors.green[800],
                                        ),
                                      ),
                                      TextSpan(
                                        text: isEnglish
                                            ? name.meaningEn
                                            : name.meaningBn,
                                        style: TextStyle(
                                          fontSize: _textFontSize,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: isEnglish
                                            ? "Meaning (Bengali): "
                                            : "Meaning: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: _textFontSize,
                                          color: isDarkMode
                                              ? Colors.green[200]
                                              : Colors.green[800],
                                        ),
                                      ),
                                      TextSpan(
                                        text: isEnglish
                                            ? name.meaningBn
                                            : name.meaningEn,
                                        style: TextStyle(
                                          fontSize: _textFontSize,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.orange[900]!.withOpacity(0.15)
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.orange[700]!
                                    : Colors.orange[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEnglish ? "Virtue:" : "ফজিলত:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _textFontSize,
                                    color: isDarkMode
                                        ? Colors.orange[200]
                                        : Colors.orange[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isEnglish ? name.fazilatEn : name.fazilatBn,
                                  style: TextStyle(
                                    fontSize: _textFontSize,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isBottomBannerAdReady && _bottomBanner != null)
              Container(
                width: screenWidth,
                height: _bottomBanner!.size.height.toDouble(),
                alignment: Alignment.center,
                color: Colors.transparent,
                margin: EdgeInsets.only(top: 8),
                child: _buildAdaptiveBannerWidget(_bottomBanner!),
              ),
          ],
        ),
      ),
    );
  }
}

class AllahNameSearchDelegate extends SearchDelegate {
  final List<AllahName> allNames;
  final bool isEnglish;

  AllahNameSearchDelegate(this.allNames, this.isEnglish);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = allNames.where((name) {
      return name.arabic.contains(query) ||
          name.bangla.contains(query) ||
          name.english.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allNames.where((name) {
      return name.arabic.contains(query) ||
          name.bangla.contains(query) ||
          name.english.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchList(suggestions);
  }

  Widget _buildSearchList(List<AllahName> names) {
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (context, index) {
        final name = names[index];
        return ListTile(
          title: Text(isEnglish ? name.english : name.bangla),
          subtitle: Text(isEnglish ? name.meaningEn : name.meaningBn),
          trailing: Text(
            name.arabic,
            style: TextStyle(fontFamily: 'ScheherazadeNew', fontSize: 18),
          ),
          onTap: () {
            query = isEnglish ? name.english : name.bangla;
            showResults(context);
          },
        );
      },
    );
  }
}
