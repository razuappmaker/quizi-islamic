// -------------------- আপনার main.dart --------------------

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart'; // ✅ Provider for theme switching
import 'auto_image_slider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ AdMob ইম্পোর্ট
import 'prayer_time_page.dart';



// নিজেরf অন্যান্য পেজ ইম্পোর্ট
import 'mcq_page.dart';
import 'about_page.dart';
import 'contact_page.dart';
import 'developer_page.dart';
import 'privacy_policy_page.dart';
import 'screens/splash_screen.dart';
import 'doya_page.dart';
import 'utils.dart';
import 'ad_helper.dart';

// -------------------- ব্যানার অ্যাড উইজেট --------------------
class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // ✅ Test Banner ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerAd == null
        ? SizedBox()
        : Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

// ✅ Theme Provider Class
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ AdMob ইনিশিয়ালাইজ
  await MobileAds.instance.initialize();

  // অ্যাপ শুরুতেই ইন্টারস্টিশিয়াল লোড
  AdHelper.loadInterstitialAd();

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ইসলামিক কুইজ অনলাইন',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(primarySwatch: Colors.green, brightness: Brightness.light),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(backgroundColor: Colors.green[900]),
      ),
      home: SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

        // ✅ Drawer যোগ করা হলো
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green[800],
                ),
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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              //_buildDrawerItem(context, Icons.book, 'দৈনন্দিন ব্যাবহারিত দোয়া', DoyaPage()),
              //_buildDrawerItem(context, Icons.access_time, 'আজকের নামাজের সময়', const PrayerTimePage()),
              //_buildDrawerItem(context, Icons.info, 'আমাদের কথা', const AboutPage()),
              //_buildDrawerItem(context, Icons.call, 'যোগাযোগ', const ContactPage()),
              // _buildDrawerItem(context, Icons.developer_mode, 'ডেভেলপার', DeveloperPage()),
              //_buildDrawerItem(context, Icons.privacy_tip, 'Privacy Policy', const PrivacyPolicyPage()),
              // Normal Pages
              _buildDrawerItem(context, Icons.book, 'দৈনন্দিন ব্যাবহারিত দোয়া',
                  page: DoyaPage()),
              _buildDrawerItem(context, Icons.access_time, 'আজকের নামাজের সময়',
                  page: const PrayerTimePage()),
              _buildDrawerItem(
                  context, Icons.info, 'আমাদের কথা', page: const AboutPage()),
              _buildDrawerItem(context, Icons.contact_page, 'যোগাযোগ',
                  page: const ContactPage()),
              _buildDrawerItem(context, Icons.developer_mode, 'ডেভেলপার',
                  page: DeveloperPage()),
              // Privacy Policy আলাদা ব্রাউজারে খুলবে
              // Privacy Policy → এখন External Browser ওপেন হবে
              _buildDrawerItem(
                context,
                Icons.privacy_tip,
                'Privacy Policy',
                url: 'https://sites.google.com/view/islamicquize/home',
              ),
              const Divider(),

              // ✅ Dark Mode Toggle
              SwitchListTile(
                title: Text("ডার্ক মোড"),
                secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons
                        .light_mode),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ],
          ),
        ),

        // --- আপনার আগের body + bottomNavigationBar অপরিবর্তিত থাকবে ---
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 🔃 স্ক্রলিং নিউজ
              Container(
                color: Colors.green.shade100,
                height: 50,
                child: Center(
                  child: Marquee(
                    text:
                    "📖 ইসলামই একমাত্র সত্য ধর্ম (আলে ইমরান: ১৯)      📖 আল্লাহকে ভয় করো ও সত্যবাদীদের সাথে থাকো (তাওবা: ১১৯)  "
                        " 📖 নামাজ অশ্লীলতা ও মন্দ কাজ থেকে বিরত রাখে (আনকাবুত: ৪৫)     📖 হে আমার প্রতিপালক! আমাকে জ্ঞান বৃদ্ধি করে দিন (ত্ব-হা: ১১৪)   "
                        " 📖  সৎকাজে প্রতিযোগিতা করো (বাকারাহ: ১৪৮)    📖 আল্লাহর স্মরণে হৃদয় শান্তি পায় (রা‘দ: ২৮)   "
                        " 📖 আল্লাহর রহমত থেকে নিরাশ হয়ো না (জুমার: ৫৩)    📖 পিতামাতার সাথে সদ্ব্যবহার করো (বনী-ইসরাঈল: ২৩)   "
                        " 📖 যারা ধৈর্য ধরে, আল্লাহ তাদের সাথে আছেন (বাকারাহ: ১৫৩)    📖 নিশ্চয়ই কষ্টের সাথে আছে স্বস্তি (ইনশিরাহ: ৬)   ",
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
              ),
              const SizedBox(height: 10),

              // স্লাইডার
              Container(
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
              ),

              const SizedBox(height: 10),

              // 🧠 ক্যাটাগরি + স্টার্ট বাটন
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('বিষয় নির্বাচন করুন',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800])),
                          const SizedBox(height: 10),

                          // Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                hint: Text(
                                  'বিষয় বেছে নিন',
                                  style: TextStyle(
                                    // Dark mode হলে কালো, নাহলে default
                                    color: Theme
                                        .of(context)
                                        .brightness == Brightness.dark
                                        ? Colors.black
                                        : null,
                                  ),
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
                                        const Icon(Icons.bookmark,
                                            size: 18, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Text(category),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ▶ Start Button
                          ElevatedButton.icon(
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
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              'শুরু করুন',
                              style: TextStyle(
                                fontSize: 16,
                                // Dark mode হলে কালো, নাহলে default white থাকবে
                                color: Theme
                                    .of(context)
                                    .brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.black54,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),

                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 👉 Body-তে আগের মতো Nav Button গুলোও থাকবে
                    _buildNavButton(
                        context, 'দৈনন্দিন ব্যাবহারিত দোয়া', DoyaPage()),
                    _buildNavButton(
                        context, 'আজকের নামাজের সময়', const PrayerTimePage()),
                    _buildNavButton(context, 'আমাদের কথা', const AboutPage()),
                    _buildNavButton(context, 'যোগাযোগ', const ContactPage()),
                    _buildNavButton(context, 'ডেভেলপার', DeveloperPage()),
                    //_buildNavButton(context, 'Privacy Policy', const PrivacyPolicyPage()),

                    // Privacy Policy আলাদা ব্রাউজারে খুলবে
                    _buildPrivacyPolicyButton(
                      context,
                      'Privacy Policy',
                      'https://sites.google.com/view/islamicquize/home',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BannerAdWidget(),
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.green[800],
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.star_rate), label: 'Rating'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.apps), label: 'Other Apps'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.share), label: 'Share'),
              ],
              onTap: (index) {
                switch (index) {
                  case 1:
                    launchUrl(Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.example.quizapp'));
                    break;
                  case 2:
                    launchUrl(Uri.parse(
                        'https://play.google.com/store/apps/dev?id=YOUR_DEVELOPER_ID'));
                    break;
                  case 3:
                    Share.share(
                      'ইসলামিক কুইজ অনলাইন অ্যাপটি ডাউনলোড করুন:\nhttps://play.google.com/store/apps/details?id=com.example.quizapp',
                    );
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold,),
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => page));
          },
          child: Text(title, textAlign: TextAlign.center),
        ),
      ),
    );
  }


  Widget _buildPrivacyPolicyButton(BuildContext context, String title,
      String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
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
          child: Text(title, textAlign: TextAlign.center),
        ),
      ),
    );
  }


// Drawer Item Builder
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      {Widget? page, String? url}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[800]),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () async {
        Navigator.pop(context); // Drawer বন্ধ হবে

        if (url != null) {
          // যদি URL দেওয়া থাকে → External Browser ওপেন হবে
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open link')),
            );
          }
        } else if (page != null) {
          // যদি Page দেওয়া থাকে → Navigator দিয়ে ওপেন হবে
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        }
      },
    );
  }
}
