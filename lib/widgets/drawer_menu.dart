// widgets/drawer_menu.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/data_deletion_manager.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/responsive_utils.dart';
import '../screens/admin_login_screen.dart';
import '../screens/support_screen.dart';
import '../screens/about_contact_page.dart';
import '../screens/reward_screen.dart';
import '../prayer_time_page.dart';
import '../developer_page.dart';

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
    final tablet = isTablet(context);

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
        width: tablet ? MediaQuery.of(context).size.width * 0.4 : null,
        backgroundColor: isDarkMode ? Colors.green[900] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context, languageProvider, tablet, isDarkMode),
            _buildDrawerBody(context, languageProvider, themeProvider),
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
    bool tablet,
    bool isDarkMode,
  ) {
    return Container(
      height: responsiveValue(context, tablet ? 100 : 120), // উচ্চতা কমানো
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.green[900]!, Colors.green[700]!]
              : [Colors.green[600]!, Colors.green[400]!],
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: responsiveValue(context, tablet ? 20 : 25), // ছোট করা
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.menu_book,
                  size: responsiveValue(context, tablet ? 25 : 28), // ছোট করা
                  color: Colors.green[800],
                ),
              ),
              const ResponsiveSizedBox(height: 6), // গ্যাপ কমানো
              // প্রথম টেক্সট
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveValue(context, 12),
                ),
                child: ResponsiveText(
                  languageProvider.isEnglish
                      ? 'Islamic Day - Global Bangladesh'
                      : 'ইসলামিক ডে - Islamic Day',
                  fontSize: 14, // ফন্ট সাইজ ছোট করা
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ),

              const ResponsiveSizedBox(height: 4), // গ্যাপ কমানো
              // দ্বিতীয় টেক্সট
              if (!tablet)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveValue(context, 16),
                  ),
                  child: ResponsiveText(
                    languageProvider.isEnglish
                        ? 'For the Global Bangladeshi Community'
                        : 'বিশ্বব্যাপী বাংলাদেশী কমিউনিটির জন্য',
                    fontSize: 10, // ফন্ট সাইজ ছোট করা
                    color: Colors.white70,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerBody(
    BuildContext context,
    LanguageProvider languageProvider,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        _buildShareAppItem(context, languageProvider),
        _buildDivider(),

        _buildDrawerItem(
          context,
          Icons.mosque,
          languageProvider.isEnglish ? 'Prayer Time' : 'নামাজের সময়',
          const PrayerTimePage(),
        ),
        _buildDivider(),

        _buildDrawerItem(
          context,
          Icons.mosque,
          languageProvider.isEnglish ? 'Nearby Mosques' : 'নিকটবর্তী মসজিদ',
          null,
          url: 'https://www.google.com/maps/search/?api=1&query=মসজিদ',
        ),
        _buildDivider(),

        _buildDrawerItem(
          context,
          Icons.person,
          languageProvider.isEnglish ? 'Rewards' : 'পুরস্কার',
          const RewardScreen(),
        ),
        _buildDivider(),

        _buildDrawerItem(
          context,
          Icons.contact_page,
          languageProvider.isEnglish ? 'About & Contact' : 'আমাদের সম্পর্কে',
          const AboutContactPage(),
        ),
        _buildDivider(),

        _buildLanguageSwitchItem(context, languageProvider),
        _buildDivider(),

        _buildDrawerItem(
          context,
          Icons.volunteer_activism,
          languageProvider.isEnglish ? 'Support Us' : 'সাপোর্ট করুন',
          const SupportScreen(),
        ),
        _buildDivider(),

        _buildDrawerItem(
          context,
          Icons.developer_mode,
          languageProvider.isEnglish ? 'Developer' : 'ডেভেলপার',
          DeveloperPage(),
        ),
        _buildDivider(),

        if (_showAdminPanel) _buildAdminPanelItem(context, languageProvider),

        _buildDrawerItem(
          context,
          Icons.privacy_tip,
          'Privacy Policy',
          null,
          url: 'https://sites.google.com/view/islamicquize/home',
        ),
        _buildDivider(),

        _buildDataDeletionItem(context, languageProvider),
        _buildDivider(),

        _buildThemeSwitchItem(context, languageProvider, themeProvider),
      ],
    );
  }

  // ডিভাইডার widget - গ্যাপ কমাতে
  Widget _buildDivider() {
    return Divider(
      height: 1,
      // উচ্চতা কমানো
      thickness: 0.5,
      // পাতলা করা
      color: Colors.grey.withOpacity(0.2),
      indent: 16,
      endIndent: 16,
    );
  }

  // শেয়ার আইটেম - কম্প্যাক্ট ভার্সন
  Widget _buildShareAppItem(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      dense: true,
      // dense=true দিয়ে উচ্চতা কমানো
      contentPadding: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 12),
        vertical: responsiveValue(context, 4), // ভার্টিকাল প্যাডিং কমানো
      ),
      leading: Container(
        padding: EdgeInsets.all(responsiveValue(context, 6)), // প্যাডিং কমানো
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.share_rounded,
          color: Colors.blue,
          size: responsiveValue(context, 20), // আইকন সাইজ ছোট করা
        ),
      ),
      title: ResponsiveText(
        languageProvider.isEnglish ? 'Share App' : 'অ্যাপ শেয়ার করুন',
        fontSize: 14, // ফন্ট সাইজ ছোট করা
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: responsiveValue(context, 14), // ছোট করা
        color: isDark ? Colors.white70 : Colors.green[700]!,
      ),
      onTap: () {
        Navigator.pop(context);
        _shareApp(context);
      },
    );
  }

  // এডমিন প্যানেল আইটেম - কম্প্যাক্ট
  Widget _buildAdminPanelItem(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildDivider(),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: responsiveValue(context, 12),
            vertical: responsiveValue(context, 4),
          ),
          leading: Icon(
            Icons.admin_panel_settings,
            color: Colors.green[700],
            size: responsiveValue(context, 20),
          ),
          title: ResponsiveText(
            languageProvider.isEnglish ? 'Admin Panel' : 'এডমিন প্যানেল',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: responsiveValue(context, 14),
            color: isDark ? Colors.white70 : Colors.green[700]!,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
            );
          },
        ),
        _buildDivider(),
      ],
    );
  }

  // মূল ড্রয়ার আইটেম বিল্ডার - সবগুলো একই স্টাইল
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget? page, {
    String? url,
    Function()? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      dense: true,
      // dense=true যোগ করা
      contentPadding: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 12),
        vertical: responsiveValue(context, 4), // ভার্টিকাল প্যাডিং কমানো
      ),
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.green[700],
        size: responsiveValue(context, 20), // আইকন সাইজ ছোট করা
      ),
      title: ResponsiveText(
        title,
        fontSize: 14, // সবগুলোর ফন্ট সাইজ 14
        fontWeight: FontWeight.w500, // সবগুলোর একই ফন্ট ওয়েট
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: responsiveValue(context, 14), // ছোট করা
        color: isDark ? Colors.white70 : Colors.green[700]!,
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

  // ভাষা সুইচ আইটেম - কম্প্যাক্ট
  Widget _buildLanguageSwitchItem(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 12),
        vertical: responsiveValue(context, 4),
      ),
      leading: Icon(
        Icons.language,
        color: isDark ? Colors.white70 : Colors.green[700],
        size: responsiveValue(context, 20),
      ),
      title: ResponsiveText(
        languageProvider.isEnglish ? 'Language' : 'ভাষা',
        fontSize: 14, // একই ফন্ট সাইজ
        fontWeight: FontWeight.w500, // একই ফন্ট ওয়েট
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Switch(
        value: languageProvider.isEnglish,
        onChanged: (value) => languageProvider.toggleLanguage(),
        activeColor: Colors.green[700],
        activeTrackColor: Colors.green[300],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // ডেটা ডিলিশন আইটেম - কম্প্যাক্ট
  Widget _buildDataDeletionItem(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 12),
        vertical: responsiveValue(context, 4),
      ),
      leading: Icon(
        Icons.delete_forever,
        color: isDark ? Colors.white70 : Colors.green[700],
        size: responsiveValue(context, 20),
      ),
      title: ResponsiveText(
        languageProvider.isEnglish ? 'Delete All Data' : 'সব তথ্য মুছুন',
        fontSize: 14, // একই ফন্ট সাইজ
        fontWeight: FontWeight.w500, // একই ফন্ট ওয়েট
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: responsiveValue(context, 14),
        color: Colors.green[700],
      ),
      onTap: () {
        Navigator.pop(context);
        DataDeletionManager.showDeleteDataDialog(context);
      },
    );
  }

  // থিম সুইচ আইটেম - কম্প্যাক্ট
  Widget _buildThemeSwitchItem(
    BuildContext context,
    LanguageProvider languageProvider,
    ThemeProvider themeProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 12),
        vertical: responsiveValue(context, 4),
      ),
      leading: Icon(
        Icons.brightness_6,
        color: isDark ? Colors.white70 : Colors.green[700]!,
        size: responsiveValue(context, 20),
      ),
      title: ResponsiveText(
        languageProvider.isEnglish ? 'Dark Mode' : 'ডার্ক মোড',
        fontSize: 14, // একই ফন্ট সাইজ
        fontWeight: FontWeight.w500, // একই ফন্ট ওয়েট
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) => themeProvider.toggleTheme(value),
        activeColor: Colors.green[700],
        activeTrackColor: Colors.green[300],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
