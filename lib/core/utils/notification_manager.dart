// lib/services/notification_manager.dart
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/language_provider.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() => _instance;

  NotificationManager._internal();

  static const String _channelKey = 'prayer_reminder_channel';
  static const String _lastScheduleKey = 'last_notification_schedule';
  BuildContext? _context;
  bool _isEnglishCached = false;

  // Context সেট করার মেথড
  void setContext(BuildContext context) {
    _context = context;
    _updateLanguageCache();
    print(
      '🎯 NotificationManager context set for language: ${_isEnglishCached ? 'English' : 'Bengali'}',
    );
  }

  // ভাষা ক্যাশে আপডেট করুন
  void _updateLanguageCache() {
    if (_context != null) {
      try {
        final languageProvider = Provider.of<LanguageProvider>(
          _context!,
          listen: false,
        );
        _isEnglishCached = languageProvider.isEnglish;
      } catch (e) {
        print('Error getting language from context: $e');
        _isEnglishCached = false;
      }
    } else {
      _isEnglishCached = false;
    }
  }

  // বর্তমান ভাষা পাওয়া - Synchronous
  bool get _isEnglish {
    return _isEnglishCached;
  }

  // SharedPreferences থেকে ভাষা async ভাবে পাওয়া (শুধু fallback এর জন্য)
  Future<bool> _getLanguageFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('current_language') ?? 'bn';
      return savedLang == 'en';
    } catch (e) {
      return false; // ডিফল্ট বাংলা
    }
  }

  // ভাষা ভিত্তিক টেক্সট
  final Map<String, Map<String, String>> _notificationTexts = {
    'prayer_reminder_title': {
      'en': '🕌 Prayer Time Reminder',
      'bn': '🕌 নামাজের সময় রিমাইন্ডার',
    },

    'prayer_reminder_body': {
      'en':
          '5 minutes left for {prayer} Azan. '
          'Azan time: {time}, '
          'please prepare for prayer.',
      'bn':
          '{prayer} আযান ৫ মিনিট বাকি। '
          'আযানের সময়: {time}, '
          'অনুগ্রহ করে নামাজের প্রস্তুতি নিন',
    },
    'fajr': {'en': 'Fajr', 'bn': 'ফজর'},
    'dhuhr': {'en': 'Dhuhr', 'bn': 'যোহর'},
    'asr': {'en': 'Asr', 'bn': 'আসর'},
    'maghrib': {'en': 'Maghrib', 'bn': 'মাগরিব'},
    'isha': {'en': 'Isha', 'bn': 'ইশা'},
  };

  // স্থানীয়কৃত টেক্সট পাওয়া
  String _getLocalizedText(String key) {
    final langKey = _isEnglish ? 'en' : 'bn';
    return _notificationTexts[key]?[langKey] ?? key;
  }

  // নামাজের স্থানীয়কৃত নাম পাওয়া
  String _getLocalizedPrayerName(String banglaPrayerName) {
    if (_isEnglish) {
      switch (banglaPrayerName) {
        case 'ফজর':
          return _getLocalizedText('fajr');
        case 'যোহর':
          return _getLocalizedText('dhuhr');
        case 'আসর':
          return _getLocalizedText('asr');
        case 'মাগরিব':
          return _getLocalizedText('maghrib');
        case 'ইশা':
          return _getLocalizedText('isha');
        default:
          return banglaPrayerName;
      }
    }
    return banglaPrayerName;
  }

  // নোটিফিকেশন চ্যানেল ইনিশিয়ালাইজেশন
  Future<void> initializeNotificationChannel() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: _channelKey,
        channelName: 'Prayer Reminders',
        channelDescription: 'Notifications for prayer times',
        defaultColor: const Color(0xFF1B5E20),
        ledColor: const Color(0xFF1B5E20),
        importance: NotificationImportance.High,
        locked: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        criticalAlerts: true,
      ),
    ], debug: true);
  }

  // সব নোটিফিকেশন শিডিউল করা
  Future<void> scheduleAllPrayerNotifications(
    Map<String, String> prayerTimes,
    Map<String, int> adjustments,
  ) async {
    if (prayerTimes.isEmpty) return;

    // ভাষা ক্যাশে আপডেট করুন
    _updateLanguageCache();

    // প্রথমে পুরানো নোটিফিকেশন ক্যানসেল করুন
    await cancelAllNotifications();

    final adjustedTimes = _getAdjustedPrayerTimes(prayerTimes, adjustments);

    int scheduledCount = 0;

    for (final entry in adjustedTimes.entries) {
      final prayerName = entry.key;
      final time = entry.value;

      if (["ফজর", "যোহর", "আসর", "মাগরিব", "ইশা"].contains(prayerName)) {
        final success = await _schedulePrayerNotification(prayerName, time);
        if (success) scheduledCount++;
      }
    }

    print(
      '✅ $scheduledCount notifications scheduled in ${_isEnglish ? 'English' : 'Bengali'}',
    );

    // শেষ শিডিউল টাইম সেভ করুন
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastScheduleKey, DateTime.now().millisecondsSinceEpoch);
  }

  // নামাজের নোটিফিকেশন শিডিউল করা
  Future<bool> _schedulePrayerNotification(
    String prayerName,
    String time,
  ) async {
    try {
      // পুরানো নোটিফিকেশন ক্যানসেল করুন
      await AwesomeNotifications().cancel(prayerName.hashCode);

      final prayerDate = _parsePrayerTime(time);
      if (prayerDate == null) return false;

      final notificationTime = prayerDate.subtract(const Duration(minutes: 5));
      final now = DateTime.now();

      // আজকের নোটিফিকেশন শিডিউল করুন
      DateTime scheduleTime;
      if (notificationTime.isAfter(now)) {
        scheduleTime = notificationTime;
      } else {
        // আগামীকালের জন্য শিডিউল করুন
        scheduleTime = notificationTime.add(const Duration(days: 1));
      }

      await _createNotification(prayerName, scheduleTime, time);
      return true;
    } catch (e) {
      print("❌ Error scheduling notification for $prayerName: $e");
      return false;
    }
  }

  // নোটিফিকেশন তৈরি করা - Language Support সহ

  Future<void> _createNotification(
    String prayerName,
    DateTime scheduleTime,
    String prayerTime,
  ) async {
    final localizedPrayerName = _getLocalizedPrayerName(prayerName);
    final title = _getLocalizedText('prayer_reminder_title');

    // 🔥 নামাজ ভিত্তিক ফরমেটেড সময়
    final formattedTime = _isEnglish
        ? _formatTimeTo12Hour(prayerTime)
        : _formatTimeForPrayerBangla(
            prayerName,
            prayerTime,
          ); // 🔥 নামাজ পাস করুন

    final body = _getLocalizedText('prayer_reminder_body')
        .replaceAll('{prayer}', localizedPrayerName)
        .replaceAll('{time}', formattedTime);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: prayerName.hashCode,
        channelKey: _channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        criticalAlert: true,
        color: const Color(0xFF1B5E20),
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

    print(
      '📅 Scheduled: $localizedPrayerName at $scheduleTime (${_isEnglish ? 'English' : 'Bengali'})',
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

  // 24-hour to 12-hour format conversion method
  String _formatTimeTo12Hour(String time24Hour) {
    try {
      final parts = time24Hour.split(':');
      if (parts.length != 2) return time24Hour;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String period = hour >= 12 ? 'PM' : 'AM';

      // Convert to 12-hour format
      if (hour > 12) {
        hour = hour - 12;
      } else if (hour == 0) {
        hour = 12;
      }

      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      print('Error formatting time: $e');
      return time24Hour;
    }
  }

  // বাংলা জন্য সময় format (সকাল/বিকাল)
  String _formatTimeTo12HourBangla(String time24Hour) {
    try {
      final parts = time24Hour.split(':');
      if (parts.length != 2) return time24Hour;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String period = hour >= 12 ? 'বিকাল' : 'সকাল';

      // Convert to 12-hour format
      if (hour > 12) {
        hour = hour - 12;
      } else if (hour == 0) {
        hour = 12;
      }

      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      print('Error formatting time: $e');
      return time24Hour;
    }
  }

  // বাংলা নামাজ ভিত্তিক সময় ফরমেট - UPDATED
  String _formatTimeForPrayerBangla(String prayerName, String time24Hour) {
    try {
      final parts = time24Hour.split(':');
      if (parts.length != 2) return time24Hour;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      // নামাজ ভিত্তিক সময়ের অংশ
      String timePeriod = _getPrayerTimePeriod(prayerName, hour);

      // Convert to 12-hour format
      if (hour > 12) {
        hour = hour - 12;
      } else if (hour == 0) {
        hour = 12;
      }

      // 🔥 সময়ের অংশ প্রথমে, তারপর সময়
      return '$timePeriod $hour:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error formatting prayer time: $e');
      return time24Hour;
    }
  }

  // নামাজ ভিত্তিক সময়ের অংশ নির্ধারণ
  String _getPrayerTimePeriod(String prayerName, int hour) {
    switch (prayerName) {
      case 'ফজর':
        return 'ভোর';
      case 'যোহর':
        return 'দুপুর';
      case 'আসর':
        return 'বিকাল';
      case 'মাগরিব':
        return 'সন্ধ্যা';
      case 'ইশা':
        return hour >= 20 ? 'রাত' : 'সন্ধ্যা'; // ৮টার পর রাত
      default:
        return hour >= 12 ? 'বিকাল' : 'সকাল';
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

      // ৩. ভাষা স্ট্যাটাস
      print('🌐 Notification Language: ${_isEnglish ? 'English' : 'Bengali'}');
    } catch (e) {
      print('❌ Notification system health check failed: $e');
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

    final lastScheduleTime = DateTime.fromMillisecondsSinceEpoch(lastSchedule);
    final now = DateTime.now();

    // ২৪ ঘণ্টার বেশি হয়ে গেলে রিশিডিউল করুন
    return now.difference(lastScheduleTime).inHours >= 24;
  }

  // Test notification (ডিবাগিং এর জন্য)
  Future<void> sendTestNotification() async {
    final title = _getLocalizedText('prayer_reminder_title');
    final body = _isEnglish
        ? 'Test notification from Prayer Time App'
        : 'প্রার্থনা সময় অ্যাপ থেকে টেস্ট নোটিফিকেশন';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 9999,
        channelKey: _channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
    print('✅ Test notification sent in ${_isEnglish ? 'English' : 'Bengali'}');
  }

  // ভাষা পরিবর্তনের পর নোটিফিকেশন রিফ্রেশ
  Future<void> refreshNotificationsWithNewLanguage(
    Map<String, String> prayerTimes,
    Map<String, int> adjustments,
  ) async {
    print(
      '🔄 Refreshing notifications with new language: ${_isEnglish ? 'English' : 'Bengali'}',
    );
    await scheduleAllPrayerNotifications(prayerTimes, adjustments);
  }

  // Static methods for boot complete handling
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    print('Action received: ${receivedAction.id}');
    if (receivedAction.actionType == ActionType.SilentBackgroundAction) {
      await _instance._rescheduleAllNotificationsOnBoot();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print('Notification created: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print('Notification displayed: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    print('Notification dismissed: ${receivedAction.id}');
  }
}
