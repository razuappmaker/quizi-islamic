// screens/premium_screen.dart
import 'package:flutter/material.dart';
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
  int _currentTabIndex = 0; // 0 = Points, 1 = Money

  @override
  void initState() {
    super.initState();
    _initializePurchaseManager();
    _loadData();
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
  Future<void> _purchaseWithPoints(String premiumType) async {
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
              '✅ ${PremiumManager.getPremiumPointsRequirements()[premiumType]!['name']} সক্রিয় হয়েছে!',
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
  Future<void> _purchaseWithMoney(String productId) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (!_purchaseManager.isProductAvailable(productId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ এই প্রোডাক্টটি এখন available নয়'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final success = await _purchaseManager.purchaseProduct(productId);

      if (success) {
        // Wait a moment for purchase to process
        await Future.delayed(const Duration(seconds: 2));
        await _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ প্রিমিয়াম সক্রিয় হয়েছে! অ্যাপ রিস্টার্ট করুন।'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ পারচেজ সম্পূর্ণ হয়নি, আবার চেষ্টা করুন'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ পারচেজ ব্যর্থ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'প্রিমিয়াম',
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

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 18),
          SizedBox(width: 10),
          Expanded(child: Text(feature, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // 🔥 টাকা দিয়ে কেনার কার্ড - সম্পূর্ণ রেসপনসিভ
  Widget _buildMoneyPurchaseCard(
    String productId,
    Map<String, dynamic> config,
  ) {
    final isProductAvailable = _purchaseManager.isProductAvailable(productId);
    final actualPrice = _purchaseManager.getProductPrice(productId);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final isVerySmall = cardWidth < 150;
        final isSmall = cardWidth < 200;

        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: isVerySmall ? 180 : (isSmall ? 200 : 220),
            maxHeight: isVerySmall ? 220 : (isSmall ? 240 : 260),
          ),
          child: Card(
            elevation: 3,
            margin: EdgeInsets.all(4),
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(isVerySmall ? 8 : (isSmall ? 10 : 12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Content - Icon and Text
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          color: Colors.blue,
                          size: isVerySmall ? 24 : (isSmall ? 28 : 32),
                        ),
                        SizedBox(height: isVerySmall ? 4 : 6),
                        Flexible(
                          child: Text(
                            config['name'],
                            style: TextStyle(
                              fontSize: isVerySmall ? 10 : (isSmall ? 12 : 14),
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            config['description'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isVerySmall ? 8 : (isSmall ? 9 : 10),
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: isVerySmall ? 4 : 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            actualPrice,
                            style: TextStyle(
                              fontSize: isVerySmall ? 12 : (isSmall ? 14 : 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        if (!isProductAvailable) ...[
                          SizedBox(height: 2),
                          Text(
                            'শীঘ্রই আসছে',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: isVerySmall ? 8 : 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Bottom Content - Button
                  Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isProductAvailable && !_isProcessing
                                ? () => _purchaseWithMoney(productId)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isVerySmall ? 6 : (isSmall ? 8 : 10),
                                horizontal: 4,
                              ),
                              minimumSize: Size(0, isVerySmall ? 28 : 32),
                            ),
                            child: _isProcessing
                                ? SizedBox(
                                    width: isVerySmall ? 12 : 14,
                                    height: isVerySmall ? 12 : 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isProductAvailable
                                          ? 'ক্রয় করুন'
                                          : 'শীঘ্রই আসছে',
                                      style: TextStyle(
                                        fontSize: isVerySmall
                                            ? 10
                                            : (isSmall ? 11 : 12),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenWidth < 380;
    final isPremium = _premiumStatus['isPremium'] == true;
    final premiumSource = _premiumStatus['source'] ?? 'none';
    final areProductsAvailable = _purchaseManager.areProductsAvailable;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'প্রিমিয়াম সাবস্ক্রিপশন',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ),
        actions: [if (isPremium) _buildPremiumBadge()],
      ),
      body: SafeArea(
        bottom: true, // ✅ Bottom safe area ensure
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : isPremium
            ? _buildPremiumUserScreen(premiumSource, screenWidth)
            : _buildPurchaseScreen(screenWidth, areProductsAvailable),
      ),
    );
  }

  Widget _buildPurchaseScreen(double screenWidth, bool areProductsAvailable) {
    return SafeArea(
      bottom: true, // ✅ Additional safety
      child: Column(
        children: [
          // User Points Info
          _buildPointsInfo(screenWidth),

          // Tab Bar
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: _currentTabIndex == 0
                ? _buildPointsTab(screenWidth)
                : _buildMoneyTab(screenWidth, areProductsAvailable),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsInfo(double screenWidth) {
    final isSmallScreen = screenWidth < 380;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      color: Colors.orange[50],
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Colors.orange,
            size: isSmallScreen ? 20 : 24,
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আপনার পয়েন্ট',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                Text(
                  '$_userPoints পয়েন্ট',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
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

  Widget _buildTabBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Container(
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _currentTabIndex = 0),
              style: TextButton.styleFrom(
                backgroundColor: _currentTabIndex == 0
                    ? Colors.purple
                    : Colors.transparent,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16,
                ),
              ),
              child: Text(
                '🎁 পয়েন্ট দিয়ে কিনুন',
                style: TextStyle(
                  color: _currentTabIndex == 0 ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 12 : 14,
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
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16,
                ),
              ),
              child: Text(
                '💳 টাকা দিয়ে কিনুন',
                style: TextStyle(
                  color: _currentTabIndex == 1 ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 FIXED: পয়েন্ট দিয়ে কেনার ট্যাব - মোবাইল ও ট্যাবলেট ফ্রেন্ডলি
  Widget _buildPointsTab(double screenWidth) {
    final pointsOptions = PremiumManager.getPremiumPointsRequirements();

    // Responsive grid configuration
    final crossAxisCount = screenWidth < 600 ? 2 : 4;
    final childAspectRatio = screenWidth < 600
        ? 0.85
        : 1.0; // Reduced aspect ratio

    final isSmallScreen = screenWidth < 380;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'কুইজ খেলে পয়েন্ট জমা করুন এবং ফ্রিতে প্রিমিয়াম পান',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 12),

          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 8, // Reduced spacing
              mainAxisSpacing: 8,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(8),
            itemCount: pointsOptions.length,
            itemBuilder: (context, index) {
              final keys = pointsOptions.keys.toList();
              final premiumType = keys[index];
              final config = pointsOptions[premiumType]!;

              return _buildFlexiblePointsCard(
                premiumType,
                config,
                isSmallScreen,
              );
            },
          ),
          SizedBox(height: 16),
          _buildFeaturesSection(isSmallScreen),
        ],
      ),
    );
  }

  // 🔥 FIXED: Removed Flexible and fixed overflow issues
  Widget _buildFlexiblePointsCard(
    String premiumType,
    Map<String, dynamic> config,
    bool isSmallScreen,
  ) {
    final hasEnoughPoints = _userPoints >= config['points'];

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      color: Colors.purple[50],
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Content - Icon and Title
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.purple,
                  size: isSmallScreen ? 22 : 28,
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  config['name'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  config['duration'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 8 : 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 6 : 8),

            // Middle Content - Points
            FittedBox(
              child: Text(
                '${config['points']} পয়েন্ট',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: isSmallScreen ? 6 : 8),

            // Bottom Content - Button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: hasEnoughPoints && !_isProcessing
                        ? () => _purchaseWithPoints(premiumType)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 4 : 6,
                        horizontal: 4,
                      ),
                      minimumSize: Size(0, isSmallScreen ? 28 : 32),
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            width: isSmallScreen ? 12 : 14,
                            height: isSmallScreen ? 12 : 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              hasEnoughPoints ? 'কিনুন' : 'পয়েন্ট নেই',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ),
                if (!hasEnoughPoints) ...[
                  SizedBox(height: 2),
                  FittedBox(
                    child: Text(
                      '${config['points'] - _userPoints} পয়েন্ট প্রয়োজন',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: isSmallScreen ? 7 : 9,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 FIXED: টাকা দিয়ে কেনার ট্যাব - মোবাইল ও ট্যাবলেট ফ্রেন্ডলি
  Widget _buildMoneyTab(double screenWidth, bool areProductsAvailable) {
    // Responsive grid configuration
    final crossAxisCount = screenWidth < 600 ? 2 : 4;
    final childAspectRatio = screenWidth < 600 ? 0.85 : 0.9;

    final isSmallScreen = screenWidth < 380;

    // Product configurations
    final productConfigs = [
      {
        'id': PremiumManager.monthlyPremiumId,
        'name': 'মাসিক প্রিমিয়াম',
        'description': '১ মাসের জন্য অ্যাড-ফ্রি',
      },
      {
        'id': PremiumManager.yearlyPremiumId,
        'name': 'বার্ষিক প্রিমিয়াম',
        'description': '১ বছরের জন্য অ্যাড-ফ্রি',
      },
      {
        'id': PremiumManager.lifetimePremiumId,
        'name': 'লাইফটাইম প্রিমিয়াম',
        'description': 'আজীবন অ্যাড-ফ্রি',
      },
      {
        'id': PremiumManager.removeAdsId,
        'name': 'অ্যাড রিমুভাল',
        'description': 'স্থায়ীভাবে অ্যাড মুছুন',
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      child: Column(
        children: [
          // 🔥 IMPORTANT: Information Message
          if (!areProductsAvailable) _buildComingSoonMessage(),

          SizedBox(height: 16),

          // 🔥 FIXED: Responsive Grid with proper height
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(4),
            itemCount: productConfigs.length,
            itemBuilder: (context, index) {
              final config = productConfigs[index];
              return _buildMoneyPurchaseCard(config['id']!, {
                'name': config['name'],
                'description': config['description'],
              });
            },
          ),

          SizedBox(height: 20),
          _buildPurchaseInstructions(isSmallScreen),
          SizedBox(height: 20),
          _buildFeaturesSection(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildComingSoonMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        children: [
          Icon(Icons.info, color: Colors.orange, size: 40),
          SizedBox(height: 8),
          Text(
            'প্রিমিয়াম সেবা শীঘ্রই চালু হচ্ছে!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'আমরা খুব শীঘ্রই ইন-অ্যাপ পারচেজ সিস্টেম চালু করব। এর মধ্যে আপনি পয়েন্ট দিয়ে প্রিমিয়াম পেতে পারেন।',
            style: TextStyle(color: Colors.orange[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseInstructions(bool isSmallScreen) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💰 কিভাবে ক্রয় করবেন:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            _buildInstructionStep(
              '১. প্রিমিয়াম প্ল্যান সিলেক্ট করুন',
              isSmallScreen,
            ),
            _buildInstructionStep(
              '২. "ক্রয় করুন" বাটনে ক্লিক করুন',
              isSmallScreen,
            ),
            _buildInstructionStep('৩. পেমেন্ট সম্পন্ন করুন', isSmallScreen),
            _buildInstructionStep('৪. অ্যাপটি রিস্টার্ট করুন', isSmallScreen),
            _buildInstructionStep(
              '৫. প্রিমিয়াম ফিচার উপভোগ করুন!',
              isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.green)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isSmallScreen) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'প্রিমিয়াম ফিচারসমূহ:',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildFeatureRow('🚫 সকল অ্যাড মুক্ত'),
            _buildFeatureRow('🎯 আনলিমিটেড কুইজ এক্সেস'),
            _buildFeatureRow('📚 এক্সক্লুসিভ কন্টেন্ট'),
            _buildFeatureRow('⚡ প্রায়োরিটি সাপোর্ট'),
            _buildFeatureRow('💎 বিশেষ ব্যাজ ও স্ট্যাটাস'),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumUserScreen(String source, double screenWidth) {
    final isLifetime = _premiumStatus['isLifetime'] == true;
    final expiryDate = _premiumStatus['expiryDate'];
    final isSmallScreen = screenWidth < 400;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          Icon(
            Icons.verified_user,
            size: isSmallScreen ? 60 : 80,
            color: Colors.green[700],
          ),
          SizedBox(height: 16),
          Text(
            'আপনি প্রিমিয়াম ইউজার! 🎉',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            source == 'points'
                ? '🎁 পয়েন্ট দিয়ে প্রিমিয়াম নেয়া হয়েছে'
                : '💳 টাকা দিয়ে প্রিমিয়াম নেয়া হয়েছে',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Card(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                children: [
                  _buildFeatureRow('✅ সকল অ্যাড মুক্ত'),
                  _buildFeatureRow('✅ আনলিমিটেড কুইজ এক্সেস'),
                  _buildFeatureRow('✅ প্রিমিয়াম কন্টেন্ট'),
                  _buildFeatureRow('✅ প্রায়োরিটি সাপোর্ট'),
                ],
              ),
            ),
          ),
          if (!isLifetime && expiryDate != null) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'আপনার সাবস্ক্রিপশন স্ট্যাটাস',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'মেয়াদ শেষ: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                  ),
                  Text(
                    'বাকি দিন: ${_premiumStatus['daysRemaining']} দিন',
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _purchaseManager.dispose();
    super.dispose();
  }
}
