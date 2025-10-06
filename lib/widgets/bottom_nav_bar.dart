// lib/widgets/bottom_nav_bar.dart - SIMPLIFIED VERSION

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
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
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Navigation items with both languages
    final List<BottomNavItem> navItems = [
      BottomNavItem(
        icon: Icons.home,
        labelBn: 'হোম',
        labelEn: 'Home',
        index: 0,
      ),
      BottomNavItem(
        icon: Icons.menu_book_rounded,
        labelBn: 'শব্দে সূরা',
        labelEn: 'Surah by Word',
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
          children: navItems.map((item) {
            return _buildBottomNavItem(
              context,
              item.icon,
              languageProvider.isEnglish ? item.labelEn : item.labelBn,
              item.index,
              isDarkMode,
              languageProvider,
              isSelected: currentIndex == item.index,
              isDefault: item.index == 0,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    bool isDarkMode,
    LanguageProvider languageProvider, {
    bool isSelected = false,
    bool isDefault = false,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onTap(index),
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
              Text(
                label,
                style: TextStyle(
                  fontSize: responsiveValue(context, 10),
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.green[700]!
                      : (isDarkMode ? Colors.white : Colors.green[700]!),
                  fontFamily: languageProvider.isEnglish
                      ? 'Roboto'
                      : 'HindSiliguri',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
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
