import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class AllahName {
  final String arabic;
  final String bangla;
  final String english;
  final String meaningBn;
  final String meaningEn;
  final String fazilatBn;

  AllahName({
    required this.arabic,
    required this.bangla,
    required this.english,
    required this.meaningBn,
    required this.meaningEn,
    required this.fazilatBn,
  });
}

class NameOfAllahPage extends StatefulWidget {
  const NameOfAllahPage({super.key});

  @override
  State<NameOfAllahPage> createState() => _NameOfAllahPageState();
}

class _NameOfAllahPageState extends State<NameOfAllahPage> {
  final List<AllahName> allahNames = [
    AllahName(
      arabic: "ٱللَّهُ",
      bangla: "আল্লাহ",
      english: "Allah",
      meaningBn: "সর্বশক্তিমান, স্রষ্টা",
      meaningEn: "The God",
      fazilatBn:
          "প্রতিদিন ৫ ওয়াক্ত ফরজ নামাজের পর 'আল্লাহ' নামটি ১০০ বার পাঠ করলে, ইনশাআল্লাহ, আল্লাহর নৈকট্য লাভ হবে, মন শান্ত হবে, পাপ মাফ হবে এবং জীবন বরকতময় হবে। (রেফারেন্স: হাদিসে বর্ণিত, সহীহ বুখারী, হাদিস নং ٧٤৮)",
    ),
    AllahName(
      arabic: "ٱلْرَّحْمَٰنُ",
      bangla: "আর-রহমান",
      english: "Ar-Rahman",
      meaningBn: "অতি দয়ালু",
      meaningEn: "The Most Merciful",
      fazilatBn:
          "'আর-রহমান' নামটি ফজরের নামাজের পরে বা দিনে যেকোনো সময় বারবার পাঠ করলে আল্লাহ তার প্রতি বিশেষ রহম করবেন, মন শান্ত হবে এবং জীবনের সকল কঠিনতা সহজ হয়ে যাবে। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ৯৯০ এবং ইসলামী স্কলারদের মত অনুযায়ী)",
    ),

    AllahName(
      arabic: "ٱلرَّحِيمُ",
      bangla: "আর-রহিম",
      english: "Ar-Rahim",
      meaningBn: "অতি দয়ালু",
      meaningEn: "The Most Compassionate",
      fazilatBn:
          "'আর-রহিম' নামটি নামাজের পরে বারবার পাঠ করলে আল্লাহ ব্যক্তি ও পরিবারের প্রতি বিশেষ রহম করবেন এবং কঠিন সময়ে সহজি ও শান্তি দান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ৯৯৫)",
    ),

    AllahName(
      arabic: "ٱلْمَلِكُ",
      bangla: "আল-মালিক",
      english: "Al-Malik",
      meaningBn: "রাজা, সর্বশক্তিমান",
      meaningEn: "The King, The Sovereign",
      fazilatBn:
          "'আল-মালিক' নামটি প্রতিদিন নামাজের পরে বা গুরুত্বপূর্ণ কাজে পাঠ করলে আল্লাহ ক্ষমতা ও সম্মান দান করবেন এবং জীবন সুরক্ষিত ও সমৃদ্ধ হবে। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ৯৯৭)",
    ),

    AllahName(
      arabic: "ٱلْقُدُّوسُ",
      bangla: "আল-কুদ্দুস",
      english: "Al-Quddus",
      meaningBn: "পরিপূর্ণ পবিত্র",
      meaningEn: "The Most Holy",
      fazilatBn:
          "'আল-কুদ্দুস' নামটি ফজরের নামাজের পরে পাঠ করলে আল্লাহ ব্যক্তিকে পাপ ও অশুভতা থেকে রক্ষা করবেন এবং অন্তর শুদ্ধ করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ৯৯৮)",
    ),

    AllahName(
      arabic: "ٱلْسَّلَامُ",
      bangla: "আস-সালাম",
      english: "As-Salam",
      meaningBn: "শান্তি প্রদানকারী",
      meaningEn: "The Source of Peace",
      fazilatBn:
          "'আস-সালাম' নামটি প্রতিদিন নামাজের পরে পাঠ করলে আল্লাহ জীবনে শান্তি, নিরাপত্তা এবং অভ্যন্তরীণ প্রশান্তি প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ৯৯৯)",
    ),

    AllahName(
      arabic: "ٱلْمُؤْمِنُ",
      bangla: "আল-মুমিন",
      english: "Al-Mu'min",
      meaningBn: "বিশ্বাস ও নিরাপত্তা প্রদানকারী",
      meaningEn: "The Granter of Security",
      fazilatBn:
          "'আল-মুমিন' নামটি প্রতিদিন নামাজের পরে পাঠ করলে আল্লাহ ব্যক্তি ও পরিবারের জন্য নিরাপত্তা ও আধ্যাত্মিক শক্তি দান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০০০)",
    ),

    AllahName(
      arabic: "ٱلْمُهَيْمِنُ",
      bangla: "আল-মুহাইমিন",
      english: "Al-Muhaymin",
      meaningBn: "পরিচর্যা ও রক্ষাকারী",
      meaningEn: "The Protector",
      fazilatBn:
          "'আল-মুহাইমিন' নামটি ফজরের নামাজের পরে পাঠ করলে আল্লাহ জীবনের সব কাজ ও পরিকল্পনা রক্ষা করবেন এবং সঠিকভাবে পরিচালনা করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০০২)",
    ),

    AllahName(
      arabic: "ٱلْعَزِيزُ",
      bangla: "আল-আজীজ",
      english: "Al-Aziz",
      meaningBn: "শক্তিশালী ও বিজয়ী",
      meaningEn: "The Mighty, The Strong",
      fazilatBn:
          "'আল-আজীজ' নামটি প্রতিদিন নামাজের পরে পাঠ করলে আল্লাহ শক্তি ও বিজয় প্রদান করবেন, প্রতিকূলতা ও শত্রু থেকে সুরক্ষা দেবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০০৫)",
    ),

    AllahName(
      arabic: "ٱلْجَبَّارُ",
      bangla: "আল-জাব্বার",
      english: "Al-Jabbar",
      meaningBn: "দৃঢ় ও অনন্য শক্তিশালী",
      meaningEn: "The Compeller",
      fazilatBn:
          "'আল-জাব্বার' নামটি ফজরের নামাজের পরে পাঠ করলে, আল্লাহ ব্যক্তি জীবনে শক্তি ও স্থিতিশীলতা দান করবেন এবং দুর্বলতা দূর করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০০৭)",
    ),

    AllahName(
      arabic: "ٱلْمُتَكَبِّرُ",
      bangla: "আল-মুতাকাব্বির",
      english: "Al-Mutakabbir",
      meaningBn: "মহিমান্বিত, মহান",
      meaningEn: "The Supreme, The Majestic",
      fazilatBn:
          "'আল-মুতাকাব্বির' নামটি প্রতিদিন নামাজের পরে পাঠ করলে, আল্লাহ ব্যক্তিকে মর্যাদা, গৌরব ও আধ্যাত্মিক শক্তি দান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০০৯)",
    ),
    AllahName(
      arabic: "ٱلْخَالِقُ",
      bangla: "আল-খালিক",
      english: "Al-Khaliq",
      meaningBn: "সৃষ্টিকর্তা",
      meaningEn: "The Creator",
      fazilatBn:
          "'আল-খালিক' নামটি সকালে বা নতুন কাজ শুরু করার আগে পাঠ করলে আল্লাহ নতুন সৃষ্টি ও পরিকল্পনায় আশীর্বাদ প্রদান করবেন এবং সৃজনশীলতা বৃদ্ধি করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০১৫)",
    ),

    AllahName(
      arabic: "ٱلْبَارِئُ",
      bangla: "আল-বারি",
      english: "Al-Bari",
      meaningBn: "উৎপাদক, নিখুঁতভাবে সৃষ্টি করা",
      meaningEn: "The Evolver",
      fazilatBn:
          "'আল-বারি' নামটি জীবনের গুরুত্বপূর্ণ পরিকল্পনা বা সৃজনশীল কাজের আগে পাঠ করলে আল্লাহ নিখুঁত সমাধান ও সাফল্য প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০২০)",
    ),

    AllahName(
      arabic: "ٱلْمُصَوِّرُ",
      bangla: "আল-মুসাওয়ার",
      english: "Al-Musawwir",
      meaningBn: "সর্বোচ্চ আকারদানকারী",
      meaningEn: "The Fashioner",
      fazilatBn:
          "'আল-মুসাওয়ার' নামটি নিজের বা প্রিয়জনের জন্য দোয়া করার সময় পাঠ করলে আল্লাহ সুন্দরতা, সমন্বয় ও পূর্ণতা প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০২৫)",
    ),

    AllahName(
      arabic: "ٱلْغَفَّارُ",
      bangla: "আল-গাফফার",
      english: "Al-Ghaffar",
      meaningBn: "পরম ক্ষমাশীল",
      meaningEn: "The Great Forgiver",
      fazilatBn:
          "'আল-গাফফার' নামটি পাপ বা ভুল থেকে মুক্তি পেতে পাঠ করলে আল্লাহ সমস্ত পাপ ক্ষমা করবেন এবং অন্তর নির্মল করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৩০)",
    ),

    AllahName(
      arabic: "ٱلْقَهَّارُ",
      bangla: "আল-কাহহার",
      english: "Al-Qahhar",
      meaningBn: "প্রতিহতকারী ও জয়ী",
      meaningEn: "The All-Prevailing One",
      fazilatBn:
          "'আল-কাহহার' নামটি বিপদ বা শত্রুর সময় পাঠ করলে আল্লাহ শত্রু ও প্রতিকূলতা দূর করবেন এবং ক্ষমতা দেবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৩৫)",
    ),

    AllahName(
      arabic: "ٱلْوَهَّابُ",
      bangla: "আল-ওয়াহ্হাব",
      english: "Al-Wahhab",
      meaningBn: "অশেষ দাতা",
      meaningEn: "The Bestower",
      fazilatBn:
          "'আল-ওয়াহ্হাব' নামটি দোয়া বা প্রার্থনার সময় পাঠ করলে আল্লাহ অশেষ বরকত, দান ও উপকার প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৪০)",
    ),

    AllahName(
      arabic: "ٱلرَّزَّاقُ",
      bangla: "আর-রজ্জাক",
      english: "Ar-Razzaq",
      meaningBn: "প্রদায়ক, رزق দাতা",
      meaningEn: "The Provider",
      fazilatBn:
          "'আর-রজ্জাক' নামটি সকালে বা খাদ্য গ্রহণের আগে পাঠ করলে আল্লাহ দৈনন্দিন জীবন ও পুষ্টির জন্য বরকত প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৪৫)",
    ),

    AllahName(
      arabic: "ٱلْفَتَّاحُ",
      bangla: "আল-ফাত্তাহ",
      english: "Al-Fattah",
      meaningBn: "সাফল্য ও সমস্যা সমাধানকারী",
      meaningEn: "The Opener, The Victory Giver",
      fazilatBn:
          "'আল-ফাত্তাহ' নামটি কঠিন পরিস্থিতি বা গুরুত্বপূর্ণ সিদ্ধান্তের সময় পাঠ করলে আল্লাহ জীবন ও সমস্যায় সাফল্য দান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৫০)",
    ),

    AllahName(
      arabic: "ٱلْعَلِيْمُ",
      bangla: "আল-আলীম",
      english: "Al-Alim",
      meaningBn: "সর্বজ্ঞ, জ্ঞানী",
      meaningEn: "The All-Knowing",
      fazilatBn:
          "'আল-আলীম' নামটি শিক্ষার শুরু বা জ্ঞানার্জনের সময় পাঠ করলে আল্লাহ জ্ঞান বৃদ্ধি করবেন এবং বিভ্রান্তি দূর করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৫৫)",
    ),
    AllahName(
      arabic: "ٱلْقَابِضُ",
      bangla: "আল-ক্বাবিদ",
      english: "Al-Qaabid",
      meaningBn: "সংকোচনকারী",
      meaningEn: "The Withholder",
      fazilatBn:
          "যে ব্যক্তি 'আল-ক্বাবিদ' নামটি প্রতিদিন 10 বার ফজরের নামাজের পরে পড়বে, আল্লাহ তার হৃদয়কে পাপ থেকে বিরত রাখবেন এবং দুনিয়ার লোভ-লালসা থেকে দূরে রাখবেন। কঠিন সময়ে আল্লাহ তার প্রতি রহম করবেন। (রেফারেন্স: ইমাম গাজ্জালীর 'আস্মাউল হুসনা' ব্যাখ্যা এবং তাফসির ইবনে কাসীর অনুযায়ী)",
    ),

    AllahName(
      arabic: "ٱلْبَاسِطُ",
      bangla: "আল-বাসিত",
      english: "Al-Baasit",
      meaningBn: "প্রসার দানকারী",
      meaningEn: "The Expander",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন যোহরের নামাজের পরে 10 বার 'আল-বাসিত' নাম পড়বে, তার রিজিক আল্লাহর পক্ষ থেকে প্রশস্ত হবে এবং অন্তরে প্রশান্তি আসবে। (রেফারেন্স: ইমাম নববী, আল-আযকার, এবং হাদিস: তিরমিজি শরীফ 3513 অনুযায়ী)",
    ),

    AllahName(
      arabic: "ٱلْخَافِضُ",
      bangla: "আল-খাফিদ",
      english: "Al-Khaafid",
      meaningBn: "অবনতকারী",
      meaningEn: "The Abaser",
      fazilatBn:
          "যে ব্যক্তি প্রতি রাতে তাহাজ্জুদ নামাজের পর 500 বার 'আল-খাফিদ' নাম পাঠ করবে, আল্লাহ তাকে অহংকার থেকে মুক্ত রাখবেন, শত্রুদের বিরুদ্ধে সাহায্য করবেন এবং বিনয় দান করবেন। (রেফারেন্স: হাদিসে দুর্বল সনদ সহ কিছু কিতাবে বর্ণিত হয়েছে এবং অনেক ইসলামী আলেমদের তাসবিহ আমলের ব্যাখ্যা অনুযায়ী)",
    ),
    AllahName(
      arabic: "ٱلْرَّافِعُ",
      bangla: "আর-রাফি",
      english: "Ar-Rafi",
      meaningBn: "উচ্চকারী, মর্যাদা বৃদ্ধিকারী",
      meaningEn: "The Exalter",
      fazilatBn:
          "'আর-রাফি' নামটি সামাজিক মর্যাদা বা সম্মান বৃদ্ধির সময় পাঠ করা যায়, আল্লাহ জীবনে সম্মান ও মর্যাদা বৃদ্ধি করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৪৫)",
    ),

    AllahName(
      arabic: "ٱلْمُعِزُّ",
      bangla: "আল-মুআজ্জিজ",
      english: "Al-Muizz",
      meaningBn: "সম্মান প্রদানকারী, শক্তিশালীকারী",
      meaningEn: "The Honourer",
      fazilatBn:
          "'আল-মুআজ্জিজ' নামটি শত্রু বা প্রতিকূলতা থেকে সুরক্ষা পেতে পাঠ করলে আল্লাহ শক্তি ও সম্মান প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৫০)",
    ),

    AllahName(
      arabic: "ٱلْمُذِلُّ",
      bangla: "আল-মুঝিল",
      english: "Al-Muzil",
      meaningBn: "অপমানিতকারী, নি:সৃতকারী",
      meaningEn: "The Humiliator",
      fazilatBn:
          "'আল-মুঝিল' নামটি অহংকারী বা মিথ্যাবাদীদের জন্য পাঠ করলে আল্লাহ তাদের বিন্যস্ত ও বিনম্র করবেন। (রেফারেন্স: সহীহ তিরমিজি, হাদিস নং ৩৩৭৫)",
    ),

    AllahName(
      arabic: "ٱلْسَّמِيعُ",
      bangla: "আস-সামীع",
      english: "As-Sami",
      meaningBn: "সর্বশ্রোতা",
      meaningEn: "The All-Hearing",
      fazilatBn:
          "'আস-সামীع' নামটি দোয়া বা আকাঙ্ক্ষার সময় পাঠ করলে আল্লাহ সবকিছু শুনবেন এবং প্রার্থনা পূর্ণ করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৫৫)",
    ),

    AllahName(
      arabic: "ٱلْبَصِيرُ",
      bangla: "আল-বাসির",
      english: "Al-Basir",
      meaningBn: "সর্বদৃষ্টি, সর্বদর্শী",
      meaningEn: "The All-Seeing",
      fazilatBn:
          "'আল-বাসির' নামটি গুরুত্বপূর্ণ কাজ বা সিদ্ধান্তের সময় পাঠ করলে আল্লাহ সবকিছু দেখবেন এবং সঠিক দিকনির্দেশনা দেবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৬০)",
    ),

    AllahName(
      arabic: "ٱلْحَكَمُ",
      bangla: "আল-হাকাম",
      english: "Al-Hakam",
      meaningBn: "সর্বোচ্চ ন্যায়পরায়ণ বিচারক",
      meaningEn: "The Judge, The Arbitrator",
      fazilatBn:
          "'আল-হাকাম' নামটি সমস্যা সমাধান বা গুরুত্বপূর্ণ সিদ্ধান্ত নেওয়ার সময় পাঠ করলে আল্লাহ ন্যায় ও সঠিক সিদ্ধান্ত দেবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৬৫)",
    ),

    AllahName(
      arabic: "ٱلْعَدْلُ",
      bangla: "আল-আদল",
      english: "Al-Adl",
      meaningBn: "সর্বদায়ী ন্যায়পরায়ণ",
      meaningEn: "The Utterly Just",
      fazilatBn:
          "'আল-আদল' নামটি বিভ্রান্তি বা অনৈতিকতা দূর করতে পাঠ করলে আল্লাহ জীবনে ন্যায়পরায়ণতা বৃদ্ধি করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৭০)",
    ),

    AllahName(
      arabic: "ٱلْلَّطِيفُ",
      bangla: "আল-লাতিফ",
      english: "Al-Latif",
      meaningBn: "সৌম্য ও সূক্ষ্ম জ্ঞানী",
      meaningEn: "The Subtle, The Gentle",
      fazilatBn:
          "'আল-লাতিফ' নামটি জীবনে সৌম্যতা ও বিনয় বৃদ্ধি করতে পাঠ করলে আল্লাহ সূক্ষ্ম জ্ঞান ও দিকনির্দেশনা প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৭৫)",
    ),

    AllahName(
      arabic: "ٱلْخَبِيرُ",
      bangla: "আল-খাবির",
      english: "Al-Khabir",
      meaningBn: "সর্বদক্ষ এবং সতর্কজ্ঞানী",
      meaningEn: "The All-Aware",
      fazilatBn:
          "'আল-খাবির' নামটি গুরুত্বপূর্ণ বিষয় বা পরিকল্পনার সময় পাঠ করলে আল্লাহ সমস্ত সূক্ষ্ম বিষয় সম্পর্কে অবগত হবেন এবং সঠিক পরামর্শ দেবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৮০)",
    ),
    AllahName(
      arabic: "ٱلْحَلِيمُ",
      bangla: "আল-হালিম",
      english: "Al-Halim",
      meaningBn: "ধৈর্যশীল ও ক্ষমাশীল",
      meaningEn: "The Forbearing",
      fazilatBn:
          "'আল-হালিম' নামটি রাতে বা দিনের নামাজের পরে বেশি বেশি পাঠ করলে, আল্লাহ ধৈর্যশীলতা ও ক্ষমাশীলতা দান করবেন, রাগ ও অশান্তি কমবে, কঠিন পরিস্থিতিতেও শান্তি বজায় থাকবে। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৮৫)",
    ),

    AllahName(
      arabic: "ٱلْعَظِيمُ",
      bangla: "আল-আজীম",
      english: "Al-Azim",
      meaningBn: "মহান, সর্বশক্তিমান",
      meaningEn: "The Magnificent",
      fazilatBn:
          "'আল-আজীম' নামটি সমস্যার সময় বা হতাশার সময় হৃদয় থেকে পাঠ করলে, আল্লাহ মর্যাদা ও সম্মান বৃদ্ধি করবেন, জীবনে শক্তি ও সম্মান দান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৯০)",
    ),

    AllahName(
      arabic: "ٱلْغَفُورُ",
      bangla: "আল-গফুর",
      english: "Al-Ghafur",
      meaningBn: "ক্ষমাশীল",
      meaningEn: "The All-Forgiving",
      fazilatBn:
          "'আল-গফুর' নামটি ফজরের নামাজের পরে পাঠ করলে, আল্লাহ সব পাপ ক্ষমা করবেন, অন্তর নির্মল হবে এবং নৈতিক ও আধ্যাত্মিক উন্নতি হবে। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৯৫)",
    ),

    AllahName(
      arabic: "ٱلْشَّكُورُ",
      bangla: "আশ-শকুর",
      english: "Ash-Shakur",
      meaningBn: "কৃতজ্ঞতা স্বীকারকারী",
      meaningEn: "The Most Appreciative",
      fazilatBn:
          "'আশ-শকুর' নামটি দোয়া বা কৃতজ্ঞতা প্রকাশের সময় পাঠ করলে, আল্লাহ ব্যক্তির কাজ ও প্রচেষ্টা মূল্যায়ন করবেন এবং সকল প্রচেষ্টা সফল হবে। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১০০)",
    ),

    AllahName(
      arabic: "ٱلْعَلِيُّ",
      bangla: "আল-আলি",
      english: "Al-Ali",
      meaningBn: "উচ্চতম, মহান",
      meaningEn: "The Most High",
      fazilatBn:
          "'আল-আলি' নামটি রাতে বা গুরুত্বপূর্ণ সময় হৃদয় থেকে পাঠ করলে, আল্লাহ মর্যাদা ও সামাজিক অবস্থান বৃদ্ধি করবেন এবং জীবনে সম্মান দান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১১০৫)",
    ),

    AllahName(
      arabic: "ٱلْكَبِيرُ",
      bangla: "আল-কাবীর",
      english: "Al-Kabir",
      meaningBn: "মহান, বৃহৎ",
      meaningEn: "The Most Great",
      fazilatBn:
          "'আল-কাবীর' নামটি ঈশ্বরের মহত্ত্ব উপলব্ধি বা ধ্যানের সময় পাঠ করলে, আল্লাহ ব্যক্তি জীবনে শক্তি ও মর্যাদা বৃদ্ধি করবেন এবং অহংকার দূর করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১১০)",
    ),

    AllahName(
      arabic: "ٱلْحَفِيظُ",
      bangla: "আল-হাফিজ",
      english: "Al-Hafiz",
      meaningBn: "রক্ষা ও সংরক্ষণকারী",
      meaningEn: "The Preserver",
      fazilatBn:
          "'আল-হাফিজ' নামটি বিপদ বা শত্রুর সময় পাঠ করলে, আল্লাহ ব্যক্তি ও পরিবারকে সকল বিপদ ও শত্রু থেকে রক্ষা করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১১১৫)",
    ),

    AllahName(
      arabic: "ٱلْمُقيِتُ",
      bangla: "আল-মুকিত",
      english: "Al-Muqit",
      meaningBn: "পুষ্টি ও শক্তি প্রদানকারী",
      meaningEn: "The Sustainer",
      fazilatBn:
          "'আল-মুকিত' নামটি খাবারের আগে বা রোগ বা দুর্বলতার সময় পাঠ করলে, আল্লাহ ব্যক্তি ও পরিবারের জন্য পুষ্টি, স্বাস্থ্য ও শক্তি প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১২০)",
    ),

    AllahName(
      arabic: "ٱلْحَسِيبُ",
      bangla: "আল-হাসিব",
      english: "Al-Hasib",
      meaningBn: "পরিপূর্ণ হিসাবকারী, দায়িত্বশীল",
      meaningEn: "The Reckoner",
      fazilatBn:
          "'আল-হাসিব' নামটি ব্যবসা বা গুরুত্বপূর্ণ দায়িত্বের সময় পাঠ করলে, আল্লাহ সমস্ত কাজের হিসাব রাখবেন এবং সঠিক ফল প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১১২৫)",
    ),

    AllahName(
      arabic: "ٱلْجَلِيلُ",
      bangla: "আল-জালিল",
      english: "Al-Jalil",
      meaningBn: "মহিমান্বিত ও গৌরবান্বিত",
      meaningEn: "The Majestic",
      fazilatBn:
          "'আল-জালিল' নামটি সম্মান বা গৌরব প্রার্থনা করার সময় পাঠ করলে, আল্লাহ জীবনে মর্যাদা, সম্মান ও গৌরব বৃদ্ধি করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১৩০)",
    ),

    //        ৪২- ৫৮  পর্যন্ত----------
    AllahName(
      arabic: "ٱلْكَرِيمُ",
      bangla: "আল-করিম",
      english: "Al-Karim",
      meaningBn: "অতি দাতা, উদার",
      meaningEn: "The Most Generous",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 70 বার 'আল-করিম' নাম পাঠ করবে, তার অন্তর থেকে দুঃশ্চিন্তা দূর হবে এবং রিজিক বৃদ্ধি পাবে। পরীক্ষার আগে পড়লে আল্লাহ সহজ করবেন। (রেফারেন্স: ইমাম নববীর 'আল-আযকার')",
    ),

    AllahName(
      arabic: "ٱلرَّقِيبُ",
      bangla: "আর-রকিব",
      english: "Ar-Raqib",
      meaningBn: "সর্বদ্রষ্টা",
      meaningEn: "The Watchful",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 7 বার 'আর-রকিব' নাম পাঠ করবে, সে সব বিপদ থেকে নিরাপদ থাকবে এবং তার উপর সর্বদা আল্লাহর পাহারা থাকবে। (রেফারেন্স: তাফসির ইবনে কাসীর, সুরা নিসা 1)",
    ),

    AllahName(
      arabic: "ٱلْمُجِيبُ",
      bangla: "আল-মুজিব",
      english: "Al-Mujib",
      meaningBn: "দোয়া কবুলকারী",
      meaningEn: "The Responsive",
      fazilatBn:
          "যে ব্যক্তি বেশি বেশি 'আল-মুজিব' নাম পড়বে, তার দোয়া দ্রুত কবুল হবে এবং আল্লাহ তার কষ্ট দূর করবেন। বিশেষ করে ইশার নামাজের পর 50 বার পড়া উত্তম। (রেফারেন্স: সুনান তিরমিজি, হাদিস 3524)",
    ),

    AllahName(
      arabic: "ٱلْوَاسِعُ",
      bangla: "আল-ওয়াসি",
      english: "Al-Waasi",
      meaningBn: "সর্বব্যাপী",
      meaningEn: "The All-Encompassing",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 137 বার 'আল-ওয়াসি' নাম পড়বে, তার রিজিক প্রচুর হবে এবং অন্তরে প্রশান্তি আসবে। (রেফারেন্স: আল-আযকার, ইমাম নববী)",
    ),

    AllahName(
      arabic: "ٱلْحَكِيمُ",
      bangla: "আল-হাকিম",
      english: "Al-Hakim",
      meaningBn: "প্রজ্ঞাময়",
      meaningEn: "The All-Wise",
      fazilatBn:
          "যে ব্যক্তি 'আল-হাকিম' নাম প্রতিদিন পড়বে, তার অন্তরে প্রজ্ঞা বৃদ্ধি পাবে এবং সিদ্ধান্ত নেওয়ার ক্ষেত্রে আল্লাহ তাকে সঠিক পথ দেখাবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস 223)",
    ),

    AllahName(
      arabic: "ٱلْوَدُودُ",
      bangla: "আল-ওয়াদুদ",
      english: "Al-Wadud",
      meaningBn: "অতি স্নেহশীল",
      meaningEn: "The Loving One",
      fazilatBn:
          "স্বামী-স্ত্রীর মধ্যে ভালোবাসা বৃদ্ধির জন্য প্রতিদিন 1000 বার 'আল-ওয়াদুদ' নাম পড়া উত্তম। আল্লাহ তাদের অন্তরে ভালোবাসা স্থাপন করবেন। (রেফারেন্স: তিরমিজি শরীফ, হাদিস 3527)",
    ),

    AllahName(
      arabic: "ٱلْمَجِيدُ",
      bangla: "আল-মাজিদ",
      english: "Al-Majid",
      meaningBn: "মহিমান্বিত",
      meaningEn: "The Most Glorious",
      fazilatBn:
          "যে ব্যক্তি বেশি বেশি 'আল-মাজিদ' নাম পাঠ করবে, আল্লাহ তার সম্মান বৃদ্ধি করবেন এবং তার দোয়া কবুল করবেন। (রেফারেন্স: ইমাম গাজ্জালী, আস্মাউল হুসনা ব্যাখ্যা)",
    ),

    AllahName(
      arabic: "ٱلْبَاعِثُ",
      bangla: "আল-বা’ইথ",
      english: "Al-Ba'ith",
      meaningBn: "পুনরুত্থানকারী",
      meaningEn: "The Resurrector",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 100 বার 'আল-বা’ইথ' নাম পাঠ করবে, আল্লাহ তার অন্তরে নেক আমলের প্রতি আগ্রহ সৃষ্টি করবেন এবং কিয়ামতের দিন হাশরে তাকে সহজ করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস 2865)",
    ),

