// update prayer header section
// Update prayer header section

// widgets/prayer_header_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/prayer_time_service.dart';
import '../../providers/language_provider.dart';

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

  // Language Texts
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

  // Get location name based on language - Optimized version
  String _getLocationName(String? location, BuildContext context) {
    if (location == null || location.isEmpty)
      return _text('currentLocation', context);

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    // English language selected - translate Bengali location names
    if (languageProvider.isEnglish) {
      const Map<String, String> locationTranslations = {
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

      return locationTranslations[location] ?? location;
    }

    // Bengali language - return original name
    return location;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // Dynamic height calculation based on screen size and orientation
    final double headerHeight = _calculateHeaderHeight(
      screenHeight,
      screenWidth,
      isLandscape,
    );

    // Dynamic padding calculation
    final double paddingSize = _calculatePaddingSize(
      screenHeight,
      screenWidth,
      isLandscape,
    );

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
          _buildCompactLocationSection(
            context,
            isDark,
            headerHeight,
            screenWidth,
            isLandscape,
          ),
          SizedBox(height: _calculateSpacing(headerHeight)),
          _buildCompactPrayerSunSection(
            context,
            isDark,
            headerHeight,
            screenWidth,
            isLandscape,
          ),
        ],
      ),
    );
  }

  // Calculate header height based on screen parameters
  double _calculateHeaderHeight(
    double screenHeight,
    double screenWidth,
    bool isLandscape,
  ) {
    if (isLandscape) {
      if (screenHeight < 400) return 120; // ← কমিয়ে দিন
      if (screenHeight < 500) return 130; // 130
      if (screenHeight < 600) return 140; //140
      return 100;
    } else {
      if (screenHeight < 600) return 120; //140
      if (screenHeight < 700) return 100; //120
      if (screenHeight < 800) return 140; //140
      if (screenHeight < 900) return 140; // 160
      return 180; // 200
    }
  }

  // Calculate padding based on screen parameters
  double _calculatePaddingSize(
    double screenHeight,
    double screenWidth,
    bool isLandscape,
  ) {
    final double shortestSide = MediaQueryData.fromWindow(
      WidgetsBinding.instance.window,
    ).size.shortestSide;

    if (shortestSide < 300) return 4;
    if (shortestSide < 360) return 6;
    if (shortestSide < 400) return 8;
    if (shortestSide < 500) return 10;
    return 8;
  }

  // স্পেসিং কমাতে
  double _calculateSpacing(double headerHeight) {
    if (headerHeight < 150) return 2; // ← কমিয়ে দিন
    if (headerHeight < 180) return 3; // ← কমিয়ে দিন
    return 4; // ← কমিয়ে দিন
  }

  Widget _buildCompactLocationSection(
    BuildContext context,
    bool isDark,
    double headerHeight,
    double screenWidth,
    bool isLandscape,
  ) {
    final double containerPadding = _calculateLocationPadding(headerHeight);
    final double iconSize = _calculateIconSize(headerHeight);
    final double titleFontSize = _calculateTitleFontSize(headerHeight);
    final double locationFontSize = _calculateLocationFontSize(headerHeight);

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(
          _calculateBorderRadius(headerHeight),
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Color(0xFF4CAF50).withOpacity(0.3),
          width: headerHeight < 160 ? 0.5 : 0.8,
        ),
      ),
      child: Row(
        children: [
          // Location Icon
          Container(
            padding: EdgeInsets.all(_calculateIconPadding(headerHeight)),
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

          SizedBox(width: _calculateSmallSpacing(headerHeight)),

          // Location Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('youAreAt', context),
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Color(0xFF388E3C),
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: headerHeight < 160 ? 1 : 2),
                Text(
                  _getLocationName(cityName, context),
                  style: TextStyle(
                    fontSize: locationFontSize,
                    color: isDark ? Colors.white : Color(0xFF1B5E20),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.05,
                  ),
                  maxLines: _getMaxLines(headerHeight),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Manual Location Badge
          if (useManualLocation) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: _calculateBadgePadding(headerHeight),
                vertical: _calculateBadgePadding(headerHeight) * 0.5,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  _calculateBadgeBorderRadius(headerHeight),
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
                  fontSize: _calculateBadgeFontSize(headerHeight),
                  color: isDark
                      ? Colors.amber.shade200
                      : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: _calculateSmallSpacing(headerHeight)),
          ],

          // Refresh Button
          Container(
            width: _calculateButtonSize(headerHeight),
            height: _calculateButtonSize(headerHeight),
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
                size: _calculateRefreshIconSize(headerHeight),
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: _calculateButtonSize(headerHeight),
                minHeight: _calculateButtonSize(headerHeight),
              ),
              tooltip: _text('refresh', context),
            ),
          ),
        ],
      ),
    );
  }

  _buildCompactPrayerSunSection(
    BuildContext context,
    bool isDark,
    double headerHeight,
    double screenWidth,
    bool isLandscape,
  ) {
    final bool isCompactMode = headerHeight < 160 || screenWidth < 400;

    return Expanded(
      child: isCompactMode
          ? _buildCompactLayout(context, isDark, headerHeight, screenWidth)
          : _buildNormalLayout(context, isDark, headerHeight, screenWidth),
    );
  }

  Widget _buildNormalLayout(
    BuildContext context,
    bool isDark,
    double headerHeight,
    double screenWidth,
  ) {
    return Row(
      children: [
        // Next Prayer Countdown
        Expanded(
          flex: _getPrayerSectionFlex(headerHeight, screenWidth),
          child: _buildCompactPrayerCard(context, isDark, headerHeight),
        ),
        SizedBox(width: _calculateMediumSpacing(headerHeight)),
        // Sunrise/Sunset Times
        Expanded(
          flex: _getSunSectionFlex(headerHeight, screenWidth),
          child: _buildCompactSunTimesCard(context, isDark, headerHeight),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    bool isDark,
    double headerHeight,
    double screenWidth,
  ) {
    return Row(
      children: [
        // Next Prayer Countdown - Compact without progress bar
        Expanded(
          flex: 6,
          child: _buildCompactPrayerCard(context, isDark, headerHeight),
        ),
        SizedBox(width: _calculateSmallSpacing(headerHeight)),
        // Sunrise/Sunset Times - Side by side in compact mode
        Expanded(
          flex: 4,
          child: _buildCompactSunTimesHorizontal(context, isDark, headerHeight),
        ),
      ],
    );
  }

  Widget _buildCompactSunTimesHorizontal(
    BuildContext context,
    bool isDark,
    double headerHeight,
  ) {
    final double cardPadding = _calculateSunCardPadding(headerHeight);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1E3A5F), const Color(0xFF2D4A72)]
              : [const Color(0xFFE8F4FD), const Color(0xFFD4E7FA)],
        ),
        borderRadius: BorderRadius.circular(
          _calculateSunCardBorderRadius(headerHeight),
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF3D5A80) : const Color(0xFF90CAF9),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Sunrise - Compact horizontal item
          Expanded(
            child: _buildCompactSunItemHorizontal(
              context,
              icon: Icons.wb_twilight,
              time: prayerTimes["সূর্যোদয়"],
              headerHeight: headerHeight,
              isDark: isDark,
              label: _text('sunrise', context),
              isSunrise: true,
            ),
          ),

          // Vertical Divider
          Container(
            width: 1,
            height: _calculateSunDividerHeight(headerHeight) * 2,
            margin: EdgeInsets.symmetric(horizontal: 4),
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.blue.withOpacity(0.3),
          ),

          // Sunset - Compact horizontal item
          Expanded(
            child: _buildCompactSunItemHorizontal(
              context,
              icon: Icons.nightlight_round,
              time: prayerTimes["সূর্যাস্ত"],
              headerHeight: headerHeight,
              isDark: isDark,
              label: _text('sunset', context),
              isSunrise: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSunItemHorizontal(
    BuildContext context, {
    required IconData icon,
    required String? time,
    required double headerHeight,
    required bool isDark,
    required String label,
    required bool isSunrise,
  }) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    String displayTime = time != null ? _formatTimeCompact(time) : "--:--";

    if (!languageProvider.isEnglish) {
      displayTime = _convertToBanglaNumbers(displayTime);
    }

    // Improved colors for sunrise and sunset
    final Color sunriseColor = isDark
        ? const Color(0xFFFFB74D)
        : const Color(0xFFFF9800);

    final Color sunsetColor = isDark
        ? const Color(0xFFFF8A65)
        : const Color(0xFFF4511E);

    final Color itemColor = isSunrise ? sunriseColor : sunsetColor;

    return Container(
      padding: EdgeInsets.all(_calculateSunItemPadding(headerHeight)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(_calculateSunIconPadding(headerHeight)),
            decoration: BoxDecoration(
              color: itemColor.withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: itemColor,
              size: _calculateSunIconSizeCompact(headerHeight),
            ),
          ),

          SizedBox(height: _calculateSunTimeSpacing(headerHeight)),

          // Time
          Text(
            displayTime,
            style: TextStyle(
              fontSize: _calculateSunTimeFontSizeCompact(headerHeight),
              fontWeight: FontWeight.w800,
              color: itemColor,
              fontFamily: 'Monospace',
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: _calculateSunTimeSpacing(headerHeight)),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: _calculateSunLabelFontSizeCompact(headerHeight),
              fontWeight: FontWeight.w600,
              color: itemColor,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Compact mode specific calculations
  double _calculateSunIconSizeCompact(double headerHeight) {
    if (headerHeight < 150) return 10;
    if (headerHeight < 180) return 12;
    return 14;
  }

  double _calculateSunTimeFontSizeCompact(double headerHeight) {
    if (headerHeight < 150) return 11;
    if (headerHeight < 180) return 13;
    return 15;
  }

  double _calculateSunLabelFontSizeCompact(double headerHeight) {
    if (headerHeight < 150) return 9;
    if (headerHeight < 180) return 10;
    return 11;
  }

  // Update the countdown section to remove progress bar in compact mode
  Widget _buildEnhancedCountdownSection(
    BuildContext context,
    bool isDark,
    double headerHeight,
  ) {
    final bool showProgressBar = headerHeight > 160;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _calculateCountdownPadding(headerHeight),
        vertical: _calculateCountdownVerticalPadding(headerHeight),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.3),
                ]
              : [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(
          _calculateCountdownBorderRadius(headerHeight),
        ),
        border: Border.all(
          color: _getCountdownBorderColor(countdown).withOpacity(0.6),
          width: _calculateCountdownBorderWidth(headerHeight),
        ),
        boxShadow: [
          BoxShadow(
            color: _getCountdownBorderColor(countdown).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCountdownNumbersRow(context, headerHeight, isDark),
          SizedBox(height: _calculateTinySpacing(headerHeight)),
          _buildCountdownLabelsRow(context, headerHeight, isDark),
          if (showProgressBar) ...[
            SizedBox(height: _calculateMicroSpacing(headerHeight)),
            _buildCountdownStatusWithProgress(context, headerHeight, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactPrayerCard(
    BuildContext context,
    bool isDark,
    double headerHeight,
  ) {
    final double cardPadding = _calculateCardPadding(headerHeight);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(
          _calculateCardBorderRadius(headerHeight),
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
          // Prayer Info (Left side) - Reduced width
          Expanded(
            flex: _getPrayerInfoFlex(headerHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('nextPrayer', context),
                  style: TextStyle(
                    fontSize: _calculatePrayerTitleFontSize(headerHeight),
                    color: isDark
                        ? Colors.white.withOpacity(0.9)
                        : Color(0xFF388E3C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: _calculateTinySpacing(headerHeight)),
                Text(
                  nextPrayer.isNotEmpty
                      ? _getPrayerName(nextPrayer, context)
                      : _text('loading', context),
                  style: TextStyle(
                    fontSize: _calculatePrayerNameFontSize(headerHeight),
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Color(0xFF1B5E20),
                    letterSpacing: -0.2,
                  ),
                  maxLines: _getPrayerNameMaxLines(headerHeight),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: _calculateSmallSpacing(headerHeight)),

          // Countdown Timer (Right side) - Increased width
          Expanded(
            flex: _getCountdownFlex(headerHeight),
            child: _buildEnhancedCountdownSection(
              context,
              isDark,
              headerHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownNumbersRow(
    BuildContext context,
    double headerHeight,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeNumber(
          value: countdown.inHours,
          headerHeight: headerHeight,
          isDark: isDark,
          context: context,
        ),
        _buildColonSeparator(isDark, headerHeight),
        _buildTimeNumber(
          value: countdown.inMinutes % 60,
          headerHeight: headerHeight,
          isDark: isDark,
          context: context,
        ),
        _buildColonSeparator(isDark, headerHeight),
        _buildTimeNumber(
          value: countdown.inSeconds % 60,
          headerHeight: headerHeight,
          isDark: isDark,
          context: context,
        ),
      ],
    );
  }

  Widget _buildTimeNumber({
    required int value,
    required double headerHeight,
    required bool isDark,
    required BuildContext context,
  }) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    String displayValue = value.toString().padLeft(2, '0');

    if (!languageProvider.isEnglish) {
      displayValue = _convertToBanglaNumbers(displayValue);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _calculateTimeNumberPadding(headerHeight),
        vertical: _calculateTimeNumberVerticalPadding(headerHeight),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.4),
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.4),
                ],
        ),
        borderRadius: BorderRadius.circular(
          _calculateTimeNumberBorderRadius(headerHeight),
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.3)
              : Colors.green.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        displayValue,
        style: TextStyle(
          fontSize: _calculateTimeNumberFontSize(headerHeight),
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : const Color(0xFF1B5E20),
          fontFamily: 'Monospace',
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildColonSeparator(bool isDark, double headerHeight) {
    return Text(
      ':',
      style: TextStyle(
        fontSize: _calculateColonFontSize(headerHeight),
        fontWeight: FontWeight.w900,
        color: isDark
            ? Colors.white.withOpacity(0.7)
            : const Color(0xFF388E3C).withOpacity(0.8),
        height: 1.0,
      ),
    );
  }

  Widget _buildCountdownLabelsRow(
    BuildContext context,
    double headerHeight,
    bool isDark,
  ) {
    final double spacing = _calculateLabelSpacing(headerHeight);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildTimeLabel(
            _text('hours', context),
            _calculateTimeLabelFontSize(headerHeight),
            isDark,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildTimeLabel(
            _text('minutes', context),
            _calculateTimeLabelFontSize(headerHeight),
            isDark,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildTimeLabel(
            _text('seconds', context),
            _calculateTimeLabelFontSize(headerHeight),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeLabel(String label, double fontSize, bool isDark) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: isDark
              ? Colors.white.withOpacity(0.8)
              : const Color(0xFF388E3C).withOpacity(0.9),
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
        maxLines: 1,
      ),
    );
  }

  Widget _buildCountdownStatusWithProgress(
    BuildContext context,
    double headerHeight,
    bool isDark,
  ) {
    final totalSeconds = countdown.inSeconds;
    final progressValue = _calculateProgressValue(totalSeconds);

    return Column(
      children: [
        // Progress bar
        Container(
          height: _calculateProgressBarHeight(headerHeight),
          margin: EdgeInsets.symmetric(
            horizontal: _calculateProgressBarMargin(headerHeight),
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              Container(width: double.infinity),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: progressValue,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCountdownBorderColor(countdown),
                      _getCountdownBorderColor(countdown).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _calculateMicroSpacing(headerHeight)),
        Text(
          _getCountdownStatus(countdown, context),
          style: TextStyle(
            fontSize: _calculateStatusFontSize(headerHeight),
            color: _getCountdownTextColor(countdown, isDark),
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSunTimesCard(
    BuildContext context,
    bool isDark,
    double headerHeight,
  ) {
    final double cardPadding = _calculateSunCardPadding(headerHeight);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1E3A5F),
                  const Color(0xFF2D4A72),
                ] // Dark blue gradient - improved
              : [
                  const Color(0xFFE8F4FD),
                  const Color(0xFFD4E7FA),
                ], // Light blue gradient - improved
        ),
        borderRadius: BorderRadius.circular(
          _calculateSunCardBorderRadius(headerHeight),
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF3D5A80) : const Color(0xFF90CAF9),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.blue.withOpacity(0.3)
                : Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sunrise Section - Golden/Yellow - Centered content
          _buildEnhancedSunItem(
            context,
            icon: Icons.wb_twilight,
            time: prayerTimes["সূর্যোদয়"],
            headerHeight: headerHeight,
            isDark: isDark,
            label: _text('sunrise', context),
            isSunrise: true,
          ),

          SizedBox(height: _calculateSunItemSpacing(headerHeight)),

          // Divider
          Container(
            height: _calculateSunDividerHeight(headerHeight),
            margin: EdgeInsets.symmetric(
              horizontal: _calculateSunDividerMargin(headerHeight),
            ),
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.blue.withOpacity(0.3),
          ),

          SizedBox(height: _calculateSunItemSpacing(headerHeight)),

          // Sunset Section - Orange/Red - Centered content
          _buildEnhancedSunItem(
            context,
            icon: Icons.nightlight_round,
            time: prayerTimes["সূর্যাস্ত"],
            headerHeight: headerHeight,
            isDark: isDark,
            label: _text('sunset', context),
            isSunrise: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSunItem(
    BuildContext context, {
    required IconData icon,
    required String? time,
    required double headerHeight,
    required bool isDark,
    required String label,
    required bool isSunrise,
  }) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    String displayTime = time != null ? _formatTimeCompact(time) : "--:--";

    if (!languageProvider.isEnglish) {
      displayTime = _convertToBanglaNumbers(displayTime);
    }

    // Improved colors for sunrise and sunset
    final Color sunriseColor = isDark
        ? const Color(0xFFFFB74D) // Brighter golden yellow for dark mode
        : const Color(0xFFFF9800); // Vibrant orange for light mode

    final Color sunsetColor = isDark
        ? const Color(0xFFFF8A65) // Warm orange for dark mode
        : const Color(0xFFF4511E); // Vibrant deep orange for light mode

    final Color itemColor = isSunrise ? sunriseColor : sunsetColor;

    return Container(
      padding: EdgeInsets.all(_calculateSunItemPadding(headerHeight)),
      decoration: BoxDecoration(
        color: isDark
            ? itemColor.withOpacity(0.15) // Subtle background for dark mode
            : itemColor.withOpacity(0.08),
        // Very subtle background for light mode
        borderRadius: BorderRadius.circular(
          _calculateSunItemBorderRadius(headerHeight),
        ),
        border: Border.all(
          color: itemColor.withOpacity(isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with colored background
          Container(
            padding: EdgeInsets.all(_calculateSunIconPadding(headerHeight)),
            decoration: BoxDecoration(
              color: itemColor.withOpacity(isDark ? 0.25 : 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: itemColor,
              size: _calculateSunIconSize(headerHeight),
            ),
          ),

          SizedBox(width: _calculateSunIconSpacing(headerHeight)),

          // Text Content - Centered
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Added to minimize height
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: _calculateSunLabelFontSize(headerHeight),
                  fontWeight: FontWeight.w600,
                  color: itemColor,
                  height: 1.0, // Reduced line height
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _calculateSunTimeSpacing(headerHeight)),
              Text(
                displayTime,
                style: TextStyle(
                  fontSize: _calculateSunTimeFontSize(headerHeight),
                  fontWeight: FontWeight.w800,
                  color: itemColor,
                  fontFamily: 'Monospace',
                  height: 1.0, // Reduced line height
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== RESPONSIVE CALCULATION METHODS ==========
  // Add these new calculation methods for the enhanced sun section:
  // Update the existing sun card padding calculation for better spacing
  // Updated calculation methods with reduced padding and spacing
  double _calculateSunItemPadding(double headerHeight) {
    if (headerHeight < 150) return 3; // Reduced from 4
    if (headerHeight < 180) return 4; // Reduced from 5
    return 6; // Reduced from 6
  }

  double _calculateSunIconPadding(double headerHeight) {
    if (headerHeight < 150) return 1.5; // Reduced from 2
    if (headerHeight < 180) return 2; // Reduced from 2.5
    return 2.5; // Reduced from 3
  }

  double _calculateSunIconSize(double headerHeight) {
    if (headerHeight < 150) return 10; // Reduced from 12
    if (headerHeight < 180) return 12; // Reduced from 14
    return 14; // Reduced from 16
  }

  double _calculateSunIconSpacing(double headerHeight) {
    if (headerHeight < 150) return 3; // Reduced from 4
    if (headerHeight < 180) return 4; // Reduced from 5
    return 5; // Reduced from 6
  }

  double _calculateSunTimeFontSize(double headerHeight) {
    if (headerHeight < 150) return 10; // Reduced from 12
    if (headerHeight < 180) return 12; // Reduced from 14
    return 14; // Reduced from 16
  }

  double _calculateSunLabelFontSize(double headerHeight) {
    if (headerHeight < 150) return 8; // Reduced from 9
    if (headerHeight < 180) return 9; // Reduced from 10
    return 10; // Reduced from 11
  }

  double _calculateSunTimeSpacing(double headerHeight) {
    if (headerHeight < 150) return 1; // Reduced from 2
    return 2; // Reduced from 3
  }

  double _calculateSunItemBorderRadius(double headerHeight) {
    if (headerHeight < 150) return 6; // Reduced from 8
    if (headerHeight < 180) return 8; // Reduced from 10
    return 10; // Reduced from 12
  }

  // সান সেকশন প্যাডিং কমাতে
  double _calculateSunCardPadding(double headerHeight) {
    if (headerHeight < 150) return 2; // ← কমিয়ে দিন
    if (headerHeight < 180) return 3; // ← কমিয়ে দিন
    return 4; // ← কমিয়ে দিন
  }

  // Add these new calculation methods for the enhanced sun section:
  double _calculateSunHeaderFontSize(double headerHeight) {
    if (headerHeight < 150) return 9;
    if (headerHeight < 180) return 10;
    if (headerHeight < 200) return 11;
    return 12;
  }

  double _calculateSunHeaderSpacing(double headerHeight) {
    if (headerHeight < 150) return 4;
    if (headerHeight < 180) return 5;
    return 6;
  }

  double _calculateSunItemSpacing(double headerHeight) {
    if (headerHeight < 150) return 4;
    if (headerHeight < 180) return 5;
    return 6;
  }

  // Location section calculations
  double _calculateLocationPadding(double headerHeight) {
    if (headerHeight < 150) return 4;
    if (headerHeight < 180) return 5;
    if (headerHeight < 200) return 6;
    return 8;
  }

  double _calculateIconSize(double headerHeight) {
    if (headerHeight < 150) return 10;
    if (headerHeight < 180) return 12;
    if (headerHeight < 200) return 14;
    return 16;
  }

  double _calculateTitleFontSize(double headerHeight) {
    if (headerHeight < 150) return 7;
    if (headerHeight < 180) return 8;
    if (headerHeight < 200) return 9;
    return 10;
  }

  double _calculateLocationFontSize(double headerHeight) {
    if (headerHeight < 150) return 9;
    if (headerHeight < 180) return 10;
    if (headerHeight < 200) return 12;
    return 14;
  }

  double _calculateBorderRadius(double headerHeight) {
    if (headerHeight < 150) return 6;
    if (headerHeight < 180) return 8;
    return 10;
  }

  double _calculateIconPadding(double headerHeight) {
    if (headerHeight < 150) return 2;
    if (headerHeight < 180) return 3;
    return 4;
  }

  int _getMaxLines(double headerHeight) {
    if (headerHeight < 160) return 1;
    return 2;
  }

  double _calculateBadgePadding(double headerHeight) {
    if (headerHeight < 150) return 4;
    if (headerHeight < 180) return 5;
    return 6;
  }

  double _calculateBadgeBorderRadius(double headerHeight) {
    if (headerHeight < 150) return 3;
    if (headerHeight < 180) return 4;
    return 5;
  }

  double _calculateBadgeFontSize(double headerHeight) {
    if (headerHeight < 150) return 6;
    if (headerHeight < 180) return 7;
    return 8;
  }

  double _calculateButtonSize(double headerHeight) {
    if (headerHeight < 150) return 20;
    if (headerHeight < 180) return 22;
    if (headerHeight < 200) return 24;
    return 28;
  }

  double _calculateRefreshIconSize(double headerHeight) {
    if (headerHeight < 150) return 10;
    if (headerHeight < 180) return 12;
    return 14;
  }

  // Spacing calculations
  double _calculateSmallSpacing(double headerHeight) {
    if (headerHeight < 150) return 4;
    if (headerHeight < 180) return 6;
    return 8;
  }

  double _calculateMediumSpacing(double headerHeight) {
    if (headerHeight < 150) return 6;
    if (headerHeight < 180) return 8;
    return 10;
  }

  double _calculateTinySpacing(double headerHeight) {
    if (headerHeight < 150) return 2;
    if (headerHeight < 180) return 3;
    return 4;
  }

  double _calculateMicroSpacing(double headerHeight) {
    if (headerHeight < 150) return 1;
    return 2;
  }

  // Prayer card calculations - UPDATED FOR WIDER COUNTDOWN
  int _getPrayerSectionFlex(double headerHeight, double screenWidth) {
    if (screenWidth < 300) return 8; // Increased
    if (screenWidth < 400) return 9; // Increased
    return 10; // Increased
  }

  int _getSunSectionFlex(double headerHeight, double screenWidth) {
    if (screenWidth < 300) return 3; // Reduced
    if (screenWidth < 400) return 4; // Reduced
    return 5; // Reduced
  }

  // নেক্সট প্রেয়ার প্যাডিং কমাতে
  double _calculateCardPadding(double headerHeight) {
    if (headerHeight < 150) return 3; // ← কমিয়ে দিন
    if (headerHeight < 180) return 4; // ← কমিয়ে দিন
    return 5; // ← কমিয়ে দিন
  }

  double _calculateCardBorderRadius(double headerHeight) {
    if (headerHeight < 150) return 8;
    if (headerHeight < 180) return 10;
    return 12;
  }

  int _getPrayerInfoFlex(double headerHeight) {
    if (headerHeight < 120) return 2; // ← খুব ছোট স্ক্রিনে আরও কম Flex
    if (headerHeight < 150) return 3; // Reduced
    if (headerHeight < 180) return 4; // Reduced
    return 5; // Reduced
  }

  int _getCountdownFlex(double headerHeight) {
    if (headerHeight < 150) return 8; // Increased
    if (headerHeight < 180) return 9; // Increased
    return 10; // Increased
  }

  double _calculatePrayerTitleFontSize(double headerHeight) {
    if (headerHeight < 150) return 10;
    if (headerHeight < 180) return 11;
    return 12;
  }

  double _calculatePrayerNameFontSize(double headerHeight) {
    if (headerHeight < 120) return 8; // ← নতুন condition যোগ করুন
    if (headerHeight < 150) return 12;
    if (headerHeight < 180) return 14;
    return 16;
  }

  int _getPrayerNameMaxLines(double headerHeight) {
    if (headerHeight < 150) return 1;
    return 2;
  }

  // Countdown section calculations
  double _calculateCountdownPadding(double headerHeight) {
    if (headerHeight < 150) return 6; // Increased
    if (headerHeight < 180) return 8; // Increased
    return 10; // Increased
  }

  double _calculateCountdownVerticalPadding(double headerHeight) {
    if (headerHeight < 150) return 6; // Increased
    if (headerHeight < 180) return 8; // Increased
    return 10; // Increased
  }

  double _calculateCountdownBorderRadius(double headerHeight) {
    if (headerHeight < 150) return 8; // Increased
    if (headerHeight < 180) return 10; // Increased
    return 12; // Increased
  }

  double _calculateCountdownBorderWidth(double headerHeight) {
    if (headerHeight < 150) return 1.5;
    return 2.0;
  }

  double _calculateTimeNumberFontSize(double headerHeight) {
    if (headerHeight < 150) return 14; // Increased
    if (headerHeight < 180) return 16; // Increased
    if (headerHeight < 200) return 18; // Increased
    return 20; // Increased
  }

  double _calculateTimeNumberPadding(double headerHeight) {
    if (headerHeight < 150) return 3; // Increased
    if (headerHeight < 180) return 4; // Increased
    return 5; // Increased
  }

  double _calculateTimeNumberVerticalPadding(double headerHeight) {
    if (headerHeight < 150) return 2; // Increased
    return 3; // Increased
  }

  double _calculateTimeNumberBorderRadius(double headerHeight) {
    if (headerHeight < 150) return 6; // Increased
    return 8; // Increased
  }

  double _calculateColonFontSize(double headerHeight) {
    if (headerHeight < 150) return 12; // Increased
    if (headerHeight < 180) return 14; // Increased
    return 16; // Increased
  }

  double _calculateTimeLabelFontSize(double headerHeight) {
    if (headerHeight < 150) return 7; // Increased
    if (headerHeight < 180) return 8; // Increased
    if (headerHeight < 200) return 9; // Increased
    return 10; // Increased
  }

  double _calculateLabelSpacing(double headerHeight) {
    if (headerHeight < 150) return 4; // Increased
    if (headerHeight < 180) return 6; // Increased
    return 8; // Increased
  }

  double _calculateStatusFontSize(double headerHeight) {
    if (headerHeight < 150) return 7; // Increased
    if (headerHeight < 180) return 8; // Increased
    return 9; // Increased
  }

  double _calculateProgressBarHeight(double headerHeight) {
    if (headerHeight < 150) return 2;
    return 3;
  }

  double _calculateProgressBarMargin(double headerHeight) {
    if (headerHeight < 150) return 4; // Increased
    return 6; // Increased
  }

  double _calculateSunCardBorderRadius(double headerHeight) {
    if (headerHeight < 150) return 6;
    if (headerHeight < 180) return 8;
    return 10;
  }

  double _calculateSunDividerHeight(double headerHeight) {
    if (headerHeight < 150) return 0.5;
    return 1.0;
  }

  double _calculateSunDividerMargin(double headerHeight) {
    if (headerHeight < 150) return 1;
    if (headerHeight < 180) return 2;
    return 3;
  }

  // Helper Methods
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

  String _convertToBanglaNumbers(String text) {
    const englishToBangla = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
      ':': ':',
      ' ': ' ',
      '-': '-',
    };

    String result = '';
    for (int i = 0; i < text.length; i++) {
      result += englishToBangla[text[i]] ?? text[i];
    }
    return result;
  }

  Color _getCountdownBorderColor(Duration countdown) {
    final totalSeconds = countdown.inSeconds;
    if (totalSeconds <= 300)
      return const Color(0xFFE53935);
    else if (totalSeconds <= 1800)
      return const Color(0xFFFB8C00);
    else if (totalSeconds <= 3600)
      return const Color(0xFFFDD835);
    else
      return const Color(0xFF43A047);
  }

  Color _getCountdownTextColor(Duration countdown, bool isDark) {
    final totalSeconds = countdown.inSeconds;
    if (!isDark) {
      if (totalSeconds <= 300)
        return const Color(0xFFC62828);
      else if (totalSeconds <= 1800)
        return const Color(0xFFEF6C00);
      else if (totalSeconds <= 3600)
        return const Color(0xFFF9A825);
      else
        return const Color(0xFF2E7D32);
    } else {
      if (totalSeconds <= 300)
        return const Color(0xFFFFCDD2);
      else if (totalSeconds <= 1800)
        return const Color(0xFFFFE0B2);
      else if (totalSeconds <= 3600)
        return const Color(0xFFFFF9C4);
      else
        return const Color(0xFFC8E6C9);
    }
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

  double _calculateProgressValue(int totalSeconds) {
    if (totalSeconds <= 300)
      return 100.0;
    else if (totalSeconds <= 1800)
      return 75.0;
    else if (totalSeconds <= 3600)
      return 50.0;
    else
      return 25.0;
  }
}
