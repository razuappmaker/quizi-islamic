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
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 16),
        vertical: responsiveValue(context, 8),
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.green[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsiveValue(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: responsiveValue(context, 6),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ResponsivePadding(
        horizontal: 10,
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
              semanticsLabel: 'হোম',
            ),
            _buildBottomNavItem(
              context,
              Icons.star,
              'রেটিং',
              1,
              isDarkMode,
              isSelected: currentIndex == 1,
              semanticsLabel: 'রেটিং',
            ),
            _buildBottomNavItem(
              context,
              Icons.apps,
              'অন্যান্য',
              2,
              isDarkMode,
              isSelected: currentIndex == 2,
              semanticsLabel: 'অন্যান্য',
            ),
            _buildBottomNavItem(
              context,
              Icons.share,
              'শেয়ার',
              3,
              isDarkMode,
              isSelected: currentIndex == 3,
              semanticsLabel: 'শেয়ার',
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
    String? semanticsLabel,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        vertical: responsiveValue(context, 6),
        horizontal: responsiveValue(context, 12),
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.green[700]!.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(responsiveValue(context, 12)),
      ),
      child: InkWell(
        onTap: () => onTap(index), // এখানে সরাসরি onTap callback ব্যবহার করুন
        child: Semantics(
          label: semanticsLabel,
          button: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: responsiveValue(context, 16),
                backgroundColor: isSelected
                    ? Colors.green[700]
                    : (isDarkMode ? Colors.green[800] : Colors.green[200]),
                child: Icon(
                  icon,
                  size: responsiveValue(context, 20),
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.green[700]),
                ),
              ),
              ResponsiveSizedBox(height: 4),
              ResponsiveText(
                label,
                fontSize: 11,
                color: isSelected
                    ? Colors.green[700]!
                    : (isDarkMode ? Colors.white : Colors.green[700]!),
                semanticsLabel: label,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Static method for handling bottom nav item taps
  static Future<void> handleBottomNavItemTap(
    BuildContext context,
    int index,
  ) async {
    try {
      switch (index) {
        case 0:
          // হোম - কিছু করার দরকার নাই (পেজে আছেই)
          break;

        case 1:
          // রেটিং
          final Uri ratingUri = Uri.parse(
            'https://play.google.com/store/apps/details?id=com.example.quizapp',
          );
          if (await canLaunchUrl(ratingUri)) {
            await launchUrl(ratingUri, mode: LaunchMode.externalApplication);
          } else {
            _showSnackBar(context, 'Google Play লিঙ্ক খোলা যায়নি');
          }
          break;

        case 2:
          // অন্যান্য অ্যাপ
          final Uri devUri = Uri.parse(
            'https://play.google.com/store/apps/dev?id=YOUR_DEVELOPER_ID',
          );
          if (await canLaunchUrl(devUri)) {
            await launchUrl(devUri, mode: LaunchMode.externalApplication);
          } else {
            _showSnackBar(context, 'ডেভেলপার প্রোফাইল খোলা যায়নি');
          }
          break;

        case 3:
          // শেয়ার
          await Share.share(
            '📲 ইসলামিক কুইজ অনলাইন অ্যাপ ডাউনলোড করুন:\n'
            'https://play.google.com/store/apps/details?id=com.example.quizapp',
          );
          break;
      }
    } catch (e) {
      _showSnackBar(context, 'কোনো সমস্যা হয়েছে: $e');
    }
  }

  /// Snackbar helper
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
