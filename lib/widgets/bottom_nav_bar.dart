// lib/widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
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
              Icons.person,
              'আমার প্রোফাইল',
              3,
              isDarkMode,
              isSelected: currentIndex == 3,
            ),
            _buildBottomNavItem(
              context,
              Icons.star,
              'রেটিং',
              1,
              isDarkMode,
              isSelected: currentIndex == 1,
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
        onTap: () => onTap(index), // ✅ শুধুমাত্র onTap কল করুন
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
                  color: isSelected
                      ? Colors.green[700]!
                      : (isDarkMode ? Colors.white : Colors.green[700]!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
