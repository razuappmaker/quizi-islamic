import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class SuraPage extends StatefulWidget {
  const SuraPage({Key? key}) : super(key: key);

  @override
  State<SuraPage> createState() => _SuraPageState();
}

class _SuraPageState extends State<SuraPage> {
  final List<Map<String, dynamic>> dailySuras =
  [
// ১. সূরা ফাতিহা
    {
      'title': 'সূরা আল ফাতিহা',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'الْحَمْدُ لِلّهِ رَبِّ الْعَالَمِينَ',
          'transliteration': 'আলহামদু লিল্লাহি রাব্বিল ‘আলামীন',
          'meaning': 'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি সমস্ত জগতের পালনকর্তা।',
        },
        {
          'arabic': 'الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'আর-রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু।',
        },
        {
          'arabic': 'مَالِكِ يَوْمِ الدِّينِ',
          'transliteration': 'মালিকি ইয়াওমিদ-দ্বিন',
          'meaning': 'বিচার দিবসের মালিক।',
        },
        {
          'arabic': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          'transliteration': 'ইয়্যাকা নাআবুদু ওয়া ইয়্যাকা নাস্তা’ইন',
          'meaning': 'আমরা কেবল আপনাকেই উপাসনা করি এবং কেবল আপনাকেই সাহায্য চাই।',
        },
        {
          'arabic': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          'transliteration': 'ইহদিনাস-সিরাতাল মুস্তাকীম',
          'meaning': 'আমাদের সরল পথ প্রদর্শন করুন।',
        },
        {
          'arabic': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          'transliteration': 'সিরাতাল লাযীনা আন’আমতা ‘আলাইহিম গাইরিল মাগদুবি ‘আলাইহিম ওয়ালাদ-দাল্লীন',
          'meaning': 'তাদের পথ যাদের প্রতি আপনি কৃপা করেছেন, যারা অভিশাপপ্রাপ্ত নয়, এবং যারা পথভ্রষ্ট নয়।',
        },
      ],
      'reference': 'কুরআন, সূরা আল ফাতিহা, আয়াত ১-৭'
    },
// ২. সূরা ইখলাস
    {
      'title': 'সূরা ইখলাস',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          'transliteration': 'কুল হুয়া আল্লাহু আহাদ',
          'meaning': 'বলুন, তিনি আল্লাহ এক।',
        },
        {
          'arabic': 'اللَّهُ الصَّمَدُ',
          'transliteration': 'আল্লাহু সসসমাদ',
          'meaning': 'আল্লাহ সর্বনিঃসঙ্গ, সকলের প্রয়োজন তার ওপর।',
        },
        {
          'arabic': 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          'transliteration': 'লাম ইয়ালিদ ওয়ালাম ইউলাদ',
          'meaning': 'তিনি জন্ম দেননি এবং জন্মগ্রহণও করেননি।',
        },
        {
          'arabic': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          'transliteration': 'ওয়ালাম ইয়াকুন লাহু কুফুয়ান আহাদ',
          'meaning': 'এবং তার সমকক্ষ কেউ নেই।',
        },
      ],
      'reference': 'কুরআন, সূরা ইখলাস, আয়াত ১-৪'
    },
// ৩. সূরা ফালাক
    {
      'title': 'সূরা ফালাক',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          'transliteration': 'কুল আউযু বিরাব্বিল ফালাক',
          'meaning': 'বলুন, আমি ভোরের পালনকর্তার আশ্রয় নিই।',
        },
        {
          'arabic': 'مِن شَرِّ مَا خَلَقَ',
          'transliteration': 'মিন শার্রি মা খালাক',
          'meaning': 'তিনি যেসব সৃষ্টি করেছেন তার شر থেকে।',
        },
        {
          'arabic': 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          'transliteration': 'ওয়া মিন শার্রি গাসিকিন ইযা ওয়াকাব',
          'meaning': 'অন্ধকারের شر থেকে, যখন তা ঢাকা দেয়।',
        },
        {
          'arabic': 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          'transliteration': 'ওয়া মিন শার্রি নাফফাতাতি ফিল উকাদ',
          'meaning': 'গুঁথে ফুঁ দেওয়াদের (কু-জাদুর) থেকে।',
        },
        {
          'arabic': 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          'transliteration': 'ওয়া মিন শার্রি হাসেদিন ইযা হাসাদ',
          'meaning': 'ইর্ষুকরী থেকে, যখন সে ইর্ষা করে।',
        },
      ],
      'reference': 'কুরআন, সূরা ফালাক, আয়াত ১-৫'
    },
