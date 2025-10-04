// mcq_security_manager.dart - UPDATED & OPTIMIZED Security & Data Management
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'network_json_loader.dart';
import '../utils/point_manager.dart';

class AnswerResult {
  final bool isCorrect;
  final int earnedPoints;

  AnswerResult({required this.isCorrect, required this.earnedPoints});
}

class MCQSecurityManager {
  // Quiz Data
  List<dynamic> questions = [];
  int score = 0;
  bool quizStarted = true;

  // Points System
  int _totalEarnedPoints = 0;
  bool pointsAdded = false;

  // User Statistics
  int _totalQuestionsAnswered = 0;
  int _totalCorrectAnswers = 0;
  int _totalPointsEarned = 0;

  // Language
  bool _isEnglish = false;

  // Category Mapping for English and Bengali
  final Map<String, String> _categoryMappings = {
    // English categories mapping to English JSON keys
    'Basic Islamic Knowledge': 'Basic Islamic Knowledge',
    'Quran': 'Quran',
    'Prophet Biography': 'Prophet Biography',
    'Worship': 'Worship',
    'Hereafter': 'Hereafter',
    'Judgment Day': 'Judgment Day',
    'Women in Islam': 'Women in Islam',
    'Islamic Ethics & Manners': 'Islamic Ethics & Manners',
    'Religious Law (Marriage-Divorce)': 'Religious Law (Marriage-Divorce)',
    'Etiquette': 'Etiquette',
    'Marital & Family Relations': 'Marital & Family Relations',
    'Hadith': 'Hadith',
    'Prophets': 'Prophets',
    'Islamic History': 'Islamic History',

    // Bengali categories mapping to Bengali JSON keys
    'ইসলামী প্রাথমিক জ্ঞান': 'ইসলামী প্রাথমিক জ্ঞান',
    'কোরআন': 'কোরআন',
    'মহানবী সঃ এর জীবনী': 'মহানবী সঃ এর জীবনী',
    'ইবাদত': 'ইবাদত',
    'আখিরাত': 'আখিরাত',
    'বিচার দিবস': 'বিচার দিবস',
    'নারী ও ইসলাম': 'নারী ও ইসলাম',
    'ইসলামী নৈতিকতা ও আচার': 'ইসলামী নৈতিকতা ও আচার',
    'ধর্মীয় আইন(বিবাহ-বিচ্ছেদ)': 'ধর্মীয় আইন(বিবাহ-বিচ্ছেদ)',
    'শিষ্টাচার': 'শিষ্টাচার',
    'দাম্পত্য ও পারিবারিক সম্পর্ক': 'দাম্পত্য ও পারিবারিক সম্পর্ক',
    'হাদিস': 'হাদিস',
    'নবী-রাসূল': 'নবী-রাসূল',
    'ইসলামের ইতিহাস': 'ইসলামের ইতিহাস',
  };

  Future<void> initialize({
    required String category,
    required String quizId,
  }) async {
    try {
      // Use the mapped quizId instead of direct category
      final String mappedQuizId = _categoryMappings[category] ?? quizId;

      print('🔄 Initializing quiz...');
      print('📝 Original Category: $category');
      print('🔑 Mapped Quiz ID: $mappedQuizId');
      print('🌐 Language: ${_isEnglish ? 'English' : 'Bangla'}');

      await loadQuestions(mappedQuizId);
      await _initializeUserStats();
      print('✅ MCQ Security Manager initialized successfully');
    } catch (e) {
      print('❌ Error initializing MCQ Security Manager: $e');
      questions = _getDefaultQuestions();
    }
  }

