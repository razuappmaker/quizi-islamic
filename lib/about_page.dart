import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  final String aboutText = '''
📖 ইসলামিক কুইজ অনলাইন অ্যাপে আপনাকে আন্তরিক স্বাগতম 🌙

আমাদের মূল লক্ষ্য হলো সহজ ও আকর্ষণীয় উপায়ে ইসলামের জ্ঞান ছড়িয়ে দেওয়া।
এই অ্যাপের মাধ্যমে আপনি ঘরে বসেই ইসলামের মৌলিক বিষয়গুলো শিখতে পারবেন এবং
নিজের জ্ঞান পরীক্ষা করার সুযোগ পাবেন।

✅ প্রতিনিয়ত নতুন প্রশ্ন ও কুইজ যুক্ত করা হয়।
✅ প্রতিটি প্রশ্ন যথাসম্ভব সঠিক ও সহজবোধ্যভাবে উপস্থাপন করা হয়েছে।

আমরা আশা করি এই অ্যাপ আপনার জ্ঞান অর্জন ও চর্চায় সহায়ক হবে।

🤲 আল্লাহ আমাদের সকলকে দ্বীনের সঠিক পথে পরিচালিত করুন।

শুভেচ্ছান্তে,
✨ ইসলামিক কুইজ টিম
''';

  @override
  Widget build(BuildContext context) {
    // Dark / Light mode চেক
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমাদের কথা'),
        backgroundColor: Colors.green[800],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // হেডার ইমেজ বা লোগো
              Center(
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: const AssetImage('assets/images/logo.png'),
                ),
              ),

              const SizedBox(height: 15),

              // টাইটেল
              Text(
                'আমাদের কথা',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.green[800],
                ),
              ),
              const SizedBox(height: 15),

              // বিস্তারিত টেক্সট
              Text(
                aboutText,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),

              const SizedBox(height: 15),

              // নিচের ছোট টেক্সট
              Center(
                child: Text(
                  '© ২০২৫ ইসলামিক কুইজ টিম',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
