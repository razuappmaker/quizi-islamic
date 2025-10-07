// widgets/prohibited_time_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../prohibited_time_service.dart';
import '../providers/language_provider.dart';

class ProhibitedTimeSection extends StatelessWidget {
  final bool isSmallScreen;
  final bool isVerySmallScreen;
  final bool isTablet;
  final bool isSmallPhone;
  final Map<String, String> prayerTimes;
  final ProhibitedTimeService prohibitedTimeService;
  final Function(BuildContext, String, String) onShowInfo;

  const ProhibitedTimeSection({
    Key? key,
    required this.isSmallScreen,
    required this.isVerySmallScreen,
    required this.isTablet,
    required this.isSmallPhone,
    required this.prayerTimes,
    required this.prohibitedTimeService,
    required this.onShowInfo,
  }) : super(key: key);

  // Language Texts
  static const Map<String, Map<String, String>> _texts = {
    'prohibitedTimes': {'en': 'Prohibited Times', 'bn': 'নিষিদ্ধ সময়'},
    'prohibitedTimesInfo': {
      'en': 'About Prohibited Prayer Times',
      'bn': 'সালাতের নিষিদ্ধ সময় সম্পর্কে',
    },
    'morning': {'en': 'Dawn', 'bn': 'ভোর'},
    'noon': {'en': 'Noon', 'bn': 'দুপুর'},
    'evening': {'en': 'Evening', 'bn': 'সন্ধ্যা'},
    'nafalPrayer': {'en': 'Nafal Prayer', 'bn': 'নফল সালাত'},
    'nafalPrayerInfo': {
      'en': 'Nafal Prayer Times',
      'bn': 'নফল সালাতের ওয়াক্ত',
    },
    'specialFacts': {'en': 'Special Facts', 'bn': 'বিশেষ ফ্যাক্ট'},
    'specialFactsInfo': {
      'en': 'Special Facts About Prayer',
      'bn': 'সালাত সম্পর্কে বিশেষ ফ্যাক্ট',
    },
    'understand': {'en': 'Got it', 'bn': 'বুঝেছি'},
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate dynamic heights based on screen size
    final double sectionHeight = isVerySmallScreen
        ? 80
        : isSmallScreen
        ? 90
        : 100;

    final double titleFontSize = isVerySmallScreen
        ? 10
        : isSmallScreen
        ? 12
        : 14;

    final double timeFontSize = isVerySmallScreen
        ? 8
        : isSmallScreen
        ? 10
        : 11;

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
      height: sectionHeight,
      padding: EdgeInsets.fromLTRB(
        paddingSize,
        paddingSize * 0.5,
        paddingSize,
        isSmallScreen ? paddingSize * 0.5 : paddingSize,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Section - Prohibited Times
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _showBottomSheet(
                context,
                _text('prohibitedTimesInfo', context),
                prohibitedTimeService.getProhibitedTimeInfo(),
              ),
              child: Container(
                padding: EdgeInsets.all(paddingSize),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(
                    isVerySmallScreen
                        ? 8
                        : isSmallScreen
                        ? 9
                        : 10,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: isVerySmallScreen
                          ? 2
                          : isSmallScreen
                          ? 2.5
                          : 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Header Row
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _text('prohibitedTimes', context),
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: paddingSize * 0.5),
                          Icon(
                            Icons.info_outline,
                            color: isDark ? Colors.blue[200] : Colors.blue[700],
                            size: iconSize,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: paddingSize * 0.5),

                    // Prohibited Times Content
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.zero,
                        child: Table(
                          columnWidths: {
                            0: FixedColumnWidth(30), // Icon column
                            1: FixedColumnWidth(40), // Label column
                            2: FlexColumnWidth(), // Time column
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            _buildTableTimeRow(
                              context,
                              icon: Icons.wb_twilight,
                              label: _text('morning', context),
                              time: prohibitedTimeService
                                  .calculateSunriseProhibitedTime(prayerTimes),
                              fontSize: timeFontSize,
                              isDark: isDark,
                            ),
                            _buildTableTimeRow(
                              context,
                              icon: Icons.light_mode,
                              label: _text('noon', context),
                              time: prohibitedTimeService
                                  .calculateDhuhrProhibitedTime(prayerTimes),
                              fontSize: timeFontSize,
                              isDark: isDark,
                            ),
                            _buildTableTimeRow(
                              context,
                              icon: Icons.nightlight,
                              label: _text('evening', context),
                              time: prohibitedTimeService
                                  .calculateSunsetProhibitedTime(prayerTimes),
                              fontSize: timeFontSize,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: paddingSize * 0.8),

          // Right Section - Info Cards
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nafal Prayer Card
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: paddingSize * 0.4),
                    child: _buildInfoCard(
                      context,
                      _text('nafalPrayer', context),
                      _text('nafalPrayerInfo', context),
                      Colors.blue,
                      prohibitedTimeService.getNafalPrayerInfo(),
                      titleFontSize,
                      iconSize,
                      paddingSize,
                    ),
                  ),
                ),

                // Special Facts Card
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: paddingSize * 0.4),
                    child: _buildInfoCard(
                      context,
                      _text('specialFacts', context),
                      _text('specialFactsInfo', context),
                      Colors.orange,
                      prohibitedTimeService.getSpecialFacts(),
                      titleFontSize,
                      iconSize,
                      paddingSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableTimeRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String time,
    required double fontSize,
    required bool isDark,
  }) {
    return TableRow(
      children: [
        // Icon
        Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(
            icon,
            size: fontSize * 0.8,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),

        // Label
        Padding(
          padding: EdgeInsets.only(right: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize * 0.8,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Time
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            time,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[900],
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String dialogTitle,
    Color color,
    String info,
    double fontSize,
    double iconSize,
    double paddingSize,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showBottomSheet(context, dialogTitle, info),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(paddingSize * 0.8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(
            isVerySmallScreen
                ? 6
                : isSmallScreen
                ? 7
                : 8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: isVerySmallScreen
                  ? 1.5
                  : isSmallScreen
                  ? 1.8
                  : 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: color, size: iconSize - 2),
            SizedBox(width: paddingSize * 0.5),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate position for bottom sheet
    final double prohibitedSectionPosition = screenHeight * 0.65;
    final double availableSpace =
        prohibitedSectionPosition - MediaQuery.of(context).padding.top;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(
            bottom: screenHeight - prohibitedSectionPosition + 20,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(
                isVerySmallScreen
                    ? 16
                    : isSmallScreen
                    ? 18
                    : 20,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: isVerySmallScreen
                      ? 15
                      : isSmallScreen
                      ? 18
                      : 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            constraints: BoxConstraints(maxHeight: availableSpace * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with drag handle
                Container(
                  padding: EdgeInsets.only(
                    top: isVerySmallScreen
                        ? 12
                        : isSmallScreen
                        ? 14
                        : 16,
                    bottom: isVerySmallScreen
                        ? 6
                        : isSmallScreen
                        ? 7
                        : 8,
                  ),
                  child: Container(
                    width: isVerySmallScreen
                        ? 35
                        : isSmallScreen
                        ? 38
                        : 40,
                    height: isVerySmallScreen
                        ? 3
                        : isSmallScreen
                        ? 3.5
                        : 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title and close button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVerySmallScreen
                        ? 16
                        : isSmallScreen
                        ? 18
                        : 20,
                    vertical: isVerySmallScreen
                        ? 6
                        : isSmallScreen
                        ? 7
                        : 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isTablet
                                ? (isVerySmallScreen
                                      ? 18
                                      : isSmallScreen
                                      ? 19
                                      : 20)
                                : (isVerySmallScreen
                                      ? 16
                                      : isSmallScreen
                                      ? 17
                                      : 18),
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: isTablet
                              ? (isVerySmallScreen
                                    ? 22
                                    : isSmallScreen
                                    ? 23
                                    : 24)
                              : (isVerySmallScreen
                                    ? 18
                                    : isSmallScreen
                                    ? 19
                                    : 20),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Divider
                Divider(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  height: 1,
                  thickness: 1,
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isVerySmallScreen
                          ? 16
                          : isSmallScreen
                          ? 18
                          : 20,
                    ),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: isTablet
                            ? (isVerySmallScreen
                                  ? 14
                                  : isSmallScreen
                                  ? 15
                                  : 16)
                            : (isVerySmallScreen
                                  ? 12
                                  : isSmallScreen
                                  ? 13
                                  : 14),
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        height: isVerySmallScreen
                            ? 1.4
                            : isSmallScreen
                            ? 1.5
                            : 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),

                // Close button at bottom
                Container(
                  padding: EdgeInsets.fromLTRB(
                    isVerySmallScreen
                        ? 16
                        : isSmallScreen
                        ? 18
                        : 20,
                    isVerySmallScreen
                        ? 8
                        : isSmallScreen
                        ? 9
                        : 10,
                    isVerySmallScreen
                        ? 16
                        : isSmallScreen
                        ? 18
                        : 20,
                    isVerySmallScreen
                        ? 16
                        : isSmallScreen
                        ? 18
                        : 20,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.blue[700]
                            : Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isVerySmallScreen
                                ? 10
                                : isSmallScreen
                                ? 11
                                : 12,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isVerySmallScreen
                              ? 12
                              : isSmallScreen
                              ? 13
                              : 14,
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _text('understand', context),
                        style: TextStyle(
                          fontSize: isTablet
                              ? (isVerySmallScreen
                                    ? 14
                                    : isSmallScreen
                                    ? 15
                                    : 16)
                              : (isVerySmallScreen
                                    ? 12
                                    : isSmallScreen
                                    ? 13
                                    : 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
