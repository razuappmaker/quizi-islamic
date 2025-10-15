import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/premium_manager.dart';

class AdHelper {
  static bool _isAdInitialized = false;
  static final AdLimitManager _adLimitManager = AdLimitManager();

  // 🔥 Google Mobile Ads SDK ইনিশিয়ালাইজ করুন
  static Future<void> initialize() async {
    if (_isAdInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isAdInitialized = true;
      preloadInterstitialAd();
      print('AdMob সফলভাবে ইনিশিয়ালাইজ হয়েছে');
    } catch (e) {
      print('AdMob ইনিশিয়ালাইজ করতে ব্যর্থ: $e');
    }
  }

  // 🔥 প্রিমিয়াম ইউজার চেক - সকল অ্যাড শো করার আগে এই চেক ব্যবহার করুন
  static Future<bool> get shouldShowAds async {
    try {
      final isPremium = await PremiumManager().isPremiumUser;
      return !isPremium;
    } catch (e) {
      print('প্রিমিয়াম স্ট্যাটাস চেক করতে ত্রুটি: $e');
      return true; // এরর হলে অ্যাড দেখান
    }
  }

  // 🔥 ব্যানার অ্যাড ইউনিট ID
  static String get bannerAdUnitId {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'ca-app-pub-3940256099942544/6300978111'; // আপনার প্রোডাকশন ID দিন
    } else {
      return 'ca-app-pub-3940256099942544/6300978111'; // টেস্ট ID
    }
  }

  // 🔥 ইন্টারস্টিশিয়াল অ্যাড ইউনিট ID
  static String get interstitialAdUnitId {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'ca-app-pub-3940256099942544/1033173712'; // আপনার প্রোডাকশন ID দিন
    } else {
      return 'ca-app-pub-3940256099942544/1033173712'; // টেস্ট ID
    }
  }

  // 🔥 রিওয়ার্ডেড অ্যাড ইউনিট ID
  static String get rewardedAdUnitId {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'ca-app-pub-3940256099942544/5224354917'; // আপনার প্রোডাকশন ID দিন
    } else {
      return 'ca-app-pub-3940256099942544/5224354917'; // টেস্ট ID
    }
  }

  // 🔥 ব্যানার অ্যাড দেখানো যাবে কিনা চেক করুন (প্রিমিয়াম ইউজার চেক সহ)
  static Future<bool> canShowBannerAd() async {
    final shouldShow = await shouldShowAds;
    if (!shouldShow) {
      print('প্রিমিয়াম ইউজার, ব্যানার অ্যাড দেখানো হবে না');
      return false;
    }
    return await _adLimitManager.canShowBannerAd();
  }

  // 🔥 ইন্টারস্টিশিয়াল অ্যাড দেখানো যাবে কিনা চেক করুন (প্রিমিয়াম ইউজার চেক সহ)
  static Future<bool> canShowInterstitialAd() async {
    final shouldShow = await shouldShowAds;
    if (!shouldShow) {
      print('প্রিমিয়াম ইউজার, ইন্টারস্টিশিয়াল অ্যাড দেখানো হবে না');
      return false;
    }
    return await _adLimitManager.canShowInterstitialAd();
  }

  // 🔥 স্ট্যান্ডার্ড ব্যানার অ্যাড তৈরি করুন - Version 6.0.0 কম্প্যাটিবল
  static BannerAd? createBannerAd(AdSize adSize, {BannerAdListener? listener}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener:
          listener ??
          BannerAdListener(
            onAdLoaded: (Ad ad) => print('অ্যাড লোড হয়েছে'),
            onAdFailedToLoad: (Ad ad, LoadAdError error) =>
                print('অ্যাড লোড হতে ব্যর্থ: $error'),
          ),
    );
  }

  // 🔥 অ্যাডাপ্টিভ ব্যানার অ্যাড তৈরি করুন ফ্যালব্যাক মেকানিজম সহ - প্রিমিয়াম চেক সহ
  static Future<BannerAd?> createAdaptiveBannerAdWithFallback(
    BuildContext context, {
    int? width,
    BannerAdListener? listener,
    Orientation orientation = Orientation.portrait,
  }) async {
    try {
      bool canShowAd = await canShowBannerAd(); // প্রিমিয়াম চেক সহ

      if (!canShowAd) {
        print('প্রিমিয়াম ইউজার, অ্যাডাপ্টিভ ব্যানার অ্যাড দেখানো হবে না');
        return null;
      }

      // প্রথমে অ্যাডাপ্টিভ ব্যানার তৈরি করার চেষ্টা করুন
      final AdSize adSize = await _getAdaptiveAdSize(context, orientation);
      final bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: adSize,
        request: const AdRequest(),
        listener:
            listener ??
            BannerAdListener(
              onAdLoaded: (Ad ad) => print('অ্যাডাপ্টিভ অ্যাড লোড হয়েছে'),
              onAdFailedToLoad: (Ad ad, LoadAdError error) =>
                  print('অ্যাডাপ্টিভ অ্যাড ব্যর্থ: $error'),
            ),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      // অ্যাডাপ্টিভ ব্যর্থ হলে স্ট্যান্ডার্ড ব্যানারে ফ্যালব্যাক করুন
      print(
        'অ্যাডাপ্টিভ ব্যানার ব্যর্থ, স্ট্যান্ডার্ড ব্যানারে ফ্যালব্যাক: $e',
      );
      final bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: listener ?? BannerAdListener(),
      );

      await bannerAd.load();
      return bannerAd;
    }
  }

  // 🔥 অ্যাডাপ্টিভ অ্যাড সাইজ পান - ম্যানুয়াল ক্যালকুলেশন
  static Future<AdSize> _getAdaptiveAdSize(
    BuildContext context,
    Orientation orientation,
  ) async {
    try {
      final width = MediaQuery.of(context).size.width;

      // স্ক্রিন প্রস্থ ভিত্তিক অ্যাডাপ্টিভ সাইজিং
      if (width < 400) {
        // ছোট স্ক্রিন (ফোন)
        return orientation == Orientation.portrait
            ? AdSize(width: width.truncate(), height: 50)
            : AdSize(width: width.truncate(), height: 90);
      } else if (width < 720) {
        // মাঝারি স্ক্রিন (বড় ফোন, ছোট ট্যাবলেট)
        return orientation == Orientation.portrait
            ? AdSize(width: width.truncate(), height: 90)
            : AdSize(width: width.truncate(), height: 90);
      } else {
        // বড় স্ক্রিন (ট্যাবলেট)
        return orientation == Orientation.portrait
            ? AdSize(width: width.truncate(), height: 90)
            : AdSize(width: width.truncate(), height: 90);
      }
    } catch (e) {
      print('অ্যাডাপ্টিভ অ্যাড সাইজ পেতে ত্রুটি: $e');
      return AdSize.banner; // স্ট্যান্ডার্ড ব্যানার সাইজে ফ্যালব্যাক
    }
  }

  // 🔥 ওরিয়েন্টেশন পরিবর্তনে ব্যানার রিলোড করুন
  static Future<BannerAd?> reloadBannerOnOrientationChange(
    BuildContext context,
    Orientation currentOrientation, {
    BannerAdListener? listener,
  }) async {
    return await createAdaptiveBannerAdWithFallback(
      context,
      listener: listener,
      orientation: currentOrientation,
    );
  }

  // 🔥 ইন্টারস্টিশিয়াল অ্যাড ম্যানেজমেন্ট
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdLoaded = false;
  static int _interstitialLoadAttempts = 0;
  static const int _maxInterstitialLoadAttempts = 3;

  // 🔥 ইন্টারস্টিশিয়াল অ্যাড লোড করুন রিট্রাই মেকানিজম সহ
  static void loadInterstitialAd({
    VoidCallback? onAdLoaded,
    VoidCallback? onAdFailedToLoad,
  }) {
    if (_interstitialLoadAttempts >= _maxInterstitialLoadAttempts) {
      print('ইন্টারস্টিশিয়াল লোডের সর্বোচ্চ চেষ্টা সীমা শেষ');
      onAdFailedToLoad?.call();
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _interstitialLoadAttempts = 0;
          print('ইন্টারস্টিশিয়াল অ্যাড সফলভাবে লোড হয়েছে');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts++;
          _isInterstitialAdLoaded = false;
          print(
            'ইন্টারস্টিশিয়াল অ্যাড লোড হতে ব্যর্থ: $error। চেষ্টা $_interstitialLoadAttempts',
          );

          // বিলম্ব后 আবার চেষ্টা করুন
          Future.delayed(Duration(seconds: 2 * _interstitialLoadAttempts), () {
            loadInterstitialAd(
              onAdLoaded: onAdLoaded,
              onAdFailedToLoad: onAdFailedToLoad,
            );
          });

          onAdFailedToLoad?.call();
        },
      ),
    );
  }

  // 🔥 ইন্টারস্টিশিয়াল অ্যাড প্রিলোড করুন
  static void preloadInterstitialAd() {
    loadInterstitialAd();
  }

  // 🔥 ইন্টারস্টিশিয়াল অ্যাড দেখান (প্রিমিয়াম ইউজার চেক সহ)
  static Future<void> showInterstitialAd({
    VoidCallback? onAdShowed,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
    String? adContext, // ট্র্যাকিং এর জন্য
  }) async {
    final shouldShow = await shouldShowAds;
    if (!shouldShow) {
      print('প্রিমিয়াম ইউজার, অ্যাড স্কিপ করা হয়েছে');
      onAdDismissed?.call(); // অ্যাড না দেখালেও onAdDismissed কল করুন
      return;
    }

    try {
      print('ইন্টারস্টিশিয়াল অ্যাড দেখানোর চেষ্টা করা হচ্ছে: $adContext');

      // লিমিট based এ অ্যাড দেখানো যাবে কিনা চেক করুন
      bool canShowAd = await _adLimitManager.canShowInterstitialAd();

      if (!canShowAd) {
        print('লিমিট এর কারণে ইন্টারস্টিশিয়াল অ্যাড দেখানো যাবে না');
        onAdFailedToShow?.call();
        return;
      }

      if (_isInterstitialAdLoaded && _interstitialAd != null) {
        await _adLimitManager.recordInterstitialAdShown();

        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (InterstitialAd ad) {
            print('ইন্টারস্টিশিয়াল অ্যাড সফলভাবে দেখানো হয়েছে');
            onAdShowed?.call();
          },
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            print('ইন্টারস্টিশিয়াল অ্যাড dismiss করা হয়েছে');
            ad.dispose();
            _isInterstitialAdLoaded = false;
            onAdDismissed?.call();
            loadInterstitialAd(); // পরবর্তী অ্যাড প্রিলোড করুন
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
                print('ইন্টারস্টিশিয়াল অ্যাড দেখাতে ব্যর্থ: $error');
                ad.dispose();
                _isInterstitialAdLoaded = false;
                onAdFailedToShow?.call();
                loadInterstitialAd(); // পরবর্তী অ্যাড প্রিলোড করুন
              },
        );

        _interstitialAd!.show();
        _interstitialAd = null; // পুনরায় ব্যবহার প্রতিরোধ
      } else {
        print('ইন্টারস্টিশিয়াল অ্যাড লোড হয়নি, লোড করার চেষ্টা করা হচ্ছে');
        onAdFailedToShow?.call();
        loadInterstitialAd(); // পরবর্তী বার জন্য লোড করুন
      }
    } catch (e) {
      print('ইন্টারস্টিশিয়াল অ্যাড দেখাতে ত্রুটি: $e');
      onAdFailedToShow?.call();
    }
  }

  // 🔥 ব্যানার অ্যাড দেখানোর রেকর্ড করুন
  static Future<void> recordBannerAdShown() async {
    await _adLimitManager.recordBannerAdShown();
  }

  // 🔥 অ্যাড ক্লিক করা যাবে কিনা চেক করুন
  static Future<bool> canClickAd() async {
    return await _adLimitManager.canClickAd();
  }

  // 🔥 অ্যাড ক্লিক রেকর্ড করুন
  static Future<void> recordAdClick() async {
    await _adLimitManager.recordAdClick();
  }

  // 🔥 অ্যাড স্ট্যাটস পান
  static Future<Map<String, int>> getAdStats() async {
    return await _adLimitManager.getAdStats();
  }

  // 🔥 অ্যাড লিমিট রিসেট করুন (টেস্টিং বা বিশেষ ক্ষেত্রে)
  static Future<void> resetAdLimits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('first_ad_today');
    await prefs.remove('daily_impressions');
    await prefs.remove('daily_clicks');
    await prefs.remove('minute_impressions');
    await prefs.remove('banner_impressions');
    await prefs.remove('interstitial_impressions');
    print('অ্যাড লিমিট সফলভাবে রিসেট হয়েছে');
  }

  // 🔥 অ্যাঙ্করড অ্যাডাপ্টিভ ব্যানার সাইজ পান
  static Future<AnchoredAdaptiveBannerAdSize?> getAnchoredAdaptiveBannerAdSize(
    BuildContext context,
  ) async {
    try {
      return await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.toInt(),
      );
    } catch (e) {
      print('অ্যাঙ্করড অ্যাডাপ্টিভ ব্যানার সাইজ পেতে ত্রুটি: $e');
      return null;
    }
  }

  // 🔥 অ্যাঙ্করড ব্যানার অ্যাড তৈরি করুন - প্রিমিয়াম চেক সহ
  static Future<BannerAd?> createAnchoredBannerAd(
    BuildContext context, {
    BannerAdListener? listener,
  }) async {
    try {
      bool canShowAd = await canShowBannerAd(); // প্রিমিয়াম চেক সহ

      if (!canShowAd) {
        print('প্রিমিয়াম ইউজার বা লিমিট রিচড, ব্যানার অ্যাড দেখানো হবে না');
        return null;
      }

      final adSize = await getAnchoredAdaptiveBannerAdSize(context);

      if (adSize == null) {
        print('অ্যাঙ্করড অ্যাডাপ্টিভ ব্যানার সাইজ পাওয়া যায়নি');
        return null;
      }

      final bannerAd = BannerAd(
        size: adSize,
        adUnitId: bannerAdUnitId,
        listener:
            listener ??
            BannerAdListener(
              onAdLoaded: (Ad ad) {
                print('অ্যাঙ্করড ব্যানার অ্যাড সফলভাবে লোড হয়েছে।');
                recordBannerAdShown();
              },
              onAdFailedToLoad: (Ad ad, LoadAdError error) {
                print('অ্যাঙ্করড ব্যানার অ্যাড লোড হতে ব্যর্থ: $error');
                ad.dispose();
              },
              onAdOpened: (Ad ad) {
                canClickAd().then((canClick) {
                  if (canClick) {
                    recordAdClick();
                    print('অ্যাঙ্করড ব্যানার অ্যাড ক্লিক করা হয়েছে।');
                  } else {
                    print('অ্যাড ক্লিক লিমিট রিচড');
                  }
                });
              },
              onAdClosed: (Ad ad) {
                print('অ্যাঙ্করড ব্যানার অ্যাড ইউজার বন্ধ করেছেন।');
              },
            ),
        request: const AdRequest(),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      print('অ্যাঙ্করড ব্যানার অ্যাড তৈরি করতে ত্রুটি: $e');
      return null;
    }
  }

  // 🔥 সহজ ব্যানার অ্যাড লোড করার মেথড - সবচেয়ে সহজভাবে ব্যবহারের জন্য
  static Future<BannerAd?> loadSimpleBannerAd(
    BuildContext context, {
    BannerAdListener? listener,
  }) async {
    try {
      bool canShowAd = await canShowBannerAd();

      if (!canShowAd) {
        print('প্রিমিয়াম ইউজার, ব্যানার অ্যাড দেখানো হবে না');
        return null;
      }

      final bannerAd = await createAnchoredBannerAd(
        context,
        listener: listener,
      );
      return bannerAd;
    } catch (e) {
      print('সিম্পল ব্যানার অ্যাড লোড করতে ত্রুটি: $e');
      return null;
    }
  }

  // 🔥 ডিসপোজ মেথড
  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _isInterstitialAdLoaded = false;
    _interstitialLoadAttempts = 0;
  }

  // 🔥 অ্যাডস ইনিশিয়ালাইজ হয়েছে কিনা চেক করুন
  static bool get isInitialized => _isAdInitialized;
}

