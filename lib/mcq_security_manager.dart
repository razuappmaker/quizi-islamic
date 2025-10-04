// mcq_security_manager.dart - COMPLETELY FIXED VERSION
// mcq_security_manager.dart - COMPLETELY FIXED VERSION
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
  bool quizStarted = false; // 🔧 FIX: Start as false

  // Points System
  int _totalEarnedPoints = 0;
  bool pointsAdded = false;

  // User Statistics
  int _totalQuestionsAnswered = 0;
  int _totalCorrectAnswers = 0;
  int _totalPointsEarned = 0;

  // Language
  bool _isEnglish = false;

  // Current Quiz ID for security tracking
  String _currentQuizId = '';

  // Category Mapping
  final Map<String, String> _categoryMappings = {
    // English categories
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

    // Bengali categories
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

  // 🔧 FIXED: Strict initialization with security check
  // MCQSecurityManager.dart - STRICT INITIALIZATION
  // MCQSecurityManager.dart - initialize মেথডে এড করুন
  Future<void> initialize({
    required String category,
    required String quizId,
  }) async {
    try {
      print('🔄 STRICT QUIZ INITIALIZATION STARTED...');

      // Use consistent quiz ID mapping
      final String mappedQuizId = getMappedQuizId(category);
      _currentQuizId = mappedQuizId;

      print('📝 Category: $category');
      print('🔑 Original Quiz ID: $quizId');
      print('🗺️ Mapped Quiz ID: $mappedQuizId');

      // 🔒 STRICT SECURITY CHECK with detailed logging
      print('🔒 Running strict security check...');
      final canPlayResult = await PointManager.canPlayQuiz(mappedQuizId);

      print('🔍 Security Check Result:');
      print('   - Can Play: ${canPlayResult['canPlay']}');
      print('   - Reason: ${canPlayResult['reason']}');
      print('   - Message: ${canPlayResult['message']}');

      if (!canPlayResult['canPlay']) {
        final String errorMessage =
            canPlayResult['message'] ?? 'কুইজ খেলা যাবে না';
        final String reason = canPlayResult['reason'] ?? 'অজানা কারণ';

        print('🚫 SECURITY BLOCKED: $reason - $errorMessage');
        throw Exception('$reason: $errorMessage');
      }

      print('✅ Security check passed, loading questions...');

      // Load questions with consistent ID
      await loadQuestions(mappedQuizId);

      if (questions.isEmpty) {
        throw Exception('কোন প্রশ্ন লোড করা যায়নি');
      }

      // 🔥 RECORD QUIZ START IMMEDIATELY
      await _recordQuizStart();

      // Initialize stats
      await _initializeUserStats();

      // Mark quiz as started ONLY after all checks pass
      quizStarted = true;

      print('✅ STRICT INITIALIZATION COMPLETED');
      print('📊 Questions loaded: ${questions.length}');
    } catch (e) {
      print('❌ STRICT INITIALIZATION FAILED: $e');

      // Clear everything on failure
      quizStarted = false;
      questions = [];
      score = 0;
      _totalEarnedPoints = 0;

      rethrow;
    }
  }

  // MCQSecurityManager.dart - নিচের মেথডটি এড করুন
  Future<void> _recordQuizStart() async {
    try {
      if (_currentQuizId.isEmpty) {
        print('🚫 Cannot record quiz start: No quiz ID');
        return;
      }

      print('📝 Recording quiz START: $_currentQuizId');

      // Record quiz start with 0 points
      await PointManager.recordQuizPlay(
        quizId: _currentQuizId,
        pointsEarned: 0, // Start with 0 points
        correctAnswers: 0,
        totalQuestions: questions.length,
      );

      print('✅ Quiz start recorded successfully');
    } catch (e) {
      print('❌ Error recording quiz start: $e');
    }
  }

  // 🔥 NEW: IMMEDIATE QUIZ PLAY RECORDING
  Future<void> _recordQuizPlayImmediately() async {
    try {
      if (_currentQuizId.isEmpty) {
        print('🚫 Cannot record quiz: No quiz ID');
        return;
      }

      print('📝 IMMEDIATE Quiz play recording: $_currentQuizId');

      // Record with 0 points initially (will update later)
      await PointManager.recordQuizPlay(
        quizId: _currentQuizId,
        pointsEarned: 0, // Initial record
        correctAnswers: 0,
        totalQuestions: questions.length,
      );

      print('✅ IMMEDIATE Quiz play recorded');
    } catch (e) {
      print('❌ Error in immediate quiz recording: $e');
    }
  }

  // 🔧 FIXED: Answer checking with proper security
  AnswerResult checkAnswer({
    required String selected,
    required int currentQuestionIndex,
    required int timeLeft,
  }) {
    // Security checks
    if (!quizStarted ||
        questions.isEmpty ||
        currentQuestionIndex >= questions.length) {
      print('🚫 Security: Invalid answer attempt');
      return AnswerResult(isCorrect: false, earnedPoints: 0);
    }

    final question = questions[currentQuestionIndex];

    // Validate question format
    if (!validateAnswerFormat(question)) {
      print('🚫 Security: Invalid question format');
      return AnswerResult(isCorrect: false, earnedPoints: 0);
    }

    final isCorrect = selected == question['answer'];
    int pointsForThisQuestion = _calculatePoints(isCorrect, timeLeft);

    print(
      '🎯 Answer checked: Correct=$isCorrect, Points=$pointsForThisQuestion',
    );

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
      print('🏁 Quiz completed, recording play...');
      _markQuizAsCompleted();
    }

    return AnswerResult(
      isCorrect: isCorrect,
      earnedPoints: pointsForThisQuestion,
    );
  }

  // 🔧 FIXED: Mark quiz as completed with proper recording
  Future<void> _markQuizAsCompleted() async {
    try {
      if (_currentQuizId.isEmpty) {
        print('🚫 Cannot mark quiz completed: No quiz ID');
        return;
      }

      print('📝 Recording quiz completion: $_currentQuizId');

      await PointManager.recordQuizPlay(
        quizId: _currentQuizId,
        pointsEarned: _totalEarnedPoints,
        correctAnswers: score,
        totalQuestions: questions.length,
      );

      print(
        '✅ Quiz marked as completed: $_totalEarnedPoints points, $score correct',
      );
    } catch (e) {
      print('❌ Error marking quiz as completed: $e');
      // Don't throw - we don't want to break the UI flow
    }
  }

  // 🔧 FIXED: Points calculation
  int _calculatePoints(bool isCorrect, int timeLeft) {
    if (!isCorrect) {
      return 1; // Participation points
    }

    // Points based on time left
    if (timeLeft >= 15)
      return 10;
    else if (timeLeft >= 10)
      return 8;
    else if (timeLeft >= 5)
      return 5;
    else
      return 3;
  }

  // 🔧 FIXED: Add points with validation
  Future<void> _addPointsToUser(int earnedPoints) async {
    try {
      // Security check: Validate points amount
      if (earnedPoints < 0 || earnedPoints > 100) {
        print('⚠️ Suspicious points amount: $earnedPoints');
        return;
      }

      await PointManager.addPoints(earnedPoints);
      print("✅ $earnedPoints points added to user account");
    } catch (e) {
      print("❌ Error adding points: $e");
    }
  }

  // 🔧 FIXED: Update user stats
  Future<void> _updateUserStats() async {
    try {
      await PointManager.updateQuizStats(score);
      print("✅ Quiz stats updated: $score correct answers");
    } catch (e) {
      print("❌ Error updating stats: $e");
    }
  }

  // 🔧 FIXED: Initialize user stats
  Future<void> _initializeUserStats() async {
    try {
      _totalQuestionsAnswered = 0;
      _totalCorrectAnswers = 0;
      _totalPointsEarned = 0;
      score = 0;
      _totalEarnedPoints = 0;

      print('✅ User stats initialized');
    } catch (e) {
      print('❌ Error initializing user stats: $e');
    }
  }

  // Existing methods remain but ensure they don't bypass security
  Future<void> loadQuestions(String quizId) async {
    try {
      print('🔄 Loading questions for: $quizId');

      final String fileName = _isEnglish
          ? 'assets/enquestions.json'
          : 'assets/questions.json';
      print('📁 Loading from: $fileName');

      // Try network first
      try {
        final List<dynamic> allQuestionsData =
            await NetworkJsonLoader.loadJsonList(fileName);
        if (allQuestionsData is List && allQuestionsData.isNotEmpty) {
          Map<dynamic, dynamic> questionsMap = {};
          for (var item in allQuestionsData) {
            if (item is Map) questionsMap.addAll(item as Map<dynamic, dynamic>);
          }
          _setQuestionsFromMap(questionsMap, quizId);
          print('✅ Questions loaded from network');
          return;
        }
      } catch (e) {
        print('❌ Network load failed: $e');
      }

      // Fallback to local
      try {
        final String localResponse = await rootBundle.loadString(fileName);
        final Map<dynamic, dynamic> localData = json.decode(localResponse);
        _setQuestionsFromMap(localData, quizId);
        print('✅ Questions loaded from local');
        return;
      } catch (e) {
        print('❌ Local load failed: $e');
      }

      // If all loading methods fail, throw exception
      throw Exception('প্রশ্ন লোড করা যায়নি');
    } catch (e) {
      print('❌ All question loading methods failed: $e');
      rethrow;
    }
  }

  void _setQuestionsFromMap(Map<dynamic, dynamic> questionsMap, String quizId) {
    print('🔍 Searching for quiz: $quizId');

    final quizIdString = quizId.toString();
    final availableKeys = questionsMap.keys.map((k) => k.toString()).toList();
    print('📋 Available keys: $availableKeys');

    // Try exact match first
    if (questionsMap.containsKey(quizIdString)) {
      final questionsData = questionsMap[quizIdString];
      if (questionsData is List) {
        questions = List<dynamic>.from(questionsData);
        print('✅ Exact match found: ${questions.length} questions');
        return;
      }
    }

    // Try partial match
    for (final key in questionsMap.keys) {
      final keyString = key.toString();
      if (keyString.toLowerCase().contains(quizIdString.toLowerCase()) ||
          quizIdString.toLowerCase().contains(keyString.toLowerCase())) {
        final questionsData = questionsMap[key];
        if (questionsData is List) {
          questions = List<dynamic>.from(questionsData);
          print('✅ Partial match found: ${questions.length} questions');
          return;
        }
      }
    }

    // No questions found
    throw Exception('এই ক্যাটাগরির জন্য কোন প্রশ্ন পাওয়া যায়নি');
  }

  // Security validation methods
  bool validateQuestionIndex(int index) {
    return index >= 0 && index < questions.length;
  }

  bool validateAnswerFormat(dynamic question) {
    if (question is! Map<String, dynamic>) return false;
    if (question['question'] is! String) return false;
    if (question['options'] is! List<dynamic>) return false;
    if (question['answer'] is! String) return false;

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
  // Getters
  int get totalQuestions => questions.length;

  int get totalScore => score;

  int calculateTotalPoints() => _totalEarnedPoints;

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
  // Cleanup
  void dispose() {
    questions.clear();
    score = 0;
    _totalEarnedPoints = 0;
    pointsAdded = false;
    quizStarted = false;
  }
}