// ৪. সূরা আন নাস
    {
      'title': 'সূরা নাস',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          'transliteration': 'কুল আউযু বিরাব্বিন নাস',
          'meaning': 'বলুন, আমি মানুষের পালনকর্তার আশ্রয় নিই।',
        },
        {
          'arabic': 'مَلِكِ النَّاسِ',
          'transliteration': 'মালিকিল নাস',
          'meaning': 'মানুষদের রাজা।',
        },
        {
          'arabic': 'إِلَٰهِ النَّاسِ',
          'transliteration': 'ইলাহিন নাস',
          'meaning': 'মানুষদের ইলাহ।',
        },
        {
          'arabic': 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          'transliteration': 'মিন শার্রিল ওয়াসওয়াসিল খন্নাস',
          'meaning': 'শয়তানের ফিসফিসের شر থেকে।',
        },
        {
          'arabic': 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
          'transliteration': 'আল্লাযি ইউওসওসু ফি সুদুরিন নাস',
          'meaning': 'যে মানুষের স্তনে ফিসফিস করে।',
        },
        {
          'arabic': 'مِنَ الْجِنَّةِ وَالنَّاسِ',
          'transliteration': 'মিনাল জিন্নাতি ওয়ান নাস',
          'meaning': 'জিন ও মানুষের মধ্যে থেকে।',
        },
      ],
      'reference': 'কুরআন, সূরা নাস, আয়াত ১-৬'
    },
// ৫. সূরা আল কাওসার
    {
      'title': 'সূরা আল কাওসার',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
          'transliteration': 'ইন্না আ‘তাইনা কাল কাওসার',
          'meaning': 'আমরা তোমাকে অতি প্রাচুর্য প্রদান করেছি।'
        },
        {
          'arabic': 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
          'transliteration': 'ফা সাল্লি লি রব্বিকা ওয়ানহার',
          'meaning': 'অতএব, তোমার পালনকর্তার জন্য নামাজ পড়ো এবং বলি দাও।'
        },
        {
          'arabic': 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
          'transliteration': 'ইন্না শানইকা হুয়া আল-আবতার',
          'meaning': 'তোমার শত্রু নিশ্চয়ই কেটে যাবে।'
        },
      ],
      'reference': 'কুরআন, সূরা আল কাওসার, আয়াত ১-৩'
    },
// ৬. সূরা আন-নাসর
    {
      'title': 'সূরা আন-নাসর',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
          'transliteration': 'ইযা জা’ নসরুল্লাহি ওয়াল ফাতহ',
          'meaning': 'যখন আল্লাহর সাহায্য এবং বিজয় এসেছে।'
        },
        {
          'arabic': 'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا',
          'transliteration': 'ওয়া রা’ইতান নাসা ইয়াদখুলুন ফি দিনিল্লাহি আফওয়াজা',
          'meaning': 'এবং তুমি দেখো মানুষরা আল্লাহর পথে ঢুকছে অনেক দলের মাধ্যমে।'
        },
        {
          'arabic': 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ',
          'transliteration': 'ফা সাব্বিহ বিহামদি রাব্বিকা ওয়াস্তাগফিরহু',
          'meaning': 'সুতরাং তোমার পালনকর্তার প্রশংসা করো এবং তাঁকে ক্ষমা চাও।'
        },
      ],
      'reference': 'কুরআন, সূরা আন-নাসর, আয়াত ১-৩'
    },
