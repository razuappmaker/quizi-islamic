// lib/widgets/image_slider.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../utils/responsive_utils.dart';

class ImageSlider extends StatelessWidget {
  final bool isDarkMode;
  final bool isTablet;
  final bool isLandscape;

  const ImageSlider({
    super.key,
    required this.isDarkMode,
    required this.isTablet,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 4), // margin কমিয়েছেন
        vertical: responsiveValue(context, 8),
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          height: isTablet
              ? responsiveValue(context, 200)
              : responsiveValue(context, 150),
          aspectRatio: isLandscape ? 21 / 9 : 16 / 9,
          viewportFraction: 1.0,
          // সম্পূর্ণ width নেবে
          initialPage: 0,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.easeInOut,
          enlargeCenterPage: false,
          scrollDirection: Axis.horizontal,
        ),
        items:
            [
              'assets/images/slider1.png',
              'assets/images/slider2.png',
              'assets/images/slider3.png',
              'assets/images/slider4.png',
              'assets/images/slider5.png',
            ].map((imagePath) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: responsiveValue(
                    context,
                    2,
                  ), // margin আরও কমিয়েছেন
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    responsiveValue(context, 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    responsiveValue(context, 16),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.fill, // BoxFit.fill ব্যবহার করুন
                    width: double.infinity, // সম্পূর্ণ width নেবে
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: responsiveValue(context, 40),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
