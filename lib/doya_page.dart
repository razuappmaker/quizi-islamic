import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class DoyaPage extends StatefulWidget {
  const DoyaPage({Key? key}) : super(key: key);

  @override
  State<DoyaPage> createState() => _DoyaPageState();
}

class _DoyaPageState extends State<DoyaPage> {
  final List<Map<String, String>> dailyDoyas =
  [
    {
      'title': 'বাসা থেকে বের হওয়ার দোয়া',
      'text': 'বিসমিল্লাহ তাওয়াক্কালতু আলাল্লাহি ওয়া লা হাওলা ওয়া লা কুওয়াতা ইল্লা বিল্লাহি',
    },
    {
      'title': 'বাসায় প্রবেশের দোয়া',
      'text': 'আল্লাহুম্মা ইন্নি আসআলুকা খায়রাল মাওলিজি ওয়া খায়রাল মাখরুজি',
    },
    {
      'title': 'ঘুম থেকে ওঠার দোয়া',
      'text': 'আলহামদুলিল্লাহিল্লাযি অহইয়ানা বাতা মা আমাতানা ওয়া ইলায়হি নুশূর',
    },
    {
      'title': 'খাবার খাওয়ার আগে দোয়া',
      'text': 'বিসমিল্লাহ',
    },
    {
      'title': 'খাবার খাওয়ার পরে দোয়া',
      'text': 'আলহামদুলিল্লাহিল্লাযি আতআমানা ওয়া সাকানা ওয়া জালালনা মুসলিমীন',
    },
    {
      'title': 'সেহরি খাওয়ার দোয়া',
      'text': 'ওয়া সেহরনা ওয়া ফাত্তরনা আলাল ইমানি ওয়াস সাবর',
    },
    {
      'title': 'ইফতার দোয়া',
      'text': 'আল্লাহুম্মা লাকা সুমতু ওয়া আলা রিজকিকা আফতারতু',
    },
    {
      'title': 'রোজা রাখার ইচ্ছার দোয়া',
      'text': 'নাওয়াইতু সাওমা গাদিন মিন শোহরি রমজান',
    },
    {
      'title': 'যাত্রা শুরু করার দোয়া',
      'text': 'সুবহানাল্লাযি সাখ্খারা লেনাজ্জা ওয়া মা কুন্না লাহু মোকরিনীন',
    },
    {
      'title': 'যাত্রাকালে নিরাপত্তার দোয়া',
      'text': 'আল্লাহুম্মা অন্তাস সাহিবু ফিস সফর',
    },
    {
      'title': 'কোনো কাজে মনোযোগের দোয়া',
      'text': 'আল্লাহুম্মা ইজআল লি নূরান ফি কালবী',
    },
    {
      'title': 'দুঃখ-কষ্টের সময় দোয়া',
      'text': 'আল্লাহুম্মা ইন্নি আজউদু বিখাল খইরি ওয়াল হাজনি',
    },
    {
      'title': 'সুস্থতার জন্য দোয়া',
      'text': 'আল্লাহুম্মা আশফি আসরারানা',
    },
    {
      'title': 'মানসিক শান্তির জন্য দোয়া',
      'text': 'আল্লাহুম্মা আনজিল সাকীনাতাকা আলা কুলুবিনা',
    },
    {
      'title': 'শুভ কাজের জন্য দোয়া',
      'text': 'রাব্বানা তকব্বাল মিননা ইন্নাকা আনতা সম্মিইউল আলীম',
    },
    {
      'title': 'রাতের দোয়া',
      'text': 'আল্লাহুম্মা বিস্মিকা আমুতু ওয়া আহই',
    },
    {
      'title': 'সকাল বেলার দোয়া',
      'text': 'আল্লাহুম্মা আন্তা রব্বি লা ইলাহা ইল্লা আন্তা',
    },
    {
      'title': 'পরীক্ষার আগে দোয়া',
      'text': 'আল্লাহুম্মা ফত্তিহ আলাইয়া হিকমাতাকা',
    },
    {
      'title': 'ভয়-আতঙ্ক কমানোর দোয়া',
      'text': 'আল্লাহুম্মা ইন্নি আজউদু বিকা মিনাল খৌফ',
    },
    {
      'title': 'ঝুঁকি মোকাবেলার দোয়া',
      'text': 'হাসবিয়াল্লাহু নি’মাল ওয়াকীল',
    },
    {
      'title': 'আর্থিক সমস্যা থেকে মুক্তির দোয়া',
      'text': 'আল্লাহুম্মা একফিনি বিহালালিকা আন হারামিকা',
    },
    {
      'title': 'ভালো স্বপ্ন দেখার দোয়া',
      'text': 'আল্লাহুম্মা আরিনি আলহাক্কা হক্কান ওয়ার্জুকনি ইত্তিবাআহু',
    },
    {
      'title': 'ভুলের জন্য ক্ষমা প্রার্থনার দোয়া',
      'text': 'রাব্বানা জলনা আনফুসানা ধলুমনা',
    },
    {
      'title': 'পরিপূর্ণ শান্তির জন্য দোয়া',
      'text': 'আল্লাহুম্মা আতা কুলুবনা সাকীনাতা ওয়াসসালাম',
    },
    {
      'title': 'মানব জীবনের জন্য দোয়া',
      'text': 'আল্লাহুম্মা হ্বাইয়া তি কাইয়্যিমান সালিহা',
    },
    {
      'title': 'ইবাদত পরিপূর্ণ করার দোয়া',
      'text': 'আল্লাহুম্মা জালনি মিন আবদিকা শাকিরীন',
    },
    {
      'title': 'সফলতার জন্য দোয়া',
      'text': 'রাব্বিনা আজিনি আন আকরালা সাদিকা',
    },
    {
      'title': 'পরিবারের জন্য দোয়া',
      'text': 'রাব্বানা জাল্না মিল্লাদুনাস সাদিকীন',
    },
    {
      'title': 'সত্য পথে চলার দোয়া',
      'text': 'আল্লাহুম্মা আলাইয়া হিদায়াতাকা ওয়াল তিকাকা',
    },
    {
      'title': 'পরীক্ষা উত্তীর্ণ হওয়ার দোয়া',
      'text': 'আল্লাহুম্মা বারিক লি ফি জিহাদী',
    },
    {
      'title': 'শত্রু থেকে রক্ষা পাওয়ার দোয়া',
      'text': 'আউযুবিল্লাহি মিনাশ শাইতানির রাজীম',
    },
    {
      'title': 'অপরাধ থেকে মুক্তির দোয়া',
      'text': 'রাব্বানা গফর লানা ওয়া লিল্মুমিনীন',
    },
    {
      'title': 'মানুষের জন্য দোয়া',
      'text': 'আল্লাহুম্মা হাফিযআল্লা আন নাস',
    },
    {
      'title': 'বিশ্বাসের দৃঢ়তার জন্য দোয়া',
      'text': 'আল্লাহুম্মা আসকিনা ফিদ্দীনিল ইমান',
    },
    {
      'title': 'নামাজের পূর্ব দোয়া',
      'text': 'আউযুবিল্লাহি মিনাল খবারি ওয়া মিনাল ফিতনা',
    },
    {
      'title': 'নামাজ শেষে দোয়া',
      'text': 'আস্তাগফিরুল্লাহ',
    },
    {
      'title': 'শান্তির জন্য দোয়া',
      'text': 'আল্লাহুম্মা আনজিল সালামা আলা খোলিকাতা',
    },
    {
      'title': 'দুঃখ-দুর্দশা কমানোর দোয়া',
      'text': 'আল্লাহুম্মা রজ্জিনা বিখাইর',
    },
    {
      'title': 'উন্নতির জন্য দোয়া',
      'text': 'আল্লাহুম্মা বারিক লি ফি আমালি',
    },
    {
      'title': 'আল্লাহর সাহায্য কামনার দোয়া',
      'text': 'আস্তাগফিরুল্লাহ ওয়া আতুবু ইলাইহি',
    },
    {
      'title': 'ধৈর্য ধরার জন্য দোয়া',
      'text': 'আল্লাহুম্মা আতিনা ফিদ্দুনিয়া হাসানাহ ওয়া ফিল আখিরাতি হাসানাহ',
    },
    {
      'title': 'সকল কষ্ট দূর করার দোয়া',
      'text': 'রাব্বানা আজিনা ফিদ্দুনিয়া হাসানাহ',
    },
    {
      'title': 'ভাল বান্ধবীর জন্য দোয়া',
      'text': 'আল্লাহুম্মা বারিক লা ফি খাইর',
    },
    {
      'title': 'পরিবারের সুখের জন্য দোয়া',
      'text': 'রাব্বানা আজিনা মিন আস্বাদিকিন ওয়াল আলিয়াফা',
    },
    {
      'title': 'সমস্ত কৃতকর্মের সাফল্যের জন্য দোয়া',
      'text': 'আল্লাহুম্মা তাব্বারকলনা ফি আমালিনা',
    },
  ];