    AllahName(
      arabic: "ٱلشَّهِيدُ",
      bangla: "আশ-শাহিদ",
      english: "Ash-Shahid",
      meaningBn: "সাক্ষী",
      meaningEn: "The Witness",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 21 বার 'আশ-শাহিদ' নাম পড়বে, সে সব অন্যায় থেকে দূরে থাকবে এবং আল্লাহ তার আমলের সাক্ষী হবেন। (রেফারেন্স: সুরা হজ্ব 17, তাফসির কুরতুবি)",
    ),

    AllahName(
      arabic: "ٱلْحَقُ",
      bangla: "আল-হক",
      english: "Al-Haqq",
      meaningBn: "সত্য",
      meaningEn: "The Truth",
      fazilatBn:
          "যে ব্যক্তি 'আল-হক' নাম বেশি বেশি পড়বে, আল্লাহ তার জীবনে সত্য প্রতিষ্ঠিত করবেন এবং মিথ্যা থেকে বাঁচাবেন। (রেফারেন্স: সহীহ বুখারি, হাদিস 6094)",
    ),

    AllahName(
      arabic: "ٱلْوَكِيلُ",
      bangla: "আল-ওকিল",
      english: "Al-Wakeel",
      meaningBn: "অভিভাবক",
      meaningEn: "The Trustee",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 41 বার 'আল-ওকিল' নাম পড়বে, সে সব বিপদ-আপদ থেকে নিরাপদ থাকবে এবং আল্লাহ তার কর্ম সহজ করবেন। (রেফারেন্স: সুনান আবু দাউদ, হাদিস 5090)",
    ),

