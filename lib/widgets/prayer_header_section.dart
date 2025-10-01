// widgets/prayer_header_section.dart
import 'package:flutter/material.dart';
import '../prayer_time_service.dart';

class PrayerHeaderSection extends StatelessWidget {
  final String? cityName;
  final String? countryName;
  final String nextPrayer;
  final Duration countdown;
  final Map<String, String> prayerTimes;
  final bool isSmallScreen;
  final bool isVerySmallScreen;
  final bool isTablet; // Added parameter
  final bool isSmallPhone; // Added parameter
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
    required this.isTablet, // Added parameter
    required this.isSmallPhone, // Added parameter
    required this.prayerTimeService,
    required this.onRefresh,
    required this.useManualLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate dynamic heights based on screen size
    final double headerHeight = isVerySmallScreen
        ? 140 // ছোট স্ক্রিনে ১৫% কম
        : isSmallScreen
        ? 160 // মাঝারি স্ক্রিনে ১০% কম
        : 180; // বড় স্ক্রিনে মূল সাইজ

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
              ? [
                  Color(0xFF0D4A3A), // Deep teal green
                  Color(0xFF1A6B52), // Medium teal
                  Color(0xFF2A8C6E), // Bright teal
                ]
              : [
                  Color(0xFFE8F5E8), // Very light mint
                  Color(0xFFC8E6C9), // Light mint
                  Color(0xFFA5D6A7), // Soft green
                ],
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

          // Location Text with prefix
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "আপনি এখন অবস্থান করছেন",
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
                  "$cityName, $countryName",
                  style: TextStyle(
                    fontSize: textFontSize,
                    color: isDark ? Colors.white : Color(0xFF1B5E20),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.05,
                  ),
                  maxLines: 1,
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
                "মানুয়াল",
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
              tooltip: "রিফ্রেশ করুন",
              splashRadius: refreshSplashRadius,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPrayerSunSection(
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
          // Prayer Info (Left side)
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "পরবর্তী নামাজ",
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
                  nextPrayer.isNotEmpty ? nextPrayer : "লোড হচ্ছে...",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTimeUnit(
                        "ঘণ্টা",
                        countdown.inHours,
                        timeUnitFontSize,
                        timeLabelFontSize,
                        isDark,
                      ),
                      _buildDivider(isVerySmallScreen, isSmallScreen, isDark),
                      _buildTimeUnit(
                        "মিনিট",
                        countdown.inMinutes % 60,
                        timeUnitFontSize,
                        timeLabelFontSize,
                        isDark,
                      ),
                      _buildDivider(isVerySmallScreen, isSmallScreen, isDark),
                      _buildTimeUnit(
                        "সেকেন্ড",
                        countdown.inSeconds % 60,
                        timeUnitFontSize,
                        timeLabelFontSize,
                        isDark,
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
                    _getCountdownStatus(countdown),
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

  // Dynamic border color based on remaining time
  Color _getCountdownBorderColor(Duration countdown) {
    final totalSeconds = countdown.inSeconds;

    if (totalSeconds <= 300) {
      return Color(0xFFE53935); // Red
    } else if (totalSeconds <= 1800) {
      return Color(0xFFFB8C00); // Orange
    } else if (totalSeconds <= 3600) {
      return Color(0xFFFDD835); // Yellow
    } else {
      return Color(0xFF43A047); // Green
    }
  }

  // Better text color for countdown status - Updated for light mode
  Color _getCountdownTextColor(Duration countdown, bool isDark) {
    // Light mode-এ সাদা, Dark mode-এ আগের মতো
    if (!isDark) {
      return Colors.white; // Light mode-এ সাদা
    }

    // Dark mode-এর জন্য আগের colors
    final totalSeconds = countdown.inSeconds;
    if (totalSeconds <= 300) {
      return Color(0xFFFFCDD2); // Light red
    } else if (totalSeconds <= 1800) {
      return Color(0xFFFFE0B2); // Light orange
    } else if (totalSeconds <= 3600) {
      return Color(0xFFFFF9C4); // Light yellow
    } else {
      return Color(0xFFC8E6C9); // Light green
    }
  }

  // Countdown status text
  String _getCountdownStatus(Duration countdown) {
    final totalSeconds = countdown.inSeconds;

    if (totalSeconds <= 60) {
      return "শীঘ্রই শুরু";
    } else if (totalSeconds <= 300) {
      return "খুব শীঘ্রই";
    } else if (totalSeconds <= 1800) {
      return "শীঘ্রই";
    } else if (totalSeconds <= 3600) {
      return "অল্প সময়";
    } else {
      return "সময় বাকি";
    }
  }

  Widget _buildCompactSunTimesCard(
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
              ? [
                  Color(0xFFE65100), // Deep orange
                  Color(0xFFEF6C00), // Medium orange
                ]
              : [
                  Color(0xFFFFCC80), // Light orange
                  Color(0xFFFFB74D), // Medium light orange
                ],
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
          // সূর্যোদয় with text
          _buildCompactSunItemWithText(
            icon: Icons.wb_twilight,
            label: "সূর্যোদয়",
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

          // সূর্যাস্ত with text
          _buildCompactSunItemWithText(
            icon: Icons.nightlight_round,
            label: "সূর্যাস্ত",
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

  Widget _buildCompactSunItemWithText({
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

  Widget _buildDivider(
    bool isVerySmallScreen,
    bool isSmallScreen,
    bool isDark,
  ) {
    return Container(
      width: 1,
      height: isVerySmallScreen
          ? 20
          : isSmallScreen
          ? 24
          : 28,
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
