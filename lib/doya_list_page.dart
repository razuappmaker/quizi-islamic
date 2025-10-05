// Doya List Page - Responsive Version for Mobile & Tablet
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart'; // Clipboard এর জন্য
import 'ad_helper.dart';
import 'network_json_loader.dart'; // নতুন নেটওয়ার্ক লোডার

class DoyaListPage extends StatefulWidget {
  final String categoryTitle;
  final String jsonFile;
  final Color categoryColor;
  final String? initialSearchQuery;
  final String? preSelectedDoyaTitle; // নতুন প্যারামিটার
  final VoidCallback? onDoyaCardOpen; // দোয়া কার্ড ওপেন কলব্যাক

  const DoyaListPage({
    Key? key,
    required this.categoryTitle,
    required this.jsonFile,
    required this.categoryColor,
    this.initialSearchQuery,
    this.preSelectedDoyaTitle, // নতুন প্যারামিটার
    this.onDoyaCardOpen,
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

  // ✅ Adaptive Bottom Banner Ad
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

  // ✅ Adaptive Inline Banner Ads (প্রতি ৬টি দোয়ার পর)
  final Map<String, BannerAd?> _inlineBannerAds = {};
  final Map<String, bool> _inlineBannerAdReady = {};

  // রেসপনসিভ লেআউট ভেরিয়েবল
  bool _isTablet = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceType();
    });

    _loadDoyaData();

    AdHelper.initialize();
    _loadBottomBannerAd();

