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
        "• চাশত - সূর্যোদয়ের ২-৩ ঘন্টা পর\n"
        "• আউয়াবীন - মাগরিবের পর\n"
        "• তাহিয়্যাতুল ওযু - ওযুর পর\n"
        "• তাহিয়্যাতুল মসজিদ - মসজিদে প্রবেশের পর";
  }

  // বিশেষ ফ্যাক্ট সম্পর্কিত তথ্য
  String getSpecialFacts() {
    return "সালাত সম্পর্কে কিছু বিশেষ তথ্য:\n\n"
        "• দিনে ৫ ওয়াক্ত নামাজ ফরজ\n"
        "• জুমার নামাজ সপ্তাহিক ফরজ\n"
        "• নামাজ ইসলামের দ্বিতীয় স্তম্ভ\n"
        "• নামাজ মুমিনের মিরাজ\n"
        "• নামাজ আল্লাহর সাথে সংযোগ স্থাপনের মাধ্যম\n"
        "• নামাজ গুনাহ মাফের কারণ\n"
        "• নামাজ ধৈর্য্য ও শৃঙ্খলা শেখায়";
  }
}
