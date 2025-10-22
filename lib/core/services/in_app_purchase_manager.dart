// utils/in_app_purchase_manager.dart - ROBUST VERSION
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../managers/premium_manager.dart';

class InAppPurchaseManager {
  static final InAppPurchaseManager _instance =
      InAppPurchaseManager._internal();

  factory InAppPurchaseManager() => _instance;

  InAppPurchaseManager._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isInitialized = false;
  bool _hasValidProducts = false;

  // 🔥 PRODUCT IDs - আপনি পরে Google Console এ create করবেন
  static const String monthlyPremiumId = 'monthly_premium';
  static const String yearlyPremiumId = 'yearly_premium';
  static const String lifetimePremiumId = 'lifetime_premium';
  static const String removeAdsId = 'remove_ads';

  // Product configurations - UI তে show করার জন্য
  final Map<String, Map<String, dynamic>> _productConfigs = {
    monthlyPremiumId: {
      'name': 'মাসিক প্রিমিয়াম',
      'description': '১ মাসের জন্য অ্যাড-ফ্রি এক্সপেরিয়েন্স',
      'duration': 30,
      'demoPrice': '৳ ১৫০/মাস', // 🔥 Demo price
    },
    yearlyPremiumId: {
      'name': 'বার্ষিক প্রিমিয়াম',
      'description': '১ বছরের জন্য অ্যাড-ফ্রি এক্সপেরিয়েন্স',
      'duration': 365,
      'demoPrice': '৳ ১,২০০/বছর',
    },
    lifetimePremiumId: {
      'name': 'লাইফটাইম প্রিমিয়াম',
      'description': 'আজীবন অ্যাড-ফ্রি এক্সপেরিয়েন্স',
      'duration': null,
      'demoPrice': '৳ ২,৫০০',
    },
    removeAdsId: {
      'name': 'অ্যাড রিমুভাল',
      'description': 'স্থায়ীভাবে অ্যাড মুছুন',
      'duration': null,
      'demoPrice': '৳ ৫০০',
    },
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isAvailable = await _inAppPurchase.isAvailable();

      if (!_isAvailable) {
        print('⚠️ ইন-অ্যাপ পারচেজ এই ডিভাইসে available নয়');
        _hasValidProducts = false;
        return;
      }

      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => print('❌ Purchase stream error: $error'),
      );

      // Load products
      await _loadProducts();

      _isInitialized = true;
      print('✅ ইন-অ্যাপ পারচেজ ম্যানেজার initialized হয়েছে');
    } catch (e) {
      print('❌ ইন-অ্যাপ পারচেজ initialize করতে ত্রুটি: $e');
      _hasValidProducts = false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = _productConfigs.keys.toSet();
      print('🔄 প্রোডাক্ট লোড করা হচ্ছে: $productIds');

      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ এই প্রোডাক্টগুলো পাওয়া যায়নি: ${response.notFoundIDs}');
        print('💡 এগুলো পরে Google Play Console এ create করবেন');
      }

      if (response.error != null) {
        print('❌ প্রোডাক্ট লোড করতে এরর: ${response.error}');
      }

      setState(() {
        _products = response.productDetails;
        _hasValidProducts = _products.isNotEmpty;
      });

      print('✅ ${_products.length} টি প্রোডাক্ট লোড হয়েছে');

      // Available products print করুন
      if (_products.isNotEmpty) {
        print('🎉 Available Products:');
        for (var product in _products) {
          print('   ✅ ${product.id} - ${product.price}');
        }
      } else {
        print(
          '💡 কোনো প্রোডাক্ট available নেই। পরে Google Console এ create করবেন।',
        );
      }
    } catch (e) {
      print('❌ প্রোডাক্ট লোড করতে ত্রুটি: $e');
      _hasValidProducts = false;
    }
  }

  Future<bool> purchaseProduct(String productId) async {
    try {
      if (!_isAvailable || !_hasValidProducts) {
        print('❌ ইন-অ্যাপ পারচেজ available নয় অথবা কোনো প্রোডাক্ট নেই');
        _showNotAvailableMessage();
        return false;
      }

      if (!isProductAvailable(productId)) {
        print('❌ এই প্রোডাক্টটি available নয়: $productId');
        _showNotAvailableMessage();
        return false;
      }

      final product = _products.firstWhere((p) => p.id == productId);

      print('🔄 পারচেজ শুরু হচ্ছে: $productId - ${product.price}');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final bool purchaseSuccess = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (purchaseSuccess) {
        print('✅ পারচেজ শুরু হয়েছে: $productId');
        return true;
      } else {
        print('❌ পারচেজ শুরু করতে ব্যর্থ: $productId');
        return false;
      }
    } catch (e) {
      print('❌ পারচেজ শুরু করতে ত্রুটি: $e');
      _showNotAvailableMessage();
      return false;
    }
  }

  void _showNotAvailableMessage() {
    // আপনি এখানে user কে message show করতে পারেন
    print('💡 প্রোডাক্টগুলো শীঘ্রই available হবে।');
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  void _handlePurchase(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
        await _handleSuccessfulPurchase(purchaseDetails);
        break;
      case PurchaseStatus.error:
        print('❌ পারচেজ এরর: ${purchaseDetails.error?.message}');
        break;
      case PurchaseStatus.pending:
        print('⏳ পারচেজ পেন্ডিং: ${purchaseDetails.productID}');
        break;
      case PurchaseStatus.restored:
        await _handleSuccessfulPurchase(purchaseDetails);
        break;
      default:
        print('ℹ️ Purchase status: ${purchaseDetails.status}');
    }
  }

  Future<void> _handleSuccessfulPurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    try {
      final productId = purchaseDetails.productID;
      final config = _productConfigs[productId];

      if (config != null) {
        await PremiumManager().activatePremiumWithPurchase(
          productId: productId,
          durationInDays: config['duration'] ?? 30,
        );

        print('✅ প্রিমিয়াম এক্টিভেটেড: $productId');

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    } catch (e) {
      print('❌ পারচেজ হ্যান্ডেল করতে ত্রুটি: $e');
    }
  }

  List<ProductDetails> get products => _products;

  bool get isAvailable => _isAvailable;

  bool get isInitialized => _isInitialized;

  bool get hasValidProducts => _hasValidProducts;

  Map<String, dynamic>? getProductConfig(String productId) {
    return _productConfigs[productId];
  }

  // 🔥 Get product price - যদি available না থাকে demo price show করবে
  String getProductPrice(String productId) {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      return product.price;
    } catch (e) {
      return _productConfigs[productId]?['demoPrice'] ?? 'শীঘ্রই আসছে';
    }
  }

  // 🔥 Check if product is available
  bool isProductAvailable(String productId) {
    return _products.any((product) => product.id == productId);
  }

  // 🔥 Check if ANY product is available
  bool get areProductsAvailable => _products.isNotEmpty;

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }

  void setState(VoidCallback callback) {
    callback();
  }
}
