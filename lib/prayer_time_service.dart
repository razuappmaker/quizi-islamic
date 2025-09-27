// prayer_time_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PrayerTimeService {
  // ইন্টারনেট কানেকশন চেক
  Future<bool> checkInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Internet connection error: $e');
      return false;
    }
  }

  // নামাজের সময় ফেচ করা (ম্যানুয়াল লোকেশন সাপোর্ট সহ)
  Future<Map<String, dynamic>?> fetchPrayerTimes({
    bool useManualLocation = false,
    double? manualLatitude,
    double? manualLongitude,
    String? manualCityName,
    String? manualCountryName,
  }) async {
    try {
      double latitude;
      double longitude;
      String cityName;
      String countryName;

      if (useManualLocation &&
          manualLatitude != null &&
          manualLongitude != null) {
        // ম্যানুয়াল লোকেশন ব্যবহার
        latitude = manualLatitude;
        longitude = manualLongitude;
        cityName = manualCityName ?? "মানুয়াল লোকেশন";
        countryName = manualCountryName ?? "";

        print('Using manual location: $latitude, $longitude');
        print('Manual city: $cityName, country: $countryName');
      } else {
        // অটোমেটিক লোকেশন
        // প্রথমে লোকেশন সার্ভিস চেক
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          print('Location services are disabled');
          return null;
        }

        // লোকেশন পারমিশন চেক
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            print('Location permissions are denied');
            return null;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          print('Location permissions are permanently denied');
          return null;
        }

        print('Fetching current position...');
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        ).timeout(Duration(seconds: 15));

        latitude = position.latitude;
        longitude = position.longitude;
        print('Auto location: $latitude, $longitude');

        // লোকেশন তথ্য উন্নতভাবে পাওয়া
        Map<String, String> locationInfo = await _getImprovedLocationInfo(
          latitude,
          longitude,
        );
        cityName = locationInfo['city']!;
        countryName = locationInfo['country']!;
      }

      final today = DateTime.now();
      final formattedDate =
          "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";

      // API URL তৈরি
      final url =
          "https://api.aladhan.com/v1/timings/$formattedDate?latitude=$latitude&longitude=$longitude&method=2";

      print('Fetching prayer times from: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API response received successfully');

        // ডিবাগিং: পুরো API রেসপন্স প্রিন্ট করুন
        print('=== API RESPONSE DEBUG ===');
        print('Timings: ${data["data"]["timings"]}');
        print('Timezone: ${data["data"]["meta"]["timezone"]}');
        print('Date: ${data["data"]["date"]["readable"]}');
        print('========================');

        final timings = data["data"]["timings"];

        // টাইমিংস ভ্যালিডেশন
        if (timings == null) {
          print('No timings found in API response');
          return null;
        }

        // সময় কনভার্সন
        final prayerTimes = _convertPrayerTimes(timings);

        print('Prayer times fetched successfully');
        print('City: $cityName, Country: $countryName');

        // প্রতিটি নামাজের সময় প্রিন্ট করুন
        prayerTimes.forEach((key, value) {
          print('$key: $value');
        });

        return {
          'cityName': cityName,
          'countryName': countryName,
          'prayerTimes': prayerTimes,
          'latitude': latitude,
          'longitude': longitude,
          'timezone': data["data"]["meta"]["timezone"] ?? "Local",
        };
      } else {
        print('API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print("Prayer time fetch error: $e");
      return null;
    }
  }

  // অ্যাডজাস্ট করা নামাজের সময় গণনা করা
  Map<String, String> getAdjustedPrayerTimes(
    Map<String, String> originalTimes,
    Map<String, int> adjustments,
  ) {
    if (originalTimes.isEmpty) return {};

    final adjustedTimes = Map<String, String>.from(originalTimes);

    for (final entry in adjustments.entries) {
      final prayerName = entry.key;
      final adjustment = entry.value;

      if (adjustedTimes.containsKey(prayerName) && adjustment != 0) {
        final originalTime = adjustedTimes[prayerName]!;
        final adjustedTime = _adjustPrayerTime(originalTime, adjustment);
        adjustedTimes[prayerName] = adjustedTime;
        print(
          'Adjusted $prayerName: $originalTime -> $adjustedTime ($adjustment minutes)',
        );
      }
    }

    return adjustedTimes;
  }

  // নামাজের সময় অ্যাডজাস্ট করা
  String _adjustPrayerTime(String time, int adjustmentMinutes) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      // মিনিট অ্যাডজাস্ট করা
      minutes += adjustmentMinutes;

      // ঘণ্টা সামঞ্জস্য করা
      while (minutes >= 60) {
        minutes -= 60;
        hours = (hours + 1) % 24;
      }

      while (minutes < 0) {
        minutes += 60;
        hours = (hours - 1) % 24;
        if (hours < 0) hours += 24;
      }

      final adjustedTime =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      print(
        'Time adjustment: $time + $adjustmentMinutes minutes = $adjustedTime',
      );

      return adjustedTime;
    } catch (e) {
      print('Error adjusting prayer time: $e');
      return time;
    }
  }

  // উন্নত লোকেশন তথ্য পাওয়া
  Future<Map<String, String>> _getImprovedLocationInfo(
    double lat,
    double lng,
  ) async {
    String city = "বর্তমান অবস্থান";
    String country = "অজানা দেশ";

    try {
      final placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(Duration(seconds: 8));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // শহরের নাম প্রায়োরিটি অনুযায়ী নিন
        city =
            place.locality ??
            place.subLocality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            "বর্তমান অবস্থান";

        country = place.country ?? "অজানা দেশ";

        // খুব দীর্ঘ নাম সংক্ষিপ্ত করুন
        if (city.length > 20) {
          city = city.substring(0, 20) + '...';
        }

        // ইংরেজি নাম বাংলায় কনভার্ট করার চেষ্টা করুন
        city = await _translateToBengali(city);
        country = await _translateToBengali(country);

        print('Improved location: $city, $country');
      }
    } catch (e) {
      print('Error getting improved location: $e');
      // ফallback হিসেবে জিওকোডিং API ব্যবহার করুন
      try {
        final response = await http
            .get(
              Uri.parse(
                'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10',
              ),
            )
            .timeout(Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final address = data['address'];
          if (address != null) {
            city =
                address['city'] ??
                address['town'] ??
                address['village'] ??
                "বর্তমান অবস্থান";
            country = address['country'] ?? "অজানা দেশ";

            // বাংলা অনুবাদ
            city = await _translateToBengali(city);
            country = await _translateToBengali(country);
          }
        }
      } catch (e2) {
        print('Fallback geocoding also failed: $e2');
      }
    }

    return {'city': city, 'country': country};
  }

  // নামাজের সময় কনভার্সন (সরলীকৃত)
  Map<String, String> _convertPrayerTimes(Map<String, dynamic> timings) {
    Map<String, String> convertedTimes = {};

    final prayerKeys = {
      "Fajr": "ফজর",
      "Dhuhr": "যোহর",
      "Asr": "আসর",
      "Maghrib": "মাগরিব",
      "Isha": "ইশা",
      "Sunrise": "সূর্যোদয়",
      "Sunset": "সূর্যাস্ত",
    };

    for (var entry in prayerKeys.entries) {
      String apiKey = entry.key;
      String banglaKey = entry.value;

      if (timings.containsKey(apiKey) && timings[apiKey] != null) {
        String originalTime = timings[apiKey].toString();

        // সময়টি ক্লিনআপ করুন (GMT বা অন্যান্য টেক্সট রিমুভ)
        String cleanTime = _cleanTimeString(originalTime);
        convertedTimes[banglaKey] = cleanTime;

        print('$apiKey: $originalTime -> $cleanTime');
      } else {
        print('Warning: $apiKey not found in API response');
        convertedTimes[banglaKey] = "00:00"; // ডিফল্ট ভ্যালু
      }
    }

    return convertedTimes;
  }

  String _cleanTimeString(String time) {
    try {
      // "05:30 (GMT)" -> "05:30"
      // "05:30" -> "05:30"
      String cleanTime = time.split(' ')[0];

      // ভ্যালিডেশন: সময় ফরম্যাট চেক করুন
      List<String> parts = cleanTime.split(':');
      if (parts.length != 2) return "00:00";

      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;

      // ভ্যালিড ঘন্টা এবং মিনিট চেক করুন
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        print('Invalid time format: $time');
        return "00:00";
      }

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error cleaning time string: $time - $e');
      return "00:00";
    }
  }

  // পরবর্তী নামাজ খুঁজে বের করা (অ্যাডজাস্টেড টাইমস সহ)
  Map<String, dynamic>? findNextPrayer(Map<String, String> prayerTimes) {
    try {
      final now = DateTime.now();
      // বর্তমান সময় (শুধু ঘন্টা এবং মিনিট)
      DateTime currentTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );

      print('Current time: $currentTime');

      DateTime? nextPrayerTime;
      String? nextName;

      // শুধুমাত্র প্রধান ৫ ওয়াক্ত নামাজ বিবেচনা করুন
      final mainPrayers = ["ফজর", "যোহর", "আসর", "মাগরিব", "ইশা"];

      for (String name in mainPrayers) {
        if (prayerTimes.containsKey(name)) {
          final time = prayerTimes[name]!;
          final prayerDate = parsePrayerTime(time);

          if (prayerDate != null) {
            print('$name: $prayerDate');

            if (prayerDate.isAfter(currentTime)) {
              if (nextPrayerTime == null ||
                  prayerDate.isBefore(nextPrayerTime)) {
                nextPrayerTime = prayerDate;
                nextName = name;
              }
            }
          } else {
            print('Failed to parse time for $name: $time');
          }
        } else {
          print('Prayer time not found for: $name');
        }
      }

      // যদি আজকের সব নামাজ শেষ হয়ে যায়, তাহলে আগামীকালের ফজর বিবেচনা করুন
      if (nextPrayerTime == null && prayerTimes.containsKey("ফজর")) {
        final fajrTime = prayerTimes["ফজর"]!;
        DateTime? tomorrowFajr = parsePrayerTime(fajrTime);
        if (tomorrowFajr != null) {
          tomorrowFajr = tomorrowFajr.add(Duration(days: 1));
          nextPrayerTime = tomorrowFajr;
          nextName = "ফজর";
          print('Using next day Fajr: $tomorrowFajr');
        }
      }

      if (nextPrayerTime != null && nextName != null) {
        final countdown = nextPrayerTime.difference(currentTime);
        print('Next prayer: $nextName at $nextPrayerTime (in $countdown)');

        return {
          'nextPrayer': nextName,
          'countdown': countdown,
          'nextPrayerTime': nextPrayerTime,
        };
      } else {
        print('No next prayer found');
      }
    } catch (e) {
      print('Error finding next prayer: $e');
    }

    return {'nextPrayer': "লোড হচ্ছে...", 'countdown': Duration.zero};
  }

  // সময় পার্স করা
  DateTime? parsePrayerTime(String time) {
    try {
      // ভ্যালিডেশন
      if (time.isEmpty || time == "00:00") {
        print('Invalid time string: $time');
        return null;
      }

      final parts = time.split(":");
      if (parts.length != 2) {
        print('Invalid time format: $time');
        return null;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        print('Invalid hour or minute in time: $time');
        return null;
      }

      final now = DateTime.now();
      var prayerDate = DateTime(now.year, now.month, now.day, hour, minute);

      // বর্তমান সময়ের সাথে তুলনা করুন
      DateTime currentTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );

      // যদি সময় ইতিমধ্যেই পাস হয়ে যায়, তাহলে আগামীকালের জন্য
      if (prayerDate.isBefore(currentTime)) {
        prayerDate = prayerDate.add(Duration(days: 1));
        print('Time passed, using next day: $prayerDate');
      }

      return prayerDate;
    } catch (e) {
      print("Error parsing prayer time: $time - $e");
      return null;
    }
  }

  // সময় ফরম্যাট করা (24h to 12h)
  String formatTimeTo12Hour(String time24) {
    try {
      final prayerDate = parsePrayerTime(time24);
      if (prayerDate == null) return time24;

      // AM/PM ফরম্যাট ব্যবহার করুন (বাংলা অনুবাদ ছাড়া)
      String formattedTime = DateFormat('hh:mm a').format(prayerDate);

      return formattedTime;
    } catch (e) {
      print('Error formatting time: $time24 - $e');
      return time24;
    }
  }

  // ইংরেজি থেকে বাংলা অনুবাদ
  Future<String> _translateToBengali(String englishText) async {
    // একটি সাধারণ ম্যাপিং টেবিল
    Map<String, String> translationMap = {
      'Kuwait': 'কুয়েত',
      'Kuwait City': 'কুয়েত সিটি',
      'Dhaka': 'ঢাকা',
      'Chittagong': 'চট্টগ্রাম',
      'Riyadh': 'রিয়াদ',
      'Dubai': 'দুবাই',
      'Doha': 'দোহা',
      'Saudi Arabia': 'সৌদি আরব',
      'Bangladesh': 'বাংলাদেশ',
      'India': 'ভারত',
      'Pakistan': 'পাকিস্তান',
      'United Arab Emirates': 'সংযুক্ত আরব আমিরাত',
      'Qatar': 'কাতার',
      'Oman': 'ওমান',
      'Bahrain': 'বাহরাইন',
      'United States': 'যুক্তরাষ্ট্র',
      'USA': 'যুক্তরাষ্ট্র',
      'America': 'আমেরিকা',
      'California': 'ক্যালিফোর্নিয়া',
      'Mountain View': 'মাউন্টেন ভিউ',
      // আরও শহর/দেশ যোগ করুন
    };

    // পুরো টেক্সট ম্যাপিং
    if (translationMap.containsKey(englishText)) {
      return translationMap[englishText]!;
    }

    // শব্দ ভেঙ্গে ম্যাপিং করার চেষ্টা করুন
    for (var entry in translationMap.entries) {
      if (englishText.contains(entry.key)) {
        return englishText.replaceAll(entry.key, entry.value);
      }
    }

    return englishText;
  }

  // নামাজের রং পাওয়া
  Color getPrayerColor(String prayerName) {
    switch (prayerName) {
      case "ফজর":
        return Colors.orange.shade700;
      case "যোহর":
        return Colors.blue.shade700;
      case "আসর":
        return Colors.green.shade700;
      case "মাগরিব":
        return Colors.purple;
      case "ইশা":
        return Colors.indigo;
      default:
        return Colors.grey.shade700;
    }
  }

  // নামাজের আইকন পাওয়া
  IconData getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case "ফজর":
        return Icons.wb_twilight;
      case "যোহর":
        return Icons.wb_sunny;
      case "আসর":
        return Icons.brightness_4;
      case "মাগরিব":
        return Icons.nights_stay;
      case "ইশা":
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }
}