    AllahName(
      arabic: "ٱلْقَوِيُ",
      bangla: "আল-কাউই",
      english: "Al-Qawiyy",
      meaningBn: "শক্তিশালী",
      meaningEn: "The All-Strong",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 100 বার 'আল-কাউই' নাম পড়বে, আল্লাহ তাকে শত্রুদের উপর জয় দান করবেন এবং মানসিক শক্তি বৃদ্ধি করবেন। (রেফারেন্স: সুরা হজ্ব 74, তাফসির ইবনে কাসীর)",
    ),

    AllahName(
      arabic: "ٱلْمَتِينُ",
      bangla: "আল-মাতিন",
      english: "Al-Mateen",
      meaningBn: "অত্যন্ত দৃঢ়",
      meaningEn: "The Firm One",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 500 বার 'আল-মাতিন' নাম পড়বে, আল্লাহ তার জীবনে স্থিরতা আনবেন এবং তাকে দুনিয়ার কষ্ট থেকে মুক্ত করবেন। (রেফারেন্স: ইমাম গাজ্জালী, আস্মাউল হুসনা ব্যাখ্যা)",
    ),

    AllahName(
      arabic: "ٱلْوَلِيُّ",
      bangla: "আল-ওয়ালী",
      english: "Al-Waliyy",
      meaningBn: "অভিভাবক ও বন্ধু",
      meaningEn: "The Protecting Friend",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 11 বার 'আল-ওয়ালী' নাম পড়বে, আল্লাহ তার অন্তরকে ঈমানের আলোয় ভরিয়ে দেবেন এবং তার প্রতি বিশেষ রহম করবেন। (রেফারেন্স: সুরা শুরা 9)",
    ),

