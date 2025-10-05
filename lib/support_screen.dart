// support_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool _isEnglish = false;
  final List<Map<String, String>> _recentDonations = [
    {'name': 'রাজু', 'amount': 'USD 59', 'currency': 'USD'},
    {'name': 'কুদদুস', 'amount': 'SAR 29.99', 'currency': 'SAR'},
    {'name': 'أحمد', 'amount': 'دينار 300', 'currency': 'Dinar'},
    {'name': 'মোহাম্মদ', 'amount': 'USD 25', 'currency': 'USD'},
    {'name': 'ইব্রাহিম', 'amount': 'BDT 500', 'currency': 'BDT'},
    {'name': 'فاطمة', 'amount': 'دينار 150', 'currency': 'Dinar'},
    {'name': 'আয়েশা', 'amount': 'SAR 50', 'currency': 'SAR'},
    {'name': 'Yusuf', 'amount': 'USD 35', 'currency': 'USD'},
    {'name': 'মারিয়া', 'amount': 'BDT 300', 'currency': 'BDT'},
  ];

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

  Widget _buildDonationItem(Map<String, String> donation, int index) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.green[100],
            radius: 20,
            child: Text(
              donation['name']!.substring(0, 1),
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            donation['name']!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              donation['amount']!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
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

              // Recent Supporters Section - Horizontal Scrolling
              // Recent Supporters Section - Scrolling Text
              // Recent Supporters Section - Marquee Scrolling Text
              // Recent Supporters Section - Simple Scrolling Text
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 20,
                            color: Colors.green[800],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEnglish
                                ? 'Recent Supporters'
                                : 'সাম্প্রতিক সাপোর্টার্স',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recentDonations.length,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemBuilder: (context, index) {
                              final donation = _recentDonations[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '🎉 ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    Text(
                                      '${donation['name']!} ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[900],
                                      ),
                                    ),
                                    Text(
                                      _isEnglish ? 'donated' : 'ডোনেট করেছেন',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      ' ${donation['amount']!} • ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Why Support Section
              _buildWhySupportSection(),
              const SizedBox(height: 24),

              // Support Buttons Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

                      // Google Play Donation Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Implement Google Play Billing
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

                      // Website Donation Button
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
              ),
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
