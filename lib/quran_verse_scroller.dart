// lib/widgets/quran_verse_scroller.dart - IMPROVED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

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
  bool _isScrolling = true;

  // Arabic verses (always show)
  final List<String> _arabicVerses = [
    "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
    "وَتَوَ كَّلْ عَلَى اللَّهِ",
    "رَبِّ زِدْنِي عِلْمًا",
    "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
    "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
    "وَاصْبِرْ فَإِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ",
    "إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
    "وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ",
  ];

  // English translations
  final List<String> _englishTranslations = [
    "Indeed, with hardship comes ease (Al-Inshirah- 94:6)",
    "And rely upon Allah (3:159)",
    "My Lord, increase me in knowledge (20:114)",
    "Indeed, with hardship comes ease (94:5)",
    "Allah does not burden a soul beyond that it can bear (2:286)",
    "Be patient, for indeed Allah does not allow the reward of the good-doers to be lost (11:115)",
    "Indeed, Allah is with the patient (2:153)",
    "But perhaps you hate a thing and it is good for you (2:216)",
  ];

  // Bengali translations
  final List<String> _bengaliTranslations = [
    "নিশ্চয় কষ্টের সাথে স্বস্তি আছে (সূরা: সূরা আল-ইনশিরাহ ৯৪:৬)",
    "আর আল্লাহর উপর ভরসা করুন (৩:১৫৯)",
    "হে আমার রব, আমার জ্ঞান বৃদ্ধি করুন (২০:১১৪)",
    "নিশ্চয় কষ্টের সাথে স্বস্তি আছে (৯৪:৫)",
    "আল্লাহ কোন প্রাণকে তার সামর্থ্যের অতিরিক্ত দায়িত্ব দেন না (২:২৮৬)",
    "ধৈর্য ধারণ করুন, নিশ্চয় আল্লাহ সৎকর্মশীলদের সওয়াব নষ্ট করেন না (১১:১১৫)",
    "নিশ্চয় আল্লাহ ধৈর্যশীলদের সাথে আছেন (২:১৫৩)",
    "হতে পারে তোমরা কোন কিছু অপছন্দ কর, অথচ তা তোমাদের জন্য কল্যাণকর (২:২১৬)",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    if (!_isScrolling || !mounted) return;

    Future.delayed(Duration(seconds: 1), () {
      if (_scrollController.hasClients && mounted && _isScrolling) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 100,
            duration: Duration(seconds: 10),
            curve: Curves.linear,
          );
        }
        _startAutoScroll();
      }
    });
  }

  void _pauseScrolling() {
    setState(() {
      _isScrolling = false;
    });
  }

  void _resumeScrolling() {
    if (!_isScrolling && mounted) {
      setState(() {
        _isScrolling = true;
      });
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

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
        child: MouseRegion(
          onEnter: (_) => _pauseScrolling(),
          onExit: (_) => _resumeScrolling(),
          child: GestureDetector(
            onTapDown: (_) => _pauseScrolling(),
            onTapCancel: _resumeScrolling,
            onTapUp: (_) => _resumeScrolling(),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Row(
                    children: List.generate(_arabicVerses.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.mosque,
                              color: widget.isDarkMode
                                  ? Colors.green[300]
                                  : Colors.green[600],
                              size: widget.isTablet ? 20 : 16,
                            ),
                            SizedBox(width: 8),
                            // 🔥 UPDATED: Single line display with language support
                            Text(
                              "${_arabicVerses[index]} - ${languageProvider.isEnglish ? _englishTranslations[index] : _bengaliTranslations[index]}",
                              style: TextStyle(
                                fontSize: widget.isTablet ? 14 : 12,
                                fontWeight: FontWeight.w500,
                                color: widget.isDarkMode
                                    ? Colors.green[100]
                                    : Colors.green[800],
                                fontFamily: languageProvider.isEnglish
                                    ? 'Roboto'
                                    : 'HindSiliguri',
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
                    }),
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
