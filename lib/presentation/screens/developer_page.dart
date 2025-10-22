//developer page
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';

class DeveloperPage extends StatelessWidget {
  DeveloperPage({Key? key}) : super(key: key);

  final Map<String, String> developerInfo = {
    'name': 'মোঃ রাজু হোসেন',
    'name_en': 'Md. Raju Hossain',
    'title': 'সিনিয়র ফ্লাটার ডেভেলপার & IT এক্সপার্ট',
    'title_en': 'Senior Flutter Developer & IT Expert',
    'experience': '১০+ বছর অভিজ্ঞতা',
    'experience_en': '10+ Years Experience',
    'specialization':
        '🚀 কাস্টম মোবাইল অ্যাপ্লিকেশন ডেভেলপমেন্ট | 🌐 ওয়েব সলিউশন | 💼 এন্ড-টু-এন্ড IT কনসাল্টেন্সি',
    'specialization_en':
        '🚀 Custom Mobile Application Development | 🌐 Web Solutions | 💼 End-to-End IT Consultancy',
  };

  final Map<String, String> aboutText = {
    'about': '''
🎯 **পেশাদার পরিচয়**
আমি একজন অভিজ্ঞ ফ্লাটার ডেভেলপার এবং IT বিশেষজ্ঞ। গত এক দশক ধরে প্রযুক্তি খাতে সক্রিয়ভাবে কাজ করছি। আমার তৈরি অ্যাপগুলো লক্ষাধিক ইউজার ব্যবহার করছে।

💡 **দক্ষতা**
• ফ্লাটার & ডার্ট
• Firebase & Backend
• UI/UX ডিজাইন
• API ইন্টিগ্রেশন
• সিকিউরিটি & পারফরম্যান্স

🚀 **ফিলোসফি**
আমি বিশ্বাস করি প্রতিটি অ্যাপ মানুষের জীবনকে সহজ ও উন্নত করার একটি সুযোগ। ব্যবহারকারীর চাহিদা বুঝে সেরা সলিউশন দেওয়াই আমার লক্ষ্য।
''',
    'about_en': '''
🎯 **Professional Profile**
I am an experienced Flutter Developer and IT Expert with over a decade of active involvement in the technology sector. My applications are being used by hundreds of thousands of users.

💡 **Expertise**
• Flutter & Dart
• Firebase & Backend
• UI/UX Design
• API Integration
• Security & Performance

🚀 **Philosophy**
I believe every app is an opportunity to simplify and enhance human life. My goal is to understand user needs and deliver the best possible solutions.
''',
  };

  final Map<String, List<Map<String, String>>> contactInfo = {
    'contacts': [
      {
        'icon': '📧',
        'title': 'ইমেইল',
        'value': 'rajudev.bd@gmail.com',
        'type': 'email',
      },
      {
        'icon': '📱',
        'title': 'ফোন',
        'value': '+8801724-184271',
        'type': 'phone',
      },
      {
        'icon': '💼',
        'title': 'লিংকডইন',
        'value': 'linkedin.com/in/rajudev',
        'type': 'linkedin',
      },
      {
        'icon': '👨‍💻',
        'title': 'পোর্টফোলিও',
        'value': 'rajudev.com',
        'type': 'portfolio',
      },
    ],
    'contacts_en': [
      {
        'icon': '📧',
        'title': 'Email',
        'value': 'rajudev.bd@gmail.com',
        'type': 'email',
      },
      {
        'icon': '📱',
        'title': 'Phone',
        'value': '+8801724-184271',
        'type': 'phone',
      },
      {
        'icon': '💼',
        'title': 'LinkedIn',
        'value': 'linkedin.com/in/rajudev',
        'type': 'linkedin',
      },
      {
        'icon': '👨‍💻',
        'title': 'Portfolio',
        'value': 'rajudev.com',
        'type': 'portfolio',
      },
    ],
  };

  void _launchContact(String type, String value, BuildContext context) async {
    final Uri uri;

    switch (type) {
      case 'email':
        uri = Uri.parse('mailto:$value');
        break;
      case 'phone':
        uri = Uri.parse('tel:$value');
        break;
      case 'linkedin':
        uri = Uri.parse('https://$value');
        break;
      case 'portfolio':
        uri = Uri.parse('https://$value');
        break;
      default:
        return;
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).isEnglish
                ? 'Could not launch: $value'
                : 'খোলা যায়নি: $value',
          ),
          backgroundColor: AppColors.getErrorColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Header Section
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                snap: false,
                stretch: true,
                backgroundColor: AppColors.getAppBarColor(isDark),
                foregroundColor: Colors.white,
                toolbarHeight: 60,
                collapsedHeight: 60,
                floating: false,
                automaticallyImplyLeading: false,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final double expandRatio = constraints.biggest.height / 280;
                    final bool isExpanded = expandRatio > 0.8;

