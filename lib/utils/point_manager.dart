// utils/point_manager.dart - TYPE ERROR FIXED VERSION
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PointManager {
  // Existing keys...
  static const String _pendingPointsKey = 'pending_points';
  static const String _totalPointsKey = 'total_points';
  static const String _totalQuizzesKey = 'total_quizzes';
  static const String _totalCorrectKey = 'total_correct';
  static const String _userEmailKey = 'user_email';
  static const String _giftHistoryKey = 'gift_history';
  static const String _dailyQuizHistoryKey = 'daily_quiz_history';
  static const String _userDeviceIdKey = 'user_device_id';

  // 🔥 NEW: Profile related keys
  static const String _userNameKey = 'user_name';
  static const String _userMobileKey = 'user_mobile';
  static const String _profileImageKey = 'profile_image';

  // 🔥 NEW: Advanced Security Keys
  static const String _quizPlayHistoryKey = 'quiz_play_history';
  static const String _suspiciousActivityKey = 'suspicious_activity_log';
  static const String _userBehaviorKey = 'user_behavior_stats';

  // 🔥 NEW: Security Constants
  static const int DAILY_QUIZ_LIMIT = 4; // দিনে সর্বোচ্চ ৪ বার
  static const int QUIZ_COOLDOWN_MINUTES = 15; // ২ ঘন্টা গ্যাপ
  static const int MAX_QUIZ_PER_HOUR = 2; // ঘন্টায় সর্বোচ্চ ২টি কুইজ
  static const int MAX_POINTS_PER_DAY = 1000; // দিনে সর্বোচ্চ ১০০০ পয়েন্ট

  //=========================Testing
  // Temporary debug - PointManager এ যোগ করুন
  static Future<void> debugResetAllQuizzes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_quizPlayHistoryKey);
      print('✅ ALL QUIZZES RESET FOR DEBUGGING');
    } catch (e) {
      print('Error resetting quizzes: $e');
    }
  }

  //=================
  // 🔥 NEW: Save profile data method
  static Future<void> saveProfileData(
    String userName,
    String userMobile,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, userName);
      await prefs.setString(_userMobileKey, userMobile);
      print('Profile data saved: $userName, $userMobile');
    } catch (e) {
      print('Error saving profile data: $e');
      throw e;
    }
  }

  // 🔥 NEW: Save profile image
  static Future<void> saveProfileImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageKey, imagePath);
      print('Profile image saved: $imagePath');
    } catch (e) {
      print('Error saving profile image: $e');
      throw e;
    }
  }

  // 🔥 NEW: Get profile image
  static Future<String?> getProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_profileImageKey);
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  // 🔥 UPDATED: getUserData method with profile data
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'pendingPoints': prefs.getInt(_pendingPointsKey) ?? 0,
      'totalPoints': prefs.getInt(_totalPointsKey) ?? 0,
      'totalQuizzes': prefs.getInt(_totalQuizzesKey) ?? 0,
      'totalCorrectAnswers': prefs.getInt(_totalCorrectKey) ?? 0,
      'userEmail': prefs.getString(_userEmailKey) ?? 'ইসলামিক কুইজ ইউজার',
      'userName': prefs.getString(_userNameKey) ?? 'ইসলামিক কুইজ ইউজার',
      'userMobile': prefs.getString(_userMobileKey) ?? '',
      'profileImage': prefs.getString(_profileImageKey),
      'todayRewards': await getTodayRewards(),
      'deviceId': await getDeviceId(),
    };
  }

  // 🔥 NEW: Reset profile data
  static Future<void> resetProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userNameKey);
      await prefs.remove(_userMobileKey);
      await prefs.remove(_profileImageKey);
      print('Profile data reset successfully');
    } catch (e) {
      print('Error resetting profile data: $e');
      throw e;
    }
  }

  // 🔥 NEW: Complete user data reset
  static Future<void> completeReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Points and stats
      await prefs.setInt(_pendingPointsKey, 0);
      await prefs.setInt(_totalPointsKey, 0);
      await prefs.setInt(_totalQuizzesKey, 0);
      await prefs.setInt(_totalCorrectKey, 0);

      // Profile data
      await prefs.remove(_userNameKey);
      await prefs.remove(_userMobileKey);
      await prefs.remove(_profileImageKey);

      // History
      await prefs.remove(_giftHistoryKey);
      await prefs.remove(_dailyQuizHistoryKey);
      await prefs.remove(_quizPlayHistoryKey);
      await prefs.remove(_suspiciousActivityKey);
      await prefs.remove(_userBehaviorKey);

      print('Complete reset successful');
    } catch (e) {
      print('Error in complete reset: $e');
      throw e;
    }
  }

  // ==================== ADVANCED SECURITY METHODS ====================

  // 🔥 NEW: Advanced Quiz Play History Management
  static Future<Map<String, dynamic>> getQuizPlayHistory(String quizId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      return history[quizId] != null
          ? Map<String, dynamic>.from(history[quizId])
          : {
              'playCount': 0,
              'lastPlayed': null,
              'todayPlayCount': 0,
              'pointsEarned': 0,
              'todayPoints': 0,
              'playSessions': [],
            };
    } catch (e) {
      print('Error getting quiz history: $e');
      return {
        'playCount': 0,
        'lastPlayed': null,
        'todayPlayCount': 0,
        'pointsEarned': 0,
        'todayPoints': 0,
        'playSessions': [],
      };
    }
  }

  // 🔥 NEW: Check if user can play quiz with advanced security
  // PointManager.dart - STRICT TYPE SAFETY এড করুন
  // PointManager.dart - canPlayQuiz মেথডে এই অংশটি আপডেট করুন
  static Future<Map<String, dynamic>> canPlayQuiz(String quizId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final DateTime now = DateTime.now();
      final String today = now.toIso8601String().split('T')[0];

      // Get quiz history
      final Map<String, dynamic> quizHistory = await getQuizPlayHistory(quizId);

      // 🔥 STRICT TYPE CONVERSION - FIXED
      final int todayPlayCount = _safeToInt(quizHistory['todayPlayCount']);
      final int totalPlayCount = _safeToInt(quizHistory['playCount']);
      final int todayPoints = _safeToInt(quizHistory['todayPoints']);
      final String? lastPlayed = quizHistory['lastPlayed']?.toString();

      print('🔍 SECURITY CHECK for $quizId:');
      print('   - Today Play Count: $todayPlayCount');
      print('   - Total Play Count: $totalPlayCount');
      print('   - Today Points: $todayPoints');
      print('   - Last Played: $lastPlayed');

      // Check if last play was today
      bool isToday = false;
      if (lastPlayed != null && lastPlayed.isNotEmpty) {
        try {
          final DateTime lastPlayedTime = DateTime.parse(lastPlayed);
          final String lastPlayedDay = lastPlayedTime.toIso8601String().split(
            'T',
          )[0];
          isToday = lastPlayedDay == today;
        } catch (e) {
          print('⚠️ Error parsing lastPlayed date: $e');
        }
      }

      // 🔒 SECURITY CHECK 1: Daily quiz limit
      if (todayPlayCount >= DAILY_QUIZ_LIMIT) {
        print(
          '🚫 BLOCKED: Daily limit reached - $todayPlayCount/$DAILY_QUIZ_LIMIT',
        );
        return {
          'canPlay': false,
          'reason': 'দৈনিক সীমা শেষ',
          'message':
              'আপনি আজ এই কুইজ ${DAILY_QUIZ_LIMIT} বার খেলেছেন। আগামীকাল আবার চেষ্টা করুন।',
          'nextAvailable': _getNextDayStart(),
          'remainingAttempts': 0,
        };
      }

      // 🔒 SECURITY CHECK 2: Cooldown period
      if (lastPlayed != null && lastPlayed.isNotEmpty) {
        try {
          final DateTime lastPlayedTime = DateTime.parse(lastPlayed);
          final int minutesSinceLastPlay = now
              .difference(lastPlayedTime)
              .inMinutes;

          if (minutesSinceLastPlay < QUIZ_COOLDOWN_MINUTES) {
            final int remainingMinutes =
                QUIZ_COOLDOWN_MINUTES - minutesSinceLastPlay;
            print(
              '🚫 BLOCKED: Cooldown active - $minutesSinceLastPlay minutes passed',
            );
            return {
              'canPlay': false,
              'reason': 'আপনি ইতিমধ্যে এ বিষয়ে কুইজ এর উত্তর দিয়েছেন',
              'message':
                  'একই বিষয়ে আবার কুইজ এর উত্তর দিতে পারবেন\n\n'
                  '⏰ ${remainingMinutes} মিনিট পর\n\n'
                  '💡 রিওয়ার্ড পয়েন্টের জন্য অন্য ক্যাটাগরি পছন্দ করুন',
              'nextAvailable': lastPlayedTime.add(
                Duration(minutes: QUIZ_COOLDOWN_MINUTES),
              ),
              'remainingAttempts': DAILY_QUIZ_LIMIT - todayPlayCount,
            };
          }
        } catch (e) {
          print('⚠️ Error parsing lastPlayed for cooldown: $e');
        }
      }

      // All checks passed
      print('✅ SECURITY PASSED: User can play quiz');
      return {
        'canPlay': true,
        'reason': 'সফল',
        'message': 'কুইজ খেলা যাবে',
        'remainingAttempts': DAILY_QUIZ_LIMIT - todayPlayCount,
        'nextAvailable': null,
      };
    } catch (e) {
      print('❌ SECURITY CHECK ERROR: $e');
      return {
        'canPlay': false,
        'reason': 'সিস্টেম ত্রুটি',
        'message': 'সিস্টেমে সাময়িক ত্রুটি রয়েছে। পরে আবার চেষ্টা করুন।',
        'nextAvailable': null,
        'remainingAttempts': 0,
      };
    }
  }

  // 🔥 NEW: STRICT TYPE CONVERSION METHOD
  static int _strictToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Remove any non-numeric characters and try to parse
      final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned) ?? 0;
    }
    if (value is num) return value.toInt();

    // If it's a bool or other type, return 0
    return 0;
  }

  // 🔥 NEW: Record quiz play with advanced tracking
  // PointManager.dart - recordQuizPlay মেথডে এই অংশটি আপডেট করুন
  static Future<void> recordQuizPlay({
    required String quizId,
    required int pointsEarned,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final DateTime now = DateTime.now();
      final String today = now.toIso8601String().split('T')[0];

      // Get current history
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      final Map<String, dynamic> quizHistory = history[quizId] != null
          ? Map<String, dynamic>.from(history[quizId])
          : {
              'playCount': 0,
              'lastPlayed': null,
              'todayPlayCount': 0,
              'pointsEarned': 0,
              'todayPoints': 0,
              'playSessions': [],
            };

      // Update quiz history
      final List<dynamic> playSessions = List<dynamic>.from(
        quizHistory['playSessions'] ?? [],
      );

      playSessions.add({
        'timestamp': now.toIso8601String(),
        'pointsEarned': pointsEarned,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
      });

      // Keep only last 50 sessions to prevent storage bloat
      if (playSessions.length > 50) {
        playSessions.removeRange(0, playSessions.length - 50);
      }

      // Check if last play was today
      final bool isToday = quizHistory['lastPlayed'] != null
          ? quizHistory['lastPlayed'].toString().contains(today)
          : false;

      // 🔥 FIXED: STRICT TYPE HANDLING
      final int currentPlayCount = _safeToInt(quizHistory['playCount']);
      final int currentTodayPlayCount = _safeToInt(
        quizHistory['todayPlayCount'],
      );
      final int currentPointsEarned = _safeToInt(quizHistory['pointsEarned']);
      final int currentTodayPoints = _safeToInt(quizHistory['todayPoints']);

      // 🔥 IMPORTANT: Only increment play count if points > 0 (not a start record)
      final bool shouldIncrementPlayCount = pointsEarned > 0;

      history[quizId] = {
        'playCount': shouldIncrementPlayCount
            ? currentPlayCount + 1
            : currentPlayCount,
        'lastPlayed': now.toIso8601String(),
        'todayPlayCount': isToday && shouldIncrementPlayCount
            ? currentTodayPlayCount + 1
            : (shouldIncrementPlayCount ? 1 : currentTodayPlayCount),
        'pointsEarned': currentPointsEarned + pointsEarned,
        'todayPoints': isToday
            ? currentTodayPoints + pointsEarned
            : pointsEarned,
        'playSessions': playSessions,
        'lastUpdated': now.toIso8601String(),
      };

      // Save updated history
      await prefs.setString(_quizPlayHistoryKey, jsonEncode(history));

      // Update user behavior stats only if actual play (points > 0)
      if (pointsEarned > 0) {
        await _updateUserBehaviorStats(
          pointsEarned,
          correctAnswers,
          totalQuestions,
        );
      }

      print(
        '✅ Quiz play recorded: $quizId, Points: $pointsEarned, PlayCountIncremented: $shouldIncrementPlayCount',
      );
    } catch (e) {
      print('Error recording quiz play: $e');
      throw e;
    }
  }

  // 🔥 NEW: Get quizzes played in last hour
  static Future<int> _getQuizzesInLastHour() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      final DateTime oneHourAgo = DateTime.now().subtract(Duration(hours: 1));
      int count = 0;

      for (final quizId in history.keys) {
        final Map<String, dynamic> quizData = Map<String, dynamic>.from(
          history[quizId],
        );
        final List<dynamic> sessions = quizData['playSessions'] ?? [];

        for (final session in sessions) {
          final Map<String, dynamic> sessionData = Map<String, dynamic>.from(
            session,
          );
          final DateTime sessionTime = DateTime.parse(sessionData['timestamp']);
          if (sessionTime.isAfter(oneHourAgo)) {
            count++;
          }
        }
      }

      return count;
    } catch (e) {
      print('Error getting quizzes in last hour: $e');
      return 0;
    }
  }

  // PointManager.dart - ডিবাগ মেথড
  static Future<void> debugSecurityStatus(String quizId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      print('=== SECURITY DEBUG ===');
      print('Quiz ID: $quizId');

      if (history.containsKey(quizId)) {
        final quizData = history[quizId];
        print(
          'Play Count: ${quizData['playCount']} (Type: ${quizData['playCount']?.runtimeType})',
        );
        print(
          'Today Play Count: ${quizData['todayPlayCount']} (Type: ${quizData['todayPlayCount']?.runtimeType})',
        );
        print('Last Played: ${quizData['lastPlayed']}');
        print('Today Points: ${quizData['todayPoints']}');

        // Test security check
        final securityResult = await canPlayQuiz(quizId);
        print(
          'Security Check: ${securityResult['canPlay']} - ${securityResult['reason']}',
        );
      } else {
        print('No history found for this quiz');
      }

      print('====================');
    } catch (e) {
      print('Security debug error: $e');
    }
  }

  // 🔥 NEW: Advanced suspicious activity detection
  static Future<bool> _detectSuspiciousActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final DateTime now = DateTime.now();
      final DateTime twentyFourHoursAgo = now.subtract(Duration(hours: 24));

      // Get play history
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      int totalQuizzes24h = 0;
      int totalPoints24h = 0;
      final Map<String, int> quizPlayCount = {};

      for (final quizId in history.keys) {
        final Map<String, dynamic> quizData = Map<String, dynamic>.from(
          history[quizId],
        );
        final List<dynamic> sessions = quizData['playSessions'] ?? [];

        for (final session in sessions) {
          final Map<String, dynamic> sessionData = Map<String, dynamic>.from(
            session,
          );
          final DateTime sessionTime = DateTime.parse(sessionData['timestamp']);

          if (sessionTime.isAfter(twentyFourHoursAgo)) {
            totalQuizzes24h++;
            // 🔧 FIX: Convert num to int safely
            totalPoints24h += _safeToInt(sessionData['pointsEarned']);
            quizPlayCount[quizId] = (quizPlayCount[quizId] ?? 0) + 1;
          }
        }
      }

      // 🔒 Detection Rule 1: Too many quizzes in 24 hours
      if (totalQuizzes24h > 20) {
        await _logSuspiciousActivity(
          'Too many quizzes in 24h: $totalQuizzes24h',
        );
        return true;
      }

      // 🔒 Detection Rule 2: Too many points in 24 hours
      if (totalPoints24h > 2000) {
        await _logSuspiciousActivity('Too many points in 24h: $totalPoints24h');
        return true;
      }

      // 🔒 Detection Rule 3: Same quiz played too many times
      for (final entry in quizPlayCount.entries) {
        if (entry.value > 8) {
          // Same quiz more than 8 times in 24h
          await _logSuspiciousActivity(
            'Quiz ${entry.key} played too many times: ${entry.value}',
          );
          return true;
        }
      }

      // 🔒 Detection Rule 4: Unusually fast quiz completion
      final bool hasRapidCompletions = await _detectRapidCompletions();
      if (hasRapidCompletions) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error in suspicious activity detection: $e');
      return false;
    }
  }

  // 🔥 NEW: Detect rapid quiz completions (cheating detection)
  static Future<bool> _detectRapidCompletions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      final DateTime oneHourAgo = DateTime.now().subtract(Duration(hours: 1));
      int rapidCompletions = 0;

      for (final quizId in history.keys) {
        final Map<String, dynamic> quizData = Map<String, dynamic>.from(
          history[quizId],
        );
        final List<dynamic> sessions = quizData['playSessions'] ?? [];

        // Sort sessions by timestamp
        sessions.sort((a, b) {
          final aTime = DateTime.parse(a['timestamp']);
          final bTime = DateTime.parse(b['timestamp']);
          return aTime.compareTo(bTime);
        });

        // Check for rapid consecutive plays
        for (int i = 1; i < sessions.length; i++) {
          final DateTime prevTime = DateTime.parse(
            sessions[i - 1]['timestamp'],
          );
          final DateTime currentTime = DateTime.parse(sessions[i]['timestamp']);
          final int secondsBetween = currentTime.difference(prevTime).inSeconds;

          // If quizzes completed in less than 30 seconds, suspicious
          if (secondsBetween < 30 && currentTime.isAfter(oneHourAgo)) {
            rapidCompletions++;
          }
        }
      }

      if (rapidCompletions >= 3) {
        await _logSuspiciousActivity(
          'Multiple rapid completions: $rapidCompletions',
        );
        return true;
      }

      return false;
    } catch (e) {
      print('Error detecting rapid completions: $e');
      return false;
    }
  }

  // 🔥 NEW: Log suspicious activity
  static Future<void> _logSuspiciousActivity(String description) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> logs =
          prefs.getStringList(_suspiciousActivityKey) ?? [];

      logs.add('${DateTime.now().toIso8601String()}: $description');

      // Keep only last 100 logs
      if (logs.length > 100) {
        logs.removeRange(0, logs.length - 100);
      }

      await prefs.setStringList(_suspiciousActivityKey, logs);
      print('🚨 Suspicious activity logged: $description');
    } catch (e) {
      print('Error logging suspicious activity: $e');
    }
  }

  // 🔥 NEW: Update user behavior statistics
  static Future<void> _updateUserBehaviorStats(
    int pointsEarned,
    int correctAnswers,
    int totalQuestions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String today = DateTime.now().toIso8601String().split('T')[0];

      final String behaviorJson = prefs.getString(_userBehaviorKey) ?? '{}';
      final Map<String, dynamic> behavior = jsonDecode(behaviorJson);

      final Map<String, dynamic> todayStats = behavior[today] != null
          ? Map<String, dynamic>.from(behavior[today])
          : {
              'totalQuizzes': 0,
              'totalPoints': 0,
              'totalCorrect': 0,
              'totalQuestions': 0,
              'accuracy': 0.0,
              'averagePoints': 0.0,
            };

      // 🔧 FIX: Convert num to int safely before arithmetic operations
      final int currentTotalQuizzes = _safeToInt(todayStats['totalQuizzes']);
      final int currentTotalPoints = _safeToInt(todayStats['totalPoints']);
      final int currentTotalCorrect = _safeToInt(todayStats['totalCorrect']);
      final int currentTotalQuestions = _safeToInt(
        todayStats['totalQuestions'],
      );

      todayStats['totalQuizzes'] = currentTotalQuizzes + 1;
      todayStats['totalPoints'] = currentTotalPoints + pointsEarned;
      todayStats['totalCorrect'] = currentTotalCorrect + correctAnswers;
      todayStats['totalQuestions'] = currentTotalQuestions + totalQuestions;

      // Calculate accuracy
      final int totalCorrect = _safeToInt(todayStats['totalCorrect']);
      final int totalQuestionsCount = _safeToInt(todayStats['totalQuestions']);
      todayStats['accuracy'] = totalQuestionsCount > 0
          ? (totalCorrect / totalQuestionsCount) * 100
          : 0.0;

      // Calculate average points
      final int totalPoints = _safeToInt(todayStats['totalPoints']);
      final int totalQuizzes = _safeToInt(todayStats['totalQuizzes']);
      todayStats['averagePoints'] = totalQuizzes > 0
          ? totalPoints / totalQuizzes
          : 0.0;

      behavior[today] = todayStats;

      // Clean up old data (keep only last 30 days)
      final List<String> dates = behavior.keys.toList();
      for (final date in dates) {
        final DateTime dateTime = DateTime.parse(date);
        if (DateTime.now().difference(dateTime).inDays > 30) {
          behavior.remove(date);
        }
      }

      await prefs.setString(_userBehaviorKey, jsonEncode(behavior));
    } catch (e) {
      print('Error updating behavior stats: $e');
    }
  }

  // 🔥 NEW: Get next day start time
  static DateTime _getNextDayStart() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  // 🔥 NEW: Reset daily limits (for testing or admin purposes)
  static Future<void> resetDailyLimits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      for (final quizId in history.keys) {
        final Map<String, dynamic> quizData = Map<String, dynamic>.from(
          history[quizId],
        );
        quizData['todayPlayCount'] = 0;
        quizData['todayPoints'] = 0;
        history[quizId] = quizData;
      }

      await prefs.setString(_quizPlayHistoryKey, jsonEncode(history));
      print('✅ Daily limits reset successfully');
    } catch (e) {
      print('Error resetting daily limits: $e');
    }
  }

  // 🔥 NEW: Get user's quiz statistics
  static Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      int totalQuizzes = 0;
      int totalPoints = 0;
      int uniqueQuizzes = history.keys.length;
      String mostPlayedQuiz = '';
      int maxPlayCount = 0;

      for (final entry in history.entries) {
        final Map<String, dynamic> quizData = Map<String, dynamic>.from(
          entry.value,
        );
        // 🔧 FIX: Convert num to int safely
        totalQuizzes += _safeToInt(quizData['playCount']);
        totalPoints += _safeToInt(quizData['pointsEarned']);

        final int playCount = _safeToInt(quizData['playCount']);
        if (playCount > maxPlayCount) {
          maxPlayCount = playCount;
          mostPlayedQuiz = entry.key;
        }
      }

      return {
        'totalQuizzes': totalQuizzes,
        'totalPoints': totalPoints,
        'uniqueQuizzes': uniqueQuizzes,
        'mostPlayedQuiz': mostPlayedQuiz,
        'averagePointsPerQuiz': totalQuizzes > 0
            ? totalPoints / totalQuizzes
            : 0,
      };
    } catch (e) {
      print('Error getting quiz statistics: $e');
      return {
        'totalQuizzes': 0,
        'totalPoints': 0,
        'uniqueQuizzes': 0,
        'mostPlayedQuiz': '',
        'averagePointsPerQuiz': 0,
      };
    }
  }

  // ==================== TYPE SAFETY HELPER METHODS ====================

  // 🔧 NEW: Safe conversion from dynamic/number to int
  static int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  // 🔧 NEW: Safe conversion from dynamic/number to double
  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  // ==================== EXISTING METHODS ====================

  // 🔥 কুইজ কমপ্লিশন মার্ক করুন
  static Future<void> markQuizPlayed(String quizId, int pointsEarned) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().split('T')[0];

    final dailyHistory = prefs.getString(_dailyQuizHistoryKey) ?? '{}';
    final Map<String, dynamic> historyMap = jsonDecode(dailyHistory);

    final String todayKey = '$today-$quizId';
    historyMap[todayKey] = {
      'playedAt': DateTime.now().toIso8601String(),
      'pointsEarned': pointsEarned,
      'quizId': quizId,
    };

    await prefs.setString(_dailyQuizHistoryKey, jsonEncode(historyMap));

    // পয়েন্ট যোগ করুন
    await addPoints(pointsEarned);
    await updateQuizStats(1); // 1 quiz completed
  }

  // পয়েন্ট যোগ করার মেথড
  static Future<void> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPending = prefs.getInt(_pendingPointsKey) ?? 0;
    await prefs.setInt(_pendingPointsKey, currentPending + points);
    final currentTotal = prefs.getInt(_totalPointsKey) ?? 0;
    await prefs.setInt(_totalPointsKey, currentTotal + points);
  }

  // 🔥 ইউনিক ডিভাইস ID জেনারেট করুন (Anti-spam)
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_userDeviceIdKey);

    if (deviceId == null) {
      deviceId =
          'device_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
      await prefs.setString(_userDeviceIdKey, deviceId);
    }

    return deviceId;
  }

  // 🔥 র‍্যান্ডম স্ট্রিং জেনারেটর
  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final result = StringBuffer();

    for (int i = 0; i < length; i++) {
      result.write(chars[(random + i) % chars.length]);
    }

    return result.toString();
  }

  // 🔥 স্প্যাম ডিটেকশন (একই ডিভাইস থেকে অনেক গিফ্ট)
  static Future<bool> isSuspiciousActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getGiftHistory();
    final deviceId = await getDeviceId();

    // গত 24 ঘন্টার গিফ্ট কাউন্ট
    final now = DateTime.now();
    final recentGifts = history.where((request) {
      try {
        final requestedAt = DateTime.parse(request['requestedAt']);
        return now.difference(requestedAt).inHours <= 24;
      } catch (e) {
        return false;
      }
    }).length;

    // 24 ঘন্টায় 3 টার বেশি গিফ্ট সাসপিশিয়াস
    if (recentGifts > 3) {
      return true;
    }

    return false;
  }

  // পয়েন্ট কাটার মেথড (গিফ্টের জন্য)
  static Future<void> deductPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPending = prefs.getInt(_pendingPointsKey) ?? 0;
    if (currentPending >= points) {
      await prefs.setInt(_pendingPointsKey, currentPending - points);
    } else {
      throw Exception('পর্যাপ্ত পয়েন্ট নেই');
    }
  }

  static Future<void> updateQuizStats(int correctAnswers) async {
    final prefs = await SharedPreferences.getInstance();
    final currentQuizzes = prefs.getInt(_totalQuizzesKey) ?? 0;
    await prefs.setInt(_totalQuizzesKey, currentQuizzes + 1);
    final currentCorrect = prefs.getInt(_totalCorrectKey) ?? 0;
    await prefs.setInt(_totalCorrectKey, currentCorrect + correctAnswers);
  }

  //--------------------------------------------------------
  // 🔥 গিফ্ট রিকোয়েস্ট সেভ করার মেথড - COMPLETELY FIXED
  static Future<void> saveGiftRequest(
    String mobileNumber,
    String userEmail,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_giftHistoryKey) ?? [];

    final newRequest = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'mobileNumber': mobileNumber,
      'userEmail': userEmail,
      'pointsUsed': 200, // 200 পয়েন্ট
      'requestedAt': DateTime.now().toIso8601String(),
      'status': 'pending',
      'processedAt': null,
    };

    // JSON encode ব্যবহার করুন
    history.add(jsonEncode(newRequest));
    await prefs.setStringList(_giftHistoryKey, history);
  }

  // 🔥 গিফ্ট হিস্ট্রি পাওয়ার মেথড - COMPLETELY FIXED
  static Future<List<Map<String, dynamic>>> getGiftHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings =
        prefs.getStringList(_giftHistoryKey) ?? [];
    final List<Map<String, dynamic>> history = [];

    for (String item in historyStrings) {
      try {
        final Map<String, dynamic> request = _safeParseGiftRequest(item);
        if (request.isNotEmpty) {
          history.add(request);
        }
      } catch (e) {
        print('গিফ্ট রিকোয়েস্ট পার্স করতে ত্রুটি: $e - Item: $item');
      }
    }

    // নতুন থেকে পুরানো order এ সাজানো
    history.sort((a, b) {
      final aId = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
      final bId = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
      return bId.compareTo(aId);
    });

    return history;
  }

  // 🔥 সেফ পার্সিং মেথড - COMPLETELY FIXED
  static Map<String, dynamic> _safeParseGiftRequest(String item) {
    try {
      // প্রথমে JSON decode চেষ্টা করুন
      final decoded = jsonDecode(item);
      if (decoded is Map<String, dynamic>) {
        return _ensureDataTypes(decoded);
      }
    } catch (e) {
      // JSON fail হলে পুরানো ফরম্যাট চেষ্টা করুন
      print('JSON decode failed, trying legacy format: $e');
    }

    // পুরানো ফরম্যাট পার্সিং
    try {
      if (item.startsWith('{') && item.endsWith('}')) {
        final cleaned = item.replaceAll('{', '').replaceAll('}', '');
        final pairs = cleaned.split(', ');
        final Map<String, dynamic> result = {};

        for (String pair in pairs) {
          final keyValue = pair.split(': ');
          if (keyValue.length == 2) {
            final key = keyValue[0].trim();
            final value = keyValue[1].trim();

            // টাইপ সেফলি কনভার্ট করুন
            if (value == 'null') {
              result[key] = null;
            } else if (int.tryParse(value) != null) {
              result[key] = int.parse(value);
            } else {
              result[key] = value;
            }
          }
        }
        return _ensureDataTypes(result);
      }
    } catch (e) {
      print('Legacy format parse failed: $e');
    }

    return {};
  }

  // 🔥 ডাটা টাইপ নিশ্চিত করার মেথড
  static Map<String, dynamic> _ensureDataTypes(Map<String, dynamic> data) {
    return {
      'id': data['id']?.toString() ?? '',
      'mobileNumber': data['mobileNumber']?.toString() ?? '',
      'userEmail': data['userEmail']?.toString() ?? '',
      'pointsUsed': _safeToInt(data['pointsUsed']),
      'requestedAt': data['requestedAt']?.toString() ?? '',
      'status': data['status']?.toString() ?? 'pending',
      'processedAt': data['processedAt']?.toString(),
    };
  }

  // 🔥 সেফলি int এ কনভার্ট করার হেল্পার (for gift requests)
  static int _safeToIntForGift(dynamic value) {
    if (value == null) return 200;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 200;
    return 200;
  }

  // 🔥 গিফ্ট রিকোয়েস্ট আপডেট করার মেথড - FIXED
  static Future<void> updateGiftStatus(
    String requestId,
    String newStatus,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings =
        prefs.getStringList(_giftHistoryKey) ?? [];
    final List<String> updatedHistory = [];

    for (String item in historyStrings) {
      try {
        Map<String, dynamic> request = _safeParseGiftRequest(item);

        if (request['id']?.toString() == requestId) {
          request['status'] = newStatus;
          request['processedAt'] = DateTime.now().toIso8601String();
        }

        updatedHistory.add(jsonEncode(request));
      } catch (e) {
        updatedHistory.add(item);
      }
    }

    await prefs.setStringList(_giftHistoryKey, updatedHistory);
  }

  // 🔥 পেন্ডিং গিফ্ট রিকোয়েস্ট কাউন্ট
  static Future<int> getPendingGiftCount() async {
    final history = await getGiftHistory();
    return history.where((request) => request['status'] == 'pending').length;
  }

  // 🔥 সব ডাটা রিসেট (যদি প্রয়োজন হয়)
  static Future<void> clearGiftHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_giftHistoryKey);
  }

  // 🔥 ডেবাগিং: সব গিফ্ট রিকোয়েস্ট প্রিন্ট করুন
  static Future<void> debugPrintAllRequests() async {
    final history = await getGiftHistory();
    print('=== গিফ্ট রিকোয়েস্ট ডিবাগ ===');
    for (int i = 0; i < history.length; i++) {
      print('Request $i: ${history[i]}');
    }
    print('=============================');
  }

  static Future<void> updateTodayRewards(int todayRewards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = 'today_rewards_${now.year}-${now.month}-${now.day}';

      await prefs.setInt(todayKey, todayRewards);
      print('আজকের রিওয়ার্ড আপডেট হয়েছে: $todayRewards');
    } catch (e) {
      print('আজকের রিওয়ার্ড আপডেট করতে ত্রুটি: $e');
      throw e;
    }
  }

  static Future<int> getTodayRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = 'today_rewards_${now.year}-${now.month}-${now.day}';

      return prefs.getInt(todayKey) ?? 0;
    } catch (e) {
      print('আজকের রিওয়ার্ড পড়তে ত্রুটি: $e');
      return 0;
    }
  }

  // 🔥 NEW: Get user profile completeness percentage
  static Future<int> getProfileCompleteness() async {
    final userData = await getUserData();
    int completeness = 0;

    if ((userData['userName'] ?? '').isNotEmpty &&
        userData['userName'] != 'ইসলামিক কুইজ ইউজার') {
      completeness += 40;
    }
    if ((userData['userMobile'] ?? '').isNotEmpty) {
      completeness += 30;
    }
    if ((userData['profileImage'] ?? '').isNotEmpty) {
      completeness += 30;
    }

    return completeness;
  }

  // 🔥 NEW: Update the existing canPlayQuizToday method to use new system
  static Future<bool> canPlayQuizToday(String quizId) async {
    final result = await canPlayQuiz(quizId);
    return result['canPlay'] ?? false;
  }
}
