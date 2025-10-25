// lib/widgets/bottom_nav_bar.dart - REDUCED HEIGHT ONLY

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../../core/utils/responsive_utils.dart';

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
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool tablet = isTablet(context);

    // Navigation items with both languages - UPDATED WITH DOYA
    final List<BottomNavItem> navItems = [
      BottomNavItem(
        icon: Icons.home,
        labelBn: 'হোম',
        labelEn: 'Home',
        index: 0,
      ),
      BottomNavItem(
        icon: Icons.lightbulb_outline_rounded, // দুআর জন্য আইকন
        labelBn: 'দুআ',
        labelEn: 'Dua',
        index: 2,
      ),
      BottomNavItem(
        icon: Icons.person,
        labelBn: 'প্রফাইল',
        labelEn: 'Profile',
        index: 3,
      ),
      BottomNavItem(
        icon: Icons.star,
        labelBn: 'রেটিং',
        labelEn: 'Rating',
        index: 1,
      ),
    ];

    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: tablet ? 1 : 0),
        padding: EdgeInsets.symmetric(
          horizontal: tablet ? 16 : 12,
          vertical: tablet ? 2 : 1,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? _Colors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
              blurRadius: tablet ? 4 : 2,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems.map((item) {
            return _buildBottomNavItem(
              context: context,
              icon: item.icon,
              label: languageProvider.isEnglish ? item.labelEn : item.labelBn,
              index: item.index,
              isDarkMode: isDarkMode,
              languageProvider: languageProvider,
              isTablet: tablet,
              isSelected: currentIndex == item.index,
              isDefault: item.index == 0,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isDarkMode,
    required LanguageProvider languageProvider,
    required bool isTablet,
    bool isSelected = false,
    bool isDefault = false,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: isTablet ? 2 : 1),
          decoration: BoxDecoration(
            gradient: isDefault && isSelected
                ? LinearGradient(
                    colors: isDarkMode
                        ? [_Colors.darkPrimary, _Colors.darkPrimaryVariant]
                        : [Colors.green.shade400, Colors.green.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: (!isDefault && isSelected)
                ? (isDarkMode
                      ? _Colors.darkPrimary.withOpacity(0.15)
                      : Colors.green[700]!.withOpacity(0.12))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            border: isSelected && !isDefault
                ? Border.all(
                    color: isDarkMode
                        ? _Colors.darkPrimary.withOpacity(0.3)
                        : Colors.green[700]!.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: isTablet ? 20 : 16,
                backgroundColor: isSelected
                    ? (isDarkMode ? _Colors.darkPrimary : Colors.green[700])
                    : (isDarkMode ? _Colors.darkCard : Colors.green[200]),
                child: Icon(
                  icon,
                  size: isTablet ? 22 : 18,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? _Colors.darkText : Colors.green[700]),
                ),
              ),
              SizedBox(height: isTablet ? 4 : 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isDarkMode ? _Colors.darkPrimary : Colors.green[700]!)
                      : (isDarkMode
                            ? _Colors.darkTextSecondary
                            : Colors.green[700]!),
                  fontFamily: languageProvider.isEnglish
                      ? 'Roboto'
                      : 'HindSiliguri',
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class for navigation items
class BottomNavItem {
  final IconData icon;
  final String labelBn;
  final String labelEn;
  final int index;

  BottomNavItem({
    required this.icon,
    required this.labelBn,
    required this.labelEn,
    required this.index,
  });
}

// হোম পেজের সাথে মিল রেখে কালার স্কিম
class _Colors {
  // Dark Mode Colors - Professional Islamic Theme
  static const Color darkPrimary = Color(0xFF10B981); // Emerald Green
  static const Color darkPrimaryVariant = Color(0xFF059669); // Darker Emerald
  static const Color darkSecondary = Color(0xFF8B5CF6); // Violet
  static const Color darkBackground = Color(0xFF111827); // Dark Blue-Gray
  static const Color darkSurface = Color(0xFF1F2937); // Dark Gray
  static const Color darkCard = Color(0xFF374151); // Medium Gray
  static const Color darkError = Color(0xFFEF4444); // Red
  static const Color darkText = Color(0xFFF9FAFB); // White
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // Light Gray

  // Dark Mode Gradients
  static const List<Color> darkBackgroundGradient = [
    Color(0xFF111827), // Dark Blue-Gray
    Color(0xFF1F2937), // Dark Gray
  ];

  // Dark Mode Border
  static const Color darkBorder = Color(0xFF4B5563);
}
