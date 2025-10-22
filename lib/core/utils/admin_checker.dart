// utils/admin_checker.dart
import 'package:shared_preferences/shared_preferences.dart';

class AdminChecker {
  static const String _adminKey = 'is_admin';
  static const String _adminPassword = 'admin123'; // আপনার পাসওয়ার্ড

  // এডমিন চেক করার মেথড
  static Future<bool> isAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_adminKey) ?? false;
    } catch (e) {
      print("Admin check error: $e");
      return false;
    }
  }

  // এডমিন লগিন করার মেথড
  static Future<bool> loginAsAdmin(String password) async {
    try {
      if (password == _adminPassword) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_adminKey, true);
        return true;
      }
      return false;
    } catch (e) {
      print("Admin login error: $e");
      return false;
    }
  }

  // এডমিন লগআউট করার মেথড
  static Future<void> logoutAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_adminKey, false);
    } catch (e) {
      print("Admin logout error: $e");
    }
  }
}
