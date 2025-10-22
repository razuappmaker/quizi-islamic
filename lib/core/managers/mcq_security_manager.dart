// mcq_security_manager.dart - PRODUCTION READY FINAL VERSION
// Author: Islamic Quiz App Development Team
// Version: 1.0.0
// Last Updated: 2024

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../services/network_json_loader.dart';
import '../../presentation/providers/language_provider.dart';
import 'point_manager.dart';

/// Represents the result of an answer check operation
/// Contains whether the answer was correct and points earned
class AnswerResult {
  final bool isCorrect;
  final int earnedPoints;

  AnswerResult({required this.isCorrect, required this.earnedPoints});
}

/// Main manager class for handling MCQ quiz operations including:
/// - Question loading and validation
/// - Answer checking and scoring
/// - Points calculation and statistics
/// - Multi-language support
/// - Security and cooldown management
class MCQSecurityManager {
  // ==================== QUIZ DATA MANAGEMENT ====================
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

  // ==================== LANGUAGE MANAGEMENT ====================
  bool get _isEnglish => _languageProvider?.isEnglish ?? false;
  LanguageProvider? _languageProvider;

  // ==================== CURRENT QUIZ ID ====================
  String _currentQuizId = '';

  // ==================== CATEGORY MAPPING SYSTEM ====================
  // Maps category names between English and Bengali for multi-language support
  final Map<String, Map<String, String>> _categoryMappings = {
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

  // ==================== MULTI-LANGUAGE TEXT DICTIONARY ====================
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
    'islamicQuestions': {'en': 'Islamic questions', 'bn': 'ইসলামিক প্রশ্ন'},
  };

