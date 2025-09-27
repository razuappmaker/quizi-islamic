// Doya Category Page - Responsive Version for Mobile & Tablet
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart'; // Clipboard এর জন্য
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_helper.dart';
import 'network_json_loader.dart'; // নতুন নেটওয়ার্ক লোডার
import 'doya_list_page.dart'; // নতুন ফাইল ইম্পোর্ট

class DoyaCategoryPage extends StatefulWidget {
  const DoyaCategoryPage({Key? key}) : super(key: key);

  @override
  State<DoyaCategoryPage> createState() => _DoyaCategoryPageState();
}

class _DoyaCategoryPageState extends State<DoyaCategoryPage> {
  // Bottom Banner Ad ভেরিয়েবল
  BannerAd? _bottomBannerAd; // ✅ Nullable করুন adaptive banner-এর জন্য
  bool _isBottomBannerAdReady = false;
  double _bannerAdHeight = 0.0;

  // Interstitial Ad ভেরিয়েবল
  bool _interstitialAdShownToday = false;
  bool _showInterstitialAds = true;
  int _doyaCardOpenCount = 0;

  // ক্যাটাগরি তালিকা - final হিসেবে ডিক্লেয়ার করুন
  final List<Map<String, dynamic>> categories = [
    {
      'title': 'সালাত-নামাজ',
      'icon': Icons.mosque,
      'color': Colors.blue,
      'jsonFile': 'assets/salat_doyas.json',
    },
    {
      'title': 'কুরআন থেকে',
      'icon': Icons.menu_book,
      'color': Colors.deepPurple,
      'jsonFile': 'assets/quranic_doyas.json',
    },
    {
      'title': 'দাম্পত্য জীবন',
      'icon': Icons.family_restroom,
      'color': Colors.teal,
      'jsonFile': 'assets/copple_doya.json',
    },
    {
      'title': 'সকাল-সন্ধ্যার জিকির',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'jsonFile': 'assets/morning_evening_doya.json',
    },
    {
      'title': 'দৈনন্দিন জীবন',
      'icon': Icons.home,
      'color': Colors.green,
      'jsonFile': 'assets/daily_life_doyas.json',
    },
    {
      'title': 'রোগ মুক্তি',
      'icon': Icons.local_hospital, // আইকন আপডেট
      'color': Colors.red,
      'jsonFile': 'assets/rog_mukti_doyas.json',
    },
    {
      'title': 'সওম-রোজা',
      'icon': Icons.nightlight_round,
      'color': Colors.purple,
      'jsonFile': 'assets/fasting_doyas.json',
    },
    {
      'title': 'বিবিধ',
      'icon': Icons.category,
      'color': Colors.brown,
      'jsonFile': 'assets/misc_doyas.json',
    },
  ];

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

    // AdMob initialize
    AdHelper.initialize();
    _initializeAds(); // Interstitial অ্যাড ইনিশিয়ালাইজ

    // ✅ Adaptive Bottom Banner Ad লোড
    _loadBottomBannerAd();

