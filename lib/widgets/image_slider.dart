// lib/widgets/image_slider.dart
import 'package:flutter/foundation.dart';
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
    if (kDebugMode) {
      print(
        "📱 Device: ${isTablet ? "Tablet" : "Mobile"} | "
        "Orientation: ${isLandscape ? "Landscape" : "Portrait"}",
      );
    }

    // Use full screen width for all devices
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calculate height based on device type and image aspect ratio
    double sliderHeight;

    if (isTablet) {
      // Tablet dimensions
      if (isLandscape) {
        // For tablet landscape (1600x1200 = 4:3 aspect ratio)
        // Height = Width × (3/4) to maintain 4:3 aspect ratio
        sliderHeight = screenWidth * (3 / 4);
      } else {
        // For tablet portrait (1200x1600 = 3:4 aspect ratio)
        // Height = Width × (4/3) to maintain 3:4 aspect ratio
        sliderHeight = screenWidth * (4 / 3);
      }
    } else {
      // Mobile dimensions (1920x1080 = 16:9 aspect ratio)
      // Height = Width × (9/16) to maintain 16:9 aspect ratio
      sliderHeight = screenWidth * (9 / 16);
    }

    return Container(
      width: screenWidth,
      margin: EdgeInsets.symmetric(vertical: responsiveValue(context, 8)),
      child: CarouselSlider(
        options: CarouselOptions(
          height: sliderHeight,
          viewportFraction: 1.0,
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

              if (kDebugMode) print("➡️ Trying: $imagePath");

              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
                  width: screenWidth,
                  height: sliderHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildErrorPlaceholder(
                        context,
                        isDarkMode,
                        imagePath,
                        screenWidth,
                        sliderHeight,
                      ),
                ),
              );
            }).toList(),
      ),
    );
  }

  String _getImagePath(String baseName) {
    if (isTablet) {
      return isLandscape
          ? 'assets/images/slider/tablet_landscape/$baseName'
          : 'assets/images/slider/tablet_portrait/$baseName';
    } else {
      return isLandscape
          ? 'assets/images/slider/mobile_landscape/$baseName'
          : 'assets/images/slider/mobile_portrait/$baseName';
    }
  }

  Widget _buildErrorPlaceholder(
    BuildContext context,
    bool isDarkMode,
    String imagePath,
    double width,
    double height,
  ) {
    if (kDebugMode) print('❌ Error loading image: $imagePath');

    final fallbackPath = 'assets/images/slider/${imagePath.split('/').last}';
    if (kDebugMode) print('🔄 Fallback to: $fallbackPath');

    return Container(
      width: width,
      height: height,
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
            const SizedBox(height: 8),
            Text(
              'ছবি লোড হয়নি',
              style: TextStyle(
                fontSize: responsiveValue(context, 12),
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Path: ${imagePath.split('/').last}',
              style: TextStyle(
                fontSize: responsiveValue(context, 10),
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Image.asset(
              fallbackPath,
              fit: BoxFit.contain,
              width: 100,
              height: 60,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