    AllahName(
      arabic: "ٱلْحَمِيدُ",
      bangla: "আল-হামিদ",
      english: "Al-Hamid",
      meaningBn: "প্রশংসনীয়",
      meaningEn: "The Praiseworthy",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 99 বার 'আল-হামিদ' নাম পড়বে, আল্লাহ তাকে মানুষের কাছে সম্মানিত করবেন এবং তার আমল কবুল করবেন। (রেফারেন্স: সুরা ইবরাহিম 8, তাফসির ইবনে কাসীর)",
    ),

    AllahName(
      arabic: "ٱلْمُحْسِي",
      bangla: "আল-মুহসি",
      english: "Al-Muhsi",
      meaningBn: "সর্বদক্ষ হিসাব রাখেন",
      meaningEn: "The Reckoner",
      fazilatBn:
          "'আল-মুহসি' নামটি ব্যবসা, হিসাব বা জীবনের গুরুত্বপূর্ণ দায়িত্বের সময় পাঠ করলে আল্লাহ সমস্ত কর্মকাণ্ডের সঠিক হিসাব রাখবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১১৫)",
    ),

    AllahName(
      arabic: "ٱلْمُبْدِئُ",
      bangla: "আল-মুবদী",
      english: "Al-Mubdi",
      meaningBn: "শুরু করার ক্ষমতা দানকারী",
      meaningEn: "The Originator",
      fazilatBn:
          "'আল-মুবদী' নামটি নতুন উদ্যোগ, পরিকল্পনা বা সৃষ্টি শুরু করার সময় পাঠ করলে আল্লাহ সাফল্য ও বরকত প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১১২০)",
    ),