// ==================== অ্যাড লিমিট ম্যানেজমেন্ট ক্লাস ====================
class AdLimitManager {
  static const int maxDailyImpressions = 400; // production এ 20 হবে
  static const int maxDailyClicks = 5;
  static const int maxImpressionsPerMinute = 30; // production এ 3 হবে
  static const int maxBannerAdsPerHour = 100; // production এ 10 হবে
  static const int maxInterstitialAdsPerHour = 30; // production এ 3 হবে

  // 🔥 ব্যানার অ্যাড দেখানো যাবে কিনা চেক করুন
  Future<bool> canShowBannerAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _resetIfNewDay(prefs);

      final dailyImpressions = prefs.getInt('daily_impressions') ?? 0;
      if (dailyImpressions >= maxDailyImpressions) {
        return false;
      }

      final now = DateTime.now();
      final minuteImpressions = prefs.getStringList('minute_impressions') ?? [];
      final currentMinute = '${now.hour}:${now.minute}';
      final minuteCount = minuteImpressions
          .where((time) => time == currentMinute)
          .length;

      if (minuteCount >= maxImpressionsPerMinute) {
        return false;
      }

      final bannerImpressions = prefs.getStringList('banner_impressions') ?? [];
      final currentHour = now.hour;
      final hourCount = bannerImpressions.where((time) {
        final hour = int.parse(time.split(':')[0]);
        return hour == currentHour;
      }).length;

