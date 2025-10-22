// prohibited_time_service.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/language_provider.dart';

class ProhibitedTimeService {
  final BuildContext context;

  ProhibitedTimeService(this.context);

  // Language Texts
  static const Map<String, Map<String, String>> _texts = {
    'sunrise': {'en': 'Sunrise', 'bn': 'সূর্যোদয়'},
    'dhuhr': {'en': 'Dhuhr', 'bn': 'যোহর'},
    'sunset': {'en': 'Sunset', 'bn': 'সূর্যাস্ত'},
  };

  // Helper method to get text based on current language
  String _text(String key) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

  // সূর্যোদয় নিষিদ্ধ সময় ক্যালকুলেশন
  String calculateSunriseProhibitedTime(Map<String, String> prayerTimes) {
    final sunriseKey = _text('sunrise');
    print('Looking for sunrise key: $sunriseKey');
    print('Available keys in prayerTimes: ${prayerTimes.keys.toList()}');

    if (prayerTimes.containsKey(sunriseKey)) {
      final sunriseTime = prayerTimes[sunriseKey]!;
      print('Found sunrise time: $sunriseTime');

      final parts = sunriseTime.split(":");
      if (parts.length != 2) return "--:-- - --:--";

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final startTime = TimeOfDay(hour: hour, minute: minute);

      // শেষ সময় গণনা করুন (সূর্যোদয়ের 15 মিনিট পর)
      int endMinute = minute + 15;
      int endHour = hour;
      if (endMinute >= 60) {
        endHour += 1;
        endMinute -= 60;
      }

      // 24-hour format adjustment
      if (endHour >= 24) {
        endHour -= 24;
      }

      final endTime = TimeOfDay(hour: endHour, minute: endMinute);

      final result =
          "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
      print('Sunrise prohibited time: $result');
      return result;
    } else {
      // Fallback: Check for English/Bangla keys
      final fallbackKey = sunriseKey == 'সূর্যোদয়' ? 'Sunrise' : 'সূর্যোদয়';
      if (prayerTimes.containsKey(fallbackKey)) {
        final sunriseTime = prayerTimes[fallbackKey]!;
        print('Found fallback sunrise time: $sunriseTime');

        final parts = sunriseTime.split(":");
        if (parts.length != 2) return "--:-- - --:--";

        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;

        final startTime = TimeOfDay(hour: hour, minute: minute);

        int endMinute = minute + 15;
        int endHour = hour;
        if (endMinute >= 60) {
          endHour += 1;
          endMinute -= 60;
        }

        if (endHour >= 24) {
          endHour -= 24;
        }

        final endTime = TimeOfDay(hour: endHour, minute: endMinute);

        final result =
            "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
        return result;
      }
    }

    print('Sunrise time not found in prayer times');
    return "--:-- - --:--";
  }

  // যোহর নিষিদ্ধ সময় ক্যালকুলেশন
  String calculateDhuhrProhibitedTime(Map<String, String> prayerTimes) {
    final dhuhrKey = _text('dhuhr');
    print('Looking for dhuhr key: $dhuhrKey');
    print('Available keys in prayerTimes: ${prayerTimes.keys.toList()}');

    if (prayerTimes.containsKey(dhuhrKey)) {
      final dhuhrTime = prayerTimes[dhuhrKey]!;
      print('Found dhuhr time: $dhuhrTime');

      final parts = dhuhrTime.split(":");
      if (parts.length != 2) return "--:-- - --:--";

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      // শুরু সময় গণনা করুন (যোহরের 6 মিনিট আগে)
      int startMinute = minute - 6;
      int startHour = hour;
      if (startMinute < 0) {
        startHour -= 1;
        startMinute += 60;
      }

      // Handle negative hours
      if (startHour < 0) {
        startHour += 24;
      }

      final startTime = TimeOfDay(hour: startHour, minute: startMinute);
      final endTime = TimeOfDay(hour: hour, minute: minute);

      final result =
          "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
      print('Dhuhr prohibited time: $result');
      return result;
    } else {
      // Fallback: Check for English/Bangla keys
      final fallbackKey = dhuhrKey == 'যোহর' ? 'Dhuhr' : 'যোহর';
      if (prayerTimes.containsKey(fallbackKey)) {
        final dhuhrTime = prayerTimes[fallbackKey]!;
        print('Found fallback dhuhr time: $dhuhrTime');

        final parts = dhuhrTime.split(":");
        if (parts.length != 2) return "--:-- - --:--";

        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;

        int startMinute = minute - 6;
        int startHour = hour;
        if (startMinute < 0) {
          startHour -= 1;
          startMinute += 60;
        }

        if (startHour < 0) {
          startHour += 24;
        }

        final startTime = TimeOfDay(hour: startHour, minute: startMinute);
        final endTime = TimeOfDay(hour: hour, minute: minute);

        final result =
            "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
        return result;
      }
    }

    print('Dhuhr time not found in prayer times');
    return "--:-- - --:--";
  }

