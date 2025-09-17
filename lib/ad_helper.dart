import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdHelper {
  static bool _isAdInitialized = false;
  static final AdLimitManager _adLimitManager = AdLimitManager();

  // Initialize Google Mobile Ads SDK
  static Future<void> initialize() async {
    if (_isAdInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isAdInitialized = true;
      preloadInterstitialAd();
      print('AdMob initialized successfully');
    } catch (e) {
      print('Failed to initialize AdMob: $e');
    }
  }

  // Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'ca-app-pub-3940256099942544/6300978111'; // আপনার প্রোডাকশন ID দিন
    } else {
      return 'ca-app-pub-3940256099942544/6300978111'; // টেস্ট ID
    }
  }

  // Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'ca-app-pub-3940256099942544/1033173712'; // আপনার প্রোডাকশন ID দিন
    } else {
      return 'ca-app-pub-3940256099942544/1033173712'; // টেস্ট ID
    }
  }

  // Create standard banner ad - Version 6.0.0 compatible
  static BannerAd createBannerAd(AdSize adSize, {BannerAdListener? listener}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener:
          listener ??
          BannerAdListener(
            onAdLoaded: (Ad ad) => print('Ad loaded'),
            onAdFailedToLoad: (Ad ad, LoadAdError error) =>
                print('Ad failed to load: $error'),
          ),
    );
  }

  // Create adaptive banner ad with fallback mechanism - Version 6.0.0 compatible
  static Future<BannerAd> createAdaptiveBannerAdWithFallback(
    BuildContext context, {
    int? width, // যদি এই parameter না থাকে
    BannerAdListener? listener,
    Orientation orientation = Orientation.portrait,
  }) async {
    try {
      // First try to create adaptive banner
      final AdSize adSize = await _getAdaptiveAdSize(context, orientation);
      return BannerAd(
        adUnitId: bannerAdUnitId,
        size: adSize,
        request: const AdRequest(),
        listener:
            listener ??
            BannerAdListener(
              onAdLoaded: (Ad ad) => print('Adaptive ad loaded'),
              onAdFailedToLoad: (Ad ad, LoadAdError error) =>
                  print('Adaptive ad failed: $error'),
            ),
      );
    } catch (e) {
      // Fallback to standard banner if adaptive fails
      print('Adaptive banner failed, falling back to standard banner: $e');
      return BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: listener ?? BannerAdListener(),
      );
    }
  }

  // Get adaptive ad size - Manual calculation
  static Future<AdSize> _getAdaptiveAdSize(
    BuildContext context,
    Orientation orientation,
  ) async {
    try {
      final width = MediaQuery.of(context).size.width;

      // Screen width based adaptive sizing
      if (width < 400) {
        // Small screens (phones)
        return orientation == Orientation.portrait
            ? AdSize(width: width.truncate(), height: 50)
            : AdSize(width: width.truncate(), height: 90);
      } else if (width < 720) {
        // Medium screens (large phones, small tablets)
        return orientation == Orientation.portrait
            ? AdSize(width: width.truncate(), height: 90)
            : AdSize(width: width.truncate(), height: 90);
      } else {
        // Large screens (tablets)
        return orientation == Orientation.portrait
            ? AdSize(width: width.truncate(), height: 90)
            : AdSize(width: width.truncate(), height: 90);
      }
    } catch (e) {
      print('Error getting adaptive ad size: $e');
      return AdSize.banner; // Fallback to standard banner size
    }
  }

  // Reload banner on orientation change - Version 6.0.0 compatible
  static Future<BannerAd> reloadBannerOnOrientationChange(
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

  // Interstitial ad management - Version 6.0.0 compatible
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdLoaded = false;
  static int _interstitialLoadAttempts = 0;
  static const int _maxInterstitialLoadAttempts = 3;

  // Load interstitial ad with retry mechanism
  static void loadInterstitialAd({
    VoidCallback? onAdLoaded,
    VoidCallback? onAdFailedToLoad,
  }) {
    if (_interstitialLoadAttempts >= _maxInterstitialLoadAttempts) {
      print('Max interstitial load attempts reached');
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
          print('Interstitial ad loaded successfully');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts++;
          _isInterstitialAdLoaded = false;
          print(
            'Interstitial ad failed to load: $error. Attempt $_interstitialLoadAttempts',
          );

          // Retry after delay
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

  // Preload interstitial ads
  static void preloadInterstitialAd() {
    loadInterstitialAd();
  }

  // Show interstitial ad with comprehensive error handling
  static Future<void> showInterstitialAd({
    VoidCallback? onAdShowed,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
    String? adContext, // For tracking where ad was called from
  }) async {
    try {
      print('Attempting to show interstitial ad from: $adContext');

      // Check if we can show ad based on limits
      bool canShowAd = await _adLimitManager.canShowInterstitialAd();

      if (!canShowAd) {
        print('Cannot show interstitial ad due to limits');
        onAdFailedToShow?.call();
        return;
      }

      if (_isInterstitialAdLoaded && _interstitialAd != null) {
        await _adLimitManager.recordInterstitialAdShown();

        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (InterstitialAd ad) {
            print('Interstitial ad showed successfully');
            onAdShowed?.call();
          },
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            print('Interstitial ad dismissed');
            ad.dispose();
            _isInterstitialAdLoaded = false;
            onAdDismissed?.call();
            loadInterstitialAd(); // Preload next ad
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
                print('Interstitial ad failed to show: $error');
                ad.dispose();
                _isInterstitialAdLoaded = false;
                onAdFailedToShow?.call();
                loadInterstitialAd(); // Preload next ad
              },
        );

        _interstitialAd!.show();
        _interstitialAd = null; // Prevent reuse
      } else {
        print('Interstitial ad not loaded, attempting to load');
        onAdFailedToShow?.call();
        loadInterstitialAd(); // Try to load for next time
      }
    } catch (e) {
      print('Error showing interstitial ad: $e');
      onAdFailedToShow?.call();
    }
  }

  // Check if we can show banner ad
  static Future<bool> canShowBannerAd() async {
    return await _adLimitManager.canShowBannerAd();
  }

  // Record banner ad shown
  static Future<void> recordBannerAdShown() async {
    await _adLimitManager.recordBannerAdShown();
  }

  // Check if user can click ad
  static Future<bool> canClickAd() async {
    return await _adLimitManager.canClickAd();
  }

  // Record ad click
  static Future<void> recordAdClick() async {
    await _adLimitManager.recordAdClick();
  }

  // Get ad stats
  static Future<Map<String, int>> getAdStats() async {
    return await _adLimitManager.getAdStats();
  }

  // Reset ad limits (for testing or special cases)
  static Future<void> resetAdLimits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('first_ad_today');
    await prefs.remove('daily_impressions');
    await prefs.remove('daily_clicks');
    await prefs.remove('minute_impressions');
    await prefs.remove('banner_impressions');
    await prefs.remove('interstitial_impressions');
    print('Ad limits reset successfully');
  }

  // Dispose methods
  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _isInterstitialAdLoaded = false;
    _interstitialLoadAttempts = 0;
  }

  // Check if ads are initialized
  static bool get isInitialized => _isAdInitialized;
}
//------------------------------------------

