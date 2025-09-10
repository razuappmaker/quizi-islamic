import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class NamajAmol extends StatefulWidget {
  const NamajAmol({Key? key}) : super(key: key);

  @override
  State<NamajAmol> createState() => _NamajAmolState();
}

class _NamajAmolState extends State<NamajAmol>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> dailySuras =
  [

    {
      'title': 'আস্তাগফিরুল্লাহ (৩ বার)',
      'ayat': [
        {
          'arabic': 'أَسْتَغْفِرُ اللهَ',
          'transliteration': 'আস্তাগফিরুল্লাহ',
          'meaning': 'আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি',
        },
      ],
      'reference': ''
    },
    {
      'title': 'আল্লাহুম্মা আন্তাস.. (১ বার)',
      'ayat': [
        {
          'arabic': 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالْإِكْرَامِ',
          'transliteration': 'আল্লাহুম্মা আন্তাস সালাম, ও মিনকাস সালাম, তাবারকতা ইয়াজালাল ওয়াল ইকরাম',
          'meaning': 'হে আল্লাহ! আপনি শান্তির উৎস, এবং আপনার কাছ থেকেই শান্তি আসে। আপনি মহিমা ও উদারতার অধিকারী।',
        },
      ],
      'reference': ''
    },
    {
      'title': 'লা ইলাহা ইল্লাল্লাহু.. (১ বার)',
      'ayat': [
        {
          'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ أَحَدُهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          'transliteration': 'লা ইলাহা ইল্লাল্লাহু ওহদাহু, লা শারিকা লাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ওয়া হুয়া আলা কুল্লি শাইইন কদীর',
          'meaning': 'আল্লাহ ছাড়া কোনো উপাস্য নেই। তিনি এক, তাঁর কোনো অংশীদার নেই। রাজত্ব তাঁর, সমস্ত প্রশংসা তাঁর, এবং তিনি সবকিছুর উপর ক্ষমতাশালী।',
        },
      ],
      'reference': ''
    },
    {
      'title': 'আল্লাহুম্মা লা মানি.. (১ বার)',
      'ayat': [
        {
          'arabic': 'اللَّهُمَّ لا مانعَ لِما أعطَيتَ، ولا مُعطِيَ لِما منَعتَ، ولا ينفعُ ذا الجدِّ منك الجَدُُّ',
          'transliteration': 'আল্লাহুম্মা লা মানি‘আ লিমা আ’তাইতা, ওয়ালা মু‘তিয়া লিমা মানা‘তা, ওয়ালা ইয়ানফা‘উ যাল-জাদ্দি মিনকাল-জাদ্দু।',
          'meaning': 'হে আল্লাহ! তুমি যা দাও, তা কেউ ঠেকাতে পারে না; আর তুমি যা রোধ কর, তা কেউ দিতে পারে না; এবং কোনো সম্মানিত বা ক্ষমতাবান ব্যক্তিকে তার সম্মান তোমার কাছ থেকে কোনো উপকারে আসতে পারে না।',
        },
      ],
      'reference': 'সহিহ বুখারী (হাদিস ৮৪৪), সহিহ মুসলিম (হাদিস ৫৯৩)'
    },
    {
      'title': 'লা ইলাহা ইল্লাল্লাহু.. (১ বার) ',
      'ayat': [
        {
          'arabic': 'لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ',
          'transliteration': 'লা ইলাহা ইল্লাল্লাহু, ওহদাহু লা শারীকালাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ওয়া হুয়া ‘আলা কুল্লি শাইইন কদীর',
          'meaning': 'আল্লাহ ছাড়া কোনো ইলাহ নেই; তিনি এক, তাঁর কোনো শরীক নেই। রাজত্ব তাঁরই, প্রশংসা তাঁরই, এবং তিনি সবকিছুর ওপর সর্বশক্তিমান।',
        },
        {
          'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ',
          'transliteration': 'লা হাওলা ওয়া লা কুওওয়াতা ইল্লা বিল্লাহ',
          'meaning': 'আল্লাহর সাহায্য ছাড়া কোনো শক্তি ও ক্ষমতা নেই।',
        },
        {
          'arabic': 'لَا إِلٰهَ إِلَّا اللّٰهُ وَلَا نَعْبُدُ إِلَّا إِيَّاهُ',
          'transliteration': 'লা ইলাহা ইল্লাল্লাহু, ওয়ালা না’বুদু ইল্লা ইয়া-হু',
          'meaning': 'আল্লাহ ছাড়া কোনো ইলাহ নেই, আমরা তাঁর ছাড়া আর কারো ইবাদত করি না।',
        },
        {
          'arabic': 'لَهُ النِّعْمَةُ وَلَهُ الْفَضْلُ وَلَهُ الثَّنَاءُ الْحَسَنُ',
          'transliteration': 'লাহুন নিঅমাতু, ওয়ালাহুল ফাদলু, ওয়ালাহুস সানা-উল হাসান',
          'meaning': 'তাঁরই নেয়ামত, তাঁরই অনুগ্রহ, তাঁরই সুন্দর প্রশংসা।',
        },
        {
          'arabic': 'لَا إِلٰهَ إِلَّا اللّٰهُ مُخْلِصِيْنَ لَهُ الدِّيْنَ وَلَوْ كَرِهَ الْكَافِرُوْنَ',
          'transliteration': 'লা ইলাহা ইল্লাল্লাহু, মুখলিসীনা লাহুদ্দীন, ওয়ালাও কারিহাল কাফিরূন',
          'meaning': 'আল্লাহ ছাড়া কোনো ইলাহ নেই, আমরা একান্তভাবে তাঁর জন্য দ্বীনকে খাঁটি করি, যদিও কাফিররা তা অপছন্দ করে।',
        },
      ],
      'reference': 'সহিহ মুসলিম (হাদিস: ৫৯৪), সহিহ বুখারি (আংশিক বর্ণনা), সালাত পরবর্তী যিকরসমূহের অংশ।',
    },
    {
      'title': 'সুবহানআল্লাহ (৩৩ বার)',
      'ayat': [
        {
          'arabic': 'سُبْحَانَ اللَّهِ',
          'transliteration': 'সুবহানআল্লাহ',
          'meaning': 'মহান আল্লাহর পবিত্রতা ঘোষণা করছি; তিনি সব ত্রুটি ও অপূর্ণতা থেকে মুক্ত',
        },
      ],
      'reference': 'যে ব্যক্তি প্রতিদিন ৩৩ বার সুবহানআল্লাহ, ৩৩ বার আলহামদুলিল্লাহ, '
          '৩৩ বার আল্লাহু আকবর এবং ১০০ বার পূর্ণ করার জন্য – '          ' "লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকালাহু, '
          'লাহুল মুলকু ওয়া লাহুল হামদু, ওয়া হুয়া আলা কুল্লি শাইইন কদীর" '
          'পাঠ করবে – তার গুনাসমূহ সমুদ্রের ফেনার হলে ও  '
          'আল্লাহ তা মাফ করে দিবেন। (সহিহ মুসলিম, হাদিস: ৫৯৭)',
    },
    {
      'title': 'আলহামদুলিল্লাহ (৩৩ বার)',
      'ayat': [
        {
          'arabic': 'الْحَمْدُ لِلَّهِ',
          'transliteration': 'আলহামদুলিল্লাহ',
          'meaning': 'সমস্ত প্রশংসা আল্লাহর জন্য।',
        },
      ],
      'reference': ''
    },
    {
      'title': 'আল্লাহু আকবর (৩৩ বার)',
      'ayat': [
        {
          'arabic': 'الله أَكْبَرُ',
          'transliteration': 'আল্লাহু আকবার',
          'meaning': 'আল্লাহ মহান।',
        },
      ],
      'reference': ''
    },
    {
      'title': 'আল্লাহুম্মা আ-ইন্নি.. (১ বার)',
      'ayat': [
        {
          'arabic': 'اللّهُمَّ أَيِّنّي على ذكرك وشكرك وحسن عبادتك',
          'transliteration': 'আল্লাহুম্মা আ-ইন্নি আলা জিকরিকা ওয়া শুকরিকা ওয়া হুসনি ইবাদাতিক',
          'meaning': 'হে আল্লাহ! আমাকে আপনার স্মরণ, কৃতজ্ঞতা এবং সুন্দরভাবে আপনার উপাসনা করার উপযোগী কর।',
        },
      ],
      'reference': ''
    },
    {
      'title': 'সূরা আল-ইখলাস',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, অতি দয়ালু আল্লাহর নামে শুরু করছি।',
        },
        {
          'arabic': 'قُلْ هُوَ اللّٰهُ أَحَدٌ',
          'transliteration': 'কুল হুয়াল্লাহু আহাদ',
          'meaning': 'বলুন, তিনিই আল্লাহ, তিনি এক।',
        },
        {
          'arabic': 'اَللّٰهُ الصَّمَدُ',
          'transliteration': 'আল্লাহুস সমাদ',
          'meaning': 'আল্লাহ অমুখাপেক্ষী।',
        },
        {
          'arabic': 'لَمْ يَلِدْ وَلَمْ يُوْلَدْ',
          'transliteration': 'লাম ইয়ালিদ ওয়ালাম ইউলাদ',
          'meaning': 'তিনি কাউকে জন্ম দেননি এবং জন্মগ্রহণও করেননি।',
        },
        {
          'arabic': 'وَلَمْ يَكُنْ لَّهٗ كُفُوًا أَحَدٌ',
          'transliteration': 'ওয়ালাম ইয়াকুল্লাহু কুফুওয়ান আহাদ',
          'meaning': 'তাঁর সমকক্ষ কেউ নেই।',
        },
      ],
      'reference': 'কুরআন, সূরা আল-ইখলাস (১১২: ১-৪)',
    },
    {
      'title': 'সূরা আল-ফালাক',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, অতি দয়ালু আল্লাহর নামে শুরু করছি।',
        },
        {
          'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          'transliteration': 'কুল আউযু বিরাব্বিল ফালাক',
          'meaning': 'বলুন, আমি আশ্রয় চাই প্রভাতের পালনকর্তার কাছে।',
        },
        {
          'arabic': 'مِنْ شَرِّ مَا خَلَقَ',
          'transliteration': 'মিন শাররি মা খালাক',
          'meaning': 'তিনি যা সৃষ্টি করেছেন, তার অনিষ্ট থেকে।',
        },
        {
          'arabic': 'وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          'transliteration': 'ওয়া মিন শাররি গাসিকিন ইযা ওয়াকাব',
          'meaning': 'অন্ধকার রাত্রির অনিষ্ট থেকে, যখন তা সমাগত হয়।',
        },
        {
          'arabic': 'وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          'transliteration': 'ওয়া মিন শাররিন্নাফফাছাতি ফিল উকাদ',
          'meaning': 'গিঁটে ফুঁ দেয়া জাদুকারিণীদের অনিষ্ট থেকে।',
        },
        {
          'arabic': 'وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          'transliteration': 'ওয়া মিন শাররি হাসিদিন ইযা হাসাদ',
          'meaning': 'হিংসুকের অনিষ্ট থেকে, যখন সে হিংসা করে।',
        },
      ],
      'reference': 'কুরআন, সূরা আল-ফালাক (১১৩: ১-৫)',
    },
    {
      'title': 'সূরা আন-নাস',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, অতি দয়ালু আল্লাহর নামে শুরু করছি।',
        },
        {
          'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          'transliteration': 'কুল আউযু বিরাব্বিন্-নাস',
          'meaning': 'বলুন, আমি আশ্রয় চাই মানুষের পালনকর্তার কাছে।',
        },
        {
          'arabic': 'مَلِكِ النَّاسِ',
          'transliteration': 'মালিকিন্-নাস',
          'meaning': 'মানুষের সম্রাটের কাছে।',
        },
        {
          'arabic': 'إِلٰهِ النَّاسِ',
          'transliteration': 'ইলাহিন্-নাস',
          'meaning': 'মানুষের উপাস্যর কাছে।',
        },
        {
          'arabic': 'مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          'transliteration': 'মিন শাররিল ওয়াসওয়াসিল খান্নাস',
          'meaning': 'কুমন্ত্রণা দানকারী ধূর্তের অনিষ্ট থেকে।',
        },
        {
          'arabic': 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
          'transliteration': 'আল্লাজি ইউওয়াসউইসু ফি সুদূরিন্-নাস',
          'meaning': 'যে কুমন্ত্রণা দেয় মানুষের অন্তরে।',
        },
        {
          'arabic': 'مِنَ الْجِنَّةِ وَالنَّاسِ',
          'transliteration': 'মিনাল-জিন্নাতি ওয়ান্-নাস',
          'meaning': 'জিন ও মানুষের মধ্যে থেকে।',
        },
      ],
      'reference': 'কুরআন, সূরা আন-নাস (১১৪: ১-৬)',
    },
    {
      'title': 'আয়াতুল কুরসি (১ বার)',
      'ayat': [
        {
          'arabic': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
          'transliteration': 'আল্লাহু লা ইলাহা ইল্লা হু আল-হাইয়্যুল-কাইয়্যুম',
          'meaning': 'আল্লাহ ছাড়া কোনো ইলাহ নেই; তিনি চিরঞ্জীব, সবকিছুর রক্ষক।',
        },
        {
          'arabic': 'لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
          'transliteration': 'লা তা’খুজুহু সিন্নাতুন ওয়ালা নাওম',
          'meaning': 'তাকে তন্দ্রা কিংবা নিদ্রা স্পর্শ করতে পারে না।',
        },
        {
          'arabic': 'لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
          'transliteration': 'লাহু মা ফিস-সামাওয়াতি ওয়া মা ফিল-আরদ',
          'meaning': 'আসমান ও জমিনে যা কিছু আছে সবই তাঁর।',
        },
        {
          'arabic': 'مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ',
          'transliteration': 'মান ধাল্লাযী ইয়াশফা‘ু ‘ইন্দাহু ইল্লা বি ইয্নিহি',
          'meaning': 'তার অনুমতি ছাড়া কে সুপারিশ করতে পারে?',
        },
        {
          'arabic': 'يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ',
          'transliteration': 'ইয়ালামু মা বাইনা আয়দিহিম ওয়া মা খলফাহুম',
          'meaning': 'তিনি জানেন যা তাদের সামনে এবং যা তাদের পেছনে।',
        },
        {
          'arabic': 'وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ',
          'transliteration': 'ওয়া লা ইউহীতুনা বিষাই-ইম মিন ‘ইলমিহি ইল্লা বিমা শা\'',
          'meaning': 'তারা তাঁর জ্ঞানের কিছুই আয়ত্ত করতে পারে না, তবে যতটুকু তিনি ইচ্ছা করেন।',
        },
        {
          'arabic': 'سِعَتْ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ',
          'transliteration': 'সিআত কুরসিইহুস-সামাওয়াতি ওয়াল-আরদ',
          'meaning': 'তাঁর কুরসি আসমান ও জমিনকে পরিবেষ্টন করেছে।',
        },
        {
          'arabic': 'وَلَا يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
          'transliteration': 'ওয়া লা ইয়াউদুহু হিফযুহুমা; ওয়া হুয়াল-‘আলিইয়্যুল-‘আজীম',
          'meaning': 'এ দু’টিকে রক্ষা করা তাঁকে ক্লান্ত করে না; তিনি মহীয়ান, মহা মহান।',
        },
      ],
      'reference': 'কুরআন, সূরা আল-বাকারাহ, আয়াত ২৫৫',
    },
    {
      'title': 'লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু.. (১০ বার) ফরজ ও মাগরিবের পর',
      'ayat': [
        {
          'arabic': 'لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِيْ وَيُمِيْتُ، وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ',
          'transliteration': 'লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকালাহু, লাহুল মুলকু ওয়ালাহুল হামদু, ইউহয়ী ওয়া ইউমীতু, ওয়া হুয়া আলা কুল্লি শাইয়িন কাদীর',
          'meaning': 'আল্লাহ ছাড়া কোনো উপাস্য নেই, তিনি একক, তাঁর কোনো শরীক নেই। রাজত্ব তাঁরই, প্রশংসা তাঁরই। তিনি জীবন দান করেন এবং মৃত্যু দেন, আর তিনি সর্বশক্তিমান।',
        },
      ],
      'reference': 'সহিহ মুসলিম (হাদিস: ২৭৩১), সহিহ বুখারি (আংশিক বর্ণনা)',
    },
    {
      'title': 'আল্লাহুম্মা ইন্নি আসআলুকা (১ বার) ফজরের পরে',
      'ayat': [
        {
          'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا',
          'transliteration': 'আল্লাহুম্মা ইন্নি আসআলুকা ইল্মান নাফি’আন, ওয়া রিজকান তয়্যিবান, ওয়া আমালান মুতাক্বাব্বালান',
          'meaning': 'হে আল্লাহ! আমি আপনার কাছে উপকারী জ্ঞান, হালাল রিযিক এবং কবুলযোগ্য আমল প্রার্থনা করছি।',
        },
      ],
      'reference': 'দোয়া: উপকারী জ্ঞান, হালাল রিযিক ও কবুল হওয়া আমলের জন্য, সুনান ইবনে মাজাহ, হাদিস: ৯২৫',
    }

  ];

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  int? expandedIndex; // কোন টাইল ওপেন থাকবে সেটা ট্র্যাক করার জন্য

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  Widget buildSura(Map<String, dynamic> sura, int index) {
    final bool isExpanded = expandedIndex == index;

    // MediaQuery for responsive sizing
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.04; // 4% padding
    final double titleFont = screenWidth * 0.05; // approx 20px
    final double arabicFont = screenWidth * 0.07; // approx 26px
    final double transliterationFont = screenWidth * 0.05; // ~20px
    final double meaningFont = screenWidth * 0.045; // 18px
    final double referenceFont = screenWidth * 0.035; // 14px

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: horizontalPadding),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          children: [
            ListTile(
              tileColor: isExpanded ? Colors.green[200] : Colors.green[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                sura['title'] ?? '',
                style: TextStyle(
                  fontSize: titleFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.black54,
                size: screenWidth * 0.06, // responsive icon size
              ),
              onTap: () {
                setState(() {
                  expandedIndex = isExpanded ? null : index;
                });
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                final offsetAnimation =
                Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero)
                    .animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: isExpanded
                  ? Padding(
                key: ValueKey('expanded_$index'),
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...List<Widget>.from(
                      (sura['ayat'] as List<dynamic>).map(
                            (ay) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: SelectableText(
                                ay['arabic'] ?? '',
                                style: TextStyle(
                                  fontSize: arabicFont,
                                  fontFamily: 'Amiri',
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(height: screenWidth * 0.015),
                            Text(
                              ay['transliteration'] ?? '',
                              style: TextStyle(
                                fontSize: transliterationFont,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.green[200]
                                    : Colors.green[900],
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: screenWidth * 0.015),
                            Text(
                              'অর্থ: ${ay['meaning'] ?? ''}',
                              style: TextStyle(
                                fontSize: meaningFont,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.black87,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: screenWidth * 0.03),
                          ],
                        ),
                      ),
                    ),
                    if ((sura['reference'] ?? '').isNotEmpty)
                      Text(
                        'নোটঃ ${sura['reference']}',
                        style: TextStyle(
                          fontSize: referenceFont,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.deepPurple,
                        ),
                      ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'ফরজ নামাজ পরবর্তী জিকির',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dailySuras.length,
              itemBuilder: (context, index) =>
                  buildSura(dailySuras[index], index),
            ),
          ),
          if (_isBannerAdReady)
            SafeArea(
              child: SizedBox(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
      ),
    );
  }
}
