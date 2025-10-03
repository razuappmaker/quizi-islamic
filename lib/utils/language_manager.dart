import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const String _languageKey = 'app_language';
  static const String _english = 'en';
  static const String _bengali = 'bn';

  // ভাষা সেট করুন
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // বর্তমান ভাষা পান
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _bengali; // ডিফল্ট বাংলা
  }

  // ভাষা টগল করুন
  static Future<void> toggleLanguage() async {
    final current = await getCurrentLanguage();
    final newLang = current == _bengali ? _english : _bengali;
    await setLanguage(newLang);
  }

  // ইংরেজি কি না চেক করুন
  static Future<bool> isEnglish() async {
    final current = await getCurrentLanguage();
    return current == _english;
  }

  // ভাষা কোড পান
  static Future<String> getLanguageCode() async {
    return await getCurrentLanguage();
  }
}
