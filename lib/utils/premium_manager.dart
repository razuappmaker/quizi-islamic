// utils/premium_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class PremiumManager {
  static final PremiumManager _instance = PremiumManager._internal();

  factory PremiumManager() => _instance;

  PremiumManager._internal();

  static const String _isPremiumKey = 'is_premium_user';
  static const String _premiumExpiryKey = 'premium_expiry_date';
  static const String _lifetimePremiumKey = 'lifetime_premium';
  static const String _premiumSourceKey =
      'premium_source'; // 'points' or 'purchase'

  // Premium product IDs
  static const String monthlyPremiumId = 'monthly_premium';
  static const String yearlyPremiumId = 'yearly_premium';
  static const String lifetimePremiumId = 'lifetime_premium';
  static const String removeAdsId = 'remove_ads';

  // Points required for premium
  static const int pointsForMonthlyPremium = 10000;
  static const int pointsForYearlyPremium = 50000;
  static const int pointsForLifetimePremium = 100000;
  static const int pointsForRemoveAds = 25000;

  Future<bool> get isPremiumUser async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check lifetime premium first
      if (prefs.getBool(_lifetimePremiumKey) == true) {
        return true;
      }

      // Check subscription expiry
      final expiryString = prefs.getString(_premiumExpiryKey);
      if (expiryString != null) {
        final expiryDate = DateTime.parse(expiryString);
        if (expiryDate.isAfter(DateTime.now())) {
          return true;
        } else {
          // Subscription expired
          await prefs.setBool(_isPremiumKey, false);
          return false;
        }
      }

      return prefs.getBool(_isPremiumKey) ?? false;
    } catch (e) {
      print('Premium status check error: $e');
      return false;
    }
  }

  // 🔥 পয়েন্ট দিয়ে প্রিমিয়াম এক্টিভেট করুন
  Future<bool> activatePremiumWithPoints(
    String premiumType,
    int userPoints,
  ) async {
    try {
      final requiredPoints = _getRequiredPoints(premiumType);

      if (userPoints < requiredPoints) {
        throw Exception(
          'পর্যাপ্ত পয়েন্ট নেই! আপনার আছে $userPoints পয়েন্ট, প্রয়োজন $requiredPoints পয়েন্ট',
        );
      }

      final prefs = await SharedPreferences.getInstance();

      // Calculate expiry based on premium type
      if (premiumType == 'monthly') {
        final expiryDate = DateTime.now().add(const Duration(days: 30));
        await prefs.setString(_premiumExpiryKey, expiryDate.toIso8601String());
      } else if (premiumType == 'yearly') {
        final expiryDate = DateTime.now().add(const Duration(days: 365));
        await prefs.setString(_premiumExpiryKey, expiryDate.toIso8601String());
      } else if (premiumType == 'lifetime') {
        await prefs.setBool(_lifetimePremiumKey, true);
      } else if (premiumType == 'remove_ads') {
        await prefs.setBool(_lifetimePremiumKey, true);
      }

      await prefs.setBool(_isPremiumKey, true);
      await prefs.setString(_premiumSourceKey, 'points');

      print('✅ পয়েন্ট দিয়ে প্রিমিয়াম এক্টিভেটেড: $premiumType');
      return true;
    } catch (e) {
      print('❌ পয়েন্ট দিয়ে প্রিমিয়াম এক্টিভেট করতে ত্রুটি: $e');
      return false;
    }
  }

  // 🔥 টাকা দিয়ে প্রিমিয়াম এক্টিভেট করুন
  Future<void> activatePremiumWithPurchase({
    required String productId,
    int durationInDays = 30,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (productId == lifetimePremiumId) {
        await prefs.setBool(_lifetimePremiumKey, true);
        await prefs.setBool(_isPremiumKey, true);
      } else if (productId == removeAdsId) {
        await prefs.setBool(_isPremiumKey, true);
      } else {
        // Calculate expiry date for subscriptions
        final expiryDate = DateTime.now().add(Duration(days: durationInDays));
        await prefs.setString(_premiumExpiryKey, expiryDate.toIso8601String());
        await prefs.setBool(_isPremiumKey, true);
      }

      await prefs.setString(_premiumSourceKey, 'purchase');
      print('✅ পারচেজ দিয়ে প্রিমিয়াম এক্টিভেটেড: $productId');
    } catch (e) {
      print('❌ পারচেজ দিয়ে প্রিমিয়াম এক্টিভেট করতে ত্রুটি: $e');
      throw e;
    }
  }

  // 🔥 প্রিমিয়াম সোর্স জানুন
  Future<String> getPremiumSource() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_premiumSourceKey) ?? 'none';
    } catch (e) {
      print('প্রিমিয়াম সোর্স পড়তে ত্রুটি: $e');
      return 'none';
    }
  }

  // 🔥 প্রয়োজনীয় পয়েন্ট জানুন
  int _getRequiredPoints(String premiumType) {
    switch (premiumType) {
      case 'monthly':
        return pointsForMonthlyPremium;
      case 'yearly':
        return pointsForYearlyPremium;
      case 'lifetime':
        return pointsForLifetimePremium;
      case 'remove_ads':
        return pointsForRemoveAds;
      default:
        return 0;
    }
  }

  // 🔥 প্রিমিয়াম টাইপ অনুযায়ী পয়েন্ট রিকোয়ারমেন্ট
  static Map<String, dynamic> getPremiumPointsRequirements() {
    return {
      'monthly': {
        'points': pointsForMonthlyPremium,
        'name': '১ মাসের প্রিমিয়াম',
        'duration': '৩০ দিন',
      },
      'yearly': {
        'points': pointsForYearlyPremium,
        'name': '১ বছরের প্রিমিয়াম',
        'duration': '৩৬৫ দিন',
      },
      'lifetime': {
        'points': pointsForLifetimePremium,
        'name': 'লাইফটাইম প্রিমিয়াম',
        'duration': 'আজীবন',
      },
      'remove_ads': {
        'points': pointsForRemoveAds,
        'name': 'অ্যাড রিমুভাল',
        'duration': 'স্থায়ী',
      },
    };
  }

  Future<void> deactivatePremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isPremiumKey, false);
      await prefs.remove(_premiumExpiryKey);
      await prefs.remove(_premiumSourceKey);
      print('প্রিমিয়াম ডিএক্টিভেটেড');
    } catch (e) {
      print('প্রিমিয়াম ডিএক্টিভেট করতে ত্রুটি: $e');
    }
  }

  Future<DateTime?> getPremiumExpiryDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_premiumExpiryKey);
      return expiryString != null ? DateTime.parse(expiryString) : null;
    } catch (e) {
      print('প্রিমিয়াম এক্সপায়ারি ডেট পড়তে ত্রুটি: $e');
      return null;
    }
  }

  Future<bool> get hasLifetimePremium async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_lifetimePremiumKey) ?? false;
    } catch (e) {
      print('লাইফটাইম প্রিমিয়াম চেক করতে ত্রুটি: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getPremiumStatus() async {
    final isPremium = await isPremiumUser;
    final expiryDate = await getPremiumExpiryDate();
    final isLifetime = await hasLifetimePremium;
    final source = await getPremiumSource();

    return {
      'isPremium': isPremium,
      'expiryDate': expiryDate,
      'isLifetime': isLifetime,
      'source': source,
      'daysRemaining': expiryDate != null
          ? expiryDate.difference(DateTime.now()).inDays
          : null,
    };
  }
}