// ৭. সূরা আল মাওন
    {
      'title': 'সূরা আল মাউন',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'أَرَأَيْتَ الَّذِي يُكَذِّبُ بِالدِّينِ',
          'transliteration': 'আরাইতা আল-লাযী ইউকাজিবু বিল-দিন',
          'meaning': 'তুমি কি দেখেছ সেইকে যে দিন বিচার অস্বীকার করে?'
        },
        {
          'arabic': 'فَذَلِكَ الَّذِي يَدُعُّ الْيَتِيمَ',
          'transliteration': 'ফা জালিকা আল-লাযী যাদ্দু আল-ইতিম',
          'meaning': 'যে অনাথকে তুচ্ছ করে।'
        },
        {
          'arabic': 'وَلَا يَحُضُّ عَلَى طَعَامِ الْمِسْكِينِ',
          'transliteration': 'ওয়া লা ইয়াহুদু ‘আলা তা‘ামিল মিসকিন',
          'meaning': 'এবং দারিদ্রের জন্য আহার দেওয়ার উৎসাহ দেয় না।'
        },
        {
          'arabic': 'فَوَيْلٌ لِلْمُصَلِّينَ',
          'transliteration': 'ফাওয়েলিল-লিল-মুসাল্লিন',
          'meaning': 'সুতরাং নামাজিদের জন্য ধিক্কার।'
        },
        {
          'arabic': 'الَّذِينَ هُمْ عَنْ صَلَاتِهِمْ سَاهُونَ',
          'transliteration': 'আল্লাযীনা হুম আন সালাতিহিম সাহুন',
          'meaning': 'যারা তাদের নামাজ থেকে উদাসীন।'
        },
        {
          'arabic': 'وَالَّذِينَ هُمْ يُرَاءُونَ',
          'transliteration': 'ওয়াল্লাযীনা হুম ইউরাউন',
          'meaning': 'এবং যারা প্রদর্শনের জন্য করে।'
        },
        {
          'arabic': 'وَيَمْنَعُونَ الْمَاعُونَ',
          'transliteration': 'ওয়া ইয়ামন‘ুনাল মাওন',
          'meaning': 'এবং সাহায্য বন্ধ করে।'
        },
      ],
      'reference': 'কুরআন, সূরা আল মাওন, আয়াত ১-৭'
    },
// ৮. সূরা আল কফিরুন
    {
      'title': 'সূরা আল কফিরুন',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'قُلْ يَا أَيُّهَا الْكَافِرُونَ',
          'transliteration': 'কুলইয়া আয়্যুহাল কাফিরুন',
          'meaning': 'বলুন, হে কাফিরগণ!'
        },
        {
          'arabic': 'لَا أَعْبُدُ مَا تَعْبُدُونَ',
          'transliteration': 'লা আ‘বুদু মা তা‘বুদুন',
          'meaning': 'আমি যা তোমরা উপাসনা করো তা উপাসনা করি না।'
        },
        {
          'arabic': 'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
          'transliteration': 'ওয়া লা আন্ত্রুম ‘আবিদুন মা আ‘বুদ',
          'meaning': 'এবং তোমরা যা আমি উপাসনা করি তা উপাসনা করতে পারবে না।'
        },
        {
          'arabic': 'وَلَا أَنَا عَابِدٌ مَّا عَبَدْتُمْ',
          'transliteration': 'ওয়া লা আনা ‘আবিদুম মা আ‘বাদতুম',
          'meaning': 'আমি তা উপাসনা করি না যা তোমরা উপাসনা করছ।'
        },
        {
          'arabic': 'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
          'transliteration': 'ওয়া লা আন্ত্রুম ‘আবিদুন মা আ‘বুদ',
          'meaning': 'এবং তোমরা তা উপাসনা করবে না যা আমি উপাসনা করি।'
        },
        {
          'arabic': 'لَكُمْ دِينُكُمْ وَلِيَ دِينِ',
          'transliteration': 'লাকুম দিনুম ওয়া লিয়াদিনি',
          'meaning': 'তোমাদের জন্য তোমাদের ধর্ম, এবং আমার জন্য আমার ধর্ম।'
        },
      ],
      'reference': 'কুরআন, সূরা আল কফিরুন, আয়াত ১-৬'
    },
