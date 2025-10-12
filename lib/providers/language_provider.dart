//language provider
// language provider
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../utils/language_manager.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'bn';
  bool _isEnglish = false;
  bool _isLoading = false;
  Timer? _debounceTimer;

  // Debounce duration
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  String get currentLanguage => _currentLanguage;

  bool get isEnglish => _isEnglish;

  bool get isLoading => _isLoading;

  // ভাষা লোড করুন
  Future<void> loadLanguage() async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentLanguage = await LanguageManager.getCurrentLanguage();
      _isEnglish = _currentLanguage == 'en';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Language loading error: $e');
      _currentLanguage = 'bn'; // ✅ Fallback to Bengali
      _isEnglish = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ভাষা টগল করুন - Debounce সহ
  Future<void> toggleLanguage() async {
    if (_isLoading) return;

    // Debounce: যদি আগের রিকোয়েস্ট চলমান থাকে, তা বাতিল করুন
    _debounceTimer?.cancel();

    _debounceTimer = Timer(_debounceDuration, () async {
      try {
        _isLoading = true;
        notifyListeners();

        // ✅ প্রথমে locally update করুন
        _isEnglish = !_isEnglish;
        _currentLanguage = _isEnglish ? 'en' : 'bn';

        // তারপর SharedPreferences-এ save করুন
        await LanguageManager.setLanguage(_currentLanguage);

        _isLoading = false;
        notifyListeners();
      } catch (e) {
        print('Language toggle error: $e');
        // ✅ Error হলে revert করুন
        _isEnglish = !_isEnglish;
        _currentLanguage = _isEnglish ? 'en' : 'bn';
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // নির্দিষ্ট ভাষা সেট করুন - Debounce সহ
  Future<void> setLanguage(String languageCode) async {
    if (_isLoading) return;

    // Debounce: যদি আগের রিকোয়েস্ট চলমান থাকে, তা বাতিল করুন
    _debounceTimer?.cancel();

    _debounceTimer = Timer(_debounceDuration, () async {
      try {
        _isLoading = true;
        notifyListeners();

        _currentLanguage = languageCode;
        _isEnglish = languageCode == 'en';

        await LanguageManager.setLanguage(languageCode);

        _isLoading = false;
        notifyListeners();
      } catch (e) {
        print('Language set error: $e');
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
