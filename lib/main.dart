import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:islamicquiz/qiblah_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
import '../widgets/responsive_widgets.dart';
import '../utils/size_config.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdHelper.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Builder(
        builder: (context) {
          SizeConfig.init(context);
          return const MyApp();
        },
      ),
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
              bodyLarge: TextStyle(
                fontSize: SizeConfig.proportionalFontSize(16),
                fontWeight: FontWeight.w500,
              ),
              bodyMedium: TextStyle(
                fontSize: SizeConfig.proportionalFontSize(14),
              ),
              headlineSmall: TextStyle(
                fontSize: SizeConfig.proportionalFontSize(20),
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SizeConfig.proportionalWidth(12),
                  ),
                ),
                elevation: 3,
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.proportionalHeight(12),
                  horizontal: SizeConfig.proportionalWidth(16),
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
              bodyLarge: TextStyle(
                fontSize: SizeConfig.proportionalFontSize(16),
                fontWeight: FontWeight.w500,
              ),
              bodyMedium: TextStyle(
                fontSize: SizeConfig.proportionalFontSize(14),
              ),
              headlineSmall: TextStyle(
                fontSize: SizeConfig.proportionalFontSize(20),
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SizeConfig.proportionalWidth(12),
                  ),
                ),
                elevation: 3,
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.proportionalHeight(12),
                  horizontal: SizeConfig.proportionalWidth(16),
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

    final bannerWidth = SizeConfig.screenWidth! * 0.9;
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
          leading: SizeConfig.isTablet
              ? null
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
        drawer: SizeConfig.isTablet ? null : _buildDrawer(themeProvider),
        body: Row(
          children: [
            if (SizeConfig.isTablet) _buildNavigationRail(themeProvider),
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
                          bottom: SizeConfig.proportionalHeight(10),
                        ),
                        child: Column(
                          children: [
                            _buildImageSlider(isDarkMode),
                            ResponsiveSizedBox(height: 8),
                            _buildCategorySelector(isDarkMode),
                            ResponsiveSizedBox(height: 8),
                            _buildQuickAccess(isDarkMode),
                            ResponsiveSizedBox(height: 8),
                            _buildAdditionalFeatures(isDarkMode),
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
        bottomNavigationBar: _buildBottomNavBar(context, isDarkMode),
      ),
    );
  }

  Widget _buildImageSlider(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.proportionalWidth(8),
        vertical: SizeConfig.proportionalHeight(8),
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          height: SizeConfig.isTablet
              ? SizeConfig.proportionalHeight(200) // Reduced height
              : SizeConfig.proportionalHeight(150),
          // Reduced height
          aspectRatio: SizeConfig.isLandscape ? 21 / 9 : 16 / 9,
          viewportFraction: SizeConfig.isTablet ? 0.7 : 0.92,
          initialPage: 0,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.easeInOut,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
        items:
            [
              'assets/images/slider1.png',
              'assets/images/slider2.png',
              'assets/images/slider3.png',
              'assets/images/slider4.png',
              'assets/images/slider5.png',
            ].map((imagePath) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: SizeConfig.proportionalWidth(2),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    SizeConfig.proportionalWidth(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    SizeConfig.proportionalWidth(16),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: SizeConfig.proportionalWidth(40),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDarkMode) {
    return ResponsivePadding(
      horizontal: SizeConfig.isTablet ? 16 : 12,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.proportionalWidth(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveText(
                'কুইজ বিষয় নির্বাচন',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.green[800],
                textAlign: TextAlign.center,
                semanticsLabel: 'কুইজ বিষয় নির্বাচন',
              ),
              ResponsiveSizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.proportionalWidth(10),
                  vertical: SizeConfig.proportionalHeight(6),
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[800] : Colors.green[50],
                  borderRadius: BorderRadius.circular(
                    SizeConfig.proportionalWidth(10),
                  ),
                  border: Border.all(
                    color: Colors.green[600]!,
                    width: SizeConfig.proportionalWidth(1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    hint: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: SizeConfig.proportionalWidth(16),
                          color: Colors.green[700],
                        ),
                        SizedBox(width: SizeConfig.proportionalWidth(6)),
                        ResponsiveText(
                          'বিষয় বেছে নিন',
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          semanticsLabel: 'বিষয় বেছে নিন',
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: SizeConfig.proportionalFontSize(12),
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.green[700],
                      size: SizeConfig.proportionalWidth(20),
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
                              size: SizeConfig.proportionalWidth(14),
                              color: Colors.green[700],
                            ),
                            SizedBox(width: SizeConfig.proportionalWidth(6)),
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
                height: SizeConfig.proportionalHeight(42),
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
                    size: SizeConfig.proportionalWidth(18),
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
                        SizeConfig.proportionalWidth(10),
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

  Widget _buildQuickAccess(bool isDarkMode) {
    final primaryColor = isDarkMode ? Colors.green[400]! : Colors.green[700]!;
    final cardColor = isDarkMode ? Colors.green[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.green[900]!;
    final secondaryTextColor = isDarkMode
        ? Colors.green[200]!
        : Colors.green[600]!;
    final iconColor = isDarkMode ? Colors.green[100]! : Colors.green[700]!;

    return ResponsivePadding(
      horizontal: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'ইবাদাত ও দোয়া',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.green[800],
            semanticsLabel: 'ইবাদাত ও দোয়া',
          ),
          ResponsiveSizedBox(height: 6),
          GridView.count(
            crossAxisCount: SizeConfig.isTablet ? 6 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: SizeConfig.proportionalHeight(10),
            crossAxisSpacing: SizeConfig.proportionalWidth(10),
            childAspectRatio: 1.0,
            // Changed to make square shape
            children: [
              _buildIslamicKnowledgeCard(
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

  Widget _buildAdditionalFeatures(bool isDarkMode) {
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
        horizontal: SizeConfig.proportionalWidth(SizeConfig.isTablet ? 16 : 8),
        vertical: SizeConfig.proportionalHeight(SizeConfig.isTablet ? 16 : 10),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SizeConfig.proportionalWidth(20)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          SizeConfig.proportionalWidth(SizeConfig.isTablet ? 16 : 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.proportionalWidth(6),
                vertical: SizeConfig.proportionalHeight(4),
              ),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  SizeConfig.proportionalWidth(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: accentColor,
                    size: SizeConfig.proportionalWidth(24),
                  ),
                  SizedBox(width: SizeConfig.proportionalWidth(8)),
                  Expanded(
                    child: ResponsiveText(
                      'ইসলামী জ্ঞান ভান্ডার',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      semanticsLabel: 'ইসলামী জ্ঞান ভান্ডার',
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.proportionalWidth(8),
                      vertical: SizeConfig.proportionalHeight(2),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        SizeConfig.proportionalWidth(8),
                      ),
                      border: Border.all(
                        color: Colors.green[700]!,
                        width: SizeConfig.proportionalWidth(1.5),
                      ),
                    ),
                    child: ResponsiveText(
                      'নতুন',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700]!,
                      semanticsLabel: 'নতুন',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.proportionalHeight(12)),
            Stack(
              children: [
                Container(
                  height: SizeConfig.proportionalHeight(150),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    controller: ScrollController(),
                    children: [
                      SizedBox(width: SizeConfig.proportionalWidth(4)),
                      _buildIslamicKnowledgeCard(
                        'আল্লাহর নামসমূহ',
                        Icons.auto_awesome_rounded,
                        iconColor,
                        cardColor,
                        textColor,
                        secondaryTextColor,
                        const NameOfAllahPage(),
                        isDarkMode,
                        description: 'আল্লাহর ৯৯টি পবিত্র নাম জানুন ও শিখুন',
                        semanticsLabel: 'আল্লাহর নামসমূহ',
                      ),
                      SizedBox(width: SizeConfig.proportionalWidth(12)),
                      _buildIslamicKnowledgeCard(
                        'কালিমাহ',
                        Icons.book_rounded,
                        iconColor,
                        cardColor,
                        textColor,
                        secondaryTextColor,
                        const KalemaPage(),
                        isDarkMode,
                        description: 'ইসলামের মূল ভিত্তি ছয় কালিমা',
                        semanticsLabel: 'কালিমাহ',
                      ),
                      SizedBox(width: SizeConfig.proportionalWidth(12)),
                      _buildIslamicKnowledgeCard(
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
                                    size: SizeConfig.proportionalWidth(20),
                                  ),
                                  SizedBox(
                                    width: SizeConfig.proportionalWidth(8),
                                  ),
                                  Text(
                                    'কুরআন শিক্ষা বিভাগ শীঘ্রই আসছে',
                                    style: TextStyle(
                                      fontSize: SizeConfig.proportionalFontSize(
                                        14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: primaryColor,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        description: 'কুরআন তেলাওয়াত ও তাফসীর শিখুন',
                        semanticsLabel: 'কুরআন শিক্ষা',
                      ),
                      SizedBox(width: SizeConfig.proportionalWidth(4)),
                    ],
                  ),
                ),
                Positioned(
                  right: SizeConfig.proportionalWidth(-8),
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.centerRight,
                        widthFactor: 0.5,
                        child: Container(
                          width: SizeConfig.proportionalWidth(28),
                          height: SizeConfig.proportionalWidth(28),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                            size: SizeConfig.proportionalWidth(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.proportionalHeight(8)),
            Center(
              child: Container(
                width: SizeConfig.proportionalWidth(40),
                height: SizeConfig.proportionalHeight(4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(
                    SizeConfig.proportionalWidth(2),
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
    return Container(
      width: SizeConfig.isTablet
          ? SizeConfig.proportionalWidth(120)
          : SizeConfig.proportionalWidth(150),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            SizeConfig.proportionalWidth(16),
          ), // Rounded corners
        ),
        color: cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(SizeConfig.proportionalWidth(16)),
          // Rounded corners
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
                        content: Text(
                          'লিঙ্ক খোলা যায়নি',
                          style: TextStyle(
                            fontSize: SizeConfig.proportionalFontSize(14),
                          ),
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
            padding: EdgeInsets.all(SizeConfig.proportionalWidth(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(SizeConfig.proportionalWidth(8)),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: SizeConfig.proportionalWidth(24),
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

    return Drawer(
      backgroundColor: isDarkMode ? Colors.green[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: SizeConfig.proportionalHeight(140),
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
                  radius: SizeConfig.proportionalWidth(30),
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu_book,
                    size: SizeConfig.proportionalWidth(34),
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
            Icons.book,
            'দৈনন্দিন দোয়া',
            const DoyaPage(),
            semanticsLabel: 'দৈনন্দিন দোয়া',
          ),
          _buildDrawerItem(
            Icons.mosque,
            'নামাজের সময়',
            const PrayerTimePage(),
            semanticsLabel: 'নামাজের সময়',
          ),
          _buildDrawerItem(
            Icons.mosque,
            'নিকটবর্তী মসজিদ',
            null,
            url: 'https://www.google.com/maps/search/?api=1&query=মসজিদ',
            semanticsLabel: 'নিকটবর্তী মসজিদ',
          ),
          _buildDrawerItem(
            Icons.info,
            'আমাদের সম্বন্ধে',
            const AboutPage(),
            semanticsLabel: 'আমাদের সম্বন্ধে',
          ),
          _buildDrawerItem(
            Icons.developer_mode,
            'ডেভেলপার',
            DeveloperPage(),
            semanticsLabel: 'ডেভেলপার',
          ),
          _buildDrawerItem(
            Icons.contact_page,
            'যোগাযোগ',
            const ContactPage(),
            semanticsLabel: 'যোগাযোগ',
          ),
          _buildDrawerItem(
            Icons.privacy_tip,
            'Privacy Policy',
            null,
            url: 'https://sites.google.com/view/islamicquize/home',
            semanticsLabel: 'Privacy Policy',
          ),
          Divider(
            color: Colors.green.shade200,
            indent: SizeConfig.proportionalWidth(16),
            endIndent: SizeConfig.proportionalWidth(16),
          ),
          ResponsivePadding(
            horizontal: 12,
            child: Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  color: Colors.green[700],
                  size: SizeConfig.proportionalWidth(24),
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

  Widget _buildNavigationRail(ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;

    return NavigationRail(
      backgroundColor: isDarkMode ? Colors.green[900] : Colors.white,
      selectedIndex: 0,
      onDestinationSelected: (index) async {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DoyaPage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrayerTimePage()),
            );
            break;
          case 2:
            final Uri uri = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=মসজিদ',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeveloperPage()),
            );
            break;
          case 5:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactPage()),
            );
            break;
          case 6:
            final Uri uri = Uri.parse(
              'https://sites.google.com/view/islamicquize/home',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            break;
        }
      },
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.book, size: SizeConfig.proportionalWidth(24)),
          selectedIcon: Icon(
            Icons.book,
            color: Colors.green[700],
            size: SizeConfig.proportionalWidth(24),
          ),
          label: ResponsiveText(
            'দৈনন্দিন দোয়া',
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black87,
            semanticsLabel: 'দৈনন্দিন দোয়া',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.mosque, size: SizeConfig.proportionalWidth(24)),
          selectedIcon: Icon(
            Icons.mosque,
            color: Colors.green[700],
            size: SizeConfig.proportionalWidth(24),
          ),
          label: ResponsiveText(
            'নামাজের সময়',
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black87,
            semanticsLabel: 'নামাজের সময়',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.mosque, size: SizeConfig.proportionalWidth(24)),
          selectedIcon: Icon(
            Icons.mosque,
            color: Colors.green[700],
            size: SizeConfig.proportionalWidth(24),
          ),
          label: ResponsiveText(
            'نিকটবর্তী মসজিদ',
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black87,
            semanticsLabel: 'নিকটবর্তী মসজিদ',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.info, size: SizeConfig.proportionalWidth(24)),
          selectedIcon: Icon(
            Icons.info,
            color: Colors.green[700],
            size: SizeConfig.proportionalWidth(24),
          ),
          label: ResponsiveText(
            'আমাদের সম্বন্ধে',
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black87,
            semanticsLabel: 'আমাদের সম্বন্ধে',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(
            Icons.developer_mode,
            size: SizeConfig.proportionalWidth(24),
          ),
          selectedIcon: Icon(
            Icons.developer_mode,
            color: Colors.green[700],
            size: SizeConfig.proportionalWidth(24),
          ),
          label: ResponsiveText(
            'ডেভেলপার',
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black87,
            semanticsLabel: 'ডেভেলপар',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(
            Icons.contact_page,
            size: SizeConfig.proportionalWidth(24),
          ),
          selectedIcon: Icon(
            Icons.contact_page,
            color: Colors.green[700],
            size: SizeConfig.proportionalWidth(24),
          ),
          label: ResponsiveText(
            'যোগাযোগ',
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black87,
            semanticsLabel: 'যোগাযোগ',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.privacy_tip, size: SizeConfig.proportionalWidth(24)),
          selectedIcon: Icon(
            Icons.privacy_tip,
            color: Colors.green[700],
            size: SizeConfig.proportionalWidth(24),
          ),
          label: ResponsiveText(
            'Privacy Policy',
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black87,
            semanticsLabel: 'Privacy Policy',
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
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
        size: SizeConfig.proportionalWidth(24),
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
        size: SizeConfig.proportionalWidth(16),
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
                content: Text(
                  'Could not open link',
                  style: TextStyle(
                    fontSize: SizeConfig.proportionalFontSize(14),
                  ),
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

  Widget _buildBottomNavBar(BuildContext context, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.proportionalWidth(16),
        vertical: SizeConfig.proportionalHeight(8),
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.green[900] : Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.proportionalWidth(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ResponsivePadding(
        horizontal: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              Icons.home,
              'হোম',
              0,
              isDarkMode,
              isSelected: true,
              semanticsLabel: 'হোম',
            ),
            _buildBottomNavItem(
              Icons.star,
              'রেটিং',
              1,
              isDarkMode,
              semanticsLabel: 'রেটিং',
            ),
            _buildBottomNavItem(
              Icons.apps,
              'অন্যান্য',
              2,
              isDarkMode,
              semanticsLabel: 'অন্যান্য',
            ),
            _buildBottomNavItem(
              Icons.share,
              'শেয়ার',
              3,
              isDarkMode,
              semanticsLabel: 'শেয়ার',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    int index,
    bool isDarkMode, {
    bool isSelected = false,
    String? semanticsLabel,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.proportionalHeight(6),
        horizontal: SizeConfig.proportionalWidth(12),
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.green[700]!.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(SizeConfig.proportionalWidth(12)),
      ),
      child: InkWell(
        onTap: () => _onBottomNavItemTapped(index),
        child: Semantics(
          label: semanticsLabel,
          button: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: SizeConfig.proportionalWidth(16),
                backgroundColor: isSelected
                    ? Colors.green[700]
                    : (isDarkMode ? Colors.green[800] : Colors.green[200]),
                child: Icon(
                  icon,
                  size: SizeConfig.proportionalWidth(20),
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.green[700]),
                ),
              ),
              ResponsiveSizedBox(height: 4),
              ResponsiveText(
                label,
                fontSize: 11,
                color: isSelected
                    ? Colors.green[700]
                    : (isDarkMode ? Colors.white : Colors.green[700]),
                semanticsLabel: label,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBottomNavItemTapped(int index) async {
    switch (index) {
      case 0:
        break;
      case 1:
        final Uri uri = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.example.quizapp',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 2:
        final Uri uri = Uri.parse(
          'https://play.google.com/store/apps/dev?id=YOUR_DEVELOPER_ID',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 3:
        await Share.share(
          'ইসলামিক কুইজ অনলাইন অ্যাপটি ডাউনলোড করুন:\nhttps://play.google.com/store/apps/details?id=com.example.quizapp',
        );
        break;
    }
  }
}