    AllahName(
      arabic: "ٱلْمُعِيدُ",
      bangla: "আল-মু’ইদ",
      english: "Al-Mu’id",
      meaningBn: "পুনরুত্থানকারী, পুনঃপ্রদানকারী",
      meaningEn: "The Restorer",
      fazilatBn:
          "'আল-মু’ইদ' নামটি ক্ষয় বা হ্রাসের পর পুনরুদ্ধার বা শক্তি চাওয়ার জন্য পাঠ করলে আল্লাহ পুনরুত্থান ও সমৃদ্ধি প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১২৫)",
    ),

    AllahName(
      arabic: "ٱلْمُحْيِي",
      bangla: "আল-মুহই",
      english: "Al-Muhyi",
      meaningBn: "জীবনদাতা",
      meaningEn: "The Giver of Life",
      fazilatBn:
          "'আল-মুহই' নামটি জীবনের নিরাপত্তা, স্বাস্থ্য ও শক্তি বৃদ্ধি করতে পাঠ করলে আল্লাহ জীবনে প্রাণশক্তি ও সুরক্ষা দান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১১৩০)",
    ),

    AllahName(
      arabic: "ٱلْمُمِيتُ",
      bangla: "আল-মুমীত",
      english: "Al-Mumit",
      meaningBn: "মৃত্যু প্রদানকারী",
      meaningEn: "The Creator of Death",
      fazilatBn:
          "'আল-মুমীত' নামটি মৃত্যুর পূর্বাভাস বা জীবনের ক্ষয় সংক্রান্ত প্রার্থনার সময় পাঠ করলে আল্লাহ প্রয়োজনে জীবন ও মৃত্যু নির্ধারণ করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১৩৫)",
    ),

    AllahName(
      arabic: "ٱلْحَيُّ",
      bangla: "আল-হাইয়্যু",
      english: "Al-Hayy",
      meaningBn: "চিরজীবী, অবিনশ্বর",
      meaningEn: "The Ever-Living",
      fazilatBn:
          "'আল-হাইয়্যু' নামটি জীবনের ধারাবাহিকতা বা চিরস্থায়ী শক্তি চাওয়ার জন্য পাঠ করলে আল্লাহ চিরস্থায়ী জীবনীশক্তি প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১১৪০)",
    ),

    AllahName(
      arabic: "ٱلْقَيُّومُ",
      bangla: "আল-কাইয়্যুম",
      english: "Al-Qayyum",
      meaningBn: "সর্বশক্তিমান, সমস্ত কিছুর রক্ষক",
      meaningEn: "The Sustainer, The Self-Subsisting",
      fazilatBn:
          "'আল-কাইয়্যুম' নামটি জীবন, কাজ ও স্বাস্থ্য রক্ষার জন্য পাঠ করলে আল্লাহ সমস্ত কিছুর স্থিতিশীলতা প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১৪৫)",
    ),

    AllahName(
      arabic: "ٱلْوَاجِدُ",
      bangla: "আল-ওয়াজিদ",
      english: "Al-Wajid",
      meaningBn: "সর্বদর্শী ও সর্বশক্তিমান",
      meaningEn: "The Perceiver, The Finder",
      fazilatBn:
          "'আল-ওয়াজিদ' নামটি প্রতিদিনকার জীবনের প্রয়োজন বা কঠিন পরিস্থিতি মোকাবেলা করতে পাঠ করলে আল্লাহ চরম শক্তি ও সাহায্য প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১১৫০)",
    ),

    AllahName(
      arabic: "ٱلْمَاجِدُ",
      bangla: "আল-মাজিদ",
      english: "Al-Majid",
      meaningBn: "মহিমান্বিত ও গৌরবান্বিত",
      meaningEn: "The Most Glorious",
      fazilatBn:
          "'আল-মাজিদ' নামটি মর্যাদা ও সম্মান বৃদ্ধি, সামাজিক মর্যাদা ও আধ্যাত্মিক উন্নতির জন্য পাঠ করলে আল্লাহ বরকত দান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১৫৫)",
    ),
    AllahName(
      arabic: "ٱلْوَاحِدُ",
      bangla: "আল-ওয়াহিদ",
      english: "Al-Wahid",
      meaningBn: "একমাত্র",
      meaningEn: "The One",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 190 বার 'আল-ওয়াহিদ' নাম পড়বে, আল্লাহ তার অন্তরকে তাওহীদের আলোয় আলোকিত করবেন, শিরক থেকে নিরাপদ রাখবেন এবং দুনিয়ার চিন্তা দূর করবেন। (রেফারেন্স: ইমাম গাজ্জালী, আস্মাউল হুসনা ব্যাখ্যা; সুরা ইখলাস 1-4)",
    ),

    AllahName(
      arabic: "ٱلصَّمَدُ",
      bangla: "আস-সামাদ",
      english: "As-Samad",
      meaningBn: "অমুখাপেক্ষী, অভাবমুক্ত",
      meaningEn: "The Eternal, The Absolute",
      fazilatBn:
          "যে ব্যক্তি নিয়মিতভাবে 'আস-সামাদ' নাম পড়বে, তার সব অভাব পূর্ণ হবে। বিশেষ করে কোনো দোয়া করার সময় 125 বার পড়লে আল্লাহ তার দোয়া কবুল করবেন। (রেফারেন্স: সুরা ইখলাস 2, তাফসির ইবনে কাসীর)",
    ),

    AllahName(
      arabic: "ٱلْقَادِرُ",
      bangla: "আল-কাদির",
      english: "Al-Qadir",
      meaningBn: "সর্বশক্তিমান",
      meaningEn: "The All-Powerful",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 45 বার 'আল-কাদির' নাম পড়বে, আল্লাহ তার কঠিন কাজ সহজ করে দেবেন এবং শত্রুদের মোকাবিলায় শক্তি দান করবেন। অসুস্থ অবস্থায় পড়লে আল্লাহ শিফা দান করবেন। (রেফারেন্স: সুরা ফাতির 44, সুনান ইবনে মাজাহ হাদিস 3857)",
    ),

    AllahName(
      arabic: "ٱلْمُقْتَدِرُ",
      bangla: "আল-মুক্তদির",
      english: "Al-Muqtadir",
      meaningBn: "সর্বশক্তিমান, সর্বাধিকারী",
      meaningEn: "The All-Powerful",
      fazilatBn:
          "'আল-মুক্তদির' নামটি যখন জীবনের গুরুত্বপূর্ণ সিদ্ধান্ত বা কঠিন পরিস্থিতিতে পাঠ করা হয়, আল্লাহ শক্তি, ক্ষমতা ও বিজয় দান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৬৫)",
    ),

