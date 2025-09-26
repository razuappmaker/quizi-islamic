// lib/widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/responsive_utils.dart';

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
        // 🔹 কমানো
        padding: EdgeInsets.symmetric(
          horizontal: responsiveValue(context, 6), // 🔹 কমানো
          vertical: responsiveValue(context, 4), // 🔹 কমানো
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.green[900] : Colors.white,
          borderRadius: BorderRadius.circular(responsiveValue(context, 0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: responsiveValue(context, 3), // 🔹 কমানো
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
              Icons.star,
              'রেটিং',
              1,
              isDarkMode,
              isSelected: currentIndex == 1,
            ),
            _buildBottomNavItem(
              context,
              Icons.apps,
              'অন্যান্য',
              2,
              isDarkMode,
              isSelected: currentIndex == 2,
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
        borderRadius: BorderRadius.circular(8), // 🔹 ছোট curve
        onTap: () {
          onTap(index);
          handleBottomNavItemTap(context, index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: responsiveValue(context, 4)),
          // 🔹 height কমানো
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
                radius: responsiveValue(context, 13), // 🔹 radius কমানো
                backgroundColor: isSelected
                    ? Colors.green[700]
                    : (isDarkMode ? Colors.green[800] : Colors.green[200]),
                child: Icon(
                  icon,
                  size: responsiveValue(context, 16), // 🔹 ছোট আইকন
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.green[700]),
                ),
              ),
              SizedBox(height: responsiveValue(context, 2)), // 🔹 spacing কমানো
              ResponsiveText(
                label,
                fontSize: 10, // 🔹 ছোট টেক্সট
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
          final Uri devUri = Uri.parse(
            'https://play.google.com/store/apps/dev?id=YOUR_DEVELOPER_ID',
          );
          if (await canLaunchUrl(devUri)) {
            await launchUrl(devUri, mode: LaunchMode.externalApplication);
          }
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
}
