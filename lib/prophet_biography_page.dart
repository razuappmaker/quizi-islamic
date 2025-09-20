import 'package:flutter/material.dart';

class ProphetBiographyPage extends StatelessWidget {
  const ProphetBiographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'মহানবী (সা.)-এর জীবনী',
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
              // পরিচিতি
              _buildSectionHeader(
                'রাহমাতুল্লিল আলামীন',
                Icons.lightbulb_outline,
                isDarkMode,
              ),
              _buildContentCard(
                'হযরত মুহাম্মদ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) are the last prophet of Islam, sent as a mercy to all mankind. His life is a perfect example for humanity to follow.',
                isDarkMode,
              ),

              // জন্ম ও শৈশব
              _buildBiographyCategory('জন্ম ও শৈশব', Icons.child_care, [
                _buildEventItem(
                  '৫৭০ খ্রিস্টাব্দ',
                  'মক্কার renowned কুরাইশ বংশে জন্মগ্রহণ',
                  'পিতা: আবদুল্লাহ ইবনে আবদুল মুত্তালিব, মাতা: আমিনা বিনতে ওয়াহাব',
                  isDarkMode,
                ),
                _buildEventItem(
                  'জন্মের পূর্বেই',
                  'পিতার ইন্তেকাল',
                  'জন্মের approximately ৬ মাস পূর্বে পিতা আবদুল্লাহ\'s demise',
                  isDarkMode,
                ),
                _buildEventItem(
                  'জন্মের পর',
                  'হালিমা সাদিয়ার care-এ লালিত-পালিত',
                  'বেদুইন পরিবারে childhood, pure Arabic language শিক্ষা',
                  isDarkMode,
                ),
              ], isDarkMode),

              // নামকরণ ও বাল্যকাল
              _buildBiographyCategory(
                'নামকরণ ও বাল্যকাল',
                Icons.assignment_ind,
                [
                  _buildEventItem(
                    'জন্মের ৭ম দিন',
                    'দাদা আবদুল মুত্তালিব নাম রাখেন "মুহাম্মদ"',
                    'যার meaning "প্রশংসিত", "উচ্চ প্রশংসার যোগ্য"',
                    isDarkMode,
                  ),
                  _buildEventItem(
                    '৬ বছর বয়স',
                    'মাতা আমিনার ইন্তেকাল',
                    'মাতার passing পর দাদার guardianship-এ',
                    isDarkMode,
                  ),
                  _buildEventItem(
                    '৮ বছর বয়স',
                    'দাদা আবদুল মুত্তালিবের ইন্তেকাল',
                    'চাচা আবু তালিবের care-এ লালিত-পালিত',
                    isDarkMode,
                  ),
                ],
                isDarkMode,
              ),

              // যৌবন ও বিবাহ
              _buildBiographyCategory('যৌবন ও বিবাহ', Icons.people, [
                _buildEventItem(
                  'কিশোর বয়স',
                  'চাচার সাথে trade journeys',
                  'Syria等地 business trips, "আল-আমিন" (বিশ্বস্ত) উপাধি প্রাপ্তি',
                  isDarkMode,
                ),
                _buildEventItem(
                  '২৫ বছর বয়স',
                  'খাদীজা (রাঃ)-এর সাথে বিবাহ',
                  'খাদীজা ছিলেন wealthy businesswoman, age ৪০ বছর',
                  isDarkMode,
                ),
                _buildEventItem(
                  'বিবাহ পরবর্তী জীবন',
                  'সুখী দাম্পত্য জীবন',
                  '৬ children: কাসিম, আবদুল্লাহ, জয়নব, রুকাইয়া, উম্মে কুলসুম, ফাতিমা',
                  isDarkMode,
                ),
              ], isDarkMode),

              // নবুয়াতের সূচনা
              _buildBiographyCategory('নবুয়াতের সূচনা', Icons.auto_awesome, [
                _buildEventItem(
                  '৪০ বছর বয়স',
                  'হেরা গুহায় meditation',
                  'নিয়মিত solitude-中 contemplation, truth অনুসন্ধান',
                  isDarkMode,
                ),
                _buildEventItem(
                  '৬১০ খ্রিস্টাব্দ',
                  'প্রথম ওহী প্রাপ্তি',
                  'জিবরাঈল (আ.)-এর মাধ্যমে "ইকরা" (পড়) ayat নাযিল',
                  isDarkMode,
                ),
                _buildEventItem(
                  'ওহী প্রাপ্তির পর',
                  'খাদীজা (রাঃ)-কে ঘটনা জানানো',
                  'খাদীজা প্রথম ইসলাম accept করেন এবং support দেন',
                  isDarkMode,
                ),
              ], isDarkMode),