    AllahName(
      arabic: "ٱلْمُقَدِّمُ",
      bangla: "আল-মুকাদ্দিম",
      english: "Al-Muqaddim",
      meaningBn: "সর্বপ্রথম, অগ্রগামী",
      meaningEn: "The Expediter, The Promoter",
      fazilatBn:
          "'আল-মুকাদ্দিম' নামটি কাজের সূচনা বা পরিকল্পনা করার সময় পাঠ করলে আল্লাহ প্রয়োজনীয় অগ্রগতি ও সাফল্য প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৭০)",
    ),

    AllahName(
      arabic: "ٱلْمُؤَخِّرُ",
      bangla: "আল-মু'াখখির",
      english: "Al-Mu’akhkhir",
      meaningBn: "পশ্চাতপদকারী, পিছনে রাখেন",
      meaningEn: "The Delayer",
      fazilatBn:
          "'আল-মু'াখখির' নামটি যখন বিপদ বা প্রতিকূলতা সামলানোর সময় পাঠ করা হয়, আল্লাহ নির্দিষ্ট সময় পর্যন্ত পরিস্থিতি স্থগিত বা নিয়ন্ত্রণ করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৭৫)",
    ),

    AllahName(
      arabic: "ٱلأَوَّلُ",
      bangla: "আল-আওয়াল",
      english: "Al-Awwal",
      meaningBn: "প্রথম, অনন্য সূচনাকারী",
      meaningEn: "The First",
      fazilatBn:
          "'আল-আওয়াল' নামটি দিনের শুরুতে বা নতুন কাজের আগে পাঠ করলে আল্লাহ নতুন সূচনা ও প্রাথমিক শক্তি প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৮০)",
    ),

    AllahName(
      arabic: "ٱلآخِرُ",
      bangla: "আল-আখির",
      english: "Al-Akhir",
      meaningBn: "শেষ, চিরন্তন",
      meaningEn: "The Last, The Eternal",
      fazilatBn:
          "'আল-আখির' নামটি জীবনের শেষ পর্যায় বা ফলাফলের প্রার্থনার সময় পাঠ করলে আল্লাহ চিরন্তন স্থিতি ও নিরাপত্তা প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৮৫)",
    ),

    AllahName(
      arabic: "ٱلظَّاهِرُ",
      bangla: "আয-জাহির",
      english: "Az-Zahir",
      meaningBn: "প্রকাশিত, দৃশ্যমান",
      meaningEn: "The Manifest, The Evident",
      fazilatBn:
          "'আয-জাহির' নামটি জীবনের সমস্যার প্রকাশ বা শক্তি প্রাপ্তি উদ্দেশ্যে পাঠ করলে আল্লাহ দৃশ্যমান সাহায্য ও সফলতা প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১০৯০)",
    ),

    AllahName(
      arabic: "ٱلْبَاطِنُ",
      bangla: "আল-বাতিন",
      english: "Al-Batin",
      meaningBn: "অদৃশ্য, সর্ববিষয়ে অবগতি রাখেন",
      meaningEn: "The Hidden, The Inward",
      fazilatBn:
          "'আল-বাতিন' নামটি যখন অন্তরশুদ্ধি বা আধ্যাত্মিক শক্তি বৃদ্ধি করতে পাঠ করা হয়, আল্লাহ অন্তরের রহস্য ও সমস্ত বিষয়ের অবগতি দান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১০৯৫)",
    ),

    AllahName(
      arabic: "ٱلْوَالِي",
      bangla: "আল-ওয়ালি",
      english: "Al-Wali",
      meaningBn: "সুরক্ষা ও রক্ষা প্রদানকারী",
      meaningEn: "The Protecting Friend",
      fazilatBn:
          "'আল-ওয়ালি' নামটি বিপদকালীন বা নিরাপত্তা চাওয়ার সময় পাঠ করলে আল্লাহ সুরক্ষা ও সহায়তা প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১১০০)",
    ),

    AllahName(
      arabic: "ٱلْمُتَعَالِي",
      bangla: "আল-মুতায়ালী",
      english: "Al-Muta’ali",
      meaningBn: "উচ্চতম, মহান",
      meaningEn: "The Supreme, The Exalted",
      fazilatBn:
          "'আল-মুতায়ালী' নামটি সম্মান বা আধ্যাত্মিক উন্নতি চাওয়ার সময় পাঠ করলে আল্লাহ মর্যাদা, গৌরব ও আধ্যাত্মিক শক্তি প্রদান করবেন। (রেফারেন্স: সহীহ বুখারী, হাদিস নং ১১০৫)",
    ),

    AllahName(
      arabic: "ٱلْبَرُّ",
      bangla: "আল-বার্র",
      english: "Al-Barr",
      meaningBn: "ভালো কাজ ও উপকারী",
      meaningEn: "The Source of All Goodness",
      fazilatBn:
          "'আল-বার্র' নামটি দয়া, সাহায্য ও ন্যায়পরায়ণতা বৃদ্ধি করতে পাঠ করলে আল্লাহ ব্যক্তি ও সমাজের জন্য কল্যাণ প্রদান করবেন। (রেফারেন্স: সহীহ মুসলিম, হাদিস নং ১১০৭)",
    ),
    AllahName(
      arabic: "ٱلْمُنتَقِمُ",
      bangla: "আল-মুনতাকিম",
      english: "Al-Muntaqim",
      meaningBn: "প্রতিশোধ গ্রহণকারী",
      meaningEn: "The Avenger",
      fazilatBn:
          "যে ব্যক্তি শত্রুর জুলুম থেকে মুক্তির জন্য রাতে 100 বার 'আল-মুনতাকিম' নাম পড়বে, আল্লাহ তাকে শত্রুর হাত থেকে রক্ষা করবেন। তবে এ নাম শুধুমাত্র ন্যায়ের জন্য আমল করা উচিত, অন্যায় উদ্দেশ্যে নয়। (রেফারেন্স: তাফসির ইবনে কাসীর, সুরা ইবরাহিম 47)",
    ),

    AllahName(
      arabic: "ٱلعَفُوُ",
      bangla: "আল-আফুউ",
      english: "Al-Afuw",
      meaningBn: "ক্ষমাশীল",
      meaningEn: "The Pardoner",
      fazilatBn:
          "যে ব্যক্তি শবে কদরে বারবার 'আল-আফুউ' নাম পড়বে, আল্লাহ তার সব গুনাহ মাফ করবেন। বিশেষ দোয়া: 'আল্লাহুম্মা ইন্নাকা আফুউওন তুহিব্বুল আফওয়া ফাআফু আন্নি'। (রেফারেন্স: সুনান তিরমিজি, হাদিস 3513)",
    ),

    AllahName(
      arabic: "ٱلرَّؤُفُ",
      bangla: "আর-রউফ",
      english: "Ar-Ra’uf",
      meaningBn: "অতি দয়ালু",
      meaningEn: "The Most Kind",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 10 বার 'আর-রউফ' নাম পড়বে, আল্লাহ তার অন্তরে মমতা দান করবেন এবং মানুষের কাছে প্রিয় করে তুলবেন। (রেফারেন্স: সুরা তওবা 117, তাফসির ইবনে কাসীর)",
    ),

    AllahName(
      arabic: "مَالِكُ ٱلْمُلْكِ",
      bangla: "মালিকুল-মুলক",
      english: "Malikul-Mulk",
      meaningBn: "সার্বভৌম শাসক",
      meaningEn: "The Owner of Sovereignty",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 212 বার 'মালিকুল-মুলক' নাম পড়বে, আল্লাহ তার রিজিক বৃদ্ধি করবেন এবং দুনিয়ার চিন্তা থেকে মুক্ত রাখবেন। (রেফারেন্স: সুরা আলে ইমরান 26, সহীহ বুখারি 7386)",
    ),

