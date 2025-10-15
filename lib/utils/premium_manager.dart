// utils/premium_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class PremiumManager {
  static final PremiumManager _instance = PremiumManager._internal();

  factory PremiumManager() => _instance;

  PremiumManager._internal();

  static const String _isPremiumKey = 'is_premium_user';
  static const String _premiumExpiryKey = 'premium_expiry_date';
  static const String _lifetimePremiumKey = 'lifetime_premium';
  static const String _premiumSourceKey = 'premium_source';

  // Premium product IDs
  static const String monthlyPremiumId = 'monthly_premium';
  static const String yearlyPremiumId = 'yearly_premium';

  // Points required for premium
  static const int pointsForMonthlyPremium = 30000;
  static const int pointsForYearlyPremium = 100000;

  // Language Provider reference (will be set from UI)
  static LanguageProvider? _languageProvider;

  // Set language provider from UI
  static void setLanguageProvider(LanguageProvider provider) {
    _languageProvider = provider;
  }

  // Get current language
  static String get _currentLanguage {
    return _languageProvider?.currentLanguage ?? 'bn';
  }

  // Check if current language is English
  static bool get _isEnglish {
    return _languageProvider?.isEnglish ?? false;
  }

  // Multi-language texts
  static Map<String, Map<String, String>> get premiumTexts {
    return {
      'monthlyName': {'en': 'Monthly Premium', 'bn': '১ মাসের প্রিমিয়াম'},
      'yearlyName': {'en': 'Yearly Premium', 'bn': '১ বছরের প্রিমিয়াম'},
      'monthlyDuration': {'en': '30 days', 'bn': '৩০ দিন'},
      'yearlyDuration': {'en': '365 days', 'bn': '৩৬৫ দিন'},
      'monthlySavings': {'en': '70% savings', 'bn': '৭০% সাশ্রয়'},
      'yearlySavings': {'en': '85% savings', 'bn': '৮৫% সাশ্রয়'},
      'pointsRequired': {'en': 'points required', 'bn': 'পয়েন্ট প্রয়োজন'},
      'notEnoughPoints': {
        'en': 'Not enough points! You have',
        'bn': 'পর্যাপ্ত পয়েন্ট নেই! আপনার আছে',
      },
      'pointsNeeded': {'en': 'points, needed', 'bn': 'পয়েন্ট, প্রয়োজন'},
      'activateSuccess': {
        'en': '✅ Premium activated successfully!',
        'bn': '✅ প্রিমিয়াম সক্রিয় হয়েছে!',
      },
      'monthlyActivated': {
        'en': 'Monthly Premium activated successfully!',
        'bn': 'মাসিক প্রিমিয়াম সক্রিয় হয়েছে!',
      },
      'yearlyActivated': {
        'en': 'Yearly Premium activated successfully!',
        'bn': 'বার্ষিক প্রিমিয়াম সক্রিয় হয়েছে!',
      },
      'purchaseSuccess': {
        'en': '✅ Premium purchased successfully!',
        'bn': '✅ প্রিমিয়াম কেনা সফল হয়েছে!',
      },
      'premiumExpired': {
        'en': 'Your premium subscription has expired',
        'bn': 'আপনার প্রিমিয়াম সাবস্ক্রিপশনের মেয়াদ শেষ হয়েছে',
      },
      'premiumActive': {
        'en': 'Premium subscription active',
        'bn': 'প্রিমিয়াম সাবস্ক্রিপশন সক্রিয়',
      },
      'daysRemaining': {'en': 'days remaining', 'bn': 'দিন বাকি'},
      'lifetimePremium': {'en': 'Lifetime Premium', 'bn': 'লাইফটাইম প্রিমিয়াম'},
      'premiumStatus': {'en': 'Premium Status', 'bn': 'প্রিমিয়াম স্ট্যাটাস'},
      'subscriptionDetails': {
        'en': 'Subscription Details',
        'bn': 'সাবস্ক্রিপশন বিস্তারিত',
      },
    };
  }

  // Get text based on current language
  static String getText(String key) {
    return premiumTexts[key]?[_currentLanguage] ?? key;
  }

  // Get text with specific language (for external use)
  static String getTextWithLanguage(String key, String language) {
    return premiumTexts[key]?[language] ?? key;
  }

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
          '${getText('notEnoughPoints')} $userPoints ${getText('pointsNeeded')} $requiredPoints ${getText('pointsRequired')}',
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
      }

      await prefs.setBool(_isPremiumKey, true);
      await prefs.setString(_premiumSourceKey, 'points');

      print(
        '✅ ${getText(premiumType == 'monthly' ? 'monthlyActivated' : 'yearlyActivated')}',
      );
      return true;
    } catch (e) {
      print('❌ Error activating premium with points: $e');
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

      // Calculate expiry date for subscriptions
      final expiryDate = DateTime.now().add(Duration(days: durationInDays));
      await prefs.setString(_premiumExpiryKey, expiryDate.toIso8601String());
      await prefs.setBool(_isPremiumKey, true);

      await prefs.setString(_premiumSourceKey, 'purchase');
      print('✅ ${getText('purchaseSuccess')}');
    } catch (e) {
      print('❌ Error activating premium with purchase: $e');
      throw e;
    }
  }

  // 🔥 লাইফটাইম প্রিমিয়াম এক্টিভেট করুন
  Future<void> activateLifetimePremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_lifetimePremiumKey, true);
      await prefs.setBool(_isPremiumKey, true);
      await prefs.setString(_premiumSourceKey, 'lifetime');
      print('✅ ${getText('lifetimePremium')} activated');
    } catch (e) {
      print('❌ Error activating lifetime premium: $e');
      throw e;
    }
  }

  // 🔥 প্রিমিয়াম সোর্স জানুন
  Future<String> getPremiumSource() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_premiumSourceKey) ?? 'none';
    } catch (e) {
      print('Error reading premium source: $e');
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
      default:
        return 0;
    }
  }

  // 🔥 প্রিমিয়াম টাইপ অনুযায়ী পয়েন্ট রিকোয়ারমেন্ট - Current language
  static Map<String, dynamic> getPremiumPointsRequirements() {
    return {
      'monthly': {
        'points': pointsForMonthlyPremium,
        'name': getText('monthlyName'),
        'duration': getText('monthlyDuration'),
        'savings': getText('monthlySavings'),
      },
      'yearly': {
        'points': pointsForYearlyPremium,
        'name': getText('yearlyName'),
        'duration': getText('yearlyDuration'),
        'savings': getText('yearlySavings'),
      },
    };
  }

  // 🔥 প্রিমিয়াম প্রাইস কনফিগারেশন - Current language
  static Map<String, dynamic> getPremiumPriceConfig() {
    return {
      'monthly': {
        'price': _isEnglish ? '\$8.99' : '৮.৯৯ ডলার',
        'originalPrice': _isEnglish ? '\$29.99' : '২৯.৯৯ ডলার',
        'period': _isEnglish ? 'month' : 'মাস',
        'savings': getText('monthlySavings'),
      },
      'yearly': {
        'price': _isEnglish ? '\$99.99' : '৯৯.৯৯ ডলার',
        'originalPrice': _isEnglish ? '\$359.88' : '৩৫৯.৮৮ ডলার',
        'period': _isEnglish ? 'year' : 'বছর',
        'savings': getText('yearlySavings'),
      },
    };
  }

  Future<void> deactivatePremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isPremiumKey, false);
      await prefs.remove(_premiumExpiryKey);
      await prefs.remove(_premiumSourceKey);
      await prefs.setBool(_lifetimePremiumKey, false);
      print('Premium deactivated');
    } catch (e) {
      print('Error deactivating premium: $e');
    }
  }

  Future<DateTime?> getPremiumExpiryDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_premiumExpiryKey);
      return expiryString != null ? DateTime.parse(expiryString) : null;
    } catch (e) {
      print('Error reading premium expiry date: $e');
      return null;
    }
  }

  Future<bool> get hasLifetimePremium async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_lifetimePremiumKey) ?? false;
    } catch (e) {
      print('Error checking lifetime premium: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getPremiumStatus() async {
    final isPremium = await isPremiumUser;
    final expiryDate = await getPremiumExpiryDate();
    final isLifetime = await hasLifetimePremium;
    final source = await getPremiumSource();

    int? daysRemaining;
    String statusText = '';
    String statusTitle = '';

    if (isLifetime) {
      statusTitle = getText('lifetimePremium');
      statusText = getText('premiumActive');
    } else if (expiryDate != null) {
      statusTitle = getText('subscriptionDetails');
      daysRemaining = expiryDate.difference(DateTime.now()).inDays;
      if (daysRemaining > 0) {
        statusText = '$daysRemaining ${getText('daysRemaining')}';
      } else {
        statusText = getText('premiumExpired');
      }
    } else if (isPremium) {
      statusTitle = getText('premiumStatus');
      statusText = getText('premiumActive');
    }

    return {
      'isPremium': isPremium,
      'expiryDate': expiryDate,
      'isLifetime': isLifetime,
      'source': source,
      'daysRemaining': daysRemaining,
      'statusText': statusText,
      'statusTitle': statusTitle,
    };
  }

  // Get current language for external use
  static String get currentLanguage => _currentLanguage;

  // Check if current language is English
  static bool get isEnglish => _isEnglish;
}
