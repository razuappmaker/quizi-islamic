// language manager
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const String _languageKey = 'app_language';
  static const String _english = 'en';
  static const String _bengali = 'bn';

  // Cache value for better performance
  static String? _cachedLanguage;

  // ভাষা সেট করুন
  static Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      _cachedLanguage = languageCode; // Cache update
    } catch (e) {
      print('Error saving language: $e');
      rethrow;
    }
  }

  // বর্তমান ভাষা পান - with cache
  static Future<String> getCurrentLanguage() async {
    try {
      // Cache থেকে প্রথমে চেক করুন
      if (_cachedLanguage != null) {
        return _cachedLanguage!;
      }

      final prefs = await SharedPreferences.getInstance();
      _cachedLanguage = prefs.getString(_languageKey) ?? _bengali;
      return _cachedLanguage!;
    } catch (e) {
      print('Error loading language: $e');
      return _bengali; // Fallback to Bengali
    }
  }

  // ভাষা টগল করুন
  static Future<void> toggleLanguage() async {
    try {
      final current = await getCurrentLanguage();
      final newLang = current == _bengali ? _english : _bengali;
      await setLanguage(newLang);
    } catch (e) {
      print('Error toggling language: $e');
      rethrow;
    }
  }

  // ইংরেজি কি না চেক করুন
  static Future<bool> isEnglish() async {
    final current = await getCurrentLanguage();
    return current == _english;
  }

  // Cache clear করুন (যদি প্রয়োজন হয়)
  static void clearCache() {
    _cachedLanguage = null;
  }
}
