// Prayer header section
// widgets/prayer_header_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../prayer_time_service.dart';
import '../providers/language_provider.dart';

class PrayerHeaderSection extends StatelessWidget {
  final String? cityName;
  final String? countryName;
  final String nextPrayer;
  final Duration countdown;
  final Map<String, String> prayerTimes;
  final bool isSmallScreen;
  final bool isVerySmallScreen;
  final bool isTablet;
  final bool isSmallPhone;
  final PrayerTimeService prayerTimeService;
  final VoidCallback onRefresh;
  final bool useManualLocation;

  const PrayerHeaderSection({
    Key? key,
    required this.cityName,
    required this.countryName,
    required this.nextPrayer,
    required this.countdown,
    required this.prayerTimes,
    required this.isSmallScreen,
    required this.isVerySmallScreen,
    required this.isTablet,
    required this.isSmallPhone,
    required this.prayerTimeService,
    required this.onRefresh,
    required this.useManualLocation,
  }) : super(key: key);

  // Make texts static const
  static const Map<String, Map<String, String>> _texts = {
    'youAreAt': {'en': 'You are currently at', 'bn': 'আপনি এখন অবস্থান করছেন'},
    'manual': {'en': 'Manual', 'bn': 'মানুয়াল'},
    'refresh': {'en': 'Refresh', 'bn': 'রিফ্রেশ করুন'},
    'nextPrayer': {'en': 'Next Prayer', 'bn': 'পরবর্তী নামাজ'},
    'loading': {'en': 'Loading...', 'bn': 'লোড হচ্ছে...'},
    'hours': {'en': 'Hours', 'bn': 'ঘণ্টা'},
    'minutes': {'en': 'Minutes', 'bn': 'মিনিট'},
    'seconds': {'en': 'Seconds', 'bn': 'সেকেন্ড'},
    'startingSoon': {'en': 'Starting Soon', 'bn': 'শীঘ্রই শুরু'},
    'verySoon': {'en': 'Very Soon', 'bn': 'খুব শীঘ্রই'},
    'soon': {'en': 'Soon', 'bn': 'শীঘ্রই'},
    'littleTime': {'en': 'Little Time', 'bn': 'অল্প সময়'},
    'timeLeft': {'en': 'Time Left', 'bn': 'সময় বাকি'},
    'sunrise': {'en': 'Sunrise', 'bn': 'সূর্যোদয়'},
    'sunset': {'en': 'Sunset', 'bn': 'সূর্যাস্ত'},
    'currentLocation': {'en': 'Current Location', 'bn': 'বর্তমান অবস্থান'},
    'unknownCountry': {'en': 'Unknown Country', 'bn': 'অজানা দেশ'},
  };

