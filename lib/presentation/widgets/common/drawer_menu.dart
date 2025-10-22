// widgets/drawer_menu.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/data_deletion_manager.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../screens/admin_login_screen.dart';
import '../../screens/support_screen.dart';
import '../../screens/about_contact_page.dart';
import '../../screens/reward_screen.dart';
import '../../features/prayer/prayer_time_page.dart';
import '../../screens/developer_page.dart';

class DrawerMenu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const DrawerMenu({super.key, required this.scaffoldKey});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  bool _showAdminPanel = false;
  DateTime? _pressStartTime;
  bool _isLongPressing = false;

  void _handleAdminAccess() {
    setState(() {
      _showAdminPanel = true;
    });

    Future.delayed(const Duration(minutes: 30), () {
      if (mounted) {
        setState(() {
          _showAdminPanel = false;
        });
      }
    });
  }

  void _shareApp(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    final String shareText = languageProvider.isEnglish
        ? "🌟 Discover the amazing Islamic Day App! 📱\n\n"
              "• Learn Quran & Hadith\n"
              "• Test your Islamic knowledge\n"
              "• Word by Word Quran learning\n"
              "• Beautiful Islamic content\n"
              "• Prayer times & Nearby Mosques\n\n"
              "Download now and enhance your Islamic knowledge! 🕌"
        : "🌟 অবিশ্বাস্য ইসলামিক ডে অ্যাপটি ডিসকভার করুন! 📱\n\n"
              "• কুরআন ও হাদিস শিখুন\n"
              "• আপনার ইসলামিক জ্ঞান পরীক্ষা করুন\n"
              "• শব্দে শব্দে কুরআন শেখা\n"
              "• সুন্দর ইসলামিক কন্টেন্ট\n"
              "• নামাজের সময় ও কাছের মসজিদ\n\n"
              "এখনই ডাউনলোড করুন এবং আপনার ইসলামিক জ্ঞান বাড়ান! 🕌";

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallPhone = screenSize.height < 600;

    return GestureDetector(
      onTapDown: (_) {
        _pressStartTime = DateTime.now();
        _isLongPressing = true;
        _startLongPressCheck();
      },
      onTapUp: (_) {
        _isLongPressing = false;
      },
      onTapCancel: () {
        _isLongPressing = false;
      },
      child: Drawer(
        width: isTablet ? screenSize.width * 0.4 : null,
        backgroundColor: isDarkMode ? _Colors.darkSurface : Colors.white,
        child: Column(
          children: [
            _buildDrawerHeader(
              context,
              languageProvider,
              isTablet,
              isSmallPhone,
              isDarkMode,
            ),
            _buildDrawerBody(
              context,
              languageProvider,
              themeProvider,
              isSmallPhone,
            ),
          ],
        ),
      ),
    );
  }

  void _startLongPressCheck() async {
    final startTime = _pressStartTime;
    if (startTime == null) return;

    await Future.delayed(const Duration(seconds: 5));

    if (_isLongPressing && _pressStartTime == startTime && mounted) {
      _isLongPressing = false;
      _handleAdminAccess();
    }
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    LanguageProvider languageProvider,
    bool isTablet,
    bool isSmallPhone,
    bool isDarkMode,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    // ডিভাইসের স্ক্রিন সাইজ অনুযায়ী হাইট সেট করা
    double headerHeight;
    if (isTablet) {
      headerHeight = screenHeight * 0.14; // ট্যাবলেটের জন্য 14%
    } else if (isSmallPhone) {
      headerHeight = screenHeight * 0.16; // ছোট ফোনের জন্য 16%
    } else {
      headerHeight = screenHeight * 0.18; // সাধারণ ফোনের জন্য 18%
    }

    // ফন্ট সাইজ ডাইনামিকভাবে সেট করা
    double titleFontSize = isTablet ? 16 : (isSmallPhone ? 12 : 14);
    double subtitleFontSize = isTablet ? 12 : (isSmallPhone ? 9 : 10);
    double iconSize = isTablet ? 30 : (isSmallPhone ? 22 : 26);
    double avatarRadius = isTablet ? 25 : (isSmallPhone ? 18 : 22);

    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? _Colors.darkHeaderGradient
              : _Colors.lightHeaderGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // আইকন সেকশন
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.menu_book,
                  size: iconSize,
                  color: isDarkMode ? _Colors.darkPrimary : Colors.green[800],
                ),
              ),

              SizedBox(height: isSmallPhone ? 4 : 6),

              // প্রধান টাইটেল
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 8 : 12,
                ),
                child: Text(
                  languageProvider.isEnglish
                      ? 'Islamic Day - Global Bangladesh'
                      : 'ইসলামিক ডে - Islamic Day',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // সাবটাইটেল (শুধুমাত্র ট্যাবলেট এবং বড় ফোনে দেখাবে)
              if (!isSmallPhone) SizedBox(height: isTablet ? 6 : 4),

              if (!isSmallPhone)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
                  child: Text(
                    languageProvider.isEnglish
                        ? 'For the Global Bangladeshi Community'
                        : 'বিশ্বব্যাপী বাংলাদেশী কমিউনিটির জন্য',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.white70,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerBody(
    BuildContext context,
    LanguageProvider languageProvider,
    ThemeProvider themeProvider,
    bool isSmallPhone,
  ) {
    final isDarkMode = themeProvider.isDarkMode;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _Colors.darkBackgroundGradient,
                )
              : null,
          color: isDarkMode ? null : Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildShareAppItem(context, languageProvider, isSmallPhone),
            _buildDivider(isDarkMode),

            _buildDrawerItem(
              context,
              Icons.access_time_rounded,
              languageProvider.isEnglish ? 'Prayer Time' : 'নামাজের সময়',
              const PrayerTimePage(),
              isDarkMode: isDarkMode,
              isSmallPhone: isSmallPhone,
            ),
            _buildDivider(isDarkMode),

            // ✅ FIXED: Nearby Mosques - Language specific search
            _buildDrawerItem(
              context,
              Icons.mosque_rounded,
              languageProvider.isEnglish ? 'Nearby Mosques' : 'নিকটবর্তী মসজিদ',
              null,
              isDarkMode: isDarkMode,
              isSmallPhone: isSmallPhone,
              url: languageProvider.isEnglish
                  ? 'https://www.google.com/maps/search/?api=1&query=Mosque'
                  : 'https://www.google.com/maps/search/?api=1&query=মসজিদ',
            ),
            _buildDivider(isDarkMode),

            _buildDrawerItem(
              context,
              Icons.emoji_events_rounded,
              languageProvider.isEnglish ? 'Rewards' : 'পুরস্কার',
              const RewardScreen(),
              isDarkMode: isDarkMode,
              isSmallPhone: isSmallPhone,
            ),
            _buildDivider(isDarkMode),

            _buildDrawerItem(
              context,
              Icons.contact_page_rounded,
              languageProvider.isEnglish
                  ? 'About & Contact'
                  : 'আমাদের সম্পর্কে',
              const AboutContactPage(),
              isDarkMode: isDarkMode,
              isSmallPhone: isSmallPhone,
            ),
            _buildDivider(isDarkMode),

            _buildLanguageSwitchItem(
              context,
              languageProvider,
              isDarkMode,
              isSmallPhone,
            ),
            _buildDivider(isDarkMode),

            _buildDrawerItem(
              context,
              Icons.volunteer_activism_rounded,
              languageProvider.isEnglish ? 'Support Us' : 'সাপোর্ট করুন',
              const SupportScreen(),
              isDarkMode: isDarkMode,
              isSmallPhone: isSmallPhone,
            ),
            _buildDivider(isDarkMode),

            _buildDrawerItem(
              context,
              Icons.developer_mode_rounded,
              languageProvider.isEnglish ? 'Developer' : 'ডেভেলপার',
              DeveloperPage(),
              isDarkMode: isDarkMode,
              isSmallPhone: isSmallPhone,
            ),
            _buildDivider(isDarkMode),

            if (_showAdminPanel)
              _buildAdminPanelItem(
                context,
                languageProvider,
                isDarkMode,
                isSmallPhone,
              ),

            _buildDrawerItem(
              context,
              Icons.privacy_tip_rounded,
              'Privacy Policy',
              null,
              isDarkMode: isDarkMode,
              isSmallPhone: isSmallPhone,
              url: 'https://sites.google.com/view/islamicquize/home',
            ),
            _buildDivider(isDarkMode),

            _buildDataDeletionItem(
              context,
              languageProvider,
              isDarkMode,
              isSmallPhone,
            ),
            _buildDivider(isDarkMode),

            _buildThemeSwitchItem(
              context,
              languageProvider,
              themeProvider,
              isDarkMode,
              isSmallPhone,
            ),
          ],
        ),
      ),
    );
  }

  // ডিভাইডার widget - ডার্ক মুড সাপোর্ট সহ
  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: isDarkMode ? _Colors.darkBorder : Colors.grey.withOpacity(0.2),
      indent: 16,
      endIndent: 16,
    );
  }

  // শেয়ার আইটেম - ডার্ক মুড অপটিমাইজড
  Widget _buildShareAppItem(
    BuildContext context,
    LanguageProvider languageProvider,
    bool isSmallPhone,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 8 : 12,
        vertical: isSmallPhone ? 2 : 4,
      ),
      leading: Container(
        padding: EdgeInsets.all(isSmallPhone ? 4 : 6),
        decoration: BoxDecoration(
          color: isDarkMode
              ? _Colors.darkBlueAccent.withOpacity(0.2)
              : Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.share_rounded,
          color: isDarkMode ? _Colors.darkBlueAccent : Colors.blue,
          size: isSmallPhone ? 16 : 20,
        ),
      ),
      title: Text(
        languageProvider.isEnglish ? 'Share App' : 'অ্যাপ শেয়ার করুন',
        style: TextStyle(
          fontSize: isSmallPhone ? 12 : 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? _Colors.darkText : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: isSmallPhone ? 12 : 14,
        color: isDarkMode ? _Colors.darkTextSecondary : Colors.green[700]!,
      ),
      onTap: () {
        Navigator.pop(context);
        _shareApp(context);
      },
    );
  }

  // এডমিন প্যানেল আইটেম - ডার্ক মুড অপটিমাইজড
  Widget _buildAdminPanelItem(
    BuildContext context,
    LanguageProvider languageProvider,
    bool isDarkMode,
    bool isSmallPhone,
  ) {
    return Column(
      children: [
        _buildDivider(isDarkMode),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 8 : 12,
            vertical: isSmallPhone ? 2 : 4,
          ),
          leading: Container(
            padding: EdgeInsets.all(isSmallPhone ? 4 : 6),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? _Colors.darkPrimary.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: isDarkMode ? _Colors.darkPrimary : Colors.green[700],
              size: isSmallPhone ? 16 : 20,
            ),
          ),
          title: Text(
            languageProvider.isEnglish ? 'Admin Panel' : 'এডমিন প্যানেল',
            style: TextStyle(
              fontSize: isSmallPhone ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? _Colors.darkText : Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: isSmallPhone ? 12 : 14,
            color: isDarkMode ? _Colors.darkTextSecondary : Colors.green[700]!,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
            );
          },
        ),
        _buildDivider(isDarkMode),
      ],
    );
  }

  // মূল ড্রয়ার আইটেম বিল্ডার - ডার্ক মুড অপটিমাইজড
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget? page, {
    required bool isDarkMode,
    required bool isSmallPhone,
    String? url,
    Function()? onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 8 : 12,
        vertical: isSmallPhone ? 2 : 4,
      ),
      leading: Container(
        padding: EdgeInsets.all(isSmallPhone ? 4 : 6),
        decoration: BoxDecoration(
          color: isDarkMode
              ? _Colors.darkPrimary.withOpacity(0.15)
              : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? _Colors.darkPrimary : Colors.green[700],
          size: isSmallPhone ? 16 : 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isSmallPhone ? 12 : 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? _Colors.darkText : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: isSmallPhone ? 12 : 14,
        color: isDarkMode ? _Colors.darkTextSecondary : Colors.green[700]!,
      ),
      onTap: onTap ?? () => _handleDrawerItemTap(context, page, url),
    );
  }

  void _handleDrawerItemTap(
    BuildContext context,
    Widget? page,
    String? url,
  ) async {
    Navigator.pop(context);
    if (url != null) {
      await _launchUrl(context, url);
    } else if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  // ভাষা সুইচ আইটেম - ডার্ক মুড অপটিমাইজড
  Widget _buildLanguageSwitchItem(
    BuildContext context,
    LanguageProvider languageProvider,
    bool isDarkMode,
    bool isSmallPhone,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 8 : 12,
        vertical: isSmallPhone ? 2 : 4,
      ),
      leading: Container(
        padding: EdgeInsets.all(isSmallPhone ? 4 : 6),
        decoration: BoxDecoration(
          color: isDarkMode
              ? _Colors.darkPurpleAccent.withOpacity(0.2)
              : Colors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.language_rounded,
          color: isDarkMode ? _Colors.darkPurpleAccent : Colors.purple,
          size: isSmallPhone ? 16 : 20,
        ),
      ),
      title: Text(
        languageProvider.isEnglish ? 'Language' : 'ভাষা',
        style: TextStyle(
          fontSize: isSmallPhone ? 12 : 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? _Colors.darkText : Colors.black87,
        ),
      ),
      trailing: Switch(
        value: languageProvider.isEnglish,
        onChanged: (value) => languageProvider.toggleLanguage(),
        activeColor: isDarkMode ? _Colors.darkPrimary : Colors.green[700],
        activeTrackColor: isDarkMode
            ? _Colors.darkPrimary.withOpacity(0.5)
            : Colors.green[300],
        inactiveThumbColor: isDarkMode
            ? _Colors.darkTextSecondary
            : Colors.grey[400],
        inactiveTrackColor: isDarkMode ? _Colors.darkBorder : Colors.grey[300],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // ডেটা ডিলিশন আইটেম - ডার্ক মুড অপটিমাইজড
  Widget _buildDataDeletionItem(
    BuildContext context,
    LanguageProvider languageProvider,
    bool isDarkMode,
    bool isSmallPhone,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 8 : 12,
        vertical: isSmallPhone ? 2 : 4,
      ),
      leading: Container(
        padding: EdgeInsets.all(isSmallPhone ? 4 : 6),
        decoration: BoxDecoration(
          color: isDarkMode
              ? _Colors.darkError.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.delete_forever_rounded,
          color: isDarkMode ? _Colors.darkError : Colors.red,
          size: isSmallPhone ? 16 : 20,
        ),
      ),
      title: Text(
        languageProvider.isEnglish ? 'Delete All Data' : 'সব তথ্য মুছুন',
        style: TextStyle(
          fontSize: isSmallPhone ? 12 : 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? _Colors.darkText : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: isSmallPhone ? 12 : 14,
        color: isDarkMode ? _Colors.darkTextSecondary : Colors.green[700]!,
      ),
      onTap: () {
        Navigator.pop(context);
        DataDeletionManager.showDeleteDataDialog(context);
      },
    );
  }

  // থিম সুইচ আইটেম - ডার্ক মুড অপটিমাইজড
  Widget _buildThemeSwitchItem(
    BuildContext context,
    LanguageProvider languageProvider,
    ThemeProvider themeProvider,
    bool isDarkMode,
    bool isSmallPhone,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 8 : 12,
        vertical: isSmallPhone ? 2 : 4,
      ),
      leading: Container(
        padding: EdgeInsets.all(isSmallPhone ? 4 : 6),
        decoration: BoxDecoration(
          color: isDarkMode
              ? _Colors.darkOrangeAccent.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.brightness_6_rounded,
          color: isDarkMode ? _Colors.darkOrangeAccent : Colors.orange,
          size: isSmallPhone ? 16 : 20,
        ),
      ),
      title: Text(
        languageProvider.isEnglish ? 'Dark Mode' : 'ডার্ক মোড',
        style: TextStyle(
          fontSize: isSmallPhone ? 12 : 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? _Colors.darkText : Colors.black87,
        ),
      ),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) => themeProvider.toggleTheme(value),
        activeColor: isDarkMode ? _Colors.darkPrimary : Colors.green[700],
        activeTrackColor: isDarkMode
            ? _Colors.darkPrimary.withOpacity(0.5)
            : Colors.green[300],
        inactiveThumbColor: isDarkMode
            ? _Colors.darkTextSecondary
            : Colors.grey[400],
        inactiveTrackColor: isDarkMode ? _Colors.darkBorder : Colors.grey[300],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
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

  static const List<Color> darkHeaderGradient = [
    Color(0xFF065F46), // Dark Emerald
    Color(0xFF059669), // Emerald
  ];

  // Dark Mode Accent Colors
  static const Color darkBlueAccent = Color(0xFF60A5FA);
  static const Color darkGreenAccent = Color(0xFF34D399);
  static const Color darkPurpleAccent = Color(0xFFA78BFA);
  static const Color darkOrangeAccent = Color(0xFFFB923C);

  // Dark Mode Border
  static const Color darkBorder = Color(0xFF4B5563);

  // Light Mode Colors - ✅ UPDATED: Green 900 for light mode header
  static const List<Color> lightHeaderGradient = [
    Color(0xFF1B5E20), // Green 900 - Darker Green
    Color(0xFF2E7D32), // Green 800
  ];

  static const List<Color> lightBackgroundGradient = [
    Color(0xFFF0FDF4), // Very Light Green
    Color(0xFFDCFCE7), // Light Green
  ];
}
