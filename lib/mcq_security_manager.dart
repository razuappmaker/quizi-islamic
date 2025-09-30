// mcq_security_manager.dart - Security & Data Management
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

  Future<void> initialize({
    required String category,
    required String quizId,
  }) async {
    try {
      await loadQuestions(category);
      await _initializeUserStats();
      print('✅ MCQ Security Manager initialized for category: $category');
    } catch (e) {
      print('❌ Error initializing MCQ Security Manager: $e');
      questions = _getDefaultQuestions();
    }
  }

  // ==================== QUESTION LOADING ====================
  Future<void> loadQuestions(String category) async {
    try {
      print('🔄 Loading questions for category: $category');

      final List<dynamic> allQuestionsData =
          await NetworkJsonLoader.loadJsonList('assets/questions.json');

      if (allQuestionsData is List && allQuestionsData.isNotEmpty) {
        Map<String, dynamic> questionsMap = {};

        for (var item in allQuestionsData) {
          if (item is Map<String, dynamic>) {
            questionsMap.addAll(item);
          }
        }

        setQuestionsFromMap(questionsMap, category);
        print('✅ Questions loaded successfully from network');
        return;
      } else if (allQuestionsData is Map) {
        setQuestionsFromMap(allQuestionsData as Map<String, dynamic>, category);
        print('✅ Questions loaded successfully from network');
        return;
      }
    } catch (e) {
      print('❌ Failed to load from network: $e');
    }

    try {
      print('🔄 Trying to load from local asset');
      final String localResponse = await rootBundle.loadString(
        'assets/questions.json',
      );
      final Map<String, dynamic> localData = json.decode(localResponse);
      setQuestionsFromMap(localData, category);
      print('✅ Questions loaded successfully from local asset');
    } catch (e) {
      print('❌ Failed to load from local asset: $e');
      questions = _getDefaultQuestions();
      print('⚠️ Using default questions');
    }
  }

  void setQuestionsFromMap(Map<String, dynamic> questionsMap, String category) {
    questions = questionsMap[category] ?? [];
    if (questions.isEmpty) {
      questions = _getDefaultQuestions();
    }
  }

  List<dynamic> _getDefaultQuestions() {
    return [
      {
        'question': 'ইসলামের প্রথম রুকন কী?',
        'options': ['নামাজ', 'রোজা', 'কালিমা', 'হজ্জ'],
        'answer': 'কালিমা',
        'image': null,
      },
      {
        'question': 'দৈনিক কত ওয়াক্ত নামাজ ফরজ?',
        'options': ['৩ ওয়াক্ত', '৪ ওয়াক্ত', '৫ ওয়াক্ত', '৬ ওয়াক্ত'],
        'answer': '৫ ওয়াক্ত',
        'image': null,
      },
      {
        'question': 'কুরআন মজীদে কতটি সূরা আছে?',
        'options': ['১০০ সূরা', '১১০ সূরা', '১১৪ সূরা', '১২০ সূরা'],
        'answer': '১১৪ সূরা',
        'image': null,
      },
    ];
  }

  // ==================== ANSWER VALIDATION & SECURITY ====================
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

  // ==================== POINTS MANAGEMENT ====================
  Future<void> _addPointsToUser(int earnedPoints) async {
    try {
      // Security check: Validate points amount
      if (earnedPoints < 0 || earnedPoints > 100) {
        print('⚠️ Suspicious points amount: $earnedPoints');
        return;
      }

      await PointManager.addPoints(earnedPoints);
      print("$earnedPoints points added successfully!");

      setState(() {
        pointsAdded = true;
      });
    } catch (e) {
      print("Error adding points: $e");
    }
  }

  Future<void> _updateUserStats() async {
    try {
      await PointManager.updateQuizStats(score);
      print("Quiz stats updated: $score correct answers");
    } catch (e) {
      print("Error updating stats: $e");
    }
  }

  Future<void> _markQuizAsCompleted() async {
    try {
      // You can add quizId parameter when needed
      await PointManager.markQuizPlayed('default_quiz_id', _totalEarnedPoints);
      print('Quiz marked as completed with $_totalEarnedPoints points');
    } catch (e) {
      print('Error marking quiz: $e');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          _showErrorSnackBar(context, 'গুগল সার্চ খোলা যাচ্ছে না');
        }
      } catch (e) {
        print('URL launch error: $e');
        _showErrorSnackBar(context, 'গুগল সার্চ খুলতে ত্রুটি');
      }
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

  // ==================== STATE MANAGEMENT ====================
  void setState(VoidCallback callback) {
    callback();
  }

  // ==================== CLEANUP ====================
  void dispose() {
    // Clean up any resources if needed
    questions.clear();
    score = 0;
    _totalEarnedPoints = 0;
  }
}