    // initial search query থাকলে সেট করুন
    if (widget.initialSearchQuery != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchController.text = widget.initialSearchQuery!;
        _searchDoya(widget.initialSearchQuery!);
      });
    }

    // pre-selected doya থাকলে সেট করুন
    if (widget.preSelectedDoyaTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoExpandPreSelectedDoya();
      });
    }
  }

  // নতুন মেথড: প্রি-সিলেক্টেড দোয়া অটো এক্সপ্যান্ড করুন
  void _autoExpandPreSelectedDoya() {
    if (widget.preSelectedDoyaTitle == null) return;

    final index = doyas.indexWhere(
      (doya) => doya['title'] == widget.preSelectedDoyaTitle,
    );

    if (index != -1 && mounted) {
      setState(() {
        _expandedDoyaIndices.add(index);

        // স্ক্রল করে সেই দোয়ায় নিয়ে যান
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final key = GlobalKey();
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      });

      // দোয়া কার্ড ওপেন হলে parent কে নোটিফাই করুন
      if (widget.onDoyaCardOpen != null) {
        widget.onDoyaCardOpen!();
      }
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
    _bottomBannerAd?.dispose();

    // ✅ সকল inline banner ads dispose করুন
    _inlineBannerAds.forEach((key, ad) => ad?.dispose());
    _inlineBannerAds.clear();
    _inlineBannerAdReady.clear();

    _searchController.dispose();
    super.dispose();
  }

  // ✅ Adaptive Bottom Banner Ad লোড করার মেথড
  Future<void> _loadBottomBannerAd() async {
    try {
      // ✅ AdHelper ব্যবহার করে adaptive banner তৈরি করুন
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('Bottom banner ad limit reached, not showing ad');
        return;
      }

      _bottomBannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Adaptive Bottom banner ad loaded successfully');
            if (mounted) {
              setState(() {
                _isBottomBannerAdReady = true;
              });
            }
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Adaptive Bottom banner ad failed to load: $error');
            ad.dispose();
            _bottomBannerAd = null;
            if (mounted) {
              setState(() {
                _isBottomBannerAdReady = false;
              });
            }
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
        ),
      );

      await _bottomBannerAd?.load();
    } catch (e) {
      print('Error loading adaptive bottom banner ad: $e');
      _bottomBannerAd?.dispose();
      _bottomBannerAd = null;
      if (mounted) {
        setState(() {
          _isBottomBannerAdReady = false;
        });
      }
    }
  }

  // ✅ Adaptive Inline Banner Ad লোড করার মেথড (প্রতি ৬টি দোয়ার পর)
  Future<void> _loadInlineBannerAd(String adKey) async {
    // Prevent duplicate loading
    if (_inlineBannerAds.containsKey(adKey) &&
        _inlineBannerAdReady[adKey] == true) {
      return;
    }

    try {
      // ✅ AdHelper ব্যবহার করে adaptive banner তৈরি করুন
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('Inline banner ad limit reached, not showing ad');
        return;
      }

      final inlineAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Inline Adaptive banner ad loaded for key $adKey');
            if (mounted) {
              setState(() {
                _inlineBannerAdReady[adKey] = true;
              });
            }
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print(
              'Inline Adaptive banner ad failed to load for key $adKey: $error',
            );
            ad.dispose();
            if (mounted) {
              setState(() {
                _inlineBannerAds.remove(adKey);
                _inlineBannerAdReady.remove(adKey);
              });
            }
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Inline Adaptive Banner ad clicked at key $adKey');
              } else {
                print('Ad click limit reached');
              }
            });
          },
        ),
      );

      if (mounted) {
        setState(() {
          _inlineBannerAds[adKey] = inlineAd;
        });
        await inlineAd.load();
      }
    } catch (e) {
      print('Error loading adaptive inline banner ad for key $adKey: $e');
      if (mounted) {
        setState(() {
          _inlineBannerAds.remove(adKey);
          _inlineBannerAdReady.remove(adKey);
        });
      }
    }
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

        // দোয়া কার্ড ওপেন হলে parent কে নোটিফাই করুন
        if (widget.onDoyaCardOpen != null) {
          widget.onDoyaCardOpen!();
        }
      }
    });
  }

  // ✅ Adaptive Inline Banner Ad বিল্ড করার মেথড
  // ✅ Adaptive Inline Banner Ad বিল্ড করার মেথড - FIXED VERSION
  Widget _buildInlineBanner(String adKey) {
    final bannerAd = _inlineBannerAds[adKey];
    final isReady = _inlineBannerAdReady[adKey] ?? false;

    // যদি অ্যাড ইতিমধ্যে লোড হয়ে থাকে এবং ready হয়
    if (bannerAd != null && isReady) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        height: bannerAd.size.height.toDouble(),
        alignment: Alignment.center,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        child: AdWidget(ad: bannerAd),
      );
    }

    // যদি অ্যাড এখনও লোড না হয়ে থাকে, তবে লোড শুরু করুন কিন্তু UI show না করুন
    if (bannerAd == null && !_inlineBannerAdReady.containsKey(adKey)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_inlineBannerAdReady.containsKey(adKey)) {
          _loadInlineBannerAd(adKey);
        }
      });
    }

    // লোডিং অবস্থায় অথবা অ্যাড না থাকলে সম্পূর্ণ hide করুন (সাইজ ০)
    return const SizedBox.shrink();
  }

  // দোয়া কার্ড বিল্ড করার মেথড - রেসপনসিভ
  Widget _buildDoyaCard(Map<String, String> doya, int index) {
    final bool isExpanded = _expandedDoyaIndices.contains(index);
    final String duaTitle = doya['title'] ?? '';
    // প্রি-সিলেক্টেড দোয়ার জন্য key তৈরি করুন
    final Key? cardKey = widget.preSelectedDoyaTitle == duaTitle
        ? GlobalKey()
        : null;

    final String duaArabic = doya['arabic'] ?? '';
    final String duaTransliteration = doya['transliteration'] ?? '';
    final String duaMeaning = doya['meaning'] ?? '';
    final String duaReference = doya['reference'] ?? '';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      key: cardKey,
      // key যোগ করুন
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

  // লোডিং ইন্ডিকেটর বিল্ড করার মেথড
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('দোয়া লোড হচ্ছে...'),
        ],
      ),
    );
  }

  // এম্পটি স্টেট বিল্ড করার মেথড
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('কোন দোয়া পাওয়া যায়নি', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  // দোয়া লিস্ট বিল্ড করার মেথড
  Widget _buildDoyaList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: _isTablet ? 8 : 0,
      ),
      itemCount: filteredDoyas.length,
      itemBuilder: (context, index) {
        final doya = filteredDoyas[index];

        // Cache the widget to avoid rebuilds
        final doyaCard = _buildDoyaCard(doya, index);

        List<Widget> widgets = [doyaCard];

        // ✅ প্রতি ৬ টা দোয়ার পর Adaptive ব্যানার অ্যাড
        if ((index + 1) % 6 == 0) {
          // filtered list-এর জন্য unique key তৈরি করুন
          final adKey = '${doya['title']}_$index';
          final bannerAd = _buildInlineBanner(adKey);
          widgets.add(bannerAd);
        }

        return Column(children: widgets);
      },
    );
  }

  // বটম ব্যানার অ্যাড বিল্ড করার মেথড
  Widget _buildBottomBannerAd() {
    return Container(
      width: double.infinity,
      height: _bottomBannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      child: AdWidget(ad: _bottomBannerAd!),
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
                  fontWeight: FontWeight.w600,
                  fontSize: _isTablet ? 22 : 20,
                  color: Colors.white,
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
      body: SafeArea(
        bottom: true, // ✅ নিচের SafeArea চালু করুন
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : filteredDoyas.isEmpty
                  ? _buildEmptyState()
                  : _buildDoyaList(),
            ),

            // ✅ Adaptive Bottom Banner Ad - SafeArea এর ভিতরে
            if (_isBottomBannerAdReady && _bottomBannerAd != null)
              _buildBottomBannerAd(),
          ],
        ),
      ),
    );
  }
}
