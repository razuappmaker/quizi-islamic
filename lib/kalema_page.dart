import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class KalemaPage extends StatefulWidget {
  const KalemaPage({super.key});

  @override
  State<KalemaPage> createState() => _KalemaPageState();
}

class _KalemaPageState extends State<KalemaPage> {
  final List<Map<String, String>> kalemaList = const [
    {
      "title": "কালেমা তাইয়্যেবা",
      "text": "لا إله إلا الله محمد رسول الله",
      "transliteration": "লা-ইলাহা ইল্লাল্লাহু মুহাম্মাদুর রাসূলুল্লাহ।",
      "meaning": "আল্লাহ ছাড়া আর কোন ইলাহ নেই, মুহাম্মদ (সা.) আল্লাহর রাসূল।",
    },
    {
      "title": "কালেমা শাহাদাত",
      "text": "أشهد أن لا إله إلا الله وأشهد أن محمداً عبده ورسوله",
      "transliteration":
          "আশহাদু আল্লা-ইলাহা ইল্লাল্লাহু ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসূলুহু।",
      "meaning":
          "আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া আর কোন ইলাহ নেই এবং আমি সাক্ষ্য দিচ্ছি মুহাম্মদ (সা.) আল্লাহর বান্দা ও রাসূল।",
    },
    {
      "title": "কালেমা তামজীদ",
      "text":
          "سُبْحَانَ اللهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللهُ وَاللهُ أَكْبَر",
      "transliteration":
          "সুবহানাল্লাহি ওয়াল হামদুলিল্লাহি ওয়ালা-ইলাহা ইল্লাল্লাহু ওয়াল্লাহু আকবার।",
      "meaning":
          "পবিত্র আল্লাহ, সমস্ত প্রশংসা আল্লাহর জন্য, আল্লাহ ছাড়া আর কোন ইলাহ নেই এবং আল্লাহ মহান।",
    },
    {
      "title": "কালেমা তাওহীদ",
      "text":
          "لا إله إلا الله وحده لا شريك له، له الملك وله الحمد، يحيي ويميت، وهو حي لا يموت أبداً، ذو الجلال والإكرام، بيده الخير، وهو على كل شيء قدير",
      "transliteration":
          "লা-ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকালাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ইউহই ওয়াইউমীতু, ওয়াহুয়া হাইয়্যুন লা ইয়ামুতু আবাদান, যুল জালালি ওয়াল ইকরাম, বিয়াদিহিল খইর, ওয়াহুয়া আলা কুল্লি শাইইন কদীর।",
      "meaning":
          "আল্লাহ ছাড়া আর কোন ইলাহ নেই, তিনি এক, তার কোন অংশীদার নেই। রাজত্ব ও প্রশংসা তার জন্য। তিনিই জীবন দান করেন, মৃত্যু ঘটান। তিনি সর্বদা জীবিত, কখনো মরবেন না। তিনি মর্যাদা ও সম্মানের অধিকারী। কল্যাণ তাঁর হাতে, এবং তিনি সব কিছুর উপর ক্ষমতাবান।",
    },
    {
      "title": "কালেমা রুদ্দে কুফর",
      "text":
          "اللهم إني أعوذ بك من أن أشرك بك شيئاً وأنا أعلم به، وأستغفرك لما لا أعلم به، تبت عنه، وتبرأت من الكفر والشرك والكذب والغيبة والبدعة والنميمة والفواحش والبهتان والمعاصي كلها، أسلمت وآمنت وأقول لا إله إلا الله محمد رسول الله",
      "transliteration":
          "আল্লাহুম্মা ইন্নি আউযু বিকা মিন আন উশরিকা বিকা শাইয়ান ওয়া আনা আ’লামু বিহি... লা-ইলাহা ইল্লাল্লাহু মুহাম্মাদুর রাসূলুল্লাহ।",
      "meaning":
          "হে আল্লাহ! আমি আপনার কাছে আশ্রয় চাই এমন শিরক থেকে যা আমি জানি। এবং যা আমি জানি না, তার জন্য আপনার কাছে ক্ষমা চাই। আমি তা থেকে তওবা করলাম এবং কুফর, শিরক, মিথ্যা, গীবত, বিদআত, নামিমা, অশ্লীলতা, অপবাদ ও সকল গোনাহ থেকে আলাদা হলাম। আমি ইসলাম গ্রহণ করলাম, ঈমান আনলাম এবং বললাম: আল্লাহ ছাড়া আর কোন ইলাহ নেই, মুহাম্মদ (সা.) আল্লাহর রাসূল।",
    },
    {
      "title": "কালেমা ছাদ্দিকীন",
      "text": "آمَنتُ باللهِ كما هو بأسمائِه وصِفاتِه وقَبِلتُ جميعَ أحكامِه",
      "transliteration":
          "আমান্তু বিল্লাহি কামা হুয়া বি আসমা-ইহি ওয়া সিফাতিহি ওয়া কাবিল্তু জামিআ আহকামিহি।",
      "meaning":
          "আমি আল্লাহর প্রতি ঈমান আনলাম, যেমন তিনি তার নাম ও গুণাবলী দ্বারা আছেন এবং আমি তার সকল বিধান মেনে নিলাম।",
    },
  ];

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _showWarning = true; // সতর্ক বার্তা দেখানোর জন্য

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    await AdHelper.initialize();
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          debugPrint('Banner Ad failed to load: $error');
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  // সতর্কবার্তা widget
  Widget buildWarningBox() {
    return Dismissible(
      key: const ValueKey("warning"),
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        setState(() {
          _showWarning = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.orange.shade50],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "আরবি আয়াত বাংলায় সম্পূর্ণ সুদ্ধভাবে প্রকাশ করা যায় না। বাংলা উচ্চারণ সহায়ক মাত্র, সঠিক তিলাওয়াতের জন্য আরবিতেই পড়ুন।",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showWarning = false;
                });
              },
              child: const Icon(Icons.close, size: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("কালেমা সমূহ"),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          if (_showWarning) buildWarningBox(), // সতর্ক বার্তা
          Expanded(
            child: ListView.builder(
              itemCount: kalemaList.length,
              itemBuilder: (context, index) {
                final kalema = kalemaList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kalema["title"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            kalema["text"]!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontFamily: 'Amiri',
                              height: 1.6,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          kalema["transliteration"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "অর্থ: ${kalema["meaning"]!}",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isBannerAdLoaded && _bannerAd != null)
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
