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
      margin: EdgeInsets.symmetric(vertical: responsiveValue(context, 8)),
      child: CarouselSlider(
        options: CarouselOptions(
          height: _getSliderHeight(context),
          aspectRatio: _getAspectRatio(),
          viewportFraction: 0.95,
          // 1.0 থেকে 0.95 এ কমিয়ে আনুন
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
              'slider1.webp',
              'slider2.webp',
              'slider3.webp',
              'slider4.webp',
              'slider5.webp',
            ].map((baseName) {
              final imagePath = _getImagePath(baseName);
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: responsiveValue(context, 8),
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain, // BoxFit.contain ব্যবহার করুন
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorPlaceholder(context, isDarkMode, imagePath),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  String _getImagePath(String baseName) {
    // প্রথমে আলাদা ফোল্ডার থেকে চেষ্টা করুন, না থাকলে সাধারণ ফোল্ডার থেকে নিন
    final String specificPath;

    if (isTablet) {
      specificPath = isLandscape
          ? 'assets/images/slider/tablet_landscape/$baseName'
          : 'assets/images/slider/tablet_portrait/$baseName';
    } else {
      specificPath = isLandscape
          ? 'assets/images/slider/mobile_landscape/$baseName'
          : 'assets/images/slider/mobile_portrait/$baseName';
    }

    // Fallback mechanism: যদি specific image না থাকে তবে সাধারণ ফোল্ডার থেকে নিন
    return specificPath;
  }

  double _getSliderHeight(BuildContext context) {
    // Height সামঞ্জস্য করুন
    if (isTablet) {
      return isLandscape
          ? responsiveValue(context, 220) // বাড়িয়ে 220
          : responsiveValue(context, 280); // বাড়িয়ে 280
    } else {
      return isLandscape
          ? responsiveValue(context, 160) // বাড়িয়ে 160
          : responsiveValue(context, 200); // বাড়িয়ে 200
    }
  }

  double _getAspectRatio() {
    // Fixed aspect ratio ব্যবহার করুন
    return 16 / 9; // স্ট্যান্ডার্ড aspect ratio
  }

  Widget _buildErrorPlaceholder(
    BuildContext context,
    bool isDarkMode,
    String imagePath,
  ) {
    // Error message improve করুন
    print('Error loading image: $imagePath');

    // Fallback: সাধারণ ফোল্ডার থেকে ছবি লোড করার চেষ্টা করুন
    final fallbackPath = imagePath
        .replaceAll('slider/tablet_', 'slider/')
        .replaceAll('slider/mobile_', 'slider/')
        .replaceAll('_landscape/', '/')
        .replaceAll('_portrait/', '/');

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: Colors.red,
              size: responsiveValue(context, 40),
            ),
            SizedBox(height: 8),
            Text(
              'ছবি লোড হয়নি',
              style: TextStyle(
                fontSize: responsiveValue(context, 12),
                color: Colors.red,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Path: ${imagePath.split('/').last}',
              style: TextStyle(
                fontSize: responsiveValue(context, 10),
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            // Fallback image লোড করার চেষ্টা করুন
            Image.asset(
              'assets/images/slider/$fallbackPath',
              fit: BoxFit.contain,
              width: 100,
              height: 60,
              errorBuilder: (context, error, stackTrace) => SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
