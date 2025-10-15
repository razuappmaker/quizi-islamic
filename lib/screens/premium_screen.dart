// screens/premium_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/premium_manager.dart';
import '../utils/point_manager.dart';
import '../utils/in_app_purchase_manager.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PremiumManager _premiumManager = PremiumManager();
  final InAppPurchaseManager _purchaseManager = InAppPurchaseManager();

  bool _isLoading = true;
  bool _isProcessing = false;
  Map<String, dynamic> _premiumStatus = {};
  int _userPoints = 0;
  int _currentTabIndex = 0;

  // Multi-language texts
  final Map<String, Map<String, String>> _texts = {
    'title': {'en': 'Premium Subscription', 'bn': 'প্রিমিয়াম সাবস্ক্রিপশন'},
    'premiumExperience': {
      'en': 'Premium Experience',
      'bn': 'প্রিমিয়াম এক্সপেরিয়েন্স',
    },
    'premiumSubtitle': {
      'en': 'Ad-free + Exclusive features',
      'bn': 'সকল অ্যাড মুক্ত + এক্সক্লুসিভ ফিচার',
    },
    'pointsTab': {'en': '🎁 Buy with Points', 'bn': '🎁 পয়েন্ট দিয়ে কিনুন'},
    'moneyTab': {'en': '💳 Buy with Money', 'bn': '💳 টাকা দিয়ে কিনুন'},
    'yourPoints': {'en': 'Your Points', 'bn': 'আপনার পয়েন্ট'},
    'points': {'en': 'Points', 'bn': 'পয়েন্ট'},
    'monthlyPremium': {'en': 'Monthly Premium', 'bn': 'মাসিক প্রিমিয়াম'},
    'yearlyPremium': {'en': 'Yearly Premium', 'bn': 'বার্ষিক প্রিমিয়াম'},
    'bestOffer': {'en': 'Best Offer', 'bn': 'সেরা অফার'},
    'buyNow': {'en': 'Buy Now', 'bn': 'এখনই কিনুন'},
    'freeTrial': {
      'en': '7-day free trial, then',
      'bn': '৭ দিন ফ্রি ট্রায়াল, তারপর',
    },
    'buyWithPoints': {'en': 'Buy with Points', 'bn': 'পয়েন্ট দিয়ে কিনুন'},
    'notEnoughPoints': {'en': 'Not Enough Points', 'bn': 'পয়েন্ট নেই'},
    'pointsRequired': {'en': 'points required', 'bn': 'পয়েন্ট প্রয়োজন'},
    'premiumFeatures': {
      'en': 'Premium Features:',
      'bn': 'প্রিমিয়াম ফিচারসমূহ:',
    },
    'adFree': {'en': '🚫 All Ads Removed', 'bn': '🚫 সকল অ্যাড মুক্ত'},
    'unlimitedQuizzes': {
      'en': '🎯 Unlimited Quiz Access',
      'bn': '🎯 আনলিমিটেড কুইজ এক্সেস',
    },
    'premiumContent': {
      'en': '📚 Exclusive Premium Content',
      'bn': '📚 এক্সক্লুসিভ প্রিমিয়াম কন্টেন্ট',
    },
    'prioritySupport': {
      'en': '⚡ Priority Support',
      'bn': '⚡ প্রায়োরিটি সাপোর্ট',
    },
    'specialBadge': {
      'en': '💎 Special Badge & Status',
      'bn': '💎 বিশেষ ব্যাজ ও স্ট্যাটাস',
    },
    'detailedAnalytics': {
      'en': '📊 Detailed Analytics',
      'bn': '📊 ডিটেইলড এনালিটিক্স',
    },
    'customThemes': {'en': '🎨 Custom Themes & UI', 'bn': '🎨 কাস্টম থিম ও UI'},
    'advancedNotifications': {
      'en': '🔔 Advanced Notifications',
      'bn': '🔔 অ্যাডভান্সড নোটিফিকেশন',
    },
    'premiumUser': {
      'en': 'You are Premium User! 🎉',
      'bn': 'আপনি প্রিমিয়াম ইউজার! 🎉',
    },
    'purchasedWithPoints': {
      'en': '🎁 Purchased with Points',
      'bn': '🎁 পয়েন্ট দিয়ে প্রিমিয়াম নেয়া হয়েছে',
    },
    'purchasedWithMoney': {
      'en': '💳 Purchased with Money',
      'bn': '💳 টাকা দিয়ে প্রিমিয়াম নেয়া হয়েছে',
    },
    'yourPremiumFeatures': {
      'en': 'Your Premium Features:',
      'bn': 'আপনার প্রিমিয়াম ফিচারসমূহ:',
    },
    'subscriptionStatus': {
      'en': 'Your Subscription Status',
      'bn': 'আপনার সাবস্ক্রিপশন স্ট্যাটাস',
    },
    'expiryDate': {'en': 'Expiry Date', 'bn': 'মেয়াদ শেষ'},
    'daysRemaining': {'en': 'Days Remaining', 'bn': 'বাকি দিন'},
    'days': {'en': 'days', 'bn': 'দিন'},
    'comingSoon': {'en': 'Coming Soon', 'bn': 'শীঘ্রই আসছে'},
    'premiumServiceSoon': {
      'en': 'Premium Service Coming Soon!',
      'bn': 'প্রিমিয়াম সেবা শীঘ্রই চালু হচ্ছে!',
    },
    'serviceDescription': {
      'en':
          'We will launch in-app purchase system soon. Meanwhile you can get premium with points.',
      'bn':
          'আমরা খুব শীঘ্রই ইন-অ্যাপ পারচেজ সিস্টেম চালু করব। এর মধ্যে আপনি পয়েন্ট দিয়ে প্রিমিয়াম পেতে পারেন।',
    },
    'activateSuccess': {
      'en': '✅ Premium activated successfully!',
      'bn': '✅ প্রিমিয়াম সক্রিয় হয়েছে!',
    },
    'restartApp': {
      'en': 'Please restart the app',
      'bn': 'অ্যাপ রিস্টার্ট করুন',
    },
    'productNotAvailable': {
      'en': '❌ This product is not available',
      'bn': '❌ এই প্রোডাক্টটি এখন available নয়',
    },
    'purchaseIncomplete': {
      'en': '❌ Purchase not completed, please try again',
      'bn': '❌ পারচেজ সম্পূর্ণ হয়নি, আবার চেষ্টা করুন',
    },
    'purchaseFailed': {'en': '❌ Purchase failed', 'bn': '❌ পারচেজ ব্যর্থ'},
    'voluntaryNotice': {
      'en': 'VOLUNTARY SUPPORT - NO FEATURES RESTRICTED',
      'bn': 'ঐচ্ছিক সহায়তা - কোনো ফিচার সীমাবদ্ধ নয়',
    },
  };

  @override
  void initState() {
    super.initState();
    _initializePurchaseManager();
    _loadData();
    _setupLanguageProvider();
  }

  void _setupLanguageProvider() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    PremiumManager.setLanguageProvider(languageProvider);
  }

  // Helper method to get text based on current language
  String _text(String key, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

  Future<void> _initializePurchaseManager() async {
    await _purchaseManager.initialize();
  }

  Future<void> _loadData() async {
    final status = await _premiumManager.getPremiumStatus();
    final userData = await PointManager.getUserData();

    setState(() {
      _premiumStatus = status;
      _userPoints = userData['pendingPoints'] ?? 0;
      _isLoading = false;
    });
  }

  // 🔥 পয়েন্ট দিয়ে প্রিমিয়াম কিনুন
  Future<void> _purchaseWithPoints(
    String premiumType,
    BuildContext context,
  ) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final success = await _premiumManager.activatePremiumWithPoints(
        premiumType,
        _userPoints,
      );

      if (success) {
        // পয়েন্ট কাটুন
        final pointsRequired =
            PremiumManager.getPremiumPointsRequirements()[premiumType]!['points']
                as int;
        await PointManager.deductPoints(pointsRequired);

        // ডাটা রিলোড করুন
        await _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${PremiumManager.getPremiumPointsRequirements()[premiumType]!['name']} ${_text('activateSuccess', context)}',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 🔥 টাকা দিয়ে প্রিমিয়াম কিনুন
  Future<void> _purchaseWithMoney(
    String productId,
    BuildContext context,
  ) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (!_purchaseManager.isProductAvailable(productId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_text('productNotAvailable', context)),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final success = await _purchaseManager.purchaseProduct(productId);

      if (success) {
        await Future.delayed(const Duration(seconds: 2));
        await _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_text('activateSuccess', context)} ${_text('restartApp', context)}',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_text('purchaseIncomplete', context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_text('purchaseFailed', context)}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 🎨 প্রিমিয়াম ব্যাজ
  Widget _buildPremiumBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.purple[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 ফিচার রো
  Widget _buildFeatureRow(
    String featureKey,
    BuildContext context, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: isHighlighted ? Colors.green[700] : Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _text(featureKey, context),
              style: TextStyle(
                fontSize: 15,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
                color: isHighlighted ? Colors.green[700] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 Voluntary Notice Banner
  Widget _buildVoluntaryNotice(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[800], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _text('voluntaryNotice', context),
              style: TextStyle(
                color: Colors.orange[800],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 টাকা দিয়ে কেনার কার্ড - প্রফেশনাল ডিজাইন
  Widget _buildMoneyPurchaseCard(String productId, BuildContext context) {
    final isProductAvailable = _purchaseManager.isProductAvailable(productId);
    final priceConfig = PremiumManager.getPremiumPriceConfig();
    final config = productId == PremiumManager.monthlyPremiumId
        ? priceConfig['monthly']!
        : priceConfig['yearly']!;

    final isYearly = productId == PremiumManager.yearlyPremiumId;
    final isPopular = isYearly;

    return Card(
      elevation: isPopular ? 6 : 3,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular
            ? BorderSide(color: Colors.orange, width: 2)
            : BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: isPopular
              ? LinearGradient(
                  colors: [Colors.blue[50]!, Colors.orange[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.white, Colors.grey[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // পপুলার ব্যাজ
            if (isPopular)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _text('bestOffer', context),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // হেডার
                  Row(
                    children: [
                      Icon(
                        isYearly ? Icons.star : Icons.favorite,
                        color: isYearly ? Colors.orange : Colors.blue,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        isYearly
                            ? _text('yearlyPremium', context)
                            : _text('monthlyPremium', context),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isYearly
                              ? Colors.orange[800]
                              : Colors.blue[800],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // প্রাইস
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config['price'],
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isYearly
                              ? Colors.orange[800]
                              : Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '/${config['period']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // সেভিংস
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      config['savings'],
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // বাটন
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isProductAvailable && !_isProcessing
                          ? () => _purchaseWithMoney(productId, context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isYearly ? Colors.orange : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: isYearly
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.3),
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _text('buyNow', context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 8),

                  // ফ্রি ট্রায়াল নোট
                  Text(
                    '${_text('freeTrial', context)} ${config['price']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 পয়েন্ট দিয়ে কেনার কার্ড - প্রফেশনাল ডিজাইন
  Widget _buildPointsPurchaseCard(String premiumType, BuildContext context) {
    final pointsOptions = PremiumManager.getPremiumPointsRequirements();
    final config = pointsOptions[premiumType]!;
    final hasEnoughPoints = _userPoints >= config['points'];
    final isYearly = premiumType == 'yearly';

    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.deepPurple[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // হেডার
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.purple, size: 24),
                  SizedBox(width: 8),
                  Text(
                    config['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // পয়েন্ট
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${config['points']} ${_text('points', context)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    config['duration'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // সেভিংস
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  config['savings'],
                  style: TextStyle(
                    color: Colors.green[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // বাটন
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasEnoughPoints && !_isProcessing
                      ? () => _purchaseWithPoints(premiumType, context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          hasEnoughPoints
                              ? _text('buyWithPoints', context)
                              : _text('notEnoughPoints', context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              if (!hasEnoughPoints) ...[
                SizedBox(height: 8),
                Text(
                  '${config['points'] - _userPoints} ${_text('pointsRequired', context)}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;
    final isPremium = _premiumStatus['isPremium'] == true;
    final premiumSource = _premiumStatus['source'] ?? 'none';
    final areProductsAvailable = _purchaseManager.areProductsAvailable;

    // Calculate safe area padding to avoid system UI
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text('title', context),
          style: TextStyle(
            fontSize: isSmallScreen
                ? 16
                : isTablet
                ? 20
                : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [if (isPremium) _buildPremiumBadge(context)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : isPremium
          ? _buildPremiumUserScreen(premiumSource, screenWidth, context)
          : _buildPurchaseScreen(screenWidth, areProductsAvailable, context),
    );
  }

  Widget _buildPurchaseScreen(
    double screenWidth,
    bool areProductsAvailable,
    BuildContext context,
  ) {
    final isTablet = screenWidth > 600;

    return SafeArea(
      bottom: true, // Ensure content stays above system navigation bar
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          child: Column(
            children: [
              // Voluntary Notice
              _buildVoluntaryNotice(context),

              // হেডার সেকশন
              _buildHeaderSection(context),

              // ট্যাব বার
              _buildTabBar(context),

              // কন্টেন্ট - ট্যাব ভিত্তিক
              _currentTabIndex == 0
                  ? _buildPointsTab(screenWidth, context)
                  : _buildMoneyTab(screenWidth, areProductsAvailable, context),

              // ফিচার সেকশন
              _buildFeaturesSection(context),

              // Bottom padding to ensure content doesn't get hidden
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.purple[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium,
            size: isTablet ? 80 : 60,
            color: Colors.white,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            _text('premiumExperience', context),
            style: TextStyle(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            _text('premiumSubtitle', context),
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _currentTabIndex = 0),
              style: TextButton.styleFrom(
                backgroundColor: _currentTabIndex == 0
                    ? Colors.purple
                    : Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _text('pointsTab', context),
                style: TextStyle(
                  color: _currentTabIndex == 0 ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _currentTabIndex = 1),
              style: TextButton.styleFrom(
                backgroundColor: _currentTabIndex == 1
                    ? Colors.blue
                    : Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _text('moneyTab', context),
                style: TextStyle(
                  color: _currentTabIndex == 1 ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsTab(double screenWidth, BuildContext context) {
    final isTablet = screenWidth > 600;
    final pointsOptions = PremiumManager.getPremiumPointsRequirements();

    return Column(
      children: [
        // পয়েন্ট ইনফো
        _buildPointsInfo(screenWidth, context),

        // প্রিমিয়াম কার্ডস - ট্যাবলেটের জন্য গ্রিড
        if (isTablet)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 0.8,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: pointsOptions.keys.map((premiumType) {
                return _buildPointsPurchaseCard(premiumType, context);
              }).toList(),
            ),
          )
        else
          Column(
            children: pointsOptions.keys.map((premiumType) {
              return _buildPointsPurchaseCard(premiumType, context);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPointsInfo(double screenWidth, BuildContext context) {
    final isTablet = screenWidth > 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      margin: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Colors.orange,
            size: isTablet ? 32 : 24,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('yourPoints', context),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 14,
                  ),
                ),
                Text(
                  '$_userPoints ${_text('points', context)}',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyTab(
    double screenWidth,
    bool areProductsAvailable,
    BuildContext context,
  ) {
    final isTablet = screenWidth > 600;

    return Column(
      children: [
        if (!areProductsAvailable) _buildComingSoonMessage(context),
        SizedBox(height: isTablet ? 20 : 16),

        // প্রিমিয়াম কার্ডস - ট্যাবলেটের জন্য গ্রিড
        if (isTablet)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 0.85,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMoneyPurchaseCard(
                  PremiumManager.monthlyPremiumId,
                  context,
                ),
                _buildMoneyPurchaseCard(
                  PremiumManager.yearlyPremiumId,
                  context,
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              // মাসিক প্রিমিয়াম
              _buildMoneyPurchaseCard(PremiumManager.monthlyPremiumId, context),

              // বার্ষিক প্রিমিয়াম
              _buildMoneyPurchaseCard(PremiumManager.yearlyPremiumId, context),
            ],
          ),
      ],
    );
  }

  Widget _buildComingSoonMessage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      margin: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        children: [
          Icon(Icons.info, color: Colors.orange, size: isTablet ? 50 : 40),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            _text('premiumServiceSoon', context),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
              fontSize: isTablet ? 20 : 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            _text('serviceDescription', context),
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: isTablet ? 16 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _text('premiumFeatures', context),
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          _buildFeatureRow('adFree', context, isHighlighted: true),
          _buildFeatureRow('unlimitedQuizzes', context, isHighlighted: true),
          _buildFeatureRow('premiumContent', context, isHighlighted: true),
          _buildFeatureRow('prioritySupport', context, isHighlighted: true),
          _buildFeatureRow('specialBadge', context, isHighlighted: true),
          _buildFeatureRow('detailedAnalytics', context),
          _buildFeatureRow('customThemes', context),
          _buildFeatureRow('advancedNotifications', context),
        ],
      ),
    );
  }

  Widget _buildPremiumUserScreen(
    String source,
    double screenWidth,
    BuildContext context,
  ) {
    final isTablet = screenWidth > 600;
    final isLifetime = _premiumStatus['isLifetime'] == true;
    final expiryDate = _premiumStatus['expiryDate'];

    return SafeArea(
      bottom: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          children: [
            Icon(
              Icons.verified_user,
              size: isTablet ? 100 : 80,
              color: Colors.green[700],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Text(
              _text('premiumUser', context),
              style: TextStyle(
                fontSize: isTablet ? 32 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              source == 'points'
                  ? _text('purchasedWithPoints', context)
                  : _text('purchasedWithMoney', context),
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 40 : 32),

            // ফিচারস
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: Column(
                  children: [
                    Text(
                      _text('yourPremiumFeatures', context),
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    _buildFeatureRow('adFree', context, isHighlighted: true),
                    _buildFeatureRow(
                      'unlimitedQuizzes',
                      context,
                      isHighlighted: true,
                    ),
                    _buildFeatureRow(
                      'premiumContent',
                      context,
                      isHighlighted: true,
                    ),
                    _buildFeatureRow(
                      'prioritySupport',
                      context,
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),
            ),

            if (!isLifetime && expiryDate != null) ...[
              SizedBox(height: isTablet ? 32 : 24),
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      _text('subscriptionStatus', context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 22 : 18,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Text(
                      '${_text('expiryDate', context)}: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      '${_text('daysRemaining', context)}: ${_premiumStatus['daysRemaining']} ${_text('days', context)}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Bottom padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _purchaseManager.dispose();
    super.dispose();
  }
}
