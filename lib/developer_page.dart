import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  DeveloperPage({Key? key}) : super(key: key);

  final String developerName = 'মোঃ রাজু হোসেন';
  final String experience =
      '১০ বছর অভিজ্ঞতা\n(ফ্লাটার অ্যাপস ডেভেলপার ও IT এক্সপার্ট)';

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
    // এখন থিম চেক করবো
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // light mode এর জন্য গ্রেডিয়েন্ট
    final Color backgroundStart = Colors.green.shade900;
    final Color backgroundEnd = Colors.green.shade600;

    // text color আলাদা
    final Color headingColor = isDark ? Colors.white : Colors.white;
    final Color subHeadingColor = isDark ? Colors.white70 : Colors.white70;
    final Color bodyColor = isDark ? Colors.white70 : Colors.white70;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ডেভেলপার'),
        backgroundColor: isDark ? Colors.black : Colors.green.shade900,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
          color: Colors.black, // Dark mode এ শুধু solid কালো ব্যাকগ্রাউন্ড
        )
            : BoxDecoration(
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
                backgroundImage: const AssetImage('assets/images/razu.jpg'),
                backgroundColor: isDark ? Colors.grey[800] : Colors.white24,
              ),
              const SizedBox(height: 20),
              Text(
                developerName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                experience,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: subHeadingColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                aboutDeveloper,
                style: TextStyle(
                  fontSize: 18,
                  color: bodyColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Divider(
                color: isDark ? Colors.white24 : Colors.white54,
                thickness: 1.2,
              ),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'আমার তৈরি কিছু অ্যাপস',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: apps.map((appName) {
                  return Card(
                    color: isDark ? Colors.grey[850] : Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.apps,
                          color: isDark ? Colors.green : Colors.white),
                      title: Text(
                        appName,
                        style: TextStyle(
                          fontSize: 18,
                          color: headingColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right,
                          color: isDark ? Colors.white54 : Colors.white70),
                      onTap: () {
                        // নেভিগেশন
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