  // Helper method to get text based on current language
  String _text(String key, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

  // Get prayer name based on language
  String _getPrayerName(String prayerName, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    if (languageProvider.isEnglish) {
      switch (prayerName) {
        case 'ফজর':
          return 'Fajr';
        case 'যোহর':
          return 'Dhuhr';
        case 'আসর':
          return 'Asr';
        case 'মাগরিব':
          return 'Maghrib';
        case 'ইশা':
          return 'Isha';
        case 'সূর্যোদয়':
          return 'Sunrise';
        case 'সূর্যাস্ত':
          return 'Sunset';
        default:
          return prayerName;
      }
    }
    return prayerName;
  }

  // Get location name based on language
  String _getLocationName(String? location, BuildContext context) {
    if (location == null) return '';

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    // যদি ইংরেজি ভাষা সিলেক্ট করা থাকে, তাহলে ইংরেজি নামে কনভার্ট করুন
    if (languageProvider.isEnglish) {
      // বাংলা লোকেশন নামগুলোর ইংরেজি ভার্সন
      Map<String, String> locationTranslations = {
        'বর্তমান অবস্থান': 'Current Location',
        'অজানা দেশ': 'Unknown Country',
        'ঢাকা': 'Dhaka',
        'চট্টগ্রাম': 'Chittagong',
        'রাজশাহী': 'Rajshahi',
        'খুলনা': 'Khulna',
        'বরিশাল': 'Barisal',
        'সিলেট': 'Sylhet',
        'কুমিল্লা': 'Comilla',
        'নারায়ণগঞ্জ': 'Narayanganj',
        'গাজীপুর': 'Gazipur',
        'বাংলাদেশ': 'Bangladesh',
        'ভারত': 'India',
        'পাকিস্তান': 'Pakistan',
        'যুক্তরাষ্ট্র': 'United States',
        'যুক্তরাজ্য': 'United Kingdom',
        'কানাডা': 'Canada',
        'অস্ট্রেলিয়া': 'Australia',
        'মালয়েশিয়া': 'Malaysia',
        'সিঙ্গাপুর': 'Singapore',
        'সৌদি আরব': 'Saudi Arabia',
        'কুয়েত': 'Kuwait',
        'কাতার': 'Qatar',
        'ওমান': 'Oman',
        'বাহরাইন': 'Bahrain',
        'সংযুক্ত আরব আমিরাত': 'United Arab Emirates',
        'দুবাই': 'Dubai',
        'আবুধাবি': 'Abu Dhabi',
        'রিয়াদ': 'Riyadh',
        'জেদ্দা': 'Jeddah',
        'মক্কা': 'Mecca',
        'মদিনা': 'Medina',
        'দাম্মাম': 'Dammam',
        'খোবার': 'Khobar',
        'মাউন্টেন ভিউ': 'Mountain View',
        'সান ফ্রান্সিস্কো': 'San Francisco',
        'লস এঞ্জেলেস': 'Los Angeles',
        'নিউ ইয়র্ক': 'New York',
        'লন্ডন': 'London',
        'টরন্টো': 'Toronto',
        'সিডনি': 'Sydney',
        'মেলবোর্ন': 'Melbourne',
        'কুয়ালালামপুর': 'Kuala Lumpur',
      };

      // পুরো টেক্সট ট্রান্সলেট করার চেষ্টা করুন
      if (locationTranslations.containsKey(location)) {
        return locationTranslations[location]!;
      }

      // শব্দ ভেঙ্গে ট্রান্সলেট করার চেষ্টা করুন
      String translatedLocation = location;
      for (var entry in locationTranslations.entries) {
        if (translatedLocation.contains(entry.key)) {
          translatedLocation = translatedLocation.replaceAll(
            entry.key,
            entry.value,
          );
        }
      }

      return translatedLocation;
    }

    // বাংলা ভাষা হলে অরিজিনাল নাম রিটার্ন করুন
    return location;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate dynamic heights based on screen size
    final double headerHeight = isVerySmallScreen
        ? 140
        : isSmallScreen
        ? 160
        : 180;

    final double fontSize = isVerySmallScreen
        ? 12
        : isSmallScreen
        ? 14
        : 16;

    final double iconSize = isVerySmallScreen
        ? 12
        : isSmallScreen
        ? 14
        : 16;

    final double paddingSize = isVerySmallScreen
        ? 6
        : isSmallScreen
        ? 8
        : 10;

    return Container(
      height: headerHeight,
      padding: EdgeInsets.fromLTRB(
        paddingSize,
        paddingSize * 0.5,
        paddingSize,
        paddingSize,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Color(0xFF0D4A3A), Color(0xFF1A6B52), Color(0xFF2A8C6E)]
              : [Color(0xFFE8F5E8), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.green.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section - Location and Refresh (Compact)
          _buildCompactLocationSection(
            context,
            isDark,
            isVerySmallScreen,
            isSmallScreen,
            isTablet,
            isSmallPhone,
          ),

          SizedBox(
            height: isVerySmallScreen
                ? 6
                : isSmallScreen
                ? 7
                : 8,
          ),

          // Bottom Section - Prayer Info and Sun Times (Compact)
          _buildCompactPrayerSunSection(
            context,
            isDark,
            isVerySmallScreen,
            isSmallScreen,
            isTablet,
            isSmallPhone,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLocationSection(
    BuildContext context,
    bool isDark,
    bool isVerySmallScreen,
    bool isSmallScreen,
    bool isTablet,
    bool isSmallPhone,
  ) {
    final double containerPadding = isVerySmallScreen
        ? 4
        : isSmallScreen
        ? 5
        : 6;
    final double iconPadding = isVerySmallScreen
        ? 2
        : isSmallScreen
        ? 3
        : 4;
    final double iconSize = isVerySmallScreen
        ? 10
        : isSmallScreen
        ? 12
        : 16;
    final double textFontSize = isVerySmallScreen
        ? 9
        : isSmallScreen
        ? 10
        : 14;
    final double badgeVerticalPadding = isVerySmallScreen
        ? 1
        : isSmallScreen
        ? 2
        : 3;
    final double badgeFontSize = isVerySmallScreen
        ? 6
        : isSmallScreen
        ? 7
        : 10;
    final double refreshIconSize = isVerySmallScreen
        ? 10
        : isSmallScreen
        ? 12
        : 16;
    final double refreshSplashRadius = isVerySmallScreen
        ? 10
        : isSmallScreen
        ? 14
        : 18;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(
          isVerySmallScreen
              ? 6
              : isSmallScreen
              ? 8
              : 10,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Color(0xFF4CAF50).withOpacity(0.3),
          width: isVerySmallScreen ? 0.5 : 0.8,
        ),
      ),
      child: Row(
        children: [
          // Location Icon
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Color(0xFF4CAF50).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              useManualLocation ? Icons.pin_drop : Icons.my_location,
              color: isDark ? Colors.white : Color(0xFF2E7D32),
              size: iconSize,
            ),
          ),

          SizedBox(
            width: isVerySmallScreen
                ? 4
                : isSmallScreen
                ? 6
                : 8,
          ),
          // widgets/prayer_header_section.dart - _buildCompactLocationSection-এর লোকেশন টেক্সট অংশ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('youAreAt', context),
                  style: TextStyle(
                    fontSize: isVerySmallScreen
                        ? 7
                        : isSmallScreen
                        ? 8
                        : 9,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Color(0xFF388E3C),
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  _getLocationName(cityName, context),
                  // শুধু cityName ব্যবহার করুন, countryName আলাদা দেখানোর দরকার নেই
                  style: TextStyle(
                    fontSize: textFontSize,
                    color: isDark ? Colors.white : Color(0xFF1B5E20),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.05,
                  ),
                  maxLines: 2, // 2 লাইনে দেখানোর সুযোগ দিন
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Manual Location Badge
          if (useManualLocation) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isVerySmallScreen
                    ? 4
                    : isSmallScreen
                    ? 5
                    : 6,
                vertical: badgeVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  isVerySmallScreen
                      ? 3
                      : isSmallScreen
                      ? 4
                      : 5,
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.amber.withOpacity(0.5)
                      : Colors.orange.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                _text('manual', context),
                style: TextStyle(
                  fontSize: badgeFontSize,
                  color: isDark
                      ? Colors.amber.shade200
                      : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: isVerySmallScreen
                  ? 4
                  : isSmallScreen
                  ? 5
                  : 6,
            ),
          ],

          // Refresh Button
          Container(
            width: isVerySmallScreen
                ? 20
                : isSmallScreen
                ? 24
                : 28,
            height: isVerySmallScreen
                ? 20
                : isSmallScreen
                ? 24
                : 28,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Color(0xFF4CAF50).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark ? Colors.white : Color(0xFF2E7D32),
                size: refreshIconSize,
              ),
              iconSize: refreshIconSize,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: isVerySmallScreen
                    ? 20
                    : isSmallScreen
                    ? 24
                    : 28,
                minHeight: isVerySmallScreen
                    ? 20
                    : isSmallScreen
                    ? 24
                    : 28,
              ),
              tooltip: _text('refresh', context),
              splashRadius: refreshSplashRadius,
            ),
          ),
        ],
      ),
    );
  }

  // ... বাকি মেথডগুলো একই থাকবে, শুধু লোকেশন ডিসপ্লে সংশোধন করা হয়েছে

  Widget _buildCompactPrayerSunSection(
    BuildContext context,
    bool isDark,
    bool isVerySmallScreen,
    bool isSmallScreen,
    bool isTablet,
    bool isSmallPhone,
  ) {
    return Row(
      children: [
        // Next Prayer Countdown
        Expanded(
          flex: 10,
          child: _buildCompactPrayerCard(
            context,
            isDark,
            isVerySmallScreen,
            isSmallScreen,
            isTablet,
            isSmallPhone,
          ),
        ),

        SizedBox(
          width: isVerySmallScreen
              ? 6
              : isSmallScreen
              ? 7
              : 8,
        ),

        // Sunrise/Sunset Times
        Expanded(
          flex: 4,
          child: _buildCompactSunTimesCard(
            context,
            isDark,
            isVerySmallScreen,
            isSmallScreen,
            isTablet,
            isSmallPhone,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactPrayerCard(
    BuildContext context,
    bool isDark,
    bool isVerySmallScreen,
    bool isSmallScreen,
    bool isTablet,
    bool isSmallPhone,
  ) {
    final double cardPadding = isVerySmallScreen
        ? 6
        : isSmallScreen
        ? 8
        : 10;
    final double titleFontSize = isVerySmallScreen
        ? 10
        : isSmallScreen
        ? 11
        : 12;
    final double prayerFontSize = isVerySmallScreen
        ? 12
        : isSmallScreen
        ? 14
        : 16;
    final double countdownPadding = isVerySmallScreen
        ? 6
        : isSmallScreen
        ? 7
        : 8;
    final double timeUnitFontSize = isVerySmallScreen
        ? 14
        : isSmallScreen
        ? 16
        : 18;
    final double timeLabelFontSize = isVerySmallScreen
        ? 8
        : isSmallScreen
        ? 9
        : 10;
    final double statusFontSize = isVerySmallScreen
        ? 7
        : isSmallScreen
        ? 8
        : 9;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(
          isVerySmallScreen
              ? 8
              : isSmallScreen
              ? 10
              : 12,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Color(0xFF4CAF50).withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Prayer Info (Left side) - একই থাকবে
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('nextPrayer', context),
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: isDark
                        ? Colors.white.withOpacity(0.9)
                        : Color(0xFF388E3C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: isVerySmallScreen
                      ? 2
                      : isSmallScreen
                      ? 3
                      : 4,
                ),
                Text(
                  nextPrayer.isNotEmpty
                      ? _getPrayerName(nextPrayer, context)
                      : _text('loading', context),
                  style: TextStyle(
                    fontSize: prayerFontSize,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Color(0xFF1B5E20),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(
            width: isVerySmallScreen
                ? 4
                : isSmallScreen
                ? 6
                : 8,
          ),

          // Countdown Timer (Right side) - With status border
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: countdownPadding,
                vertical: isVerySmallScreen
                    ? 4
                    : isSmallScreen
                    ? 5
                    : 6,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(
                  isVerySmallScreen
                      ? 6
                      : isSmallScreen
                      ? 8
                      : 10,
                ),
                border: Border.all(
                  color: _getCountdownBorderColor(countdown),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getCountdownBorderColor(countdown).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Countdown numbers and labels in organized columns
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ঘণ্টা কলাম
                      _buildTimeUnitColumn(
                        value: countdown.inHours,
                        label: _text('hours', context),
                        timeFontSize: timeUnitFontSize,
                        labelFontSize: timeLabelFontSize,
                        isDark: isDark,
                      ),

                      // প্রথম ডিভাইডার
                      _buildDivider(isVerySmallScreen, isSmallScreen, isDark),

                      // মিনিট কলাম
                      _buildTimeUnitColumn(
                        value: countdown.inMinutes % 60,
                        label: _text('minutes', context),
                        timeFontSize: timeUnitFontSize,
                        labelFontSize: timeLabelFontSize,
                        isDark: isDark,
                      ),

                      // দ্বিতীয় ডিভাইডার
                      _buildDivider(isVerySmallScreen, isSmallScreen, isDark),

                      // সেকেন্ড কলাম
                      _buildTimeUnitColumn(
                        value: countdown.inSeconds % 60,
                        label: _text('seconds', context),
                        timeFontSize: timeUnitFontSize,
                        labelFontSize: timeLabelFontSize,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: isVerySmallScreen
                        ? 1
                        : isSmallScreen
                        ? 2
                        : 4,
                  ),

                  // Countdown status text
                  Text(
                    _getCountdownStatus(countdown, context),
                    style: TextStyle(
                      fontSize: statusFontSize,
                      color: _getCountdownTextColor(countdown, isDark),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // নতুন মেথড যোগ করুন - শুধু সংখ্যার জন্য
  // নতুন মেথড - সংখ্যা এবং লেবেল একই কলামে
  Widget _buildTimeUnitColumn({
    required int value,
    required String label,
    required double timeFontSize,
    required double labelFontSize,
    required bool isDark,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // সংখ্যা (০৩, ২৬, ৪৫)
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: timeFontSize,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Color(0xFF1B5E20),
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: isDark
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ]
                : null,
          ),
        ),

        SizedBox(height: 2),

        // লেবেল (ঘণ্টা, মিনিট, সেকেন্ড)
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: isDark ? Colors.white.withOpacity(0.9) : Color(0xFF388E3C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ডিভাইডার মেথড - উচ্চতা ঠিক করুন
  Widget _buildDivider(
    bool isVerySmallScreen,
    bool isSmallScreen,
    bool isDark,
  ) {
    return Container(
      width: 1,
      height: isVerySmallScreen
          ? 28 // ← কলামের মোট উচ্চতার সাথে মিল করুন
          : isSmallScreen
          ? 32
          : 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark
                ? Colors.white.withOpacity(0.6)
                : Color(0xFF4CAF50).withOpacity(0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ... বাকি সব হেল্পার মেথডগুলো একই থাকবে
  Color _getCountdownBorderColor(Duration countdown) {
    final totalSeconds = countdown.inSeconds;
    if (totalSeconds <= 300)
      return Color(0xFFE53935);
    else if (totalSeconds <= 1800)
      return Color(0xFFFB8C00);
    else if (totalSeconds <= 3600)
      return Color(0xFFFDD835);
    else
      return Color(0xFF43A047);
  }

  Color _getCountdownTextColor(Duration countdown, bool isDark) {
    if (!isDark) return Colors.white;
    final totalSeconds = countdown.inSeconds;
    if (totalSeconds <= 300)
      return Color(0xFFFFCDD2);
    else if (totalSeconds <= 1800)
      return Color(0xFFFFE0B2);
    else if (totalSeconds <= 3600)
      return Color(0xFFFFF9C4);
    else
      return Color(0xFFC8E6C9);
  }

  String _getCountdownStatus(Duration countdown, BuildContext context) {
    final totalSeconds = countdown.inSeconds;
    if (totalSeconds <= 60)
      return _text('startingSoon', context);
    else if (totalSeconds <= 300)
      return _text('verySoon', context);
    else if (totalSeconds <= 1800)
      return _text('soon', context);
    else if (totalSeconds <= 3600)
      return _text('littleTime', context);
    else
      return _text('timeLeft', context);
  }

  Widget _buildCompactSunTimesCard(
    BuildContext context,
    bool isDark,
    bool isVerySmallScreen,
    bool isSmallScreen,
    bool isTablet,
    bool isSmallPhone,
  ) {
    final double cardPadding = isVerySmallScreen
        ? 4
        : isSmallScreen
        ? 6
        : 8;
    final double iconSize = isVerySmallScreen
        ? 10
        : isSmallScreen
        ? 12
        : 14;
    final double labelFontSize = isVerySmallScreen
        ? 9
        : isSmallScreen
        ? 10
        : 11;
    final double timeFontSize = isVerySmallScreen
        ? 10
        : isSmallScreen
        ? 12
        : 14;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [Color(0xFFE65100), Color(0xFFEF6C00)]
              : [Color(0xFFFFCC80), Color(0xFFFFB74D)],
        ),
        borderRadius: BorderRadius.circular(
          isVerySmallScreen
              ? 8
              : isSmallScreen
              ? 10
              : 12,
        ),
        border: Border.all(
          color: isDark ? Color(0xFFE65100) : Color(0xFFF57C00),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.deepOrange.withOpacity(0.4)
                : Colors.orange.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCompactSunItemWithText(
            context,
            icon: Icons.wb_twilight,
            label: _text('sunrise', context),
            time: prayerTimes["সূর্যোদয়"],
            iconSize: iconSize,
            labelFontSize: labelFontSize,
            timeFontSize: timeFontSize,
            isDark: isDark,
          ),
          Container(
            height: 1.0,
            margin: EdgeInsets.symmetric(
              vertical: isVerySmallScreen
                  ? 1
                  : isSmallScreen
                  ? 2
                  : 3,
            ),
            color: isDark
                ? Colors.white.withOpacity(0.3)
                : Colors.orange.withOpacity(0.4),
          ),
          _buildCompactSunItemWithText(
            context,
            icon: Icons.nightlight_round,
            label: _text('sunset', context),
            time: prayerTimes["সূর্যাস্ত"],
            iconSize: iconSize,
            labelFontSize: labelFontSize,
            timeFontSize: timeFontSize,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSunItemWithText(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? time,
    required double iconSize,
    required double labelFontSize,
    required double timeFontSize,
    required bool isDark,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white : Color(0xFF5D4037),
              size: iconSize,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: isDark
                    ? Colors.white.withOpacity(0.9)
                    : Color(0xFF5D4037),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          time != null ? _formatTimeCompact(time) : "--:--",
          style: TextStyle(
            fontSize: timeFontSize,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeUnit(
    String label,
    int value,
    double timeFontSize,
    double labelFontSize,
    bool isDark,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: timeFontSize,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Color(0xFF1B5E20),
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: isDark
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: isDark ? Colors.white.withOpacity(0.9) : Color(0xFF388E3C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatTimeCompact(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        return '${hour.toString().padLeft(2, '0')}:$minute';
      }
      return time;
    } catch (e) {
      return time;
    }
  }
}
