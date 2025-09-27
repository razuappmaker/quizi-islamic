// widgets/prohibited_time_section.dart
import 'package:flutter/material.dart';
import '../prohibited_time_service.dart';

class ProhibitedTimeSection extends StatelessWidget {
  final bool isSmallScreen;
  final Map<String, String> prayerTimes;
  final ProhibitedTimeService prohibitedTimeService;
  final Function(BuildContext, String, String) onShowInfo;

  const ProhibitedTimeSection({
    Key? key,
    required this.isSmallScreen,
    required this.prayerTimes,
    required this.prohibitedTimeService,
    required this.onShowInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(10, 4, 10, isSmallScreen ? 4 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "নিষিদ্ধ সময়",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onShowInfo(
                          context,
                          "সালাতের নিষিদ্ধ সময় সম্পর্কে",
                          prohibitedTimeService.getProhibitedTimeInfo(),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: isDark ? Colors.blue[200] : Colors.blue[700],
                          size: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ভোর: ${prohibitedTimeService.calculateSunriseProhibitedTime(prayerTimes)}",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "দুপুর: ${prohibitedTimeService.calculateDhuhrProhibitedTime(prayerTimes)}",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "সন্ধ্যা: ${prohibitedTimeService.calculateSunsetProhibitedTime(prayerTimes)}",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              children: [
                _buildInfoCard(
                  context,
                  "নফল সালাত",
                  "নফল সালাতের ওয়াক্ত",
                  Colors.blue,
                  prohibitedTimeService.getNafalPrayerInfo(),
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  context,
                  "বিশেষ ফ্যাক্ট",
                  "সালাত সম্পর্কে বিশেষ ফ্যাক্ট",
                  Colors.orange,
                  prohibitedTimeService.getSpecialFacts(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String dialogTitle,
    Color color,
    String info,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSmallScreen = MediaQuery.of(context).size.height < 700;

    return GestureDetector(
      onTap: () => onShowInfo(context, dialogTitle, info),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_up,
              color: color,
              size: isSmallScreen ? 12 : 14,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
