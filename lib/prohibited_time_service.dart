// prohibited_time_service.dart
import 'package:flutter/material.dart'; // Color এবং TimeOfDay এর জন্য
import 'package:intl/intl.dart';

class ProhibitedTimeService {
  // সূর্যোদয় নিষিদ্ধ সময় ক্যালকুলেশন
  String calculateSunriseProhibitedTime(Map<String, String> prayerTimes) {
    if (prayerTimes.containsKey("সূর্যোদয়")) {
      final sunriseTime = prayerTimes["সূর্যোদয়"]!;
      final parts = sunriseTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final startTime = TimeOfDay(hour: hour, minute: minute);

      // শেষ সময় গণনা করুন (সূর্যোদয়ের 15 মিনিট পর)
      int endMinute = minute + 15;
      int endHour = hour;
      if (endMinute >= 60) {
        endHour += 1;
        endMinute -= 60;
      }
      final endTime = TimeOfDay(hour: endHour, minute: endMinute);

      return "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
    }
    return "--:-- - --:--";
  }

  // যোহর নিষিদ্ধ সময় ক্যালকুলেশন
  String calculateDhuhrProhibitedTime(Map<String, String> prayerTimes) {
    if (prayerTimes.containsKey("যোহর")) {
      final dhuhrTime = prayerTimes["যোহর"]!;
      final parts = dhuhrTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // শুরু সময় গণনা করুন (যোহরের 6 মিনিট আগে)
      int startMinute = minute - 6;
      int startHour = hour;
      if (startMinute < 0) {
        startHour -= 1;
        startMinute += 60;
      }
      final startTime = TimeOfDay(hour: startHour, minute: startMinute);

      final endTime = TimeOfDay(hour: hour, minute: minute);

      return "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
    }
    return "--:-- - --:--";
  }

  // সূর্যাস্ত নিষিদ্ধ সময় ক্যালকুলেশন
  String calculateSunsetProhibitedTime(Map<String, String> prayerTimes) {
    if (prayerTimes.containsKey("সূর্যাস্ত")) {
      final sunsetTime = prayerTimes["সূর্যাস্ত"]!;
      final parts = sunsetTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // শুরু সময় গণনা করুন (সূর্যাস্তের 15 মিনিট আগে)
      int startMinute = minute - 15;
      int startHour = hour;
      if (startMinute < 0) {
        startHour -= 1;
        startMinute += 60;
      }
      final startTime = TimeOfDay(hour: startHour, minute: startMinute);

      final endTime = TimeOfDay(hour: hour, minute: minute);

      return "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}";
    }
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

  // নিষিদ্ধ সময় সম্পর্কিত তথ্য
  String getProhibitedTimeInfo() {
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

  // নফল সালাত সম্পর্কিত তথ্য
  String getNafalPrayerInfo() {
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
        "১️⃣ রাসূলুল্লাহ ﷺ বলেছেন: ‘বান্দা আমার নিকটবর্তী হয় নফল আমলের মাধ্যমে, যতক্ষণ না আমি তাকে ভালোবাসি।’\n"
        "(সহিহ বুখারি, হাদিস: ৬৫০২)\n\n"
        "২️⃣ আবু হুরাইরা (রা.) থেকে বর্ণিত: রাসূলুল্লাহ ﷺ বলেছেন—\n"
        "‘যে ব্যক্তি ফজরের নামাজ জামাতে পড়ে, তারপর সূর্যোদয় পর্যন্ত আল্লাহর যিকিরে ব্যস্ত থাকে এবং সূর্যোদয়ের পর দুই রাকাত (ইশরাক) নামাজ আদায় করে, তার জন্য এক হজ্জ ও এক উমরার পূর্ণ সওয়াব লেখা হয়।’\n"
        "(সুনান তিরমিজি, হাদিস: ৫৮৬; সহিহ হিসেবে বর্ণিত)";
  }

  // বিশেষ ফ্যাক্ট সম্পর্কিত তথ্য
  String getSpecialFacts() {
    return "সালাত সম্পর্কে কিছু বিশেষ তথ্য:\n\n"
        "• দিনে ৫ ওয়াক্ত নামাজ ফরজ, এটা প্রত্যেক মুসলিম পুরুষ ও নারীর জন্য অপরিহার্য\n"
        "• জুমার নামাজ মুসলিম পুরুষদের জন্য সাপ্তাহিক ফরজ ইবাদত\n"
        "• সালাত ইসলামের দ্বিতীয় স্তম্ভ এবং ঈমানের পর সবচেয়ে গুরুত্বপূর্ণ আমল\n"
        "• রাসূলুল্লাহ ﷺ বলেছেন: “নামাজ মুমিনের মিরাজ” — অর্থাৎ আল্লাহর নৈকট্যে পৌঁছানোর শ্রেষ্ঠ উপায়\n"
        "• নামাজ কিয়ামতের দিন প্রথম হিসাব নেওয়া হবে; যদি নামাজ ঠিক থাকে, বাকি আমলও ঠিক থাকবে (সুনান তিরমিজি, হাদিস: ৪১৩)\n"
        "• নামাজ দুনিয়াতে মন্দ কাজ ও অশ্লীলতা থেকে বিরত রাখে (কুরআন: সূরা আনকাবুত ২৯:৪৫)\n"
        "• নামাজ গুনাহ মাফের মাধ্যম; এক নামাজ থেকে অন্য নামাজ পর্যন্ত গুনাহ মাফ হয়\n"
        "• নামাজ ধৈর্য, শৃঙ্খলা ও আত্মিক প্রশান্তি প্রদান করে\n"
        "• নিয়মিত নামাজ আদায়কারীর মুখে আল্লাহর নূর ও হৃদয়ে প্রশান্তি দেখা যায়\n"
        "• নামাজ ছেড়ে দেওয়া বড় গোনাহ এবং আল্লাহর সাথে সম্পর্ক ছিন্ন করার সমতুল্য\n";
  }
}
