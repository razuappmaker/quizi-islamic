// mcq_security_manager.dart - FINAL CLEAN VERSION
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
  // ==================== QUIZ DATA ====================
  List<dynamic> questions = [];
  int score = 0;
  bool quizStarted = false;

  // ==================== POINTS SYSTEM ====================
  int _totalEarnedPoints = 0;
  bool pointsAdded = false;
  bool _quizRecorded = false;

  // ==================== USER STATISTICS ====================
  int _totalQuestionsAnswered = 0;
  int _totalCorrectAnswers = 0;
  int _totalPointsEarned = 0;

  // ==================== LANGUAGE ====================
  bool _isEnglish = false;

  // ==================== CURRENT QUIZ ID ====================
  String _currentQuizId = '';

  // ==================== CATEGORY MAPPING ====================
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

  // ==================== INITIALIZATION ====================

  /// কুইজ ইনিশিয়ালাইজেশন মেথড
  Future<void> initialize({
    required String category,
    required String quizId,
  }) async {
    try {
      print('🔄 QUIZ INITIALIZATION STARTED...');

      final String mappedQuizId = getMappedQuizId(category);
      _currentQuizId = mappedQuizId;

      print('📝 Category: $category → Mapped: $mappedQuizId');

      // Security check
      final canPlayResult = await PointManager.canPlayQuiz(mappedQuizId);

      print('🔍 Security Check Result:');
      print('   - Can Play: ${canPlayResult['canPlay']}');
      print('   - Reason: ${canPlayResult['reason']}');
      print('   - Remaining Points: ${canPlayResult['remainingPoints']}');

      if (!canPlayResult['canPlay']) {
        final String errorMessage =
            canPlayResult['message'] ?? 'কুইজ খেলা যাবে না';
        final String reason = canPlayResult['reason'] ?? 'অজানা কারণ';
        throw Exception('$reason: $errorMessage');
      }

      // Load questions
      await loadQuestions(mappedQuizId);

      if (questions.isEmpty) {
        throw Exception('কোন প্রশ্ন লোড করা যায়নি');
      }

      // Initialize stats
      await _initializeUserStats();

      quizStarted = true;
      _quizRecorded = false;

      print('✅ INITIALIZATION COMPLETED - Questions: ${questions.length}');
    } catch (e) {
      print('❌ INITIALIZATION FAILED: $e');
      _resetQuizState();
      rethrow;
    }
  }

  // ==================== ANSWER CHECKING ====================

  /// উত্তর চেক করার মেথড
  AnswerResult checkAnswer({
    required String selected,
    required int currentQuestionIndex,
    required int timeLeft,
  }) {
    // Security checks
    if (!quizStarted ||
        questions.isEmpty ||
        currentQuestionIndex >= questions.length) {
      return AnswerResult(isCorrect: false, earnedPoints: 0);
    }

    final question = questions[currentQuestionIndex];

    if (!validateAnswerFormat(question)) {
      return AnswerResult(isCorrect: false, earnedPoints: 0);
    }

    final isCorrect = selected == question['answer'];
    int pointsForThisQuestion = _calculatePoints(isCorrect, timeLeft);

    print('🎯 Answer: Correct=$isCorrect, Points=$pointsForThisQuestion');

    // Update scores
    if (isCorrect) {
      score++;
      _totalCorrectAnswers++;
    }

    _totalQuestionsAnswered++;
    _totalEarnedPoints += pointsForThisQuestion;
    _totalPointsEarned += pointsForThisQuestion;

    // 🔥 CRITICAL FIX: Record quiz play ONLY on first answer
    if (!_quizRecorded) {
      _recordQuizPlay();
      _quizRecorded = true;
    } else {
      // 🔥 শুধুমাত্র আপডেট করবে, নতুন করে পয়েন্ট যোগ করবে না
      _updateQuizRecord();
    }

    // Add points and update stats
    //_addPointsToUser(pointsForThisQuestion);
    _updateUserStats();

    // Finalize if last question
    if (currentQuestionIndex == questions.length - 1) {
      _finalizeQuiz();
    }

    return AnswerResult(
      isCorrect: isCorrect,
      earnedPoints: pointsForThisQuestion,
    );
  }

  // ==================== POINTS MANAGEMENT ====================

  /// পয়েন্ট ক্যালকুলেশন মেথড
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

  /// ইউজার অ্যাকাউন্টে পয়েন্ট যোগ করার মেথড
  /*Future<void> _addPointsToUser(int earnedPoints) async {
    try {
      // Security checks
      if (earnedPoints <= 0 || earnedPoints > 100) {
        print('⚠️ Invalid points amount: $earnedPoints');
        return;
      }

      // 🔥 Check daily limit BEFORE adding points
      final totalPointsToday = await PointManager.getTotalPointsToday();
      if (totalPointsToday >= PointManager.MAX_POINTS_PER_DAY) {
        print('🚫 Daily points limit reached, skipping points addition');
        return;
      }

      // 🔥 Ensure we don't exceed daily limit
      int pointsToAdd = earnedPoints;
      if (totalPointsToday + earnedPoints > PointManager.MAX_POINTS_PER_DAY) {
        pointsToAdd = PointManager.MAX_POINTS_PER_DAY - totalPointsToday;
        print(
          '🎯 Capping points: $earnedPoints → $pointsToAdd (to stay within daily limit)',
        );
      }

      // Add points
      if (pointsToAdd > 0) {
        await PointManager.addPoints(pointsToAdd);
        print("✅ $pointsToAdd points added to user account");
      } else {
        print('⏭️ No points added (Daily limit reached)');
      }
    } catch (e) {
      print("❌ Error adding points: $e");
    }
  }*/

  // ==================== QUIZ RECORDING ====================

  /// কুইজ খেলা রেকর্ড করার মেথড
  Future<void> _recordQuizPlay() async {
    try {
      if (_currentQuizId.isEmpty) return;

      await PointManager.recordQuizPlay(
        quizId: _currentQuizId,
        pointsEarned: _totalEarnedPoints,
        correctAnswers: score,
        totalQuestions: questions.length,
      );

      print('✅ Quiz play recorded with ${_totalEarnedPoints} points');
    } catch (e) {
      print('❌ Error recording quiz play: $e');
    }
  }

  /// কুইজ রেকর্ড আপডেট করার মেথড
  Future<void> _updateQuizRecord() async {
    try {
      if (_currentQuizId.isEmpty || !_quizRecorded) return;

      await PointManager.recordQuizPlay(
        quizId: _currentQuizId,
        pointsEarned: _totalEarnedPoints,
        correctAnswers: score,
        totalQuestions: questions.length,
      );

      print('✅ Quiz record updated with ${_totalEarnedPoints} points');
    } catch (e) {
      print('❌ Error updating quiz record: $e');
    }
  }

  /// কুইজ ফাইনালাইজ করার মেথড
  Future<void> _finalizeQuiz() async {
    try {
      if (_currentQuizId.isEmpty) return;

      await PointManager.recordQuizPlay(
        quizId: _currentQuizId,
        pointsEarned: _totalEarnedPoints,
        correctAnswers: score,
        totalQuestions: questions.length,
      );

      print(
        '✅ Quiz finalized - Total Points: $_totalEarnedPoints, Correct: $score',
      );
    } catch (e) {
      print('❌ Error finalizing quiz: $e');
    }
  }

  // ==================== USER STATS MANAGEMENT ====================

  /// ইউজার স্ট্যাটস আপডেট করার মেথড
  Future<void> _updateUserStats() async {
    try {
      await PointManager.updateQuizStats(score);
    } catch (e) {
      print("❌ Error updating stats: $e");
    }
  }

  /// ইউজার স্ট্যাটস ইনিশিয়ালাইজ করার মেথড
  Future<void> _initializeUserStats() async {
    _totalQuestionsAnswered = 0;
    _totalCorrectAnswers = 0;
    _totalPointsEarned = 0;
    score = 0;
    _totalEarnedPoints = 0;
    _quizRecorded = false;
  }

  /// কুইজ স্টেট রিসেট করার মেথড
  void _resetQuizState() {
    quizStarted = false;
    questions = [];
    score = 0;
    _totalEarnedPoints = 0;
    _quizRecorded = false;
  }

  // ==================== QUESTION LOADING ====================

  /// প্রশ্ন লোড করার মেথড
  Future<void> loadQuestions(String quizId) async {
    try {
      final String fileName = _isEnglish
          ? 'assets/enquestions.json'
          : 'assets/questions.json';

      // Try network first
      try {
        final List<dynamic> allQuestionsData =
            await NetworkJsonLoader.loadJsonList(fileName);
        if (allQuestionsData.isNotEmpty) {
          Map<dynamic, dynamic> questionsMap = {};
          for (var item in allQuestionsData) {
            if (item is Map) questionsMap.addAll(item as Map<dynamic, dynamic>);
          }
          _setQuestionsFromMap(questionsMap, quizId);
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
        return;
      } catch (e) {
        print('❌ Local load failed: $e');
      }

      throw Exception('প্রশ্ন লোড করা যায়নি');
    } catch (e) {
      print('❌ All question loading methods failed: $e');
      rethrow;
    }
  }

  /// ম্যাপ থেকে প্রশ্ন সেট করার মেথড
  void _setQuestionsFromMap(Map<dynamic, dynamic> questionsMap, String quizId) {
    final quizIdString = quizId.toString();
    final availableKeys = questionsMap.keys.map((k) => k.toString()).toList();

    // Exact match
    if (questionsMap.containsKey(quizIdString)) {
      final questionsData = questionsMap[quizIdString];
      if (questionsData is List) {
        questions = List<dynamic>.from(questionsData);
        return;
      }
    }

    // Partial match
    for (final key in questionsMap.keys) {
      final keyString = key.toString();
      if (keyString.toLowerCase().contains(quizIdString.toLowerCase()) ||
          quizIdString.toLowerCase().contains(keyString.toLowerCase())) {
        final questionsData = questionsMap[key];
        if (questionsData is List) {
          questions = List<dynamic>.from(questionsData);
          return;
        }
      }
    }

    throw Exception('এই ক্যাটাগরির জন্য কোন প্রশ্ন পাওয়া যায়নি');
  }

  // ==================== VALIDATION METHODS ====================

  /// প্রশ্ন ইন্ডেক্স ভ্যালিডেশন মেথড
  bool validateQuestionIndex(int index) {
    return index >= 0 && index < questions.length;
  }

  /// উত্তর ফরম্যাট ভ্যালিডেশন মেথড
  bool validateAnswerFormat(dynamic question) {
    if (question is! Map<String, dynamic>) return false;
    if (question['question'] is! String) return false;
    if (question['options'] is! List<dynamic>) return false;
    if (question['answer'] is! String) return false;

    final options = List<String>.from(question['options']);
    return options.contains(question['answer']);
  }

  // ==================== EXTERNAL SERVICES ====================

  /// গুগলে সার্চ করার মেথড
  Future<void> searchOnGoogle({
    required BuildContext context,
    required String question,
  }) async {
    try {
      final bool? shouldSearch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('গুগলে সার্চ করুন'),
          content: Text('আপনি কি "$question" প্রশ্নটি গুগলে সার্চ করতে চান?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
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

  /// এরর স্ন্যাকবার দেখানোর মেথড
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== CATEGORY UTILITIES ====================

  /// ক্যাটাগরি ম্যাপিং মেথড
  String getMappedQuizId(String category) {
    return _categoryMappings[category] ?? category;
  }

  /// ভ্যালিড ক্যাটাগরি চেক মেথড
  bool isValidCategory(String category) {
    return _categoryMappings.containsKey(category);
  }

  /// অ্যাভেইলেবল ক্যাটাগরি লিস্ট মেথড
  List<String> getAvailableCategories() {
    return _categoryMappings.keys.toList();
  }

  // ==================== GETTERS ====================

  int get totalQuestions => questions.length;

  int get totalScore => score;

  int get totalQuestionsAnswered => _totalQuestionsAnswered;

  int get totalCorrectAnswers => _totalCorrectAnswers;

  int get totalPointsEarned => _totalPointsEarned;

  int calculateTotalPoints() => _totalEarnedPoints;

  double get accuracyRate => _totalQuestionsAnswered > 0
      ? (_totalCorrectAnswers / _totalQuestionsAnswered) * 100
      : 0.0;

  // ==================== DEBUGGING UTILITIES ====================

  // TODO: Remove debug methods after testing
  /*
  Future<void> _debugPointsStatus() async {
    try {
      final totalPointsToday = await PointManager.getTotalPointsToday();
      print('🔍 DEBUG POINTS STATUS:');
      print('   - MAX_POINTS_PER_DAY: ${PointManager.MAX_POINTS_PER_DAY}');
      print('   - Total Points Today: $totalPointsToday');
      print('   - Remaining Points: ${PointManager.MAX_POINTS_PER_DAY - totalPointsToday}');
    } catch (e) {
      print('❌ Error checking points status: $e');
    }
  }

  void printDebugInfo(String category, String quizId) {
    print('=== MCQ SECURITY MANAGER DEBUG INFO ===');
    print('📝 Category: $category');
    print('🔑 Quiz ID: $quizId');
    print('🗺️ Mapped Quiz ID: ${getMappedQuizId(category)}');
    print('📊 Questions Loaded: ${questions.length}');
    print('✅ Valid Category: ${isValidCategory(category)}');
    print('🎯 Quiz Started: $quizStarted');
    print('📝 Quiz Recorded: $_quizRecorded');
    print('💰 Total Earned Points: $_totalEarnedPoints');
    print('=== END DEBUG INFO ===');
  }
  */

  // ==================== CLEANUP ====================

  /// ডিসপোজ মেথড
  void dispose() {
    questions.clear();
    score = 0;
    _totalEarnedPoints = 0;
    pointsAdded = false;
    quizStarted = false;
    _quizRecorded = false;
  }
}