//৯। সূরা কুরাইশ
    {
      'title': 'সূরা কুরাইশ',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'لِإِيلَافِ قُرَيْشٍ',
          'transliteration': 'লি-ইলাফি কুরাইশ',
          'meaning': 'কুরাইশদের অভ্যাসের কারণে,',
        },
        {
          'arabic': 'إِيلَافِهِمْ رِحْلَةَ الشِّتَاءِ وَالصَّيْفِ',
          'transliteration': 'ইলাফিহিম রিহলাতাশ-শিতা-ই ওয়াস্-সাইফ',
          'meaning': 'তাদের শীত ও গ্রীষ্মের সফরের অভ্যাসের কারণে,',
        },
        {
          'arabic': 'فَلْيَعْبُدُوا رَبَّ هَٰذَا الْبَيْتِ',
          'transliteration': 'ফালইয়াবুদু রব্বা হাযাল বাইত',
          'meaning': 'অতএব, তারা যেন এই ঘরের প্রতিপালকের ইবাদত করে,',
        },
        {
          'arabic': 'الَّذِي أَطْعَمَهُم مِّن جُوعٍ وَآمَنَهُم مِّنْ خَوْفٍ',
          'transliteration': 'আল্লাযী আত্‘আমাহুম মিন জু‘ঈঁ ওয়া-আমানাহুম মিন খাওফ',
          'meaning': 'যিনি তাদের ক্ষুধায় আহার দিয়েছেন এবং ভয় থেকে নিরাপদ করেছেন।',
        },
      ],
      'reference': 'কুরআন, সূরা কুরাইশ, আয়াত ১-৪'
    },
//১০। সূরা আল-লাহাব (মাসাদ)
    {
      'title': 'সূরা আল-লাহাব',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'تَبَّتْ يَدَا أَبِي لَهَبٍ وَتَبَّ',
          'transliteration': 'তাব্বাত্ ইয়াদা আবি লাহাবি ওয়াতাব্ব',
          'meaning': 'আবু লাহাবের হাত ধ্বংস হোক, এবং সে নিজেও ধ্বংস হয়েছে।',
        },
        {
          'arabic': 'مَا أَغْنَىٰ عَنْهُ مَالُهُ وَمَا كَسَبَ',
          'transliteration': 'মা আগনা আনহু মালুহু ওয়া মা কাসাব',
          'meaning': 'তার ধন-সম্পদ ও উপার্জন তাকে কোন কাজে আসেনি।',
        },
        {
          'arabic': 'سَيَصْلَىٰ نَارًا ذَاتَ لَهَبٍ',
          'transliteration': 'সায়াসলা নারানজাতালাহাব',
          'meaning': 'সে শীঘ্রই প্রবল শিখাযুক্ত আগুনে প্রবেশ করবে।',
        },
        {
          'arabic': 'وَامْرَأَتُهُ حَمَّالَةَ الْحَطَبِ',
          'transliteration': 'ওয়ামরাতুহু হাম্মালাতাল-হাতাব',
          'meaning': 'আর তার স্ত্রীও (আগুন বহনকারী) কাঁটার বোঝা বহন করবে।',
        },
        {
          'arabic': 'فِي جِيدِهَا حَبْلٌ مِّن مَّسَدٍ',
          'transliteration': 'ফি জিদিহা হাবলুম-মিম-মাসাদ',
          'meaning': 'তার গলায় থাকবে মোটা দড়ির ফাঁস।',
        },
      ],
      'reference': 'কুরআন, সূরা আল-লাহাব, আয়াত ১-৫'
    },
