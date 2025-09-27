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
    required this.prayerTimeService,
    required this.onRefresh,
    required this.useManualLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        10,
        isVerySmallScreen
            ? 4
            : isSmallScreen
            ? 6
            : 8,
        10,
        isVerySmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.green.shade900,
                  Colors.green.shade800,
                  Colors.green.shade700,
                ]
              : [
                  Colors.green.shade600,
                  Colors.green.shade500,
                  Colors.green.shade400,
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.green.shade800.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section - Location and Refresh (Ultra Compact)
          _buildUltraCompactTopSection(isDark),

          SizedBox(height: isVerySmallScreen ? 4 : 6),

          // Bottom Section - Prayer Info and Sun Times (Ultra Compact)
          _buildUltraCompactBottomSection(isDark),
        ],
      ),
    );
  }

  Widget _buildUltraCompactTopSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
      child: Row(
        children: [
          // Location Icon
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.green.shade800.withOpacity(0.25)
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              useManualLocation ? Icons.pin_drop : Icons.my_location,
              color: Colors.white,
              size: isVerySmallScreen ? 12 : 14,
            ),
          ),

          const SizedBox(width: 8),

          // Location Text (বর্তমান অবস্থান removed)
          Expanded(
            child: Text(
              "$cityName, $countryName",
              style: TextStyle(
                fontSize: isVerySmallScreen ? 11 : 12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Manual Location Badge (if applicable)
          if (useManualLocation) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                "মানুয়াল",
                style: TextStyle(
                  fontSize: 7,
                  color: Colors.orange.shade100,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],

          // Refresh Button
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: isVerySmallScreen ? 12 : 14,
              ),
              iconSize: isVerySmallScreen ? 12 : 14,
              padding: const EdgeInsets.all(3),
              tooltip: "রিফ্রেশ করুন",
              splashRadius: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraCompactBottomSection(bool isDark) {
    return Row(
      children: [
        // Next Prayer Countdown
        Expanded(flex: 7, child: _buildUltraCompactNextPrayerCard(isDark)),

        SizedBox(width: isVerySmallScreen ? 4 : 5),

        // Sunrise/Sunset Times
        Expanded(flex: 5, child: _buildUltraCompactSunTimesCard(isDark)),
      ],
    );
  }

  Widget _buildUltraCompactNextPrayerCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Text(
            "পরবর্তী নামাজ",
            style: TextStyle(
              fontSize: isVerySmallScreen ? 9 : 10,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          // Prayer Name
          Text(
            nextPrayer.isNotEmpty ? nextPrayer : "লোড হচ্ছে...",
            style: TextStyle(
              fontSize: isVerySmallScreen ? 10 : 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Countdown Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUltraCompactTimeUnit("ঘণ্টা", countdown.inHours),
                _buildUltraCompactDivider(),
                _buildUltraCompactTimeUnit("মিনিট", countdown.inMinutes % 60),
                _buildUltraCompactDivider(),
                _buildUltraCompactTimeUnit("সেকেন্ড", countdown.inSeconds % 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraCompactSunTimesCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 5 : 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange.withOpacity(isDark ? 0.3 : 0.4),
            Colors.deepOrange.withOpacity(isDark ? 0.2 : 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.25), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // সূর্যোদয় with text
          _buildUltraCompactSunItemWithText(
            icon: Icons.wb_twilight,
            label: "সূর্যোদয়",
            time: prayerTimes["সূর্যোদয়"],
          ),

          Container(
            height: 1,
            margin: EdgeInsets.symmetric(vertical: isVerySmallScreen ? 2 : 3),
            color: Colors.white.withOpacity(0.25),
          ),

          // সূর্যাস্ত with text
          _buildUltraCompactSunItemWithText(
            icon: Icons.nightlight_round,
            label: "সূর্যাস্ত",
            time: prayerTimes["সূর্যাস্ত"],
          ),
        ],
      ),
    );
  }

  Widget _buildUltraCompactSunItemWithText({
    required IconData icon,
    required String label,
    required String? time,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: isVerySmallScreen ? 10 : 12),
        const SizedBox(width: 3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 7 : 8,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                time != null ? _formatTimeCompact(time) : "--:--",
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 9 : 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUltraCompactTimeUnit(String label, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: isVerySmallScreen ? 12 : 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 6,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUltraCompactDivider() {
    return Container(
      width: 0.8,
      height: 16,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.3),
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