  List<Map<String, String>> filteredDoyas = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDoyas = dailyDoyas;
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      filteredDoyas = dailyDoyas;
      _searchController.clear();
    });
  }

  void _searchDoya(String query) {
    final results = dailyDoyas.where((doya) {
      final titleLower = doya['title']!.toLowerCase();
      final textLower = doya['text']!.toLowerCase();
      final searchLower = query.toLowerCase();

      return titleLower.contains(searchLower) || textLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredDoyas = results;
    });
  }

  void _showDoyaDetails(Map<String, String> doya) {
    final String duaTitle = doya['title'] ?? '';
    final String duaText = doya['text'] ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          duaTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        content: SelectableText(
          duaText,
          style: const TextStyle(fontSize: 20, fontFamily: 'Amiri'),
          textAlign: TextAlign.center,
          toolbarOptions: const ToolbarOptions(
            copy: true,
            selectAll: true,
          ),
        ),
        actions: [
          // শেয়ার বাটন
          TextButton.icon(
            onPressed: () {
              Share.share('$duaTitle\n\n$duaText');
            },
            icon: const Icon(Icons.share, color: Colors.blue),
            label: const Text('শেয়ার', style: TextStyle(color: Colors.blue)),
          ),

          // বন্ধ বাটন
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বন্ধ করুন', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: !_isSearching
            ? const Text('দৈনন্দিন দোয়া', style: TextStyle(fontWeight: FontWeight.bold))
            : TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'দোয়া অনুসন্ধান করুন...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          cursorColor: Colors.white,
          onChanged: _searchDoya,
        ),
        actions: [
          !_isSearching
              ? IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _startSearch,
          )
              : IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _stopSearch,
          ),
        ],
      ),
      body: filteredDoyas.isEmpty
          ? const Center(
        child: Text(
          'কোন দোয়া পাওয়া যায়নি।',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredDoyas.length,
        itemBuilder: (context, index) {
          final doya = filteredDoyas[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            shadowColor: Colors.greenAccent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              title: Text(
                doya['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  doya['text'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
              onTap: () => _showDoyaDetails(doya),
            ),
          );
        },
      ),
    );
  }
}