    AllahName(
      arabic: "ذُو ٱلْجَلَالِ وَٱلْإِكْرَامِ",
      bangla: "যুল-জালালি ওয়াল-ইকরাম",
      english: "Dhul-Jalali Wal-Ikram",
      meaningBn: "মহিমা ও সম্মানের অধিকারী",
      meaningEn: "The Lord of Glory and Honor",
      fazilatBn:
          "যে ব্যক্তি বারবার 'যুল-জালালি ওয়াল-ইকরাম' নাম পাঠ করবে, আল্লাহ তার দোয়া দ্রুত কবুল করবেন। এটি রাসূল ﷺ এর সবচেয়ে বেশি পড়া দোয়ার মধ্যে একটি। (রেফারেন্স: সুনান তিরমিজি, হাদিস 3524)",
    ),

    AllahName(
      arabic: "ٱلْمُقْسِطُ",
      bangla: "আল-মুকসিত",
      english: "Al-Muqsit",
      meaningBn: "ন্যায়পরায়ণ",
      meaningEn: "The Just",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 209 বার 'আল-মুকসিত' নাম পড়বে, আল্লাহ তাকে ন্যায়পরায়ণ বানাবেন এবং অন্যায়ের শিকার হলে ন্যায় প্রতিষ্ঠা করবেন। (রেফারেন্স: সুরা আলে ইমরান 18, তাফসির কুরতুবি)",
    ),

    AllahName(
      arabic: "ٱلْجَامِعُ",
      bangla: "আল-জামি",
      english: "Al-Jami",
      meaningBn: "একত্রকারী",
      meaningEn: "The Gatherer",
      fazilatBn:
          "যে ব্যক্তি শুক্রবার ফজরের নামাজের পর 10 বার 'আল-জামি' নাম পড়বে, হারানো জিনিস ফিরে পাবে এবং পরিবারে ঐক্য আসবে। (রেফারেন্স: সুরা আলে ইমরান 9, তাফসির ইবনে কাসীর)",
    ),

    AllahName(
      arabic: "ٱلْغَنِيُ",
      bangla: "আল-গনি",
      english: "Al-Ghaniyy",
      meaningBn: "অভাবমুক্ত",
      meaningEn: "The Self-Sufficient",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 1000 বার 'আল-গনি' নাম পড়বে, আল্লাহ তাকে দারিদ্র্য থেকে মুক্ত করবেন এবং অভাব পূর্ণ করবেন। (রেফারেন্স: সুরা ফাতির 15, সহীহ মুসলিম 2757)",
    ),

    AllahName(
      arabic: "ٱلْمُغْنِي",
      bangla: "আল-মুগনি",
      english: "Al-Mughni",
      meaningBn: "অভাব দূরকারী",
      meaningEn: "The Enricher",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 1111 বার 'আল-মুগনি' নাম পড়বে, আল্লাহ তাকে স্বয়ংসম্পূর্ণ করবেন এবং হালাল রিজিক দান করবেন। (রেফারেন্স: ইমাম গাজ্জালী, আস্মাউল হুসনা ব্যাখ্যা)",
    ),

    AllahName(
      arabic: "ٱلْمَانِعُ",
      bangla: "আল-মানি",
      english: "Al-Mani",
      meaningBn: "প্রতিবন্ধক",
      meaningEn: "The Preventer",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 161 বার 'আল-মানি' নাম পড়বে, আল্লাহ তাকে বিপদ-আপদ, জাদু ও শত্রুর হাত থেকে রক্ষা করবেন। (রেফারেন্স: সুরা মায়েদা 67, তাফসির কুরতুবি)",
    ),
    AllahName(
      arabic: "ٱلضَّارُ",
      bangla: "আদ-দার",
      english: "Ad-Darr",
      meaningBn: "ক্ষতি সাধনকারী",
      meaningEn: "The Distresser",
      fazilatBn:
          "যে ব্যক্তি রাতে 100 বার 'আদ-দার' নাম পড়বে, আল্লাহ তাকে শত্রুর ষড়যন্ত্র থেকে রক্ষা করবেন। এ নাম কষ্ট থেকে হিফাজতের জন্য আমল করা হয়। (রেফারেন্স: ইমাম গাজ্জালী, আস্মাউল হুসনা ব্যাখ্যা)",
    ),

    AllahName(
      arabic: "ٱلنَّافِعُ",
      bangla: "আন-নাফি",
      english: "An-Nafi",
      meaningBn: "কল্যাণদাতা",
      meaningEn: "The Benefiter",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 41 বার 'আন-নাফি' নাম পড়বে, আল্লাহ তার অন্তরে ও জীবনে কল্যাণ দান করবেন। অসুস্থ ব্যক্তির উপর পড়ে ফুঁ দিলে উপকার পাওয়া যায়। (রেফারেন্স: সুরা ইউনুস 107, তাফসির ইবনে কাসীর)",
    ),

    AllahName(
      arabic: "ٱلنُّورُ",
      bangla: "আন-নূর",
      english: "An-Nur",
      meaningBn: "আলো",
      meaningEn: "The Light",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 256 বার 'আন-নূর' নাম পড়বে, তার অন্তর ঈমানের আলোয় আলোকিত হবে এবং অন্ধকারে পথ হারাবে না। (রেফারেন্স: সুরা নূর 35, সহীহ মুসলিম 178)",
    ),

    AllahName(
      arabic: "ٱلْهَادِي",
      bangla: "আল-হাদি",
      english: "Al-Hadi",
      meaningBn: "পথপ্রদর্শক",
      meaningEn: "The Guide",
      fazilatBn:
          "যে ব্যক্তি বারবার 'আল-হাদি' নাম পড়বে, আল্লাহ তার অন্তরকে সঠিক পথে পরিচালিত করবেন। ভ্রমণে বা জীবনের সিদ্ধান্ত নেওয়ার সময় 50 বার পড়া বিশেষ উপকারী। (রেফারেন্স: সুরা কাহফ 17, তাফসির কুরতুবি)",
    ),

    AllahName(
      arabic: "ٱلْبَدِيعُ",
      bangla: "আল-বাদি",
      english: "Al-Badi’",
      meaningBn: "অদ্বিতীয় স্রষ্টা",
      meaningEn: "The Incomparable Originator",
      fazilatBn:
          "যে ব্যক্তি বিপদে পড়ে 70 বার 'আল-বাদি' নাম পড়বে, আল্লাহ নতুন সমাধান দান করবেন। কোনো কাজ শুরু করার আগে পড়লে বরকত হবে। (রেফারেন্স: সুরা বাকারা 117, তাফসির ইবনে কাসীর)",
    ),

    AllahName(
      arabic: "ٱلْبَاقِي",
      bangla: "আল-বাকি",
      english: "Al-Baqi",
      meaningBn: "চিরস্থায়ী",
      meaningEn: "The Everlasting",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 100 বার 'আল-বাকি' নাম পড়বে, আল্লাহ তার অন্তরকে দুনিয়ার মোহ থেকে মুক্ত করবেন এবং আখিরাতের প্রতি মনোযোগী করবেন। (রেফারেন্স: সুরা রহমান 26-27, সহীহ বুখারি 4877)",
    ),

    AllahName(
      arabic: "ٱلْوَارِثُ",
      bangla: "আল-ওয়ারিস",
      english: "Al-Warith",
      meaningBn: "উত্তরাধিকারী",
      meaningEn: "The Inheritor",
      fazilatBn:
          "যে ব্যক্তি প্রতিদিন 100 বার 'আল-ওয়ারিস' নাম পড়বে, আল্লাহ তার পরবর্তী প্রজন্মকে হেফাজত করবেন এবং রিজিকের বরকত দান করবেন। (রেফারেন্স: সুরা হিজর 23, তাফসির ইবনে কাসীর)",
    ),

    AllahName(
      arabic: "ٱلرَّشِيدُ",
      bangla: "আর-রশিদ",
      english: "Ar-Rashid",
      meaningBn: "সঠিক পথপ্রদর্শক",
      meaningEn: "The Righteous Teacher",
      fazilatBn:
          "যে ব্যক্তি 1000 বার 'আর-রশিদ' নাম পড়বে, আল্লাহ তাকে সঠিক সিদ্ধান্ত নিতে সাহায্য করবেন এবং জীবনে বিভ্রান্তি দূর করবেন। (রেফারেন্স: ইমাম গাজ্জালী, আস্মাউল হুসনা ব্যাখ্যা)",
    ),

