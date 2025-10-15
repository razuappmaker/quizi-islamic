// prayer_time_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PrayerTimeService {
  Timer? _countdownTimer;
  Duration _currentCountdown = Duration.zero;
  String _currentNextPrayer = "";
  Map<String, String> _currentPrayerTimes = {};

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

  // Getter for current countdown
  Duration get countdownDuration => _currentCountdown;

  // Getter for next prayer name
  String get nextPrayerName => _currentNextPrayer;

  // Getter for prayer times
  Map<String, String> get prayerTimes => _currentPrayerTimes;

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

        // ম্যানুয়াল লোকেশনের জন্য _getImprovedLocationInfo কল করুন
        Map<String, String> locationInfo = await _getImprovedLocationInfo(
          latitude,
          longitude,
          isManual: true,
          manualCity: manualCityName,
          manualCountry: manualCountryName,
        );
        cityName = locationInfo['city']!;
        countryName = locationInfo['country']!;

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
        _currentPrayerTimes = prayerTimes;

        print('Prayer times fetched successfully');
        print('City: $cityName, Country: $countryName');

        // প্রতিটি নামাজের সময় প্রিন্ট করুন
        prayerTimes.forEach((key, value) {
          print('$key: $value');
        });

        // Start countdown timer
        _startCountdownTimer(prayerTimes);

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

  // Start countdown timer with seconds
  void _startCountdownTimer(Map<String, String> prayerTimes) {
    _countdownTimer?.cancel();

    // Update countdown immediately
    _updateCountdown(prayerTimes);

    // Start timer for seconds update
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateCountdown(prayerTimes);
    });
  }

  // Update countdown with seconds
  void _updateCountdown(Map<String, String> prayerTimes) {
    final result = findNextPrayer(prayerTimes);
    if (result != null) {
      _currentNextPrayer = result['nextPrayer'];
      _currentCountdown = result['countdown'];
    } else {
      _currentNextPrayer = "লোড হচ্ছে...";
      _currentCountdown = Duration.zero;
    }
  }

  // Dispose timer
  void dispose() {
    _countdownTimer?.cancel();
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

  // prayer_time_service.dart - _getImprovedLocationInfo মেথডটি রিপ্লেস করুন
  Future<Map<String, String>> _getImprovedLocationInfo(
    double lat,
    double lng, {
    bool isManual = false,
    String? manualCity,
    String? manualCountry,
  }) async {
    // যদি ম্যানুয়াল লোকেশন হয়
    if (isManual && manualCity != null) {
      String finalLocation = manualCity;

      // দেশের নাম যোগ করুন
      if (manualCountry != null && manualCountry.isNotEmpty) {
        finalLocation = "$finalLocation, $manualCountry";
      } else {
        finalLocation = "$finalLocation, বাংলাদেশ"; // ডিফল্ট দেশ
      }

      return {'city': finalLocation, 'country': manualCountry ?? "বাংলাদেশ"};
    }

    // বাকি কোড অটোমেটিক লোকেশনের জন্য একই থাকবে
    String city = "বর্তমান অবস্থান";
    String country = "বাংলাদেশ";
    String area = "";

    try {
      final placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(Duration(seconds: 8));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // আপনার আগের ডিটেইলড লোকেশন লজিক
        String locality = place.locality ?? "";
        String subLocality = place.subLocality ?? "";
        String administrativeArea = place.administrativeArea ?? "";
        String subAdministrativeArea = place.subAdministrativeArea ?? "";
        String thoroughfare = place.thoroughfare ?? "";

        country = place.country ?? "বাংলাদেশ";

        // এলাকা/এরিয়া নির্ধারণ
        if (subLocality.isNotEmpty) {
          area = subLocality;
        } else if (thoroughfare.isNotEmpty) {
          area = thoroughfare;
        } else if (subAdministrativeArea.isNotEmpty) {
          area = subAdministrativeArea;
        }

        // শহরের নাম নির্ধারণ
        if (locality.isNotEmpty) {
          city = locality;
        } else if (subAdministrativeArea.isNotEmpty) {
          city = subAdministrativeArea;
        } else if (administrativeArea.isNotEmpty) {
          city = administrativeArea;
        }

        // ফাইনাল লোকেশন স্ট্রিং তৈরি - "গুলশান, ঢাকা, বাংলাদেশ" ফরম্যাটে
        String finalLocation = "";

        if (area.isNotEmpty && area != city) {
          finalLocation = "$area, $city";
        } else {
          finalLocation = city;
        }

        // দেশের নাম যোগ করুন
        if (country.isNotEmpty) {
          finalLocation = "$finalLocation, $country";
        }

        // খুব দীর্ঘ নাম সংক্ষিপ্ত করুন
        if (finalLocation.length > 35) {
          finalLocation = finalLocation.substring(0, 35) + '...';
        }

        print('Detailed Location: $finalLocation');
        print('Country: $country');

        return {'city': finalLocation, 'country': country};
      }
    } catch (e) {
      print('Error getting location: $e');
    }

    return {'city': "বর্তমান অবস্থান, বাংলাদেশ", 'country': "বাংলাদেশ"};
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
      // বর্তমান সময় (ঘন্টা, মিনিট, সেকেন্ড সহ)
      DateTime currentTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
        now.second,
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

    return null;
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
        now.second,
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
      // প্রাসঙ্গিক দেশ ও শহর
      'Kuwait': 'কুয়েত',
      'Kuwait City': 'কুয়েত সিটি',
      'Dhaka': 'ঢাকা',
      'Chittagong': 'চট্টগ্রাম',
      'Riyadh': 'রিয়াদ',
      'Jeddah': 'জেদ্দা',
      'Makkah': 'মক্কা',
      'Madinah': 'মদিনা',
      'Dammam': 'দাম্মাম',
      'Khobar': 'খোবার',
      'Dubai': 'দুবাই',
      'Abu Dhabi': 'আবুধাবি',
      'Sharjah': 'শারজাহ',
      'Ajman': 'আজমান',
      'Ras Al Khaimah': 'রাস আল খাইমা',
      'Fujairah': 'ফুজেইরা',
      'Umm Al Quwain': 'উম্ম আল কউইন',
      'Doha': 'দোহা',
      'Qatar': 'কাতার',
      'Saudi Arabia': 'সৌদি আরব',
      'Bangladesh': 'বাংলাদেশ',
      'India': 'ভারত',
      'Pakistan': 'পাকিস্তান',
      'United Arab Emirates': 'সংযুক্ত আরব আমিরাত',
      'Oman': 'ওমান',
      'Muscat': 'মাসকাট',
      'Bahrain': 'বাহরাইন',
      'Manama': 'মানামা',
      'United States': 'যুক্তরাষ্ট্র',
      'USA': 'যুক্তরাষ্ট্র',
      'America': 'আমেরিকা',
      'Canada': 'কানাডা',
      'Australia': 'অস্ট্রেলিয়া',
      'United Kingdom': 'যুক্তরাজ্য',
      'UK': 'যুক্তরাজ্য',
      'London': 'লন্ডন',
      'New York': 'নিউ ইয়র্ক',
      'California': 'ক্যালিফোর্নিয়া',
      'San Francisco': 'সান ফ্রান্সিস্কো',
      'Los Angeles': 'লস এঞ্জেলেস',
      'Mountain View': 'মাউন্টেন ভিউ',
      'Boston': 'বস্টন',
      'Chicago': 'চিকাগো',
      'Houston': 'হিউস্টন',
      'Singapore': 'সিঙ্গাপুর',
      'Malaysia': 'মালয়েশিয়া',
      'Kuala Lumpur': 'কুয়ালালামপুর',
      'Saudi': 'সৌদি', // বিকল্প, প্রয়োজনমতো
      // আরও দেশ/শহর যুক্ত করুন
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

  // অ্যাডজাস্ট করা নামাজের সময় রিটার্ন করার মেথড
  Map<String, String> getAdjustedPrayerTimesForNotifications(
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
      }
    }

    return adjustedTimes;
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
