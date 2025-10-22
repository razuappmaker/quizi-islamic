// widgets/prayer_time_adjustment_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class PrayerTimeAdjustmentModal extends StatefulWidget {
  final Map<String, int> prayerTimeAdjustments;
  final Function(String, int) onAdjustmentChanged;
  final VoidCallback onResetAll;
  final VoidCallback onSaveAdjustments;
  final VoidCallback onRescheduleNotifications; // নতুন callback যোগ করুন

  const PrayerTimeAdjustmentModal({
    Key? key,
    required this.prayerTimeAdjustments,
    required this.onAdjustmentChanged,
    required this.onResetAll,
    required this.onSaveAdjustments,
    required this.onRescheduleNotifications, // নতুন parameter
  }) : super(key: key);

  @override
  State<PrayerTimeAdjustmentModal> createState() =>
      _PrayerTimeAdjustmentModalState();
}

class _PrayerTimeAdjustmentModalState extends State<PrayerTimeAdjustmentModal> {
  Map<String, int> _currentAdjustments = {};

  // Language Texts (একই থাকবে)
  static const Map<String, Map<String, String>> _texts = {
    'adjustPrayerTimes': {
      'en': 'Adjust Prayer Times',
      'bn': 'নামাজের সময় সামঞ্জস্য করুন',
    },
    'adjustDescription': {
      'en':
          'Adjust according to local mosque timing\nUse (+/-) buttons to adjust by 1 minute',
      'bn':
          'স্থানীয় মসজিদের সময়ের সাথে মিলিয়ে নিন\n(+/-) বাটন দিয়ে ১ মিনিট করে সামঞ্জস্য করুন',
    },
    'resetTime': {'en': 'Reset Time', 'bn': 'সময় রিসেট'},
    'timeReset': {
      'en': 'Time reset successfully',
      'bn': 'সময় রিসেট করা হয়েছে',
    },
    'saveSettings': {
      'en': 'Time settings saved successfully',
      'bn': 'সময় সেটিংস সফলভাবে সেভ করা হয়েছে',
    },
    'save': {'en': 'Save', 'bn': 'সেভ করুন'},
    'close': {'en': 'Close', 'bn': 'বন্ধ করুন'},
    'minutes': {'en': 'minutes', 'bn': 'মিনিট'},
    'zeroMinutes': {'en': '0 minutes', 'bn': '০ মিনিট'},
    'resetTooltip': {'en': 'Reset', 'bn': 'রিসেট করুন'},
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

  @override
  void initState() {
    super.initState();
    _currentAdjustments = Map.from(widget.prayerTimeAdjustments);
  }

  void _adjustTime(String prayerName, int minutes) {
    setState(() {
      _currentAdjustments[prayerName] =
          (_currentAdjustments[prayerName] ?? 0) + minutes;
    });
    widget.onAdjustmentChanged(prayerName, minutes);
  }

  void _resetAdjustment(String prayerName) {
    setState(() {
      _currentAdjustments[prayerName] = 0;
    });
    widget.onAdjustmentChanged(prayerName, -_currentAdjustments[prayerName]!);
  }

  bool get _hasAdjustments {
    return _currentAdjustments.values.any((value) => value != 0);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _text('adjustPrayerTimes', context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              // Refresh Button with Text
              InkWell(
                onTap: () {
                  widget.onResetAll();
                  widget.onRescheduleNotifications(); // নোটিফিকেশন রিশিডিউল
                  setState(() {
                    _currentAdjustments = {
                      _text('fajr', context): 0,
                      _text('dhuhr', context): 0,
                      _text('asr', context): 0,
                      _text('maghrib', context): 0,
                      _text('isha', context): 0,
                    };
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_text('timeReset', context)),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.blue, size: 18),
                      SizedBox(width: 6),
                      Text(
                        _text('resetTime', context),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            _text('adjustDescription', context),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Adjustment List
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildAdjustmentList(context),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Save and Close Buttons
          Row(
            children: [
              // Save Button (only visible when there are adjustments)
              if (_hasAdjustments) ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      widget.onSaveAdjustments();
                      widget.onRescheduleNotifications(); // নোটিফিকেশন রিশিডিউল
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_text('saveSettings', context)),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 18),
                        SizedBox(width: 8),
                        Text(
                          _text('save', context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
              ],

              // Close Button
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    _text('close', context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAdjustmentList(BuildContext context) {
    final prayers = [
      _text('fajr', context),
      _text('dhuhr', context),
      _text('asr', context),
      _text('maghrib', context),
      _text('isha', context),
    ];

    return prayers.map((prayerName) {
      final adjustment = _currentAdjustments[prayerName] ?? 0;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
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
            // Prayer Name
            SizedBox(
              width: 60,
              child: Text(
                prayerName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Adjustment Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: adjustment == 0
                    ? Colors.grey.shade100
                    : adjustment > 0
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: adjustment == 0
                      ? Colors.grey.shade300
                      : adjustment > 0
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Text(
                adjustment == 0
                    ? _text('zeroMinutes', context)
                    : adjustment > 0
                    ? "+$adjustment ${_text('minutes', context)}"
                    : "$adjustment ${_text('minutes', context)}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: adjustment == 0
                      ? Colors.grey.shade600
                      : adjustment > 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ),

            const Spacer(),

            // Minus Button
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: IconButton(
                icon: Icon(Icons.remove, color: Colors.red, size: 16),
                onPressed: () => _adjustTime(prayerName, -1),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Plus Button
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.green, size: 16),
                onPressed: () => _adjustTime(prayerName, 1),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Reset Button
            if (adjustment != 0)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue, size: 14),
                  onPressed: () => _resetAdjustment(prayerName),
                  padding: EdgeInsets.zero,
                  tooltip: _text('resetTooltip', context),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }
}
