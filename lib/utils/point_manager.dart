// utils/point_manager.dart - COMPLETE UPDATED VERSION
// utils/point_manager.dart - FIXED DAILY LIMIT
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PointManager {
  // ==================== STORAGE KEYS ====================
  static const String _pendingPointsKey = 'pending_points';
  static const String _totalPointsKey = 'total_points';
  static const String _totalQuizzesKey = 'total_quizzes';
  static const String _totalCorrectKey = 'total_correct';
  static const String _userEmailKey = 'user_email';
  static const String _giftHistoryKey = 'gift_history';
  static const String _userDeviceIdKey = 'user_device_id';
  static const String _userNameKey = 'user_name';
  static const String _userMobileKey = 'user_mobile';
  static const String _profileImageKey = 'profile_image';
  static const String _quizPlayHistoryKey = 'quiz_play_history';

  // ==================== CONSTANTS ====================
  static const int QUIZ_COOLDOWN_MINUTES = 15;
  static const int MAX_POINTS_PER_DAY = 1000; // 🔥 দৈনিক সর্বোচ্চ ১০০০ পয়েন্ট

  // ==================== CORE POINTS MANAGEMENT ====================

  /// পয়েন্ট যোগ করার মেথড
  static Future<void> addPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPending = prefs.getInt(_pendingPointsKey) ?? 0;
      final currentTotal = prefs.getInt(_totalPointsKey) ?? 0;

      await prefs.setInt(_pendingPointsKey, currentPending + points);
      await prefs.setInt(_totalPointsKey, currentTotal + points);

      print("✅ $points points added to user account");
      print("📊 Total Points Now: ${currentTotal + points}");
    } catch (e) {
      print("❌ Error adding points: $e");
      throw e;
    }
  }

  // ==================== QUIZ SECURITY & LIMITS ====================

  /// কুইজ খেলা যাবে কিনা চেক করার মেথড
  static Future<Map<String, dynamic>> canPlayQuiz(String quizId) async {
    try {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> quizHistory = await getQuizPlayHistory(quizId);

      final int todayPoints = _safeToInt(quizHistory['todayPoints']);
      final String? lastPlayed = quizHistory['lastPlayed']?.toString();
      final int totalPointsToday = await getTotalPointsToday();

      print('🔍 SECURITY CHECK for $quizId:');
      print('   - This Quiz Points Today: $todayPoints');
      print(
        '   - Total Quiz Points Today: $totalPointsToday/$MAX_POINTS_PER_DAY',
      );
      print('   - Last Played: $lastPlayed');

      // 🔒 SECURITY CHECK 1: Daily points limit - শুধুমাত্র আজকের কুইজ পয়েন্ট
      if (totalPointsToday >= MAX_POINTS_PER_DAY) {
        print(
          '🚫 BLOCKED: Daily quiz points limit reached - $totalPointsToday/$MAX_POINTS_PER_DAY',
        );
        return {
          'canPlay': false,
          'reason': 'দৈনিক পয়েন্ট সীমা',
          'message':
              'আপনি আজ সকল কুইজ থেকে সর্বোচ্চ $MAX_POINTS_PER_DAY পয়েন্ট অর্জন করেছেন। আগামীকাল আবার চেষ্টা করুন।',
          'nextAvailable': _getNextDayStart(),
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
                  'একই বিষয়ে আবার কুইজ এর উত্তর দিতে পারবেন\n\n⏰ ${remainingMinutes} মিনিট পর',
              'nextAvailable': lastPlayedTime.add(
                Duration(minutes: QUIZ_COOLDOWN_MINUTES),
              ),
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
        'remainingPoints': MAX_POINTS_PER_DAY - totalPointsToday,
        'nextAvailable': null,
      };
    } catch (e) {
      print('❌ SECURITY CHECK ERROR: $e');
      return {
        'canPlay': false,
        'reason': 'সিস্টেম ত্রুটি',
        'message': 'সিস্টেমে সাময়িক ত্রুটি রয়েছে। পরে আবার চেষ্টা করুন।',
        'nextAvailable': null,
      };
    }
  }

  /// আজকের মোট পয়েন্ট পাওয়ার মেথড (শুধুমাত্র কুইজ থেকে অর্জিত)
  static Future<int> getTotalPointsToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      final DateTime now = DateTime.now();
      final DateTime todayStart = DateTime(now.year, now.month, now.day);
      final DateTime tomorrowStart = todayStart.add(Duration(days: 1));

      int totalPointsToday = 0;

      for (final quizId in history.keys) {
        final Map<String, dynamic> quizData = Map<String, dynamic>.from(
          history[quizId],
        );
        final String? lastPlayed = quizData['lastPlayed']?.toString();

        if (lastPlayed != null && lastPlayed.isNotEmpty) {
          try {
            final DateTime lastPlayedTime = DateTime.parse(lastPlayed);
            final bool isToday =
                lastPlayedTime.isAfter(todayStart) &&
                lastPlayedTime.isBefore(tomorrowStart);
            final int todayPoints = _safeToInt(quizData['todayPoints']);

            if (isToday) {
              totalPointsToday += todayPoints;
              print('   - ✅ $quizId: $todayPoints points (Last: $lastPlayed)');
            }
          } catch (e) {
            print('⚠️ Date parsing error for $quizId: $e');
          }
        }
      }

      print(
        '💰 Total Quiz Points Today: $totalPointsToday/$MAX_POINTS_PER_DAY',
      );
      return totalPointsToday;
    } catch (e) {
      print('❌ Error getting total points today: $e');
      return 0;
    }
  }

  // ==================== QUIZ PLAY RECORDING ====================

  /// কুইজ খেলার রেকর্ড সেভ করার মেথড
  /// কুইজ খেলার রেকর্ড সেভ করার মেথড
  static Future<void> recordQuizPlay({
    required String quizId,
    required int pointsEarned,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final DateTime now = DateTime.now();
      final DateTime todayStart = DateTime(now.year, now.month, now.day);
      final DateTime tomorrowStart = todayStart.add(Duration(days: 1));

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

      // Check if last play was today
      final String? lastPlayed = quizHistory['lastPlayed']?.toString();
      bool isToday = false;

      if (lastPlayed != null && lastPlayed.isNotEmpty) {
        try {
          final DateTime lastPlayedTime = DateTime.parse(lastPlayed);
          isToday =
              lastPlayedTime.isAfter(todayStart) &&
              lastPlayedTime.isBefore(tomorrowStart);
        } catch (e) {
          print('⚠️ Error parsing lastPlayed date: $e');
        }
      }

      // 🔥 CRITICAL FIX: Check daily limit BEFORE adding points
      final int totalPointsToday = await getTotalPointsToday();

      // যদি আজকের পয়েন্ট লিমিট অতিক্রম করে, তাহলে পয়েন্ট যোগ করবে না
      if (totalPointsToday >= MAX_POINTS_PER_DAY) {
        print(
          '🚫 DAILY LIMIT REACHED: Not adding points. Today: $totalPointsToday, Limit: $MAX_POINTS_PER_DAY',
        );

        // শুধুমাত্র রেকর্ড আপডেট করবে, কিন্তু পয়েন্ট যোগ করবে না
        history[quizId] = {
          'playCount': _safeToInt(quizHistory['playCount']) + 1,
          'lastPlayed': now.toIso8601String(),
          'todayPlayCount': isToday
              ? _safeToInt(quizHistory['todayPlayCount']) + 1
              : 1,
          'pointsEarned': _safeToInt(quizHistory['pointsEarned']),
          // 🔥 পয়েন্ট যোগ করবে না
          'todayPoints': _safeToInt(quizHistory['todayPoints']),
          // 🔥 আজকের পয়েন্টও পরিবর্তন করবে না
          'playSessions': [
            ...(quizHistory['playSessions'] ?? []),
            {
              'timestamp': now.toIso8601String(),
              'pointsEarned': 0, // 🔥 0 পয়েন্ট রেকর্ড করবে
              'correctAnswers': correctAnswers,
              'totalQuestions': totalQuestions,
            },
          ],
        };

        await prefs.setString(_quizPlayHistoryKey, jsonEncode(history));
        print('📝 Quiz recorded but NO points added (Daily limit reached)');
        return;
      }

      // Calculate new points (শুধুমাত্র যদি লিমিটের মধ্যে থাকে)
      int currentTodayPoints = _safeToInt(quizHistory['todayPoints']);
      int newTodayPoints = isToday
          ? currentTodayPoints + pointsEarned
          : pointsEarned;
      int newTodayPlayCount = isToday
          ? _safeToInt(quizHistory['todayPlayCount']) + 1
          : 1;

      // 🔥 FINAL CHECK: Ensure we don't exceed daily limit
      if (totalPointsToday + pointsEarned > MAX_POINTS_PER_DAY) {
        final int allowedPoints = MAX_POINTS_PER_DAY - totalPointsToday;
        print(
          '🎯 Capping points: $pointsEarned → $allowedPoints (to stay within daily limit)',
        );
        pointsEarned = allowedPoints;
        newTodayPoints = isToday
            ? currentTodayPoints + allowedPoints
            : allowedPoints;
      }

      // Update history
      history[quizId] = {
        'playCount': _safeToInt(quizHistory['playCount']) + 1,
        'lastPlayed': now.toIso8601String(),
        'todayPlayCount': newTodayPlayCount,
        'pointsEarned': _safeToInt(quizHistory['pointsEarned']) + pointsEarned,
        'todayPoints': newTodayPoints,
        'playSessions': [
          ...(quizHistory['playSessions'] ?? []),
          {
            'timestamp': now.toIso8601String(),
            'pointsEarned': pointsEarned,
            'correctAnswers': correctAnswers,
            'totalQuestions': totalQuestions,
          },
        ],
      };

      await prefs.setString(_quizPlayHistoryKey, jsonEncode(history));

      // 🔥 ACTUAL POINTS ADDITION (শুধুমাত্র যদি লিমিটের মধ্যে থাকে)
      if (pointsEarned > 0) {
        await addPoints(pointsEarned);
        print('✅ Quiz play recorded: $quizId, Points: $pointsEarned');
        print('📊 Today Points for $quizId: $newTodayPoints');
      } else {
        print('📝 Quiz recorded but NO points added (Daily limit reached)');
      }
    } catch (e) {
      print('❌ Error recording quiz play: $e');
      throw e;
    }
  }

  // ==================== USER DATA MANAGEMENT ====================

  /// ইউজার ডাটা পাওয়ার মেথড
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final int totalPoints = prefs.getInt(_totalPointsKey) ?? 0;
    final int totalPointsToday = await getTotalPointsToday();

    return {
      'pendingPoints': prefs.getInt(_pendingPointsKey) ?? 0,
      'totalPoints': totalPoints,
      'totalQuizzes': prefs.getInt(_totalQuizzesKey) ?? 0,
      'totalCorrectAnswers': prefs.getInt(_totalCorrectKey) ?? 0,
      'userEmail': prefs.getString(_userEmailKey) ?? 'ইসলামিক কুইজ ইউজার',
      'userName': prefs.getString(_userNameKey) ?? 'ইসলামিক কুইজ ইউজার',
      'userMobile': prefs.getString(_userMobileKey) ?? '',
      'profileImage': prefs.getString(_profileImageKey),
      'todayRewards': await getTodayRewards(),
      'deviceId': await getDeviceId(),
      'totalPointsToday': totalPointsToday,
      'remainingPointsToday': MAX_POINTS_PER_DAY - totalPointsToday,
      // 🔥 নতুন যোগ করা
    };
  }

  // ==================== DEBUG & MAINTENANCE ====================

  /// ডিবাগ: আজকের পয়েন্ট স্ট্যাটাস দেখার মেথড
  static Future<void> debugTodayPointsStatus() async {
    try {
      final int totalPointsToday = await getTotalPointsToday();
      final int maxPointsPerDay = MAX_POINTS_PER_DAY;

      print('=== TODAY POINTS DEBUG ===');
      print('📊 Today\'s Quiz Points: $totalPointsToday');
      print('🎯 Daily Limit: $maxPointsPerDay');
      print('📈 Remaining Points: ${maxPointsPerDay - totalPointsToday}');
      print('✅ Can Play More: ${totalPointsToday < maxPointsPerDay}');
      print('==========================');
    } catch (e) {
      print('❌ Error in debugTodayPointsStatus: $e');
    }
  }

  /// ডিবাগ: সব কুইজের আজকের পয়েন্ট দেখার মেথড
  static Future<void> debugAllQuizPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString(_quizPlayHistoryKey) ?? '{}';
      final Map<String, dynamic> history = jsonDecode(historyJson);

      final DateTime now = DateTime.now();
      final DateTime todayStart = DateTime(now.year, now.month, now.day);

      print('=== ALL QUIZ POINTS DEBUG ===');

      int totalToday = 0;
      for (final quizId in history.keys) {
        final Map<String, dynamic> quizData = Map<String, dynamic>.from(
          history[quizId],
        );
        final String? lastPlayed = quizData['lastPlayed']?.toString();
        final int todayPoints = _safeToInt(quizData['todayPoints']);

        bool isToday = false;
        if (lastPlayed != null && lastPlayed.isNotEmpty) {
          try {
            final DateTime lastPlayedTime = DateTime.parse(lastPlayed);
            isToday = lastPlayedTime.isAfter(todayStart);
          } catch (e) {
            print('⚠️ Error parsing date for $quizId: $e');
          }
        }

        print('📊 $quizId:');
        print('   - Today Points: $todayPoints');
        print('   - Last Played: $lastPlayed');
        print('   - Is Today: $isToday');

        if (isToday) {
          totalToday += todayPoints;
        }
      }

      print('💰 TOTAL TODAY: $totalToday/$MAX_POINTS_PER_DAY');
      print('============================');
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }

  // ==================== CORE POINTS MANAGEMENT ====================

  /// পয়েন্ট কাটার মেথড (গিফ্টের জন্য)
  static Future<void> deductPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPending = prefs.getInt(_pendingPointsKey) ?? 0;

      if (currentPending >= points) {
        await prefs.setInt(_pendingPointsKey, currentPending - points);
      } else {
        throw Exception('পর্যাপ্ত পয়েন্ট নেই');
      }
    } catch (e) {
      print("❌ Error deducting points: $e");
      throw e;
    }
  }

  // ==================== TODAY REWARDS MANAGEMENT ====================

  /// আজকের রিওয়ার্ড আপডেট করার মেথড
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

  /// আজকের রিওয়ার্ড পাওয়ার মেথড
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

  // ==================== QUIZ SECURITY & LIMITS ====================

  /// কুইজ খেলা যাবে কিনা চেক করার মেথড

  /// আজকের মোট পয়েন্ট পাওয়ার মেথড

  // ==================== QUIZ PLAY RECORDING ====================

  /// কুইজ হিস্ট্রি পাওয়ার মেথড
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

  // ==================== USER DATA MANAGEMENT ====================

  /// ইউজার ডাটা পাওয়ার মেথড

  /// কুইজ স্ট্যাটস আপডেট করার মেথড
  static Future<void> updateQuizStats(int correctAnswers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentQuizzes = prefs.getInt(_totalQuizzesKey) ?? 0;
      await prefs.setInt(_totalQuizzesKey, currentQuizzes + 1);

      final currentCorrect = prefs.getInt(_totalCorrectKey) ?? 0;
      await prefs.setInt(_totalCorrectKey, currentCorrect + correctAnswers);

      print("✅ Quiz stats updated: $correctAnswers correct answers");
    } catch (e) {
      print("❌ Error updating stats: $e");
    }
  }

  // ==================== PROFILE MANAGEMENT ====================

  /// প্রোফাইল ডাটা সেভ করার মেথড
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

  /// প্রোফাইল ইমেজ সেভ করার মেথড
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

  /// প্রোফাইল ইমেজ পাওয়ার মেথড
  static Future<String?> getProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_profileImageKey);
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  /// প্রোফাইল কমপ্লিটনেস পার্সেন্টেজ পাওয়ার মেথড
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

  // ==================== GIFT MANAGEMENT ====================

  /// গিফ্ট রিকোয়েস্ট সেভ করার মেথড
  static Future<void> saveGiftRequest(
    String mobileNumber,
    String userEmail,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> history = prefs.getStringList(_giftHistoryKey) ?? [];

      final newRequest = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'mobileNumber': mobileNumber,
        'userEmail': userEmail,
        'pointsUsed': 200,
        'requestedAt': DateTime.now().toIso8601String(),
        'status': 'pending',
        'processedAt': null,
      };

      history.add(jsonEncode(newRequest));
      await prefs.setStringList(_giftHistoryKey, history);
      print('✅ Gift request saved');
    } catch (e) {
      print('❌ Error saving gift request: $e');
      throw e;
    }
  }

  /// গিফ্ট হিস্ট্রি পাওয়ার মেথড
  static Future<List<Map<String, dynamic>>> getGiftHistory() async {
    try {
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
          print('Gift request parse error: $e');
        }
      }

      history.sort((a, b) {
        final aId = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
        final bId = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
        return bId.compareTo(aId);
      });

      return history;
    } catch (e) {
      print('Error getting gift history: $e');
      return [];
    }
  }

  /// গিফ্ট স্ট্যাটাস আপডেট করার মেথড
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

  /// পেন্ডিং গিফ্ট কাউন্ট পাওয়ার মেথড
  static Future<int> getPendingGiftCount() async {
    final history = await getGiftHistory();
    return history.where((request) => request['status'] == 'pending').length;
  }

  // ==================== UTILITY METHODS ====================
  /// পরের দিনের শুরু সময় পাওয়ার মেথড
  static DateTime _getNextDayStart() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  /// সেফলি int এ কনভার্ট করার হেল্পার
  static int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  /// ডিভাইস আইডি জেনারেট করার মেথড
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

  /// র‍্যান্ডম স্ট্রিং জেনারেটর
  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final result = StringBuffer();

    for (int i = 0; i < length; i++) {
      result.write(chars[(random + i) % chars.length]);
    }

    return result.toString();
  }

  /// গিফ্ট রিকোয়েস্ট সেফলি পার্স করার মেথড
  static Map<String, dynamic> _safeParseGiftRequest(String item) {
    try {
      final decoded = jsonDecode(item);
      if (decoded is Map<String, dynamic>) {
        return {
          'id': decoded['id']?.toString() ?? '',
          'mobileNumber': decoded['mobileNumber']?.toString() ?? '',
          'userEmail': decoded['userEmail']?.toString() ?? '',
          'pointsUsed': _safeToInt(decoded['pointsUsed']),
          'requestedAt': decoded['requestedAt']?.toString() ?? '',
          'status': decoded['status']?.toString() ?? 'pending',
          'processedAt': decoded['processedAt']?.toString(),
        };
      }
    } catch (e) {
      print('JSON decode failed: $e');
    }
    return {};
  }

  // ==================== DEBUG & MAINTENANCE ====================

  /// সম্পূর্ণ রিসেট করার মেথড
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
      await prefs.remove(_quizPlayHistoryKey);

      print('✅ Complete reset successful');
    } catch (e) {
      print('❌ Error in complete reset: $e');
      throw e;
    }
  }
}
