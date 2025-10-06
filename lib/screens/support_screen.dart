// support_screen.dart - Updated with Option 4 (Dynamic Daily Data)
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool _isEnglish = false;
  final ScrollController _tickerController = ScrollController();

  // ==================== OPTION 4: DYNAMIC DAILY DATA ====================
  // This will generate different data every day
  // Replace this with real API/Firebase data in production
  List<Map<String, String>> _recentDonations = [];
  int _todayDonationCount = 0;
  bool _showDonationTicker =
      true; // শুধু এই ভেরিয়েবল false করলেই টিকার লুকিয়ে যাবে
  @override
  void initState() {
    super.initState();
    _generateTodayDonations(); // Generate dynamic data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  // ==================== DYNAMIC DATA GENERATION ====================
  void _generateTodayDonations() {
    DateTime now = DateTime.now();
    List<Map<String, String>> donations = [];

    // Different names pool for variety
    List<String> names = [
      'রাজু আহমেদ',
      'কিবরিয়া ইসলাম',
      'أحمد محمد',
      'মোহাম্মদ আলী',
      'ইব্রাহিম হোসেন',
      'فاطمة الزهراء',
      'আয়েশা বেগম',
      'Yusuf Rahman',
      'মারিয়া খাতুন',
      'সাজিদ মিয়া',
      'নূর জাহান',
      'خالد بن سعود',
      'আব্দুল্লাহ',
      'সুমাইয়া',
      'রহিমা',
      'জাকারিয়া',
      'ফারহানা',
      'ওমর',
    ];

    // Different amounts for realism
    List<String> amounts = [
      'USD 25',
      'USD 50',
      'USD 100',
      'BDT 500',
      'BDT 1000',
      'SAR 50',
      'SAR 100',
      'USD 75',
      'BDT 750',
      'SAR 75',
    ];

    // Shuffle names and amounts for daily variety
    names.shuffle();
    amounts.shuffle();

    // Generate different number of donations each day (8-15)
    // Using day of month to create variation
    int donationCount = 8 + (now.day % 8); // Changes daily (8-15)

    for (int i = 0; i < donationCount; i++) {
      String timeText = _getTimeText(i, now);
      donations.add({
        'name': names[i % names.length],
        'amount': amounts[i % amounts.length],
        'currency': 'USD',
        'time': timeText,
      });
    }

    setState(() {
      _recentDonations = donations;
      _todayDonationCount = donationCount;
    });
  }

  String _getTimeText(int index, DateTime now) {
    // Make times relative to current time for realism
    int minutesAgo = (index + 1) * 3 + (now.minute % 15);
    if (minutesAgo < 60) {
      return '$minutesAgo ${_isEnglish ? 'mins ago' : 'মিনিট আগে'}';
    } else {
      int hours = minutesAgo ~/ 60;
      return '$hours ${_isEnglish ? 'hours ago' : 'ঘন্টা আগে'}';
    }
  }

  // ==================== TOGGLE DONATION TICKER VISIBILITY ====================
  void _toggleDonationTicker() {
    setState(() {
      _showDonationTicker = !_showDonationTicker;
    });
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 2), () {
      if (_tickerController.hasClients && mounted && _showDonationTicker) {
        final maxScroll = _tickerController.position.maxScrollExtent;
        final currentScroll = _tickerController.offset;

        if (currentScroll >= maxScroll) {
          _tickerController.jumpTo(0);
        } else {
          _tickerController.animateTo(
            currentScroll + 50,
            duration: Duration(seconds: 15),
            curve: Curves.linear,
          );
        }
        _startAutoScroll();
      }
    });
  }

  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEnglish
              ? '❌ Could not open the link'
              : '❌ লিঙ্কটি খুলতে ব্যর্থ হয়েছে',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showExternalDonationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _isEnglish ? 'Visit Our Website' : 'আমাদের ওয়েবসাইট ভিজিট করুন',
          style: TextStyle(color: Colors.green[800]),
        ),
        content: Text(
          _isEnglish
              ? 'For more donation options and detailed information, please visit our official website. We appreciate your support!'
              : 'আরও ডোনেশন অপশন এবং বিস্তারিত তথ্যের জন্য আমাদের অফিসিয়াল ওয়েবসাইট ভিজিট করুন। আমরা আপনার সাপোর্টের জন্য কৃতজ্ঞ!',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_isEnglish ? 'Cancel' : 'বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              _launchURL('https://www.islamicquiz.com/donate');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            child: Text(_isEnglish ? 'Visit Website' : 'ওয়েবসাইট ভিজিট করুন'),
          ),
        ],
      ),
    );
  }

  // ==================== DONATION TICKER ITEM BUILDER ====================
  Widget _buildDonationTickerItem(Map<String, String> donation, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green[50]!,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // প্রোফাইল আভাতার
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getAvatarColor(index),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                donation['name']!.substring(0, 1),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),

          // ডোনেশন তথ্য
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                donation['name']!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.green[900],
                ),
              ),
              SizedBox(height: 2),
              Text(
                donation['time']!,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(width: 16),

          // ডোনেশন অ্যামাউন্ট
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.green[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              donation['amount']!,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          SizedBox(width: 8),

          // আইকন
          Icon(Icons.volunteer_activism, color: Colors.green[600], size: 16),
        ],
      ),
    );
  }

  Color _getAvatarColor(int index) {
    List<Color> colors = [
      Colors.green[600]!,
      Colors.blue[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.teal[600]!,
      Colors.indigo[600]!,
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: Text(
          _isEnglish ? 'Support Us' : 'আমাদের সাপোর্ট করুন',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ),
        actions: [
          // Toggle Donation Ticker Button
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _showDonationTicker ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _toggleDonationTicker,
              tooltip: _showDonationTicker
                  ? (_isEnglish ? 'Hide Ticker' : 'টিকার লুকান')
                  : (_isEnglish ? 'Show Ticker' : 'টিকার দেখান'),
              splashRadius: 20,
            ),
          ),
          // Language Toggle Button
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isEnglish ? Icons.language : Icons.translate,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _toggleLanguage,
              tooltip: _isEnglish ? 'বাংলা' : 'English',
              splashRadius: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: 24),

              // ==================== LIVE DONATION TICKER SECTION ====================
              // This section can be easily hidden by toggling _showDonationTicker
              if (_showDonationTicker) _buildDonationTickerSection(),

              // Why Support Section
              _buildWhySupportSection(),
              const SizedBox(height: 24),

              // Support Buttons Section
              _buildSupportButtonsSection(),
              const SizedBox(height: 24),

              // Contact Section
              _buildContactSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DONATION TICKER SECTION WIDGET ====================
  Widget _buildDonationTickerSection() {
    return Column(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[50]!, Colors.blue[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header with toggle info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.live_tv, color: Colors.white, size: 16),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _isEnglish ? 'LIVE DONATIONS' : 'লাইভ ডোনেশন',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                        letterSpacing: 1.2,
                      ),
                    ),
                    Spacer(),
                    // Info icon showing this is demo data
                    Tooltip(
                      message: _isEnglish
                          ? 'Demo data - changes daily\nTap eye icon to hide'
                          : 'ডেমো ডেটা - প্রতিদিন পরিবর্তন হয়\nআইকন টেপ করে লুকান',
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.green[600],
                        size: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Ticker Container
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      controller: _tickerController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          ...List.generate(_recentDonations.length, (index) {
                            return _buildDonationTickerItem(
                              _recentDonations[index],
                              index,
                            );
                          }),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                // Stats Row - Now shows dynamic count
                SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_alt,
                        color: Colors.green[800],
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '$_todayDonationCount+ ${_isEnglish ? 'Supporters Today' : 'আজকের সাপোর্টার্স'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.attach_money,
                        color: Colors.green[800],
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        _isEnglish ? 'Multiple Currencies' : 'বহু মুদ্রা',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volunteer_activism,
                size: 36,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isEnglish
                  ? 'Support Islamic Education'
                  : 'ইসলামিক শিক্ষাকে সাপোর্ট করুন',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isEnglish
                  ? 'Your support helps us maintain and improve this app for millions of users worldwide'
                  : 'আপনার সাপোর্ট লক্ষাধিক ব্যবহারকারীর জন্য এই অ্যাপটি উন্নত এবং সচল রাখতে সাহায্য করে',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhySupportSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEnglish
                  ? 'Why Your Support Matters'
                  : 'আপনার সাপোর্ট কেন গুরুত্বপূর্ণ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildReasonItem(
              Icons.cloud_upload,
              _isEnglish ? 'Server & Hosting Costs' : 'সার্ভার ও হোস্টিং খরচ',
              _isEnglish
                  ? 'Monthly server maintenance and cloud hosting'
                  : 'মাসিক সার্ভার মেইন্টেনেন্স এবং ক্লাউড হোস্টিং',
            ),
            _buildReasonItem(
              Icons.developer_mode,
              _isEnglish ? 'App Development' : 'অ্যাপ ডেভেলপমেন্ট',
              _isEnglish
                  ? 'New features and regular updates'
                  : 'নতুন ফিচার এবং নিয়মিত আপডেট',
            ),
            _buildReasonItem(
              Icons.security,
              _isEnglish ? 'Security & Performance' : 'সিকিউরিটি ও পারফরমেন্স',
              _isEnglish
                  ? 'Security updates and performance improvements'
                  : 'সিকিউরিটি আপডেট এবং পারফরমেন্স উন্নতি',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportButtonsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _isEnglish ? 'Make a Difference' : 'একটি পরিবর্তন আনুন',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isEnglish
                            ? 'Google Play Billing will be implemented here'
                            : 'গুগল প্লে বিলিং এখানে ইমপ্লিমেন্ট করা হবে',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart, size: 20),
                label: Text(
                  _isEnglish
                      ? 'Support via Google Play'
                      : 'গুগল প্লে এর মাধ্যমে সাপোর্ট করুন',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showExternalDonationDialog,
                icon: const Icon(Icons.language, size: 20),
                label: Text(
                  _isEnglish
                      ? 'Donate via Website'
                      : 'ওয়েবসাইট এর মাধ্যমে ডোনেট করুন',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[800],
                  side: BorderSide(color: Colors.green[800]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.green[800], size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEnglish ? 'Contact Information' : 'যোগাযোগের তথ্য',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email, 'support@islamicquiz.com'),
            _buildContactItem(Icons.language, 'www.islamicquiz.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
