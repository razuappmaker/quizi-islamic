// mcq_security_manager.dart - FINAL CLEAN VERSION with Language Support
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'network_json_loader.dart';
import '../providers/language_provider.dart';
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
  bool get _isEnglish => _languageProvider?.isEnglish ?? false;
  LanguageProvider? _languageProvider;

  // ==================== CURRENT QUIZ ID ====================
  String _currentQuizId = '';

  // ==================== CATEGORY MAPPING ====================
  final Map<String, Map<String, String>> _categoryMappings = {
    // English categories
    'Basic Islamic Knowledge': {
      'en': 'Basic Islamic Knowledge',
      'bn': 'ইসলামী প্রাথমিক জ্ঞান',
    },
    'Quran': {'en': 'Quran', 'bn': 'কোরআন'},
    'Prophet Biography': {
      'en': 'Prophet Biography',
      'bn': 'মহানবী সঃ এর জীবনী',
    },
    'Worship': {'en': 'Worship', 'bn': 'ইবাদত'},
    'Hereafter': {'en': 'Hereafter', 'bn': 'আখিরাত'},
    'Judgment Day': {'en': 'Judgment Day', 'bn': 'বিচার দিবস'},
    'Women in Islam': {'en': 'Women in Islam', 'bn': 'নারী ও ইসলাম'},
    'Islamic Ethics & Manners': {
      'en': 'Islamic Ethics & Manners',
      'bn': 'ইসলামী নৈতিকতা ও আচার',
    },
    'Religious Law (Marriage-Divorce)': {
      'en': 'Religious Law (Marriage-Divorce)',
      'bn': 'ধর্মীয় আইন(বিবাহ-বিচ্ছেদ)',
    },
    'Etiquette': {'en': 'Etiquette', 'bn': 'শিষ্টাচার'},
    'Marital & Family Relations': {
      'en': 'Marital & Family Relations',
      'bn': 'দাম্পত্য ও পারিবারিক সম্পর্ক',
    },
    'Hadith': {'en': 'Hadith', 'bn': 'হাদিস'},
    'Prophets': {'en': 'Prophets', 'bn': 'নবী-রাসূল'},
    'Islamic History': {'en': 'Islamic History', 'bn': 'ইসলামের ইতিহাস'},
  };

  // ==================== TEXT DICTIONARY ====================
  static const Map<String, Map<String, String>> _texts = {
    'searchGoogle': {'en': 'Search on Google', 'bn': 'গুগলে সার্চ করুন'},
    'searchConfirmation': {
      'en': 'Do you want to search Google for the question:',
      'bn': 'আপনি কি "প্রশ্ন" প্রশ্নটি গুগলে সার্চ করতে চান?',
    },
    'cancel': {'en': 'Cancel', 'bn': 'বাতিল'},
    'search': {'en': 'Search', 'bn': 'সার্চ করুন'},
    'googleSearchError': {
      'en': 'Cannot open Google search',
      'bn': 'গুগল সার্চ খোলা যাচ্ছে না',
    },
    'searchError': {
      'en': 'Error opening Google search',
      'bn': 'গুগল সার্চ খুলতে ত্রুটি',
    },
    'noQuestionsLoaded': {
      'en': 'No questions loaded',
      'bn': 'কোন প্রশ্ন লোড করা যায়নি',
    },
    'noQuestionsForCategory': {
      'en': 'No questions found for this category',
      'bn': 'এই ক্যাটাগরির জন্য কোন প্রশ্ন পাওয়া যায়নি',
    },
    'questionLoadError': {
      'en': 'Questions could not be loaded',
      'bn': 'প্রশ্ন লোড করা যায়নি',
    },
    'quizNotAvailable': {'en': 'Quiz not available', 'bn': 'কুইজ খেলা যাবে না'},
    'unknownReason': {'en': 'Unknown reason', 'bn': 'অজানা কারণ'},
  };

  // ==================== HELPER METHOD ====================
  String _text(String key, BuildContext context) {
    final langKey = _isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

  // ==================== INITIALIZATION ====================

  /// কুইজ ইনিশিয়ালাইজেশন মেথড
  Future<void> initialize({
    required String category,
    required String quizId,
    required BuildContext context,
  }) async {
    try {
      print('🔄 QUIZ INITIALIZATION STARTED...');

      // Set language provider from context
      _languageProvider = Provider.of<LanguageProvider>(context, listen: false);

      final String mappedQuizId = getMappedQuizId(category, context);
      _currentQuizId = mappedQuizId;

      print('📝 Category: $category → Mapped: $mappedQuizId');
      print('🌐 Language: ${_isEnglish ? 'English' : 'Bengali'}');

      // Security check
      final canPlayResult = await PointManager.canPlayQuiz(mappedQuizId);

      print('🔍 Security Check Result:');
      print('   - Can Play: ${canPlayResult['canPlay']}');
      print('   - Reason: ${canPlayResult['reason']}');
      print('   - Remaining Points: ${canPlayResult['remainingPoints']}');

      if (!canPlayResult['canPlay']) {
        final String errorMessage =
            canPlayResult['message'] ?? _text('quizNotAvailable', context);
        final String reason =
            canPlayResult['reason'] ?? _text('unknownReason', context);
        throw Exception('$reason: $errorMessage');
      }

      // Load questions with language support
      await loadQuestions(mappedQuizId, context);

      if (questions.isEmpty) {
        throw Exception(_text('noQuestionsLoaded', context));
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

    // Update stats
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

  /// প্রশ্ন লোড করার মেথড - ভাষা অনুযায়ী
  Future<void> loadQuestions(String quizId, BuildContext context) async {
    try {
      // ভাষা অনুযায়ী JSON ফাইল সিলেক্ট করুন
      final String fileName = _isEnglish
          ? 'assets/en_questions.json'
          : 'assets/questions.json';

      print('📁 Loading questions from: $fileName');

      // Try network first
      try {
        final List<dynamic> allQuestionsData =
            await NetworkJsonLoader.loadJsonList(fileName);
        if (allQuestionsData.isNotEmpty) {
          Map<dynamic, dynamic> questionsMap = {};
          for (var item in allQuestionsData) {
            if (item is Map) questionsMap.addAll(item as Map<dynamic, dynamic>);
          }
          _setQuestionsFromMap(questionsMap, quizId, context);
          return;
        }
      } catch (e) {
        print('❌ Network load failed: $e');
      }

      // Fallback to local
      try {
        final String localResponse = await rootBundle.loadString(fileName);
        final Map<dynamic, dynamic> localData = json.decode(localResponse);
        _setQuestionsFromMap(localData, quizId, context);
        return;
      } catch (e) {
        print('❌ Local load failed: $e');
      }

      throw Exception(_text('questionLoadError', context));
    } catch (e) {
      print('❌ All question loading methods failed: $e');
      rethrow;
    }
  }

  /// ম্যাপ থেকে প্রশ্ন সেট করার মেথড
  void _setQuestionsFromMap(
    Map<dynamic, dynamic> questionsMap,
    String quizId,
    BuildContext context,
  ) {
    final quizIdString = quizId.toString();
    final availableKeys = questionsMap.keys.map((k) => k.toString()).toList();

    print('🔍 Looking for quiz ID: $quizIdString');
    print('📋 Available keys: $availableKeys');

    // Exact match
    if (questionsMap.containsKey(quizIdString)) {
      final questionsData = questionsMap[quizIdString];
      if (questionsData is List) {
        questions = List<dynamic>.from(questionsData);
        print('✅ Exact match found - Questions: ${questions.length}');
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
          print('✅ Partial match found - Questions: ${questions.length}');
          return;
        }
      }
    }

    throw Exception(_text('noQuestionsForCategory', context));
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

  /// গুগলে সার্চ করার মেথড - ভাষা অনুযায়ী
  Future<void> searchOnGoogle({
    required BuildContext context,
    required String question,
  }) async {
    try {
      final bool? shouldSearch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_text('searchGoogle', context)),
          content: Text('${_text('searchConfirmation', context)} "$question"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_text('cancel', context)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_text('search', context)),
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
          _showErrorSnackBar(context, _text('googleSearchError', context));
        }
      }
    } catch (e) {
      print('❌ Google search error: $e');
      _showErrorSnackBar(context, _text('searchError', context));
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

  /// ক্যাটাগরি ম্যাপিং মেথড - ভাষা অনুযায়ী
  String getMappedQuizId(String category, BuildContext context) {
    final langKey = _isEnglish ? 'en' : 'bn';

    // First try exact match
    if (_categoryMappings.containsKey(category)) {
      return _categoryMappings[category]![langKey] ?? category;
    }

    // Then try case-insensitive match
    for (final key in _categoryMappings.keys) {
      if (key.toLowerCase() == category.toLowerCase()) {
        return _categoryMappings[key]![langKey] ?? category;
      }
    }

    // Return original if no match found
    return category;
  }

  /// ভ্যালিড ক্যাটাগরি চেক মেথড
  bool isValidCategory(String category) {
    return _categoryMappings.containsKey(category);
  }

  /// অ্যাভেইলেবল ক্যাটাগরি লিস্ট মেথড - ভাষা অনুযায়ী
  List<String> getAvailableCategories(BuildContext context) {
    final langKey = _isEnglish ? 'en' : 'bn';
    return _categoryMappings.values
        .map((map) => map[langKey] ?? '')
        .where((category) => category.isNotEmpty)
        .toList();
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

  /// ভাষা সেট করার মেথড (যদি প্রয়োজন হয়)
  void setLanguageProvider(LanguageProvider provider) {
    _languageProvider = provider;
  }

  /// ডিসপোজ মেথড
  void dispose() {
    questions.clear();
    score = 0;
    _totalEarnedPoints = 0;
    pointsAdded = false;
    quizStarted = false;
    _quizRecorded = false;
    _languageProvider = null;
  }
}
