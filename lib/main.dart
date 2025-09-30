// main.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

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
import 'utils/responsive_utils.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/admin_login_screen.dart';
import 'quran_verse_scroller.dart';
//import 'widgets/image_slider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AdHelper.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'ইসলামিক কুইজ অনলাইন',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            primarySwatch: Colors.green,
            brightness: Brightness.light,
            fontFamily: 'HindSiliguri',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              bodyMedium: TextStyle(fontSize: 14),
              headlineSmall: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.green,
            brightness: Brightness.dark,
            fontFamily: 'HindSiliguri',
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: const AppBarTheme(backgroundColor: Colors.green),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              bodyMedium: TextStyle(fontSize: 14),
              headlineSmall: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BannerAd? _bannerAd;
  bool _isConnected = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentBottomNavIndex = 0; // নতুন ভেরিয়েবল যোগ করুন

  final List<String> categories = [
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

  @override
  void initState() {
    super.initState();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkConnectivity();
        _loadBannerAd();
        AdHelper.loadInterstitialAd();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _loadBannerAd() async {
    if (!_isConnected) return;
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
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tablet = isTablet(context);
    final landscape = isLandscape(context);
    final mediaQuery = MediaQuery.of(context);

    return WillPopScope(
      onWillPop: () async => await showExitConfirmationDialog(context),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const ResponsiveText(
            'ইসলামিক কুইজ অনলাইন',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            semanticsLabel: 'ইসলামিক কুইজ অনলাইন',
          ),
          centerTitle: true,
          backgroundColor: isDarkMode ? Colors.green[900] : Colors.green[800],
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          leading: tablet
              ? ResponsiveIconButton(
                  // ট্যাবলেটেও Drawer আইকন দেখাবে
                  icon: Icons.menu,
                  iconSize: 28,
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  color: Colors.white,
                  semanticsLabel: 'মেনু খুলুন',
                )
              : ResponsiveIconButton(
                  icon: Icons.menu,
                  iconSize: 28,
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  color: Colors.white,
                  semanticsLabel: 'মেনু খুলুন',
                ),
          actions: [
            ResponsiveIconButton(
              icon: isDarkMode ? Icons.brightness_7 : Icons.brightness_4,
              iconSize: 28,
              onPressed: () =>
                  themeProvider.toggleTheme(!themeProvider.isDarkMode),
              color: Colors.white,
              semanticsLabel: isDarkMode ? 'লাইট মোড' : 'ডার্ক মোড',
            ),
          ],
        ),
        drawer: _buildAppDrawer(context, themeProvider),

        // ট্যাব
        body: Row(
          children: [
            //if (isTablet(context)) _buildNavigationRail(themeProvider),
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
                            // ImageSlider widget স্লাইডার চাইলে কমেন্ট আউট
                            /*ImageSlider(
                              isDarkMode: isDarkMode,
                              isTablet: tablet,
                              isLandscape: landscape,
                            ),*/
                            ResponsiveSizedBox(height: 8),
                            _buildCategorySelector(isDarkMode),
                            ResponsiveSizedBox(height: 8),
                            _buildQuickAccess(context, isDarkMode, tablet),
                            ResponsiveSizedBox(height: 8),
                            _buildAdditionalFeatures(
                              context,
                              isDarkMode,
                              tablet,
                            ),
                            ResponsiveSizedBox(height: 8),
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
        ),
        bottomNavigationBar: CustomBottomNavBar(
          isDarkMode: isDarkMode,
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() {
              _currentBottomNavIndex = index;
            });

            CustomBottomNavBar.handleBottomNavItemTap(context, index).then((_) {
              // কাজ শেষে স্বয়ংক্রিয়ভাবে হোমে ফিরে আসা (শুধুমাত্র হোম ছাড়া অন্য আইটেমের জন্য)
              if (mounted && index != 0) {
                setState(() {
                  _currentBottomNavIndex = 0;
                });
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDarkMode) {
    return ResponsivePadding(
      horizontal: isTablet(context) ? 16 : 12,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(responsiveValue(context, 10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveText(
                'ইসলামী মেধাযাচাই: জ্ঞান কুইজ',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: (isDarkMode ? Colors.white : Colors.green[800]!),
                textAlign: TextAlign.center,
                semanticsLabel: 'ইসলামী মেধাযাচাই: জ্ঞান কুইজ',
              ),
              ResponsiveSizedBox(height: 6),
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
                    hint: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: responsiveValue(context, 16),
                          color: isDarkMode ? Colors.white : Colors.green[700],
                        ),
                        SizedBox(width: responsiveValue(context, 6)),
                        ResponsiveText(
                          'বিষয় বেছে নিন',
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          semanticsLabel: 'বিষয় বেছে নিন',
                        ),
                      ],
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
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: responsiveValue(context, 14),
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors
                                        .white // ডার্ক মোডে সাদা
                                  : Colors.green[700], // লাইট মোডে সবুজ
                            ),
                            SizedBox(width: responsiveValue(context, 6)),
                            Expanded(
                              child: ResponsiveText(
                                category,
                                fontSize: 12,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors
                                          .white // ডার্ক মোডে সাদা
                                    : Colors.black, // লাইট মোডে কালো
                                overflow: TextOverflow.ellipsis,
                                semanticsLabel: category,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ResponsiveSizedBox(height: 8),
              Container(
                height: responsiveValue(context, 42),
                child: ElevatedButton.icon(
                  onPressed: selectedCategory == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MCQPage(
                                category: selectedCategory!,
                                quizId: selectedCategory!, // 🔥 FIXED
                              ),
                            ),
                          );
                        },
                  icon: Icon(
                    Icons.play_circle_filled,
                    size: responsiveValue(context, 18),
                  ),
                  label: ResponsiveText(
                    'কুইজ শুরু করুন',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    semanticsLabel: 'কুইজ শুরু করুন',
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

  //===============
  Widget _buildQuickAccess(
    BuildContext context,
    bool isDarkMode,
    bool isTablet,
  ) {
    final primaryColor = isDarkMode ? Colors.green[400]! : Colors.green[700]!;
    final cardColor = isDarkMode
        ? Colors.green[700]!
        : Colors.white; // ডার্ক মুডে green[700]
    final textColor = isDarkMode
        ? Colors.white
        : Colors.green[900]!; // ডার্ক মুডে সাদা
    final secondaryTextColor = isDarkMode
        ? Colors.white70
        : Colors.green[600]!; // ডার্ক মুডে সাদা
    final iconColor = isDarkMode
        ? Colors.white
        : Colors.green[700]!; // ডার্ক মুডে সাদা
    final backgroundColor = isDarkMode
        ? Colors.grey[900]!
        : Colors.green[100]!; // কন্টেইনার ব্যাকগ্রাউন্ড

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 10),
        vertical: responsiveValue(context, 8),
      ),
      padding: EdgeInsets.all(responsiveValue(context, 12)),
      decoration: BoxDecoration(
        color: backgroundColor, // ডার্ক মুডে grey[900], লাইট মুডে green[50]
        borderRadius: BorderRadius.circular(responsiveValue(context, 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ইবাদাত ও দোয়া',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Colors.green[800]!, // ডার্ক মুডে সাদা
            ),
            semanticsLabel: 'ইবাদাত ও দোয়া',
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
                'নামাজের সময়',
                Icons.access_time_rounded,
                iconColor,
                // ডার্ক মুডে সাদা
                cardColor,
                // ডার্ক মুডে green[700]
                textColor,
                // ডার্ক মুডে সাদা
                secondaryTextColor,
                // ডার্ক মুডে সাদা
                const PrayerTimePage(),
                isDarkMode,
                semanticsLabel: 'নামাজের সময়',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'সেহেরী ও ইফতার',
                Icons.restaurant,
                iconColor,
                // ডার্ক মুডে সাদা
                cardColor,
                // ডার্ক মুডে green[700]
                textColor,
                // ডার্ক মুডে সাদা
                secondaryTextColor,
                // ডার্ক মুডে সাদা
                const IfterTimePage(),
                isDarkMode,
                semanticsLabel: 'সেহেরী ও ইফতার',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'ছোট সূরা',
                Icons.menu_book_rounded,
                iconColor,
                // ডার্ক মুডে সাদা
                cardColor,
                // ডার্ক মুডে green[700]
                textColor,
                // ডার্ক মুডে সাদা
                secondaryTextColor,
                // डार्क মুডে সাদা
                const SuraPage(),
                isDarkMode,
                semanticsLabel: 'ছোট সুরা',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'দুআ',
                Icons.lightbulb_outline_rounded,
                iconColor,
                // ডার্ক মুডে সাদা
                cardColor,
                // ডার্ক মুডে green[700]
                textColor,
                // ডার্ক মুডে সাদা
                secondaryTextColor,
                // ডার্ক মুডে সাদা
                const DoyaCategoryPage(),
                isDarkMode,
                semanticsLabel: 'দুআ',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'তসবিহ',
                Icons.fingerprint_rounded,
                iconColor,
                // ডার্ক মুডে সাদা
                cardColor,
                // ডার্ক মুডে green[700]
                textColor,
                // ডার্ক মুডে সাদা
                secondaryTextColor,
                // ডার্ক মুডে সাদা
                const TasbeehPage(),
                isDarkMode,
                semanticsLabel: 'তসবিহ',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'কিবলা',
                Icons.explore_rounded,
                iconColor,
                // ডার্ক মুডে সাদা
                cardColor,
                // ডার্ক মুডে green[700]
                textColor,
                // ডার্ক মুডে সাদা
                secondaryTextColor,
                // ডার্ক মুডে সাদা
                const QiblaPage(),
                isDarkMode,
                semanticsLabel: 'কিবলা',
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
            // হেডার সেকশন
            _buildCompactHeader(
              context,
              isDarkMode,
              primaryColor,
              accentColor,
              textColor,
              isTablet,
            ),
            SizedBox(
              height: isTablet
                  ? MediaQuery.of(context).size.height * 0.012
                  : MediaQuery.of(context).size.height * 0.012,
            ),

            // ৪টি চ্যাপ্টা কার্ড গ্রিড
            _buildCompactCardGrid(
              context,
              iconColor,
              textColor,
              secondaryTextColor,
              isDarkMode,
              isTablet,
            ),
          ],
        ),
      ),
    );
  }

  // কমপ্যাক্ট হেডার
  Widget _buildCompactHeader(
    BuildContext context,
    bool isDarkMode,
    Color primaryColor,
    Color accentColor,
    Color textColor,
    bool isTablet,
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
            'ইসলামী জ্ঞান ভাণ্ডার',
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

  // কমপ্যাক্ট কার্ড গ্রিড
  Widget _buildCompactCardGrid(
    BuildContext context,
    Color iconColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDarkMode,
    bool isTablet,
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
      // ট্যাবলেটে কার্ডগুলো আরও চ্যাপ্টা করা হয়েছে
      children: [
        _buildUltraCompactIslamicCard(
          context,
          'আল্লাহর নামসমূহ',
          Icons.auto_awesome_rounded,
          iconColor,
          isDarkMode ? Colors.blue[900]! : Colors.blue[50]!,
          isDarkMode ? Colors.blue[200]! : Colors.blue[600]!,
          textColor,
          secondaryTextColor,
          const NameOfAllahPage(),
          isDarkMode,
          isTablet,
          description: '৯৯টি পবিত্র নাম',
        ),

        _buildUltraCompactIslamicCard(
          context,
          'কালিমাহ',
          Icons.book_rounded,
          iconColor,
          isDarkMode ? Colors.green[900]! : Colors.green[50]!,
          isDarkMode ? Colors.green[200]! : Colors.green[600]!,
          textColor,
          secondaryTextColor,
          const KalemaPage(),
          isDarkMode,
          isTablet,
          description: 'ছয়টি মূল কালিমা',
        ),

        _buildUltraCompactIslamicCard(
          context,
          'কোরআন শিক্ষা',
          Icons.menu_book_rounded,
          iconColor,
          isDarkMode ? Colors.purple[900]! : Colors.purple[50]!,
          isDarkMode ? Colors.purple[200]! : Colors.purple[600]!,
          textColor,
          secondaryTextColor,
          const NadiyatulQuran(),
          isDarkMode,
          isTablet,
          description: 'নাদিয়াতুল কুরআন',
        ),

        _buildUltraCompactIslamicCard(
          context,
          'অন্যান্য',
          Icons.more_horiz_rounded,
          iconColor,
          isDarkMode ? Colors.orange[900]! : Colors.orange[50]!,
          isDarkMode ? Colors.orange[200]! : Colors.orange[600]!,
          textColor,
          secondaryTextColor,
          null,
          isDarkMode,
          isTablet,
          description: 'মুহাম্মাদ (সঃ) জীবনী',
          onTap: () {
            _showMoreOptions(context);
          },
        ),
      ],
    );
  }

  // আল্ট্রা কমপ্যাক্ট ইসলামী কার্ড (ট্যাবলেটের জন্য অপ্টিমাইজড)
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
              if (page != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              }
            },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? screenWidth * 0.02 : screenWidth * 0.025,
            vertical: isTablet
                ? screenHeight * 0.008
                : screenHeight *
                      0.015, // ভার্টিক্যাল প্যাডিং কমিয়ে চ্যাপ্টা করা
          ),
          constraints: BoxConstraints(
            minHeight: isTablet
                ? screenHeight * 0.05
                : screenHeight *
                      0.075, // ট্যাবলেটে উচ্চতা আরও কমিয়ে চ্যাপ্টা করা হয়েছে
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // আইকন - ট্যাবলেটে ছোট
              Container(
                padding: EdgeInsets.all(
                  isTablet ? screenWidth * 0.01 : screenWidth * 0.018,
                ),
                // প্যাডিং কমিয়ে চ্যাপ্টা করা
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withOpacity(isTablet ? 0.15 : 0.2),
                    width: isTablet
                        ? 0.8
                        : 1.2, // বর্ডার থিকনেস কমিয়ে চ্যাপ্টা করা
                  ),
                ),
                child: Icon(
                  icon,
                  size: isTablet ? screenWidth * 0.028 : screenWidth * 0.04,
                  // আইকন সাইজ সামান্য কমিয়ে চ্যাপ্টা করা
                  color: iconColor,
                ),
              ),

              SizedBox(
                width: isTablet ? screenWidth * 0.018 : screenWidth * 0.02,
              ),

              // কন্টেন্ট - ট্যাবলেটে কমপ্যাক্ট
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // শিরোনাম
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet
                            ? screenWidth * 0.02
                            : screenWidth *
                                  0.03, // ফন্ট সাইজ সামান্য কমিয়ে চ্যাপ্টা করা
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
                      ), // স্পেস কমিয়ে চ্যাপ্টা করা
                      // বর্ণনা
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isTablet
                              ? screenWidth * 0.015
                              : screenWidth * 0.026,
                          // ফন্ট সাইজ সামান্য কমিয়ে চ্যাপ্টা করা
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // অ্যারো আইকন - ট্যাবলেটে ছোট
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: isTablet ? screenWidth * 0.02 : screenWidth * 0.03,
                // আইকন সাইজ সামান্য কমিয়ে চ্যাপ্টা করা
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // অন্যান্য options ডায়ালগ
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // ✅ নিচে কন্টেন্ট ঢুকে যাবে না
      builder: (context) {
        return SafeArea(
          // ✅ বটম শীট কনটেন্ট SafeArea এর মধ্যে
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
                  'আরও ইসলামী জ্ঞান',
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
                  'ইসলামের ইতিহাস',
                  onTap: () {
                    Navigator.pop(context); // বটম শীট বন্ধ করুন
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SafeArea(child: const IslamicHistoryPage()),
                      ),
                    );
                  },
                ),
                _buildCompactOptionItem(
                  context,
                  Icons.person,
                  'হজরত মুহাম্মাদ (সা.)-এর জীবনী',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SafeArea(child: const ProphetBiographyPage()),
                      ),
                    );
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

  // কমপ্যাক্ট option আইটেম (আপডেটেড ভার্সন)
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

  // ইসলামিক নলেজ কার্ড
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
                  final Uri uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
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
                } else if (page != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SafeArea(child: page),
                    ),
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
                  semanticsLabel: semanticsLabel,
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
                    semanticsLabel: description,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;
    final mediaQuery = MediaQuery.of(context);

    return Drawer(
      backgroundColor: isDarkMode ? Colors.green[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 140 * mediaQuery.textScaleFactor,
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
                  radius: 30 * mediaQuery.textScaleFactor,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu_book,
                    size: 34 * mediaQuery.textScaleFactor,
                    color: Colors.green[800],
                  ),
                ),
                ResponsiveSizedBox(height: 10),
                const ResponsiveText(
                  'ইসলামিক কুইজ অনলাইন',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  semanticsLabel: 'ইসলামিক কুইজ অনলাইন',
                ),
                const ResponsiveText(
                  'ইসলামের জ্ঞান অর্জন করুন',
                  fontSize: 12,
                  color: Colors.white70,
                  semanticsLabel: 'ইসলামের জ্ঞান অর্জন করুন',
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.book,
            'দুআ',
            const DoyaCategoryPage(),
            semanticsLabel: 'দুআ',
          ),
          _buildDrawerItem(
            context,
            Icons.mosque,
            'নামাজের সময়',
            const PrayerTimePage(),
            semanticsLabel: 'নামাজের সময়',
          ),
          _buildDrawerItem(
            context,
            Icons.mosque,
            'নিকটবর্তী মসজিদ',
            null,
            url: 'https://www.google.com/maps/search/?api=1&query=মসজিদ',
            semanticsLabel: 'নিকটবর্তী মসজিদ',
          ),
          _buildDrawerItem(
            context,
            Icons.info,
            'আমাদের সম্বন্ধে',
            const AboutPage(),
            semanticsLabel: 'আমাদের সম্বন্ধে',
          ),
          _buildDrawerItem(
            context,
            Icons.developer_mode,
            'ডেভেলপার',
            DeveloperPage(),
            semanticsLabel: 'ডেভেলপার',
          ),
          _buildDrawerItem(
            context,
            Icons.contact_page,
            'যোগাযোগ',
            const ContactPage(),
            semanticsLabel: 'যোগাযোগ',
          ),
          _buildDrawerItem(
            context,
            Icons.contact_page,
            'প্রফাইল',
            const ProfileScreen(),
            semanticsLabel: 'যোগাযোগ',
          ),
          _buildDrawerItem(
            context,
            Icons.admin_panel_settings,
            'এডমিন প্যানেল',
            const AdminLoginScreen(),
            // 🔥 সরাসরি AdminRechargeScreen এর বদলে AdminLoginScreen
            semanticsLabel: 'এডমিন প্যানেল',
          ),
          _buildDrawerItem(
            context,
            Icons.privacy_tip,
            'Privacy Policy',
            null,
            url: 'https://sites.google.com/view/islamicquize/home',
            semanticsLabel: 'Privacy Policy',
          ),

          Divider(
            color: Colors.green.shade200,
            indent: 16 * mediaQuery.textScaleFactor,
            endIndent: 16 * mediaQuery.textScaleFactor,
          ),
          ResponsivePadding(
            horizontal: 12,
            child: Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  color: Colors.green[700],
                  size: 24 * mediaQuery.textScaleFactor,
                ),
                ResponsiveSizedBox(width: 10),
                const ResponsiveText(
                  'ডার্ক মোড',
                  fontSize: 16,
                  semanticsLabel: 'ডার্ক মোড',
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

  //--------------
  Widget _buildAppDrawer(BuildContext context, ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;
    final tablet = isTablet(context);

    return Drawer(
      width: tablet
          ? MediaQuery.of(context).size.width * 0.4
          : null, // ট্যাবলেটে ড্রয়ার width কমিয়ে দিন
      backgroundColor: isDarkMode ? Colors.green[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: responsiveValue(context, tablet ? 120 : 140),
            // ট্যাবলেটে header height কমিয়ে দিন
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
                  // ট্যাবলেটে avatar size কমিয়ে দিন
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu_book,
                    size: responsiveValue(context, tablet ? 30 : 34),
                    // ট্যাবলেটে icon size কমিয়ে দিন
                    color: Colors.green[800],
                  ),
                ),
                ResponsiveSizedBox(height: 10),
                const ResponsiveText(
                  'ইসলামিক কুইজ অনলাইন',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  semanticsLabel: 'ইসলামিক কুইজ অনলাইন',
                ),
                if (!tablet) // শুধুমাত্র মোবাইলে ছোট টেক্সট দেখাবে
                  const ResponsiveText(
                    'ইসলামের জ্ঞান অর্জন করুন',
                    fontSize: 12,
                    color: Colors.white70,
                    semanticsLabel: 'ইসলামের জ্ঞান অর্জন করুন',
                  ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.book,
            'দুআ',
            const DoyaCategoryPage(),
            semanticsLabel: 'দুআ',
          ),
          _buildDrawerItem(
            context,
            Icons.mosque,
            'নামাজের সময়',
            const PrayerTimePage(),
            semanticsLabel: 'নামাজের সময়',
          ),
          _buildDrawerItem(
            context,
            Icons.mosque,
            'নিকটবর্তী মসজিদ',
            null,
            url: 'https://www.google.com/maps/search/?api=1&query=মসজিদ',
            semanticsLabel: 'নিকটবর্তী মসজিদ',
          ),
          _buildDrawerItem(
            context,
            Icons.info,
            'আমাদের সম্বন্ধে',
            const AboutPage(),
            semanticsLabel: 'আমাদের সম্বন্ধে',
          ),
          _buildDrawerItem(
            context,
            Icons.developer_mode,
            'ডেভেলপার',
            DeveloperPage(),
            semanticsLabel: 'ডেভেলপার',
          ),
          _buildDrawerItem(
            context,
            Icons.contact_page,
            'যোগাযোগ',
            const ContactPage(),
            semanticsLabel: 'যোগাযোগ',
          ),
          // 🔥 প্রোফাইল আইটেম যোগ করুন
          _buildDrawerItem(
            context,
            Icons.person,
            'আমার প্রোফাইল',
            ProfileScreen(),
            semanticsLabel: 'প্রোফাইল পেজ',
          ),
          _buildDrawerItem(
            context,
            Icons.admin_panel_settings,
            'এডমিন প্যানেল',
            const AdminLoginScreen(),
            // 🔥 সরাসরি AdminRechargeScreen এর বদলে AdminLoginScreen
            semanticsLabel: 'এডমিন প্যানেল',
          ),

          _buildDrawerItem(
            context,
            Icons.privacy_tip,
            'Privacy Policy',
            null,
            url: 'https://sites.google.com/view/islamicquize/home',
            semanticsLabel: 'Privacy Policy',
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
                const ResponsiveText(
                  'ডার্ক মোড',
                  fontSize: 16,
                  semanticsLabel: 'ডার্ক মোড',
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
    String? semanticsLabel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.green[700],
        //color: Colors.green[700],
        size: responsiveValue(context, 24),
      ),
      title: ResponsiveText(
        title,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
        semanticsLabel: semanticsLabel,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: responsiveValue(context, 16),
        color: Colors.green[700],
      ),
      onTap: () async {
        Navigator.pop(context);
        if (url != null) {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
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
        } else if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }

  /// Snackbar helper
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
