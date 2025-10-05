// Doya Page - Fixed Version
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_helper.dart';
import 'network_json_loader.dart';
import 'doya_list_page.dart';

class DoyaCategoryPage extends StatefulWidget {
  const DoyaCategoryPage({Key? key}) : super(key: key);

  @override
  State<DoyaCategoryPage> createState() => _DoyaCategoryPageState();
}

class _DoyaCategoryPageState extends State<DoyaCategoryPage> {
  // Bottom Banner Ad ভেরিয়েবল
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdReady = false;
  double _bannerAdHeight = 0.0;

  // Interstitial Ad ভেরিয়েবল
  bool _interstitialAdShownToday = false;
  bool _showInterstitialAds = true;
  int _doyaCardOpenCount = 0;

  // ক্যাটাগরি তালিকা
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
      'icon': Icons.local_hospital,
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

  Widget _buildCategoryCard(Map<String, dynamic> category) {
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

  Widget _buildSearchResultCard(Map<String, String> doya) {
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
              'ক্যাটাগরি: ${doya['category']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _navigateToSearchedDoya(context, doya),
      ),
    );
  }

  Widget _buildBodyContent() {
    return _isSearching ? _buildSearchResults() : _buildCategoryGrid();
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
            Expanded(child: _buildBodyContent()),

            // Banner Ad - শুধুমাত্র যখন প্রয়োজন
            _buildBottomBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final crossAxisCount = _isTablet ? 4 : 2;

    return GridView.builder(
      padding: EdgeInsets.all(_isTablet ? 20 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _isTablet ? 16 : 12,
        mainAxisSpacing: _isTablet ? 16 : 12,
        childAspectRatio: _isTablet ? 0.8 : 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _buildCategoryCard(categories[index]),
    );
  }

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
