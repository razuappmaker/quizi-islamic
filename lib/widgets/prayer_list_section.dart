// widgets/prayer_list_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../prayer_time_service.dart';

class PrayerListSection extends StatelessWidget {
  final Map<String, String> prayerTimes;
  final String nextPrayer;
  final bool isSmallScreen;
  final bool isVerySmallScreen;
  final PrayerTimeService prayerTimeService;
  final VoidCallback onRefresh;
  final Function(String, String) onPrayerTap;

  const PrayerListSection({
    Key? key,
    required this.prayerTimes,
    required this.nextPrayer,
    required this.isSmallScreen,
    required this.isVerySmallScreen,
    required this.prayerTimeService,
    required this.onRefresh,
    required this.onPrayerTap,
    required Map<String, int> prayerTimeAdjustments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                "নামাজের সময়সমূহ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: prayerTimes.isNotEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                  children: prayerTimes.entries
                      .where(
                        (e) => e.key != "সূর্যোদয়" && e.key != "সূর্যাস্ত",
                      )
                      .map(
                        (e) => _buildPrayerRow(context, e.key, e.value, isDark),
                      )
                      .toList(),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        "নামাজের সময় লোড হচ্ছে...",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: onRefresh,
                        child: Text("রিফ্রেশ করুন"),
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
  ) {
    Color prayerColor = prayerTimeService.getPrayerColor(prayerName);
    IconData prayerIcon = prayerTimeService.getPrayerIcon(prayerName);
    final isNextPrayer = nextPrayer == prayerName;

    // Calculate dynamic dimensions
    final double cardHeight = _calculateCardHeight();
    final double iconSize = isVerySmallScreen ? 16.0 : 20.0;
    final double titleFontSize = isVerySmallScreen ? 14.0 : 16.0;
    final double timeFontSize = isVerySmallScreen ? 12.0 : 14.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isNextPrayer
            ? prayerColor.withOpacity(isDark ? 0.25 : 0.15)
            : isDark
            ? Colors.grey[850]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isNextPrayer
            ? Border.all(color: prayerColor.withOpacity(0.3), width: 1.5)
            : Border.all(color: Colors.transparent, width: 0),
        boxShadow: isDark
            ? [
                if (isNextPrayer)
                  BoxShadow(
                    color: prayerColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
                if (isNextPrayer)
                  BoxShadow(
                    color: prayerColor.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            onPrayerTap(prayerName, time);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: cardHeight,
            child: Row(
              children: [
                // Prayer Icon
                Container(
                  width: iconSize + 20,
                  height: iconSize + 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        prayerColor.withOpacity(isDark ? 0.3 : 0.2),
                        prayerColor.withOpacity(isDark ? 0.2 : 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: prayerColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(prayerIcon, color: prayerColor, size: iconSize),
                ),

                const SizedBox(width: 16),

                // Prayer Name
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            prayerName,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              color: isNextPrayer
                                  ? prayerColor
                                  : isDark
                                  ? Colors.white
                                  : Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (isNextPrayer) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: prayerColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "পরবর্তী",
                                style: TextStyle(
                                  fontSize: titleFontSize - 4,
                                  fontWeight: FontWeight.w700,
                                  color: prayerColor,
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

                // Time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[800]!.withOpacity(0.5)
                        : Colors.grey[100]!,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    prayerTimeService.formatTimeTo12Hour(time),
                    style: TextStyle(
                      fontSize: timeFontSize,
                      fontWeight: FontWeight.w600,
                      color: isNextPrayer
                          ? prayerColor
                          : isDark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateCardHeight() {
    if (isVerySmallScreen) return 60.0;
    if (isSmallScreen) return 70.0;
    return 80.0;
  }
}
