import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';

class DeveloperPage extends StatelessWidget {
  DeveloperPage({Key? key}) : super(key: key);

  final Map<String, String> developerInfo = {
    'name': 'মোঃ রাজু হোসেন',
    'name_en': 'Md. Raju Hossain',
    'title': 'সিনিয়র ফ্লাটার ডেভেলপার & IT এক্সপার্ট',
    'title_en': 'Senior Flutter Developer & IT Expert',
    'experience': '১০+ বছর অভিজ্ঞতা',
    'experience_en': '10+ Years Experience',
    'specialization': 'মোবাইল অ্যাপ ডেভেলপমেন্ট, ওয়েব সলিউশন, IT কনসাল্টেন্সি',
    'specialization_en':
        'Mobile App Development, Web Solutions, IT Consultancy',
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

  final Map<String, List<String>> apps = {
    'apps_bn': [
      'ইসলামিক কুইজ অ্যাপ',
      'জাকাত ক্যালকুলেটর',
      'প্রবাসীর কষ্ট SMS',
      'ই-কমার্স সলিউশন',
      'ওয়েব ভিউ অ্যাপস',
      'রেসিপি বুক অ্যাপ',
    ],
    'apps_en': [
      'Islamic Quiz App',
      'Zakat Calculator',
      'Probashi SMS',
      'E-Commerce Solution',
      'Web View Apps',
      'Recipe Book App',
    ],
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
        'value': '+8801303-585259',
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
        'value': '+8801303-585259',
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
          backgroundColor: Colors.red,
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
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? Colors.black : Colors.green[800],
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isEnglish ? 'Developer' : 'ডেভেলপার',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green[900]!,
                          Colors.green[700]!,
                          Colors.green[500]!,
                        ],
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
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundImage: const AssetImage(
                              'assets/images/razu.jpg',
                            ),
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isEnglish
                              ? developerInfo['name_en']!
                              : developerInfo['name']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEnglish
                              ? developerInfo['title_en']!
                              : developerInfo['title']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEnglish
                              ? developerInfo['experience_en']!
                              : developerInfo['experience']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Specialization Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: isDark ? Colors.grey[800] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEnglish
                                  ? developerInfo['specialization_en']!
                                  : developerInfo['specialization']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.grey[800],
                                height: 1.4,
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
                      color: isDark ? Colors.white : Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: isDark ? Colors.grey[800] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        isEnglish
                            ? aboutText['about_en']!
                            : aboutText['about']!,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Portfolio Apps Section
                  Text(
                    isEnglish ? 'Portfolio Apps' : 'আমার তৈরি অ্যাপস',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: isEnglish
                        ? apps['apps_en']!.length
                        : apps['apps_bn']!.length,
                    itemBuilder: (context, index) {
                      final appName = isEnglish
                          ? apps['apps_en']![index]
                          : apps['apps_bn']![index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: isDark ? Colors.grey[800] : Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withOpacity(0.1),
                                Colors.blue.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.apps_rounded,
                                color: Colors.green[600],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  appName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.grey[800],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Contact Section
                  Text(
                    isEnglish ? 'Get In Touch' : 'যোগাযোগ করুন',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: isDark ? Colors.grey[800] : Colors.white,
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
                                        color: isDark
                                            ? Colors.white
                                            : Colors.grey[800],
                                      ),
                                    ),
                                    subtitle: Text(
                                      contact['value']!,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.green[600],
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
                        colors: [Colors.green[700]!, Colors.green[500]!],
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