    // গ্লোবাল সার্চের জন্য সকল দোয়া লোড
    _loadAllDoyas();
  }

  // ✅ Adaptive Bottom Banner Ad লোড করার মেথড
  Future<void> _loadBottomBannerAd() async {
    try {
      // ✅ AdHelper ব্যবহার করে adaptive banner তৈরি করুন
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('Banner ad limit reached, not showing ad');
        return;
      }

      _bottomBannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Adaptive Bottom banner ad loaded successfully');
            setState(() {
              _isBottomBannerAdReady = true;
              _bannerAdHeight = _bottomBannerAd!.size.height.toDouble();
            });
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Adaptive Bottom banner ad failed to load: $error');
            ad.dispose();
            _bottomBannerAd = null;
            setState(() {
              _isBottomBannerAdReady = false;
              _bannerAdHeight = 0.0;
            });
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
          onAdClosed: (ad) => print('Bottom banner ad closed'),
        ),
      );

      await _bottomBannerAd?.load();
    } catch (e) {
      print('Error loading adaptive bottom banner ad: $e');
      _bottomBannerAd?.dispose();
      _bottomBannerAd = null;
      setState(() {
        _isBottomBannerAdReady = false;
        _bannerAdHeight = 0.0;
      });
    }
  }

  // অ্যাড সিস্টেম ইনিশিয়ালাইজেশন
  Future<void> _initializeAds() async {
    try {
      // সেটিংস লোড করুন
      final prefs = await SharedPreferences.getInstance();

      // interstitial অ্যাড সেটিংস লোড করুন (ডিফল্ট true)
      _showInterstitialAds = prefs.getBool('show_interstitial_ads') ?? true;

      // আজকে interstitial অ্যাড দেখানো হয়েছে কিনা চেক করুন
      final lastShownDate = prefs.getString('last_interstitial_date_doya');
      final today = DateTime.now().toIso8601String().split('T')[0];

      setState(() {
        _interstitialAdShownToday = (lastShownDate == today);
      });

      print(
        'দোয়া পেজ - অ্যাড সিস্টেম ইনিশিয়ালাইজড: interstitial অ্যাড = $_showInterstitialAds, আজকে দেখানো হয়েছে = $_interstitialAdShownToday',
      );
    } catch (e) {
      print('দোয়া পেজ - অ্যাড ইনিশিয়ালাইজেশনে ত্রুটি: $e');
    }
  }

  // Interstitial অ্যাড শো করুন যদি প্রয়োজন হয়
  Future<void> _showInterstitialAdIfNeeded() async {
    try {
      // interstitial অ্যাড বন্ধ থাকলে স্কিপ করুন
      if (!_showInterstitialAds) {
        print('দোয়া পেজ - Interstitial অ্যাড ইউজার বন্ধ রেখেছেন');
        return;
      }

      // যদি আজকে ইতিমধ্যে interstitial অ্যাড দেখানো হয়ে থাকে তবে স্কিপ করুন
      if (_interstitialAdShownToday) {
        print('দোয়া পেজ - ইতিমধ্যে আজ interstitial অ্যাড দেখানো হয়েছে');
        return;
      }

      // দোয়া কার্ড ওপেন কাউন্টার চেক (৬টি দোয়া পড়লে)
      if (_doyaCardOpenCount < 6) {
        print('দোয়া পেজ - দোয়া কার্ড ওপেন কাউন্ট: $_doyaCardOpenCount/6');
        return;
      }

      print('দোয়া পেজ - Interstitial অ্যাড শো করার চেষ্টা করা হচ্ছে...');

      // AdHelper এর মাধ্যমে interstitial অ্যাড শো করুন
      await AdHelper.showInterstitialAd(
        onAdShowed: () {
          print('দোয়া পেজ - Interstitial অ্যাড শো করা হলো');
          _recordInterstitialShown();
          _resetDoyaCardCount(); // কাউন্টার রিসেট
        },
        onAdDismissed: () {
          print('দোয়া পেজ - Interstitial অ্যাড ডিসমিস করা হলো');
        },
        onAdFailedToShow: () {
          print('দোয়া পেজ - Interstitial অ্যাড শো করতে ব্যর্থ');
        },
        adContext: 'DoyaPage',
      );
    } catch (e) {
      print('দোয়া পেজ - Interstitial অ্যাড শো করতে ত্রুটি: $e');
    }
  }

  // Interstitial অ্যাড দেখানো রেকর্ড করুন
  void _recordInterstitialShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      await prefs.setString('last_interstitial_date_doya', today);

      setState(() {
        _interstitialAdShownToday = true;
      });

      print(
        'দোয়া পেজ - আজকের interstitial অ্যাড দেখানো রেকর্ড করা হলো: $today',
      );
    } catch (e) {
      print('দোয়া পেজ - Interstitial অ্যাড রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // দোয়া কার্ড কাউন্টার রিসেট করুন
  void _resetDoyaCardCount() {
    setState(() {
      _doyaCardOpenCount = 0;
    });
  }

  // দোয়া কার্ড ওপেন কাউন্টার ইনক্রিমেন্ট করুন
  void _incrementDoyaCardCount() {
    setState(() {
      _doyaCardOpenCount++;
    });

    print('দোয়া পেজ - দোয়া কার্ড ওপেন কাউন্ট: $_doyaCardOpenCount/6');

    // ৬টি দোয়া পড়লে interstitial অ্যাড শো করুন
    if (_doyaCardOpenCount >= 6) {
      _showInterstitialAdIfNeeded();
    }
  }

  // ডিভাইসের ধরন চেক করার মেথড
  void _checkDeviceType(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;

    // ট্যাবলেটের থ্রেশহোল্ড: 600dp
    setState(() {
      _isTablet = shortestSide >= 600;
    });
  }

  // সকল দোয়া লোড করার মেথড
  Future<void> _loadAllDoyas() async {
    setState(() => _isLoadingAllDoyas = true);

    try {
      List<Map<String, String>> allDoyas = [];

      for (var category in categories) {
        try {
          // NetworkJsonLoader ব্যবহার করুন (নেটওয়ার্ক থেকে প্রথমে, তারপর লোকাল)
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

          // প্রতিটি দোয়ায় ক্যাটাগরি তথ্য যোগ করুন
          for (var doya in convertedData) {
            doya['category'] = category['title'];
            doya['categoryColor'] = category['color'].toString();
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
    _bottomBannerAd?.dispose(); // ✅ Null safety সহ dispose
    _searchController.dispose();
    super.dispose();
  }

  // সার্চ শুরু করার মেথড
  void _startSearch() => setState(() => _isSearching = true);

  // সার্চ বন্ধ করার মেথড
  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
    });
  }

  // সকল দোয়ায় সার্চ করার মেথড
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

  // ক্যাটাগরি পেইজে নেভিগেট করার মেথড
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
          onDoyaCardOpen:
              _incrementDoyaCardCount, // কাউন্টার ইনক্রিমেন্ট কলব্যাক
        ),
      ),
    );
  }

  // সার্চ করা দোয়ায় নেভিগেট করার মেথড
  void _navigateToSearchedDoya(BuildContext context, Map<String, String> doya) {
    // এই দোয়ার ক্যাটাগরি খুঁজুন
    final category = categories.firstWhere(
      (cat) => cat['title'] == doya['category'],
      orElse: () => categories.last,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoyaListPage(
          categoryTitle: category['title'],
          jsonFile: category['jsonFile'],
          categoryColor: category['color'],
          initialSearchQuery: doya['title'],
          onDoyaCardOpen:
              _incrementDoyaCardCount, // কাউন্টার ইনক্রিমেন্ট কলব্যাক
        ),
      ),
    );
  }

  // ক্যাটাগরি কার্ড বিল্ড করার মেথড - রেসপনসিভ
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(_isTablet ? 12 : 8), // ট্যাবলেটে বেশি margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToCategoryDoyas(context, category),
        child: Container(
          height: _isTablet ? 140 : 120, // ট্যাবলেটে উচ্চতা বেশি
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
                size: _isTablet ? 40 : 32, // ট্যাবলেটে বড় আইকন
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                category['title'],
                style: TextStyle(
                  fontSize: _isTablet ? 18 : 16, // ট্যাবলেটে বড় ফন্ট
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

  // সার্চ রেজাল্ট কার্ড বিল্ড করার মেথড
  Widget _buildSearchResultCard(Map<String, String> doya) {
    Color categoryColor = Colors.teal; // ডিফল্ট কালার
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
              'ক্যাটাগরি: ${doya['category']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _navigateToSearchedDoya(context, doya),
      ),
    );
  }

  // বডি কন্টেন্ট বিল্ড করার মেথড
  Widget _buildBodyContent() {
    return _isSearching ? _buildSearchResults() : _buildCategoryGrid();
  }

  // ✅ Adaptive বটম ব্যানার অ্যাড বিল্ড করার মেথড
  Widget _buildBottomBannerAd() {
    if (!_isBottomBannerAdReady || _bottomBannerAd == null) {
      return SizedBox(
        height: _bannerAdHeight,
      ); // Empty space when ad not loaded
    }

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        height: _bottomBannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        child: AdWidget(ad: _bottomBannerAd!),
      ),
    );
  }

  // সিস্টেম ন্যাভিগেশন বার এর height নির্ণয় করার মেথড
  double _getSystemNavigationBarHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.bottom;
  }

  @override
  Widget build(BuildContext context) {
    // বিল্ড করার সময় ডিভাইস টাইপ চেক করুন
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceType(context);
    });

    final systemNavigationBarHeight = _getSystemNavigationBarHeight(context);
    final totalBottomPadding = _bannerAdHeight + systemNavigationBarHeight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'সকল দোয়া খুঁজুন...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
                onChanged: _searchAllDoyas,
              )
            : const Text(
                'দুআর সংকলন (অর্থসহ)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
        centerTitle: false,
        elevation: 0,
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
        bottom: false, // নিচের SafeArea বন্ধ রাখুন
        child: Stack(
          children: [
            // Main content with bottom padding
            Padding(
              padding: EdgeInsets.only(bottom: totalBottomPadding),
              child: _buildBodyContent(),
            ),

            // ✅ Adaptive Bottom banner ad positioned at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: systemNavigationBarHeight,
              // System navigation bar এর উপরে
              child: _buildBottomBannerAd(),
            ),
          ],
        ),
      ),
    );
  }

  // ক্যাটাগরি গ্রিড বিল্ড করার মেথড - রেসপনসিভ
  Widget _buildCategoryGrid() {
    // ডিভাইস অনুযায়ী কলাম সংখ্যা নির্ধারণ
    final crossAxisCount = _isTablet
        ? 4
        : 2; // ট্যাবলেটে ৪ কলাম, মোবাইলে ২ কলাম

    return GridView.builder(
      padding: EdgeInsets.all(_isTablet ? 20 : 16), // ট্যাবলেটে বেশি padding
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _isTablet ? 16 : 12, // ট্যাবলেটে বেশি spacing
        mainAxisSpacing: _isTablet ? 16 : 12,
        childAspectRatio: _isTablet
            ? 0.8
            : 0.9, // ট্যাবলেটে aspect ratio adjustment
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _buildCategoryCard(categories[index]),
    );
  }

  // সার্চ রেজাল্ট বিল্ড করার মেথড
  Widget _buildSearchResults() {
    if (_isLoadingAllDoyas) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text(
          'দোয়া খুঁজতে টাইপ করুন...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
              '"${_searchController.text}" এর জন্য কোন ফলাফল নেই',
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
          _buildSearchResultCard(_searchResults[index]),
    );
  }
}
