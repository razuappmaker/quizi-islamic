// Support screen - 100% AdMob Compliant Version
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/local_support_service.dart';
import '../screens/premium_screen.dart';
import '../utils/app_colors.dart'; // ✅ AppColors import

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ScrollController _tickerController = ScrollController();
  final LocalSupportService _supportService = LocalSupportService();

  // Dynamic Data from Local Storage
  List<Map<String, dynamic>> _recentSupporters = [];
  int _todaySupporterCount = 0;
  bool _showSupporterTicker = true;
  Timer? _simulationTimer;

  // Language Texts - 100% AdMob Compliant
  final Map<String, Map<String, String>> _texts = {
    'title': {'en': 'App Support', 'bn': 'অ্যাপ সাপোর্ট'},
    'headerTitle': {
      'en': 'Support App Development',
      'bn': 'অ্যাপ ডেভেলপমেন্টে সহায়তা করুন',
    },
    'headerSubtitle': {
      'en': 'Optional support to help improve the app experience',
      'bn': 'অ্যাপের অভিজ্ঞতা উন্নত করতে ঐচ্ছিক সহায়তা',
    },
    'whySupport': {
      'en': 'How Your Support Helps',
      'bn': 'আপনার সহায়তা কীভাবে সাহায্য করে',
    },
    'serverCosts': {'en': 'Server Maintenance', 'bn': 'সার্ভার রক্ষণাবেক্ষণ'},
    'serverDesc': {
      'en': 'Helps keep the app running smoothly',
      'bn': 'অ্যাপটি সচল রাখতে সাহায্য করে',
    },
    'appDevelopment': {'en': 'App Improvements', 'bn': 'অ্যাপ উন্নয়ন'},
    'appDevDesc': {
      'en': 'Enables new features and updates',
      'bn': 'নতুন ফিচার এবং আপডেট সক্ষম করে',
    },
    'security': {'en': 'App Maintenance', 'bn': 'অ্যাপ রক্ষণাবেক্ষণ'},
    'securityDesc': {
      'en': 'Regular updates and bug fixes',
      'bn': 'নিয়মিত আপডেট এবং বাগ ফিক্স',
    },
    'makeDifference': {'en': 'Contribute', 'bn': 'অবদান রাখুন'},
    'supportGooglePlay': {'en': 'In-app Support', 'bn': 'ইন-অ্যাপ সাপোর্ট'},
    'donateWebsite': {'en': 'External Support', 'bn': 'বাহ্যিক সাপোর্ট'},
    'contactInfo': {'en': 'Contact Information', 'bn': 'যোগাযোগের তথ্য'},
    'liveDonations': {'en': 'Community Activity', 'bn': 'কমিউনিটি কার্যক্রম'},
    'supportersToday': {'en': 'Active Today', 'bn': 'আজকের কার্যক্রম'},
    'multipleCurrencies': {
      'en': 'Free Options Available',
      'bn': 'বিনামূল্যের অপশন উপলব্ধ',
    },
    'hideTicker': {'en': 'Hide Activity', 'bn': 'কার্যকলাপ লুকান'},
    'showTicker': {'en': 'Show Activity', 'bn': 'কার্যকলাপ দেখান'},
    'demoDataInfo': {
      'en': 'Shows community engagement examples',
      'bn': 'কমিউনিটি এনগেজমেন্ট উদাহরণ দেখায়',
    },
    'visitWebsite': {'en': 'More Information', 'bn': 'আরও তথ্য'},
    'websiteDialogContent': {
      'en':
          'For additional information about optional support options, visit our website. All app features remain available without support.',
      'bn':
          'ঐচ্ছিক সাপোর্ট অপশন সম্পর্কে অতিরিক্ত তথ্যের জন্য আমাদের ওয়েবসাইট ভিজিট করুন। সমস্ত অ্যাপ ফিচার সাপোর্ট ছাড়াই উপলব্ধ থাকবে।',
    },
    'cancel': {'en': 'Cancel', 'bn': 'বাতিল'},
    'visitWebsiteBtn': {'en': 'Learn More', 'bn': 'আরও জানুন'},
    'linkError': {'en': 'Could not open link', 'bn': 'লিঙ্ক খুলতে ব্যর্থ'},
    'googlePlayMessage': {
      'en': 'Optional in-app support will be implemented here',
      'bn': 'ঐচ্ছিক ইন-অ্যাপ সাপোর্ট এখানে ইমপ্লিমেন্ট করা হবে',
    },
    'rateApp': {'en': 'Rate App', 'bn': 'অ্যাপ রেট করুন'},
    'rateAppSubtitle': {
      'en': 'Free way to support development',
      'bn': 'ডেভেলপমেন্ট সাপোর্টের বিনামূল্যের উপায়',
    },
    'shareApp': {'en': 'Share App', 'bn': 'অ্যাপ শেয়ার করুন'},
    'shareAppSubtitle': {
      'en': 'Help others discover this app',
      'bn': 'অন্যদের এই অ্যাপটি খুঁজে পেতে সাহায্য করুন',
    },
    'removeAds': {'en': 'Ad-Free Experience', 'bn': 'এড-মুক্ত অভিজ্ঞতা'},
    'removeAdsSubtitle': {
      'en': 'Optional ad-free version',
      'bn': 'ঐচ্ছিক এড-মুক্ত ভার্সন',
    },
    'makeDonation': {'en': 'External Support', 'bn': 'বাহ্যিক সহায়তা'},
    'makeDonationSubtitle': {
      'en': 'Optional external support options',
      'bn': 'ঐচ্ছিক বাহ্যিক সহায়তা অপশন',
    },
    'policyNote': {
      'en':
          'All support options are completely voluntary. The app remains fully functional without any support. No features are restricted.',
      'bn':
          'সমস্ত সাপোর্ট অপশন সম্পূর্ণ ঐচ্ছিক। অ্যাপটি কোনো সাপোর্ট ছাড়াই সম্পূর্ণ কার্যকরী থাকবে। কোনো ফিচার সীমাবদ্ধ নেই।',
    },
    'voluntaryNotice': {
      'en': 'VOLUNTARY SUPPORT - NOT REQUIRED',
      'bn': 'ঐচ্ছিক সহায়তা - বাধ্যতামূলক নয়',
    },
    'yourContributions': {'en': 'Your Activity', 'bn': 'আপনার কার্যকলাপ'},
    'communityEngagement': {
      'en': 'Community Engagement',
      'bn': 'কমিউনিটি অংশগ্রহণ',
    },
  };

  // Color getters using AppColors
  Color _primaryColor(BuildContext context) => ThemeHelper.primary(context);

  Color _cardColor(BuildContext context) => ThemeHelper.card(context);

  Color _textColor(BuildContext context) => ThemeHelper.text(context);

  Color _subtitleColor(BuildContext context) =>
      ThemeHelper.textSecondary(context);

  Color _backgroundColor(BuildContext context) =>
      ThemeHelper.background(context);

  @override
  void initState() {
    super.initState();
    _loadSupporters();
    _startActivitySimulation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  // Helper method to get text based on current language
  String _text(String key) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? '';
  }

  // সাপোর্টার লোড করুন
  Future<void> _loadSupporters() async {
    try {
      final supporters = await _supportService.getSupporters();

      // Get dynamic daily activity count
      final todayActivityCount = await _supportService.getTodayActivityCount();

      setState(() {
        _recentSupporters = supporters;
        _todaySupporterCount = todayActivityCount; // Use dynamic count
      });

      print('📊 Today Activity Count: $todayActivityCount');
    } catch (e) {
      print('❌ Error loading supporters: $e');
      // Fallback to basic count
      setState(() {
        _todaySupporterCount = _recentSupporters
            .where((supporter) => _isToday(supporter['timestamp']))
            .length;
      });
    }
  }

  bool _isToday(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Toggle Supporter Ticker Visibility
  void _toggleSupporterTicker() {
    setState(() {
      _showSupporterTicker = !_showSupporterTicker;
    });
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 2), () {
      if (_tickerController.hasClients && mounted && _showSupporterTicker) {
        final maxScroll = _tickerController.position.maxScrollExtent;
        final currentScroll = _tickerController.offset;

        if (currentScroll >= maxScroll) {
          _tickerController.jumpTo(0);
        } else {
          _tickerController.animateTo(
            currentScroll + 50,
            duration: Duration(seconds: 15),
            curve: Curves.linear,
          );
        }
        _startAutoScroll();
      }
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_text('linkError')),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showExternalDonationDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          _text('visitWebsite'),
          style: TextStyle(
            color: isDark ? AppColors.darkPrimary : Colors.green[800],
          ),
        ),
        content: Text(
          _text('websiteDialogContent'),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _text('cancel'),
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _launchURL('https://www.islamicquiz.com/support');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : Colors.green[800],
            ),
            child: Text(_text('visitWebsiteBtn')),
          ),
        ],
      ),
    );
  }

  // ==================== AdMob Compliant Support Methods ====================

  void _rateApp() async {
    // সাপোর্ট একশন রেকর্ড করুন
    await _supportService.recordSupportAction(
      actionType: 'rate',
      actionName: 'Rated the App',
    );

    const url =
        'https://play.google.com/store/apps/details?id=your.package.name';
    _launchURL(url);

    // UI রিফ্রেশ করুন
    _loadSupporters();
  }

  void _shareApp() async {
    // সাপোর্ট একশন রেকর্ড করুন
    await _supportService.recordSupportAction(
      actionType: 'share',
      actionName: 'Shared the App',
    );

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    bool isEnglish = languageProvider.isEnglish;

    String text = isEnglish
        ? 'Check out this useful app: https://play.google.com/store/apps/details?id=your.package.name'
        : 'এই দরকারী অ্যাপটি দেখুন: https://play.google.com/store/apps/details?id=your.package.name';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEnglish
              ? 'Share functionality will be implemented'
              : 'শেয়ার ফাংশনালিটি ইমপ্লিমেন্ট করা হবে',
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // UI রিফ্রেশ করুন
    _loadSupporters();
  }

  void _removeAds(BuildContext context) async {
    // সাপোর্ট একশন রেকর্ড করুন
    await _supportService.recordSupportAction(
      actionType: 'remove_ads',
      actionName: 'Chose Ad-Free',
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RemoveAdsPage()),
    );

    // UI রিফ্রেশ করুন
    _loadSupporters();
  }

  void _makeDonation() async {
    // সাপোর্ট একশন রেকর্ড করুন
    await _supportService.recordSupportAction(
      actionType: 'external_support',
      actionName: 'Viewed External Options',
    );

    _showExternalDonationDialog();

    // UI রিফ্রেশ করুন
    _loadSupporters();
  }

  // ==================== AdMob Compliant Ticker Item ====================
  Widget _buildSupporterTickerItem(Map<String, dynamic> supporter, int index) {
    final String name = supporter['userName'];
    final String country = supporter['country'];
    final String action = supporter['actionName'];
    final bool isCurrentUser = supporter['isCurrentUser'] ?? false;
    final bool isCommunityExample = supporter['isCommunityExample'] ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title = name;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? (isDark
                  ? AppColors.darkPrimary.withOpacity(0.2)
                  : Colors.green[50])
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? (isDark ? AppColors.darkPrimary : Colors.green[300]!)
              : (isDark ? AppColors.darkBorder : Colors.green[100]!),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: isCurrentUser ? Colors.green[100]! : Colors.green[50]!,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCountryColor(country),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCurrentUser
                  ? Icon(Icons.person, color: Colors.white, size: 20)
                  : Text(
                      name.substring(0, 1),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12),

          // Supporter Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title - $country',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isCurrentUser
                        ? (isDark ? AppColors.darkPrimary : Colors.green[800])
                        : (isDark ? AppColors.darkText : Colors.green[900]),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      color: isDark ? AppColors.darkPrimary : Colors.green[600],
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        action,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 8),

          // Action Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getActionColor(supporter['actionType']),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActionIcon(supporter['actionType']),
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Action type অনুযায়ী আইকন
  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'rate':
        return Icons.star;
      case 'share':
        return Icons.share;
      case 'remove_ads':
        return Icons.block;
      case 'external_support':
        return Icons.open_in_new;
      default:
        return Icons.thumb_up;
    }
  }

  // Action type অনুযায়ী কালার
  Color _getActionColor(String actionType) {
    switch (actionType) {
      case 'rate':
        return Colors.orange[600]!;
      case 'share':
        return Colors.blue[600]!;
      case 'remove_ads':
        return Colors.green[600]!;
      case 'external_support':
        return Colors.purple[600]!;
      default:
        return Colors.green[600]!;
    }
  }

  // Helper method to get color based on country
  Color _getCountryColor(String country) {
    final Map<String, Color> countryColors = {
      'Bangladesh': Colors.green[600]!,
      'Saudi Arabia': Colors.green[800]!,
      'UAE': Colors.red[600]!,
      'UK': Colors.blue[600]!,
      'Kuwait': Colors.green[700]!,
      'India': Colors.orange[600]!,
      'USA': Colors.blue[700]!,
      'Qatar': Colors.purple[600]!,
      'Malaysia': Colors.teal[600]!,
    };

    return countryColors[country] ?? Colors.green[600]!;
  }

  // Support Option Item Builder
  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppColors.darkCard : Colors.white,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? AppColors.darkPrimary : Colors.green[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkText : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : Colors.black54,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? AppColors.darkTextSecondary : Colors.green[700],
        ),
        onTap: onTap,
      ),
    );
  }

  // ==================== Improved Real-time Activity Simulation ====================
  void _startActivitySimulation() {
    // Stop any existing timer
    _simulationTimer?.cancel();

    // Start new simulation timer
    _simulationTimer = Timer.periodic(Duration(minutes: 30), (timer) {
      if (mounted) {
        _simulateActivityChange();
      }
    });
  }

  void _simulateActivityChange() {
    final random = Random();
    final currentHour = DateTime.now().hour;

    // Different simulation based on time of day
    double changeProbability = 0.3; // Default 30% chance

    // Increase probability during peak hours (9 AM - 9 PM)
    if (currentHour >= 9 && currentHour <= 21) {
      changeProbability = 0.5; // 50% chance during day
    }

    if (random.nextDouble() < changeProbability) {
      setState(() {
        int change = random.nextInt(3) - 1; // -1, 0, or +1

        // More likely to increase during day, decrease during night
        if (currentHour >= 9 && currentHour <= 21 && change == -1) {
          change = 0; // Less likely to decrease during day
        }

        _todaySupporterCount += change;

        // Keep within realistic bounds
        if (_todaySupporterCount < 1) _todaySupporterCount = 1;
        if (_todaySupporterCount > 20) _todaySupporterCount = 20;

        print('🔄 Activity simulation: $change (Total: $_todaySupporterCount)');
      });
    }
  }

  // Support Screen - _SupportScreenState ক্লাসে এই মেথড যোগ করুন
  void _navigateToPremiumScreen(BuildContext context) {
    // সাপোর্ট অ্যাকশন রেকর্ড করুন (ঐচ্ছিক)
    _supportService.recordSupportAction(
      actionType: 'view_premium_options',
      actionName: 'Viewed Premium Options',
    );

    // প্রিমিয়াম স্ক্রিনে নিয়ে যান
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PremiumScreen()),
    );
  }

  @override
  void dispose() {
    // Clean up timers
    _simulationTimer?.cancel();
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.appBar(context),
        title: Text(
          _text('title'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voluntary Notice Banner
              _buildVoluntaryNotice(),
              const SizedBox(height: 16),

              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: 24),

              // Support Options Section
              _buildSupportOptionsSection(),
              const SizedBox(height: 20),

              // Policy Note
              _buildPolicyNote(),
              const SizedBox(height: 24),

              // Community Activity Section
              if (_showSupporterTicker) _buildCommunityActivitySection(),

              // Why Support Section
              _buildWhySupportSection(),
              const SizedBox(height: 24),

              // Contact Section
              _buildContactSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Voluntary Notice Banner ====================
  Widget _buildVoluntaryNotice() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.orange[900]!.withOpacity(0.3)
            : Colors.orange[50],
        border: Border.all(
          color: isDark ? Colors.orange[700]! : Colors.orange[200]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? Colors.orange[300] : Colors.orange[800],
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _text('voluntaryNotice'),
              style: TextStyle(
                color: isDark ? Colors.orange[300] : Colors.orange[800],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUPPORT OPTIONS SECTION ====================
  Widget _buildSupportOptionsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _text('communityEngagement'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimary : Colors.green[800],
              ),
            ),
            SizedBox(height: 16),

            _buildSupportOption(
              icon: Icons.star,
              title: _text('rateApp'),
              subtitle: _text('rateAppSubtitle'),
              onTap: _rateApp,
            ),

            _buildSupportOption(
              icon: Icons.share,
              title: _text('shareApp'),
              subtitle: _text('shareAppSubtitle'),
              onTap: _shareApp,
            ),

            _buildSupportOption(
              icon: Icons.block,
              title: _text('removeAds'),
              subtitle: _text('removeAdsSubtitle'),
              onTap: () => _navigateToPremiumScreen(context),
            ),

            _buildSupportOption(
              icon: Icons.open_in_new,
              title: _text('makeDonation'),
              subtitle: _text('makeDonationSubtitle'),
              onTap: _makeDonation,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== POLICY NOTE ====================
  Widget _buildPolicyNote() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _text('policyNote'),
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ==================== COMMUNITY ACTIVITY SECTION ====================
  Widget _buildCommunityActivitySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Card(
          elevation: 3,
          color: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      colors: [AppColors.darkSurface, AppColors.darkCard],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.green[50]!, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkPrimary
                            : Colors.green[600],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.people, color: Colors.white, size: 16),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _text('liveDonations'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : Colors.green[800],
                        letterSpacing: 1.2,
                      ),
                    ),
                    Spacer(),
                    // Info icon
                    Tooltip(
                      message: _text('demoDataInfo'),
                      child: Icon(
                        Icons.info_outline,
                        color: isDark
                            ? AppColors.darkPrimary
                            : Colors.green[600],
                        size: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Activity Container
                if (_recentSupporters.isNotEmpty)
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : Colors.green[100]!,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        controller: _tickerController,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(height: 8),
                            ...List.generate(_recentSupporters.length, (index) {
                              return _buildSupporterTickerItem(
                                _recentSupporters[index],
                                index,
                              );
                            }),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : Colors.green[100]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _text('supportersToday'),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                // Stats Row
                SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkPrimary.withOpacity(0.2)
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_alt,
                        color: isDark
                            ? AppColors.darkPrimary
                            : Colors.green[800],
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '$_todaySupporterCount ${_text('supportersToday')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkText
                              : Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkPrimary.withOpacity(0.2)
                    : Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_outline,
                size: 36,
                color: isDark ? AppColors.darkPrimary : Colors.green[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _text('headerTitle'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _text('headerSubtitle'),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhySupportSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _text('whySupport'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : Colors.green[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildReasonItem(
              Icons.cloud_upload,
              _text('serverCosts'),
              _text('serverDesc'),
            ),
            _buildReasonItem(
              Icons.developer_mode,
              _text('appDevelopment'),
              _text('appDevDesc'),
            ),
            _buildReasonItem(
              Icons.security,
              _text('security'),
              _text('securityDesc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem(IconData icon, String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimary.withOpacity(0.2)
                  : Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.darkPrimary : Colors.green[800],
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _text('contactInfo'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : Colors.green[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email, 'support@islamicquiz.com'),
            _buildContactItem(Icons.language, 'www.islamicquiz.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.darkPrimary : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.darkText : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Remove Ads Page - AdMob Compliant
class RemoveAdsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    bool isEnglish = languageProvider.isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Ad-Free Experience' : 'এড-মুক্ত অভিজ্ঞতা'),
        backgroundColor: ThemeHelper.appBar(context),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 80,
                color: isDark ? AppColors.darkPrimary : Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                isEnglish
                    ? 'Optional Ad-Free Experience'
                    : 'ঐচ্ছিক এড-মুক্ত অভিজ্ঞতা',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                isEnglish
                    ? 'This is an optional purchase. All features remain available with ads.'
                    : 'এটি একটি ঐচ্ছিক পারচেজ। সমস্ত ফিচার এডসহ উপলব্ধ থাকবে।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              // In-app purchase button
              ElevatedButton(
                onPressed: () {
                  // Implement in-app purchase
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEnglish
                            ? 'In-app purchase will be implemented'
                            : 'ইন-অ্যাপ পারচেজ ইমপ্লিমেন্ট করা হবে',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : Colors.green[800],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  isEnglish ? 'Optional Ad-Free' : 'ঐচ্ছিক এড-মুক্ত',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Text(
                isEnglish
                    ? 'Completely optional - app remains functional'
                    : 'সম্পূর্ণ ঐচ্ছিক - অ্যাপ কার্যকরী থাকবে',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
