import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      home: SplashScreen(),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmed = await showExitConfirmationDialog(context);
        if (exitConfirmed) {
          await AdHelper.showInterstitialAd(adContext: "Exit App");
          return true;
        }
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('ইসলামিক কুইজ অনলাইন'),
          centerTitle: true,
          backgroundColor: Colors.green[800],
          elevation: 0,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// ---------------- Marquee ----------------
                Container(
                  color: Colors.green.shade100.withOpacity(0.7),
                  height: 40,
                  child: Center(
                    child: Marquee(
                      text:
                          "📖 ইসলামই একমাত্র সত্য ধর্ম (আলে ইমরান: ১৯) 📖 আল্লাহকে ভয় করো ও সত্যবাদীদের সাথে থাকো (তাওবা: ১১৯) 📖 নামাজ অশ্লীলতা ও মন্দ কাজ থেকে বিরত রাখে (আনকাবুত: ৪৫) 📖 হে আমার প্রতিপালক! আমার জ্ঞানকে বৃদ্ধি করে দিন (ত্ব-হা: ১১৪) 📖 সৎকাজে প্রতিযোগিতা করো (বাকারাহ: ১৪৮) 📖 আল্লাহর স্মরণে হৃদয় শান্তি পায় (রা‘দ: ২৮)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      scrollAxis: Axis.horizontal,
                      blankSpace: 50.0,
                      velocity: 50.0,
                      pauseAfterRound: Duration(seconds: 1),
                      startPadding: 10.0,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// ---------------- Image Slider ----------------
                Container(
                  height: 180,
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
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

                const SizedBox(height: 20),

                /// ---------------- Category Selector ----------------
                _buildCategorySelector(isDarkMode),

                const SizedBox(height: 20),

                /// ---------------- Quick Access ----------------
                _buildQuickAccess(isDarkMode),

                const SizedBox(height: 20),

                /// ---------------- Additional Features ----------------
                _buildAdditionalFeatures(isDarkMode),

                const SizedBox(height: 20),
              ],
            ),
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
              const SizedBox.shrink(), //  কোনো ফাঁকা জায়গা থাকবে না

            _buildBottomNavBar(),
            // তোমার বটম নেভিগেশন
          ],
        ),
      ),
    );
  }

  /// ---------------- Category Selector ----------------
  Widget _buildCategorySelector(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.green[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'বিষয় নির্বাচন করুন',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.green[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 1.2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  hint: Text(
                    'বিষয় বেছে নিন',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.green),
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
                      child: Row(
                        children: [
                          Icon(Icons.bookmark, size: 18, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: selectedCategory == null
                    ? null
                    : () async {
                        await AdHelper.showInterstitialAd(
                          adContext: "Start Quiz",
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MCQPage(category: selectedCategory!),
                          ),
                        );
                      },
                child: Text(
                  'কুইজ শুরু করুন',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
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
            'দ্রুত অ্যাক্সেস',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.green[800],
            ),
          ),
          SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildFeatureCard('১৬টি ছোট সূরা', Icons.book, SuraPage()),
              _buildFeatureCard('দৈনন্দিন দোয়া', Icons.lightbulb, DoyaPage()),
              _buildFeatureCard(
                'নামাজের সময়',
                Icons.access_time,
                PrayerTimePage(),
              ),
              _buildFeatureCard('সালাতের জিকির', Icons.psychology, NamajAmol()),
              _buildFeatureCard(
                'ডিজিটাল তসবিহ',
                Icons.psychology,
                TasbeehPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- Additional Features ----------------
  Widget _buildAdditionalFeatures(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'অন্যান্য ফিচার',
            style: TextStyle(
              fontSize: 18,
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
              SizedBox(width: 8),
              Expanded(child: _buildSmallButton('কালিমাহ', KalemaPage())),
            ],
          ),
          SizedBox(height: 8),
          _buildPrivacyPolicyButton(),
        ],
      ),
    );
  }

  /// ---------------- Feature Card ----------------
  Widget _buildFeatureCard(String title, IconData icon, Widget page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.green[800] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await AdHelper.showInterstitialAd(adContext: "Feature $title");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: isDark ? Colors.white : Colors.green[700],
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- Small Button ----------------
  Widget _buildSmallButton(String title, Widget page) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          await AdHelper.showInterstitialAd(adContext: "SmallButton $title");
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
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
        child: Text(
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
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green[800],
              image: DecorationImage(
                image: AssetImage('assets/images/mosque_background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: Icon(
                    Icons.menu_book,
                    size: 30,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "ইসলামিক কুইজ অনলাইন",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "সঠিক জ্ঞানের সাথী",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.book, 'দৈনন্দিন দোয়া', DoyaPage()),
          _buildDrawerItem(
            Icons.access_time,
            'আজকের নামাজের সময়',
            PrayerTimePage(),
          ),
          _buildDrawerItem(Icons.info, 'আমাদের কথা', AboutPage()),
          _buildDrawerItem(Icons.contact_page, 'যোগাযোগ', ContactPage()),
          _buildDrawerItem(Icons.developer_mode, 'ডেভেলপার', DeveloperPage()),
          _buildDrawerItem(
            Icons.privacy_tip,
            'Privacy Policy',
            null,
            url: 'https://sites.google.com/view/islamicquize/home',
          ),
          Divider(color: Colors.green.shade200),
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
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'হোম', 0),
            _buildBottomNavItem(Icons.star_rate, 'রেটিং', 1),
            _buildBottomNavItem(Icons.apps, 'অন্যান্য অ্যাপ', 2),
            _buildBottomNavItem(Icons.share, 'শেয়ার', 3),
          ],
        ),
      ),
    );
  }

  /// ---------------- Bottom Navigation Item Widget ----------------
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onBottomNavItemTapped(index),
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
