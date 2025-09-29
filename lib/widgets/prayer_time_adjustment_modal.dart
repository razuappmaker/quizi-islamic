// widgets/prayer_time_adjustment_modal.dart
import 'package:flutter/material.dart';

class PrayerTimeAdjustmentModal extends StatefulWidget {
  final Map<String, int> prayerTimeAdjustments;
  final Function(String, int) onAdjustmentChanged;
  final VoidCallback onResetAll;

  const PrayerTimeAdjustmentModal({
    Key? key,
    required this.prayerTimeAdjustments,
    required this.onAdjustmentChanged,
    required this.onResetAll,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "নামাজের সময় সামঞ্জস্য করুন",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue),
                onPressed: () {
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
                },
                tooltip: "সব রিসেট করুন",
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            "স্থানীয় মসজিদের সময়ের সাথে মিলিয়ে নিন\n"
            "(+/-) বাটন দিয়ে ১ মিনিট করে প্রয়োজনমতো সামঞ্জস্য করুন",

            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),

          const SizedBox(height: 20),

          // Adjustment List
          ..._buildAdjustmentList(),

          const SizedBox(height: 20),

          // Close Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("বন্ধ করুন"),
            ),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                prayerName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            // Adjustment Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: adjustment == 0
                    ? Colors.grey.shade100
                    : adjustment > 0
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
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
                  fontWeight: FontWeight.w600,
                  color: adjustment == 0
                      ? Colors.grey.shade600
                      : adjustment > 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Minus Button
            IconButton(
              icon: Icon(Icons.remove, color: Colors.red),
              onPressed: () => _adjustTime(prayerName, -1),
              style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
            ),

            // Plus Button
            IconButton(
              icon: Icon(Icons.add, color: Colors.green),
              onPressed: () => _adjustTime(prayerName, 1),
              style: IconButton.styleFrom(
                backgroundColor: Colors.green.shade50,
              ),
            ),

            // Reset Button
            if (adjustment != 0)
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue, size: 18),
                onPressed: () => _resetAdjustment(prayerName),
                tooltip: "রিসেট করুন",
              ),
          ],
        ),
      );
    }).toList();
  }
}
