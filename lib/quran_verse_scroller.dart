// lib/widgets/quran_verse_scroller.dart
import 'package:flutter/material.dart';

class QuranVerseScroller extends StatefulWidget {
  final bool isDarkMode;
  final bool isTablet;
  final bool isLandscape;

  const QuranVerseScroller({
    Key? key,
    required this.isDarkMode,
    required this.isTablet,
    required this.isLandscape,
  }) : super(key: key);

  @override
  State<QuranVerseScroller> createState() => _QuranVerseScrollerState();
}

class _QuranVerseScrollerState extends State<QuranVerseScroller> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _quranVerses = [
    "إِنَّ مَعَ الْعُسْرِ يُسْرًا - নিশ্চয় কষ্টের সাথে স্বস্তি আছে (সূরা আল-ইনশিরাহ: ৬)",
    "وَتَوَ كَّلْ عَلَى اللَّهِ - আর আল্লাহর উপর ভরসা করুন (সূরা আলে-ইমরান: ১৫৯)",
    "رَبِّ زِدْنِي عِلْمًا - হে আমার রব, আমার জ্ঞান বৃদ্ধি করুন (সূরা ত্ব-হা: ১১৪)",
    "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا - নিশ্চয় কষ্টের সাথে স্বস্তি আছে (সূরা আল-ইনশিরাহ: ৫)",
    "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا - আল্লাহ কোন প্রাণকে তার সামর্থ্যের অতিরিক্ত দায়িত্ব দেন না (সূরা আল-বাকারা: ২৮৬)",
    "وَاصْبِرْ فَإِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ - ধৈর্য ধারণ করুন, নিশ্চয় আল্লাহ সৎকর্মশীলদের সওয়াব নষ্ট করেন না (সূরা হুদ: ১১৫)",
    "إِنَّ اللَّهَ مَعَ الصَّابِرِينَ - নিশ্চয় আল্লাহ ধৈর্যশীলদের সাথে আছেন (সূরা আল-বাকারা: ১৫৩)",
    "وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ - হতে পারে তোমরা কোন কিছু অপছন্দ কর, অথচ তা তোমাদের জন্য কল্যাণকর (সূরা আল-বাকারা: ২১৬)",
  ];

  @override
  void initState() {
    super.initState();
    // অটো স্ক্রল শুরু করুন
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 1), () {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll >= maxScroll) {
          // শেষে পৌঁছে গেলে শুরুতে ফিরে যান
          _scrollController.jumpTo(0);
        } else {
          // ডান থেকে বামে স্ক্রল করুন
          _scrollController.animateTo(
            currentScroll + 100,
            duration: Duration(seconds: 10),
            curve: Curves.linear,
          );
        }
        _startAutoScroll(); // পুনরাবৃত্তি করুন
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      height: widget.isTablet ? 50 : 40,
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.green[900]!.withOpacity(0.3)
            : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.green[700]!.withOpacity(0.5)
              : Colors.green[200]!,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          // ম্যানুয়াল স্ক্রল বন্ধ
          child: Row(
            children: [
              SizedBox(width: 16),
              // আয়াতগুলি হরিজন্টালি显示
              Row(
                children: _quranVerses.map((verse) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // ইসলামিক ডেকোরেশন আইকন
                        Icon(
                          Icons.mosque,
                          color: widget.isDarkMode
                              ? Colors.green[300]
                              : Colors.green[600],
                          size: widget.isTablet ? 20 : 16,
                        ),
                        SizedBox(width: 8),
                        // আয়াত টেক্সট
                        Text(
                          verse,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                            color: widget.isDarkMode
                                ? Colors.green[100]
                                : Colors.green[800],
                            fontFamily: 'SolaimanLipi', // বাংলা ফন্ট (ঐচ্ছিক)
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          color: widget.isDarkMode
                              ? Colors.green[300]
                              : Colors.green[600],
                          size: widget.isTablet ? 16 : 12,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