  Future<void> loadQuestions(String quizId) async {
    try {
      print('🔄 Loading questions for Quiz ID: $quizId');

      // Determine which file to load based on language
      final String fileName = _getQuestionFileName();

      print('📁 Loading from file: $fileName');

      // Try loading from network first
      try {
        final List<dynamic> allQuestionsData =
            await NetworkJsonLoader.loadJsonList(fileName);

        if (allQuestionsData is List && allQuestionsData.isNotEmpty) {
          Map<dynamic, dynamic> questionsMap = {};

          for (var item in allQuestionsData) {
            if (item is Map) {
              questionsMap.addAll(item as Map<dynamic, dynamic>);
            }
          }

          _setQuestionsFromMap(questionsMap, quizId);
          print('✅ Questions loaded successfully from network: $fileName');
          return;
        } else if (allQuestionsData is Map) {
          _setQuestionsFromMap(
            allQuestionsData as Map<dynamic, dynamic>,
            quizId,
          );
          print('✅ Questions loaded successfully from network: $fileName');
          return;
        }
      } catch (e) {
        print('❌ Failed to load from network: $e');
      }

      // Fallback to local asset
      try {
        print('🔄 Trying to load from local asset: $fileName');
        final String localResponse = await rootBundle.loadString(fileName);
        final Map<dynamic, dynamic> localData =
            json.decode(localResponse) as Map<dynamic, dynamic>;
        _setQuestionsFromMap(localData, quizId);
        print('✅ Questions loaded successfully from local asset: $fileName');
        return;
      } catch (e) {
        print('❌ Failed to load from local asset: $e');

        // If English file fails, try Bangla file as fallback
        if (fileName == 'assets/enquestions.json') {
          print('🔄 Falling back to Bangla questions file');
          await _loadBanglaQuestions(quizId);
          return;
        }
      }

      // Final fallback to direct JSON file
      try {
        print('🔄 Trying to load direct JSON file');
        await _loadFromDirectJsonFile(quizId, fileName);
        return;
      } catch (e) {
        print('❌ Failed to load direct JSON file: $e');
        questions = _getDefaultQuestions();
        print('⚠️ Using default questions');
      }
    } catch (e) {
      print('❌ All loading methods failed: $e');
      questions = _getDefaultQuestions();
    }
  }

  String _getQuestionFileName() {
    return _isEnglish ? 'assets/enquestions.json' : 'assets/questions.json';
  }

  Future<void> _loadBanglaQuestions(String quizId) async {
    try {
      final String localResponse = await rootBundle.loadString(
        'assets/questions.json',
      );
      final Map<String, dynamic> localData = json.decode(localResponse);
      _setQuestionsFromMap(localData, quizId);
      print('✅ Questions loaded from Bangla file as fallback');
    } catch (e) {
      print('❌ Failed to load Bangla questions: $e');
      questions = _getDefaultQuestions();
    }
  }

  Future<void> _loadFromDirectJsonFile(String quizId, String fileName) async {
    try {
      // Try different possible file paths
      final possiblePaths = [
        fileName,
        'assets/quiz/$quizId.json',
        'assets/questions/$quizId.json',
        'assets/json/$quizId.json',
        'assets/$quizId.json',
      ];

      for (final path in possiblePaths) {
        try {
          print('🔄 Trying path: $path');
          final String data = await rootBundle.loadString(path);
          final jsonData = json.decode(data);

          if (jsonData is Map && jsonData.containsKey('questions')) {
            questions = List<Map<String, dynamic>>.from(jsonData['questions']);
            print('✅ Questions loaded from: $path');
            return;
          } else if (jsonData is Map) {
            _setQuestionsFromMap(jsonData, quizId);
            print('✅ Questions loaded from: $path');
            return;
          }
        } catch (e) {
          print('❌ Failed to load from $path: $e');
          continue;
        }
      }

      throw Exception('All direct file paths failed');
    } catch (e) {
      rethrow;
    }
  }