    AllahName(
      arabic: "ٱلصَّبُورُ",
      bangla: "আস-সবুর",
      english: "As-Sabur",
      meaningBn: "অতি ধৈর্যশীল",
      meaningEn: "The Patient",
      fazilatBn:
          "যে ব্যক্তি বিপদের সময়ে বারবার 'আস-সবুর' নাম পড়বে, আল্লাহ তাকে ধৈর্য দান করবেন এবং কঠিন পরিস্থিতি সহজ করে দেবেন। প্রতিদিন 100 বার পড়া বিশেষ উপকারী। (রেফারেন্স: সহীহ মুসলিম, হাদিস 1053)",
    ),

    // 👉 বাকি সব নাম, অর্থ ও ফজিলত এভাবেই যোগ করবেন
  ];

  List<AllahName> filteredNames = [];
  final List<BannerAd?> _bannerAds = [];
  BannerAd? _bottomBanner;
  TextEditingController searchController = TextEditingController();
  bool _isBottomBannerAdReady = false;

  double _arabicFontSize = 28.0;
  double _textFontSize = 16.0;
  final double _minFontSize = 14.0;
  final double _maxFontSize = 36.0;
  final double _fontSizeStep = 2.0;

  @override
  void initState() {
    super.initState();
    filteredNames = List.from(allahNames);
    _loadAds();
  }

  void _loadAds() async {
    // AdMob initialize
    await AdHelper.initialize();

    // প্রতি ৬টি আল্লাহর নামের পরে adaptive ব্যানার অ্যাড তৈরি এবং লোড করা
    int adCount = (allahNames.length / 6).ceil();
    for (int i = 0; i < adCount; i++) {
      try {
        final banner = await AdHelper.createAdaptiveBannerAdWithFallback(
          context,
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              print('In-list adaptive banner ad loaded successfully');
              if (mounted) setState(() {});
            },
            onAdFailedToLoad: (ad, error) {
              print('In-list adaptive banner ad failed to load: $error');
              ad.dispose();
              _bannerAds[i] = null;
            },
          ),
        );
        banner.load();
        _bannerAds.add(banner);
      } catch (e) {
        print('Error creating in-list adaptive banner: $e');
        _bannerAds.add(null);
      }
    }

    // পেইজের নিচের স্থায়ী adaptive ব্যানার অ্যাড তৈরি
    try {
      _bottomBanner = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('Bottom adaptive banner ad loaded successfully');
            if (mounted) {
              setState(() {
                _isBottomBannerAdReady = true;
              });
            }
            // Record banner impression
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (ad, error) {
            print('Bottom adaptive banner ad failed to load: $error');
            ad.dispose();
            _isBottomBannerAdReady = false;
          },
          onAdClicked: (ad) {
            // Record ad click
            AdHelper.recordAdClick();
          },
        ),
      );
      _bottomBanner!.load();
    } catch (e) {
      print('Error creating bottom adaptive banner: $e');
      _isBottomBannerAdReady = false;
    }
  }

  @override
  void dispose() {
    for (var ad in _bannerAds) {
      ad?.dispose();
    }
    _bottomBanner?.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _increaseFontSize() {
    setState(() {
      if (_arabicFontSize < _maxFontSize && _textFontSize < _maxFontSize) {
        _arabicFontSize += _fontSizeStep;
        _textFontSize += _fontSizeStep;
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_arabicFontSize > _minFontSize && _textFontSize > _minFontSize) {
        _arabicFontSize -= _fontSizeStep;
        _textFontSize -= _fontSizeStep;
      }
    });
  }

  void _resetFontSize() {
    setState(() {
      _arabicFontSize = 28.0;
      _textFontSize = 16.0;
    });
  }

  // Adaptive banner widget with proper sizing
  Widget _buildAdaptiveBannerWidget(BannerAd banner) {
    return Container(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: banner),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.green[800];
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    int totalItems = filteredNames.length + (filteredNames.length / 6).floor();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "আল্লাহর ৯৯ নাম",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AllahNameSearchDelegate(filteredNames),
              );
            },
          ),
          // Font size control in app bar
          PopupMenuButton<String>(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'increase',
                child: ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('ফন্ট বড় করুন'),
                  onTap: _increaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'decrease',
                child: ListTile(
                  leading: const Icon(Icons.zoom_out),
                  title: const Text('ফন্ট ছোট করুন'),
                  onTap: _decreaseFontSize,
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('ডিফল্ট ফন্ট সাইজ'),
                  onTap: _resetFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: true, // We'll handle bottom padding manually for the ad
        child: Column(
          children: [
            // Main content area with safe area padding
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: totalItems,
                itemBuilder: (context, index) {
                  // প্রতি ৬ নামের পরে adaptive অ্যাড
                  if ((index + 1) % 6 == 0) {
                    int adIndex = ((index + 1) / 6).floor() - 1;
                    if (adIndex < _bannerAds.length &&
                        _bannerAds[adIndex] != null) {
                      final banner = _bannerAds[adIndex]!;
                      return Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildAdaptiveBannerWidget(banner),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  int nameIndex = index - (index / 6).floor();
                  if (nameIndex >= filteredNames.length) {
                    return const SizedBox.shrink();
                  }

                  final name = filteredNames[nameIndex];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // নামের হেডার সেকশন
                          Row(
                            children: [
                              // নাম্বার বেজ
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor!.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  "${nameIndex + 1}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.bangla,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      name.english,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // আরবি টেক্সট সেকশন
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[900]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                name.arabic,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _arabicFontSize,
                                  fontFamily: 'ScheherazadeNew',
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  height: 1.8,
                                  wordSpacing: 2.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // অর্থ সেকশন
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.green[900]!.withOpacity(0.2)
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "অর্থ: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: _textFontSize,
                                          color: isDarkMode
                                              ? Colors.green[200]
                                              : Colors.green[800],
                                        ),
                                      ),
                                      TextSpan(
                                        text: name.meaningBn,
                                        style: TextStyle(
                                          fontSize: _textFontSize,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Meaning: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: _textFontSize,
                                          color: isDarkMode
                                              ? Colors.green[200]
                                              : Colors.green[800],
                                        ),
                                      ),
                                      TextSpan(
                                        text: name.meaningEn,
                                        style: TextStyle(
                                          fontSize: _textFontSize,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ফজিলত সেকশন
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.orange[900]!.withOpacity(0.15)
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.orange[700]!
                                    : Colors.orange[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ফজিলত:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _textFontSize,
                                    color: isDarkMode
                                        ? Colors.orange[200]
                                        : Colors.orange[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  name.fazilatBn,
                                  style: TextStyle(
                                    fontSize: _textFontSize,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // নিচের adaptive ব্যানার অ্যাড - শুধুমাত্র প্রয়োজনীয় margin
            if (_isBottomBannerAdReady && _bottomBanner != null)
              Container(
                width: screenWidth,
                height: _bottomBanner!.size.height.toDouble(),
                alignment: Alignment.center,
                color: Colors.transparent,
                // শুধুমাত্র top margin দিন যদি প্রয়োজন হয়, bottom margin দেবেন না
                margin: EdgeInsets.only(top: 8),
                // Optional: সামান্য spacing
                child: _buildAdaptiveBannerWidget(_bottomBanner!),
              ),
          ],
        ),
      ),
    );
  }
}

// Search Delegate
class AllahNameSearchDelegate extends SearchDelegate {
  final List<AllahName> allNames;

  AllahNameSearchDelegate(this.allNames);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = allNames.where((name) {
      return name.arabic.contains(query) ||
          name.bangla.contains(query) ||
          name.english.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView(
      children: results
          .map(
            (name) => ListTile(
              title: Text("${name.arabic} | ${name.bangla} | ${name.english}"),
              subtitle: Text(name.meaningBn),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allNames.where((name) {
      return name.arabic.contains(query) ||
          name.bangla.contains(query) ||
          name.english.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView(
      children: suggestions
          .map(
            (name) => ListTile(
              title: Text("${name.arabic} | ${name.bangla} | ${name.english}"),
              onTap: () {
                query = name.english;
                showResults(context);
              },
            ),
          )
          .toList(),
    );
  }
}
