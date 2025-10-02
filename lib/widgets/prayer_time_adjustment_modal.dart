// widgets/prayer_time_adjustment_modal.dart
import 'package:flutter/material.dart';

class PrayerTimeAdjustmentModal extends StatefulWidget {
  final Map<String, int> prayerTimeAdjustments;
  final Function(String, int) onAdjustmentChanged;
  final VoidCallback onResetAll;
  final VoidCallback onSaveAdjustments; // নতুন সেভ ফাংশন

  const PrayerTimeAdjustmentModal({
    Key? key,
    required this.prayerTimeAdjustments,
    required this.onAdjustmentChanged,
    required this.onResetAll,
    required this.onSaveAdjustments, // নতুন প্যারামিটার
  }) : super(key: key);

  @override
  State<PrayerTimeAdjustmentModal> createState() =>
      _PrayerTimeAdjustmentModalState();
}

class _PrayerTimeAdjustmentModalState extends State<PrayerTimeAdjustmentModal> {
  Map<String, int> _currentAdjustments = {};

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
    // Reset করতে 0-বর্তমান মান পাঠানো
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
                  "নামাজের সময় সামঞ্জস্য করুন",
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
                  setState(() {
                    _currentAdjustments = {
                      "ফজর": 0,
                      "যোহর": 0,
                      "আসর": 0,
                      "মাগরিব": 0,
                      "ইশা": 0,
                    };
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('সময় রিসেট করা হয়েছে'),
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
                        "সময় রিসেট",
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
            "স্থানীয় মসজিদের সময়ের সাথে মিলিয়ে নিন\n"
            "(+/-) বাটন দিয়ে ১ মিনিট করে সামঞ্জস্য করুন",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Adjustment List with reduced height
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height *
                  0.3, // 25% reduced from 0.4 to 0.3
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildAdjustmentList(),
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
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('সময় সেটিংস সফলভাবে সেভ করা হয়েছে'),
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
                          "সেভ করুন",
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
                    "বন্ধ করুন",
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

  List<Widget> _buildAdjustmentList() {
    final prayers = ["ফজর", "যোহর", "আসর", "মাগরিব", "ইশা"];

    return prayers.map((prayerName) {
      final adjustment = _currentAdjustments[prayerName] ?? 0;

      return Container(
        margin: const EdgeInsets.only(bottom: 8), // Reduced margin
        padding: const EdgeInsets.all(10), // Reduced padding
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
              width: 60, // Fixed width for prayer names
              child: Text(
                prayerName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                    ? "০ মিনিট"
                    : adjustment > 0
                    ? "+$adjustment মিনিট"
                    : "$adjustment মিনিট",
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
                  tooltip: "রিসেট করুন",
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