  // ==================== TEXT HELPER METHOD ====================
  /// Returns the appropriate text based on current language setting
  /// [key] - The text key to look up in the dictionary
  /// [context] - BuildContext to access language provider
  /// Returns the translated text or the key itself if not found
  String _text(String key, BuildContext context) {
    final langKey = _isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

  // ==================== INITIALIZATION METHODS ====================

  /// Initializes the quiz with the specified category and quiz ID
  /// Performs security checks, loads questions, and sets up the quiz environment
  /// [category] - The quiz category name
  /// [quizId] - Unique identifier for the quiz
  /// [context] - BuildContext for accessing providers and UI context
  /// Throws Exception if initialization fails
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

      // Security check - verify user can play this quiz
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

      // Initialize stats for new quiz session
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

  // ==================== ANSWER CHECKING & SCORING ====================

  /// Checks the user's answer and calculates points earned
  /// [selected] - The option selected by the user
  /// [currentQuestionIndex] - Index of the current question
  /// [timeLeft] - Time remaining when answer was submitted
  /// Returns AnswerResult with correctness and points information
  AnswerResult checkAnswer({
    required String selected,
    required int currentQuestionIndex,
    required int timeLeft,
  }) {
    // Security and validation checks
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

    // Debug logging for answer checking
    print('🎯 Answer Checking:');
    print('   - Question Index: $currentQuestionIndex');
    print('   - Selected: $selected');
    print('   - Correct Answer: ${question['answer']}');
    print('   - Is Correct: $isCorrect');
    print('   - Points: $pointsForThisQuestion');
    print('   - BEFORE - Score: $score');

    // Update scores - only increment score for correct answers
    if (isCorrect) {
      score++;
      print('   - AFTER - Score: $score (Increased by 1)');
    }

    // Update statistics
    _totalQuestionsAnswered++;
    _totalEarnedPoints += pointsForThisQuestion;
    _totalPointsEarned += pointsForThisQuestion;

    // Record quiz play on first answer only to prevent multiple recordings
    if (!_quizRecorded) {
      _recordQuizPlay();
      _quizRecorded = true;
    }

    // Finalize quiz if this is the last question
    if (currentQuestionIndex == questions.length - 1) {
      _finalizeQuiz();
    }

    return AnswerResult(
      isCorrect: isCorrect,
      earnedPoints: pointsForThisQuestion,
    );
  }

  /// Calculates points based on answer correctness and response time
  /// [isCorrect] - Whether the answer was correct
  /// [timeLeft] - Time remaining when answer was submitted
  /// Returns calculated points
  int _calculatePoints(bool isCorrect, int timeLeft) {
    if (!isCorrect) {
      return 1; // Participation points for incorrect answers
    }

    // Points based on time left - faster answers get more points
    if (timeLeft >= 15)
      return 10;
    else if (timeLeft >= 10)
      return 8;
    else if (timeLeft >= 5)
      return 5;
    else
      return 3;
  }

  // ==================== QUIZ RECORDING & STATISTICS ====================

  /// Records the quiz play session with points and statistics
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

  /// Finalizes the quiz and updates all statistics
  Future<void> _finalizeQuiz() async {
    try {
      if (_currentQuizId.isEmpty) return;

      // Update user statistics with final score
      await _updateUserStats();

      await PointManager.recordQuizPlay(
        quizId: _currentQuizId,
        pointsEarned: _totalEarnedPoints,
        correctAnswers: score,
        totalQuestions: questions.length,
      );

      print(
        '✅ Quiz finalized - Total Points: $_totalEarnedPoints, Correct Answers: $score',
      );
    } catch (e) {
      print('❌ Error finalizing quiz: $e');
    }
  }

  /// Updates user statistics with the current quiz results
  Future<void> _updateUserStats() async {
    try {
      await PointManager.updateQuizStats(score);
      print('✅ Stats updated with score: $score');
    } catch (e) {
      print("❌ Error updating stats: $e");
    }
  }

  /// Initializes user statistics for a new quiz session
  Future<void> _initializeUserStats() async {
    _totalQuestionsAnswered = 0;
    _totalCorrectAnswers = 0;
    _totalPointsEarned = 0;
    score = 0;
    _totalEarnedPoints = 0;
    _quizRecorded = false;
  }

  /// Resets the quiz state to initial values
  void _resetQuizState() {
    quizStarted = false;
    questions = [];
    score = 0;
    _totalEarnedPoints = 0;
    _quizRecorded = false;
  }

  // ==================== QUESTION LOADING & MANAGEMENT ====================

  /// Loads questions for the specified quiz ID with language support
  /// [quizId] - The quiz ID to load questions for
  /// [context] - BuildContext for language and UI operations
  /// Throws Exception if questions cannot be loaded
  Future<void> loadQuestions(String quizId, BuildContext context) async {
    try {
      // Select JSON file based on language
      final String fileName = _isEnglish
          ? 'assets/en_questions.json'
          : 'assets/questions.json';

      print('📁 Loading questions from: $fileName');

      // Try network loading first for dynamic content updates
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

      // Fallback to local asset loading
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

  /// Sets questions from the provided map data
  /// [questionsMap] - Map containing quiz questions data
  /// [quizId] - The quiz ID to extract questions for
  /// [context] - BuildContext for error messages
  void _setQuestionsFromMap(
    Map<dynamic, dynamic> questionsMap,
    String quizId,
    BuildContext context,
  ) {
    final quizIdString = quizId.toString();
    final availableKeys = questionsMap.keys.map((k) => k.toString()).toList();

    print('🔍 Looking for quiz ID: $quizIdString');
    print('📋 Available keys: $availableKeys');

    // Exact match search
    if (questionsMap.containsKey(quizIdString)) {
      final questionsData = questionsMap[quizIdString];
      if (questionsData is List) {
        questions = List<dynamic>.from(questionsData);
        print('✅ Exact match found - Questions: ${questions.length}');
        return;
      }
    }

    // Partial match search for flexible quiz ID matching
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

  /// Validates if the question index is within bounds
  /// [index] - The question index to validate
  /// Returns true if index is valid
  bool validateQuestionIndex(int index) {
    return index >= 0 && index < questions.length;
  }

  /// Validates the format and structure of a question
  /// [question] - The question object to validate
  /// Returns true if question format is valid
  bool validateAnswerFormat(dynamic question) {
    if (question is! Map<String, dynamic>) return false;
    if (question['question'] is! String) return false;
    if (question['options'] is! List<dynamic>) return false;
    if (question['answer'] is! String) return false;

    final options = List<String>.from(question['options']);
    return options.contains(question['answer']);
  }

  // ==================== EXTERNAL SERVICES ====================

  /// Opens Google search for the specified question
  /// [context] - BuildContext for dialogs and UI
  /// [question] - The question text to search for
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
        final islamicText = _text('islamicQuestions', context);
        final encodedQuestion = Uri.encodeComponent('$question $islamicText');
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

  /// Shows error message as a snackbar
  /// [context] - BuildContext for showing snackbar
  /// [message] - Error message to display
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

  /// Maps category name to appropriate quiz ID based on language
  /// [category] - The category name to map
  /// [context] - BuildContext for language settings
  /// Returns mapped quiz ID
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

  /// Checks if the category is valid
  /// [category] - The category to validate
  /// Returns true if category exists in mappings
  bool isValidCategory(String category) {
    return _categoryMappings.containsKey(category);
  }

  /// Returns list of available categories based on current language
  /// [context] - BuildContext for language settings
  /// Returns list of category names
  List<String> getAvailableCategories(BuildContext context) {
    final langKey = _isEnglish ? 'en' : 'bn';
    return _categoryMappings.values
        .map((map) => map[langKey] ?? '')
        .where((category) => category.isNotEmpty)
        .toList();
  }

  // ==================== STATISTICS GETTERS ====================

  int get totalQuestions => questions.length;

  int get totalScore => score;

  int get totalQuestionsAnswered => _totalQuestionsAnswered;

  int get totalCorrectAnswers => _totalCorrectAnswers;

  int get totalPointsEarned => _totalPointsEarned;

  /// Calculates total points earned in current quiz session
  int calculateTotalPoints() => _totalEarnedPoints;

  /// Calculates accuracy rate as percentage
  double get accuracyRate => _totalQuestionsAnswered > 0
      ? (_totalCorrectAnswers / _totalQuestionsAnswered) * 100
      : 0.0;

  // ==================== ADDITIONAL MANAGEMENT METHODS ====================

  /// Sets the language provider for the manager
  void setLanguageProvider(LanguageProvider provider) {
    _languageProvider = provider;
  }

  /// Updates final statistics after quiz completion
  Future<void> updateFinalStats() async {
    try {
      await _updateUserStats();
      print('✅ Final stats updated - Correct Answers: $score');
    } catch (e) {
      print('❌ Error updating final stats: $e');
    }
  }

  /// Resets quiz statistics for a new session
  Future<void> resetQuizStats() async {
    _totalQuestionsAnswered = 0;
    _totalCorrectAnswers = 0;
    _totalPointsEarned = 0;
    score = 0;
    _totalEarnedPoints = 0;
    _quizRecorded = false;
    print('✅ Quiz stats reset');
  }

  /// Cleans up resources and resets state
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
