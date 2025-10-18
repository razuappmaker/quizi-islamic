// lib/services/notification_manager.dart
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() => _instance;

  NotificationManager._internal();

  static const String _channelKey = 'prayer_reminder_channel';
  static const String _lastScheduleKey = 'last_notification_schedule';

  // নোটিফিকেশন চ্যানেল ইনিশিয়ালাইজেশন
  Future<void> initializeNotificationChannel() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: _channelKey,
        channelName: 'Prayer Reminders',
        channelDescription: 'Notifications for prayer times',
        defaultColor: const Color(0xFF1B5E20),
        // সরাসরি Color object দিন
        ledColor: const Color(0xFF1B5E20),
        // সরাসরি Color object দিন
        importance: NotificationImportance.High,
        locked: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        criticalAlerts: true,
      ),
    ], debug: true);

    // Boot Complete Listener সেটআপ
    //_setupBootCompleteListener();
  }

  // Boot Complete Listener সেটআপ
  /* void _setupBootCompleteListener() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }*/

  // Static methods for boot complete handling
  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    print('Action received: ${receivedAction.id}');

    if (receivedAction.actionType == ActionType.SilentBackgroundAction) {
      await _instance._rescheduleAllNotificationsOnBoot();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print('Notification created: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print('Notification displayed: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    print('Notification dismissed: ${receivedAction.id}');
  }

  // সব নোটিফিকেশন শিডিউল করা
  Future<void> scheduleAllPrayerNotifications(
    Map<String, String> prayerTimes,
    Map<String, int> adjustments,
  ) async {
    if (prayerTimes.isEmpty) return;

    final adjustedTimes = _getAdjustedPrayerTimes(prayerTimes, adjustments);

    for (final entry in adjustedTimes.entries) {
      final prayerName = entry.key;
      final time = entry.value;

      if (["ফজর", "যোহর", "আসর", "মাগরিব", "ইশা"].contains(prayerName)) {
        await _schedulePrayerNotification(prayerName, time);
      }
    }

    print('✅ All notifications scheduled with adjusted times');

    // শেষ শিডিউল টাইম সেভ করুন
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastScheduleKey, DateTime.now().millisecondsSinceEpoch);
  }

  // নামাজের নোটিফিকেশন শিডিউল করা
  Future<void> _schedulePrayerNotification(
    String prayerName,
    String time,
  ) async {
    try {
      // পুরানো নোটিফিকেশন ক্যানসেল করুন
      await AwesomeNotifications().cancel(prayerName.hashCode);

      final prayerDate = _parsePrayerTime(time);
      if (prayerDate == null) return;

      final notificationTime = prayerDate.subtract(const Duration(minutes: 5));
      final now = DateTime.now();

      // আজকের নোটিফিকেশন শিডিউল করুন
      if (notificationTime.isAfter(now)) {
        await _createNotification(prayerName, notificationTime);
      }
      // আগামীকালের জন্য শিডিউল করুন
      else {
        final tomorrowNotificationTime = notificationTime.add(
          const Duration(days: 1),
        );
        await _createNotification(prayerName, tomorrowNotificationTime);
      }

      print('✅ Notification scheduled for $prayerName at $notificationTime');
    } catch (e) {
      print("Error scheduling notification for $prayerName: $e");
    }
  }

  // নোটিফিকেশন তৈরি করা
  Future<void> _createNotification(
    String prayerName,
    DateTime scheduleTime,
  ) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: prayerName.hashCode,
        channelKey: _channelKey,
        title: 'Prayer Times',
        body: '$prayerName - Azan starts in 5 minutes, Prepare for Prayer',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        criticalAlert: true,
      ),
      schedule: NotificationCalendar(
        year: scheduleTime.year,
        month: scheduleTime.month,
        day: scheduleTime.day,
        hour: scheduleTime.hour,
        minute: scheduleTime.minute,
        second: 0,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  // Adjusted prayer times বের করা
  Map<String, String> _getAdjustedPrayerTimes(
    Map<String, String> prayerTimes,
    Map<String, int> adjustments,
  ) {
    final adjustedTimes = Map<String, String>.from(prayerTimes);

    for (final entry in adjustments.entries) {
      final prayerName = entry.key;
      final adjustment = entry.value;

      if (adjustedTimes.containsKey(prayerName) && adjustment != 0) {
        final originalTime = adjustedTimes[prayerName]!;
        final adjustedTime = _adjustPrayerTime(originalTime, adjustment);
        adjustedTimes[prayerName] = adjustedTime;
      }
    }

    return adjustedTimes;
  }

  // নামাজের সময় অ্যাডজাস্ট করা
  String _adjustPrayerTime(String time, int adjustmentMinutes) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      minutes += adjustmentMinutes;

      while (minutes >= 60) {
        minutes -= 60;
        hours = (hours + 1) % 24;
      }

      while (minutes < 0) {
        minutes += 60;
        hours = (hours - 1) % 24;
        if (hours < 0) hours += 24;
      }

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error adjusting prayer time: $e');
      return time;
    }
  }

  // সময় পার্স করা
  DateTime? _parsePrayerTime(String time) {
    try {
      final now = DateTime.now();
      final parts = time.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      print('Error parsing prayer time: $e');
      return null;
    }
  }

  // Boot Complete হলে সব নোটিফিকেশন রিশিডিউল করা
  Future<void> _rescheduleAllNotificationsOnBoot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedPrayerTimes = prefs.getString("prayerTimes");

      if (savedPrayerTimes != null) {
        final Map<String, String> prayerTimes = Map<String, String>.from(
          jsonDecode(savedPrayerTimes),
        );

        final Map<String, int> prayerTimeAdjustments = {
          "ফজর": prefs.getInt('adjustment_fajr') ?? 0,
          "যোহর": prefs.getInt('adjustment_dhuhr') ?? 0,
          "আসর": prefs.getInt('adjustment_asr') ?? 0,
          "মাগরিব": prefs.getInt('adjustment_maghrib') ?? 0,
          "ইশা": prefs.getInt('adjustment_isha') ?? 0,
        };

        await scheduleAllPrayerNotifications(
          prayerTimes,
          prayerTimeAdjustments,
        );
        print('✅ All notifications rescheduled after boot');
      }
    } catch (e) {
      print('Error rescheduling notifications on boot: $e');
    }
  }

  // নোটিফিকেশন পারমিশন চেক
  Future<bool> checkAndRequestNotificationPermission() async {
    bool isNotificationAllowed = await AwesomeNotifications()
        .isNotificationAllowed();

    if (!isNotificationAllowed) {
      isNotificationAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications(
            channelKey: _channelKey,
            permissions: [
              NotificationPermission.Alert,
              NotificationPermission.Sound,
              NotificationPermission.Badge,
              NotificationPermission.Vibration,
              NotificationPermission.Light,
              NotificationPermission.CriticalAlert,
            ],
          );
    }

    return isNotificationAllowed;
  }

  // নোটিফিকেশন সিস্টেম হেলথ চেক
  Future<void> checkNotificationSystemHealth() async {
    try {
      // ১. পারমিশন চেক
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      print('🔔 Notification Permission: $isAllowed');

      // ২. শিডিউল্ড নোটিফিকেশন চেক
      final scheduledNotifications = await AwesomeNotifications()
          .listScheduledNotifications();
      print(
        '📋 Currently scheduled notifications: ${scheduledNotifications.length}',
      );

      for (final notification in scheduledNotifications) {
        final content = notification.content;
        print(' - ${content?.title} (ID: ${content?.id})');
      }

      // ৩. চ্যানেল স্ট্যাটাস চেক
      await _checkChannelStatus();
    } catch (e) {
      print('❌ Notification system health check failed: $e');
    }
  }

  // চ্যানেল স্ট্যাটাস চেক
  Future<void> _checkChannelStatus() async {
    try {
      final scheduledNotifications = await AwesomeNotifications()
          .listScheduledNotifications();

      if (scheduledNotifications.isNotEmpty) {
        print('📡 Notification channel is working properly');
      } else {
        print(
          '⚠️ No scheduled notifications found - channel might have issues',
        );
      }
    } catch (e) {
      print('❌ Error checking channel status: $e');
    }
  }

  // সব নোটিফিকেশন ক্যানসেল করা
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    print('🗑️ All notifications cancelled');
  }

  // নির্দিষ্ট নামাজের নোটিফিকেশন ক্যানসেল করা
  Future<void> cancelPrayerNotification(String prayerName) async {
    await AwesomeNotifications().cancel(prayerName.hashCode);
    print('🗑️ Notification cancelled for: $prayerName');
  }

  // শেষ শিডিউল টাইম চেক করা
  Future<bool> shouldRescheduleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSchedule = prefs.getInt(_lastScheduleKey);

    if (lastSchedule == null) return true;
    if (lastSchedule == null) return true;

    final lastScheduleTime = DateTime.fromMillisecondsSinceEpoch(lastSchedule);
    final now = DateTime.now();

    // ২৪ ঘণ্টার বেশি হয়ে গেলে রিশিডিউল করুন
    return now.difference(lastScheduleTime).inHours >= 24;
  }

  // Test notification (ডিবাগিং এর জন্য)
  Future<void> sendTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 9999,
        channelKey: _channelKey,
        title: 'Test Notification',
        body: 'This is a test notification from Prayer Time App',
        notificationLayout: NotificationLayout.Default,
      ),
    );
    print('✅ Test notification sent');
  }

  // Notification body based on language
  String getNotificationBody(bool isEnglish) {
    return isEnglish
        ? 'Azan starts in 5 minutes, Prepare for Prayer'
        : 'আযান এর মাত্র ৫ মিনিট বাকি, নামাজের প্রস্তুতি নিন';
  }

  // Prayer name based on language
  String getPrayerName(String prayerName, bool isEnglish) {
    if (isEnglish) {
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
        default:
          return prayerName;
      }
    }
    return prayerName;
  }
}
