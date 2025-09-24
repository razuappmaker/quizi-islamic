// Doya Page - Responsive Version for Mobile & Tablet
// দোয়া পেইজ - মোবাইল ও ট্যাবলেটের জন্য রেসপনসিভ ভার্সন
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart'; // Clipboard এর জন্য
import 'ad_helper.dart';
import 'network_json_loader.dart'; // নতুন নেটওয়ার্ক লোডার

class DoyaCategoryPage extends StatefulWidget {
  const DoyaCategoryPage({Key? key}) : super(key: key);

  @override
  State<DoyaCategoryPage> createState() => _DoyaCategoryPageState();
}

class _DoyaCategoryPageState extends State<DoyaCategoryPage> {
  // Bottom Banner Ad ভেরিয়েবল
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

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

    // Bottom Banner Ad লোড
    _bottomBannerAd = AdHelper.createBannerAd(
      AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();

    // গ্লোবাল সার্চের জন্য সকল দোয়া লোড
    _loadAllDoyas();
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
    _bottomBannerAd.dispose();
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

  @override
  Widget build(BuildContext context) {
    // বিল্ড করার সময় ডিভাইস টাইপ চেক করুন
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
                'দুআ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
      body: _isSearching ? _buildSearchResults() : _buildCategoryGrid(),
      bottomNavigationBar: _isBottomBannerAdReady
          ? SafeArea(
              child: Container(
                width: double.infinity,
                height: _bottomBannerAd.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bottomBannerAd),
              ),
            )
          : null,
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

class DoyaListPage extends StatefulWidget {
  final String categoryTitle;
  final String jsonFile;
  final Color categoryColor;
  final String? initialSearchQuery;

  const DoyaListPage({
    Key? key,
    required this.categoryTitle,
    required this.jsonFile,
    required this.categoryColor,
    this.initialSearchQuery,
  }) : super(key: key);

  @override
  State<DoyaListPage> createState() => _DoyaListPageState();
}

class _DoyaListPageState extends State<DoyaListPage> {
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

  // Bottom Banner Ad
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

  // রেসপনসিভ লেআউট ভেরিয়েবল
  bool _isTablet = false;

  @override
  void initState() {
    super.initState();

    // ডিভাইস টাইপ চেক
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceType();
    });

    _loadDoyaData();

    // AdMob initialize
    AdHelper.initialize();

    // Bottom Banner Ad লোড
    _bottomBannerAd = AdHelper.createBannerAd(
      AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();

    // initial search query থাকলে সেট করুন
    if (widget.initialSearchQuery != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchController.text = widget.initialSearchQuery!;
        _searchDoya(widget.initialSearchQuery!);
      });
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
            'title': 'তাকবিরাতুল ইহরাম',
            'bangla': 'আল্লাহু আকবার',
            'arabic': 'اللهُ أَكْبَرُ',
            'transliteration': 'আল্লাহু আকবার',
            'meaning': 'আল্লাহ সর্বশ্রেষ্ঠ',
            'reference': 'সহীহ বুখারী: 789',
            'error': 'Original file failed to load: $e',
          },
        ];
        filteredDoyas = doyas;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // পেইজ বন্ধ হলে সকল expanded state রিসেট করুন
    _expandedDoyaIndices.clear();
    _showFullWarningStates.clear();
    _bottomBannerAd.dispose();
    _searchController.dispose();
    super.dispose();
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
  Future<void> _copyToClipboard(Map<String, String> doya) async {
    final String duaTitle = doya['title'] ?? '';
    final String duaArabic = doya['arabic'] ?? '';
    final String duaTransliteration = doya['transliteration'] ?? '';
    final String duaMeaning = doya['meaning'] ?? '';
    final String duaReference = doya['reference'] ?? '';

    final String copyText =
        '$duaTitle\n\n$duaArabic\n\n$duaTransliteration\n\nঅর্থ: $duaMeaning${duaReference.isNotEmpty ? '\n\nরেফারেন্স: $duaReference' : ''}';

    await Clipboard.setData(ClipboardData(text: copyText));

    // Snackbar দেখান
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$duaTitle" কপি করা হয়েছে'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  // সতর্কবার্তা উইজেট বিল্ড করার মেথড
  Widget _buildWarningWidget(int index) {
    final showFullWarning = _showFullWarningStates[index] ?? false;

    return showFullWarning
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.orange[900]?.withOpacity(0.1)
                  : Colors.orange[50],
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'সতর্কবার্তা',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  'কুরআনের আয়াত বা আরবি দুআ বাংলায় উচ্চারণ করে পড়লে অনেক সময় অর্থের বিকৃতি ঘটে। '
                  'তাই এ উচ্চারণকে শুধু সহায়ক হিসেবে গ্রহণ করুন। আসুন, আমরা শুদ্ধভাবে কুরআন পড়া শিখি।',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 12),

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
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'বুঝেছি',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                _showFullWarningStates[index] = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.orange[900]?.withOpacity(0.1)
                    : Colors.orange[50],
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.orange[700],
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'বাংলা উচ্চরণ',
                    style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                  ),
                ],
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
      }
    });
  }

  // দোয়া কার্ড বিল্ড করার মেথড - রেসপনসিভ
  Widget _buildDoyaCard(Map<String, String> doya, int index) {
    final bool isExpanded = _expandedDoyaIndices.contains(index);
    final String duaTitle = doya['title'] ?? '';
    final String duaArabic = doya['arabic'] ?? '';
    final String duaTransliteration = doya['transliteration'] ?? '';
    final String duaMeaning = doya['meaning'] ?? '';
    final String duaReference = doya['reference'] ?? '';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
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

                // Warning message
                _buildWarningWidget(index),

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
                    "অর্থ: $duaMeaning",
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
                    "রেফারেন্স: $duaReference",
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
                      onPressed: () => _copyToClipboard(doya),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('কপি'),
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
                        Share.share(
                          '$duaTitle\n\n$duaArabic\n\n$duaTransliteration\n\nঅর্থ: $duaMeaning\n\nরেফারেন্স: $duaReference',
                        );
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('শেয়ার'),
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

  // ইনলাইন ব্যানার বিল্ড করার মেথড
  Widget _buildInlineBanner() {
    final BannerAd inlineAd = AdHelper.createBannerAd(
      AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: inlineAd.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: inlineAd),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  fontWeight: FontWeight.bold,
                  fontSize: _isTablet ? 22 : 20, // ট্যাবলেটে বড় ফন্ট
                ),
              )
            : TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'দোয়া অনুসন্ধান করুন...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
                onChanged: _searchDoya,
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
                    title: const Text('ফন্ট বড় করুন'),
                    onTap: _increaseFontSize,
                  ),
                ),
                PopupMenuItem(
                  value: 'decrease',
                  child: ListTile(
                    leading: const Icon(Icons.zoom_out),
                    title: const Text('ফন্ট ছোট করুন'),
                    onTap: _decreaseFontSize,
                  ),
                ),
                PopupMenuItem(
                  value: 'reset',
                  child: ListTile(
                    leading: const Icon(Icons.restart_alt),
                    title: const Text('ডিফল্ট ফন্ট সাইজ'),
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
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDoyas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'কোন দোয়া পাওয়া যায়নি',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: _isTablet
                          ? 8
                          : 0, // ট্যাবলেটে horizontal padding
                    ),
                    itemCount: filteredDoyas.length,
                    itemBuilder: (context, index) {
                      final doya = filteredDoyas[index];
                      List<Widget> widgets = [_buildDoyaCard(doya, index)];

                      // প্রতি ৫ টা দোয়ার পর ব্যানার অ্যাড
                      if ((index + 1) % 5 == 0) {
                        widgets.add(_buildInlineBanner());
                      }

                      return Column(children: widgets);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _isBottomBannerAdReady
          ? SafeArea(
              child: Container(
                width: double.infinity,
                height: _bottomBannerAd.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bottomBannerAd),
              ),
            )
          : null,
    );
  }
}
