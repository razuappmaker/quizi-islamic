// widgets/prayer_list_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/prayer_time_service.dart';
import '../../providers/language_provider.dart';

class PrayerListSection extends StatelessWidget {
  final Map<String, String> prayerTimes;
  final String nextPrayer;
  final bool isSmallScreen;
  final bool isVerySmallScreen;
  final bool isTablet;
  final bool isSmallPhone;
  final PrayerTimeService prayerTimeService;
  final VoidCallback onRefresh;
  final Function(String, String) onPrayerTap;
  final Map<String, int> prayerTimeAdjustments;

  const PrayerListSection({
    Key? key,
    required this.prayerTimes,
    required this.nextPrayer,
    required this.isSmallScreen,
    required this.isVerySmallScreen,
    required this.isTablet,
    required this.isSmallPhone,
    required this.prayerTimeService,
    required this.onRefresh,
    required this.onPrayerTap,
    required this.prayerTimeAdjustments,
  }) : super(key: key);

  // Language Texts
  static const Map<String, Map<String, String>> _texts = {
    'prayerTimes': {'en': 'Prayer Times', 'bn': 'নামাজের সময়সমূহ'},
    'loading': {
      'en': 'Loading prayer times...',
      'bn': 'নামাজের সময় লোড হচ্ছে...',
    },
    'refresh': {'en': 'Refresh', 'bn': 'রিফ্রেশ করুন'},
    'next': {'en': 'Next', 'bn': 'পরবর্তী'},
    'fajr': {'en': 'Fajr', 'bn': 'ফজর'},
    'dhuhr': {'en': 'Dhuhr', 'bn': 'যোহর'},
    'asr': {'en': 'Asr', 'bn': 'আসর'},
    'maghrib': {'en': 'Maghrib', 'bn': 'মাগরিব'},
    'isha': {'en': 'Isha', 'bn': 'ইশা'},
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate dynamic heights based on screen size
    final double itemHeight = isVerySmallScreen
        ? 60
        : isSmallScreen
        ? 70
        : 80;

    final double fontSize = isVerySmallScreen
        ? 12
        : isSmallScreen
        ? 14
        : 16;

    final double iconSize = isVerySmallScreen
        ? 16
        : isSmallScreen
        ? 18
        : 20;

    final double paddingSize = isVerySmallScreen
        ? 8
        : isSmallScreen
        ? 10
        : 12;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            paddingSize,
            paddingSize,
            paddingSize,
            paddingSize,
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                size: iconSize,
              ),
              SizedBox(width: paddingSize * 0.5),
              Text(
                _text('prayerTimes', context),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: prayerTimes.isNotEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight;
                    final prayerCount = prayerTimes.entries
                        .where(
                          (e) => e.key != "সূর্যোদয়" && e.key != "সূর্যাস্ত",
                        )
                        .length;

                    // Dynamic card height based on screen height and available space
                    double cardHeight = _calculateCardHeight(
                      screenHeight,
                      availableHeight,
                      prayerCount,
                    );

                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        paddingSize * 0.5,
                        0,
                        paddingSize * 0.5,
                        paddingSize,
                      ),
                      children: prayerTimes.entries
                          .where(
                            (e) => e.key != "সূর্যোদয়" && e.key != "সূর্যাস্ত",
                          )
                          .map(
                            (e) => _buildPrayerRow(
                              context,
                              e.key,
                              e.value,
                              isDark,
                              cardHeight,
                              screenHeight,
                            ),
                          )
                          .toList(),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: isVerySmallScreen
                            ? 32
                            : isSmallScreen
                            ? 36
                            : 40,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: isVerySmallScreen
                            ? 6
                            : isSmallScreen
                            ? 8
                            : 10,
                      ),
                      Text(
                        _text('loading', context),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: isVerySmallScreen
                              ? 12
                              : isSmallScreen
                              ? 14
                              : 16,
                        ),
                      ),
                      SizedBox(
                        height: isVerySmallScreen
                            ? 6
                            : isSmallScreen
                            ? 8
                            : 10,
                      ),
                      ElevatedButton(
                        onPressed: onRefresh,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen
                                ? 16
                                : isSmallScreen
                                ? 18
                                : 20,
                            vertical: isVerySmallScreen
                                ? 8
                                : isSmallScreen
                                ? 10
                                : 12,
                          ),
                          textStyle: TextStyle(
                            fontSize: isVerySmallScreen
                                ? 12
                                : isSmallScreen
                                ? 14
                                : 16,
                          ),
                        ),
                        child: Text(_text('refresh', context)),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPrayerRow(
    BuildContext context,
    String prayerName,
    String time,
    bool isDark,
    double cardHeight,
    double screenHeight,
  ) {
    Color prayerColor = prayerTimeService.getPrayerColor(prayerName);
    IconData prayerIcon = prayerTimeService.getPrayerIcon(prayerName);
    final isNextPrayer = nextPrayer == prayerName;
    final displayPrayerName = _getPrayerName(prayerName, context);

    // Calculate dynamic sizes based on card height and screen size
    final double iconSize = isVerySmallScreen
        ? cardHeight * 0.25
        : isSmallScreen
        ? cardHeight * 0.28
        : cardHeight * 0.3;

    final double titleFontSize = isVerySmallScreen
        ? cardHeight * 0.18
        : isSmallScreen
        ? cardHeight * 0.19
        : cardHeight * 0.2;

    final double timeFontSize = isVerySmallScreen
        ? cardHeight * 0.16
        : isSmallScreen
        ? cardHeight * 0.17
        : cardHeight * 0.18;

    // Enhanced colors for dark mode next prayer
    final Color nextPrayerIconColor = isDark
        ? prayerColor.withOpacity(0.8)
        : prayerColor;

    final Color nextPrayerTextColor = isDark ? Colors.white : prayerColor;

    final Color nextPrayerBadgeTextColor = isDark ? Colors.white : prayerColor;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isVerySmallScreen
            ? 3
            : isSmallScreen
            ? 4
            : 5,
        horizontal: isVerySmallScreen
            ? 6
            : isSmallScreen
            ? 7
            : 8,
      ),
      height: cardHeight, // Use dynamic height
      decoration: BoxDecoration(
        color: isNextPrayer
            ? prayerColor.withOpacity(isDark ? 0.3 : 0.15)
            : isDark
            ? Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(
          isVerySmallScreen
              ? 10
              : isSmallScreen
              ? 11
              : 12,
        ),
        border: isNextPrayer
            ? Border.all(
                color: prayerColor.withOpacity(isDark ? 0.7 : 0.3),
                width: isVerySmallScreen ? 1.5 : 2.0,
              )
            : Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.transparent,
                width: 0.5,
              ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: isVerySmallScreen
                      ? 6
                      : isSmallScreen
                      ? 7
                      : 8,
                  offset: const Offset(0, 2),
                ),
                if (isNextPrayer)
                  BoxShadow(
                    color: prayerColor.withOpacity(0.8),
                    blurRadius: isVerySmallScreen
                        ? 12
                        : isSmallScreen
                        ? 14
                        : 15,
                    spreadRadius: isVerySmallScreen
                        ? 1
                        : isSmallScreen
                        ? 1.5
                        : 2,
                    offset: const Offset(0, 3),
                  ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: isVerySmallScreen
                      ? 4
                      : isSmallScreen
                      ? 5
                      : 6,
                  offset: const Offset(0, 2),
                ),
                if (isNextPrayer)
                  BoxShadow(
                    color: prayerColor.withOpacity(0.2),
                    blurRadius: isVerySmallScreen
                        ? 8
                        : isSmallScreen
                        ? 9
                        : 10,
                    spreadRadius: isVerySmallScreen
                        ? 0.5
                        : isSmallScreen
                        ? 0.75
                        : 1,
                    offset: const Offset(0, 3),
                  ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            isVerySmallScreen
                ? 10
                : isSmallScreen
                ? 11
                : 12,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            onPrayerTap(prayerName, time);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen
                  ? cardHeight * 0.15
                  : cardHeight * 0.2,
            ),
            child: Row(
              children: [
                // Prayer Icon - Enhanced for next prayer in dark mode
                Container(
                  width:
                      iconSize +
                      (isVerySmallScreen
                          ? 16
                          : isSmallScreen
                          ? 18
                          : 20),
                  height:
                      iconSize +
                      (isVerySmallScreen
                          ? 16
                          : isSmallScreen
                          ? 18
                          : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isNextPrayer && isDark
                          ? [prayerColor, prayerColor.withOpacity(0.7)]
                          : [
                              prayerColor.withOpacity(isDark ? 0.4 : 0.2),
                              prayerColor.withOpacity(isDark ? 0.3 : 0.1),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      isVerySmallScreen
                          ? 8
                          : isSmallScreen
                          ? 9
                          : 10,
                    ),
                    border: Border.all(
                      color: isNextPrayer && isDark
                          ? prayerColor
                          : prayerColor.withOpacity(isDark ? 0.3 : 0.2),
                      width: isNextPrayer && isDark
                          ? (isVerySmallScreen ? 1.5 : 2.0)
                          : 1,
                    ),
                    boxShadow: (isNextPrayer && isDark)
                        ? [
                            BoxShadow(
                              color: prayerColor.withOpacity(0.6),
                              blurRadius: isVerySmallScreen
                                  ? 8
                                  : isSmallScreen
                                  ? 9
                                  : 10,
                              spreadRadius: isVerySmallScreen
                                  ? 0.5
                                  : isSmallScreen
                                  ? 0.75
                                  : 1,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : isDark
                        ? [
                            BoxShadow(
                              color: prayerColor.withOpacity(0.2),
                              blurRadius: isVerySmallScreen
                                  ? 3
                                  : isSmallScreen
                                  ? 3.5
                                  : 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    prayerIcon,
                    color: isNextPrayer && isDark ? Colors.white : prayerColor,
                    size: iconSize.clamp(
                      isVerySmallScreen
                          ? 14
                          : isSmallScreen
                          ? 16
                          : 18,
                      isVerySmallScreen
                          ? 20
                          : isSmallScreen
                          ? 22
                          : 24,
                    ),
                  ),
                ),

                SizedBox(
                  width: isVerySmallScreen
                      ? 12
                      : isSmallScreen
                      ? 14
                      : 16,
                ),

                // Prayer Name - Enhanced for next prayer in dark mode
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            displayPrayerName,
                            style: TextStyle(
                              fontSize: titleFontSize.clamp(
                                isVerySmallScreen
                                    ? 12
                                    : isSmallScreen
                                    ? 14
                                    : 16,
                                isVerySmallScreen
                                    ? 16
                                    : isSmallScreen
                                    ? 18
                                    : 20,
                              ),
                              fontWeight: FontWeight.w600,
                              color: isNextPrayer
                                  ? nextPrayerTextColor
                                  : isDark
                                  ? Colors.white
                                  : Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (isNextPrayer) ...[
                            SizedBox(
                              width: isVerySmallScreen
                                  ? 6
                                  : isSmallScreen
                                  ? 7
                                  : 8,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isVerySmallScreen
                                    ? 6
                                    : isSmallScreen
                                    ? 7
                                    : 8,
                                vertical: isVerySmallScreen
                                    ? 1
                                    : isSmallScreen
                                    ? 1.5
                                    : 2,
                              ),
                              decoration: BoxDecoration(
                                color: prayerColor.withOpacity(
                                  isDark ? 0.4 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  isVerySmallScreen
                                      ? 10
                                      : isSmallScreen
                                      ? 11
                                      : 12,
                                ),
                                border: Border.all(
                                  color: prayerColor.withOpacity(
                                    isDark ? 0.8 : 0.2,
                                  ),
                                  width: isVerySmallScreen ? 1.0 : 1.5,
                                ),
                              ),
                              child: Text(
                                _text('next', context),
                                style: TextStyle(
                                  fontSize: (titleFontSize * 0.7).clamp(
                                    isVerySmallScreen
                                        ? 8
                                        : isSmallScreen
                                        ? 10
                                        : 12,
                                    isVerySmallScreen
                                        ? 12
                                        : isSmallScreen
                                        ? 14
                                        : 16,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  color: nextPrayerBadgeTextColor,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Time - Enhanced for next prayer in dark mode
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVerySmallScreen
                        ? 8
                        : isSmallScreen
                        ? 10
                        : 12,
                    vertical: isVerySmallScreen
                        ? 4
                        : isSmallScreen
                        ? 5
                        : 6,
                  ),
                  decoration: BoxDecoration(
                    color: isNextPrayer && isDark
                        ? prayerColor.withOpacity(0.2)
                        : isDark
                        ? Color(0xFF2D2D2D)
                        : Colors.grey[100]!,
                    borderRadius: BorderRadius.circular(
                      isVerySmallScreen
                          ? 6
                          : isSmallScreen
                          ? 7
                          : 8,
                    ),
                    border: Border.all(
                      color: isNextPrayer && isDark
                          ? prayerColor.withOpacity(0.5)
                          : isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      width: isNextPrayer && isDark
                          ? (isVerySmallScreen ? 0.8 : 1.0)
                          : 0.5,
                    ),
                  ),
                  child: Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      String displayTime = languageProvider.isEnglish
                          ? prayerTimeService.formatTimeTo12Hour(time)
                          : prayerTimeService.formatTimeToBanglaWithPeriod(
                              time,
                            );

                      return Text(
                        displayTime,
                        style: TextStyle(
                          fontSize: timeFontSize.clamp(
                            isVerySmallScreen
                                ? 10
                                : isSmallScreen
                                ? 12
                                : 14,
                            isVerySmallScreen
                                ? 14
                                : isSmallScreen
                                ? 16
                                : 18,
                          ),
                          fontWeight: FontWeight.w600,
                          color: isNextPrayer
                              ? nextPrayerTextColor
                              : isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                          letterSpacing: 0.3,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateCardHeight(
    double screenHeight,
    double availableHeight,
    int prayerCount,
  ) {
    if (prayerCount == 0) return 70.0;

    // Base calculation based on available height and prayer count
    double baseHeight = availableHeight / prayerCount;

    // Adjust based on screen size categories
    if (isVerySmallScreen) {
      return baseHeight.clamp(50, 60);
    } else if (isSmallScreen) {
      return baseHeight.clamp(55, 65);
    } else if (isSmallPhone) {
      return baseHeight.clamp(60, 70);
    } else if (isTablet) {
      return baseHeight.clamp(75, 90);
    } else {
      return baseHeight.clamp(70, 85);
    }
  }
}
