// lib/utils/app_colors.dart - ইউনিফাইড কালার সিস্টেম
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/theme_provider.dart';

class AppColors {
  // ==================== DARK MODE COLORS ====================
  // Professional Islamic Dark Theme - হোম পেইজের মতো
  static const Color darkPrimary = Color(0xFF10B981); // Emerald Green
  static const Color darkPrimaryVariant = Color(0xFF059669); // Darker Emerald
  static const Color darkAppBar = Color(
    0xFF065F46,
  ); // Dark Emerald - AppBar Color
  static const Color darkSecondary = Color(0xFF8B5CF6); // Violet
  static const Color darkBackground = Color(0xFF111827); // Dark Blue-Gray
  static const Color darkSurface = Color(0xFF1F2937); // Dark Gray
  static const Color darkCard = Color(0xFF374151); // Medium Gray
  static const Color darkError = Color(0xFFEF4444); // Red
  static const Color darkText = Color(0xFFF9FAFB); // White
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // Light Gray
  static const Color darkBorder = Color(0xFF4B5563); // Border Color

  // Dark Mode Gradients
  static const List<Color> darkBackgroundGradient = [
    Color(0xFF111827), // Dark Blue-Gray
    Color(0xFF1F2937), // Dark Gray
  ];

  static const List<Color> darkHeaderGradient = [
    Color(0xFF065F46), // Dark Emerald
    Color(0xFF059669), // Emerald
  ];

  // Dark Mode Accent Colors
  static const Color darkBlueAccent = Color(0xFF60A5FA);
  static const Color darkGreenAccent = Color(0xFF34D399);
  static const Color darkPurpleAccent = Color(0xFFA78BFA);
  static const Color darkOrangeAccent = Color(0xFFFB923C);

  // ==================== LIGHT MODE COLORS ====================
  // সুরা পেইজের লাইট মুডের মতো কালার
  static const Color lightPrimary = Color(0xFF2E7D32); // Nature Green
  static const Color lightPrimaryVariant = Color(0xFF1B5E20); // Darker Green
  static const Color lightAppBar = Color(0xFF2E7D32); // AppBar Color
  static const Color lightSecondary = Color(0xFF7E57C2); // Purple
  static const Color lightBackground = Color(0xFFFAFAFA); // Very Light Gray
  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightCard = Color(0xFFFFFFFF); // White Card
  static const Color lightError = Color(0xFFD32F2F); // Red
  static const Color lightText = Color(0xFF37474F); // Dark Gray
  static const Color lightTextSecondary = Color(0xFF546E7A); // Medium Gray
  static const Color lightBorder = Color(0xFFE0E0E0); // Light Gray Border

  // Light Mode Gradients
  static const List<Color> lightBackgroundGradient = [
    Color(0xFFFAFAFA), // Very Light Gray
    Color(0xFFF5F5F5), // Light Gray
  ];

  static const List<Color> lightHeaderGradient = [
    Color(0xFF2E7D32), // Nature Green
    Color(0xFF4CAF50), // Light Green
  ];

  // Light Mode Accent Colors
  static const Color lightBlueAccent = Color(0xFF1976D2);
  static const Color lightGreenAccent = Color(0xFF388E3C);
  static const Color lightPurpleAccent = Color(0xFF7B1FA2);
  static const Color lightOrangeAccent = Color(0xFFF57C00);

  // ==================== HELPER METHODS ====================

  // অ্যাপবার কালার পাওয়ার জন্য
  static Color getAppBarColor(bool isDarkMode) {
    return isDarkMode ? darkAppBar : lightAppBar;
  }

  // ব্যাকগ্রাউন্ড কালার পাওয়ার জন্য
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? darkBackground : lightBackground;
  }

  // ব্যাকগ্রাউন্ড গ্রেডিয়েন্ট পাওয়ার জন্য
  static List<Color> getBackgroundGradient(bool isDarkMode) {
    return isDarkMode ? darkBackgroundGradient : lightBackgroundGradient;
  }

  // কার্ড কালার পাওয়ার জন্য
  static Color getCardColor(bool isDarkMode) {
    return isDarkMode ? darkCard : lightCard;
  }

  // সারফেস কালার পাওয়ার জন্য
  static Color getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? darkSurface : lightSurface;
  }

  // প্রাইমারী টেক্সট কালার পাওয়ার জন্য
  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? darkText : lightText;
  }

  // সেকেন্ডারী টেক্সট কালার পাওয়ার জন্য
  static Color getTextSecondaryColor(bool isDarkMode) {
    return isDarkMode ? darkTextSecondary : lightTextSecondary;
  }

  // প্রাইমারী কালার পাওয়ার জন্য
  static Color getPrimaryColor(bool isDarkMode) {
    return isDarkMode ? darkPrimary : lightPrimary;
  }

  // বর্ডার কালার পাওয়ার জন্য
  static Color getBorderColor(bool isDarkMode) {
    return isDarkMode ? darkBorder : lightBorder;
  }

  // এরর কালার পাওয়ার জন্য
  static Color getErrorColor(bool isDarkMode) {
    return isDarkMode ? darkError : lightError;
  }

  // একসেন্ট কালার পাওয়ার জন্য (বিভিন্ন টাইপ)
  static Color getAccentColor(String type, bool isDarkMode) {
    switch (type) {
      case 'blue':
        return isDarkMode ? darkBlueAccent : lightBlueAccent;
      case 'green':
        return isDarkMode ? darkGreenAccent : lightGreenAccent;
      case 'purple':
        return isDarkMode ? darkPurpleAccent : lightPurpleAccent;
      case 'orange':
        return isDarkMode ? darkOrangeAccent : lightOrangeAccent;
      default:
        return isDarkMode ? darkPrimary : lightPrimary;
    }
  }
}

// ==================== QUICK USAGE HELPER ====================
class ThemeHelper {
  static Color appBar(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return AppColors.getAppBarColor(themeProvider.isDarkMode);
  }

  static Color background(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return AppColors.getBackgroundColor(themeProvider.isDarkMode);
  }

  static List<Color> backgroundGradient(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return AppColors.getBackgroundGradient(themeProvider.isDarkMode);
  }

  static Color card(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return AppColors.getCardColor(themeProvider.isDarkMode);
  }

  static Color text(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return AppColors.getTextColor(themeProvider.isDarkMode);
  }

  static Color textSecondary(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return AppColors.getTextSecondaryColor(themeProvider.isDarkMode);
  }

  static Color primary(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return AppColors.getPrimaryColor(themeProvider.isDarkMode);
  }
}
