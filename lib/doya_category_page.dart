// Doya Page - Multi-language Support সহ
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'ad_helper.dart';
import 'network_json_loader.dart';
import 'doya_list_page.dart';
import '../providers/language_provider.dart';

class DoyaCategoryPage extends StatefulWidget {
  const DoyaCategoryPage({Key? key}) : super(key: key);

  @override
  State<DoyaCategoryPage> createState() => _DoyaCategoryPageState();
}

class _DoyaCategoryPageState extends State<DoyaCategoryPage> {
  // ==================== ভাষা টেক্সট ডিক্লেয়ারেশন ====================
  static const Map<String, Map<String, String>> _texts = {
    'pageTitle': {
      'en': 'Dua Collection (With Meaning)',
      'bn': 'দুআর সংকলন (অর্থসহ)',
    },
    'searchHint': {'en': 'Search all duas...', 'bn': 'সকল দোয়া খুঁজুন...'},
    'searching': {
      'en': 'Type to search duas...',
      'bn': 'দোয়া খুঁজতে টাইপ করুন...',
    },
    'noResults': {'en': 'No results found for', 'bn': 'এর জন্য কোন ফলাফল নেই'},
    'category': {'en': 'Category', 'bn': 'ক্যাটাগরি'},
    'salat': {'en': 'Salah-Prayer', 'bn': 'সালাত-নামাজ'},
    'quranic': {'en': 'From Quran', 'bn': 'কুরআন থেকে'},
    'marriage': {'en': 'Marriage Life', 'bn': 'দাম্পত্য জীবন'},
    'morningEvening': {
      'en': 'Morning-Evening Zikr',
      'bn': 'সকাল-সন্ধ্যার জিকির',
    },
    'dailyLife': {'en': 'Daily Life', 'bn': 'দৈনন্দিন জীবন'},
    'healing': {'en': 'Healing', 'bn': 'রোগ মুক্তি'},
    'fasting': {'en': 'Fasting', 'bn': 'সওম-রোজা'},
    'miscellaneous': {'en': 'Miscellaneous', 'bn': 'বিবিধ'},
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

  // Bottom Banner Ad ভেরিয়েবল
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdReady = false;
  double _bannerAdHeight = 0.0;

  // Interstitial Ad ভেরিয়েবল
  bool _interstitialAdShownToday = false;
  bool _showInterstitialAds = true;
  int _doyaCardOpenCount = 0;

  // ক্যাটাগরি তালিকা - ভাষা অনুযায়ী ডাইনামিক
  List<Map<String, dynamic>> getCategories(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isEnglish = languageProvider.isEnglish;

    return [
      {
        'title': _text('salat', context),
        'icon': Icons.mosque,
        'color': Colors.blue,
        'jsonFile': isEnglish
            ? 'assets/en_salat_doyas.json'
            : 'assets/salat_doyas.json',
      },
      {
        'title': _text('quranic', context),
        'icon': Icons.menu_book,
        'color': Colors.deepPurple,
        'jsonFile': isEnglish
            ? 'assets/en_quranic_doyas.json'
            : 'assets/quranic_doyas.json',
      },
      {
        'title': _text('marriage', context),
        'icon': Icons.family_restroom,
        'color': Colors.teal,
        'jsonFile': isEnglish
            ? 'assets/en_copple_doya.json'
            : 'assets/copple_doya.json',
      },
      {
        'title': _text('morningEvening', context),
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
        'jsonFile': isEnglish
            ? 'assets/en_morning_evening_doya.json'
            : 'assets/morning_evening_doya.json',
      },
      {
        'title': _text('dailyLife', context),
        'icon': Icons.home,
        'color': Colors.green,
        'jsonFile': isEnglish
            ? 'assets/en_daily_life_doyas.json'
            : 'assets/daily_life_doyas.json',
      },
      {
        'title': _text('healing', context),
        'icon': Icons.local_hospital,
        'color': Colors.red,
        'jsonFile': isEnglish
            ? 'assets/en_rog_mukti_doyas.json'
            : 'assets/rog_mukti_doyas.json',
      },
      {
        'title': _text('fasting', context),
        'icon': Icons.nightlight_round,
        'color': Colors.purple,
        'jsonFile': isEnglish
            ? 'assets/en_fasting_doyas.json'
            : 'assets/fasting_doyas.json',
      },
      {
        'title': _text('miscellaneous', context),
        'icon': Icons.category,
        'color': Colors.brown,
        'jsonFile': isEnglish
            ? 'assets/en_misc_doyas.json'
            : 'assets/misc_doyas.json',
      },
    ];
  }

  // গ্লোবাল সার্চ ভেরিয়েবল
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allDoyas = [];
  List<Map<String, String>> _searchResults = [];
  bool _isLoadingAllDoyas = false;

  // রেসপনসিভ লেআউট ভেরিয়েবল
  bool _isTablet = false;

  @override
  void initState() {
    super.initState();
    AdHelper.initialize();
    _initializeAds();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBottomBannerAd();
    });
    _loadAllDoyas();
  }

  Future<void> _loadBottomBannerAd() async {
    try {
      bool canShowAd = await AdHelper.canShowBannerAd();
      if (!canShowAd) {
        print('Banner ad limit reached, not showing ad');
        setState(() {
          _bannerAdHeight = 0.0;
          _isBottomBannerAdReady = false;
        });
        return;
      }

      final bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        width: MediaQuery.of(context).size.width.toInt(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('✅ Adaptive Bottom banner ad loaded successfully');
            setState(() {
              _bottomBannerAd = ad as BannerAd?;
              _isBottomBannerAdReady = true;
              _bannerAdHeight = _bottomBannerAd!.size.height.toDouble();
            });
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('❌ Adaptive Bottom banner ad failed to load: $error');
            ad.dispose();
            setState(() {
              _bottomBannerAd = null;
              _isBottomBannerAdReady = false;
              _bannerAdHeight = 0.0;
            });
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('🔵 Adaptive Bottom Banner ad clicked.');
              } else {
                print('🔴 Ad click limit reached');
              }
            });
          },
          onAdClosed: (ad) => print('🔵 Bottom banner ad closed'),
        ),
      );

      bannerAd.load();
    } catch (e) {
      print('❌ Error loading adaptive bottom banner ad: $e');
      _bottomBannerAd?.dispose();
      _bottomBannerAd = null;
      setState(() {
        _isBottomBannerAdReady = false;
        _bannerAdHeight = 0.0;
      });
    }
  }

  Future<void> _initializeAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _showInterstitialAds = prefs.getBool('show_interstitial_ads') ?? true;

      final lastShownDate = prefs.getString('last_interstitial_date_doya');
      final today = DateTime.now().toIso8601String().split('T')[0];

      setState(() {
        _interstitialAdShownToday = (lastShownDate == today);
      });
    } catch (e) {
      print('দোয়া পেজ - অ্যাড ইনিশিয়ালাইজেশনে ত্রুটি: $e');
    }
  }

  Future<void> _showInterstitialAdIfNeeded() async {
    try {
      if (!_showInterstitialAds ||
          _interstitialAdShownToday ||
          _doyaCardOpenCount < 6) {
        return;
      }

      await AdHelper.showInterstitialAd(
        onAdShowed: () {
          _recordInterstitialShown();
          _resetDoyaCardCount();
        },
        onAdDismissed: () {},
        onAdFailedToShow: () {},
        adContext: 'DoyaPage',
      );
    } catch (e) {
      print('দোয়া পেজ - Interstitial অ্যাড শো করতে ত্রুটি: $e');
    }
  }

  void _recordInterstitialShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('last_interstitial_date_doya', today);
      setState(() {
        _interstitialAdShownToday = true;
      });
    } catch (e) {
      print('দোয়া পেজ - Interstitial অ্যাড রেকর্ড করতে ত্রুটি: $e');
    }
  }

  void _resetDoyaCardCount() {
    setState(() {
      _doyaCardOpenCount = 0;
    });
  }

  void _incrementDoyaCardCount() {
    setState(() {
      _doyaCardOpenCount++;
    });
    if (_doyaCardOpenCount >= 6) {
      _showInterstitialAdIfNeeded();
    }
  }

  void _checkDeviceType(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    setState(() {
      _isTablet = shortestSide >= 600;
    });
  }

  Future<void> _loadAllDoyas() async {
    setState(() => _isLoadingAllDoyas = true);
    try {
      List<Map<String, String>> allDoyas = [];
      final categories = getCategories(context);

      for (var category in categories) {
        try {
          final loadedData = await NetworkJsonLoader.loadJsonList(
            category['jsonFile'],
          );
          final convertedData = loadedData.map<Map<String, String>>((item) {
            final Map<String, dynamic> dynamicItem = Map<String, dynamic>.from(
              item,
            );
            return dynamicItem.map(
              (key, value) => MapEntry(key, value.toString()),
            );
          }).toList();

          for (var doya in convertedData) {
            doya['category'] = category['title'];
            doya['categoryColor'] = category['color'].toString();
            doya['jsonFile'] = category['jsonFile']; // JSON file যোগ করা
          }
          allDoyas.addAll(convertedData);
        } catch (e) {
          print('Error loading ${category['jsonFile']}: $e');
        }
      }
      setState(() {
        _allDoyas = allDoyas;
        _isLoadingAllDoyas = false;
      });
    } catch (e) {
      print('Error loading all doyas: $e');
      setState(() => _isLoadingAllDoyas = false);
    }
  }

  @override
  void dispose() {
    _bottomBannerAd?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
    });
  }

  void _searchAllDoyas(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }

    final results = _allDoyas.where((doya) {
      final titleLower = doya['title']?.toLowerCase() ?? '';
      final banglaLower = doya['bangla']?.toLowerCase() ?? '';
      final arabicLower = doya['arabic']?.toLowerCase() ?? '';
      final categoryLower = doya['category']?.toLowerCase() ?? '';

      return titleLower.contains(query.toLowerCase()) ||
          banglaLower.contains(query.toLowerCase()) ||
          arabicLower.contains(query.toLowerCase()) ||
          categoryLower.contains(query.toLowerCase());
    }).toList();

    setState(() => _searchResults = results);
  }

  void _navigateToCategoryDoyas(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoyaListPage(
          categoryTitle: category['title'],
          jsonFile: category['jsonFile'],
          categoryColor: category['color'],
          onDoyaCardOpen: _incrementDoyaCardCount,
        ),
      ),
    );
  }

  // আপডেট করা মেথড: সরাসরি দোয়া ওপেন করবে
  void _navigateToSearchedDoya(BuildContext context, Map<String, String> doya) {
    final categories = getCategories(context);
    final category = categories.firstWhere(
      (cat) => cat['title'] == doya['category'],
      orElse: () => categories.last,
    );

    // দোয়া কার্ড ওপেন হলে parent কে নোটিফাই করুন
    _incrementDoyaCardCount();

    // সরাসরি DoyaDetailPage-এ নিয়ে যান (আপনার যদি থাকে) অথবা
    // DoyaListPage-এ নিয়ে গিয়ে সরাসরি সেই দোয়াটি হাইলাইট/এক্সপ্যান্ড করুন
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoyaListPage(
          categoryTitle: category['title'],
          jsonFile: category['jsonFile'],
          categoryColor: category['color'],
          initialSearchQuery: doya['title'],
          // সার্চ কোয়েরি পাঠানো
          preSelectedDoyaTitle: doya['title'],
          // নতুন প্যারামিটার - সরাসরি দোয়া সিলেক্ট করার জন্য
          onDoyaCardOpen: _incrementDoyaCardCount,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    BuildContext context,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(_isTablet ? 12 : 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToCategoryDoyas(context, category),
        child: Container(
          height: _isTablet ? 140 : 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category['color'].withOpacity(0.8),
                category['color'].withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category['icon'],
                size: _isTablet ? 40 : 32,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                category['title'],
                style: TextStyle(
                  fontSize: _isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(
    Map<String, String> doya,
    BuildContext context,
  ) {
    Color categoryColor = Colors.teal;
    try {
      categoryColor = Color(int.parse(doya['categoryColor'] ?? '0xFF009688'));
    } catch (e) {
      categoryColor = Colors.teal;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(Icons.search, color: categoryColor),
        title: Text(
          doya['title'] ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, color: categoryColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doya['bangla'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_text('category', context)}: ${doya['category']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _navigateToSearchedDoya(context, doya),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context) {
    return _isSearching
        ? _buildSearchResults(context)
        : _buildCategoryGrid(context);
  }

  Widget _buildBottomBannerAd() {
    if (!_isBottomBannerAdReady ||
        _bannerAdHeight <= 0 ||
        _bottomBannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: _bannerAdHeight,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceType(context);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: _text('searchHint', context),
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
                onChanged: _searchAllDoyas,
              )
            : Text(
                _text('pageTitle', context),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
        centerTitle: false,
        elevation: 0,
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
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _stopSearch,
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _startSearch,
                ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main Content - সম্পূর্ণ জায়গা নেয়
            Expanded(child: _buildBodyContent(context)),

            // Banner Ad - শুধুমাত্র যখন প্রয়োজন
            _buildBottomBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final crossAxisCount = _isTablet ? 4 : 2;
    final categories = getCategories(context);

    return GridView.builder(
      padding: EdgeInsets.all(_isTablet ? 20 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _isTablet ? 16 : 12,
        mainAxisSpacing: _isTablet ? 16 : 12,
        childAspectRatio: _isTablet ? 0.8 : 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) =>
          _buildCategoryCard(categories[index], context),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_isLoadingAllDoyas) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Text(
          _text('searching', context),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '${_text('noResults', context)} "${_searchController.text}"',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) =>
          _buildSearchResultCard(_searchResults[index], context),
    );
  }
}
