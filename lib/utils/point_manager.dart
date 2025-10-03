// utils/point_manager.dart - UPDATED WITH PROFILE FEATURES
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PointManager {
  static const String _pendingPointsKey = 'pending_points';
  static const String _totalPointsKey = 'total_points';
  static const String _totalQuizzesKey = 'total_quizzes';
  static const String _totalCorrectKey = 'total_correct';
  static const String _userEmailKey = 'user_email';
  static const String _rechargeHistoryKey = 'recharge_history';
  static const String _dailyQuizHistoryKey = 'daily_quiz_history';
  static const String _userDeviceIdKey = 'user_device_id';

  // 🔥 NEW: Profile related keys
  static const String _userNameKey = 'user_name';
  static const String _userMobileKey = 'user_mobile';
  static const String _profileImageKey = 'profile_image';

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
      // 🔥 NEW
      'userMobile': prefs.getString(_userMobileKey) ?? '',
      // 🔥 NEW
      'profileImage': prefs.getString(_profileImageKey),
      // 🔥 NEW
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
      await prefs.remove(_rechargeHistoryKey);
      await prefs.remove(_dailyQuizHistoryKey);

      print('Complete reset successful');
    } catch (e) {
      print('Error in complete reset: $e');
      throw e;
    }
  }

  // Existing methods remain the same...

  // 🔥 ডেইলি কুইজ লিমিট চেক
  static Future<bool> canPlayQuizToday(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().split(
      'T',
    )[0]; // YYYY-MM-DD

    final dailyHistory = prefs.getString(_dailyQuizHistoryKey) ?? '{}';
    final Map<String, dynamic> historyMap = jsonDecode(dailyHistory);

    final String todayKey = '$today-$quizId';

    // যদি আজকে এই কুইজ already played হয়
    if (historyMap.containsKey(todayKey)) {
      return false;
    }

    return true;
  }

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

  // 🔥 স্প্যাম ডিটেকশন (একই ডিভাইস থেকে অনেক রিচার্জ)
  static Future<bool> isSuspiciousActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getRechargeHistory();
    final deviceId = await getDeviceId();

    // গত 24 ঘন্টার রিচার্জ কাউন্ট
    final now = DateTime.now();
    final recentRecharges = history.where((request) {
      try {
        final requestedAt = DateTime.parse(request['requestedAt']);
        return now.difference(requestedAt).inHours <= 24;
      } catch (e) {
        return false;
      }
    }).length;

    // 24 ঘন্টায় 3 টার বেশি রিচার্জ সাসপিশিয়াস
    if (recentRecharges > 3) {
      return true;
    }

    return false;
  }

  // পয়েন্ট কাটার মেথড (রিচার্জের জন্য)
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
  // 🔥 রিচার্জ রিকোয়েস্ট সেভ করার মেথড - COMPLETELY FIXED
  static Future<void> saveRechargeRequest(
    String mobileNumber,
    String userEmail,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_rechargeHistoryKey) ?? [];

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
    await prefs.setStringList(_rechargeHistoryKey, history);
  }

  // 🔥 রিচার্জ হিস্ট্রি পাওয়ার মেথড - COMPLETELY FIXED
  static Future<List<Map<String, dynamic>>> getRechargeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings =
        prefs.getStringList(_rechargeHistoryKey) ?? [];
    final List<Map<String, dynamic>> history = [];

    for (String item in historyStrings) {
      try {
        final Map<String, dynamic> request = _safeParseRechargeRequest(item);
        if (request.isNotEmpty) {
          history.add(request);
        }
      } catch (e) {
        print('রিচার্জ রিকোয়েস্ট পার্স করতে ত্রুটি: $e - Item: $item');
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
  static Map<String, dynamic> _safeParseRechargeRequest(String item) {
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

  // 🔥 সেফলি int এ কনভার্ট করার হেল্পার
  static int _safeToInt(dynamic value) {
    if (value == null) return 200;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 200;
    return 200;
  }

  // 🔥 রিচার্জ রিকোয়েস্ট আপডেট করার মেথড - FIXED
  static Future<void> updateRechargeStatus(
    String requestId,
    String newStatus,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings =
        prefs.getStringList(_rechargeHistoryKey) ?? [];
    final List<String> updatedHistory = [];

    for (String item in historyStrings) {
      try {
        Map<String, dynamic> request = _safeParseRechargeRequest(item);

        if (request['id']?.toString() == requestId) {
          request['status'] = newStatus;
          request['processedAt'] = DateTime.now().toIso8601String();
        }

        updatedHistory.add(jsonEncode(request));
      } catch (e) {
        updatedHistory.add(item);
      }
    }

    await prefs.setStringList(_rechargeHistoryKey, updatedHistory);
  }

  // 🔥 পেন্ডিং রিচার্জ রিকোয়েস্ট কাউন্ট
  static Future<int> getPendingRechargeCount() async {
    final history = await getRechargeHistory();
    return history.where((request) => request['status'] == 'pending').length;
  }

  // 🔥 সব ডাটা রিসেট (যদি প্রয়োজন হয়)
  static Future<void> clearRechargeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rechargeHistoryKey);
  }

  // 🔥 ডেবাগিং: সব রিচার্জ রিকোয়েস্ট প্রিন্ট করুন
  static Future<void> debugPrintAllRequests() async {
    final history = await getRechargeHistory();
    print('=== রিচার্জ রিকোয়েস্ট ডিবাগ ===');
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
}