      if (hourCount >= maxBannerAdsPerHour) {
        return false;
      }

      return true;
    } catch (e) {
      print('ব্যানার অ্যাড লিমিট চেক করতে ত্রুটি: $e');
      return true; // লিমিট চেকিং এ এরর হলে অ্যাড allow করুন
    }
  }

  // 🔥 ইন্টারস্টিশিয়াল অ্যাড দেখানো যাবে কিনা চেক করুন
  Future<bool> canShowInterstitialAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _resetIfNewDay(prefs);

      final dailyImpressions = prefs.getInt('daily_impressions') ?? 0;
      if (dailyImpressions >= maxDailyImpressions) {
        return false;
      }

      final now = DateTime.now();
      final interstitialImpressions =
          prefs.getStringList('interstitial_impressions') ?? [];
      final currentHour = now.hour;
      final hourCount = interstitialImpressions.where((time) {
        final hour = int.parse(time.split(':')[0]);
        return hour == currentHour;
      }).length;

      if (hourCount >= maxInterstitialAdsPerHour) {
        return false;
      }

      return true;
    } catch (e) {
      print('ইন্টারস্টিশিয়াল অ্যাড লিমিট চেক করতে ত্রুটি: $e');
      return true; // লিমিট চেকিং এ এরর হলে অ্যাড allow করুন
    }
  }

  // 🔥 ব্যানার অ্যাড দেখানোর রেকর্ড করুন
  Future<void> recordBannerAdShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      final dailyImpressions = (prefs.getInt('daily_impressions') ?? 0) + 1;
      await prefs.setInt('daily_impressions', dailyImpressions);

      final minuteImpressions = prefs.getStringList('minute_impressions') ?? [];
      minuteImpressions.add('${now.hour}:${now.minute}');
      await prefs.setStringList('minute_impressions', minuteImpressions);

      final bannerImpressions = prefs.getStringList('banner_impressions') ?? [];
      bannerImpressions.add('${now.hour}:${now.minute}');
      await prefs.setStringList('banner_impressions', bannerImpressions);
    } catch (e) {
      print('ব্যানার অ্যাড ইম্প্রেশন রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // 🔥 ইন্টারস্টিশিয়াল অ্যাড দেখানোর রেকর্ড করুন
  Future<void> recordInterstitialAdShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      final dailyImpressions = (prefs.getInt('daily_impressions') ?? 0) + 1;
      await prefs.setInt('daily_impressions', dailyImpressions);

      final interstitialImpressions =
          prefs.getStringList('interstitial_impressions') ?? [];
      interstitialImpressions.add('${now.hour}:${now.minute}');
      await prefs.setStringList(
        'interstitial_impressions',
        interstitialImpressions,
      );
    } catch (e) {
      print('ইন্টারস্টিশিয়াল অ্যাড ইম্প্রেশন রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // 🔥 অ্যাড ক্লিক করা যাবে কিনা চেক করুন
  Future<bool> canClickAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _resetIfNewDay(prefs);

      final dailyClicks = prefs.getInt('daily_clicks') ?? 0;
      return dailyClicks < maxDailyClicks;
    } catch (e) {
      print('অ্যাড ক্লিক লিমিট চেক করতে ত্রুটি: $e');
      return true; // লিমিট চেকিং এ এরর হলে ক্লিক allow করুন
    }
  }

  // 🔥 অ্যাড ক্লিক রেকর্ড করুন
  Future<void> recordAdClick() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dailyClicks = (prefs.getInt('daily_clicks') ?? 0) + 1;
      await prefs.setInt('daily_clicks', dailyClicks);
    } catch (e) {
      print('অ্যাড ক্লিক রেকর্ড করতে ত্রুটি: $e');
    }
  }

  // 🔥 অ্যাড স্ট্যাটস পান
  Future<Map<String, int>> getAdStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _resetIfNewDay(prefs);

      return {
        'daily_impressions': prefs.getInt('daily_impressions') ?? 0,
        'daily_clicks': prefs.getInt('daily_clicks') ?? 0,
        'max_daily_impressions': maxDailyImpressions,
        'max_daily_clicks': maxDailyClicks,
      };
    } catch (e) {
      print('অ্যাড স্ট্যাটস পেতে ত্রুটি: $e');
      return {
        'daily_impressions': 0,
        'daily_clicks': 0,
        'max_daily_impressions': maxDailyImpressions,
        'max_daily_clicks': maxDailyClicks,
      };
    }
  }

  // 🔥 নতুন দিন হলে অ্যাড লিমিট রিসেট করুন
  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    try {
      final firstAdToday = prefs.getString('first_ad_today');
      final now = DateTime.now();

      if (firstAdToday == null) {
        await prefs.setString('first_ad_today', now.toIso8601String());
      } else {
        final firstAdDate = DateTime.parse(firstAdToday);
        if (now.difference(firstAdDate).inHours >= 24) {
          await prefs.setString('first_ad_today', now.toIso8601String());
          await prefs.setInt('daily_impressions', 0);
          await prefs.setInt('daily_clicks', 0);
          await prefs.setStringList('minute_impressions', []);
          await prefs.setStringList('banner_impressions', []);
          await prefs.setStringList('interstitial_impressions', []);
        }
      }
    } catch (e) {
      print('অ্যাড লিমিট রিসেট করতে ত্রুটি: $e');
    }
  }
}