  // সূর্যাস্ত নিষিদ্ধ সময় ক্যালকুলেশন
  String calculateSunsetProhibitedTime(Map<String, String> prayerTimes) {
    final sunsetKey = _text('sunset');
    print('Looking for sunset key: $sunsetKey');
    print('Available keys in prayerTimes: ${prayerTimes.keys.toList()}');

    if (prayerTimes.containsKey(sunsetKey)) {
      final sunsetTime = prayerTimes[sunsetKey]!;
      print('Found sunset time: $sunsetTime');

      final parts = sunsetTime.split(":");
      if (parts.length != 2) return "--:-- - --:--";

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      // শুরু সময় গণনা করুন (সূর্যাস্তের 15 মিনিট আগে)
      int startMinute = minute - 15;
      int startHour = hour;
      if (startMinute < 0) {
        startHour -= 1;
        startMinute += 60;
      }

      // Handle negative hours
      if (startHour < 0) {
        startHour += 24;
      }

      final startTime = TimeOfDay(hour: startHour, minute: startMinute);
      final endTime = TimeOfDay(hour: hour, minute: minute);

      final result =
          "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
      print('Sunset prohibited time: $result');
      return result;
    } else {
      // Fallback: Check for English/Bangla keys
      final fallbackKey = sunsetKey == 'সূর্যাস্ত' ? 'Sunset' : 'সূর্যাস্ত';
      if (prayerTimes.containsKey(fallbackKey)) {
        final sunsetTime = prayerTimes[fallbackKey]!;
        print('Found fallback sunset time: $sunsetTime');

        final parts = sunsetTime.split(":");
        if (parts.length != 2) return "--:-- - --:--";

        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;

        int startMinute = minute - 15;
        int startHour = hour;
        if (startMinute < 0) {
          startHour -= 1;
          startMinute += 60;
        }

        if (startHour < 0) {
          startHour += 24;
        }

        final startTime = TimeOfDay(hour: startHour, minute: startMinute);
        final endTime = TimeOfDay(hour: hour, minute: minute);

        final result =
            "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
        return result;
      }
    }

    print('Sunset time not found in prayer times');
    return "--:-- - --:--";
  }

