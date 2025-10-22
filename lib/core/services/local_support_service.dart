// services/local_support_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class LocalSupportService {
  static const String _supportersKey = 'app_supporters_list';
  static const String _userActionsKey = 'user_support_actions';
  static const String _communityExamplesKey = 'community_examples_data';
  static const String _dailyActivityKey = 'daily_activity_data';

  // Dynamic Community Examples - সময় অনুযায়ী change হবে
  List<Map<String, dynamic>> get _dynamicCommunityExamples {
    final now = DateTime.now();
    final random = Random(now.day + now.month); // Daily changing seed

    List<Map<String, dynamic>> examples = [];

    // বিভিন্ন সময়ের জন্য বিভিন্ন activity generate করুন
    for (int i = 0; i < 25; i++) {
      final hoursAgo = i < 15 ? random.nextInt(24) : random.nextInt(72) + 24;
      final actionType = random.nextBool() ? 'rate' : 'share';

      examples.add({
        'userId': 'community_${i + 1}',
        'userName': _getRandomUserName(random),
        'country': _getRandomCountry(random),
        'actionType': actionType,
        'actionName': _getRandomActionName(actionType, random),
        'timestamp': DateTime.now()
            .subtract(Duration(hours: hoursAgo))
            .millisecondsSinceEpoch,
        'isCommunityExample': true,
      });
    }

    return examples;
  }

  String _getRandomUserName(Random random) {
    final names = [
      'Community Member',
      'App User',
      'Regular User',
      'Active Member',
      'Community Helper',
      'App Lover',
      'Helpful User',
      'Engaged User',
      'Supportive User',
      'Dedicated User',
      'Active Supporter',
      'Community Builder',
    ];
    return names[random.nextInt(names.length)];
  }

  String _getRandomCountry(Random random) {
    final countries = [
      'Bangladesh',
      'India',
      'Saudi Arabia',
      'UAE',
      'UK',
      'USA',
      'Kuwait',
      'Qatar',
      'Malaysia',
      'Canada',
      'Australia',
      'Germany',
    ];
    return countries[random.nextInt(countries.length)];
  }

  String _getRandomActionName(String actionType, Random random) {
    if (actionType == 'rate') {
      final actions = [
        'Rated the App',
        'Provided Feedback',
        'Supported Development',
        'Gave 5 Star Rating',
        'Left Positive Review',
        'Helped Improve App',
      ];
      return actions[random.nextInt(actions.length)];
    } else {
      final actions = [
        'Shared with Friends',
        'Recommended to Others',
        'Shared on Social Media',
        'Told Friends About App',
        'Shared App Link',
        'Spread the Word',
      ];
      return actions[random.nextInt(actions.length)];
    }
  }

  // Daily activity management
  Future<void> _updateDailyActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10); // YYYY-MM-DD

    // Get current daily activity
    final dailyActivityJson = prefs.getString(_dailyActivityKey);
    Map<String, dynamic> dailyActivity = {};

    if (dailyActivityJson != null) {
      dailyActivity = Map<String, dynamic>.from(json.decode(dailyActivityJson));
    }

    // If it's a new day, reset activity
    if (dailyActivity['date'] != today) {
      final random = Random(DateTime.now().day + DateTime.now().month);
      dailyActivity = {
        'date': today,
        'count': random.nextInt(8) + 3, // 3-10 random daily activity
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_dailyActivityKey, json.encode(dailyActivity));
    }
  }

  Future<int> getTodayActivityCount() async {
    await _updateDailyActivity();
    final prefs = await SharedPreferences.getInstance();
    final dailyActivityJson = prefs.getString(_dailyActivityKey);

    if (dailyActivityJson != null) {
      final dailyActivity = Map<String, dynamic>.from(
        json.decode(dailyActivityJson),
      );
      return dailyActivity['count'] ?? 0;
    }

    return 0;
  }

  Future<void> _incrementDailyActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);

    final dailyActivityJson = prefs.getString(_dailyActivityKey);
    Map<String, dynamic> dailyActivity = {};

    if (dailyActivityJson != null) {
      dailyActivity = Map<String, dynamic>.from(json.decode(dailyActivityJson));
    }

    // Only increment if it's today
    if (dailyActivity['date'] == today) {
      dailyActivity['count'] = (dailyActivity['count'] ?? 0) + 1;
      dailyActivity['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(_dailyActivityKey, json.encode(dailyActivity));
    }
  }

  // Static Community Examples for fallback
  final List<Map<String, dynamic>> _staticCommunityExamples = [
    {
      'userId': 'community_1',
      'userName': 'Community Member',
      'country': 'Bangladesh',
      'actionType': 'rate',
      'actionName': 'Rated the App',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 2))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_2',
      'userName': 'App User',
      'country': 'Saudi Arabia',
      'actionType': 'share',
      'actionName': 'Shared with Friends',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 4))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_3',
      'userName': 'Regular User',
      'country': 'USA',
      'actionType': 'rate',
      'actionName': 'Provided Feedback',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 6))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_4',
      'userName': 'Active Member',
      'country': 'UAE',
      'actionType': 'share',
      'actionName': 'Recommended to Others',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 8))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_5',
      'userName': 'Community Helper',
      'country': 'UK',
      'actionType': 'rate',
      'actionName': 'Supported Development',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 10))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_6',
      'userName': 'App Lover',
      'country': 'India',
      'actionType': 'share',
      'actionName': 'Shared on Social Media',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 12))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_7',
      'userName': 'Helpful User',
      'country': 'Kuwait',
      'actionType': 'rate',
      'actionName': 'Gave 5 Star Rating',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 14))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_8',
      'userName': 'Engaged User',
      'country': 'Qatar',
      'actionType': 'share',
      'actionName': 'Told Friends About App',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 16))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_9',
      'userName': 'Supportive Member',
      'country': 'Malaysia',
      'actionType': 'rate',
      'actionName': 'Left Positive Review',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 18))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_10',
      'userName': 'Active Supporter',
      'country': 'Oman',
      'actionType': 'share',
      'actionName': 'Shared with Family',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 20))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_11',
      'userName': 'Community Contributor',
      'country': 'Bahrain',
      'actionType': 'rate',
      'actionName': 'Rated and Reviewed',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 22))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_12',
      'userName': 'App Enthusiast',
      'country': 'Canada',
      'actionType': 'share',
      'actionName': 'Recommended in Group',
      'timestamp': DateTime.now()
          .subtract(Duration(hours: 24))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_13',
      'userName': 'Regular Visitor',
      'country': 'Australia',
      'actionType': 'rate',
      'actionName': 'Supported the Team',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 1, hours: 2))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_14',
      'userName': 'Dedicated User',
      'country': 'Germany',
      'actionType': 'share',
      'actionName': 'Shared App Link',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 1, hours: 4))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_15',
      'userName': 'Community Builder',
      'country': 'France',
      'actionType': 'rate',
      'actionName': 'Provided Suggestions',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 1, hours: 6))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_16',
      'userName': 'Active Participant',
      'country': 'Singapore',
      'actionType': 'share',
      'actionName': 'Spread the Word',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 1, hours: 8))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_17',
      'userName': 'App Advocate',
      'country': 'South Africa',
      'actionType': 'rate',
      'actionName': 'Helped Improve App',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 1, hours: 10))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_18',
      'userName': 'Community Leader',
      'country': 'Egypt',
      'actionType': 'share',
      'actionName': 'Shared Experience',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 1, hours: 12))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_19',
      'userName': 'Supportive User',
      'country': 'Turkey',
      'actionType': 'rate',
      'actionName': 'Gave Helpful Feedback',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 1, hours: 14))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_20',
      'userName': 'Active Community Member',
      'country': 'Pakistan',
      'actionType': 'share',
      'actionName': 'Recommended to Colleagues',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 1, hours: 16))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_21',
      'userName': 'Dedicated Supporter',
      'country': 'Indonesia',
      'actionType': 'rate',
      'actionName': 'Supported Development',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 2))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_22',
      'userName': 'Community Volunteer',
      'country': 'Philippines',
      'actionType': 'share',
      'actionName': 'Shared with Community',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 2, hours: 4))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_23',
      'userName': 'App Ambassador',
      'country': 'Thailand',
      'actionType': 'rate',
      'actionName': 'Helped with Testing',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 2, hours: 8))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_24',
      'userName': 'Active Contributor',
      'country': 'Vietnam',
      'actionType': 'share',
      'actionName': 'Promoted the App',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 2, hours: 12))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
    {
      'userId': 'community_25',
      'userName': 'Community Partner',
      'country': 'Sri Lanka',
      'actionType': 'rate',
      'actionName': 'Provided Valuable Input',
      'timestamp': DateTime.now()
          .subtract(Duration(days: 3))
          .millisecondsSinceEpoch,
      'isCommunityExample': true,
    },
  ];

  // ইউজারের সাপোর্ট একশন রেকর্ড করুন
  Future<void> recordSupportAction({
    required String actionType,
    required String actionName,
    String? country,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = await _getOrCreateUserId();
      String userCountry = country ?? await _detectUserCountry();
      String userName = await _generateUserName();

      Map<String, dynamic> supporterData = {
        'userId': userId,
        'userName': userName,
        'country': userCountry,
        'actionType': actionType,
        'actionName': actionName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isCurrentUser': true,
        'isRealUser': true,
      };

      List<dynamic> existingSupporters = await _getSupportersList();

      // Remove duplicate
      existingSupporters.removeWhere(
        (supporter) => supporter['userId'] == userId,
      );

      // Add new supporter at top
      existingSupporters.insert(0, supporterData);

      // Keep only 100 supporters
      if (existingSupporters.length > 100) {
        existingSupporters = existingSupporters.sublist(0, 100);
      }

      await prefs.setString(_supportersKey, json.encode(existingSupporters));

      // Update daily activity count when user performs action
      await _incrementDailyActivity();

      print('✅ Support action recorded: $actionName by $userName');
    } catch (e) {
      print('❌ Error recording support action: $e');
    }
  }

  // সব সাপোর্টারদের লিস্ট পান (Community Examples + Real Users)
  Future<List<Map<String, dynamic>>> getSupporters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final supportersJson = prefs.getString(_supportersKey);

      List<Map<String, dynamic>> allSupporters = [];

      // Use dynamic community examples (changes daily)
      final dynamicExamples = _dynamicCommunityExamples;

      // Community Examples যোগ করুন
      if (!prefs.containsKey(_communityExamplesKey)) {
        allSupporters.addAll(dynamicExamples);
        await prefs.setString(
          _communityExamplesKey,
          json.encode(dynamicExamples),
        );
      } else {
        // Check if we should refresh examples (after 24 hours)
        final examplesJson = prefs.getString(_communityExamplesKey);
        final lastSavedExamples = List<Map<String, dynamic>>.from(
          json.decode(examplesJson!),
        );

        if (lastSavedExamples.isNotEmpty) {
          final firstExampleTime = DateTime.fromMillisecondsSinceEpoch(
            lastSavedExamples.first['timestamp'],
          );
          final now = DateTime.now();
          final difference = now.difference(firstExampleTime);

          // Refresh examples every 24 hours
          if (difference.inHours >= 24) {
            allSupporters.addAll(dynamicExamples);
            await prefs.setString(
              _communityExamplesKey,
              json.encode(dynamicExamples),
            );
          } else {
            allSupporters.addAll(lastSavedExamples);
          }
        } else {
          allSupporters.addAll(dynamicExamples);
          await prefs.setString(
            _communityExamplesKey,
            json.encode(dynamicExamples),
          );
        }
      }

      // Real User Supporters যোগ করুন
      if (supportersJson != null) {
        final realSupporters = List<Map<String, dynamic>>.from(
          json.decode(supportersJson),
        );
        allSupporters.addAll(realSupporters);
      }

      // সর্ট করুন টাইমস্ট্যাম্প অনুযায়ী (নতুন থেকে পুরাতন)
      allSupporters.sort(
        (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int),
      );

      return allSupporters;
    } catch (e) {
      print('❌ Error getting supporters: $e');
      return _getDefaultSupporters();
    }
  }

  // ইউজারের নিজের সাপোর্ট হিস্ট্রি পান
  Future<List<Map<String, dynamic>>> getUserSupportHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final supportersJson = prefs.getString(_supportersKey);

      if (supportersJson == null) return [];

      final allSupporters = List<Map<String, dynamic>>.from(
        json.decode(supportersJson),
      );
      final userId = await _getOrCreateUserId();

      return allSupporters
          .where((supporter) => supporter['userId'] == userId)
          .toList();
    } catch (e) {
      print('❌ Error getting user support history: $e');
      return [];
    }
  }

  // ইউজার আইডি তৈরি বা পান
  Future<String> _getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_unique_id');

    if (userId == null) {
      userId =
          'user_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
      await prefs.setString('user_unique_id', userId);
    }

    return userId;
  }

  // ইউজারনেম জেনারেট করুন
  Future<String> _generateUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('user_display_name');

    if (userName == null) {
      List<String> names = [
        'Community User',
        'App Supporter',
        'Active Member',
        'Helpful User',
        'App Lover',
        'Regular User',
        'Engaged User',
        'Supportive User',
      ];

      final random = Random();
      userName = names[random.nextInt(names.length)];

      await prefs.setString('user_display_name', userName);
    }

    return userName;
  }

  // ইউজারের দেশ ডিটেক্ট করুন
  Future<String> _detectUserCountry() async {
    List<String> countries = [
      'Bangladesh',
      'India',
      'Saudi Arabia',
      'UAE',
      'UK',
      'USA',
      'Kuwait',
      'Qatar',
      'Malaysia',
    ];
    return countries[Random().nextInt(countries.length)];
  }

  // সাপোর্টার লিস্ট পান
  Future<List<dynamic>> _getSupportersList() async {
    final prefs = await SharedPreferences.getInstance();
    final supportersJson = prefs.getString(_supportersKey);

    if (supportersJson == null) {
      return [];
    }

    return json.decode(supportersJson);
  }

  // ডিফল্ট সাপোর্টার ডেটা
  List<Map<String, dynamic>> _getDefaultSupporters() {
    return [
      ..._staticCommunityExamples,
      {
        'userId': 'demo_1',
        'userName': 'Community User',
        'country': 'Bangladesh',
        'actionType': 'rate',
        'actionName': 'Rated the App',
        'timestamp': DateTime.now()
            .subtract(Duration(hours: 2))
            .millisecondsSinceEpoch,
      },
      {
        'userId': 'demo_2',
        'userName': 'App Supporter',
        'country': 'Saudi Arabia',
        'actionType': 'share',
        'actionName': 'Shared the App',
        'timestamp': DateTime.now()
            .subtract(Duration(hours: 5))
            .millisecondsSinceEpoch,
      },
    ];
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