// Ad limit management class
class AdLimitManager {
  static const int maxDailyImpressions = 20;
  static const int maxDailyClicks = 5;
  static const int maxImpressionsPerMinute = 3;
  static const int maxBannerAdsPerHour = 10;
  static const int maxInterstitialAdsPerHour = 3;

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
      print('Error checking banner ad limits: $e');
      return true; // Allow ads if there's an error in limit checking
    }
  }

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
      print('Error checking interstitial ad limits: $e');
      return true; // Allow ads if there's an error in limit checking
    }
  }

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
      print('Error recording banner ad impression: $e');
    }
  }

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
      print('Error recording interstitial ad impression: $e');
    }
  }

  Future<bool> canClickAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _resetIfNewDay(prefs);

      final dailyClicks = prefs.getInt('daily_clicks') ?? 0;
      return dailyClicks < maxDailyClicks;
    } catch (e) {
      print('Error checking ad click limits: $e');
      return true; // Allow clicks if there's an error in limit checking
    }
  }

  Future<void> recordAdClick() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dailyClicks = (prefs.getInt('daily_clicks') ?? 0) + 1;
      await prefs.setInt('daily_clicks', dailyClicks);
    } catch (e) {
      print('Error recording ad click: $e');
    }
  }

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
      print('Error getting ad stats: $e');
      return {
        'daily_impressions': 0,
        'daily_clicks': 0,
        'max_daily_impressions': maxDailyImpressions,
        'max_daily_clicks': maxDailyClicks,
      };
    }
  }

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
      print('Error resetting ad limits: $e');
    }
  }
}
