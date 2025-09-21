// Doya Page
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'json_loader.dart';

class DoyaCategoryPage extends StatefulWidget {
  const DoyaCategoryPage({Key? key}) : super(key: key);

  @override
  State<DoyaCategoryPage> createState() => _DoyaCategoryPageState();
}

class _DoyaCategoryPageState extends State<DoyaCategoryPage> {
  // Bottom Banner
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'সালাত-নামাজ',
      'icon': Icons.mosque,
      'color': Colors.blue,
      'jsonFile': 'assets/salat_doyas.json',
    },
    {
      'title': 'দৈনন্দিন জীবন',
      'icon': Icons.home,
      'color': Colors.green,
      'jsonFile': 'assets/daily_life_doyas.json',
    },
    {
      'title': 'সওম-রোজা',
      'icon': Icons.nightlight_round,
      'color': Colors.purple,
      'jsonFile': 'assets/fasting_doyas.json',
    },
    {
      'title': 'সকাল-সন্ধ্যার জিকির',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'jsonFile': 'assets/azkar_doyas.json',
    },
    {
      'title': 'কুরআন থেকে',
      'icon': Icons.menu_book,
      'color': Colors.deepPurple,
      'jsonFile': 'assets/quranic_doyas.json',
    },
    {
      'title': 'বিবিধ',
      'icon': Icons.category,
      'color': Colors.teal,
      'jsonFile': 'assets/misc_doyas.json',
    },
  ];

  // Global search variables
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allDoyas = [];
  List<Map<String, String>> _searchResults = [];
  bool _isLoadingAllDoyas = false;

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

    // Load all doyas for global search
    _loadAllDoyas();
  }

  Future<void> _loadAllDoyas() async {
    setState(() => _isLoadingAllDoyas = true);

    try {
      List<Map<String, String>> allDoyas = [];

      for (var category in categories) {
        try {
          final loadedData = await JsonLoader.loadJsonList(
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

          // Add category information to each doya
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
        ),
      ),
    );
  }

  void _navigateToSearchedDoya(BuildContext context, Map<String, String> doya) {
    // Find the category for this doya
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

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToCategoryDoyas(context, category),
        child: Container(
          height: 120,
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
              Icon(category['icon'], size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                category['title'],
                style: const TextStyle(
                  fontSize: 16,
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
    Color categoryColor = Colors.teal; // Default color
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
                'দোয়ার ক্যাটাগরি',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
        centerTitle: true,
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

  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cards per row
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9, // Square aspect ratio
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

// DoyaListPage কে আপডেট করুন initialSearchQuery support করার জন্য
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

  // Track which doya is expanded and warning state
  int? _expandedDoyaIndex;
  bool _showFullWarning = false;

  // Bottom Banner
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

  @override
  void initState() {
    super.initState();
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
  }

  Future<void> _loadDoyaData() async {
    try {
      print('Loading doya data from: ${widget.jsonFile}'); // Debug
      final loadedData = await JsonLoader.loadJsonList(widget.jsonFile);

      final List<Map<String, String>> convertedData = loadedData
          .map<Map<String, String>>((item) {
            print('Processing item: $item'); // Debug
            final Map<String, dynamic> dynamicItem = Map<String, dynamic>.from(
              item,
            );
            return dynamicItem.map(
              (key, value) => MapEntry(key, value.toString()),
            );
          })
          .toList();

      print('Successfully converted ${convertedData.length} items'); // Debug

      setState(() {
        doyas = convertedData;
        filteredDoyas = convertedData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _loadDoyaData: $e'); // Debug
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
    _bottomBannerAd.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      filteredDoyas = doyas;
      _searchController.clear();
    });
  }

  void _searchDoya(String query) {
    final results = doyas.where((doya) {
      final titleLower = doya['title']!.toLowerCase();
      final banglaLower = doya['bangla']!.toLowerCase();
      return titleLower.contains(query.toLowerCase()) ||
          banglaLower.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredDoyas = results);
  }

  //===================
  Widget _buildWarningWidget() {
    return _showFullWarning
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
                // Simple header
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

                // Simple content
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

                // Simple close button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showFullWarning = false;
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
        : // Simple collapsed state
          GestureDetector(
            onTap: () {
              setState(() {
                _showFullWarning = true;
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

  // Helper method for consistent paragraph styling
  Widget _buildWarningParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.5,
        height: 1.7,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.black87,
      ),
      textAlign: TextAlign.justify,
    );
  }

  void _showDoyaDetails(Map<String, String> doya, int index) {
    setState(() {
      if (_expandedDoyaIndex == index) {
        // If already expanded, collapse it
        _expandedDoyaIndex = null;
        _showFullWarning = false;
      } else {
        // Expand this doya
        _expandedDoyaIndex = index;
        _showFullWarning = false;
      }
    });
  }

  Widget _buildDoyaCard(Map<String, String> doya, int index) {
    final bool isExpanded = _expandedDoyaIndex == index;
    final String duaTitle = doya['title'] ?? '';
    final String duaArabic = doya['arabic'] ?? '';
    final String duaTransliteration = doya['transliteration'] ?? '';
    final String duaMeaning = doya['meaning'] ?? '';
    final String duaReference = doya['reference'] ?? '';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDoyaDetails(doya, index),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                            fontSize: 18,
                            color: widget.categoryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doya['bangla'] ?? '',
                          style: const TextStyle(fontSize: 16),
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
                _buildWarningWidget(),

                const SizedBox(height: 16),

                // Arabic text
                SelectableText(
                  duaArabic,
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'Amiri',
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 15),

                // Transliteration
                Text(
                  duaTransliteration,
                  style: TextStyle(
                    fontSize: 18,
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
                  child: Text(
                    "অর্থ: $duaMeaning",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),

                // Reference
                if (duaReference.isNotEmpty)
                  Text(
                    "রেফারেন্স: $duaReference",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.green[200] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 16),

                // Share button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Share.share(
                        '$duaTitle\n\n$duaArabic\n\n$duaTransliteration\n\nঅর্থ: $duaMeaning\n\nরেফারেন্স: $duaReference',
                      );
                    },
                    icon: Icon(Icons.share, color: widget.categoryColor),
                    label: Text(
                      'শেয়ার করুন',
                      style: TextStyle(color: widget.categoryColor),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  //===================

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.categoryColor,
        title: !_isSearching
            ? Text(
                widget.categoryTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
