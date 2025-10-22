// utils/admin_gesture_detector.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminGestureDetector {
  static bool _isLongPressing = false;
  static DateTime? _pressStartTime;

  static Widget wrapWithAdminGesture({
    required Widget child,
    required VoidCallback onAdminAccess,
    required BuildContext context,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        _pressStartTime = DateTime.now();
        _isLongPressing = true;
        _startLongPressCheck(onAdminAccess, context);
      },
      onTapUp: (_) {
        _isLongPressing = false;
      },
      onTapCancel: () {
        _isLongPressing = false;
      },
      child: child,
    );
  }

  static void _startLongPressCheck(
    VoidCallback onAdminAccess,
    BuildContext context,
  ) async {
    final startTime = _pressStartTime;
    if (startTime == null) return;

    // 5 সেকেন্ড পর চেক করুন
    await Future.delayed(const Duration(seconds: 5));

    if (_isLongPressing && _pressStartTime == startTime) {
      _isLongPressing = false;

      // ভাইব্রেশন (ঐচ্ছিক)
      // HapticFeedback.heavyImpact();

      // এডমিন এক্সেস অন করুন
      onAdminAccess();

      // স্ন্যাকবার দেখান
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'এডমিন প্যানেল এক্টিভেট করা হয়েছে!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
