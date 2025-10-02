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

  Widget _buildFeatureItem(String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: isDark ? Color(0xFF2E7D32) : Color(0xFF2E7D32),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'আমাদের কথা',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? Color(0xFF2E7D32) : Color(0xFF2E7D32),
        centerTitle: true,
        elevation: 0,
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
      ),
      body: Container(
        color: isDark ? Color(0xFF121212) : Color(0xFFFAFAFA),
        child: SafeArea(
          bottom: false, // Bottom safe area handle manually
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // লোগো সেকশন
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF2D2D2D) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isDark
                                ? Color(0xFF404040)
                                : Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.mosque_rounded,
                                size: 50,
                                color: isDark
                                    ? Color(0xFF2E7D32)
                                    : Color(0xFF2E7D32),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // টাইটেল সেকশন
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF2D2D2D) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Color(0xFF404040)
                                : Color(0xFFE0E0E0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'আমাদের কথা',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Color(0xFF2E7D32),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // কন্টেন্ট কার্ড
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Color(0xFF404040)
                                : Color(0xFFE0E0E0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // আইকন সহ হেডার
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: isDark
                                      ? Color(0xFF2E7D32)
                                      : Color(0xFF2E7D32),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'অ্যাপ সম্পর্কে',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Color(0xFF37474F),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // মূল টেক্সট
                            Text(
                              aboutText,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: isDark
                                    ? Colors.white70
                                    : Color(0xFF546E7A),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ফিচার লিস্ট
                            _buildFeatureItem(
                              '🔄 নিয়মিত আপডেট',
                              'প্রতিনিয়ত নতুন কুইজ ও প্রশ্ন যোগ করা হয়',
                              isDark,
                            ),
                            _buildFeatureItem(
                              '✅ নির্ভরযোগ্য তথ্য',
                              'সঠিক ও সহজবোধ্যভাবে উপস্থাপন',
                              isDark,
                            ),
                            _buildFeatureItem(
                              '📱 ব্যবহারে সহজ',
                              'সরল ও আকর্ষণীয় ইন্টারফেস',
                              isDark,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // কন্টাক্ট ইনফো
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF2D2D2D) : Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Color(0xFF404040)
                                : Color(0xFFC8E6C9),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.contact_support_rounded,
                              color: isDark
                                  ? Color(0xFF2E7D32)
                                  : Color(0xFF2E7D32),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'যেকোনো প্রশ্ন বা পরামর্শের জন্য',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white70
                                    : Color(0xFF546E7A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ইসলামিক কুইজ টিম',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom spacing for safe area
                      SizedBox(height: safeAreaBottom + 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // বটম বার
      bottomNavigationBar: Container(
        height: 60 + safeAreaBottom,
        padding: EdgeInsets.only(bottom: safeAreaBottom),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Color(0xFF404040) : Color(0xFFE0E0E0),
            ),
          ),
        ),
        child: Center(
          child: Text(
            '© ২০২৫ ইসলামিক কুইজ টিম',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
