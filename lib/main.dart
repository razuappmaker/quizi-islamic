// main.dart
// -------------------- main.dart --------------------
import 'package:flutter/material.dart';
import 'package:islamicquiz/namaj_amol.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'auto_image_slider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'prayer_time_page.dart';
import 'mcq_page.dart';
import 'about_page.dart';
import 'contact_page.dart';
import 'developer_page.dart';
import 'screens/splash_screen.dart';
import 'doya_page.dart';
import 'utils.dart';
import 'ad_helper.dart';
import 'sura_page.dart';
import 'name_of_allah_page.dart';
import 'kalema_page.dart';

// -------------------- Banner Ad Widget --------------------
class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdaptiveBanner();
  }

  void _loadAdaptiveBanner() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
          Orientation.portrait,
          MediaQuery.of(context).size.width.truncate(),
        );

    if (size == null) return;

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('BannerAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded && _bannerAd != null
        ? Container(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

// -------------------- Theme Provider --------------------
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// -------------------- Main --------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();
  AdHelper.loadInterstitialAd();

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
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(backgroundColor: Colors.green[900]),
      ),
      home: SplashScreen(),
    );
  }
}

// -------------------- Home Page --------------------
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCategory;

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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmed = await showExitConfirmationDialog(context);
        if (exitConfirmed) {
          AdHelper.loadInterstitialAd();
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ইসলামিক কুইজ অনলাইন'),
          centerTitle: true,
          backgroundColor: Colors.green[800],
        ),

        // Drawer
        drawer: _buildDrawer(themeProvider),

        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildMarquee(),
              const SizedBox(height: 5), // আগের 10 → 5, gap কমানো
              _buildSlider(),
              const SizedBox(height: 5), // আগের 10 → 5
              _buildCategorySelector(context),
              const SizedBox(height: 5), // আগের 10 → 5
              _buildNavButtons(context),
              const SizedBox(height: 5),
            ],
          ),
        ),

        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [BannerAdWidget(), _buildBottomNavBar()],
        ),
      ),
    );
  }

  // -------------------- Widgets --------------------
  Widget _buildMarquee() {
    return Container(
      color: Colors.green.shade100,
      height: 50,
      child: Center(
        child: Marquee(
          text:
              "📖 ইসলামই একমাত্র সত্য ধর্ম (আলে ইমরান: ১৯) 📖 আল্লাহকে ভয় করো ও সত্যবাদীদের সাথে থাকো (তাওবা: ১১৯) 📖 নামাজ অশ্লীলতা ও মন্দ কাজ থেকে বিরত রাখে (আনকাবুত: ৪৫) 📖 হে আমার প্রতিপালক! আমার জ্ঞানকে বৃদ্ধি করে দিন (ত্ব-হা: ১১৪) 📖 সৎকাজে প্রতিযোগিতা করো (বাকারাহ: ১৪৮) 📖 আল্লাহর স্মরণে হৃদয় শান্তি পায় (রা‘দ: ২৮)",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          scrollAxis: Axis.horizontal,
          blankSpace: 50.0,
          velocity: 50.0,
          pauseAfterRound: Duration(seconds: 1),
          startPadding: 10.0,
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Container(
      height: 200,
      color: Colors.green[100],
      child: AutoImageSlider(
        imageUrls: [
          'assets/images/slider1.png',
          'assets/images/slider2.png',
          'assets/images/slider3.png',
          'assets/images/slider4.png',
          'assets/images/slider5.png',
        ],
      ),
    );
  }

  // বিষয় নির্বাচন বক্স এর সব
  Widget _buildCategorySelector(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      // আরও কম padding, প্রায় full width
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 0, // প্রায় পুরো প্রস্থ
              vertical: screenHeight * 0.015,
            ),
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'বিষয় নির্বাচন করুন',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // একটু বড় font
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Container(
                  width: double.infinity, // পুরো প্রস্থ
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      hint: Text(
                        'বিষয় বেছে নিন',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045, // font size সামঞ্জস্য
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
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
                              const Icon(
                                Icons.bookmark,
                                size: 18,
                                color: Colors.green,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.07,
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors
                                .black // 🔹 Dark Mode → কালো Icon
                          : Colors.white, // 🔹 Light Mode → সাদা Icon
                    ),
                    label: Text(
                      'শুরু করুন',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors
                                  .black // 🔹 Dark Mode → কালো Text
                            : Colors.white, // 🔹 Light Mode → সাদা Text
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
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

  Widget _buildNavButtons(BuildContext context) {
    return Column(
      children: [
        _buildNavButton(context, '১৬টি ছোট সূরা (অর্থসহ)', SuraPage()),
        _buildNavButton(context, 'দৈনন্দিন ব্যাবহারিত দোয়া', DoyaPage()),
        _buildNavButton(context, 'আজকের নামাজের সময়', const PrayerTimePage()),
        _buildNavButton(context, 'ফরজ সালাতের পর জিকিরসমূহ', const NamajAmol()),
        // 🔹 আল্লাহর নাম ও কালেমা Section
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6, bottom: 5, top: 1),
          child: Row(
            children: [
              // Name of Allah Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NameOfAllahPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'আল্লাহর নামসমূহ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 3),

              // Kalema Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KalemaPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'কালিমাহ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        _buildPrivacyPolicyButton(
          context,
          'Privacy Policy',
          'https://sites.google.com/view/islamicquize/home',
        ),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, String title, Widget page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 0),
      child: SizedBox(
        width: double.infinity,
        height: screenHeight * 0.065, // ✅ স্ক্রিনের 7% উচ্চতা নেবে (রেস্পনসিভ)
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white : Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyButton(
    BuildContext context,
    String title,
    String url,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 0),
      child: SizedBox(
        width: double.infinity,
        height: screenHeight * 0.07,
        // ✅ buildNavButton এর সাথে একই রেস্পনসিভ height
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () async {
            final Uri uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open Privacy Policy')),
              );
            }
          },
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(ThemeProvider themeProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[800]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.menu_book, size: 50, color: Colors.white),
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
          _buildDrawerItem(
            context,
            Icons.book,
            'দৈনন্দিন ব্যাবহারিত দোয়া',
            page: DoyaPage(),
          ),
          _buildDrawerItem(
            context,
            Icons.access_time,
            'আজকের নামাজের সময়',
            page: const PrayerTimePage(),
          ),
          _buildDrawerItem(
            context,
            Icons.info,
            'আমাদের কথা',
            page: const AboutPage(),
          ),
          _buildDrawerItem(
            context,
            Icons.contact_page,
            'যোগাযোগ',
            page: const ContactPage(),
          ),
          _buildDrawerItem(
            context,
            Icons.developer_mode,
            'ডেভেলপার',
            page: DeveloperPage(),
          ),
          _buildDrawerItem(
            context,
            Icons.privacy_tip,
            'Privacy Policy',
            url: 'https://sites.google.com/view/islamicquize/home',
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("ডার্ক মোড"),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? page,
    String? url,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[800]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green[800],
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.star_rate), label: 'Rating'),
        BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Other Apps'),
        BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Share'),
      ],
      onTap: (index) {
        switch (index) {
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
      },
    );
  }
}