// ১১. সূরা আল ক্বাদর
    {
      'title': 'সূরা আল ক্বাদর',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ',
          'transliteration': 'ইন্না আনজালনাহু ফি লাইলাতিল ক্বদর',
          'meaning': 'নিশ্চয়ই আমরা এটি অবতীর্ণ করেছি লাইলাতুল ক্বদরে।'
        },
        {
          'arabic': 'وَمَا أَدْرَاكَ مَا لَيْلَةُ الْقَدْرِ',
          'transliteration': 'ওয়া মা আদ্রাকা মা লাইলাতুল ক্বদর',
          'meaning': 'তুমি কি জানো লাইলাতুল ক্বদর কী?'
        },
        {
          'arabic': 'لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ',
          'transliteration': 'লাইলাতুল ক্বদর খাইরুন মিন আলফি শাহর',
          'meaning': 'লাইলাতুল ক্বদর এক হাজার মাসের চেয়ে উত্তম।'
        },
      ],
      'reference': 'কুরআন, সূরা আল ক্বাদর, আয়াত ১-৩'
    },
// ১২. সূরা আল ফিল
    {
      'title': 'সূরা আল ফিল',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ',
          'transliteration': 'আলাম তারা কাইফা ফ‘ালা রাব্বুকা বি আসহাবিল ফিল',
          'meaning': 'তুমি কি দেখনি তোমার পালনকর্তা হাতির সাথে লোকদের কী করেছেন?'
        },
        {
          'arabic': 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ',
          'transliteration': 'আলাম যাজ‘াল কায়দাহুম ফি তদলিল',
          'meaning': 'তিনি কি তাদের পরিকল্পনাকে ব্যর্থ করেননি?'
        },
        {
          'arabic': 'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ',
          'transliteration': 'ওয়া আরসালা আলাইহিম তাইরান আবাবীল',
          'meaning': 'এবং তিনি তাদের ওপর পাখি পাঠাল আবাবিল।'
        },
        {
          'arabic': 'تَرْمِيهِم بِحِجَارَةٍ مِنْ سِجِّيلٍ',
          'transliteration': 'তারমিহিম বিহিজারাতিন মিন সিজজিল',
          'meaning': 'যারা ইট দিয়ে নিক্ষেপ করেছিল।'
        },
      ],
      'reference': 'কুরআন, সূরা আল ফিল, আয়াত ১-৫'
    },
