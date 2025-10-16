// home page - COMPACT VERSION
// lib/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

// আপনার সব imports
import '../ifter_time_page.dart';
import '../profile_screen.dart';
import '../qiblah_page.dart';
import '../mcq_page.dart';
import '../islamic_history_page.dart';
import '../prophet_biography_page.dart';
import '../prayer_time_page.dart';
import '../doya_category_page.dart';
import '../nadiyatul_quran.dart';
import '../sura_page.dart';
import '../name_of_allah_page.dart';
import '../kalema_page.dart';
import '../utils.dart';
import '../ad_helper.dart';
import '../tasbeeh_page.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/responsive_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/drawer_menu.dart';
import '../quran_verse_scroller.dart';
import '../word_by_word_quran_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  String? selectedCategory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BannerAd? _bannerAd;
  bool _isConnected = true;
  bool _isBannerLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentBottomNavIndex = 0;

  // Refresh control variables
  final RefreshController _refreshController = RefreshController();
  bool _isRefreshing = false;

  // Adaptive banner ad variables
  bool _showBannerAd = true;
  bool _isBannerAdLoaded = false;
  double _bannerHeight = 50.0;

  final List<String> _categoriesBn = [
    'ইসলামী প্রাথমিক জ্ঞান',
    'কোরআন',
    'মহানবী সঃ এর জীবনী',
    'ইবাদত',
    'আখিরাত',
    'বিচার দিবস',
    'নারী ও ইসলাম',
    'ইসলামী নৈতিকতা ও আচার',
    'ধর্মীয় আইন(বিবাহ-বিচ্ছেদ)',
    'শিষ্টাচার',
    'দাম্পত্য ও পারিবারিক সম্পর্ক',
    'হাদিস',
    'নবী-রাসূল',
    'ইসলামের ইতিহাস',
  ];

  final List<String> _categoriesEn = [
    'Basic Islamic Knowledge',
    'Quran',
    'Prophet Biography',
    'Worship',
    'Hereafter',
    'Judgment Day',
    'Women in Islam',
    'Islamic Ethics & Manners',
    'Religious Law (Marriage-Divorce)',
    'Etiquette',
    'Marital & Family Relations',
    'Hadith',
    'Prophets',
    'Islamic History',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Reduced duration
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          // Reduced slide distance
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      // Reduced delay
      if (mounted) {
        _initializeApp();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshHomePage();
      }
    });
  }

  @override
  void didPushNext() {
    print('HomePage didPushNext');
  }

  @override
  void didPush() {
    print('HomePage didPush');
  }

  @override
  void didPop() {
    print('HomePage didPop');
  }

  void _initializeApp() {
    _checkConnectivity();
    _loadAdaptiveBannerAd();
    AdHelper.loadInterstitialAd();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _animationController.stop();
        break;
      case AppLifecycleState.resumed:
        if (!_animationController.isAnimating) {
          _animationController.forward();
        }
        if (_showBannerAd && !_isBannerAdLoaded) {
          _loadAdaptiveBannerAd();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _cleanupResources();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _cleanupResources() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _bannerAd?.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _animationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (mounted) {
        setState(() {
          _isConnected = connectivityResult != ConnectivityResult.none;
        });
      }
    } catch (e) {
      print('Connectivity check error: $e');
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    }
  }

  Future<void> _loadAdaptiveBannerAd() async {
    if (!_isConnected || !mounted || _isBannerLoading) return;

    BannerAd? banner;

    try {
      setState(() {
        _isBannerLoading = true;
      });

      final shouldShow = await AdHelper.shouldShowAds;
      if (!shouldShow) {
        if (mounted) {
          setState(() {
            _showBannerAd = false;
            _isBannerLoading = false;
            _isBannerAdLoaded = false;
          });
        }
        return;
      }

      final canShow = await AdHelper.canShowBannerAd();
      if (!canShow) {
        if (mounted) {
          setState(() {
            _showBannerAd = false;
            _isBannerLoading = false;
            _isBannerAdLoaded = false;
          });
        }
        return;
      }

      banner = await AdHelper.createAnchoredBannerAd(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Adaptive banner ad loaded successfully.');
            if (mounted) {
              setState(() {
                _isBannerAdLoaded = true;
                _isBannerLoading = false;
                _bannerAd = banner;
                _bannerHeight = _bannerAd?.size.height.toDouble() ?? 50.0;
              });
            }
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Adaptive banner failed to load: $error');
            if (mounted) {
              setState(() {
                _isBannerAdLoaded = false;
                _isBannerLoading = false;
                _bannerAd = null;
              });
            }
            Future.delayed(const Duration(seconds: 30), () {
              if (mounted && _showBannerAd) {
                _loadAdaptiveBannerAd();
              }
            });
          },
          onAdOpened: (Ad ad) {
            print('Banner ad opened.');
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
              }
            });
          },
          onAdClosed: (Ad ad) {
            print('Banner ad closed.');
          },
        ),
      );

      if (banner != null) {
        await banner.load();
      } else {
        if (mounted) {
          setState(() {
            _isBannerLoading = false;
            _isBannerAdLoaded = false;
            _bannerHeight = 0.0;
          });
        }
      }
    } catch (e) {
      print('Adaptive banner ad loading error: $e');
      if (mounted) {
        setState(() {
          _isBannerLoading = false;
          _isBannerAdLoaded = false;
          _bannerHeight = 0.0;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    print('🔄 Pull-to-Refresh triggered...');

    _animationController.reset();
    await _checkConnectivity();

    if (!_showBannerAd) {
      setState(() {
        _showBannerAd = true;
      });
    }

    if (_showBannerAd) {
      _bannerAd?.dispose();
      _isBannerAdLoaded = false;
      await _loadAdaptiveBannerAd();
    }

    _animationController.forward();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.isEnglish
                ? 'Home page refreshed'
                : 'হোম পেজ রিফ্রেশ করা হয়েছে',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green[700],
        ),
      );
    }

    setState(() {
      _isRefreshing = false;
    });
  }

  void _refreshHomePage() {
    if (!mounted) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    print('🔄 Refreshing home page from back navigation...');

    setState(() {
      selectedCategory = null;
    });

    _animationController.reset();
    _animationController.forward();

    if (!_showBannerAd) {
      setState(() {
        _showBannerAd = true;
      });
    }

    if (_showBannerAd) {
      print('🔄 Refreshing banner ad...');
      _bannerAd?.dispose();
      _isBannerAdLoaded = false;
      _loadAdaptiveBannerAd();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageProvider.isEnglish
              ? 'Home page refreshed'
              : 'হোম পেজ রিফ্রেশ করা হয়েছে',
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  void _toggleBannerAd() {
    if (mounted) {
      setState(() {
        _showBannerAd = !_showBannerAd;
      });

      if (_showBannerAd && !_isBannerAdLoaded) {
        _loadAdaptiveBannerAd();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tablet = isTablet(context);
    final landscape = isLandscape(context);

    return WillPopScope(
      onWillPop: () async => await showExitConfirmationDialog(context),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: ResponsiveText(
            languageProvider.isEnglish ? 'Islamic Day' : 'Islamic Day',
            fontSize: tablet ? 20 : 18, // Reduced font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          backgroundColor: isDarkMode ? _Colors.darkAppBar : Colors.green[800],
          elevation: 2,
          // Reduced elevation
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(12),
            ), // Reduced radius
          ),
          leading: ResponsiveIconButton(
            icon: Icons.menu,
            iconSize: tablet ? 24 : 22, // Reduced icon size
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            color: Colors.white,
          ),
          actions: [
            ResponsiveIconButton(
              icon: Icons.language,
              iconSize: tablet ? 24 : 22, // Reduced icon size
              onPressed: () async {
                if (mounted) {
                  setState(() {
                    selectedCategory = null;
                  });
                }
                final languageProvider = Provider.of<LanguageProvider>(
                  context,
                  listen: false,
                );
                await languageProvider.toggleLanguage();
              },
              color: Colors.white,
            ),
            ResponsiveIconButton(
              icon: isDarkMode ? Icons.brightness_7 : Icons.brightness_4,
              iconSize: tablet ? 24 : 22, // Reduced icon size
              onPressed: () =>
                  themeProvider.toggleTheme(!themeProvider.isDarkMode),
              color: Colors.white,
            ),
          ],
        ),
        drawer: DrawerMenu(scaffoldKey: _scaffoldKey),
        body: SafeArea(
          bottom: false,
          child: _buildBody(isDarkMode, tablet, landscape, languageProvider),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          isDarkMode: isDarkMode,
          currentIndex: _currentBottomNavIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  Widget _buildBody(
    bool isDarkMode,
    bool tablet,
    bool landscape,
    LanguageProvider languageProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? _Colors.darkBackgroundGradient
              : _Colors.lightBackgroundGradient,
        ),
      ),
      child: Column(
        children: [
          // Main Content Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: isDarkMode ? _Colors.darkPrimary : Colors.green,
              backgroundColor: isDarkMode ? _Colors.darkCard : Colors.white,
              strokeWidth: 2.0,
              // Reduced stroke width
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              child: _buildCompactContentList(
                isDarkMode,
                tablet,
                landscape,
                languageProvider,
              ),
            ),
          ),

          // Banner Ad Section
          if (_showBannerAd && _isBannerAdLoaded && _bannerAd != null)
            Container(
              color: isDarkMode ? _Colors.darkSurface : Colors.white,
              width: double.infinity,
              height: _bannerHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(child: AdWidget(ad: _bannerAd!)),
                  Positioned(
                    top: -6, // Reduced position
                    right: -6, // Reduced position
                    child: GestureDetector(
                      onTap: _toggleBannerAd,
                      child: Container(
                        width: 24, // Reduced size
                        height: 24, // Reduced size
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 3, // Reduced shadow
                              offset: const Offset(0, 1), // Reduced offset
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14, // Reduced icon size
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // COMPACT CONTENT LIST - OPTIMIZED FOR MOBILE AND TABLET
  Widget _buildCompactContentList(
    bool isDarkMode,
    bool tablet,
    bool landscape,
    LanguageProvider languageProvider,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: tablet ? 8 : 4, // Reduced padding
      ),
      children: [
        // Quran Verse Scroller - Reduced height
        SizedBox(
          height: tablet ? 45 : 40, // Reduced height
          child: QuranVerseScroller(
            isDarkMode: isDarkMode,
            isTablet: tablet,
            isLandscape: landscape,
          ),
        ),

        SizedBox(height: tablet ? 6 : 4), // Reduced spacing
        // Category Selector - Compact version
        _buildCompactCategorySelector(isDarkMode, tablet),

        SizedBox(height: tablet ? 6 : 4), // Reduced spacing
        // Quick Access - Compact version
        _buildCompactQuickAccess(context, isDarkMode, tablet),

        SizedBox(height: tablet ? 6 : 4), // Reduced spacing
        // Additional Features - Compact version
        _buildCompactAdditionalFeatures(context, isDarkMode, tablet),

        // Banner Ad Loading Indicator
        if (_showBannerAd && !_isBannerAdLoaded && _isBannerLoading)
          Container(
            height: _bannerHeight,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 1.5, // Reduced stroke width
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? _Colors.darkPrimary : Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  // COMPACT CATEGORY SELECTOR
  Widget _buildCompactCategorySelector(bool isDarkMode, bool tablet) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (languageProvider.isLoading ||
        languageProvider.currentLanguage.isEmpty) {
      return Container(
        height: tablet ? 80 : 70, // Reduced height
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final categories = languageProvider.isEnglish
        ? _categoriesEn
        : _categoriesBn;

    final Map<String, String> categoryMappings = {
      'ইসলামী প্রাথমিক জ্ঞান': 'islamic_basic_knowledge',
      'Basic Islamic Knowledge': 'islamic_basic_knowledge',
      'কোরআন': 'quran',
      'Quran': 'quran',
      'মহানবী সঃ এর জীবনী': 'prophet_biography',
      'Prophet Biography': 'prophet_biography',
      'ইবাদত': 'worship',
      'Worship': 'worship',
      'আখিরাত': 'hereafter',
      'Hereafter': 'hereafter',
      'বিচার দিবস': 'judgment_day',
      'Judgment Day': 'judgment_day',
      'নারী ও ইসলাম': 'women_in_islam',
      'Women in Islam': 'women_in_islam',
      'ইসলামী নৈতিকতা ও আচার': 'islamic_ethics',
      'Islamic Ethics & Manners': 'islamic_ethics',
      'ধর্মীয় আইন(বিবাহ-বিচ্ছেদ)': 'religious_law',
      'Religious Law (Marriage-Divorce)': 'religious_law',
      'শিষ্টাচার': 'etiquette',
      'Etiquette': 'etiquette',
      'দাম্পত্য ও পারিবারিক সম্পর্ক': 'family_relations',
      'Marital & Family Relations': 'family_relations',
      'হাদিস': 'hadith',
      'Hadith': 'hadith',
      'নবী-রাসূল': 'prophets',
      'Prophets': 'prophets',
      'ইসলামের ইতিহাস': 'islamic_history',
      'Islamic History': 'islamic_history',
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: tablet ? 12 : 8),
      child: Card(
        elevation: isDarkMode ? 0 : 2,
        color: isDarkMode ? _Colors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 12 : 8),
          side: isDarkMode
              ? BorderSide(color: _Colors.darkBorder.withOpacity(0.3))
              : BorderSide.none,
        ),
        child: Padding(
          padding: EdgeInsets.all(tablet ? 8 : 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveText(
                languageProvider.isEnglish
                    ? 'Islamic Knowledge Test: Quiz'
                    : 'ইসলামী মেধাযাচাই: জ্ঞান কুইজ',
                fontSize: tablet ? 18 : 13,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? _Colors.darkText : Colors.green[800]!,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tablet ? 4 : 3),
              // Compact Dropdown
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tablet ? 8 : 6,
                  vertical: tablet ? 4 : 3,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? _Colors.darkSurface : Colors.green[50],
                  borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                  border: Border.all(
                    color: isDarkMode
                        ? _Colors.darkPrimary
                        : Colors.green[600]!,
                    width: 0.8,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    hint: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: tablet ? 14 : 12,
                          color: isDarkMode
                              ? _Colors.darkText
                              : Colors.green[700],
                        ),
                        SizedBox(width: tablet ? 4 : 3),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ResponsiveText(
                              languageProvider.isEnglish
                                  ? 'Select Category'
                                  : 'বিষয় বেছে নিন',
                              fontSize: tablet ? 11 : 10,
                              color: isDarkMode
                                  ? _Colors.darkTextSecondary
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: tablet ? 11 : 10,
                      color: isDarkMode ? _Colors.darkText : Colors.black87,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDarkMode ? _Colors.darkText : Colors.green,
                      size: tablet ? 18 : 16,
                    ),
                    isExpanded: true,
                    dropdownColor: isDarkMode ? _Colors.darkCard : Colors.white,
                    menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
                    onChanged: (String? newValue) {
                      if (mounted) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      }
                    },
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: tablet ? 6 : 4,
                            horizontal: tablet ? 4 : 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(tablet ? 4 : 3),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? _Colors.darkPrimary.withOpacity(0.2)
                                      : Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.bookmark_border,
                                  size: tablet ? 12 : 10,
                                  color: isDarkMode
                                      ? _Colors.darkPrimary
                                      : Colors.green[700],
                                ),
                              ),
                              SizedBox(width: tablet ? 8 : 6),
                              Expanded(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: tablet ? 11 : 10,
                                    color: isDarkMode
                                        ? _Colors.darkText
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: tablet ? 6 : 4),
              // Compact Button
              SizedBox(
                height: tablet ? 36 : 32,
                child: ElevatedButton.icon(
                  onPressed: selectedCategory == null
                      ? null
                      : () {
                          if (mounted) {
                            final String quizId =
                                categoryMappings[selectedCategory!] ??
                                selectedCategory!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MCQPage(
                                  category: selectedCategory!,
                                  quizId: quizId,
                                ),
                              ),
                            );
                          }
                        },
                  icon: Icon(Icons.play_circle_filled, size: tablet ? 16 : 12),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ResponsiveText(
                      languageProvider.isEnglish
                          ? 'Start Quiz'
                          : 'কুইজ শুরু করুন',
                      fontSize: _getButtonFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? _Colors.darkPrimary
                        : Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tablet ? 8 : 6),
                    ),
                    elevation: 2,
                    padding: EdgeInsets.symmetric(
                      horizontal: tablet ? 16 : 8,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to calculate dynamic font size
  double _getButtonFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      // Very small phones
      return 10;
    } else if (width < 400) {
      // Small phones
      return 11;
    } else if (width < 500) {
      // Medium phones
      return 12;
    } else {
      // Tablets and large devices
      return 13;
    }
  }

  // COMPACT QUICK ACCESS - UPDATED WITH DARK MODE COLORS
  Widget _buildCompactQuickAccess(
    BuildContext context,
    bool isDarkMode,
    bool isTablet,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    final primaryColor = isDarkMode ? _Colors.darkPrimary : Colors.green[700]!;
    final cardColor = isDarkMode ? _Colors.darkCard : Colors.white;
    final textColor = isDarkMode ? _Colors.darkText : Colors.green[900]!;
    final iconColor = isDarkMode ? _Colors.darkPrimary : Colors.green[700]!;
    final containerColor = isDarkMode
        ? _Colors.darkSurface
        : Colors.green[100]!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 6),
      padding: EdgeInsets.all(isTablet ? 12 : 6),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.isEnglish ? 'Worship & Prayers' : 'ইবাদাত ও দোয়া',
            style: TextStyle(
              fontSize: isTablet ? 20 : 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? _Colors.darkText : Colors.green[800]!,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 6),

          // FIXED 3x2 GRID - Reduced height for tablet
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: isTablet ? 8 : 6,
            crossAxisSpacing: isTablet ? 8 : 6,
            childAspectRatio: isTablet ? 1.2 : 0.8,
            children: [
              _buildCompactIslamicCard(
                context,
                languageProvider.isEnglish ? 'Prayer Time' : 'নামাজের সময়',
                Icons.access_time_rounded,
                iconColor,
                cardColor,
                textColor,
                const PrayerTimePage(),
                isDarkMode,
                isTablet,
              ),
              _buildCompactIslamicCard(
                context,
                languageProvider.isEnglish ? 'Sehri & Iftar' : 'সেহেরী ও ইফতার',
                Icons.restaurant,
                iconColor,
                cardColor,
                textColor,
                const IfterTimePage(),
                isDarkMode,
                isTablet,
              ),
              _buildCompactIslamicCard(
                context,
                languageProvider.isEnglish ? 'Short Surahs' : 'ছোট সূরা',
                Icons.menu_book_rounded,
                iconColor,
                cardColor,
                textColor,
                const SuraPage(),
                isDarkMode,
                isTablet,
              ),
              _buildCompactIslamicCard(
                context,
                languageProvider.isEnglish ? 'Prayers' : 'দুআ',
                Icons.lightbulb_outline_rounded,
                iconColor,
                cardColor,
                textColor,
                const DoyaCategoryPage(),
                isDarkMode,
                isTablet,
              ),
              _buildCompactIslamicCard(
                context,
                languageProvider.isEnglish ? 'Tasbih' : 'তসবিহ',
                Icons.fingerprint_rounded,
                iconColor,
                cardColor,
                textColor,
                const TasbeehPage(),
                isDarkMode,
                isTablet,
              ),
              _buildCompactIslamicCard(
                context,
                languageProvider.isEnglish ? 'Qibla' : 'কিবলা',
                Icons.explore_rounded,
                iconColor,
                cardColor,
                textColor,
                const QiblaPage(),
                isDarkMode,
                isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPDATED COMPACT ISLAMIC CARD - IMPROVED DARK MODE
  Widget _buildCompactIslamicCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    Color cardColor,
    Color textColor,
    Widget? page,
    bool isDarkMode,
    bool isTablet,
  ) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
        side: isDarkMode
            ? BorderSide(color: _Colors.darkBorder.withOpacity(0.2))
            : BorderSide.none,
      ),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
        onTap: page != null && mounted
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              }
            : null,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 6 : 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 3),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? _Colors.darkPrimary.withOpacity(0.15)
                      : iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: isTablet ? 30 : 20, color: iconColor),
              ),
              SizedBox(height: isTablet ? 4 : 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.1,
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

  // COMPACT ADDITIONAL FEATURES - IMPROVED DARK MODE
  Widget _buildCompactAdditionalFeatures(
    BuildContext context,
    bool isDarkMode,
    bool isTablet,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    final backgroundColor = isDarkMode ? _Colors.darkCard : Colors.green[50]!;
    final textColor = isDarkMode ? _Colors.darkText : Colors.green[900]!;
    final secondaryTextColor = isDarkMode
        ? _Colors.darkTextSecondary
        : Colors.green[600]!;
    final iconColor = isDarkMode ? _Colors.darkPrimary : Colors.green[700]!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 6),
      padding: EdgeInsets.all(isTablet ? 12 : 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 10),
        border: isDarkMode
            ? Border.all(color: _Colors.darkBorder.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 8 : 6,
              vertical: isTablet ? 6 : 4,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? _Colors.darkPrimary.withOpacity(0.1)
                  : Colors.green[100]!,
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 8 : 6),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? _Colors.darkPrimary.withOpacity(0.15)
                        : Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: isDarkMode
                        ? _Colors.darkPrimary
                        : Colors.green[700]!,
                    size: isTablet ? 22 : 18,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: Text(
                    languageProvider.isEnglish
                        ? 'Islamic Knowledge Bank'
                        : 'ইসলামী জ্ঞান ভাণ্ডার',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),

          // Compact Grid - ডার্ক মুডে কালার আপডেট করা হয়েছে
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: isTablet ? 12 : 8,
            mainAxisSpacing: isTablet ? 12 : 8,
            childAspectRatio: isTablet ? 3.2 : 3.0,
            children: [
              _buildUltraCompactCard(
                context,
                languageProvider.isEnglish
                    ? 'Names of Allah'
                    : 'আল্লাহর নামসমূহ',
                Icons.auto_awesome_rounded,
                isDarkMode ? _Colors.darkPrimary : Colors.blue[600]!,
                // সবগুলোতে darkPrimary
                isDarkMode ? _Colors.darkSurface : Colors.blue[50]!,
                // darkSurface ব্যাকগ্রাউন্ড
                isDarkMode ? _Colors.darkPrimary : Colors.blue[600]!,
                // darkPrimary বর্ডার
                textColor,
                const NameOfAllahPage(),
                isDarkMode,
                isTablet,
              ),
              _buildUltraCompactCard(
                context,
                languageProvider.isEnglish ? 'Kalimah' : 'কালিমাহ',
                Icons.book_rounded,
                isDarkMode ? _Colors.darkPrimary : Colors.green[600]!,
                // সবগুলোতে darkPrimary
                isDarkMode ? _Colors.darkSurface : Colors.green[50]!,
                // darkSurface ব্যাকগ্রাউন্ড
                isDarkMode ? _Colors.darkPrimary : Colors.green[600]!,
                // darkPrimary বর্ডার
                textColor,
                const KalemaPage(),
                isDarkMode,
                isTablet,
              ),
              _buildUltraCompactCard(
                context,
                languageProvider.isEnglish ? 'Quran Learning' : 'কোরআন শিক্ষা',
                Icons.menu_book_rounded,
                isDarkMode ? _Colors.darkPrimary : Colors.purple[600]!,
                // সবগুলোতে darkPrimary
                isDarkMode ? _Colors.darkSurface : Colors.purple[50]!,
                // darkSurface ব্যাকগ্রাউন্ড
                isDarkMode ? _Colors.darkPrimary : Colors.purple[600]!,
                // darkPrimary বর্ডার
                textColor,
                const NadiyatulQuran(),
                isDarkMode,
                isTablet,
              ),
              _buildUltraCompactCard(
                context,
                languageProvider.isEnglish ? 'More' : 'অন্যান্য',
                Icons.more_horiz_rounded,
                isDarkMode ? _Colors.darkPrimary : Colors.orange[600]!,
                // সবগুলোতে darkPrimary
                isDarkMode ? _Colors.darkSurface : Colors.orange[50]!,
                // darkSurface ব্যাকগ্রাউন্ড
                isDarkMode ? _Colors.darkPrimary : Colors.orange[600]!,
                // darkPrimary বর্ডার
                textColor,
                null,
                isDarkMode,
                isTablet,
                onTap: () {
                  _showCompactMoreOptions(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPDATED ULTRA COMPACT CARD - ডার্ক মুডে ইউনিফাইড কালার
  Widget _buildUltraCompactCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
    Color borderColor,
    Color textColor,
    Widget? page,
    bool isDarkMode,
    bool isTablet, {
    Function()? onTap,
  }) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        side: BorderSide(
          color: isDarkMode
              ? _Colors.darkPrimary.withOpacity(
                  0.3,
                ) // ডার্ক মুডে সব কার্ডে darkPrimary বর্ডার
              : borderColor.withOpacity(0.3),
          width: isTablet ? 1.2 : 0.8,
        ),
      ),
      color: backgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        onTap:
            onTap ??
            (page != null && mounted
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => page),
                    );
                  }
                : null),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // আইকন কন্টেইনার - ডার্ক মুডে সব আইকনে darkPrimary কালার
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 6),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? _Colors.darkPrimary.withOpacity(
                          0.15,
                        ) // ডার্ক মুডে সব আইকনে darkPrimary ব্যাকগ্রাউন্ড
                      : iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: isDarkMode
                      ? Border.all(
                          color: _Colors.darkPrimary.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  icon,
                  size: isTablet ? 24 : 18,
                  color: isDarkMode
                      ? _Colors.darkPrimary
                      : iconColor, // ডার্ক মুডে সব আইকনে darkPrimary কালার
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              // টাইটেল
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompactMoreOptions(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? _Colors.darkCard
                  : Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? _Colors.darkTextSecondary
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  languageProvider.isEnglish
                      ? 'More Islamic Knowledge'
                      : 'আরও ইসলামী জ্ঞান',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? _Colors.darkPrimary : Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildCompactOptionItem(
                  context,
                  Icons.history_rounded,
                  languageProvider.isEnglish
                      ? 'Islamic History'
                      : 'ইসলামের ইতিহাস',
                  onTap: () {
                    Navigator.pop(context);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IslamicHistoryPage(),
                        ),
                      );
                    }
                  },
                ),
                _buildCompactOptionItem(
                  context,
                  Icons.person,
                  languageProvider.isEnglish
                      ? 'Prophet Muhammad (PBUH) Biography'
                      : 'হজরত মুহাম্মাদ (সা.)-এর জীবনী',
                  onTap: () {
                    Navigator.pop(context);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProphetBiographyPage(),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactOptionItem(
    BuildContext context,
    IconData icon,
    String title, {
    Function()? onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(
        icon,
        size: 18,
        color: isDarkMode ? _Colors.darkPrimary : Colors.green[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? _Colors.darkText : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 12,
        color: isDarkMode ? _Colors.darkTextSecondary : Colors.grey[500],
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  void _onBottomNavTap(int index) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    if (index == 0 && _currentBottomNavIndex == 0) {
      _handleRefresh();
    }

    if (mounted) {
      setState(() {
        _currentBottomNavIndex = index;
      });
    }

    switch (index) {
      case 0:
        break;
      case 1:
        _showSnackBar(
          languageProvider.isEnglish
              ? 'Opening Play Store...'
              : 'প্লে স্টোর খোলা হচ্ছে...',
        );
        await _launchPlayStore();
        if (mounted) {
          setState(() {
            _currentBottomNavIndex = 0;
          });
        }
        break;
      case 2:
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WordByWordQuranPage()),
          );
        }
        break;
      case 3:
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
        break;
    }
  }

  Future<void> _launchPlayStore() async {
    try {
      final Uri ratingUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.example.quizapp',
      );
      if (await canLaunchUrl(ratingUri)) {
        await launchUrl(ratingUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Play Store launch error: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Enhanced Color Scheme for Dark Mode
class _Colors {
  // Dark Mode Colors - Professional Islamic Theme
  static const Color darkPrimary = Color(0xFF10B981); // Emerald Green
  static const Color darkPrimaryVariant = Color(0xFF059669); // Darker Emerald
  static const Color darkSecondary = Color(0xFF8B5CF6); // Violet
  static const Color darkBackground = Color(0xFF111827); // Dark Blue-Gray
  static const Color darkSurface = Color(0xFF1F2937); // Dark Gray
  static const Color darkCard = Color(0xFF374151); // Medium Gray
  static const Color darkError = Color(0xFFEF4444); // Red
  static const Color darkText = Color(0xFFF9FAFB); // White
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // Light Gray

  // Dark Mode Gradients
  static const List<Color> darkBackgroundGradient = [
    Color(0xFF111827), // Dark Blue-Gray
    Color(0xFF1F2937), // Dark Gray
  ];

  // Dark Mode Card Colors
  static const Color darkBlueCard = Color(0xFF1E3A8A);
  static const Color darkGreenCard = Color(0xFF065F46);
  static const Color darkPurpleCard = Color(0xFF5B21B6);
  static const Color darkOrangeCard = Color(0xFF9A3412);

  // Dark Mode Accent Colors
  static const Color darkBlueAccent = Color(0xFF60A5FA);
  static const Color darkGreenAccent = Color(0xFF34D399);
  static const Color darkPurpleAccent = Color(0xFFA78BFA);
  static const Color darkOrangeAccent = Color(0xFFFB923C);

  // Dark Mode Border
  static const Color darkBorder = Color(0xFF4B5563);

  // Light Mode Colors (Existing)
  static const List<Color> lightBackgroundGradient = [
    Color(0xFFF0FDF4), // Very Light Green
    Color(0xFFDCFCE7), // Light Green
  ];

  // App Bar
  //static const Color darkAppBar = Color(0xFF1B5E20); // Dark Emerald
  static const Color darkAppBar = Color(0xFF065F46); // Dark Emerald
}

// Route Observer
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// RefreshController
class RefreshController {
  void refreshCompleted() {}

  void resetNoData() {}
}
