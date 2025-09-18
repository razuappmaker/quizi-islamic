// main.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:islamicquiz/qiblah_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'mcq_page.dart';
import 'prayer_time_page.dart';
import 'doya_page.dart';
import 'namaj_amol.dart';
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
import 'widgets/image_slider.dart';
import 'widgets/bottom_nav_bar.dart';

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
            textTheme: TextTheme(
              bodyLarge: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              bodyMedium: const TextStyle(fontSize: 14),
              headlineSmall: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
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
            appBarTheme: AppBarTheme(backgroundColor: Colors.green[900]),
            textTheme: TextTheme(
              bodyLarge: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              bodyMedium: const TextStyle(fontSize: 14),
              headlineSmall: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
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
                            // পুরানো _buildImageSlider কে নতুন ImageSlider widget দিয়ে প্রতিস্থাপন করুন
                            ImageSlider(
                              isDarkMode: isDarkMode,
                              isTablet: tablet,
                              isLandscape: landscape,
                            ),
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
        /*bottomNavigationBar: CustomBottomNavBar(
          isDarkMode: isDarkMode,
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() {
              _currentBottomNavIndex = index;
            });
            CustomBottomNavBar.handleBottomNavItemTap(context, index);
          },
        ),*/
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
                'কুইজ বিষয় নির্বাচন',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: (isDarkMode ? Colors.white : Colors.green[800]!),
                textAlign: TextAlign.center,
                semanticsLabel: 'কুইজ বিষয় নির্বাচন',
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
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.green[700],
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
                              color: Colors.green[700],
                            ),
                            SizedBox(width: responsiveValue(context, 6)),
                            Expanded(
                              child: ResponsiveText(
                                category,
                                fontSize: 12,
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
                              builder: (context) =>
                                  MCQPage(category: selectedCategory!),
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

  Widget _buildQuickAccess(
    BuildContext context,
    bool isDarkMode,
    bool isTablet,
  ) {
    final primaryColor = isDarkMode ? Colors.green[400]! : Colors.green[700]!;
    final cardColor = isDarkMode ? Colors.green[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.green[900]!;
    final secondaryTextColor = isDarkMode
        ? Colors.green[200]!
        : Colors.green[600]!;
    final iconColor = isDarkMode ? Colors.green[100]! : Colors.green[700]!;
    final mediaQuery = MediaQuery.of(context); // ✅ define it here

    return ResponsivePadding(
      horizontal: responsiveValue(context, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'ইবাদাত ও দোয়া',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: (isDarkMode ? Colors.white : Colors.green[800]!),
            semanticsLabel: 'ইবাদাত ও দোয়া',
          ),
          ResponsiveSizedBox(height: 6),
          GridView.count(
            crossAxisCount: isTablet ? 6 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: responsiveValue(context, 10),
            crossAxisSpacing: responsiveValue(context, 10),
            childAspectRatio: 1.0,
            // Square shape
            children: [
              _buildIslamicKnowledgeCard(
                context,
                'নামাজের সময়',
                Icons.access_time_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const PrayerTimePage(),
                isDarkMode,
                semanticsLabel: 'নামাজের সময়',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'কুরআনের সূরা',
                Icons.menu_book_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const SuraPage(),
                isDarkMode,
                semanticsLabel: 'কুরআনের সূরা',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'দৈনন্দিন দোয়া',
                Icons.lightbulb_outline_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const DoyaPage(),
                isDarkMode,
                semanticsLabel: 'দৈনন্দিন দোয়া',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'তসবিহ',
                Icons.fingerprint_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const TasbeehPage(),
                isDarkMode,
                semanticsLabel: 'তসবিহ',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'কিবলা',
                Icons.explore_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const QiblaPage(),
                isDarkMode,
                semanticsLabel: 'কিবলা',
              ),
              _buildIslamicKnowledgeCard(
                context,
                'নামাজ শিক্ষা',
                Icons.picture_as_pdf_rounded,
                iconColor,
                cardColor,
                textColor,
                secondaryTextColor,
                const NamajAmol(),
                isDarkMode,
                semanticsLabel: 'নামাজ শিক্ষা',
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
    final cardColor = isDarkMode ? Colors.green[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.green[900]!;
    final secondaryTextColor = isDarkMode
        ? Colors.green[200]!
        : Colors.green[600]!;
    final iconColor = isDarkMode ? Colors.green[100]! : Colors.green[700]!;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, isTablet ? 16 : 8),
        vertical: responsiveValue(context, isTablet ? 16 : 10),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(responsiveValue(context, 20)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.green.withOpacity(0.1),
            blurRadius: responsiveValue(context, 10),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(responsiveValue(context, isTablet ? 16 : 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveValue(context, 6),
                vertical: responsiveValue(context, 4),
              ),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  responsiveValue(context, 12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: accentColor,
                    size: responsiveValue(context, 24),
                  ),
                  ResponsiveSizedBox(width: responsiveValue(context, 8)),
                  Expanded(
                    child: ResponsiveText(
                      'ইসলামী জ্ঞান ভান্ডার',
                      fontSize: responsiveValue(context, 14),
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      semanticsLabel: 'ইসলামী জ্ঞান ভান্ডার',
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveValue(context, 8),
                      vertical: responsiveValue(context, 2),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        responsiveValue(context, 8),
                      ),
                      border: Border.all(
                        color: Colors.green[700]!,
                        width: responsiveValue(context, 1.5),
                      ),
                    ),
                    child: ResponsiveText(
                      'নতুন',
                      fontSize: responsiveValue(context, 10),
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700]!,
                      semanticsLabel: 'নতুন',
                    ),
                  ),
                ],
              ),
            ),
            ResponsiveSizedBox(height: responsiveValue(context, 12)),
            Stack(
              children: [
                Container(
                  height: responsiveValue(context, 150),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    controller: ScrollController(),
                    children: [
                      ResponsiveSizedBox(width: responsiveValue(context, 4)),
                      // আল্লাহর নাম কার্ড
                      _buildIslamicKnowledgeCard(
                        context,
                        'আল্লাহর নামসমূহ',
                        Icons.auto_awesome_rounded,
                        iconColor,
                        cardColor,
                        textColor,
                        isDarkMode ? Colors.white : Colors.green[600]!,
                        // হালকা সাদা
                        const NameOfAllahPage(),
                        isDarkMode,
                        description: 'আল্লাহর ৯৯টি পবিত্র নাম জানুন ও শিখুন',
                        semanticsLabel: 'আল্লাহর নামসমূহ',
                      ),
                      ResponsiveSizedBox(width: responsiveValue(context, 12)),
                      // কালিমাহ কার্ড
                      _buildIslamicKnowledgeCard(
                        context,
                        'কালিমাহ',
                        Icons.book_rounded,
                        iconColor,
                        cardColor,
                        textColor,
                        isDarkMode ? Colors.white : Colors.green[600]!,
                        // হালকা সাদা
                        const KalemaPage(),
                        isDarkMode,
                        description: 'ইসলামের মূল ভিত্তি ছয় কালিমা',
                        semanticsLabel: 'কালিমাহ',
                      ),
                      ResponsiveSizedBox(width: responsiveValue(context, 12)),
                      _buildIslamicKnowledgeCard(
                        context,
                        'কুরআন শিক্ষা',
                        Icons.menu_book_rounded,
                        iconColor,
                        cardColor,
                        textColor,
                        secondaryTextColor,
                        null,
                        isDarkMode,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: responsiveValue(context, 20),
                                  ),
                                  ResponsiveSizedBox(
                                    width: responsiveValue(context, 8),
                                  ),
                                  ResponsiveText(
                                    'কুরআন শিক্ষা বিভাগ শীঘ্রই আসছে',
                                    fontSize: responsiveValue(context, 14),
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              backgroundColor: primaryColor,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        description: 'কুরআন তেলাওয়াত ও তাফসীর শিখুন',
                        semanticsLabel: 'কুরআন শিক্ষা',
                      ),
                      ResponsiveSizedBox(width: responsiveValue(context, 4)),
                    ],
                  ),
                ),
                Positioned(
                  right: -responsiveValue(context, 8),
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.centerRight,
                        widthFactor: 0.5,
                        child: Container(
                          width: responsiveValue(context, 28),
                          height: responsiveValue(context, 28),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                            size: responsiveValue(context, 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ResponsiveSizedBox(height: responsiveValue(context, 8)),
            Center(
              child: Container(
                width: responsiveValue(context, 40),
                height: responsiveValue(context, 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(
                    responsiveValue(context, 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          : responsiveValue(context, 170), // 140 Defaul value
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
                    MaterialPageRoute(builder: (context) => page),
                  );
                }
              },
          child: Container(
            padding: EdgeInsets.all(responsiveValue(context, 10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(responsiveValue(context, 8)),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: responsiveValue(context, 24),
                    color: iconColor,
                  ),
                ),
                ResponsiveSizedBox(height: 8),
                ResponsiveText(
                  title,
                  fontSize: 12,
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
                    fontSize: 10,
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
            'দৈনন্দিন দোয়া',
            const DoyaPage(),
            semanticsLabel: 'দৈনন্দিন দোয়া',
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
            'দৈনন্দিন দোয়া',
            const DoyaPage(),
            semanticsLabel: 'দৈনন্দিন দোয়া',
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
        color: Colors.green[700],
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

  /*Widget _buildNavigationRail(ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;

    return NavigationRail(
      backgroundColor: isDarkMode ? Colors.green[900] : Colors.white,
      selectedIndex: _currentBottomNavIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _currentBottomNavIndex = index;
        });
        CustomBottomNavBar.handleBottomNavItemTap(context, index);
      },
      labelType: NavigationRailLabelType.selected,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home),
          selectedIcon: Icon(Icons.home_filled),
          label: Text('হোম'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.star),
          selectedIcon: Icon(Icons.star_rate),
          label: Text('রেটিং'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.apps),
          selectedIcon: Icon(Icons.apps),
          label: Text('অন্যান্য'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.share),
          selectedIcon: Icon(Icons.share),
          label: Text('শেয়ার'),
        ),
      ],
    );
  }*/

  /// Snackbar helper
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
