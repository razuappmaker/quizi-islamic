// Main.dart with Responsive 100 %

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:islamicquiz/qiblah_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';

import 'auto_image_slider.dart';
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
import 'ad_helper.dart'; // ✅ AdHelper
import 'tasbeeh_page.dart';
import 'screens/splash_screen.dart';
import '../widgets/responsive_widgets.dart';
import '../utils/size_config.dart';
import 'providers/theme_provider.dart'; // নতুন লাইন যোগ করুন

/// -------------------- Theme Provider --------------------
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

/// -------------------- Main --------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdHelper.initialize(); // ✅ Google Mobile Ads init
  runApp(
    ChangeNotifierProvider(create: (_) => ThemeProvider(), child: MyApp()),
  );
}

// main.dart এ MyApp ক্লাস
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ThemeProvider এখন context থেকে access করা যাবে
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ইসলামিক কুইজ অনলাইন',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        fontFamily: 'HindSiliguri',
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(backgroundColor: Colors.green[900]),
        fontFamily: 'HindSiliguri',
      ),
      home: Builder(
        builder: (context) {
          // SizeConfig init করুন
          SizeConfig.init(context);
          return SplashScreen();
        },
      ),
    );
  }
}

/// -------------------- Home Page --------------------
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCategory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BannerAd? _bannerAd; // ✅ Banner Ad variable

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
    //WidgetsBinding.instance.addPostFrameCallback((_) {
    // if (mounted) {
    //  SizeConfig.init(context);
    //}
    //});
    _loadBannerAd(); // ✅ HomePage লোড হলে ব্যানার অ্যাড লোড হবে
    AdHelper.loadInterstitialAd(); // ✅ Interstitial আগে থেকে লোড রাখা হবে
  }

  /// ✅ Banner Ad লোড ফাংশন
  void _loadBannerAd() async {
    final canShow = await AdHelper.canShowBannerAd();
    if (!canShow) return;

    final banner = await AdHelper.createAdaptiveBannerAdWithFallback(context);
    await banner.load();
    setState(() {
      _bannerAd = banner;
    });
    await AdHelper.recordBannerAdShown();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  //----------------------------------
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmed = await showExitConfirmationDialog(context);
        if (exitConfirmed) {
          return true;
        }
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('ইসলামিক কুইজ অনলাইন'),
          centerTitle: true,
          backgroundColor: isDarkMode ? Colors.green[900] : Colors.green[800],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6, color: Colors.white),
              onPressed: () {
                themeProvider.toggleTheme(!themeProvider.isDarkMode);
              },
            ),
          ],
        ),
        drawer: _buildDrawer(themeProvider),
        body: Container(
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
              /// ---------------- Marquee ----------------
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: SizeConfig.proportionalHeight(6),
                  horizontal: SizeConfig.proportionalWidth(12),
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.green[800]!.withOpacity(0.8)
                      : Colors.green.shade100.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(
                    SizeConfig.proportionalWidth(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                height: SizeConfig.proportionalHeight(36),
                child: Center(
                  child: Marquee(
                    text:
                        "📖 ইসলামই একমাত্র সত্য ধর্ম (আলে ইমরান: ১৯) 📖 আল্লাহকে ভয় করো ও সত্যবাদীদের সাথে থাকো (তাওবা: ১১৯) 📖 নামাজ অশ্লীলতা ও মন্দ কাজ থেকে বিরত রাখে (আনকাবুত: ৪৫) 📖 হে আমার প্রতিপালক! আমার জ্ঞানকে বৃদ্ধি করে দিন (ত্ব-হা: ১১৪) 📖 সৎকাজে প্রতিযোগিতা করো (বাকারাহ: ১৪৮) 📖 আল্লাহর স্মরণে হৃদয় শান্তি পায় (রা‘দ: ২৮)",
                    style: TextStyle(
                      fontSize: SizeConfig.proportionalFontSize(14),
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.green[900],
                    ),
                    scrollAxis: Axis.horizontal,
                    blankSpace: 40.0,
                    velocity: 40.0,
                    pauseAfterRound: Duration(seconds: 1),
                    startPadding: 10.0,
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      /// ---------------- Image Slider ----------------
                      Container(
                        height: SizeConfig.proportionalHeight(140),
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.proportionalWidth(16),
                          vertical: SizeConfig.proportionalHeight(8),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            SizeConfig.proportionalWidth(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            SizeConfig.proportionalWidth(12),
                          ),
                          child: AutoImageSlider(
                            imageUrls: [
                              'assets/images/slider1.png',
                              'assets/images/slider2.png',
                              'assets/images/slider3.png',
                              'assets/images/slider4.png',
                              'assets/images/slider5.png',
                            ],
                          ),
                        ),
                      ),

                      /// ---------------- Category Selector ----------------
                      _buildCategorySelector(isDarkMode),

                      SizedBox(height: 16),

                      /// ---------------- Quick Access ----------------
                      _buildQuickAccess(isDarkMode),

                      SizedBox(height: 16),

                      /// ---------------- Additional Features ----------------
                      _buildAdditionalFeatures(isDarkMode),

                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            else
              const SizedBox.shrink(),

            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  /// ---------------- Category Selector ----------------
  Widget _buildCategorySelector(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.proportionalWidth(16),
      ),
      padding: EdgeInsets.all(SizeConfig.proportionalWidth(12)),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.green[900] : Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.proportionalWidth(12)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'বিষয় নির্বাচন করুন',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.proportionalWidth(10),
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.green[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(
                SizeConfig.proportionalWidth(10),
              ),
              border: Border.all(
                color: isDarkMode ? Colors.green[600]! : Colors.green.shade300,
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                hint: Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.proportionalWidth(8),
                  ),
                  child: Text(
                    'বিষয় বেছে নিন',
                    style: TextStyle(
                      fontSize: SizeConfig.proportionalFontSize(14),
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: SizeConfig.proportionalFontSize(14),
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.green,
                  size: 24,
                ),
                isExpanded: true,
                dropdownColor: isDarkMode ? Colors.green[800] : Colors.white,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.proportionalHeight(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bookmark,
                            size: SizeConfig.proportionalFontSize(16),
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: SizeConfig.proportionalFontSize(13),
                              ),
                              overflow: TextOverflow.ellipsis,
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
          SizedBox(height: 12),
          SizedBox(
            height: SizeConfig.proportionalHeight(44),
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
                Icons.play_arrow,
                size: SizeConfig.proportionalFontSize(20),
              ),
              label: Text(
                'কুইজ শুরু করুন',
                style: TextStyle(
                  fontSize: SizeConfig.proportionalFontSize(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SizeConfig.proportionalWidth(10),
                  ),
                ),
                elevation: 3,
                shadowColor: Colors.green.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- Quick Access ----------------
  Widget _buildQuickAccess(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ইবাদাত ও দোয়া',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.green[800],
            ),
          ),
          SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: SizeConfig.proportionalHeight(12),
            crossAxisSpacing: SizeConfig.proportionalWidth(12),
            childAspectRatio: 1.2,
            children: [
              _buildFeatureCard(
                'নামাজের সময়',
                Icons.access_alarm,
                PrayerTimePage(),
              ),
              _buildFeatureCard('১৬টি ছোট সূরা', Icons.menu_book, SuraPage()),
              _buildFeatureCard('দৈনন্দিন দোয়া', Icons.lightbulb, DoyaPage()),
              _buildFeatureCard(
                'ডিজিটাল তসবিহ',
                Icons.fingerprint,
                TasbeehPage(),
              ),
              _buildFeatureCard('কেবলা', Icons.explore, QiblaPage()),
              _buildFeatureCard('অন্যান্য', Icons.picture_as_pdf, NamajAmol()),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- Additional Features ----------------
  Widget _buildAdditionalFeatures(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.green[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ইসলামী জ্ঞান',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.green[800],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSmallButton('আল্লাহর নামসমূহ', NameOfAllahPage()),
              ),
              SizedBox(width: 10),
              Expanded(child: _buildSmallButton('কালিমাহ', KalemaPage())),
            ],
          ),
          SizedBox(height: 10),
          _buildPrivacyPolicyButton(),
        ],
      ),
    );
  }

  /// ---------------- Feature Card ----------------
  // Feature Card কে রেসপনসিভ করুন
  Widget _buildFeatureCard(String title, IconData icon, Widget page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.proportionalWidth(12)),
      ),
      color: isDark ? Colors.green[800] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeConfig.proportionalWidth(12)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              SizeConfig.proportionalWidth(12),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.green[800]!, Colors.green[700]!]
                  : [Colors.white, Colors.green[50]!],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.proportionalWidth(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(SizeConfig.proportionalWidth(6)),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.green[900] : Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: SizeConfig.proportionalFontSize(20),
                    color: isDark ? Colors.white : Colors.green[700],
                  ),
                ),
                SizedBox(height: SizeConfig.proportionalHeight(8)),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: SizeConfig.proportionalFontSize(12),
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- Small Button ----------------
  Widget _buildSmallButton(String title, Widget page) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// ---------------- Privacy Policy Button ----------------
  Widget _buildPrivacyPolicyButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: () async {
          final Uri uri = Uri.parse(
            'https://sites.google.com/view/islamicquize/home',
          );
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open Privacy Policy')),
            );
          }
        },
        //icon: Icon(Icons.lock, size: 18),
        icon: Icon(Icons.lock, size: 18),
        label: Text(
          //'Privacy Policy',
          'Privacy Policy',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// ---------------- Drawer ----------------
  Widget _buildDrawer(ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: isDarkMode ? Colors.green[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green[800],
              image: DecorationImage(
                image: AssetImage('assets/images/mosque_background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(
                    Icons.menu_book,
                    size: 36,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "ইসলামিক কুইজ অনলাইন",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "সঠিক জ্ঞানের সাথী",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.book, 'দৈনন্দিন দোয়া', DoyaPage()),
          _buildDrawerItem(Icons.mosque, 'আজকের নামাজের সময়', PrayerTimePage()),
          _buildDrawerItem(
            Icons.mosque,
            'নিকটবর্তী মসজিদ',
            null,
            url: "https://www.google.com/maps/search/?api=1&query=মসজিদ",
          ),
          _buildDrawerItem(Icons.info, 'আমাদের সম্বন্ধে', AboutPage()),

          _buildDrawerItem(Icons.developer_mode, 'ডেভেলপার', DeveloperPage()),

          _buildDrawerItem(
            Icons.contact_page,
            'আমাদের সাথে যোগাযোগ',
            ContactPage(),
          ),
          _buildDrawerItem(
            Icons.privacy_tip,
            'Privacy Policy',
            null,
            url: 'https://sites.google.com/view/islamicquize/home',
          ),
          Divider(color: Colors.green.shade200, indent: 16, endIndent: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.brightness_6, color: Colors.green[700]),
                SizedBox(width: 12),
                Text("ডার্ক মোড", style: TextStyle(fontSize: 16)),
                Spacer(),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- Drawer Item ----------------
  Widget _buildDrawerItem(
    IconData icon,
    String title,
    Widget? page, {
    String? url,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
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
              const SnackBar(content: Text('Could not open link')),
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

  /// ---------------- Bottom Navigation ----------------
  Widget _buildBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.green[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home, 'হোম', 0),
              _buildBottomNavItem(Icons.star, 'রেটিং', 1),
              _buildBottomNavItem(Icons.apps, 'অন্যান্য', 2),
              _buildBottomNavItem(Icons.share, 'শেয়ার', 3),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- Bottom Navigation Item Widget ----------------
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onBottomNavItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.green[200] : Colors.green[700],
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.green[200] : Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- Bottom Navigation Tap Handler ----------------
  void _onBottomNavItemTapped(int index) {
    switch (index) {
      case 0:
        // হোমে থাকলে কিছু করার দরকার নাই
        break;
      case 1:
        launchUrl(
          Uri.parse(
            'https://play.google.com/store/apps/details?id=com.example.quizapp',
          ),
        );
        break;
      case 2:
        launchUrl(
          Uri.parse(
            'https://play.google.com/store/apps/dev?id=YOUR_DEVELOPER_ID',
          ),
        );
        break;
      case 3:
        Share.share(
          'ইসলামিক কুইজ অনলাইন অ্যাপটি ডাউনলোড করুন:\nhttps://play.google.com/store/apps/details?id=com.example.quizapp',
        );
        break;
    }
  }
}
