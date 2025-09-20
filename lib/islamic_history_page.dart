import 'package:flutter/material.dart';

class IslamicHistoryPage extends StatelessWidget {
  const IslamicHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ইসলামের ইতিহাস',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.green[800] : Colors.green[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[900]!,
                    Colors.green[900]!.withOpacity(0.8),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[50]!, Colors.white],
                ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // সূচনা অংশ
              _buildSectionHeader(
                'ইসলামের সূচনা',
                Icons.lightbulb_outline,
                isDarkMode,
              ),
              _buildContentCard(
                'ইসলামের ইতিহাস শুরু হয় ৭ম শতাব্দীতে আরব উপদ্বীপে। আল্লাহ তাআলা শেষ নবী হযরত মুহাম্মদ (সা.)-এর মাধ্যমে ইসলাম ধর্মের পূর্ণতা দান করেন। মক্কা নগরীতে ৫৭০ খ্রিস্টাব্দে তাঁর জন্ম এবং ৬১০ খ্রিস্টাব্দে প্রথম ওহী প্রাপ্তির মাধ্যমে ইসলামের যাত্রা শুরু হয়।',
                isDarkMode,
              ),

              const SizedBox(height: 20),

              // গুরুত্বপূর্ণ ঘটনাবলী
              _buildSectionHeader(
                'গুরুত্বপূর্ণ ঘটনাবলী',
                Icons.event,
                isDarkMode,
              ),
              _buildTimelineItem(
                '৬১০ খ্রিস্টাব্দ',
                'প্রথম ওহী প্রাপ্তি (হেরা গুহায়)',
                isDarkMode,
              ),
              _buildTimelineItem(
                '৬২২ খ্রিস্টাব্দ',
                'হিজরত (মক্কা থেকে মদিনায়)',
                isDarkMode,
              ),
              _buildTimelineItem('৬৩০ খ্রিস্টাব্দ', 'মক্কা বিজয়', isDarkMode),
              _buildTimelineItem(
                '৬৩২ খ্রিস্টাব্দ',
                'বিদায় হজ ও নবী (সা.)-এর ওফাত',
                isDarkMode,
              ),

              const SizedBox(height: 20),

              // খোলাফায়ে রাশেদীন
              _buildSectionHeader(
                'খোলাফায়ে রাশেদীন',
                Icons.people,
                isDarkMode,
              ),
              _buildContentCard(
                'নবী মুহাম্মদ (সা.)-এর পর চারজন খলিফা ইসলামী রাষ্ট্র পরিচালনা করেন:\n\n'
                '১. হযরত আবু বকর (রা.) - ৬৩২-৬৩৪ খ্রিস্টাব্দ\n'
                '২. হযরত উমর (রা.) - ৬৩৪-৬৪৪ খ্রিস্টাব্দ\n'
                '৩. হযরত উসমান (রা.) - ৬৪৪-৬৫৬ খ্রিস্টাব্দ\n'
                '৪. হযরত আলী (রা.) - ৬৫৬-৬৬১ খ্রিস্টাব্দ\n\n'
                'এই period ইসলামের প্রসার এবং সংহতির golden age হিসেবে বিবেচিত।',
                isDarkMode,
              ),

              const SizedBox(height: 20),

              // ইসলামের প্রসার
              _buildSectionHeader(
                'ইসলামের বিশ্বব্যাপী প্রসার',
                Icons.public,
                isDarkMode,
              ),
              _buildContentCard(
                '৭ম থেকে ১৬শ শতাব্দী পর্যন্ত ইসলাম迅速ভাবে spread করে:\n\n'
                '• Middle East এবং Persia\n'
                '• North Africa এবং Spain\n'
                '• Central Asia এবং Indian Subcontinent\n'
                '• Southeast Asia এবং Africa\n\n'
                'বিজ্ঞান, philosophy, medicine, mathematics এবং architecture-এ Muslim scholars গুরুত্বপূর্ণ contribution রাখেন।',
                isDarkMode,
              ),

              const SizedBox(height: 20),

              // সাম্রাজ্য ও সভ্যতা
              _buildSectionHeader(
                'ইসলামী সাম্রাজ্য ও সভ্যতা',
                Icons.architecture,
                isDarkMode,
              ),
              _buildExpansionItem(
                'উমাইয়া খিলাফত (৬৬১-৭৫০ খ্রিস্টাব্দ)',
                'দামেস্ক-based প্রথম hereditary মুসলিম সাম্রাজ্য, Spain থেকে India পর্যন্ত বিস্তৃত।',
                isDarkMode,
              ),
              _buildExpansionItem(
                'আব্বাসীয় খিলাফত (৭৫০-১২৫৮ খ্রিস্টাব্দ)',
                'বাগদাদ-based, Islamic Golden Age-এর peak, knowledge এবং culture-এর center।',
                isDarkMode,
              ),
              _buildExpansionItem(
                'অটোমান সাম্রাজ্য (১২৯৯-১৯২২ খ্রিস্টাব্দ)',
                'সর্বশেষ বৃহৎ ইসলামী সাম্রাজ্য, তিন continent জুড়ে বিস্তৃত।',
                isDarkMode,
              ),

              const SizedBox(height: 20),

              // ইসলামের মৌলিক বিষয়
              _buildSectionHeader('ইসলামের মৌলিক বিষয়', Icons.book, isDarkMode),
              _buildContentCard(
                'ইসলাম পাঁচটি মৌলিক ভিত্তির উপর প্রতিষ্ঠিত:\n\n'
                '১. শাহাদাহ - আল্লাহর একত্ববাদ এবং মুহাম্মদ (সা.)-এর রিসালাতের স্বীকৃতি\n'
                '২. সালাত - দৈনিক পাঁচ ওয়াক্ত নামাজ\n'
                '৩. সিয়াম - রমজান মাসের রোজা\n'
                '৪. যাকাত - সম্পদের annual charity\n'
                '৫. হজ - জীবনে once Mecca-তে pilgrimage\n\n'
                'এই pillars মুসলিম的生活 এবং faith-এর foundation গঠন করে।',
                isDarkMode,
              ),

              const SizedBox(height: 30),

              // শেষ কথা
              Center(
                child: Text(
                  '"নিশ্চয়ই আল্লাহর নিকট গ্রহণযোগ্য religion হল ইসলাম。"\n(সূরা আলে ইমরান: ১৯)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.green[200] : Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // সেকশন হেডার widget
  Widget _buildSectionHeader(String title, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDarkMode ? Colors.green[300] : Colors.green[700],
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.green[900],
          ),
        ),
      ],
    );
  }

  // কন্টেন্ট কার্ড widget
  Widget _buildContentCard(String content, bool isDarkMode) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDarkMode ? Colors.white70 : Colors.grey[800],
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  // টাইমলাইন আইটেম widget
  Widget _buildTimelineItem(String year, String event, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.green[700] : Colors.green[500],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              year,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // এক্সপ্যানশন আইটেম widget
  Widget _buildExpansionItem(String title, String content, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.green[300] : Colors.green[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              content,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