                    return FlexibleSpaceBar(
                      title: AnimatedOpacity(
                        opacity: isExpanded ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            isEnglish ? 'Developer' : 'ডেভেলপার',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 8,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      centerTitle: true,
                      titlePadding: const EdgeInsets.only(bottom: 16),
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? AppColors.darkHeaderGradient
                                    : AppColors.lightHeaderGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          // Developer Photo and Info
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedOpacity(
                                  opacity: isExpanded ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.2,
                                    ),
                                    child: CircleAvatar(
                                      radius: 56,
                                      backgroundImage: const AssetImage(
                                        'assets/images/razu.webp',
                                      ),
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AnimatedOpacity(
                                  opacity: isExpanded ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 400),
                                  child: Text(
                                    isEnglish
                                        ? developerInfo['name_en']!
                                        : developerInfo['name']!,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 4,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AnimatedOpacity(
                                  opacity: isExpanded ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Text(
                                    isEnglish
                                        ? developerInfo['title_en']!
                                        : developerInfo['title']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        const Shadow(
                                          color: Colors.black,
                                          blurRadius: 4,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedOpacity(
                                  opacity: isExpanded ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 600),
                                  child: Text(
                                    isEnglish
                                        ? developerInfo['experience_en']!
                                        : developerInfo['experience']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                      shadows: [
                                        const Shadow(
                                          color: Colors.black,
                                          blurRadius: 4,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ];
          },
          body: Builder(
            builder: (context) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Specialization Card - Improved Version
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: AppColors.getCardColor(isDark),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.rocket_launch_rounded,
                                    color: AppColors.getPrimaryColor(isDark),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isEnglish
                                        ? 'Services I Offer'
                                        : 'আমার সেবাসমূহ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.getTextColor(isDark),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isEnglish
                                    ? developerInfo['specialization_en']!
                                    : developerInfo['specialization']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.getTextColor(isDark),
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.getPrimaryColor(
                                          isDark,
                                        ).withOpacity(0.2)
                                      : AppColors.getPrimaryColor(
                                          isDark,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isEnglish
                                      ? '💡 From concept to deployment - complete technical solutions for your business'
                                      : '💡 ধারণা থেকে বাস্তবায়ন - আপনার ব্যবসার জন্য সম্পূর্ণ প্রযুক্তিগত সমাধান',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.getPrimaryColor(isDark),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About Section
                      Text(
                        isEnglish ? 'About Me' : 'আমার সম্পর্কে',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: AppColors.getCardColor(isDark),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            isEnglish
                                ? aboutText['about_en']!
                                : aboutText['about']!,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: AppColors.getTextSecondaryColor(isDark),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Contact Section
                      Text(
                        isEnglish ? 'Get In Touch' : 'যোগাযোগ করুন',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: AppColors.getCardColor(isDark),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children:
                                (isEnglish
                                        ? contactInfo['contacts_en']!
                                        : contactInfo['contacts']!)
                                    .map((contact) {
                                      return ListTile(
                                        leading: Text(
                                          contact['icon']!,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        title: Text(
                                          contact['title']!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.getTextColor(
                                              isDark,
                                            ),
                                          ),
                                        ),
                                        subtitle: Text(
                                          contact['value']!,
                                          style: TextStyle(
                                            color:
                                                AppColors.getTextSecondaryColor(
                                                  isDark,
                                                ),
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: AppColors.getPrimaryColor(
                                            isDark,
                                          ),
                                        ),
                                        onTap: () => _launchContact(
                                          contact['type']!,
                                          contact['value']!,
                                          context,
                                        ),
                                      );
                                    })
                                    .toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Call to Action
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? AppColors.darkHeaderGradient
                                : AppColors.lightHeaderGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.handshake_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isEnglish
                                  ? 'Let\'s Build Something Amazing Together!'
                                  : 'চলুন একসাথে কিছু অসাধারণ তৈরি করি!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isEnglish
                                  ? 'Ready to start your next project?'
                                  : 'আপনার পরবর্তী প্রজেক্ট শুরু করতে প্রস্তুত?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Bottom spacing
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