              // মি'রাজ
              _buildBiographyCategory('মি\'রাজ', Icons.flight_takeoff, [
                _buildEventItem(
                  '৬২০ খ্রিস্টাব্দ',
                  'ইসরা ও মি\'রাজ',
                  'মসজিদুল হারাম থেকে মসজিদুল আকসা then সপ্তম আসমান পর্যন্ত journey',
                  isDarkMode,
                ),
                _buildEventItem(
                  'মি\'রাজের night',
                  'সর্বোচ্চ spiritual experience',
                  'আল্লাহর direct dialogue, five daily prayers ফরজ হয়',
                  isDarkMode,
                ),
                _buildEventItem(
                  'ফজরের পর',
                  'মি\'রাজের ঘটনা বর্ণনা',
                  'কুরাইশ leaders不相信, but আবু বকর (রা.) confirm করেন',
                  isDarkMode,
                ),
              ], isDarkMode),

              // দাওয়াতের পর্যায়
              _buildBiographyCategory('দাওয়াতের পর্যায়', Icons.mic, [
                _buildEventItem(
                  '৬১০-৬১৩ খ্রিস্টাব্দ',
                  'গোপনে দাওয়াত',
                  'নিকটতম people-কে ইসলামের message, approximately ৩ বছর',
                  isDarkMode,
                ),
                _buildEventItem(
                  '৬১৩ খ্রিস্টাব্দ',
                  'প্রকাশ্যে দাওয়াত',
                  'সাফা পাহাড়ে open invitation, opposition শুরু হয়',
                  isDarkMode,
                ),
                _buildEventItem(
                  'বিরোধিতা',
                  'কুরাইশদের persecution',
                  'Muslims- উপর torture, economic boycott, social boycott',
                  isDarkMode,
                ),
              ], isDarkMode),

              // তায়েফ গমন
              _buildBiographyCategory('তায়েফ গমন', Icons.landscape, [
                _buildEventItem(
                  '৬১৯ খ্রিস্টাব্দ',
                  'তায়েফে দাওয়াত',
                  'মক্কার outside support খোঁজা, severe rejection enfrentar',
                  isDarkMode,
                ),
                _buildEventItem(
                  'তায়েফবাসীর reaction',
                  'কঠোর প্রত্যাখ্যান',
                  'Stone-marched, severely injured, but patience demonstrated',
                  isDarkMode,
                ),
                _buildEventItem(
                  'প্রার্থনা',
                  'আল্লাহর কাছে দোয়া',
                  'Famous prayer for guidance and mercy for the people',
                  isDarkMode,
                ),
              ], isDarkMode),

              // হিজরত
              _buildBiographyCategory('হিজরত', Icons.travel_explore, [
                _buildEventItem(
                  '৬২২ খ্রিস্টাব্দ',
                  'মদিনায় হিজরত',
                  'মক্কা থেকে মদিনায় migration, Islamic calendar-এর সূচনা',
                  isDarkMode,
                ),
                _buildEventItem(
                  'হিজরতের night',
                  'আলী (রা.)-কে risk নিয়ে রেখে যান',
                  'আবু বকর (রা.)-এর সাথে সাওর cave-中 আশ্রয়',
                  isDarkMode,
                ),
                _buildEventItem(
                  'মদিনায় arrival',
                  'Warm welcome',
                  'Ansar (helpers) and Muhajireen (migrants) brotherhood established',
                  isDarkMode,
                ),
              ], isDarkMode),

              // মদিনার জীবন
              _buildBiographyCategory('মদিনার জীবন', Icons.mosque, [
                _buildEventItem(
                  'মসজিদ নির্মাণ',
                  'মসজিদে নববী প্রতিষ্ঠা',
                  'Community center and place of worship construction',
                  isDarkMode,
                ),
                _buildEventItem(
                  'মদিনা সনদ',
                  'Constitution of Medina',
                  'Multi-religious community-এর জন্য charter প্রণয়ন',
                  isDarkMode,
                ),
                _buildEventItem(
                  'নতুন society গঠন',
                  'Islamic state প্রতিষ্ঠা',
                  'Social, economic, and political system implementation',
                  isDarkMode,
                ),
              ], isDarkMode),

