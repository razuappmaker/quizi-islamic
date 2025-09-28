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
    final screenHeight = MediaQuery.of(context).size.height;

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
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
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
    double cardHeight,
    double screenHeight,
  ) {
    Color prayerColor = prayerTimeService.getPrayerColor(prayerName);
    IconData prayerIcon = prayerTimeService.getPrayerIcon(prayerName);
    final isNextPrayer = nextPrayer == prayerName;

    // Calculate dynamic sizes based on card height
    final double iconSize = cardHeight * 0.3;
    final double titleFontSize = cardHeight * 0.2;
    final double timeFontSize = cardHeight * 0.18;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      height: cardHeight, // Use dynamic height
      decoration: BoxDecoration(
        color: isNextPrayer
            ? prayerColor.withOpacity(isDark ? 0.25 : 0.15)
            : isDark
            ? Color(0xFF1E1E1E) // Professional dark grey
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isNextPrayer
            ? Border.all(
                color: prayerColor.withOpacity(isDark ? 0.5 : 0.3),
                width: 1.5,
              )
            : Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.transparent,
                width: 0.5,
              ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                if (isNextPrayer)
                  BoxShadow(
                    color: prayerColor.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
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
            padding: EdgeInsets.symmetric(horizontal: cardHeight * 0.2),
            child: Row(
              children: [
                // Prayer Icon
                Container(
                  width: iconSize + 20,
                  height: iconSize + 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        prayerColor.withOpacity(isDark ? 0.4 : 0.2),
                        prayerColor.withOpacity(isDark ? 0.3 : 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: prayerColor.withOpacity(isDark ? 0.3 : 0.2),
                      width: 1,
                    ),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: prayerColor.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    prayerIcon,
                    color: prayerColor,
                    size: iconSize.clamp(16, 24), // Limit icon size
                  ),
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
                              fontSize: titleFontSize.clamp(14, 18),
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
                                color: prayerColor.withOpacity(
                                  isDark ? 0.2 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: prayerColor.withOpacity(
                                    isDark ? 0.4 : 0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "পরবর্তী",
                                style: TextStyle(
                                  fontSize: (titleFontSize * 0.7).clamp(10, 14),
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
                        ? Color(0xFF2D2D2D) // Professional dark background
                        : Colors.grey[100]!,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    prayerTimeService.formatTimeTo12Hour(time),
                    style: TextStyle(
                      fontSize: timeFontSize.clamp(12, 16),
                      fontWeight: FontWeight.w600,
                      color: isNextPrayer
                          ? prayerColor
                          : isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
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

  double _calculateCardHeight(
    double screenHeight,
    double availableHeight,
    int prayerCount,
  ) {
    if (prayerCount == 0) return 70.0;

    // Base calculation based on available height and prayer count
    double baseHeight = availableHeight / prayerCount;

    // Adjust based on screen height
    if (screenHeight < 600) {
      // Very small screens (under 600px)
      return baseHeight.clamp(55, 65);
    } else if (screenHeight < 700) {
      // Small screens (600px - 700px)
      return baseHeight.clamp(60, 75);
    } else if (screenHeight < 800) {
      // Medium screens (700px - 800px)
      return baseHeight.clamp(65, 80);
    } else if (screenHeight < 900) {
      // Large screens (800px - 900px)
      return baseHeight.clamp(70, 85);
    } else {
      // Very large screens (900px+)
      return baseHeight.clamp(75, 90);
    }
  }
}
