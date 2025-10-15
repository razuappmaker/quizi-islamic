// utils/point_manager.dart - BACKWARD COMPATIBLE VERSION
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PointManager with ChangeNotifier {
  // ==================== SINGLETON PATTERN (Backward Compatible) ====================
  static final PointManager _instance = PointManager._internal();

  factory PointManager() => _instance;

  PointManager._internal();

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
  static const String _currentLanguageKey = 'current_language';

  // ==================== CONSTANTS ====================
  static const int QUIZ_COOLDOWN_MINUTES = 15;
  static const int MAX_POINTS_PER_DAY = 1000; //1000

  // ==================== LANGUAGE MANAGEMENT ====================
  String _currentLanguage = 'bn';

  String get currentLanguage => _currentLanguage;

  bool get isEnglish => _currentLanguage == 'en';

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentLanguageKey, languageCode);
    notifyListeners();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_currentLanguageKey) ?? 'bn';
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _currentLanguage = _currentLanguage == 'bn' ? 'en' : 'bn';
    await setLanguage(_currentLanguage);
  }

  // ==================== TRANSLATION SYSTEM ====================
  String _getText(String english, String bangla) {
    return _currentLanguage == 'en' ? english : bangla;
  }

  // ==================== STATIC METHODS (For Backward Compatibility) ====================
  // আপনার পুরানো code এর জন্য static methods রাখা হলো

  static Future<void> addPoints(int points) async {
    return _instance._addPoints(points);
  }

  static Future<void> deductPoints(int points) async {
    return _instance._deductPoints(points);
  }

  static Future<Map<String, dynamic>> canPlayQuiz(String quizId) async {
    return _instance._canPlayQuiz(quizId);
  }

  static Future<void> recordQuizPlay({
    required String quizId,
    required int pointsEarned,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    return _instance._recordQuizPlay(
      quizId: quizId,
      pointsEarned: pointsEarned,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );
  }

  static Future<Map<String, dynamic>> getUserData() async {
    return _instance._getUserData();
  }

  static Future<void> saveProfileData(
    String userName,
    String userMobile,
  ) async {
    return _instance._saveProfileData(userName, userMobile);
  }

  static Future<void> saveProfileImage(String imagePath) async {
    return _instance._saveProfileImage(imagePath);
  }

  static Future<void> saveGiftRequest(
    String mobileNumber,
    String userEmail,
  ) async {
    return _instance._saveGiftRequest(mobileNumber, userEmail);
  }

  static Future<int> getTotalPointsToday() async {
    return _instance._getTotalPointsToday();
  }

  static Future<Map<String, dynamic>> getQuizPlayHistory(String quizId) async {
    return _instance._getQuizPlayHistory(quizId);
  }

  static Future<void> updateQuizStats(int correctAnswers) async {
    return _instance._updateQuizStats(correctAnswers);
  }

  static Future<int> getTodayRewards() async {
    return _instance._getTodayRewards();
  }

  static Future<String> getDeviceId() async {
    return _instance._getDeviceId();
  }

  static Future<List<Map<String, dynamic>>> getGiftHistory() async {
    return _instance._getGiftHistory();
  }

  static Future<void> updateGiftStatus(
    String requestId,
    String newStatus,
  ) async {
    return _instance._updateGiftStatus(requestId, newStatus);
  }

  static Future<int> getPendingGiftCount() async {
    return _instance._getPendingGiftCount();
  }

  static Future<int> getProfileCompleteness() async {
    return _instance._getProfileCompleteness();
  }

  static Future<void> completeReset() async {
    return _instance._completeReset();
  }

  static Future<void> debugTodayPointsStatus() async {
    return _instance._debugTodayPointsStatus();
  }

  static Future<void> debugAllQuizPoints() async {
    return _instance._debugAllQuizPoints();
  }

  // ==================== INSTANCE METHODS (Actual Implementation) ====================

  Future<void> _addPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPending = prefs.getInt(_pendingPointsKey) ?? 0;
      final currentTotal = prefs.getInt(_totalPointsKey) ?? 0;

      await prefs.setInt(_pendingPointsKey, currentPending + points);
      await prefs.setInt(_totalPointsKey, currentTotal + points);

      print(
        _getText(
          "✅ $points points added to user account",
          "✅ $points পয়েন্ট যোগ হয়েছে",
        ),
      );
      notifyListeners();
    } catch (e) {
      print(
        _getText("❌ Error adding points: $e", "❌ পয়েন্ট যোগ করতে ত্রুটি: $e"),
      );
      throw e;
    }
  }

  Future<void> _deductPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPending = prefs.getInt(_pendingPointsKey) ?? 0;

      if (currentPending >= points) {
        await prefs.setInt(_pendingPointsKey, currentPending - points);
        notifyListeners();
      } else {
        throw Exception(_getText('Insufficient points', 'পর্যাপ্ত পয়েন্ট নেই'));
      }
    } catch (e) {
      print(
        _getText("❌ Error deducting points: $e", "❌ পয়েন্ট কাটতে ত্রুটি: $e"),
      );
      throw e;
    }
  }

  Future<Map<String, dynamic>> _canPlayQuiz(String quizId) async {
    try {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> quizHistory = await _getQuizPlayHistory(
        quizId,
      );

      final int todayPoints = _safeToInt(quizHistory['todayPoints']);
      final String? lastPlayed = quizHistory['lastPlayed']?.toString();
      final int totalPointsToday = await _getTotalPointsToday();

      // Daily points limit check
      if (totalPointsToday >= MAX_POINTS_PER_DAY) {
        return {
          'canPlay': false,
          'reason': _getText('Daily Points Limit', 'দৈনিক পয়েন্ট সীমা'),
          'message': _getText(
            'You have earned maximum 1000 points from all quizzes today. Please try again tomorrow.',
            'আপনি আজ সকল কুইজ থেকে সর্বোচ্চ ১০০০ পয়েন্ট অর্জন করেছেন। আগামীকাল আবার চেষ্টা করুন।',
          ),
          'nextAvailable': _getNextDayStart(),
        };
      }

      // Cooldown period check
      if (lastPlayed != null && lastPlayed.isNotEmpty) {
        try {
          final DateTime lastPlayedTime = DateTime.parse(lastPlayed);
          final int minutesSinceLastPlay = now
              .difference(lastPlayedTime)
              .inMinutes;

          if (minutesSinceLastPlay < QUIZ_COOLDOWN_MINUTES) {
            final int remainingMinutes =
                QUIZ_COOLDOWN_MINUTES - minutesSinceLastPlay;
            return {
              'canPlay': false,
              'reason': _getText(
                'You have already attempted this quiz',
                'আপনি ইতিমধ্যে এ বিষয়ে কুইজ এর উত্তর দিয়েছেন',
              ),
              'message': _getText(
                'You can play quiz on this topic again after\n\n⏰ $remainingMinutes minutes',
                'একই বিষয়ে আবার কুইজ এর উত্তর দিতে পারবেন\n\n⏰ $remainingMinutes মিনিট পর',
              ),
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
      return {
        'canPlay': true,
        'reason': _getText('Success', 'সফল'),
        'message': _getText('Can play quiz', 'কুইজ খেলা যাবে'),
        'remainingPoints': MAX_POINTS_PER_DAY - totalPointsToday,
        'nextAvailable': null,
      };
    } catch (e) {
      return {
        'canPlay': false,
        'reason': _getText('System Error', 'সিস্টেম ত্রুটি'),
        'message': _getText(
          'System has temporary error. Please try again later.',
          'সিস্টেমে সাময়িক ত্রুটি রয়েছে। পরে আবার চেষ্টা করুন।',
        ),
        'nextAvailable': null,
      };
    }
  }

  Future<void> _recordQuizPlay({
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

      // Check daily limit BEFORE adding points
      final int totalPointsToday = await _getTotalPointsToday();

      if (totalPointsToday >= MAX_POINTS_PER_DAY) {
        print(
          _getText(
            '🚫 DAILY LIMIT REACHED: Not adding points',
            '🚫 দৈনিক লিমিট শেষ: পয়েন্ট যোগ করা হচ্ছেনা',
          ),
        );

        // Record without adding points
        history[quizId] = {
          'playCount': _safeToInt(quizHistory['playCount']) + 1,
          'lastPlayed': now.toIso8601String(),
          'todayPlayCount': isToday
              ? _safeToInt(quizHistory['todayPlayCount']) + 1
              : 1,
          'pointsEarned': _safeToInt(quizHistory['pointsEarned']),
          'todayPoints': _safeToInt(quizHistory['todayPoints']),
          'playSessions': [
            ...(quizHistory['playSessions'] ?? []),
            {
              'timestamp': now.toIso8601String(),
              'pointsEarned': 0,
              'correctAnswers': correctAnswers,
              'totalQuestions': totalQuestions,
            },
          ],
        };

        await prefs.setString(_quizPlayHistoryKey, jsonEncode(history));
        return;
      }

      // Calculate new points
      int currentTodayPoints = _safeToInt(quizHistory['todayPoints']);
      int newTodayPoints = isToday
          ? currentTodayPoints + pointsEarned
          : pointsEarned;

      // Final check: Ensure we don't exceed daily limit
      if (totalPointsToday + pointsEarned > MAX_POINTS_PER_DAY) {
        final int allowedPoints = MAX_POINTS_PER_DAY - totalPointsToday;
        pointsEarned = allowedPoints;
        newTodayPoints = isToday
            ? currentTodayPoints + allowedPoints
            : allowedPoints;
      }

      // Update history
      history[quizId] = {
        'playCount': _safeToInt(quizHistory['playCount']) + 1,
        'lastPlayed': now.toIso8601String(),
        'todayPlayCount': isToday
            ? _safeToInt(quizHistory['todayPlayCount']) + 1
            : 1,
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

      // Add actual points
      if (pointsEarned > 0) {
        await _addPoints(pointsEarned);
        await _updateQuizStats(correctAnswers);

        print(
          _getText(
            '✅ Quiz play recorded: $quizId, Points: $pointsEarned',
            '✅ কুইজ রেকর্ড হয়েছে: $quizId, পয়েন্ট: $pointsEarned',
          ),
        );
      }
    } catch (e) {
      print(
        _getText(
          '❌ Error recording quiz play: $e',
          '❌ কুইজ রেকর্ড করতে ত্রুটি: $e',
        ),
      );
      throw e;
    }
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final int totalPoints = prefs.getInt(_totalPointsKey) ?? 0;
    final int totalPointsToday = await _getTotalPointsToday();

    String defaultUser = _getText('Islamic Quiz User', 'ইসলামিক কুইজ ইউজার');

    return {
      'pendingPoints': prefs.getInt(_pendingPointsKey) ?? 0,
      'totalPoints': totalPoints,
      'totalQuizzes': prefs.getInt(_totalQuizzesKey) ?? 0,
      'totalCorrectAnswers': prefs.getInt(_totalCorrectKey) ?? 0,
      'userEmail': prefs.getString(_userEmailKey) ?? defaultUser,
      'userName': prefs.getString(_userNameKey) ?? defaultUser,
      'userMobile': prefs.getString(_userMobileKey) ?? '',
      'profileImage': prefs.getString(_profileImageKey),
      'todayRewards': await _getTodayRewards(),
      'deviceId': await _getDeviceId(),
      'totalPointsToday': totalPointsToday,
      'remainingPointsToday': MAX_POINTS_PER_DAY - totalPointsToday,
    };
  }

  Future<void> _saveProfileData(String userName, String userMobile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, userName);
      await prefs.setString(_userMobileKey, userMobile);
      print(
        _getText(
          '✅ Profile data saved: $userName, $userMobile',
          '✅ প্রোফাইল ডাটা সেভ হয়েছে: $userName, $userMobile',
        ),
      );
      notifyListeners();
    } catch (e) {
      print(
        _getText(
          '❌ Error saving profile data: $e',
          '❌ প্রোফাইল সেভ করতে ত্রুটি: $e',
        ),
      );
      throw e;
    }
  }

  Future<void> _saveProfileImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageKey, imagePath);
      print(
        _getText(
          '✅ Profile image saved: $imagePath',
          '✅ প্রোফাইল ছবি সেভ হয়েছে: $imagePath',
        ),
      );
      notifyListeners();
    } catch (e) {
      print(
        _getText(
          '❌ Error saving profile image: $e',
          '❌ প্রোফাইল ছবি সেভ করতে ত্রুটি: $e',
        ),
      );
      throw e;
    }
  }

  Future<void> _saveGiftRequest(String mobileNumber, String userEmail) async {
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
      print(_getText('✅ Gift request saved', '✅ গিফ্ট রিকোয়েস্ট সেভ হয়েছে'));
      notifyListeners();
    } catch (e) {
      print(
        _getText(
          '❌ Error saving gift request: $e',
          '❌ গিফ্ট রিকোয়েস্ট সেভ করতে ত্রুটি: $e',
        ),
      );
      throw e;
    }
  }

  Future<int> _getTotalPointsToday() async {
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
            }
          } catch (e) {
            print('⚠️ Date parsing error for $quizId: $e');
          }
        }
      }

      return totalPointsToday;
    } catch (e) {
      print('❌ Error getting total points today: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> _getQuizPlayHistory(String quizId) async {
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

  Future<void> _updateQuizStats(int correctAnswers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentQuizzes = prefs.getInt(_totalQuizzesKey) ?? 0;
      await prefs.setInt(_totalQuizzesKey, currentQuizzes + 1);

      final currentCorrect = prefs.getInt(_totalCorrectKey) ?? 0;
      await prefs.setInt(_totalCorrectKey, currentCorrect + correctAnswers);

      print(
        _getText(
          "✅ Quiz stats updated: $correctAnswers correct answers",
          "✅ কুইজ স্ট্যাটস আপডেট হয়েছে: $correctAnswers সঠিক উত্তর",
        ),
      );
    } catch (e) {
      print(
        _getText(
          "❌ Error updating stats: $e",
          "❌ স্ট্যাটস আপডেট করতে ত্রুটি: $e",
        ),
      );
    }
  }

  Future<int> _getTodayRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = 'today_rewards_${now.year}-${now.month}-${now.day}';
      return prefs.getInt(todayKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_userDeviceIdKey);

    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_userDeviceIdKey, deviceId);
    }

    return deviceId;
  }

  Future<List<Map<String, dynamic>>> _getGiftHistory() async {
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

  Future<void> _updateGiftStatus(String requestId, String newStatus) async {
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

  Future<int> _getPendingGiftCount() async {
    final history = await _getGiftHistory();
    return history.where((request) => request['status'] == 'pending').length;
  }

  Future<int> _getProfileCompleteness() async {
    final userData = await _getUserData();
    int completeness = 0;

    // ✅ Language-aware default user check
    String defaultUser = _getText('Islamic Quiz User', 'ইসলামিক কুইজ ইউজার');

    if ((userData['userName'] ?? '').isNotEmpty &&
        userData['userName'] != defaultUser) {
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

  Future<void> _completeReset() async {
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

      print(_getText('✅ Complete reset successful', '✅ সম্পূর্ণ রিসেট সফল'));

      notifyListeners();
    } catch (e) {
      print(
        _getText('❌ Error in complete reset: $e', '❌ রিসেট করতে ত্রুটি: $e'),
      );
      throw e;
    }
  }

  Future<void> _debugTodayPointsStatus() async {
    try {
      final int totalPointsToday = await _getTotalPointsToday();
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

  Future<void> _debugAllQuizPoints() async {
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

  // ==================== HELPER METHODS ====================
  static int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  static DateTime _getNextDayStart() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

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

  // ==================== TODAY REWARDS MANAGEMENT ====================

  /// আজকের রিওয়ার্ড আপডেট করার মেথড - STATIC VERSION
  static Future<void> updateTodayRewards(int todayRewards) async {
    return _instance._updateTodayRewards(todayRewards);
  }

  /// আজকের রিওয়ার্ড আপডেট করার মেথড - INSTANCE VERSION
  Future<void> _updateTodayRewards(int todayRewards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = 'today_rewards_${now.year}-${now.month}-${now.day}';

      await prefs.setInt(todayKey, todayRewards);

      print(
        _getText(
          'Today rewards updated: $todayRewards',
          'আজকের রিওয়ার্ড আপডেট হয়েছে: $todayRewards',
        ),
      );

      notifyListeners();
    } catch (e) {
      print(
        _getText(
          'Error updating today rewards: $e',
          'আজকের রিওয়ার্ড আপডেট করতে ত্রুটি: $e',
        ),
      );
      throw e;
    }
  }
}