              // গুরুত্বপূর্ণ যুদ্ধসমূহ
              _buildBiographyCategory('গুরুত্বপূর্ণ যুদ্ধসমূহ', Icons.shield, [
                _buildEventItem(
                  '৬২৪ খ্রিস্টাব্দ',
                  'বদরের যুদ্ধ',
                  'First major battle, Muslim victory against overwhelming odds',
                  isDarkMode,
                ),
                _buildEventItem(
                  '৬২৫ খ্রিস্টাব্দ',
                  'উহud的 যুদ্ধ',
                  'Strategic lessons learned, military tactics development',
                  isDarkMode,
                ),
                _buildEventItem(
                  '৬২৭ খ্রিস্টাব্দ',
                  'খন্দকের যুদ্ধ',
                  'Trench warfare, successful defense against coalition forces',
                  isDarkMode,
                ),
              ], isDarkMode),

              // মক্কা বিজয়
              _buildBiographyCategory('মক্কা বিজয়', Icons.flag, [
                _buildEventItem(
                  '৬৩০ খ্রিস্টাব্দ',
                  'মক্কা বিজয়',
                  'Bloodless conquest, general amnesty declaration',
                  isDarkMode,
                ),
                _buildEventItem(
                  'কাবা purification',
                  ' idols ধ্বংস',
                  'Kaaba-কে pure monotheism-এর জন্য reconsecration',
                  isDarkMode,
                ),
                _buildEventItem(
                  'ক্ষমা প্রদর্শন',
                  'General forgiveness',
                  'Former enemies-কে unconditional pardon',
                  isDarkMode,
                ),
              ], isDarkMode),

              // বিদায় হজ্জ
              _buildBiographyCategory('বিদায় হজ্জ', Icons.celebration, [
                _buildEventItem(
                  '৬৩২ খ্রিস্টাব্দ',
                  'বিদায় হজ্জ',
                  'First and only Hajj performed by Prophet (SAW)',
                  isDarkMode,
                ),
                _buildEventItem(
                  'আরাফার ভাষণ',
                  'Historical sermon',
                  'Human rights, social justice, and equality declaration',
                  isDarkMode,
                ),
                _buildEventItem(
                  'কুরআন পূর্ণতা',
                  'Completion of revelation',
                  '"আল-ইয়াওমা আকমালতু লাকুম দীনাকুম" ayat নাযিল',
                  isDarkMode,
                ),
              ], isDarkMode),

              // ওফাত
              _buildBiographyCategory('ওফাত', Icons.invert_colors, [
                _buildEventItem(
                  '৬৩২ খ্রিস্টাব্দ',
                  '最后 illness',
                  'High fever and weakness during his final days',
                  isDarkMode,
                ),
                _buildEventItem(
                  'জুন ৮, ৬৩২ খ্রিস্টাব্দ',
                  'ওফাত',
                  '৬৩ বছর বয়সে ইন্তেকাল, আয়েশা (রা.)-এর room-中',
                  isDarkMode,
                ),
                _buildEventItem(
                  'সমাধি',
                  'রওজা-এ-মুবারক',
                  'মসজিদে নববী-中 সমাহিত, current location',
                  isDarkMode,
                ),
              ], isDarkMode),

              const SizedBox(height: 30),

              // শেষ আয়াত
              Center(
                child: Text(
                  '"আল্লাহ及 তাঁর ফেরেশতাগণ নবীর উপর দরূদ প্রেরণ করেন। হে মুমিনগণ! তোমরাও তাঁর উপর দরূদ প্রেরণ কর及বিশেষভাবে সালাম পেশ কর。"\n(সূরা আল-আহযাব: ৫৬)',
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

  // জীবনী ক্যাটাগরি widget
  Widget _buildBiographyCategory(
    String title,
    IconData icon,
    List<Widget> events,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildSectionHeader(title, icon, isDarkMode),
        const SizedBox(height: 12),
        Column(children: events),
      ],
    );
  }

  // ইভেন্ট আইটেম widget
  Widget _buildEventItem(
    String year,
    String title,
    String description,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.green[900]!.withOpacity(0.2)
            : Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDarkMode
              ? Colors.green[700]!.withOpacity(0.3)
              : Colors.green[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[700] : Colors.green[600],
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.green[100] : Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
