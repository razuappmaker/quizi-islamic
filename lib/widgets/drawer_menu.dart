// widgets/drawer_menu.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart'; // ✅ নতুন প্যাকেজ যোগ করুন

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

    // 30 মিনিট পর অটো হাইড
    Future.delayed(const Duration(minutes: 30), () {
      if (mounted) {
        setState(() {
          _showAdminPanel = false;
        });
      }
    });
  }

  // ✅ নতুন শেয়ার ফাংশন যোগ করুন
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

    // 5 সেকেন্ড পর চেক করুন
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
      height: responsiveValue(context, tablet ? 120 : 140),
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
                radius: responsiveValue(context, tablet ? 25 : 30),
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.menu_book,
                  size: responsiveValue(context, tablet ? 30 : 34),
                  color: Colors.green[800],
                ),
              ),
              const ResponsiveSizedBox(height: 10),

              // প্রথম টেক্সট - প্যাডিং সহ
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveValue(context, 16),
                ),
                child: ResponsiveText(
                  languageProvider.isEnglish
                      ? 'Islamic Day - Global Bangladesh'
                      : 'ইসলামিক ডে - Islamic Day',
                  fontSize: 18, // ফন্ট একটু ছোট করা হলো
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ),

              const ResponsiveSizedBox(height: 8),

              // দ্বিতীয় টেক্সট - শুধু ট্যাবলেট না হলে
              if (!tablet)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveValue(context, 20),
                  ),
                  child: ResponsiveText(
                    languageProvider.isEnglish
                        ? 'For the Global Bangladeshi Community'
                        : 'বিশ্বব্যাপী বাংলাদেশী কমিউনিটির জন্য',
                    fontSize: 11, // ফন্ট একটু ছোট করা হলো
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
        // ✅ নতুন শেয়ার বাটন যোগ করুন - প্রথম আইটেম হিসেবে
        _buildShareAppItem(context, languageProvider),

        _buildDrawerItem(
          context,
          Icons.mosque,
          languageProvider.isEnglish ? 'Prayer Time' : 'নামাজের সময়',
          const PrayerTimePage(),
        ),

        _buildDrawerItem(
          context,
          Icons.mosque,
          languageProvider.isEnglish ? 'Nearby Mosques' : 'নিকটবর্তী মসজিদ',
          null,
          url: 'https://www.google.com/maps/search/?api=1&query=মসজিদ',
        ),
        _buildDrawerItem(
          context,
          Icons.person,
          languageProvider.isEnglish ? 'Rewards' : 'পুরস্কার',
          const RewardScreen(),
        ),
        // drawer_menu.dart - শুধু একটি আইটেম রাখুন
        _buildDrawerItem(
          context,
          Icons.contact_page, // অথবা Icons.info
          languageProvider.isEnglish ? 'About & Contact' : 'আমাদের সম্পর্কে',
          const AboutContactPage(), // নতুন combined page
        ),
        _buildLanguageSwitchItem(context, languageProvider),
        _buildDrawerItem(
          context,
          Icons.volunteer_activism,
          languageProvider.isEnglish ? 'Support Us' : 'সাপোর্ট করুন',
          const SupportScreen(),
        ),

        _buildDrawerItem(
          context,
          Icons.developer_mode,
          languageProvider.isEnglish ? 'Developer' : 'ডেভেলপার',
          DeveloperPage(),
        ),

        // ✅ শুধুমাত্র লং প্রেস করলে এডমিন প্যানেল দেখাবে
        if (_showAdminPanel) _buildAdminPanelItem(context, languageProvider),

        _buildDrawerItem(
          context,
          Icons.privacy_tip,
          'Privacy Policy',
          null,
          url: 'https://sites.google.com/view/islamicquize/home',
        ),
        _buildDataDeletionItem(context, languageProvider),
        _buildThemeSwitchItem(context, languageProvider, themeProvider),
      ],
    );
  }

  // ✅ নতুন শেয়ার আইটেম বিল্ডার
  Widget _buildShareAppItem(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(responsiveValue(context, 8)),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.share_rounded,
          color: Colors.blue,
          size: responsiveValue(context, 24),
        ),
      ),
      title: ResponsiveText(
        languageProvider.isEnglish ? 'Share App' : 'অ্যাপ শেয়ার করুন',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
      subtitle: Text(
        languageProvider.isEnglish
            ? 'Share with friends & family'
            : 'বন্ধু ও পরিবারের সাথে শেয়ার করুন',
        style: TextStyle(
          fontSize: responsiveValue(context, 12),
          color: isDark ? Colors.white60 : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: responsiveValue(context, 16),
        color: isDark ? Colors.white70 : Colors.green[700]!,
      ),
      onTap: () {
        Navigator.pop(context); // Drawer বন্ধ করুন
        _shareApp(context); // শেয়ার ফাংশন কল করুন
      },
    );
  }

  // ✅ এডমিন প্যানেল আইটেম
  Widget _buildAdminPanelItem(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Divider(
          color: Colors.green.shade200,
          indent: responsiveValue(context, 16),
          endIndent: responsiveValue(context, 16),
        ),
        ListTile(
          leading: Icon(
            Icons.admin_panel_settings,
            color: Colors.green[700],
            size: responsiveValue(context, 24),
          ),
          title: ResponsiveText(
            languageProvider.isEnglish ? 'Admin Panel' : 'এডমিন প্যানেল',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            //color: Colors.green[700],
          ),
          subtitle: Text(
            'Active for 30 minutes',
            style: TextStyle(fontSize: 12, color: Colors.green[600]),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: responsiveValue(context, 16),
            color: isDark ? Colors.white : Colors.green[700]!,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
            );
          },
        ),
        Divider(
          color: Colors.green.shade200,
          indent: responsiveValue(context, 16),
          endIndent: responsiveValue(context, 16),
        ),
      ],
    );
  }

  // ... বাকি মেথডগুলো একই থাকবে
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
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.green[700],
        size: responsiveValue(context, 24),
      ),
      title: ResponsiveText(
        title,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: responsiveValue(context, 16),
        color: isDark ? Colors.white70 : Colors.green[700]!, // ✅ আপডেটেড
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

  Widget _buildLanguageSwitchItem(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isDark ? Colors.white70 : Colors.green[700],
        size: responsiveValue(context, 24),
      ),
      title: ResponsiveText(
        languageProvider.isEnglish ? 'Language' : 'ভাষা',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Switch(
        value: languageProvider.isEnglish,
        onChanged: (value) => languageProvider.toggleLanguage(),
        activeColor: Colors.green[700],
        activeTrackColor: Colors.green[300],
      ),
    );
  }

  Widget _buildDataDeletionItem(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        Icons.delete_forever,
        color: isDark ? Colors.white70 : Colors.green[700],
        size: responsiveValue(context, 24),
      ),
      title: ResponsiveText(
        languageProvider.isEnglish ? 'Delete All Data' : 'সব তথ্য মুছুন',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: responsiveValue(context, 16),
        color: Colors.green[700],
      ),
      onTap: () {
        Navigator.pop(context);
        DataDeletionManager.showDeleteDataDialog(context);
      },
    );
  }

  Widget _buildThemeSwitchItem(
    BuildContext context,
    LanguageProvider languageProvider,
    ThemeProvider themeProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Divider(
          color: Colors.green.shade200,
          indent: responsiveValue(context, 16),
          endIndent: responsiveValue(context, 16),
        ),
        ResponsivePadding(
          horizontal: 12,
          child: Row(
            children: [
              Icon(
                Icons.brightness_6,
                color: isDark ? Colors.white : Colors.green[700]!,
                size: responsiveValue(context, 24),
              ),
              const ResponsiveSizedBox(width: 10),
              ResponsiveText(
                languageProvider.isEnglish ? 'Dark Mode' : 'ডার্ক মোড',
                color: isDark ? Colors.white70 : Colors.green[700]!,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const Spacer(),
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
                activeColor: Colors.green[700],
                activeTrackColor: Colors.green[300],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
