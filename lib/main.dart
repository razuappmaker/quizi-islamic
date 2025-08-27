import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auto_image_slider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ AdMob ইম্পোর্ট

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ AdMob ইনিশিয়ালাইজ
  await MobileAds.instance.initialize();

  // অ্যাপ শুরুতেই ইন্টারস্টিশিয়াল লোড
  AdHelper.loadInterstitialAd();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ইসলামিক কুইজ অনলাইন',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
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
    'হাদিস',
    'নবী-রাসূল',
    'ইসলামের ইতিহাস',
    'ইবাদত',
    'আখিরাত',
    'বিচার দিবস',
    'নারী ও ইসলাম',
    'ইসলামী নৈতিকতা ও আচার',
    'ইসলামিক আইন (বিহাহ-বিচ্ছেদ)',
    'শিষ্টাচার',
    'দাম্পত্য ও পারিবারিক সম্পর্ক',
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ✅ সিস্টেম ব্যাক বাটন প্রেস হ্যান্ডেল করা
      onWillPop: () async {
        bool exitConfirmed = await showExitConfirmationDialog(context);
        if (exitConfirmed) {
          // ✅ Exit এর আগে ফুল স্ক্রিন অ্যাড দেখানো
          AdHelper.loadInterstitialAd();
          return true; // অ্যাপ বন্ধ হবে
        }
        return false; // অ্যাপ খোলা থাকবে
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ইসলামিক কুইজ অনলাইন'),
          centerTitle: true,
          backgroundColor: Colors.green[800],
        ),

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
                    "📖 ইসলামই একমাত্র সত্য ধর্ম (আলে ইমরান: ১৯)   •   আল্লাহকে ভয় করো ও সত্যবাদীদের সাথে থাকো (তাওবা: ১১৯)   •  "
                        " নামাজ অশ্লীলতা ও মন্দ কাজ থেকে বিরত রাখে (আনকাবুত: ৪৫)   •   হে আমার প্রতিপালক! আমাকে জ্ঞান বৃদ্ধি করে দিন "
                        "(ত্ব-হা: ১১৪)   •   সৎকাজে প্রতিযোগিতা করো (বাকারাহ: ১৪৮)   ",
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
                      margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                            padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border:
                              Border.all(color: Colors.green.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                hint: const Text('বিষয় বেছে নিন'),
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

                              //AdHelper.loadInterstitialAd(); // ✅ কুইজ শুরুর আগে ইন্টারস্টিশিয়াল অ্যাড দেখানো

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MCQPage(
                                      category: selectedCategory!),
                                ),
                              );
                            },
                            //-----------------------------------------------------------
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('শুরু করুন',
                                style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildNavButton(
                        context, 'দৈনন্দিন ব্যাবহারিত দোয়া', DoyaPage()),
                    _buildNavButton(
                        context, 'আমাদের কথা', const AboutPage()),
                    _buildNavButton(
                        context, 'যোগাযোগ', const ContactPage()),
                    _buildNavButton(context, 'Privacy Policy',
                        const PrivacyPolicyPage()),
                    _buildNavButton(
                        context, 'ডেভেলপার', DeveloperPage()),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ✅ নিচে ব্যানার অ্যাড
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
                BottomNavigationBarItem(icon: Icon(Icons.star_rate), label: 'Rating'),
                BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Other Apps'),
                BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Share'),
              ],
              onTap: (index) {
                switch (index) {
                  case 1:
                    launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.example.quizapp'));
                    break;
                  case 2:
                    launchUrl(Uri.parse('https://play.google.com/store/apps/dev?id=YOUR_DEVELOPER_ID'));
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
                fontSize: 18, fontWeight: FontWeight.bold),
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
}
