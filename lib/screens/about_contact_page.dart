// screens/about_contact_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../profile_screen.dart';
import '../providers/language_provider.dart';
import '../utils/responsive_utils.dart';

class AboutContactPage extends StatelessWidget {
  const AboutContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Tablet = isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          isEnglish ? 'About & Contact' : 'আমাদের সাথে যোগাযোগ',
          fontSize: Tablet ? 20 : 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: Tablet ? 28 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(
                responsiveValue(context, Tablet ? 20 : 16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeaderSection(context, isEnglish, isDark, Tablet),

                      SizedBox(
                        height: responsiveValue(context, Tablet ? 30 : 24),
                      ),

                      // Features Section
                      _buildFeaturesSection(context, isEnglish, isDark, Tablet),

                      SizedBox(
                        height: responsiveValue(context, Tablet ? 30 : 24),
                      ),

                      // Rewards Section
                      _buildRewardsSection(context, isEnglish, isDark, Tablet),

                      SizedBox(
                        height: responsiveValue(context, Tablet ? 30 : 24),
                      ),

                      // Contact Section
                      _buildContactSection(context, isEnglish, isDark, Tablet),

                      SizedBox(
                        height: responsiveValue(context, Tablet ? 30 : 24),
                      ),

                      // Footer Section
                      _buildFooterSection(context, isEnglish, isDark, Tablet),

                      // Bottom spacing for safety
                      SizedBox(height: responsiveValue(context, 20)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    bool isEnglish,
    bool isDark,
    bool isTablet,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsiveValue(context, isTablet ? 24 : 20)),
        child: Column(
          children: [
            // App Icon
            Container(
              width: responsiveValue(context, isTablet ? 100 : 80),
              height: responsiveValue(context, isTablet ? 100 : 80),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                border: Border.all(
                  color: Colors.green[300]!,
                  width: isTablet ? 4 : 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isTablet ? 21 : 17),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: responsiveValue(context, isTablet ? 100 : 80),
                  height: responsiveValue(context, isTablet ? 100 : 80),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.mosque,
                      size: responsiveValue(context, isTablet ? 40 : 30),
                      color: Colors.green[700],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: responsiveValue(context, isTablet ? 20 : 16)),

            // Welcome Text
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveValue(context, isTablet ? 20 : 16),
                vertical: responsiveValue(context, isTablet ? 16 : 12),
              ),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                border: Border(
                  left: BorderSide(
                    color: Colors.green[400]!,
                    width: isTablet ? 5 : 4,
                  ),
                  right: BorderSide(
                    color: Colors.green[400]!,
                    width: isTablet ? 5 : 4,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '✨',
                    style: TextStyle(
                      fontSize: responsiveValue(context, isTablet ? 22 : 18),
                    ),
                  ),
                  SizedBox(width: responsiveValue(context, isTablet ? 12 : 8)),
                  Expanded(
                    child: Text(
                      isEnglish
                          ? 'Welcome to Islamic Day App'
                          : 'ইসলামিক ডে অ্যাপে আপনাকে স্বাগতম',
                      style: TextStyle(
                        fontSize: responsiveValue(context, isTablet ? 18 : 16),
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: responsiveValue(context, isTablet ? 12 : 8)),
                  Text(
                    '🌙',
                    style: TextStyle(
                      fontSize: responsiveValue(context, isTablet ? 22 : 18),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: responsiveValue(context, isTablet ? 20 : 12)),

            // Description
            Container(
              padding: EdgeInsets.all(
                responsiveValue(context, isTablet ? 28 : 24),
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.green[900]!.withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                border: Border.all(
                  color: isDark ? Colors.green[700]! : Colors.green[100]!,
                  width: 2,
                ),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: isEnglish
                          ? "We're transforming Islamic learning with "
                          : "আমরা ইসলামিক শিক্ষাকে রূপান্তর করছি ",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[800],
                        fontSize: responsiveValue(context, isTablet ? 16 : 15),
                      ),
                    ),
                    TextSpan(
                      text: isEnglish
                          ? "digital innovation"
                          : "ডিজিটাল উদ্ভাবনের",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.green[600],
                        fontStyle: FontStyle.italic,
                        fontSize: responsiveValue(context, isTablet ? 16 : 15),
                      ),
                    ),
                    TextSpan(
                      text: isEnglish
                          ? ". Engage with interactive quizzes and authentic content to strengthen your spiritual journey."
                          : " মাধ্যমে। আপনার ইসলামী পথের যাত্রাকে শক্তিশালী করতে ইন্টারেক্টিভ কুইজ এবং প্রামাণিক কন্টেন্টের সাথে যুক্ত হোন।",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[800],
                        fontSize: responsiveValue(context, isTablet ? 16 : 15),
                      ),
                    ),
                  ],
                ),
                style: TextStyle(height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    bool isEnglish,
    bool isDark,
    bool isTablet,
  ) {
    return Container(
      height: responsiveValue(context, isTablet ? 80 : 60),
      margin: EdgeInsets.only(bottom: responsiveValue(context, 12)),
      child: Stack(
        children: [
          // Background Design
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: responsiveValue(context, isTablet ? 30 : 20),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[50]!, Colors.green[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
              border: Border.all(color: Colors.green[200]!, width: 1.5),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveValue(context, isTablet ? 40 : 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with pulse effect
                  Container(
                    width: responsiveValue(context, isTablet ? 45 : 36),
                    height: responsiveValue(context, isTablet ? 45 : 36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.fiber_new_rounded,
                      size: responsiveValue(context, isTablet ? 24 : 20),
                      color: Colors.green[600],
                    ),
                  ),
                  SizedBox(width: responsiveValue(context, isTablet ? 16 : 12)),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnglish
                              ? 'Regular Content Updates'
                              : 'নিয়মিত কন্টেন্ট আপডেট',
                          style: TextStyle(
                            fontSize: responsiveValue(
                              context,
                              isTablet ? 16 : 14,
                            ),
                            fontWeight: FontWeight.w700,
                            color: Colors.green[800],
                          ),
                        ),
                        SizedBox(height: responsiveValue(context, 2)),
                        Text(
                          isEnglish
                              ? 'Fresh Islamic knowledge always available'
                              : 'সর্বদা নতুন ইসলামিক জ্ঞান পাওয়া যাবে',
                          style: TextStyle(
                            fontSize: responsiveValue(
                              context,
                              isTablet ? 13 : 11,
                            ),
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: responsiveValue(context, isTablet ? 12 : 8)),

                  // Live indicator
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveValue(context, isTablet ? 8 : 6),
                      vertical: responsiveValue(context, isTablet ? 4 : 2),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[500],
                      borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: responsiveValue(context, isTablet ? 8 : 6),
                          height: responsiveValue(context, isTablet ? 8 : 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          width: responsiveValue(context, isTablet ? 6 : 4),
                        ),
                        Text(
                          isEnglish ? 'LIVE' : 'লাইভ',
                          style: TextStyle(
                            fontSize: responsiveValue(
                              context,
                              isTablet ? 11 : 9,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection(
    BuildContext context,
    bool isEnglish,
    bool isDark,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          isEnglish ? '🏆 Quiz Rewards' : '🏆 কুইজ পুরস্কার',
          Icons.emoji_events,
          isTablet,
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(
              responsiveValue(context, isTablet ? 20 : 16),
            ),
            child: Column(
              children: [
                // Reward Icon
                Container(
                  width: responsiveValue(context, isTablet ? 80 : 60),
                  height: responsiveValue(context, isTablet ? 80 : 60),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber[300]!,
                      width: isTablet ? 3 : 2,
                    ),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: responsiveValue(context, isTablet ? 40 : 30),
                    color: Colors.amber[700],
                  ),
                ),
                SizedBox(height: responsiveValue(context, isTablet ? 16 : 12)),

                Text(
                  isEnglish
                      ? 'Win Exciting Rewards!'
                      : 'জিতুন আকর্ষণীয় পুরস্কার!',
                  style: TextStyle(
                    fontSize: responsiveValue(context, isTablet ? 18 : 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),

                SizedBox(height: responsiveValue(context, isTablet ? 12 : 8)),

                Text(
                  isEnglish
                      ? '• Complete quizzes and earn 5000 points\n• Get amazing gifts and rewards\n• Test your Islamic knowledge\n• Earn free points and bonuses'
                      : '• কুইজ সম্পন্ন করে ৫০০০ পয়েন্ট অর্জন করুন\n• পেয়ে যান আকর্ষণীয় গিফট ও পুরস্কার\n• ইসলামিক জ্ঞান যাচাই করুন\n• ফ্রি পয়েন্ট ও বোনাস উপভোগ করুন',
                  style: TextStyle(
                    fontSize: responsiveValue(context, isTablet ? 15 : 13),
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    height: 1.6,
                  ),
                ),

                SizedBox(height: responsiveValue(context, isTablet ? 20 : 16)),

                // Button 1: Start Quiz (Goes to Home Page)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.quiz,
                      size: responsiveValue(context, isTablet ? 24 : 20),
                    ),
                    label: Text(
                      isEnglish ? 'Start Quiz Now' : 'এখনই কুইজ শুরু করুন',
                      style: TextStyle(
                        fontSize: responsiveValue(context, isTablet ? 16 : 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: responsiveValue(context, isTablet ? 16 : 12),
                        horizontal: responsiveValue(
                          context,
                          isTablet ? 20 : 16,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: responsiveValue(context, isTablet ? 12 : 8)),

                // Button 2: View Profile
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.person,
                      size: responsiveValue(context, isTablet ? 24 : 20),
                    ),
                    label: Text(
                      isEnglish ? 'View Your Profile' : 'আপনার প্রোফাইল দেখুন',
                      style: TextStyle(
                        fontSize: responsiveValue(context, isTablet ? 16 : 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green[700]!),
                      padding: EdgeInsets.symmetric(
                        vertical: responsiveValue(context, isTablet ? 16 : 12),
                        horizontal: responsiveValue(
                          context,
                          isTablet ? 20 : 16,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(
    BuildContext context,
    bool isEnglish,
    bool isDark,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          isEnglish ? '📞 Contact Us' : '📞 যোগাযোগ করুন',
          Icons.contact_mail,
          isTablet,
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(
              responsiveValue(context, isTablet ? 20 : 16),
            ),
            child: Column(
              children: [
                _buildContactItem(
                  context,
                  Icons.email,
                  isEnglish ? 'Email Support' : 'ইমেইল সাপোর্ট',
                  'support@islamicday.com',
                  isTablet,
                  onTap: () => _launchEmail('support@islamicday.com'),
                ),
                _buildContactItem(
                  context,
                  Icons.phone,
                  isEnglish ? 'Call Us' : 'ফোন করুন',
                  '+880 1724-184271',
                  isTablet,
                  onTap: () => _launchPhone('+8801724184271'),
                ),
                _buildContactItem(
                  context,
                  Icons.web,
                  isEnglish ? 'Our Website' : 'আমাদের ওয়েবসাইট',
                  'www.islamicday.com',
                  isTablet,
                  onTap: () => _launchUrl('https://www.islamicday.com'),
                ),
                _buildContactItem(
                  context,
                  Icons.facebook,
                  isEnglish ? 'Facebook Page' : 'ফেসবুক পেজ',
                  'fb.com/islamicday',
                  isTablet,
                  onTap: () => _launchUrl('https://fb.com/islamicday'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection(
    BuildContext context,
    bool isEnglish,
    bool isDark,
    bool isTablet,
  ) {
    return Card(
      color: isDark ? Colors.green[900] : Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(responsiveValue(context, isTablet ? 24 : 20)),
        child: Column(
          children: [
            Text(
              isEnglish
                  ? '🤲 May Allah guide us all to the right path of Deen.'
                  : '🤲 আল্লাহ আমাদের সকলকে দ্বীনের সঠিক পথে পরিচালিত করুন।',
              style: TextStyle(
                fontSize: responsiveValue(context, isTablet ? 16 : 14),
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : Colors.green[800],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsiveValue(context, isTablet ? 16 : 12)),
            Divider(color: Colors.green[300]),
            SizedBox(height: responsiveValue(context, isTablet ? 12 : 8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  size: responsiveValue(context, isTablet ? 20 : 16),
                  color: Colors.green[700],
                ),
                SizedBox(width: responsiveValue(context, isTablet ? 8 : 6)),
                Text(
                  isEnglish ? 'Islamic Day Team' : 'ইসলামিক ডে টিম',
                  style: TextStyle(
                    fontSize: responsiveValue(context, isTablet ? 16 : 14),
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: responsiveValue(context, isTablet ? 8 : 4)),
            Text(
              isEnglish
                  ? 'For any questions or suggestions'
                  : 'যেকোনো প্রশ্ন বা পরামর্শের জন্য',
              style: TextStyle(
                fontSize: responsiveValue(context, isTablet ? 14 : 12),
                color: isDark ? Colors.white60 : Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsiveValue(context, isTablet ? 12 : 8),
        left: 4,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green[700],
            size: responsiveValue(context, isTablet ? 24 : 20),
          ),
          SizedBox(width: responsiveValue(context, isTablet ? 12 : 8)),
          Text(
            title,
            style: TextStyle(
              fontSize: responsiveValue(context, isTablet ? 18 : 16),
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    bool isTablet, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green[700],
        size: responsiveValue(context, isTablet ? 28 : 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: responsiveValue(context, isTablet ? 16 : 14),
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: responsiveValue(context, isTablet ? 15 : 13),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: responsiveValue(context, isTablet ? 18 : 16),
        color: Colors.green[700],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        vertical: responsiveValue(context, isTablet ? 8 : 4),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