// ১৩। সুরা ...।।
    {
      'title': 'সূরা ক্বারিয়াহ',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'الْقَارِعَةُ',
          'transliteration': 'আল-ক্বারিআহ',
          'meaning': 'প্রচণ্ড আঘাত (কিয়ামতের দিন)।',
        },
        {
          'arabic': 'مَا الْقَارِعَةُ',
          'transliteration': 'মা আল-ক্বারিআহ',
          'meaning': 'কি সেই কিয়ামত?',
        },
        {
          'arabic': 'وَمَا أَدْرَاكَ مَا الْقَارِعَةُ',
          'transliteration': 'ওয়া মা আদরাকা মা আল-ক্বারিআহ',
          'meaning': 'আপনি কি জানেন কিয়ামত কী?',
        },
        {
          'arabic': 'يَوْمَ يَكُونُ النَّاسُ كَالْفَرَاشِ الْمَبْثُوثِ',
          'transliteration': 'ইউমা ইয়াকূনু আন-নাসু কালফারাশিল মাব্থূস',
          'meaning': 'যেদিন মানুষ ছড়িয়ে থাকা পোকামাকড়ের মতো হবে।',
        },
        {
          'arabic': 'وَتَكُونُ الْجِبَالُ كَالْعِهْنِ الْمَنفُوشِ',
          'transliteration': 'ওয়াতাকূনুল জিবালু কালইহ্নিল মানফূশ',
          'meaning': 'এবং পর্বতগুলো হবে ঝোপঝাড়ের মতো ছড়িয়ে।',
        },
        {
          'arabic': 'فَأَمَّا مَنْ ثَقُلَتْ مَوَازِينُهُ',
          'transliteration': 'ফা আ ম্মা মান থাকুলাত মাওাজীনুহু',
          'meaning': 'অতএব যার তূলা ভারী হবে,',
        },
        {
          'arabic': 'فَهُوَ فِي عِيشَةٍ رَّاضِيَةٍ',
          'transliteration': 'ফা হুওয়া ফি ই‘ইশাতিন রাদিয়া',
          'meaning': 'তাহার জন্য থাকবে সুখী জীবন।',
        },
        {
          'arabic': 'وَأَمَّا مَنْ خَفَّتْ مَوَازِينُهُ',
          'transliteration': 'ওয়া আ ম্মা মান খাফফাত মাওাজীনুহু',
          'meaning': 'আর যার তূলা হালকা হবে,',
        },
        {
          'arabic': 'فَأُمُّهُ هَاوِيَةٌ',
          'transliteration': 'ফা উম্মুহু হাওইয়া',
          'meaning': 'তার জন্য হবে হতাশাজনক জায়গা।',
        },
        {
          'arabic': 'وَمَا أَدْرَاكَ مَا هِيَهْ',
          'transliteration': 'ওয়া মা আদরাকা মা হিয়াহ',
          'meaning': 'আপনি কি জানেন সেটি কী?',
        },
        {
          'arabic': 'نَارٌ حَامِيَةٌ',
          'transliteration': 'নারুন হামিয়াহ',
          'meaning': 'একটি তপ্ত আগুন।',
        },
      ],
      'reference': 'কুরআন, সূরা ক্বারিয়াহ, আয়াত ১-১১'
    },
// ১৪। সুরা মাআউন
    {
      'title': 'সূরা মাআউন',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'أَرَأَيْتَ الَّذِي يُكَذِّبُ بِالدِّينِ',
          'transliteration': 'আরাইতাল্লাজি ইউকাযিবু বিলদ্দিন',
          'meaning': 'তুমি কি দেখেছ সেই ব্যক্তিকে যে ধর্মকে অস্বীকার করে?',
        },
        {
          'arabic': 'فَذَلِكَ الَّذِي يَدُعُّ الْيَتِيمَ',
          'transliteration': 'ফাযালিকা আল্লাজি যাদুউল ইয়তিম',
          'meaning': 'সে এতই যে অনাথকে তাড়ায়।',
        },
        {
          'arabic': 'وَلَا يَحُضُّ عَلَى طَعَامِ الْمِسْكِينِ',
          'transliteration': 'ওয়ালা ইয়াহুদ্দু ‘আলা তা‘ামিল মিসকিন',
          'meaning': 'এবং দারিদ্রকে খাওয়ানোর প্রতি উদ্দীপনা দেখায় না।',
        },
        {
          'arabic': 'فَوَيْلٌ لِّلْمُصَلِّينَ',
          'transliteration': 'ফাওয়াইলুলিল মুসাল্লীন',
          'meaning': 'সুতরাং নামাজপাঠীদের জন্য শাস্তি রয়েছে।',
        },
        {
          'arabic': 'الَّذِينَ هُمْ عَنْ صَلَاتِهِمْ سَاهُونَ',
          'transliteration': 'আল্লাজিনা হামু আন সালাতিহিম সাহুন',
          'meaning': 'যারা তাদের নামাজ থেকে অবহেলা করে।',
        },
        {
          'arabic': 'الَّذِينَ هُمْ يُرَاؤُونَ',
          'transliteration': 'আল্লাজিনা হামু ইউরা’উন',
          'meaning': 'যারা লোক দেখানোর জন্য (রিয়াকর) কাজ করে।',
        },
        {
          'arabic': 'وَيَمْنَعُونَ الْمَاعُونَ',
          'transliteration': 'ওয়া ইয়ামনা’উনাল মাওয়ুন',
          'meaning': 'এবং যেটি প্রয়োজন তা দান থেকে আটকায়।',
        },
      ],
      'reference': 'কুরআন, সূরা মাআউন, আয়াত ১-৭'
    },
