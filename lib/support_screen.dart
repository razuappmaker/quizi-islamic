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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: Text(
          _isEnglish ? 'Support Us' : 'আমাদের সাপোর্ট করুন',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
        actions: [
          Container(
            margin: EdgeInsets.all(8),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            const SizedBox(height: 30),

            // Why Support Section
            _buildWhySupportSection(),
            const SizedBox(height: 30),

            // Support Methods Section
            _buildSupportMethodsSection(),
            const SizedBox(height: 30),

            // Contact Section
            _buildContactSection(),
            const SizedBox(height: 20),

            // Footer Note
            _buildFooterNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.volunteer_activism, size: 60, color: Colors.green[800]),
            const SizedBox(height: 16),
            Text(
              _isEnglish
                  ? '🌟 Support Islamic Education'
                  : '🌟 ইসলামিক শিক্ষাকে সাপোর্ট করুন',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _isEnglish
                  ? 'Your support helps us maintain and improve this Islamic learning app for millions of users worldwide.'
                  : 'আপনার সাপোর্ট আমাদের লক্ষাধিক ব্যবহারকারীর জন্য এই ইসলামিক লার্নিং অ্যাপটি উন্নত এবং সচল রাখতে সাহায্য করে।',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
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
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEnglish
                  ? '🤲 Why Your Support Matters'
                  : '🤲 আপনার সাপোর্ট কেন গুরুত্বপূর্ণ',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildReasonItem(
              Icons.cloud_upload,
              _isEnglish ? 'Server & Hosting Costs' : 'সার্ভার ও হোস্টিং খরচ',
              _isEnglish
                  ? 'Monthly server maintenance and cloud hosting expenses'
                  : 'মাসিক সার্ভার মেইন্টেনেন্স এবং ক্লাউড হোস্টিং খরচ',
            ),
            _buildReasonItem(
              Icons.developer_mode,
              _isEnglish ? 'App Development' : 'অ্যাপ ডেভেলপমেন্ট',
              _isEnglish
                  ? 'Continuous improvement and new feature development'
                  : 'অ্যাপের উন্নতি এবং নতুন ফিচার যোগ করা',
            ),
            _buildReasonItem(
              Icons.security,
              _isEnglish ? 'Security & Updates' : 'সিকিউরিটি ও আপডেট',
              _isEnglish
                  ? 'Regular security updates and bug fixes'
                  : 'নিয়মিত সিকিউরিটি আপডেট এবং বাগ ফিক্স',
            ),
            _buildReasonItem(
              Icons.ads_click,
              _isEnglish ? 'Ad-Free Experience' : 'এড-ফ্রি এক্সপেরিয়েন্স',
              _isEnglish
                  ? 'Reducing ads and providing better user experience'
                  : 'অ্যাড কমিয়ে ইউজার এক্সপেরিয়েন্স উন্নত করা',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportMethodsSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEnglish ? '💳 Support Methods' : '💳 সাপোর্ট করার পদ্ধতি',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),

            // Google Pay
            _buildSupportMethodCard(
              'Google Pay',
              'গুগল পে',
              'Send support via Google Pay',
              'গুগল পে এর মাধ্যমে সাপোর্ট পাঠান',
              'https://pay.google.com',
              Icons.payment,
              Colors.blue,
            ),
            const SizedBox(height: 12),

            // Bank Transfer
            _buildSupportMethodCard(
              'Bank Transfer',
              'ব্যাংক ট্রান্সফার',
              'Direct bank transfer details',
              'সরাসরি ব্যাংক ট্রান্সফার',
              '',
              Icons.account_balance,
              Colors.green,
            ),
            const SizedBox(height: 12),

            // bKash
            _buildSupportMethodCard(
              'bKash',
              'বিকাশ',
              'Send via bKash mobile banking',
              'বিকাশ মোবাইল ব্যাংকিং এর মাধ্যমে পাঠান',
              'https://bkash.com',
              Icons.phone_android,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportMethodCard(
    String englishTitle,
    String banglaTitle,
    String englishDesc,
    String banglaDesc,
    String url,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEnglish ? englishTitle : banglaTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        _isEnglish ? englishDesc : banglaDesc,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (url.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _launchURL(url),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isEnglish ? 'Donate Now' : 'এখনই ডোনেট করুন'),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEnglish
                          ? 'Contact for bank details:'
                          : 'ব্যাংক ডিটেইলসের জন্য যোগাযোগ করুন:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isEnglish
                          ? 'Email: support@islamicquiz.com\nPhone: +880 XXXX-XXXXXX'
                          : 'ইমেইল: support@islamicquiz.com\nফোন: +৮৮০ XXXX-XXXXXX',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEnglish ? '📞 Contact Information' : '📞 যোগাযোগের তথ্য',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.email,
              _isEnglish ? 'Email' : 'ইমেইল',
              'support@islamicquiz.com',
              'mailto:support@islamicquiz.com',
            ),
            _buildContactItem(
              Icons.phone,
              _isEnglish ? 'Phone' : 'ফোন',
              '+880 XXXX-XXXXXX',
              'tel:+880XXXXXXXXX',
            ),
            _buildContactItem(
              Icons.web,
              _isEnglish ? 'Website' : 'ওয়েবসাইট',
              'www.islamicquiz.com',
              'https://www.islamicquiz.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String value,
    String url,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () => _launchURL(url),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.blue[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite, color: Colors.red, size: 30),
          const SizedBox(height: 8),
          Text(
            _isEnglish
                ? '💝 May Allah reward you for your support and generosity. Your contribution helps spread Islamic knowledge to millions.'
                : '💝 আল্লাহ আপনার সাপোর্ট এবং দানশীলতার জন্য আপনাকে উত্তম প্রতিদান দিন। আপনার অবদান লক্ষাধিক মানুষের মধ্যে ইসলামিক জ্ঞান ছড়িয়ে দিতে সাহায্য করে।',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[800],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isEnglish
                ? 'JazakAllah Khairan for your support!'
                : 'আপনার সাপোর্টের জন্য জাযাকাল্লাহু খাইরান!',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