  void _setQuestionsFromMap(Map<dynamic, dynamic> questionsMap, String quizId) {
    print('🔍 Searching for quizId: $quizId in questions map');

    // Convert keys to strings for safe access
    final availableKeys = questionsMap.keys.map((k) => k.toString()).toList();
    print('📋 Available keys in questions map: $availableKeys');

    // Try the exact quizId first (convert to string for comparison)
    final quizIdString = quizId.toString();
    if (questionsMap.containsKey(quizIdString)) {
      final questionsData = questionsMap[quizIdString];
      if (questionsData is List) {
        questions = List<dynamic>.from(questionsData);
        print(
          '✅ Found questions with exact key: $quizIdString (${questions.length} questions)',
        );
        return;
      } else {
        print(
          '❌ Key $quizIdString exists but is not a List: ${questionsData.runtimeType}',
        );
      }
    }

    // If no specific key found, try to find any matching category
    for (final key in questionsMap.keys) {
      final keyString = key.toString();
      if (keyString.toLowerCase().contains(quizIdString.toLowerCase()) ||
          quizIdString.toLowerCase().contains(keyString.toLowerCase())) {
        final questionsData = questionsMap[key];
        if (questionsData is List) {
          questions = List<dynamic>.from(questionsData);
          print(
            '✅ Found similar questions with key: $keyString (${questions.length} questions)',
          );
          return;
        }
      }
    }

    // If still no questions found, use default questions
    print(
      '❌ No questions found for quizId: $quizIdString, using default questions',
    );
    questions = _getDefaultQuestions();
  }

  // Add a method to set language
  void setLanguage(bool isEnglish) {
    _isEnglish = isEnglish;
    print('🌐 Language set to: ${isEnglish ? 'English' : 'Bangla'}');
  }

  // ... rest of your existing methods (checkAnswer, _calculatePoints, etc.) remain the same
  List<dynamic> _getDefaultQuestions() {
    return [
      {
        'question': _isEnglish
            ? 'What is the first pillar of Islam?'
            : 'ইসলামের প্রথম রুকন কী?',
        'options': _isEnglish
            ? ['Prayer', 'Fasting', 'Shahada', 'Hajj']
            : ['নামাজ', 'রোজা', 'কালিমা', 'হজ্জ'],
        'answer': _isEnglish ? 'Shahada' : 'কালিমা',
        'image': null,
      },
      {
        'question': _isEnglish
            ? 'How many daily prayers are obligatory?'
            : 'দৈনিক কত ওয়াক্ত নামাজ ফরজ?',
        'options': _isEnglish
            ? ['3 times', '4 times', '5 times', '6 times']
            : ['৩ ওয়াক্ত', '৪ ওয়াক্ত', '৫ ওয়াক্ত', '৬ ওয়াক্ত'],
        'answer': _isEnglish ? '5 times' : '৫ ওয়াক্ত',
        'image': null,
      },
    ];
  }

  // ==================== OPTIMIZED ANSWER VALIDATION & SECURITY ====================
  AnswerResult checkAnswer({
    required String selected,
    required int currentQuestionIndex,
    required int timeLeft,
  }) {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return AnswerResult(isCorrect: false, earnedPoints: 0);
    }

    final question = questions[currentQuestionIndex];
    final isCorrect = selected == question['answer'];

    int pointsForThisQuestion = _calculatePoints(isCorrect, timeLeft);

    if (isCorrect) {
      score++;
      _totalCorrectAnswers++;
    }

    _totalQuestionsAnswered++;
    _totalEarnedPoints += pointsForThisQuestion;
    _totalPointsEarned += pointsForThisQuestion;

    // Add points to user account
    _addPointsToUser(pointsForThisQuestion);

    // Update quiz stats
    _updateUserStats();

    // Mark quiz as completed if it's the last question
    if (currentQuestionIndex == questions.length - 1) {
      _markQuizAsCompleted();
    }

