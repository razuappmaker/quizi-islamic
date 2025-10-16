// lib/widgets/quran_verse_scroller.dart - WITH ALTERNATIVE ICONS
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
  int _currentIconIndex = 0; // For rotating icons

  // List of alternative icons
  final List<IconData> _alternativeIcons = [
    Icons.mosque, // Original mosque
    Icons.auto_awesome, // Sparkle/star
    Icons.light_mode, // Light/moon
    Icons.eco, // Leaf/eco
    Icons.water_drop, // Water drop (purity)
    Icons.architecture, // Islamic architecture
    Icons.flag, // Islamic flag
    Icons.book, // Quran book
    Icons.import_contacts, // Another book style
    Icons.auto_awesome_mosaic, // Geometric pattern
    Icons.brightness_1, // Circle
    Icons.workspace_premium, // Premium/badge
    Icons.verified, // Verified
    Icons.favorite, // Heart
    Icons.psychology, // Wisdom
  ];

  // Arabic verses (always show)
  final List<String> _arabicVerses = [
    "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
    "وَتَوَكَّلْ عَلَى اللَّهِ ۚ إِنَّ اللَّهَ يُحِبُّ الْمُتَوَكِّلِينَ",
    "رَّبِّ زِدْنِي عِلْمًا",
    "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
    "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
    "وَاصْبِرْ فَإِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ",
    "إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
    "وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ",
  ];

  // English translations
  final List<String> _englishTranslations = [
    "Remember, after every difficulty comes relief (94:5)",
    "Put your trust in Allah - He loves those who rely on Him (3:159)",
    "My Lord, increase me in knowledge and understanding (20:114)",
    "Know that with every hardship comes ease (94:6)",
    "Allah never burdens you beyond what you can bear (2:286)",
    "Remain patient - Allah never wastes the reward of good deeds (11:115)",
    "Allah is always with those who patiently persevere (2:153)",
    "What you dislike today may be best for you tomorrow (2:216)",
  ];

  // Bengali translations
  final List<String> _bengaliTranslations = [
    "নিশ্চয় কষ্টের সাথে স্বস্তি আছে (সূরা আল-ইনশিরাহ ৯৪:৫)",
    "আর আল্লাহর উপর ভরসা কর, নিশ্চয় আল্লাহ ভরসাকারীদেরকে ভালোবাসেন (সূরা আলে-ইমরান ৩:১৫৯)",
    "হে আমার রব, আমার জ্ঞান বৃদ্ধি করুন (সূরা ত্বাহা ২০:১১৪)",
    "নিশ্চয় কষ্টের সাথে স্বস্তি আছে (সূরা আল-ইনশিরাহ ৯৪:৬)",
    "আল্লাহ কোন প্রাণকে তার সাধ্যের অতিরিক্ত দায়িত্ব দেন না (সূরা আল-বাকারা ২:২৮৬)",
    "আর তুমি ধৈর্য ধারণ কর, নিশ্চয় আল্লাহ সৎকর্মশীলদের সওয়াব নষ্ট করেন না (সূরা হুদ ১১:১১৫)",
    "নিশ্চয় আল্লাহ ধৈর্যশীলদের সাথে আছেন (সূরা আল-বাকারা ২:১৫৩)",
    "হতে পারে তোমরা কোন কিছু অপছন্দ কর, অথচ তা তোমাদের জন্য কল্যাণকর (সূরা আল-বাকারা ২:২১৬)",
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
          // Change icon when resetting scroll
          _changeIcon();
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

  void _changeIcon() {
    if (mounted) {
      setState(() {
        _currentIconIndex = (_currentIconIndex + 1) % _alternativeIcons.length;
      });
    }
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
    final currentIcon = _alternativeIcons[_currentIconIndex];

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
            onDoubleTap: _changeIcon,
            // Double tap to change icon
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
                            // 🔥 UPDATED: Dynamic icon that changes
                            Icon(
                              currentIcon,
                              color: widget.isDarkMode
                                  ? Colors.green[300]
                                  : Colors.green[600],
                              size: widget.isTablet ? 20 : 16,
                            ),
                            SizedBox(width: 8),
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
