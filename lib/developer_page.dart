import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  DeveloperPage({Key? key}) : super(key: key);

  final String developerName = 'মোহাম্মদ রাজু হোসেন';
  final String experience = '১০ বছর অভিজ্ঞতা\n(ফ্লাটার অ্যাপস ডেভেলপার ও IT এক্সপার্ট)';

  final String aboutDeveloper = '''
👨‍💻 আমি একজন অভিজ্ঞ Flutter অ্যাপ ডেভেলপার এবং IT এক্সপার্ট ।
📱 মোবাইল ও 💻 ওয়েব অ্যাপ ডেভেলপমেন্টে দীর্ঘদিন ধরে কাজ করছি।


🎯 আমার প্রধান লক্ষ্য হলো ব্যবহারকারীদের জন্য এমন অ্যাপ তৈরি করা যা হবে সহজ, আকর্ষণীয় এবং কার্যকরী।


✨ মূল বৈশিষ্ট্যসমূহ:
🔹 আধুনিক ও আকর্ষণীয় ডিজাইন
🔹 ব্যবহারবান্ধব ইন্টারফেস
🔹 দ্রুত ও নির্ভরযোগ্য পারফরম্যান্স


✨ আমি বিশ্বাস করি, প্রতিটি অ্যাপ মানুষের জীবনকে সহজ ও সমৃদ্ধ করার একটি মাধ্যম।
''';
  final List<String> apps = [
    'ইসলামিক কুইজ অ্যাপ',
    'জাকাত ক্যালকুলেটর',
    'প্রবাসীর কষ্ট SMS',
    'ই কমার্স',
    'ওয়েব ভিউ আপস',
    'Recipe Book App',
  ];

  @override
  Widget build(BuildContext context) {
    final Color backgroundStart = Colors.green.shade900;
    final Color backgroundEnd = Colors.green.shade600;
    final TextStyle headingStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    final TextStyle subHeadingStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white70,
    );
    final TextStyle bodyStyle = const TextStyle(
      fontSize: 18,
      color: Colors.white70,
      height: 1.4,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ডেভেলপার'),
        backgroundColor: Colors.green.shade900,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundStart, backgroundEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/images/razu.jpg'),
                backgroundColor: Colors.white24,
              ),
              const SizedBox(height: 20),
              Text(developerName, style: headingStyle),
              const SizedBox(height: 8),
              Text(experience, style: subHeadingStyle,textAlign: TextAlign.center,),
              const SizedBox(height: 20),
              Text(
                aboutDeveloper,
                style: bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Divider(color: Colors.white54, thickness: 1.2),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'আমার তৈরি কিছু অ্যাপস',
                  style: headingStyle.copyWith(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: apps.map((appName) {
                  return Card(
                    color: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.apps, color: Colors.white),
                      title: Text(
                        appName,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                      onTap: () {
                        // তোমার অ্যাপের বিস্তারিত পেজে নেভিগেশন দিতে পারো এখানে
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