  // TimeOfDay কে স্ট্রিং ফরম্যাটে কনভার্ট করা
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('h:mm').format(dateTime);
  }

  String formatTimeToBangla(String time) {
    try {
      // Check if it's a time range (contains '-')
      if (time.contains('-')) {
        List<String> parts = time.split('-');
        if (parts.length == 2) {
          // Convert both start and end times
          String startTime = _convertSingleTimeToBangla(parts[0].trim());
          String endTime = _convertSingleTimeToBangla(parts[1].trim());
          return '$startTime - $endTime'; // বাংলায়ও স্পেস যোগ
        }
      }
      // Single time
      return _convertSingleTimeToBangla(time);
    } catch (e) {
      return time;
    }
  }

  String formatTimeToEnglish(String time) {
    try {
      // Check if it's a time range (contains '-')
      if (time.contains('-')) {
        List<String> parts = time.split('-');
        if (parts.length == 2) {
          // Keep both times in English format with spaces
          String startTime = parts[0].trim();
          String endTime = parts[1].trim();
          return '$startTime - $endTime'; // ইংরেজিতে স্পেস যোগ
        }
      }
      // Single time
      return time.trim();
    } catch (e) {
      return time;
    }
  }

  String _convertSingleTimeToBangla(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final formattedTime = '${hour.toString().padLeft(2, '0')}:$minute';
        return _convertToBanglaNumbers(formattedTime);
      }
      return _convertToBanglaNumbers(time);
    } catch (e) {
      return time;
    }
  }

  String _convertToBanglaNumbers(String text) {
    const englishToBangla = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
      ':': ':',
      ' ': ' ',
      '-': '-',
    };

    String result = '';
    for (int i = 0; i < text.length; i++) {
      result += englishToBangla[text[i]] ?? text[i];
    }
    return result;
  }

  // নিষিদ্ধ সময় সম্পর্কিত তথ্য
  String getProhibitedTimeInfo() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    if (languageProvider.isEnglish) {
      return "In Islamic Shariah, there are 3 times when prayer is prohibited. The method of determining prohibited times and rulings, with exceptions for Asr and sunset, are given below:\n\n"
          "1. Sunrise time: From when the sun starts rising until it completely rises. "
          "This app shows the prohibited time at sunrise as 15 minutes.\n\n"
          "2. Exactly noon or midday time: Until 3 minutes before Dhuhr time starts. "
          "But for extra precaution, the Islamic Foundation has determined 6 minutes before Dhuhr time as prohibited time. "
          "During this time, the sun is exactly overhead.\n\n"
          "3. Sunset time: From when the sun starts setting until it completely sets. "
          "The app also shows this prohibited time as 15 minutes.\n\n"
          "However, if for some reason the Asr prayer of that day is not prayed, then only Asr prayer can be performed during the prohibited time of sunset. "
          "But delaying prayer so much is not appropriate at all.\n\n"
          "🔹 Read authentic Hadith books for detailed information about prohibited times.\n\n"
          "📌 Context: Previously, the prohibited time at sunrise and sunset was considered 23 minutes. "
          "But in light of modern scientific research, scholars have opined that this time limit is not more than 15 minutes. "
          "Therefore, this app shows prohibited time as 15 minutes instead of 23 minutes.\n\n"
          "👉 It is prohibited to pray Nafl prayers during these times.";
    } else {
      return "ইসলামি শরীয়তে ৩টি সময়ে সালাত আদায় নিষিদ্ধ। আসর ও সূর্যাস্তের ব্যতিক্রমসহ নিষিদ্ধ সময় নির্ণয়ের পদ্ধতি ও মাসআলা নিম্নে দেওয়া হলোঃ \n\n"
          "১. সূর্যোদয়ের সময়ঃ সূর্য ওঠা শুরু করার সময় থেকে সম্পূর্ণ উদয় হওয়া পর্যন্ত। "
          "এই অ্যাপে সূর্যোদয়ের নিষিদ্ধ সময় ১৫ মিনিট হিসেবে দেখানো হয়েছে।\n\n"
          "২. ঠিক দুপুর বা মধ্যাহ্নের সময়ঃ যুহরের ওয়াক্ত শুরু হওয়ার আগের ৩ মিনিট পর্যন্ত। "
          "কিন্তু বাড়তি সতর্কতার জন্য ইসলামিক ফাউন্ডেশন যুহরের ওয়াক্তের আগের ৬ মিনিট নিষিদ্ধ সময় হিসেবে নির্ধারণ করেছে। "
          "এ সময় সূর্য ঠিক মাথার ওপরে থাকে।\n\n"
          "৩. সূর্যাস্তের সময়ঃ সূর্য অস্ত যেতে শুরু করার সময় থেকে পুরোপুরি অস্তমিত হওয়া পর্যন্ত। "
          "অ্যাপে এই নিষিদ্ধ সময়ও ১৫ মিনিট হিসেবে দেখানো হয়েছে।\n\n"
          "তবে, যদি কোন কারণে ঐ দিনের আসরের সালাত পড়া না হয়, তাহলে সূর্যাস্তের নিষিদ্ধ সময়ের মধ্যেও শুধু আসরের সালাত আদায় করা যাবে। "
          "তবে সালাত এত দেরি করে পড়া একেবারেই উচিত নয়।\n\n"
          "🔹 নিষিদ্ধ সময়ের ব্যাপারে বিস্তারিত জানতে প্রামাণ্য হাদিস গ্রন্থ পড়ুন।\n\n"
          "📌 প্রসঙ্গত উল্লেখঃ পূর্বে সূর্যোদয় ও সূর্যাস্তের নিষিদ্ধ সময় ২৩ মিনিট ধরা হত। "
          "কিন্তু আধুনিক বৈজ্ঞানিক গবেষণার আলোকে আলেমগণ মত দিয়েছেন যে এই সময়সীমা ১৫ মিনিটের বেশি নয়। "
          "তাই এই অ্যাপে নিষিদ্ধ সময় ২৩ মিনিটের পরিবর্তে ১৫ মিনিট দেখানো হয়েছে।\n\n"
          "👉 এই সময়গুলোতে নফল নামাজ পড়া নিষিদ্ধ।";
    }
  }

  // নফল সালাত সম্পর্কিত তথ্য
  String getNafalPrayerInfo() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    if (languageProvider.isEnglish) {
      return "Best times for Nafl prayers:\n\n"
          "• Tahajjud - Last third of the night\n"
          "• Ishraq - 15-20 minutes after sunrise\n"
          "• Chasht (Duha) - 2-3 hours after sunrise\n"
          "• Awwabeen - 6 rak'ahs after Maghrib (2+2+2)\n"
          "• Tahiyyatul Wudu - 2 rak'ahs after ablution\n"
          "• Tahiyyatul Masjid - 2 rak'ahs after entering mosque\n"
          "• Salatut Tasbih - 4 rak'ahs once a week or at least once in lifetime\n"
          "• Salatul Hajat - 2 rak'ahs for special needs or problems\n"
          "• Salatut Taubah - 2 rak'ahs for forgiveness after sin\n"
          "• Salatul Istikhara - 2 rak'ahs before important decisions\n"
          "• Salatul Kusuf - 2 rak'ahs during solar eclipse\n"
          "• Salatul Khusuf - 2 rak'ahs during lunar eclipse\n"
          "• Salatul Istisqa - 2 rak'ahs in congregation for rain prayer\n"
          "• Any Nafl prayer with Darood Sharif - as desired\n\n"
          "Virtues of Nafl prayers from authentic Hadith:\n\n"
          "1️⃣ The Messenger of Allah ﷺ said: 'My servant draws near to Me with nothing more beloved to Me than what I have made obligatory upon him. My servant continues to draw near to Me with supererogatory works until I love him.'\n"
          "(Sahih Bukhari, Hadith: 6502)\n\n"
          "2️⃣ Abu Huraira (RA) reported: The Messenger of Allah ﷺ said—\n"
          "'Whoever prays Fajr in congregation, then remains engaged in Allah's remembrance until sunrise, and then prays two rak'ahs (Ishraq), will receive the reward of a complete Hajj and Umrah.'\n"
          "(Sunan Tirmidhi, Hadith: 586; narrated as authentic)";
    } else {
      return "নফল নামাজ পড়ার উত্তম সময়:\n\n"
          "• তাহাজ্জুদ - রাতের শেষ তৃতীয়াংশ\n"
          "• ইশরাক - সূর্যোদয়ের ১৫-২০ মিনিট পর\n"
          "• চাশত (দুহা) - সূর্যোদয়ের ২-৩ ঘন্টা পর\n"
          "• আউয়াবীন - মাগরিবের পর ৬ রাকাত (২+২+২)\n"
          "• তাহিয়্যাতুল ওযু - ওযুর পর ২ রাকাত\n"
          "• তাহিয়্যাতুল মসজিদ - মসজিদে প্রবেশের পর ২ রাকাত\n"
          "• সালাতুত তাসবিহ - সপ্তাহে একবার বা জীবনে অন্তত একবার ৪ রাকাত\n"
          "• সালাতুত হাজত - বিশেষ প্রয়োজন বা সমস্যার সময় ২ রাকাত\n"
          "• সালাতুত তওবা - গোনাহের পর ক্ষমা প্রার্থনার জন্য ২ রাকাত\n"
          "• সালাতুল ইস্তিখারা - গুরুত্বপূর্ণ সিদ্ধান্ত নেওয়ার আগে ২ রাকাত\n"
          "• সালাতুল কুসুফ - সূর্যগ্রহণের সময় ২ রাকাত\n"
          "• সালাতুল খুসুফ - চন্দ্রগ্রহণের সময় ২ রাকাত\n"
          "• সালাতুল ইস্তিসকা - বৃষ্টি প্রার্থনার জন্য জামাতে ২ রাকাত\n"
          "• দুরুদ শরীফসহ যেকোনো নফল নামাজ - ইচ্ছা অনুযায়ী\n\n"
          "সহিহ হাদিস থেকে নফল নামাজের ফজিলত:\n\n"
          "১️⃣ রাসূলুল্লাহ ﷺ বলেছেন: 'বান্দা আমার নিকটবর্তী হয় নফল আমলের মাধ্যমে, যতক্ষণ না আমি তাকে ভালোবাসি।'\n"
          "(সহিহ বুখারি, হাদিস: ৬৫০২)\n\n"
          "২️⃣ আবু হুরাইরা (রা.) থেকে বর্ণিত: রাসূলুল্লাহ ﷺ বলেছেন—\n"
          "'যে ব্যক্তি ফজরের নামাজ জামাতে পড়ে, তারপর সূর্যোদয় পর্যন্ত আল্লাহর যিকিরে ব্যস্ত থাকে এবং সূর্যোদয়ের পর দুই রাকাত (ইশরাক) নামাজ আদায় করে, তার জন্য এক হজ্জ ও এক উমরার পূর্ণ সওয়াব লেখা হয়।'\n"
          "(সুনান তিরমিজি, হাদিস: ৫৮৬; সহিহ হিসেবে বর্ণিত)";
    }
  }

  // বিশেষ ফ্যাক্ট সম্পর্কিত তথ্য
  String getSpecialFacts() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    if (languageProvider.isEnglish) {
      return "Some special facts about Salah:\n\n"
          "• 5 daily prayers are obligatory, it is essential for every Muslim man and woman\n"
          "• Friday prayer is a weekly obligatory worship for Muslim men\n"
          "• Salah is the second pillar of Islam and the most important deed after faith\n"
          "• The Messenger of Allah ﷺ said: 'Prayer is the Mi'raj of the believer' - meaning the best way to reach closeness to Allah\n"
          "• Prayer will be the first account taken on the Day of Judgment; if prayer is correct, other deeds will also be correct (Sunan Tirmidhi, Hadith: 413)\n"
          "• Prayer prevents from evil deeds and obscenity in this world (Quran: Surah Ankabut 29:45)\n"
          "• Prayer is a means of forgiveness of sins; sins are forgiven from one prayer to another\n"
          "• Prayer provides patience, discipline and spiritual peace\n"
          "• Regular prayers show Allah's light on the face and peace in the heart\n"
          "• Abandoning prayer is a major sin and equivalent to severing relationship with Allah";
    } else {
      return "সালাত সম্পর্কে কিছু বিশেষ তথ্য:\n\n"
          "• দিনে ৫ ওয়াক্ত নামাজ ফরজ, এটা প্রত্যেক মুসলিম পুরুষ ও নারীর জন্য অপরিহার্য\n"
          "• জুমার নামাজ মুসলিম পুরুষদের জন্য সাপ্তাহিক ফরজ ইবাদত\n"
          "• সালাত ইসলামের দ্বিতীয় স্তম্ভ এবং ঈমানের পর সবচেয়ে গুরুত্বপূর্ণ আমল\n"
          "• রাসূলুল্লাহ ﷺ বলেছেন: 'নামাজ মুমিনের মিরাজ' — অর্থাৎ আল্লাহর নৈকট্যে পৌঁছানোর শ্রেষ্ঠ উপায়\n"
          "• নামাজ কিয়ামতের দিন প্রথম হিসাব নেওয়া হবে; যদি নামাজ ঠিক থাকে, বাকি আমলও ঠিক থাকবে (সুনান তিরমিজি, হাদিস: ৪১৩)\n"
          "• নামাজ দুনিয়াতে মন্দ কাজ ও অশ্লীলতা থেকে বিরত রাখে (কুরআন: সূরা আনকাবুত ২৯:৪৫)\n"
          "• নামাজ গুনাহ মাফের মাধ্যম; এক নামাজ থেকে অন্য নামাজ পর্যন্ত গুনাহ মাফ হয়\n"
          "• নামাজ ধৈর্য, শৃঙ্খলা ও আত্মিক প্রশান্তি প্রদান করে\n"
          "• নিয়মিত নামাজ আদায়কারীর মুখে আল্লাহর নূর ও হৃদয়ে প্রশান্তি দেখা যায়\n"
          "• নামাজ ছেড়ে দেওয়া বড় গোনাহ এবং আল্লাহর সাথে সম্পর্ক ছিন্ন করার সমতুল্য\n";
    }
  }
}
