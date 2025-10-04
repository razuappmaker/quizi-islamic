// main.dart
//main.dart Trying to dropdown

// main.dart - COMPLETE OPTIMIZED VERSION
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

// Your existing imports
import 'package:islamicquiz/screens/reward_screen.dart';
import 'package:islamicquiz/ifter_time_page.dart';
import 'package:islamicquiz/profile_screen.dart';
import 'package:islamicquiz/qiblah_page.dart';
import 'mcq_page.dart';
import 'islamic_history_page.dart';
import 'prophet_biography_page.dart';
import 'prayer_time_page.dart';
import 'doya_category_page.dart';
import 'nadiyatul_quran.dart';
import 'about_page.dart';
import 'contact_page.dart';
import 'developer_page.dart';
import 'sura_page.dart';
import 'name_of_allah_page.dart';
import 'kalema_page.dart';
import 'utils.dart';
import 'ad_helper.dart';
import 'tasbeeh_page.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'utils/responsive_utils.dart';
import 'utils/in_app_purchase_manager.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/admin_login_screen.dart';
import 'quran_verse_scroller.dart';
import 'support_screen.dart';
import 'word_by_word_quran_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await InAppPurchaseManager().initialize();
    await AdHelper.initialize();
  } catch (e) {
    print('Initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// main.dart এ MyApp widget আপডেট করুন
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        // Handle language loading state - শুধু প্রথম লোডিং এর জন্য
        if (languageProvider.currentLanguage.isEmpty) {
          return _buildLoadingScreen();
        }

        return MaterialApp(
          title: languageProvider.isEnglish
              ? 'Islamic Day - Global Bangladeshi'
              : 'ইসলামিক ডে - বৈশ্বিক বাংলাদেশী',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: _buildTheme(languageProvider.isEnglish, Brightness.light),
          darkTheme: _buildTheme(languageProvider.isEnglish, Brightness.dark),
          home: SplashScreen(),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
              ),
              const SizedBox(height: 20),
              Text(
                'লোড হচ্ছে...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[800],
                  fontFamily: 'HindSiliguri',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme(bool isEnglish, Brightness brightness) {
    return ThemeData(
      primarySwatch: Colors.green,
      brightness: brightness,
      fontFamily: isEnglish ? 'Roboto' : 'HindSiliguri',
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.green[800],
        elevation: 4,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String? selectedCategory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BannerAd? _bannerAd;
  bool _isConnected = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentBottomNavIndex = 0;

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
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _initializeApp();
      }
    });
  }

  void _initializeApp() {
    _checkConnectivity();
    _loadBannerAd();
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

  Future<void> _loadBannerAd() async {
    if (!_isConnected) return;

    try {
      final canShow = await AdHelper.canShowBannerAd();
      if (!canShow) return;

      final mediaQuery = MediaQuery.of(context);
      final bannerWidth = mediaQuery.size.width * 0.9;
      final banner = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        width: bannerWidth.toInt(),
      );

      await banner.load();

      if (mounted) {
        setState(() {
          _bannerAd = banner;
        });
        await AdHelper.recordBannerAdShown();
      }
    } catch (e) {
      print('Banner ad loading error: $e');
    }
  }

  void _refreshHomePage() {
    if (!mounted) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    setState(() {
      selectedCategory = null;
    });

    _animationController.reset();
    _animationController.forward();

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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          backgroundColor: isDarkMode ? Colors.green[900] : Colors.green[800],
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          leading: ResponsiveIconButton(
            icon: Icons.menu,
            iconSize: 28,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            color: Colors.white,
          ),
          actions: [
            ResponsiveIconButton(
              icon: Icons.language,
              iconSize: 28,
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
              iconSize: 28,
              onPressed: () =>
                  themeProvider.toggleTheme(!themeProvider.isDarkMode),
              color: Colors.white,
            ),
          ],
        ),
        drawer: _buildAppDrawer(context, themeProvider),
        body: _buildBody(isDarkMode, tablet, landscape),
        bottomNavigationBar: CustomBottomNavBar(
          isDarkMode: isDarkMode,
          currentIndex: _currentBottomNavIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  Widget _buildBody(bool isDarkMode, bool tablet, bool landscape) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [Colors.green[900]!, Colors.green[800]!]
                    : [Colors.green[50]!, Colors.green[100]!],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: responsiveValue(context, 10),
                    ),
                    child: Column(
                      children: [
                        QuranVerseScroller(
                          isDarkMode: isDarkMode,
                          isTablet: tablet,
                          isLandscape: landscape,
                        ),
                        const ResponsiveSizedBox(height: 8),
                        _buildCategorySelector(isDarkMode),
                        const ResponsiveSizedBox(height: 8),
                        _buildQuickAccess(context, isDarkMode, tablet),
                        const ResponsiveSizedBox(height: 8),
                        _buildAdditionalFeatures(context, isDarkMode, tablet),
                        const ResponsiveSizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (_bannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onBottomNavTap(int index) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    if (index == 0 && _currentBottomNavIndex == 0) {
      _refreshHomePage();
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

  Widget _buildCategorySelector(bool isDarkMode) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Loading state check
    if (languageProvider.isLoading ||
        languageProvider.currentLanguage.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Always use Bengali categories for the dropdown, regardless of language setting
    final categories = _categoriesBn;

    // Define category mappings to quiz IDs/file paths
    final Map<String, String> categoryMappings = {
      // Bengali categories mapping (your existing working ones)
      'ইসলামী প্রাথমিক জ্ঞান': 'islamic_basic_knowledge',
      'কোরআন': 'quran',
      'মহানবী সঃ এর জীবনী': 'prophet_biography',
      'ইবাদত': 'worship',
      'আখিরাত': 'hereafter',
      'বিচার দিবস': 'judgment_day',
      'নারী ও ইসলাম': 'women_in_islam',
      'ইসলামী নৈতিকতা ও আচার': 'islamic_ethics',
      'ধর্মীয় আইন(বিবাহ-বিচ্ছেদ)': 'religious_law',
      'শিষ্টাচার': 'etiquette',
      'দাম্পত্য ও পারিবারিক সম্পর্ক': 'family_relations',
      'হাদিস': 'hadith',
      'নবী-রাসূল': 'prophets',
      'ইসলামের ইতিহাস': 'islamic_history',
    };

    // Validate selectedCategory
    if (selectedCategory != null && !categories.contains(selectedCategory)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedCategory = null;
          });
        }
      });
    }

    return ResponsivePadding(
      horizontal: isTablet(context) ? 16 : 12,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(responsiveValue(context, 10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveText(
                languageProvider.isEnglish
                    ? 'Islamic Knowledge Test: Quiz'
                    : 'ইসলামী মেধাযাচাই: জ্ঞান কুইজ',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: (isDarkMode ? Colors.white : Colors.green[800]!),
                textAlign: TextAlign.center,
              ),
              const ResponsiveSizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveValue(context, 10),
                  vertical: responsiveValue(context, 6),
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[800] : Colors.green[50],
                  borderRadius: BorderRadius.circular(
                    responsiveValue(context, 10),
                  ),
                  border: Border.all(
                    color: Colors.green[600]!,
                    width: responsiveValue(context, 1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    hint: Container(
                      // Container ব্যবহার করুন Row এর পরিবর্তে
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // এটি গুরুত্বপূর্ণ
                        children: [
                          Icon(
                            Icons.search,
                            size: responsiveValue(context, 16),
                            color: isDarkMode
                                ? Colors.white
                                : Colors.green[700],
                          ),
                          SizedBox(width: responsiveValue(context, 6)),
                          Expanded(
                            // Text কে Expanded দিয়ে wrap করুন
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ResponsiveText(
                                languageProvider.isEnglish
                                    ? 'Select Category'
                                    : 'বিষয় বেছে নিন',
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    style: TextStyle(
                      fontSize: responsiveValue(context, 12),
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDarkMode ? Colors.white70 : Colors.green,
                      size: responsiveValue(context, 20),
                    ),
                    isExpanded: true,
                    dropdownColor: isDarkMode
                        ? Colors.green[800]
                        : Colors.white,

                    // ড্রপডাউনের সর্বোচ্চ উচ্চতা সীমিত (স্ক্রিনের ৫০%)
                    menuMaxHeight: MediaQuery.of(context).size.height * 0.5,

                    // ড্রপডাউন নিচের দিকেই খুলবে
                    alignment: Alignment.bottomCenter,

                    // সিলেক্টেড আইটেমের স্টাইল
                    selectedItemBuilder: (BuildContext context) {
                      return categories.map<Widget>((String item) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: responsiveValue(context, 12),
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList();
                    },

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
                            vertical: responsiveValue(context, 8),
                            horizontal: responsiveValue(context, 4),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[300]!.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                  responsiveValue(context, 6),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.bookmark_border,
                                  size: responsiveValue(context, 14),
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.green[700],
                                ),
                              ),
                              SizedBox(width: responsiveValue(context, 10)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: responsiveValue(context, 12),
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: responsiveValue(context, 2),
                                    ),
                                    Text(
                                      'কুইজ: ${categories.indexOf(category) + 1}',
                                      style: TextStyle(
                                        fontSize: responsiveValue(context, 9),
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white60
                                            : Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selectedCategory == category)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: responsiveValue(context, 16),
                                  color: Colors.green,
                                ),
                              SizedBox(width: responsiveValue(context, 4)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const ResponsiveSizedBox(height: 8),
              SizedBox(
                height: responsiveValue(context, 42),
                child: ElevatedButton.icon(
                  onPressed: selectedCategory == null
                      ? null
                      : () {
                          if (mounted) {
                            // Get the correct quiz ID from the mapping
                            final String quizId =
                                categoryMappings[selectedCategory!] ??
                                selectedCategory!;

                            print('Selected Category: $selectedCategory');
                            print('Mapped Quiz ID: $quizId');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MCQPage(
                                  category: selectedCategory!,
                                  quizId: quizId, // Use mapped quiz ID
                                ),
                              ),
                            );
                          }
                        },
                  icon: Icon(
                    Icons.play_circle_filled,
                    size: responsiveValue(context, 18),
                  ),
                  label: ResponsiveText(
                    languageProvider.isEnglish
                        ? 'Start Quiz and Win Rewards'
                        : 'কুইজ শুরু করুন এবং পুরস্কার জিতুন',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        responsiveValue(context, 10),
                      ),
                    ),
                    elevation: 4,
                    shadowColor: Colors.green.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccess(
    BuildContext context,
    bool isDarkMode,
    bool isTablet,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (!mounted) return const SizedBox();

    final primaryColor = isDarkMode ? Colors.green[400]! : Colors.green[700]!;
    final cardColor = isDarkMode ? Colors.green[700]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.green[900]!;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.green[600]!;
    final iconColor = isDarkMode ? Colors.white : Colors.green[700]!;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 10),
        vertical: responsiveValue(context, 8),
      ),
      padding: EdgeInsets.all(responsiveValue(context, 12)),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900]! : Colors.green[100]!,
        borderRadius: BorderRadius.circular(responsiveValue(context, 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.isEnglish ? 'Worship & Prayers' : 'ইবাদাত ও দোয়া',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.green[800]!,
            ),
          ),
          SizedBox(height: responsiveValue(context, 6)),
          GridView.count(
            crossAxisCount: isTablet ? 6 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: responsiveValue(context, 10),
            crossAxisSpacing: responsiveValue(context, 10),
            childAspectRatio: 1.0,
            children: [
              _buildIslamicKnowledgeCard(
                context,
                languageProvider.isEnglish ? 'Prayer Time' : 'নামাজের সময়',
                Icons.access_time_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const PrayerTimePage(),
                isDarkMode,
              ),
              _buildIslamicKnowledgeCard(
                context,
                languageProvider.isEnglish ? 'Sehri & Iftar' : 'সেহেরী ও ইফতার',
                Icons.restaurant,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const IfterTimePage(),
                isDarkMode,
              ),
              _buildIslamicKnowledgeCard(
                context,
                languageProvider.isEnglish ? 'Short Surahs' : 'ছোট সূরা',
                Icons.menu_book_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const SuraPage(),
                isDarkMode,
              ),
              _buildIslamicKnowledgeCard(
                context,
                languageProvider.isEnglish ? 'Prayers' : 'দুআ',
                Icons.lightbulb_outline_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const DoyaCategoryPage(),
                isDarkMode,
              ),
              _buildIslamicKnowledgeCard(
                context,
                languageProvider.isEnglish ? 'Tasbih' : 'তসবিহ',
                Icons.fingerprint_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const TasbeehPage(),
                isDarkMode,
              ),
              _buildIslamicKnowledgeCard(
                context,
                languageProvider.isEnglish ? 'Qibla' : 'কিবলা',
                Icons.explore_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const QiblaPage(),
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalFeatures(
    BuildContext context,
    bool isDarkMode,
    bool isTablet,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (!mounted) return const SizedBox();

    final primaryColor = isDarkMode ? Colors.green[400]! : Colors.green[700]!;
    final accentColor = isDarkMode ? Colors.amber[300]! : Colors.amber[700]!;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.green[50]!;
    final textColor = isDarkMode ? Colors.white : Colors.green[900]!;
    final secondaryTextColor = isDarkMode
        ? Colors.green[200]!
        : Colors.green[600]!;
    final iconColor = isDarkMode ? Colors.green[100]! : Colors.green[700]!;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet
            ? MediaQuery.of(context).size.width * 0.025
            : MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isTablet
              ? MediaQuery.of(context).size.width * 0.018
              : MediaQuery.of(context).size.width * 0.025,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactHeader(
              context,
              isDarkMode,
              primaryColor,
              accentColor,
              textColor,
              isTablet,
              languageProvider,
            ),
            SizedBox(
              height: isTablet
                  ? MediaQuery.of(context).size.height * 0.012
                  : MediaQuery.of(context).size.height * 0.012,
            ),
            _buildCompactCardGrid(
              context,
              iconColor,
              textColor,
              secondaryTextColor,
              isDarkMode,
              isTablet,
              languageProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader(
    BuildContext context,
    bool isDarkMode,
    Color primaryColor,
    Color accentColor,
    Color textColor,
    bool isTablet,
    LanguageProvider languageProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(
            isTablet
                ? MediaQuery.of(context).size.width * 0.018
                : MediaQuery.of(context).size.width * 0.014,
          ),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lightbulb_outline_rounded,
            color: accentColor,
            size: isTablet
                ? MediaQuery.of(context).size.width * 0.035
                : MediaQuery.of(context).size.width * 0.045,
          ),
        ),
        SizedBox(
          width: isTablet
              ? MediaQuery.of(context).size.width * 0.012
              : MediaQuery.of(context).size.width * 0.018,
        ),
        Expanded(
          child: Text(
            languageProvider.isEnglish
                ? 'Islamic Knowledge Bank'
                : 'ইসলামী জ্ঞান ভাণ্ডার',
            style: TextStyle(
              fontSize: isTablet
                  ? MediaQuery.of(context).size.width * 0.022
                  : MediaQuery.of(context).size.width * 0.032,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCardGrid(
    BuildContext context,
    Color iconColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDarkMode,
    bool isTablet,
    LanguageProvider languageProvider,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: isTablet ? screenWidth * 0.018 : screenWidth * 0.018,
      mainAxisSpacing: isTablet ? screenHeight * 0.008 : screenHeight * 0.008,
      childAspectRatio: isTablet ? 3.2 : 1.8,
      children: [
        _buildUltraCompactIslamicCard(
          context,
          languageProvider.isEnglish ? 'Names of Allah' : 'আল্লাহর নামসমূহ',
          Icons.auto_awesome_rounded,
          iconColor,
          isDarkMode ? Colors.blue[900]! : Colors.blue[50]!,
          isDarkMode ? Colors.blue[200]! : Colors.blue[600]!,
          textColor,
          secondaryTextColor,
          const NameOfAllahPage(),
          isDarkMode,
          isTablet,
          description: languageProvider.isEnglish
              ? '99 Sacred Names'
              : '৯৯টি পবিত্র নাম',
        ),
        _buildUltraCompactIslamicCard(
          context,
          languageProvider.isEnglish ? 'Kalimah' : 'কালিমাহ',
          Icons.book_rounded,
          iconColor,
          isDarkMode ? Colors.green[900]! : Colors.green[50]!,
          isDarkMode ? Colors.green[200]! : Colors.green[600]!,
          textColor,
          secondaryTextColor,
          const KalemaPage(),
          isDarkMode,
          isTablet,
          description: languageProvider.isEnglish
              ? 'Six Basic Kalimahs'
              : 'ছয়টি মূল কালিমা',
        ),
        _buildUltraCompactIslamicCard(
          context,
          languageProvider.isEnglish ? 'Quran Learning' : 'কোরআন শিক্ষা',
          Icons.menu_book_rounded,
          iconColor,
          isDarkMode ? Colors.purple[900]! : Colors.purple[50]!,
          isDarkMode ? Colors.purple[200]! : Colors.purple[600]!,
          textColor,
          secondaryTextColor,
          const NadiyatulQuran(),
          isDarkMode,
          isTablet,
          description: languageProvider.isEnglish
              ? 'Nadiyatul Quran'
              : 'নাদিয়াতুল কুরআন',
        ),
        _buildUltraCompactIslamicCard(
          context,
          languageProvider.isEnglish ? 'More' : 'অন্যান্য',
          Icons.more_horiz_rounded,
          iconColor,
          isDarkMode ? Colors.orange[900]! : Colors.orange[50]!,
          isDarkMode ? Colors.orange[200]! : Colors.orange[600]!,
          textColor,
          secondaryTextColor,
          null,
          isDarkMode,
          isTablet,
          description: languageProvider.isEnglish
              ? 'Prophet Biography'
              : 'মুহাম্মাদ (সঃ) জীবনী',
          onTap: () {
            _showMoreOptions(context);
          },
        ),
      ],
    );
  }

  Widget _buildUltraCompactIslamicCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
    Color borderColor,
    Color textColor,
    Color secondaryTextColor,
    Widget? page,
    bool isDarkMode,
    bool isTablet, {
    String? description,
    Function()? onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: isTablet ? 0.8 : 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: borderColor.withOpacity(isTablet ? 0.2 : 0.3),
          width: isTablet ? 0.8 : 1.2,
        ),
      ),
      color: backgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap:
            onTap ??
            () {
              if (page != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              }
            },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? screenWidth * 0.02 : screenWidth * 0.025,
            vertical: isTablet ? screenHeight * 0.008 : screenHeight * 0.015,
          ),
          constraints: BoxConstraints(
            minHeight: isTablet ? screenHeight * 0.05 : screenHeight * 0.075,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(
                  isTablet ? screenWidth * 0.01 : screenWidth * 0.018,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withOpacity(isTablet ? 0.15 : 0.2),
                    width: isTablet ? 0.8 : 1.2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: isTablet ? screenWidth * 0.028 : screenWidth * 0.04,
                  color: iconColor,
                ),
              ),
              SizedBox(
                width: isTablet ? screenWidth * 0.018 : screenWidth * 0.02,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet
                            ? screenWidth * 0.02
                            : screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null) ...[
                      SizedBox(
                        height: isTablet
                            ? screenHeight * 0.002
                            : screenHeight * 0.004,
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isTablet
                              ? screenWidth * 0.015
                              : screenWidth * 0.026,
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: isTablet ? screenWidth * 0.02 : screenWidth * 0.03,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  languageProvider.isEnglish
                      ? 'More Islamic Knowledge'
                      : 'আরও ইসলামী জ্ঞান',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 8),
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
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, size: 20, color: Colors.green[700]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey[500],
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  Widget _buildIslamicKnowledgeCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Widget? page,
    bool isDarkMode, {
    String? url,
    String? description,
    Function()? onTap,
    String? semanticsLabel,
  }) {
    final tablet = isTablet(context);

    return Container(
      width: tablet
          ? responsiveValue(context, 120)
          : responsiveValue(context, 170),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsiveValue(context, 16)),
        ),
        color: cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(responsiveValue(context, 16)),
          onTap:
              onTap ??
              () async {
                if (url != null) {
                  try {
                    final Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: ResponsiveText(
                            'লিঙ্ক খোলা যায়নি',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                  }
                } else if (page != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                }
              },
          child: Container(
            padding: EdgeInsets.all(responsiveValue(context, 6)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(responsiveValue(context, 6)),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: responsiveValue(context, 20),
                    color: iconColor,
                  ),
                ),
                ResponsiveSizedBox(height: 6),
                ResponsiveText(
                  title,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null) ...[
                  ResponsiveSizedBox(height: 2),
                  ResponsiveText(
                    description,
                    fontSize: 9,
                    color: secondaryTextColor,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context, ThemeProvider themeProvider) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final tablet = isTablet(context);

    return Drawer(
      width: tablet ? MediaQuery.of(context).size.width * 0.4 : null,
      backgroundColor: isDarkMode ? Colors.green[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: responsiveValue(context, tablet ? 120 : 140),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.green[900]!, Colors.green[700]!]
                    : [Colors.green[600]!, Colors.green[400]!],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: responsiveValue(context, tablet ? 25 : 30),
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu_book,
                    size: responsiveValue(context, tablet ? 30 : 34),
                    color: Colors.green[800],
                  ),
                ),
                ResponsiveSizedBox(height: 10),
                ResponsiveText(
                  languageProvider.isEnglish
                      ? 'Islamic Day - Global Bangladeshi'
                      : 'ইসলামিক ডে - বৈশ্বিক বাংলাদেশী',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                if (!tablet)
                  ResponsiveText(
                    languageProvider.isEnglish
                        ? 'For the Global Bangladeshi Community'
                        : 'বিশ্বব্যাপী বাংলাদেশী কমিউনিটির জন্য',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.book,
            languageProvider.isEnglish ? 'Prayers' : 'দুআ',
            const DoyaCategoryPage(),
          ),
          _buildDrawerItem(
            context,
            Icons.mosque,
            languageProvider.isEnglish ? 'Prayer Time' : 'নামাজের সময়',
            const PrayerTimePage(),
          ),
          _buildDrawerItem(
            context,
            Icons.mosque,
            languageProvider.isEnglish ? 'Nearby Mosques' : 'নিকটবর্তী মসজিদ',
            null,
            url: 'https://www.google.com/maps/search/?api=1&query=মসজিদ',
          ),
          _buildDrawerLanguageItem(context, languageProvider),
          _buildDrawerItem(
            context,
            Icons.volunteer_activism,
            languageProvider.isEnglish ? 'Support Us' : 'সাপোর্ট করুন',
            const SupportScreen(),
          ),
          _buildDrawerItem(
            context,
            Icons.info,
            languageProvider.isEnglish ? 'About Us' : 'আমাদের সম্বন্ধে',
            const AboutPage(),
          ),
          _buildDrawerItem(
            context,
            Icons.developer_mode,
            languageProvider.isEnglish ? 'Developer' : 'ডেভেলপার',
            DeveloperPage(),
          ),
          _buildDrawerItem(
            context,
            Icons.contact_page,
            languageProvider.isEnglish ? 'Contact' : 'যোগাযোগ',
            const ContactPage(),
          ),
          _buildDrawerItem(
            context,
            Icons.person,
            languageProvider.isEnglish ? 'Rewards' : 'পুরস্কার',
            RewardScreen(),
          ),
          _buildDrawerItem(
            context,
            Icons.admin_panel_settings,
            languageProvider.isEnglish ? 'Admin Panel' : 'এডমিন প্যানেল',
            const AdminLoginScreen(),
          ),
          _buildDrawerItem(
            context,
            Icons.privacy_tip,
            'Privacy Policy',
            null,
            url: 'https://sites.google.com/view/islamicquize/home',
          ),
          Divider(
            color: Colors.green.shade200,
            indent: responsiveValue(context, 16),
            endIndent: responsiveValue(context, 16),
          ),
          ResponsivePadding(
            horizontal: 12,
            child: Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  color: Colors.green[700],
                  size: responsiveValue(context, 24),
                ),
                ResponsiveSizedBox(width: 10),
                ResponsiveText(
                  languageProvider.isEnglish ? 'Dark Mode' : 'ডার্ক মোড',
                  fontSize: 16,
                ),
                const Spacer(),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                  activeColor: Colors.green[700],
                  activeTrackColor: Colors.green[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget? page, {
    String? url,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.green[700],
        size: responsiveValue(context, 24),
      ),
      title: ResponsiveText(
        title,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: responsiveValue(context, 16),
        color: Colors.green[700],
      ),
      onTap: () async {
        Navigator.pop(context);
        if (url != null) {
          try {
            final Uri uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: ResponsiveText(
                    'Could not open link',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              );
            }
          }
        } else if (page != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }

  Widget _buildDrawerLanguageItem(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isDark ? Colors.white70 : Colors.green[700],
        size: responsiveValue(context, 24),
      ),
      title: ResponsiveText(
        languageProvider.isEnglish ? 'Language' : 'ভাষা',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Switch(
        value: languageProvider.isEnglish,
        onChanged: (value) => languageProvider.toggleLanguage(),
        activeColor: Colors.green[700],
        activeTrackColor: Colors.green[300],
      ),
    );
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
