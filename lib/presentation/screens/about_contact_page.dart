// screens/about_contact_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../features/home/home_page.dart';
import '../providers/language_provider.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/constants/app_colors.dart'; // ✅ AppColors import

class AboutContactPage extends StatelessWidget {
  const AboutContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabletSize = isTablet(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEnglish ? 'About & Contact' : 'আমাদের সম্পর্কে',
          style: TextStyle(
            fontSize: tabletSize ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeHelper.appBar(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: tabletSize ? 28 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            responsiveValue(context, tabletSize ? 20 : 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(context, isEnglish, isDark, tabletSize),

              SizedBox(height: responsiveValue(context, tabletSize ? 30 : 24)),

              // App Features Section
              _buildFeaturesSection(context, isEnglish, isDark, tabletSize),

              SizedBox(height: responsiveValue(context, tabletSize ? 24 : 20)),

              // Learning Benefits Section
              _buildBenefitsSection(context, isEnglish, isDark, tabletSize),

              SizedBox(height: responsiveValue(context, tabletSize ? 24 : 20)),

              // Contact Section
              _buildContactSection(context, isEnglish, isDark, tabletSize),

              SizedBox(height: responsiveValue(context, tabletSize ? 24 : 20)),

              // Footer Section
              _buildFooterSection(context, isEnglish, isDark, tabletSize),

              // Bottom spacing
              SizedBox(height: responsiveValue(context, 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    bool isEnglish,
    bool isDark,
    bool tabletSize,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tabletSize ? 20 : 16),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsiveValue(context, tabletSize ? 24 : 20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? AppColors.darkHeaderGradient
                : [Colors.green[700]!, Colors.green[600]!],
          ),
          borderRadius: BorderRadius.circular(tabletSize ? 20 : 16),
        ),
        child: Column(
          children: [
            // App Icon with better design
            Container(
              width: responsiveValue(context, tabletSize ? 120 : 90),
              height: responsiveValue(context, tabletSize ? 120 : 90),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(tabletSize ? 30 : 24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: tabletSize ? 4 : 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tabletSize ? 26 : 20),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: responsiveValue(context, tabletSize ? 100 : 80),
                  height: responsiveValue(context, tabletSize ? 100 : 80),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.mosque_rounded,
                      size: responsiveValue(context, tabletSize ? 50 : 40),
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: responsiveValue(context, tabletSize ? 20 : 16)),

            // Welcome Text
            Text(
              isEnglish
                  ? 'Welcome to Islamic Learning App'
                  : 'ইসলামিক লার্নিং অ্যাপে স্বাগতম',
              style: TextStyle(
                fontSize: responsiveValue(context, tabletSize ? 22 : 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: responsiveValue(context, tabletSize ? 12 : 8)),

            // Description
            Text(
              isEnglish
                  ? 'Enhance your Islamic knowledge through interactive learning and authentic content'
                  : 'ইন্টারেক্টিভ লার্নিং এবং প্রামাণিক কন্টেন্টের মাধ্যমে আপনার ইসলামিক জ্ঞান বৃদ্ধি করুন',
              style: TextStyle(
                fontSize: responsiveValue(context, tabletSize ? 16 : 14),
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: responsiveValue(context, tabletSize ? 16 : 12)),

            // App Version Info
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveValue(context, tabletSize ? 16 : 12),
                vertical: responsiveValue(context, tabletSize ? 8 : 6),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: responsiveValue(context, tabletSize ? 18 : 16),
                    color: Colors.white,
                  ),
                  SizedBox(width: responsiveValue(context, tabletSize ? 8 : 6)),
                  Text(
                    isEnglish
                        ? 'Verified Islamic Content'
                        : 'যাচাইকৃত ইসলামিক কন্টেন্ট',
                    style: TextStyle(
                      fontSize: responsiveValue(context, tabletSize ? 14 : 12),
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
    bool tabletSize,
  ) {
    final features = [
      {
        'icon': Icons.quiz_rounded,
        'title': isEnglish ? 'Islamic Quizzes' : 'ইসলামিক কুইজ',
        'description': isEnglish
            ? 'Test your knowledge with authentic Islamic questions'
            : 'প্রামাণিক ইসলামিক প্রশ্ন দিয়ে আপনার জ্ঞান যাচাই করুন',
        'color': isDark ? AppColors.darkBlueAccent : Colors.blue,
        'details': {
          'en': '''
🎯 Comprehensive Islamic Learning Categories:

• Islamic Basic Knowledge - Foundational principles and fundamentals
• Quran Studies - In-depth understanding of divine revelations
• Life of Prophet Muhammad (PBUH) - Seerah and prophetic biography
• Worship & Ibadah - Practical aspects of Islamic rituals
• Akhirah & Afterlife - Concepts of life after death
• Day of Judgment - Qiyamah and final reckoning
• Women in Islam - Rights, roles and responsibilities
• Islamic Ethics & Manners - Moral values and character building
• Islamic Law - Marriage, divorce and family jurisprudence
• Etiquette & Conduct - Social and personal manners
• Marital & Family Relations - Spousal and family dynamics
• Hadith Studies - Prophetic traditions and teachings
• Prophets & Messengers - Stories of all prophets
• Islamic History - Historical development of Islam

📊 Learning Resources:
• 2800+ Bilingual MCQ Questions in English and Bengali
• Detailed explanations with authentic references
• Progressive difficulty levels from beginner to advanced
• Instant results with performance analytics
• Bookmark difficult questions for revision

🎯 Educational Approach:
- Structured learning path with 14 comprehensive categories
- Bilingual interface supporting both English and Bengali
- Designed for global Muslim community
- Special focus for Bangladeshi diaspora
- Regular content updates with new questions
- Scholarly verified content from authentic sources
- Mobile-friendly learning experience
- Offline access to downloaded content
''',
          'bn': '''
🎯 বিস্তৃত ইসলামিক শিক্ষার বিভাগসমূহ:

• ইসলামী প্রাথমিক জ্ঞান - ইসলামের মৌলিক নীতি ও ভিত্তিমূলক বিষয়াবলী
• কোরআন অধ্যয়ন - পবিত্র কোরআনের গভীর উপলব্ধি ও ব্যাখ্যা
• মহানবী সঃ এর জীবনী - রাসূলের পূর্ণাঙ্গ জীবনচরিত ও শিক্ষা
• ইবাদত - নামাজ, রোজা, হজ্জ ও যাকাতের ব্যবহারিক দিকনির্দেশনা
• আখিরাত - মৃত্যুপরবর্তী জীবন ও পরকালের বিস্তারিত ধারণা
• বিচার দিবস - কিয়ামতের দিনের ঘটনাবলী ও চূড়ান্ত ফলাফল
• নারী ও ইসলাম - ইসলামে নারীর অধিকার, মর্যাদা ও দায়িত্ব
• ইসলামী নৈতিকতা ও আচার - উত্তম চরিত্র ও সদগুণাবলি গঠন
• ধর্মীয় আইন (বিবাহ-বিচ্ছেদ) - পারিবারিক জীবন ও সামাজিক বিধান
• শিষ্টাচার - দৈনন্দিন জীবনের সুন্নাতি আদব ও শিষ্টাচার
• দাম্পত্য ও পারিবারিক সম্পর্ক - সুখী দাম্পত্য ও পারিবারিক বন্ধন
• হাদিস - রাসূলের বাণী ও শিক্ষার বিশুদ্ধ সংগ্রহ
• নবী-রাসূল - সকল নবী-রাসূলের জীবনী ও শিক্ষা
• ইসলামের ইতিহাস - ইসলামের গৌরবময় ইতিহাস ও সভ্যতা

📊 শিক্ষণীয় উপকরণ:
• ২৮০০+ দ্বিভাষিক এমসিকিউ প্রশ্ন (ইংরেজি ও বাংলা)
• প্রামাণিক দলিল-দস্তাবেজ সহ বিশদ ব্যাখ্যা
• প্রাথমিক থেকে উন্নত পর্যায় পর্যন্ত ধাপে ধাপে শিক্ষা
• তাত্ক্ষণিক ফলাফল ও performance বিশ্লেষণ
• পুনরায় দেখার জন্য কঠিন প্রশ্ন সংরক্ষণ

🎯 শিক্ষাদান পদ্ধতি:
• ১৪টি সুসংগঠিত বিভাগে সাজানো শিক্ষাপদ্ধতি
• ইংরেজি ও বাংলা উভয় ভাষায় সম্পূর্ণ সমর্থন
• বিশ্বব্যাপী মুসলিম সম্প্রদায়ের জন্য উপযোগী
• বাংলাদেশি প্রবাসীদের জন্য বিশেষভাবে উপকরণ
• নিয়মিত নতুন প্রশ্ন ও বিষয়বস্তু সংযোজন
• প্রামাণিক সূত্র থেকে যাচাইকৃত শিক্ষাসামগ্রী
• মোবাইল-বান্ধব ব্যবহারকারী অভিজ্ঞতা
• অফলাইনেও ডাউনলোডকৃত বিষয়বস্তু ব্যবহার
''',
        },
      },
      {
        'icon': Icons.school_rounded,
        'title': isEnglish ? 'Learning Content' : 'শিক্ষামূলক কন্টেন্ট',
        'description': isEnglish
            ? 'Access verified Islamic educational materials'
            : 'যাচাইকৃত ইসলামিক শিক্ষামূলক উপকরণ অ্যাক্সেস করুন',
        'color': isDark ? AppColors.darkGreenAccent : Colors.green,
        'details': {
          'en': '''
Comprehensive Learning Materials:

Authentic Sources - All content thoroughly verified by qualified Islamic scholars
Structured Curriculum - Well-organized learning path designed for systematic study
Visual Learning - Educational infographics, detailed diagrams and clear illustrations
Audio Support - Beautiful Quran recitations and comprehensive lesson explanations
Progressive Levels - Carefully designed tracks for Beginner, Intermediate, and Advanced learners

Educational Features:
Daily Lessons - Bite-sized learning modules perfect for busy schedules
Revision System - Spaced repetition technique for better knowledge retention
Progress Tracking - Comprehensive monitoring of your entire learning journey
Certificate System - Earn meaningful achievements for completed learning levels
Community Learning - Engage in discussions with fellow learners worldwide

Global Accessibility:
Specifically designed for Bangladeshi diaspora living worldwide
Fully bilingual interface supporting both English and Bengali
Cultural sensitivity carefully maintained throughout all content
Complete offline access available for downloaded materials
Regular content updates to ensure fresh learning experiences
''',
          'bn': '''
সম্পূর্ণ শিক্ষামূলক উপকরণ:

প্রামাণিক সূত্র - সকল বিষয়বস্তু যোগ্য ইসলামিক আলেমদের দ্বারা সম্পূর্ণ যাচাইকৃত
সুসংগঠিত পাঠ্যক্রম - ধারাবাহিক পড়াশোনার জন্য সুনির্দিষ্টভাবে সাজানো শিক্ষাপদ্ধতি
দৃশ্য শিক্ষণ - শিক্ষামূলক ইনফোগ্রাফিক, বিস্তারিত ডায়াগ্রাম এবং স্পষ্ট ইলাস্ট্রেশন
অডিও সমর্থন - মনোরম কুরআন তিলাওয়াত এবং পূর্ণাঙ্গ পাঠের ব্যাখ্যা
ধাপে ধাপে স্তর - শিক্ষানবিস, মধ্যবর্তী এবং উন্নত শিক্ষার্থীদের জন্য বিশেষভাবে তৈরি

শিক্ষামূলক বৈশিষ্ট্য:
দৈনিক পাঠ - ব্যস্ত সময়সূচীর জন্য উপযুক্ত ছোট ছোট শিক্ষণ মডিউল
পুনরাবৃত্তি পদ্ধতি -更好 জ্ঞান ধারণের জন্য নির্দিষ্ট ব্যবধানে পুনরালোচনা
অগ্রগতি নিরীক্ষণ - আপনার সম্পূর্ণ শিক্ষাযাত্রার সামগ্রিক পর্যবেক্ষণ
সনদপত্র ব্যবস্থা - সম্পূর্ণ শিক্ষাস্তরের জন্য অর্থপূর্ণ অর্জন লাভ
সম্প্রদায় শিক্ষণ - বিশ্বজুড়ে সহপাঠীদের সাথে আলোচনায় অংশগ্রহণ

বিশ্বব্যাপী প্রবেশাধিকার:
বিশ্বব্যাপী বসবাসরত বাংলাদেশি প্রবাসীদের জন্য বিশেষভাবে নকশাকৃত
ইংরেজি ও বাংলা উভয় ভাষায় সম্পূর্ণ দ্বিভাষিক ইন্টারফেস
সকল বিষয়বস্তুতে সাংস্কৃতিক সংবেদনশীলতা সযত্নে বজায় রাখা
ডাউনলোডকৃত উপকরণের জন্য সম্পূর্ণ অফলাইন অ্যাক্সেস উপলব্ধ
সতেজ শিক্ষার অভিজ্ঞতা নিশ্চিত করতে নিয়মিত বিষয়বস্তু আপডেট
''',
        },
      },
      {
        'icon': Icons.update_rounded,
        'title': isEnglish ? 'Regular Updates' : 'নিয়মিত আপডেট',
        'description': isEnglish
            ? 'Fresh content added regularly for continuous learning'
            : 'ক্রমাগত শেখার জন্য নিয়মিত নতুন কন্টেন্ট যোগ করা হয়',
        'color': isDark ? AppColors.darkOrangeAccent : Colors.orange,
        'details': {
          'en': '''
Continuous Content Enhancement:

Weekly New Content - Fresh quizzes and comprehensive learning materials added every week
Seasonal Specials - Special content for Ramadan, Eid, and other Islamic holidays
User Requested Topics - Content developed based on valuable community feedback
Current Affairs - Contemporary Islamic issues and meaningful discussions
Scholarly Insights - Latest fatwas and authentic Islamic rulings from reputable scholars

Update Schedule:
Daily - New quiz questions and featured hadith of the day
Weekly - New learning modules and expanded categories
Monthly - Major feature updates and significant content expansions
Seasonally - Special programs and content for important Islamic occasions

Future Roadmap:
Advanced Islamic courses covering deeper theological aspects
Live interactive sessions with renowned Islamic scholars
Community discussion forums for knowledge sharing
Seamless synchronization between mobile and desktop platforms
Multi-language expansion to reach wider audience
Advanced analytics for personalized learning experience

Designed For:
Bangladeshi Muslims living abroad seeking authentic Islamic knowledge
Global Muslim community looking for structured learning
Islamic students and teachers requiring comprehensive resources
New Muslims and reverts seeking foundational understanding
Families learning together in supportive environment
''',
          'bn': '''
ক্রমাগত বিষয়বস্তু উন্নয়ন:

সাপ্তাহিক নতুন বিষয়বস্তু - প্রতি সপ্তাহে নতুন কুইজ এবং সম্পূর্ণ শিক্ষণ উপকরণ যোগ করা হয়
মৌসুমী বিশেষ - রমজান, ঈদ এবং অন্যান্য ইসলামিক ছুটির জন্য বিশেষ বিষয়বস্তু
ব্যবহারকারীর অনুরোধিত বিষয় - মূল্যবান সম্প্রদায়ের প্রতিক্রিয়া ভিত্তিক তৈরি বিষয়বস্তু
বর্তমান বিষয় - সমসাময়িক ইসলামিক বিষয় এবং অর্থপূর্ণ আলোচনা
বিজ্ঞ আলেমদের অন্তর্দৃষ্টি - নির্ভরযোগ্য আলেমদের সর্বশেষ ফতোয়া ও প্রামাণিক ইসলামিক বিধান

আপডেট সময়সূচী:
দৈনিক - নতুন কুইজ প্রশ্ন এবং দিনের নির্বাচিত হাদিস
সাপ্তাহিক - নতুন শিক্ষণ মডিউল এবং সম্প্রসারিত বিভাগ
মাসিক - প্রধান বৈশিষ্ট্য আপডেট এবং উল্লেখযোগ্য বিষয়বস্তু সম্প্রসারণ
মৌসুমী - গুরুত্বপূর্ণ ইসলামিক উপলক্ষ্যের জন্য বিশেষ 프로그램 ও বিষয়বস্তু

ভবিষ্যত পরিকল্পনা:
গভীর ধর্মতাত্ত্বিক দিক covering উন্নত ইসলামিক কোর্স
প্রতিষ্ঠিত ইসলামিক আলেমদের সাথে সরাসরি ইন্টারেক্টিভ সেশন
জ্ঞান বিনিময়ের জন্য সম্প্রদায় আলোচনা ফোরাম
মোবাইল এবং ডেস্কটপ প্ল্যাটফর্মের মধ্যে নিরবিচ্ছিন্ন সিঙ্ক্রোনাইজেশন
ব্যাপক শ্রোতা raggi করার জন্য বহুভাষিক সম্প্রসারণ
ব্যক্তিগতকৃত শিক্ষার অভিজ্ঞতার জন্য উন্নত বিশ্লেষণ

যাদের জন্য ডিজাইন করা:
প্রামাণিক ইসলামিক জ্ঞান সন্ধানকারী বিদেশে বসবাসরত বাংলাদেশি মুসলমানরা
সুসংগঠিত শিক্ষার সন্ধানকারী বিশ্বব্যাপী মুসলিম সম্প্রদায়
সম্পূর্ণ সম্পদের প্রয়োজন ইসলামিক ছাত্র এবং শিক্ষকরা
মৌলিক বুঝাপড়া খোঁজা নতুন মুসলিম এবং ধর্মান্তরিতরা
সহায়ক পরিবেশে একসাথে শেখা পরিবারগুলি
''',
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          isEnglish ? '📚 App Features' : '📚 অ্যাপের বৈশিষ্ট্য',
          Icons.featured_play_list_rounded,
          tabletSize,
          isDark,
        ),
        ...features
            .map(
              (feature) => _buildFeatureCard(
                context: context,
                icon: feature['icon'] as IconData,
                title: feature['title'] as String,
                description: feature['description'] as String,
                color: feature['color'] as Color,
                tabletSize: tabletSize,
                isDark: isDark,
                details: feature['details'] as Map<String, String>,
                isEnglish: isEnglish,
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool tabletSize,
    required bool isDark,
    required Map<String, String> details,
    required bool isEnglish,
  }) {
    return Card(
      margin: EdgeInsets.only(
        bottom: responsiveValue(context, tabletSize ? 12 : 8),
      ),
      elevation: 2,
      color: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tabletSize ? 16 : 12),
      ),
      child: InkWell(
        onTap: () => _showFeatureDetails(
          context,
          title,
          details,
          isEnglish,
          color,
          tabletSize,
          isDark,
        ),
        borderRadius: BorderRadius.circular(tabletSize ? 16 : 12),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(
              responsiveValue(context, tabletSize ? 12 : 8),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(tabletSize ? 12 : 8),
            ),
            child: Icon(
              icon,
              color: color,
              size: responsiveValue(context, tabletSize ? 24 : 20),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: responsiveValue(context, tabletSize ? 16 : 14),
              color: isDark ? AppColors.darkText : Colors.black87,
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              fontSize: responsiveValue(context, tabletSize ? 14 : 12),
              color: isDark ? AppColors.darkTextSecondary : Colors.black54,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: responsiveValue(context, tabletSize ? 18 : 16),
            color: color,
          ),
          contentPadding: EdgeInsets.all(
            responsiveValue(context, tabletSize ? 16 : 12),
          ),
        ),
      ),
    );
  }

  void _showFeatureDetails(
    BuildContext context,
    String title,
    Map<String, String> details,
    bool isEnglish,
    Color color,
    bool tabletSize,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(
                responsiveValue(context, tabletSize ? 20 : 16),
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.3 : 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: color,
                    size: responsiveValue(context, tabletSize ? 28 : 24),
                  ),
                  SizedBox(
                    width: responsiveValue(context, tabletSize ? 12 : 8),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: responsiveValue(
                          context,
                          tabletSize ? 20 : 18,
                        ),
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: responsiveValue(context, tabletSize ? 24 : 20),
                      color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  responsiveValue(context, tabletSize ? 20 : 16),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: details[isEnglish ? 'en' : 'bn'] ?? '',
                        style: TextStyle(
                          fontSize: responsiveValue(
                            context,
                            tabletSize ? 16 : 14,
                          ),
                          height: 1.6,
                          color: isDark ? AppColors.darkText : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Close Button
            Container(
              padding: EdgeInsets.all(
                responsiveValue(context, tabletSize ? 16 : 12),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: responsiveValue(context, tabletSize ? 16 : 14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tabletSize ? 12 : 10),
                    ),
                  ),
                  child: Text(
                    isEnglish ? 'Close' : 'বন্ধ করুন',
                    style: TextStyle(
                      fontSize: responsiveValue(context, tabletSize ? 16 : 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection(
    BuildContext context,
    bool isEnglish,
    bool isDark,
    bool tabletSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          isEnglish ? '🎯 Learning Benefits' : '🎯 শিক্ষার সুবিধা',
          Icons.auto_awesome_rounded,
          tabletSize,
          isDark,
        ),
        Card(
          elevation: 2,
          color: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tabletSize ? 16 : 12),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              responsiveValue(context, tabletSize ? 20 : 16),
            ),
            child: Column(
              children: [
                // Benefits Grid
                Wrap(
                  spacing: responsiveValue(context, tabletSize ? 16 : 12),
                  runSpacing: responsiveValue(context, tabletSize ? 16 : 12),
                  children: [
                    _buildBenefitItem(
                      context,
                      Icons.lightbulb_rounded,
                      isEnglish ? 'Knowledge Enhancement' : 'জ্ঞান বৃদ্ধি',
                      isDark ? AppColors.darkOrangeAccent : Colors.amber,
                      tabletSize,
                      isDark,
                    ),
                    _buildBenefitItem(
                      context,
                      Icons.groups_rounded,
                      isEnglish ? 'Community Learning' : 'কমিউনিটি লার্নিং',
                      isDark ? AppColors.darkBlueAccent : Colors.blue,
                      tabletSize,
                      isDark,
                    ),
                    _buildBenefitItem(
                      context,
                      Icons.schedule_rounded,
                      isEnglish ? 'Flexible Timing' : 'নমনীয় সময়',
                      isDark ? AppColors.darkGreenAccent : Colors.green,
                      tabletSize,
                      isDark,
                    ),
                    _buildBenefitItem(
                      context,
                      Icons.verified_rounded,
                      isEnglish ? 'Authentic Content' : 'প্রামাণিক কন্টেন্ট',
                      isDark ? AppColors.darkPurpleAccent : Colors.purple,
                      tabletSize,
                      isDark,
                    ),
                  ],
                ),

                SizedBox(
                  height: responsiveValue(context, tabletSize ? 20 : 16),
                ),

                // Start Learning Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.school_rounded,
                      size: responsiveValue(context, tabletSize ? 24 : 20),
                    ),
                    label: Text(
                      isEnglish
                          ? 'Start Learning Journey'
                          : 'শেখার যাত্রা শুরু করুন',
                      style: TextStyle(
                        fontSize: responsiveValue(
                          context,
                          tabletSize ? 16 : 14,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: responsiveValue(
                          context,
                          tabletSize ? 16 : 14,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          tabletSize ? 12 : 10,
                        ),
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

  // Contact Section - Updated contact methods
  Widget _buildContactSection(
    BuildContext context,
    bool isEnglish,
    bool isDark,
    bool tabletSize,
  ) {
    final contactMethods = [
      {
        'icon': Icons.email_rounded,
        'title': isEnglish ? 'Email Support' : 'ইমেইল সাপোর্ট',
        'value': 'info@codescapebd.com',
        'action': () =>
            _launchEmail(context, 'info@codescapebd.com', isEnglish),
      },
      {
        'icon': Icons.help_rounded,
        'title': isEnglish ? 'Help Center' : 'হেল্প সেন্টার',
        'value': isEnglish ? 'Get assistance' : 'সহায়তা নিন',
        'action': () => _showHelpDialog(context, isEnglish, isDark),
      },
      {
        'icon': Icons.feedback_rounded,
        'title': isEnglish ? 'Send Feedback' : 'ফিডব্যাক পাঠান',
        'value': isEnglish ? 'Share your thoughts' : 'আপনার মতামত শেয়ার করুন',
        'action': () =>
            _launchEmail(context, 'info@codescapebd.com', isEnglish),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          isEnglish ? '💬 Get In Touch' : '💬 যোগাযোগ করুন',
          Icons.contact_support_rounded,
          tabletSize,
          isDark,
        ),
        Card(
          elevation: 2,
          color: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tabletSize ? 16 : 12),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              responsiveValue(context, tabletSize ? 20 : 16),
            ),
            child: Column(
              children: contactMethods
                  .map(
                    (method) => _buildContactCard(
                      context: context,
                      icon: method['icon'] as IconData,
                      title: method['title'] as String,
                      value: method['value'] as String,
                      onTap: method['action'] as VoidCallback,
                      tabletSize: tabletSize,
                      isDark: isDark,
                    ),
                  )
                  .toList(),
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
    bool tabletSize,
  ) {
    final primaryColor = isDark ? AppColors.darkPrimary : Colors.green[700];
    final backgroundColor = isDark ? AppColors.darkSurface : Colors.green[50];
    final textColor = isDark ? AppColors.darkText : Colors.green[800];

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(responsiveValue(context, tabletSize ? 24 : 20)),
        child: Column(
          children: [
            Icon(
              Icons.mosque_rounded,
              size: responsiveValue(context, tabletSize ? 40 : 32),
              color: primaryColor,
            ),
            SizedBox(height: responsiveValue(context, tabletSize ? 16 : 12)),
            Text(
              isEnglish
                  ? 'May Allah accept our efforts in seeking knowledge'
                  : 'আল্লাহ আমাদের জ্ঞান অর্জনের প্রচেষ্টা কবুল করুন',
              style: TextStyle(
                fontSize: responsiveValue(context, tabletSize ? 16 : 14),
                fontStyle: FontStyle.italic,
                color: textColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsiveValue(context, tabletSize ? 12 : 8)),
            Divider(color: isDark ? AppColors.darkBorder : Colors.green[300]),
            SizedBox(height: responsiveValue(context, tabletSize ? 12 : 8)),
            Text(
              'Islamic Day App',
              style: TextStyle(
                fontSize: responsiveValue(context, tabletSize ? 16 : 14),
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: responsiveValue(context, tabletSize ? 4 : 2)),
            Text(
              isEnglish ? 'Version 1.0.0' : 'সংস্করণ ১.০.০',
              style: TextStyle(
                fontSize: responsiveValue(context, tabletSize ? 14 : 12),
                color: isDark ? AppColors.darkTextSecondary : Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
    bool tabletSize,
    bool isDark,
  ) {
    return Container(
      width: responsiveValue(context, tabletSize ? 150 : 130),
      padding: EdgeInsets.all(responsiveValue(context, tabletSize ? 16 : 12)),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(tabletSize ? 12 : 8),
        border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: responsiveValue(context, tabletSize ? 32 : 28),
            color: color,
          ),
          SizedBox(height: responsiveValue(context, tabletSize ? 8 : 6)),
          Text(
            text,
            style: TextStyle(
              fontSize: responsiveValue(context, tabletSize ? 14 : 12),
              fontWeight: FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required bool tabletSize,
    required bool isDark,
  }) {
    final primaryColor = isDark ? AppColors.darkPrimary : Colors.green[700];

    return Card(
      margin: EdgeInsets.only(
        bottom: responsiveValue(context, tabletSize ? 12 : 8),
      ),
      elevation: 1,
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tabletSize ? 12 : 8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: primaryColor,
          size: responsiveValue(context, tabletSize ? 28 : 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: responsiveValue(context, tabletSize ? 16 : 14),
            color: isDark ? AppColors.darkText : Colors.black87,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: responsiveValue(context, tabletSize ? 14 : 12),
            color: isDark ? AppColors.darkTextSecondary : Colors.black54,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: responsiveValue(context, tabletSize ? 18 : 16),
          color: primaryColor,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.all(
          responsiveValue(context, tabletSize ? 12 : 8),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    bool tabletSize,
    bool isDark,
  ) {
    final primaryColor = isDark ? AppColors.darkPrimary : Colors.green[700];
    final backgroundColor = isDark
        ? AppColors.darkPrimary.withOpacity(0.2)
        : Colors.green[100];
    final textColor = isDark ? AppColors.darkText : Colors.green[800];

    return Padding(
      padding: EdgeInsets.only(
        bottom: responsiveValue(context, tabletSize ? 16 : 12),
        left: 4,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              responsiveValue(context, tabletSize ? 8 : 6),
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(tabletSize ? 12 : 8),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: responsiveValue(context, tabletSize ? 24 : 20),
            ),
          ),
          SizedBox(width: responsiveValue(context, tabletSize ? 12 : 8)),
          Text(
            title,
            style: TextStyle(
              fontSize: responsiveValue(context, tabletSize ? 20 : 18),
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Copy to clipboard function
  void _copyToClipboard(BuildContext context, String text, bool isEnglish) {
    // For web compatibility, we'll use a simple approach
    // In a real app, you might want to use the clipboard package
    final message = isEnglish
        ? 'Email address copied: $text'
        : 'ইমেইল ঠিকানা কপি করা হয়েছে: $text';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Fallback dialog when email app is not found
  void _showEmailFallbackDialog(
    BuildContext context,
    String email,
    bool isEnglish,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : Colors.white,
        title: Text(
          isEnglish ? 'Email App Not Found' : 'ইমেইল অ্যাপ পাওয়া যায়নি',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkText
                : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish
                  ? 'Please send email to:'
                  : 'অনুগ্রহ করে ইমেইল পাঠান এই ঠিকানায়:',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            SelectableText(
              email,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              isEnglish
                  ? 'Email address has been copied to clipboard.'
                  : 'ইমেইল ঠিকানা ক্লিপবোর্ডে কপি করা হয়েছে।',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : Colors.green[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isEnglish ? 'Close' : 'বন্ধ করুন',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Copy to clipboard
              _copyToClipboard(context, email, isEnglish);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkPrimary
                  : Colors.green[700],
            ),
            child: Text(
              isEnglish ? 'Copy Email' : 'ইমেইল কপি করুন',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Updated help dialog
  void _showHelpDialog(BuildContext context, bool isEnglish, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          isEnglish ? 'Need Help?' : 'সহায়তা প্রয়োজন?',
          style: TextStyle(color: isDark ? AppColors.darkText : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish
                  ? 'For any assistance or questions:'
                  : 'যেকোনো সহায়তা বা প্রশ্নের জন্য:',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            SelectableText(
              'info@codescapebd.com',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isEnglish ? 'Close' : 'বন্ধ করুন',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail(context, 'info@codescapebd.com', isEnglish);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : Colors.green[700],
            ),
            child: Text(
              isEnglish ? 'Send Email' : 'ইমেইল পাঠান',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Updated email launch function
  Future<void> _launchEmail(
    BuildContext context,
    String email,
    bool isEnglish,
  ) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': isEnglish
            ? 'Islamic Day App Support'
            : 'ইসলামিক ডে অ্যাপ সাপোর্ট',
        'body': isEnglish
            ? 'Hello Islamic Day Team,\n\nI would like to get support regarding:'
            : 'আসসালামু আলাইকুম ইসলামিক ডে টিম,\n\nআমি সহায়তা চাই বিষয়:',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback: Copy email to clipboard and show message
        _showEmailFallbackDialog(context, email, isEnglish);
      }
    } catch (e) {
      // If everything fails, show fallback dialog
      _showEmailFallbackDialog(context, email, isEnglish);
    }
  }
}
