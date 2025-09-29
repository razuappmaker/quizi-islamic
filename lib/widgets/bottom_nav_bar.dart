// lib/widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/responsive_utils.dart';
import 'package:islamicquiz/word_by_word_quran_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final bool isDarkMode;
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.isDarkMode,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: responsiveValue(context, 2)),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveValue(context, 6),
          vertical: responsiveValue(context, 4),
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.green[900] : Colors.white,
          borderRadius: BorderRadius.circular(responsiveValue(context, 0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: responsiveValue(context, 3),
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              context,
              Icons.home,
              'হোম',
              0,
              isDarkMode,
              isSelected: currentIndex == 0,
              isDefault: true,
            ),

            _buildBottomNavItem(
              context,
              Icons.menu_book_rounded,
              'শব্দে কুরআন',
              2,
              isDarkMode,
              isSelected: currentIndex == 2,
            ),
            _buildBottomNavItem(
              context,
              Icons.star,
              'রেটিং',
              1,
              isDarkMode,
              isSelected: currentIndex == 1,
            ),
            _buildBottomNavItem(
              context,
              Icons.share,
              'শেয়ার',
              3,
              isDarkMode,
              isSelected: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    bool isDarkMode, {
    bool isSelected = false,
    bool isDefault = false,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          onTap(index);
          handleBottomNavItemTap(context, index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: responsiveValue(context, 4)),
          decoration: BoxDecoration(
            gradient: isDefault && isSelected
                ? LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: (!isDefault && isSelected)
                ? Colors.green[700]!.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(responsiveValue(context, 8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: responsiveValue(context, 13),
                backgroundColor: isSelected
                    ? Colors.green[700]
                    : (isDarkMode ? Colors.green[800] : Colors.green[200]),
                child: Icon(
                  icon,
                  size: responsiveValue(context, 16),
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.green[700]),
                ),
              ),
              SizedBox(height: responsiveValue(context, 2)),
              ResponsiveText(
                label,
                fontSize: 10,
                color: isSelected
                    ? Colors.green[700]!
                    : (isDarkMode ? Colors.white : Colors.green[700]!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> handleBottomNavItemTap(
    BuildContext context,
    int index,
  ) async {
    try {
      switch (index) {
        case 1:
          final Uri ratingUri = Uri.parse(
            'https://play.google.com/store/apps/details?id=com.example.quizapp',
          );
          if (await canLaunchUrl(ratingUri)) {
            await launchUrl(ratingUri, mode: LaunchMode.externalApplication);
          }
          break;
        case 2:
          _navigateToWordByWordQuran(context);
          break;
        case 3:
          await Share.share(
            '📲 ইসলামিক কুইজ অনলাইন অ্যাপ ডাউনলোড করুন:\n'
            'https://play.google.com/store/apps/details?id=com.example.quizapp',
          );
          break;
      }
    } catch (e) {
      debugPrint("Error in BottomNav tap: $e");
    }
  }

  // ✅ এখানে Navigation ফাংশন
  static void _navigateToWordByWordQuran(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordByWordQuranPage()),
    );
  }
}
