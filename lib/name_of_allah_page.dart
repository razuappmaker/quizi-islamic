import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AllahName {
  final String arabic;
  final String bangla;
  final String english;
  final String meaningBn;
  final String meaningEn;
  final String fazilatBn;

  AllahName({
    required this.arabic,
    required this.bangla,
    required this.english,
    required this.meaningBn,
    required this.meaningEn,
    required this.fazilatBn,
  });
}

class NameOfAllahPage extends StatefulWidget {
  const NameOfAllahPage({super.key});

  @override
  State<NameOfAllahPage> createState() => _NameOfAllahPageState();
}

class _NameOfAllahPageState extends State<NameOfAllahPage> {
  final List<AllahName> allahNames = [
    AllahName(
      arabic: "ٱلرَّحِيمُ",
      bangla: "আর-রহিম",
      english: "Ar-Rahim",
      meaningBn: "অতি দয়ালু",
      meaningEn: "The Most Compassionate",
      fazilatBn:
          "যে ব্যক্তি বেশি বেশি 'আর-রহিম' পাঠ করবে, আল্লাহ তার প্রতি বিশেষ রহম করবেন।",
    ),

    AllahName(
      arabic: "ٱلْمَلِكُ",
      bangla: "আল-মালিক",
      english: "Al-Malik",
      meaningBn: "সর্বময় কর্তৃত্বের অধিকারী",
      meaningEn: "The King",
      fazilatBn: "যে ব্যক্তি 'আল-মালিক' পড়বে, তার অন্তরে দুনিয়ার লোভ কমে যাবে।",
    ),

    AllahName(
      arabic: "ٱلْقُدُّوسُ",
      bangla: "আল-কুদ্দুস",
      english: "Al-Quddus",
      meaningBn: "পবিত্রতম",
      meaningEn: "The Most Pure",
      fazilatBn: "যে ব্যক্তি এই নাম পড়বে, তার অন্তর অপবিত্রতা থেকে পবিত্র হবে।",
    ),

    AllahName(
      arabic: "ٱلسَّلَامُ",
      bangla: "আস-সালাম",
      english: "As-Salam",
      meaningBn: "শান্তির উৎস",
      meaningEn: "The Source of Peace",
      fazilatBn:
          "যে ব্যক্তি বেশি বেশি 'আস-সালাম' পাঠ করবে, আল্লাহ তাকে দুনিয়া ও আখিরাতে শান্তি দেবেন।",
    ),

    AllahName(
      arabic: "ٱلْمُؤْمِنُ",
      bangla: "আল-মুমিন",
      english: "Al-Mu’min",
      meaningBn: "নিরাপত্তা দাতা",
      meaningEn: "The Giver of Faith",
      fazilatBn: "এই নাম পাঠ করলে ভয় ও দুশ্চিন্তা দূর হয়।",
    ),

    AllahName(
      arabic: "ٱلْمُهَيْمِنُ",
      bangla: "আল-মুহাইমিন",
      english: "Al-Muhaymin",
      meaningBn: "রক্ষক ও পর্যবেক্ষক",
      meaningEn: "The Protector",
      fazilatBn:
          "যে ব্যক্তি 'আল-মুহাইমিন' পাঠ করবে, আল্লাহ তাকে সর্বপ্রকার বিপদ থেকে রক্ষা করবেন।",
    ),

    AllahName(
      arabic: "ٱلْعَزِيزُ",
      bangla: "আল-আজিজ",
      english: "Al-Aziz",
      meaningBn: "পরাক্রমশালী",
      meaningEn: "The Almighty",
      fazilatBn:
          "যে ব্যক্তি বেশি বেশি এই নাম পড়বে, সে মানুষের নিকট সম্মানিত হবে।",
    ),

    AllahName(
      arabic: "ٱلْجَبَّارُ",
      bangla: "আল-জব্বার",
      english: "Al-Jabbar",
      meaningBn: "অপরাজেয়",
      meaningEn: "The Compeller",
      fazilatBn: "এই নাম পড়লে অন্তরে সাহস ও দৃঢ়তা বৃদ্ধি পায়।",
    ),

    AllahName(
      arabic: "ٱلْمُتَكَبِّرُ",
      bangla: "আল-মুতাকাব্বির",
      english: "Al-Mutakabbir",
      meaningBn: "মহিমাময়",
      meaningEn: "The Supreme in Greatness",
      fazilatBn: "যে ব্যক্তি এই নাম পাঠ করবে, সে অহংকার থেকে মুক্তি পাবে।",
    ),

    AllahName(
      arabic: "ٱلْخَالِقُ",
      bangla: "আল-খালিক",
      english: "Al-Khaliq",
      meaningBn: "সৃষ্টিকর্তা",
      meaningEn: "The Creator",
      fazilatBn:
          "যে ব্যক্তি বেশি বেশি 'আল-খালিক' পাঠ করবে, তার অন্তরে সৃষ্টির রহস্য বোঝার জ্ঞান বৃদ্ধি পাবে।",
    ),

    // 👉 বাকি সব নাম, অর্থ ও ফজিলত এভাবেই যোগ করবেন
  ];

  List<AllahName> filteredNames = [];
  final List<BannerAd?> _bannerAds = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredNames = List.from(allahNames);

    int adCount = (allahNames.length / 5).ceil();
    for (int i = 0; i < adCount; i++) {
      final banner = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111', // ✅ Test Ad
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      )..load();
      _bannerAds.add(banner);
    }
  }

  void _filterNames(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNames = List.from(allahNames);
      } else {
        filteredNames = allahNames.where((name) {
          return name.arabic.contains(query) ||
              name.bangla.contains(query) ||
              name.english.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    for (var ad in _bannerAds) {
      ad?.dispose();
    }
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = filteredNames.length + (filteredNames.length / 5).floor();

    return Scaffold(
      appBar: AppBar(
        title: const Text("আল্লাহর ৯৯ নাম"),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AllahNameSearchDelegate(allahNames),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: totalItems,
        itemBuilder: (context, index) {
          if ((index + 1) % 6 == 0) {
            int adIndex = ((index + 1) / 6).floor() - 1;
            if (adIndex < _bannerAds.length && _bannerAds[adIndex] != null) {
              return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: _bannerAds[adIndex]!.size.width.toDouble(),
                height: _bannerAds[adIndex]!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAds[adIndex]!),
              );
            } else {
              return const SizedBox.shrink();
            }
          }

          int nameIndex = index - (index / 6).floor();
          final name = filteredNames[nameIndex];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name.arabic,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      Text(
                        name.bangla,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        name.english,
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "অর্থ (বাংলা): ${name.meaningBn}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Meaning (English): ${name.meaningEn}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "ফজিলত: ${name.fazilatBn}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AllahNameSearchDelegate extends SearchDelegate {
  final List<AllahName> allNames;

  AllahNameSearchDelegate(this.allNames);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allNames.where((name) {
      return name.arabic.contains(query) ||
          name.bangla.contains(query) ||
          name.english.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView(
      children: results
          .map(
            (name) => ListTile(
              title: Text("${name.arabic} | ${name.bangla} | ${name.english}"),
              subtitle: Text(name.meaningBn),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allNames.where((name) {
      return name.arabic.contains(query) ||
          name.bangla.contains(query) ||
          name.english.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView(
      children: suggestions
          .map(
            (name) => ListTile(
              title: Text("${name.arabic} | ${name.bangla} | ${name.english}"),
              onTap: () {
                query = name.english;
                showResults(context);
              },
            ),
          )
          .toList(),
    );
  }
}
