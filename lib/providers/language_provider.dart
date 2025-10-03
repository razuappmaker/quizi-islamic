import 'package:flutter/foundation.dart';
import '../utils/language_manager.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'bn';
  bool _isEnglish = false;

  String get currentLanguage => _currentLanguage;

  bool get isEnglish => _isEnglish;

  // ভাষা লোড করুন
  Future<void> loadLanguage() async {
    _currentLanguage = await LanguageManager.getCurrentLanguage();
    _isEnglish = _currentLanguage == 'en';
    notifyListeners();
  }

  // ভাষা টগল করুন
  Future<void> toggleLanguage() async {
    await LanguageManager.toggleLanguage();
    await loadLanguage(); // আপডেটেড ভাষা লোড করুন
  }

  // নির্দিষ্ট ভাষা সেট করুন
  Future<void> setLanguage(String languageCode) async {
    await LanguageManager.setLanguage(languageCode);
    await loadLanguage();
  }
}