// ১৫। সূরা আত-তীন
    {
      'title': 'সূরা আত-তীন',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'وَالتِّينِ وَالزَّيْتُونِ',
          'transliteration': 'ওয়াত্-তীনি ওয়া যায়তূন',
          'meaning': 'তিন (ডুমুর) ও জলপাইয়ের শপথ,',
        },
        {
          'arabic': 'وَطُورِ سِينِينَ',
          'transliteration': 'ওয়া তূরি সীনীন',
          'meaning': 'আর সিনাই পর্বতের শপথ,',
        },
        {
          'arabic': 'وَهٰذَا الْبَلَدِ الْأَمِينِ',
          'transliteration': 'ওয়া হাাযাল বালাদিল আমীন',
          'meaning': 'এবং এই নিরাপদ নগরীর (মক্কার) শপথ,',
        },
        {
          'arabic': 'لَقَدْ خَلَقْنَا الْإِنْسَانَ فِي أَحْسَنِ تَقْوِيمٍ',
          'transliteration': 'লাকাদ খালাকনাল ইনসানা ফী আহসানি তাকওয়ীম',
          'meaning': 'আমি মানুষকে উত্তম গঠনে সৃষ্টি করেছি।',
        },
        {
          'arabic': 'ثُمَّ رَدَدْنَاهُ أَسْفَلَ سَافِلِينَ',
          'transliteration': 'সুম্মা রাদাদনাহু আসফালা সাফিলীন',
          'meaning': 'তারপর তাকে নীচেরতম স্তরে নামিয়ে দিয়েছি,',
        },
        {
          'arabic': 'إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ فَلَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍ',
          'transliteration': 'ইল্লাল্লাযীনা আামানূ ওয়া আমিলুস্-সালিহাতি ফালাহুম আজরুগ্ইরু মামনূন',
          'meaning': 'কেবল তারা ব্যতীত যারা ঈমান এনেছে এবং সৎকর্ম করেছে, তাদের জন্য নিরবচ্ছিন্ন পুরস্কার রয়েছে।',
        },
        {
          'arabic': 'فَمَا يُكَذِّبُكَ بَعْدُ بِالدِّينِ',
          'transliteration': 'ফামা ইউকাজ্জিবুকা বা‘দু বিদ্দীন',
          'meaning': 'অতএব এরপর কে তোমাকে বিচার দিবসকে মিথ্যা বলাবে?',
        },
        {
          'arabic': 'أَلَيْسَ اللَّهُ بِأَحْكَمِ الْحَاكِمِينَ',
          'transliteration': 'আলাইসাল্লাহু বিআহকামিল হাকিমীন',
          'meaning': 'আল্লাহ কি সর্বাধিক ন্যায়বিচারক নন?',
        },
      ],
      'reference': 'কুরআন, সূরা আত-তীন, আয়াত ১-৮'
    },