    return AnswerResult(
      isCorrect: isCorrect,
      earnedPoints: pointsForThisQuestion,
    );
  }

  int _calculatePoints(bool isCorrect, int timeLeft) {
    if (!isCorrect) {
      return 1; // Participation points
    }

    // Points based on time left
    if (timeLeft >= 15) {
      return 10;
    } else if (timeLeft >= 10) {
      return 8;
    } else if (timeLeft >= 5) {
      return 5;
    } else {
      return 3;
    }
  }

  // ==================== OPTIMIZED POINTS MANAGEMENT ====================
  Future<void> _addPointsToUser(int earnedPoints) async {
    try {
      // Security check: Validate points amount
      if (earnedPoints < 0 || earnedPoints > 100) {
        print('⚠️ Suspicious points amount: $earnedPoints');
        return;
      }

      await PointManager.addPoints(earnedPoints);
      print("✅ $earnedPoints points added successfully!");

      // Use a callback instead of setState
      pointsAdded = true;
    } catch (e) {
      print("❌ Error adding points: $e");
    }
  }

  Future<void> _updateUserStats() async {
    try {
      await PointManager.updateQuizStats(score);
      print("✅ Quiz stats updated: $score correct answers");
    } catch (e) {
      print("❌ Error updating stats: $e");
    }
  }

  Future<void> _markQuizAsCompleted() async {
    try {
      // You can add quizId parameter when needed
      await PointManager.markQuizPlayed('default_quiz_id', _totalEarnedPoints);
      print('✅ Quiz marked as completed with $_totalEarnedPoints points');
    } catch (e) {
      print('❌ Error marking quiz: $e');
    }
  }

  Future<void> _initializeUserStats() async {
    try {
      // Initialize user statistics
      _totalQuestionsAnswered = 0;
      _totalCorrectAnswers = 0;
      _totalPointsEarned = 0;

      print('✅ User stats initialized');
    } catch (e) {
      print('❌ Error initializing user stats: $e');
    }
  }

  // ==================== SECURITY CHECKS ====================
  bool validateQuestionIndex(int index) {
    return index >= 0 && index < questions.length;
  }

  bool validateAnswerFormat(dynamic question) {
    if (question is! Map<String, dynamic>) return false;
    if (question['question'] is! String) return false;
    if (question['options'] is! List<dynamic>) return false;
    if (question['answer'] is! String) return false;

    // Check if answer is in options
    final options = List<String>.from(question['options']);
    return options.contains(question['answer']);
  }

  // ==================== EXTERNAL SERVICES ====================
  Future<void> searchOnGoogle({
    required BuildContext context,
    required String question,
  }) async {
    try {
      final bool? shouldSearch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'গুগলে সার্চ করুন',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'আপনি কি "$question" প্রশ্নটি গুগলে সার্চ করতে চান?',
            style: const TextStyle(fontSize: 14, height: 1.4),
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('সার্চ করুন'),
            ),
          ],
        ),
      );

      if (shouldSearch == true) {
        final encodedQuestion = Uri.encodeComponent('$question ইসলামিক প্রশ্ন');
        final url = 'https://www.google.com/search?q=$encodedQuestion';

        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          _showErrorSnackBar(context, 'গুগল সার্চ খোলা যাচ্ছে না');
        }
      }
    } catch (e) {
      print('❌ Google search error: $e');
      _showErrorSnackBar(context, 'গুগল সার্চ খুলতে ত্রুটি');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==================== CATEGORY MAPPING UTILITIES ====================
  String getMappedQuizId(String category) {
    return _categoryMappings[category] ?? category;
  }

  bool isValidCategory(String category) {
    return _categoryMappings.containsKey(category);
  }

  List<String> getAvailableCategories() {
    return _categoryMappings.keys.toList();
  }

  // ==================== GETTERS ====================
  int get totalQuestions => questions.length;

  int get totalScore => score;

  int calculateTotalPoints() => _totalEarnedPoints;

  // For statistics
  int get totalQuestionsAnswered => _totalQuestionsAnswered;

  int get totalCorrectAnswers => _totalCorrectAnswers;

  int get totalPointsEarned => _totalPointsEarned;

  double get accuracyRate => _totalQuestionsAnswered > 0
      ? (_totalCorrectAnswers / _totalQuestionsAnswered) * 100
      : 0.0;

  // ==================== DEBUGGING UTILITIES ====================
  void printDebugInfo(String category, String quizId) {
    print('=== MCQ SECURITY MANAGER DEBUG INFO ===');
    print('📝 Category: $category');
    print('🔑 Quiz ID: $quizId');
    print('🗺️ Mapped Quiz ID: ${getMappedQuizId(category)}');
    print('📊 Questions Loaded: ${questions.length}');
    print('✅ Valid Category: ${isValidCategory(category)}');
    print('=== END DEBUG INFO ===');
  }

  // ==================== CLEANUP ====================
  void dispose() {
    // Clean up any resources if needed
    questions.clear();
    score = 0;
    _totalEarnedPoints = 0;
    pointsAdded = false;
  }
}
