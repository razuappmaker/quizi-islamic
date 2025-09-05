import 'dart:async';
import 'package:flutter/material.dart';

class AutoImageSlider extends StatefulWidget {
  final List<String> imageUrls;

  const AutoImageSlider({Key? key, required this.imageUrls}) : super(key: key);

  @override
  _AutoImageSliderState createState() => _AutoImageSliderState();
}

class _AutoImageSliderState extends State<AutoImageSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 6), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % widget.imageUrls.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _currentPage = nextPage;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sliderHeight = MediaQuery.of(context).size.height * 0.3; // 30% স্ক্রিন উচ্চতা

    return SizedBox(
      height: sliderHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black12,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: Image.asset(
                widget.imageUrls[index],
                fit: BoxFit.fitWidth, // ছবির অনুপাত ঠিক থাকবে, কাটবে না
                width: MediaQuery.of(context).size.width, // স্ক্রিনের প্রস্থ অনুযায়ী
                height: MediaQuery.of(context).size.height * 0.3, // স্ক্রিনের উচ্চতার 30%
              ),
            ),
          );
        },
      ),
    );
  }
}