// ১৬। সূরা আত-তাকাসুর
    {
      'title': 'সূরা আত-তাকাসুর',
      'ayat': [
        {
          'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
          'transliteration': 'বিসমিল্লাহির রাহমানির রাহিম',
          'meaning': 'পরম করুণাময়, পরম দয়ালু আল্লাহর নামে।',
        },
        {
          'arabic': 'أَلْهَاكُمُ التَّكَاثُرُ',
          'transliteration': 'আলহাকুমুত তাকাসুর',
          'meaning': 'বহুত্বের প্রতিযোগিতা তোমাদেরকে বিভ্রান্ত করেছে।',
        },
        {
          'arabic': 'حَتَّى زُرْتُمُ الْمَقَابِرَ',
          'transliteration': 'হাত্তা যুরতুমুল মাকাবির',
          'meaning': 'যাবত তোমরা কবরস্থানে গমন করলে।',
        },
        {
          'arabic': 'كَلَّا سَوْفَ تَعْلَمُونَ',
          'transliteration': 'কাল্লা সৌফা তা’লামুন',
          'meaning': 'কখনো নয়; তোমরা শীঘ্রই জানতে পারবে।',
        },
        {
          'arabic': 'ثُمَّ كَلَّا سَوْفَ تَعْلَمُونَ',
          'transliteration': 'সুম্মা কাল্লা সৌফা তা’লামুন',
          'meaning': 'পুনরায় বলছি, তোমরা অবশ্যই জানতে পারবে।',
        },
        {
          'arabic': 'كَلَّا لَوْ تَعْلَمُونَ عِلْمَ الْيَقِينِ',
          'transliteration': 'কাল্লা লাও তা’লামুনা ‘ইলমাল ইয়াকীন',
          'meaning': 'কখনো নয়; যদি তোমরা নিশ্চিত জ্ঞান দ্বারা জানতে।',
        },
        {
          'arabic': 'لَتَرَوُنَّ الْجَحِيمَ',
          'transliteration': 'লাতারাওন্নাল জাহীম',
          'meaning': 'অবশ্যই তোমরা জাহান্নামকে দেখতে পাবে।',
        },
        {
          'arabic': 'ثُمَّ لَتَرَوُنَّهَا عَيْنَ الْيَقِينِ',
          'transliteration': 'সুম্মা লাতারাওন্নাহা ‘আইনাল ইয়াকীন',
          'meaning': 'পুনরায় অবশ্যই তোমরা তা প্রত্যক্ষ জ্ঞান দ্বারা দেখতে পাবে।',
        },
        {
          'arabic': 'ثُمَّ لَتُسْأَلُنَّ يَوْمَئِذٍ عَنِ النَّعِيمِ',
          'transliteration': 'সুম্মা লাতুস্‌আলুন্না ইয়াওমাইযিন আনিন না’ইম',
          'meaning': 'তারপর সেদিন তোমাদের অবশ্যই নেয়ামত সম্পর্কে জিজ্ঞাসা করা হবে।',
        },
      ],
      'reference': 'কুরআন, সূরা আত-তাকাসুর, আয়াত ১-৮'
    },
  ];

  Set<int> expandedIndices = {}; // multiple expand
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

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
    expandedIndices.clear(); // exit page -> collapse all
    super.dispose();
  }

  Widget buildSura(Map<String, dynamic> sura, int index) {
    final bool isExpanded = expandedIndices.contains(index);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: Colors.green.withOpacity(0.3),
        child: Column(
          children: [
            ListTile(
              tileColor: isExpanded ? Colors.green[100] : Colors.green[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                sura['title'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.green[800],
                size: 28,
              ),
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    expandedIndices.remove(index);
                  } else {
                    expandedIndices.add(index);
                  }
                });
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: isExpanded
                  ? Padding(
                key: ValueKey('expanded_$index'),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                                  fontSize: 28,
                                  fontFamily: 'Amiri',
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ay['transliteration'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.green[200]
                                    : Colors.green[900],
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'অর্থ: ${ay['meaning'] ?? ''}',
                              style: TextStyle(
                                fontSize: 17,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.black87,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    if ((sura['reference'] ?? '').isNotEmpty)
                      Text(
                        'সূত্র: ${sura['reference']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.deepPurple[400],
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
          'আরবি, বাংলা ও অর্থসহ',
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
