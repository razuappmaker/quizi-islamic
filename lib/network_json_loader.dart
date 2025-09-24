// network_json_loader.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class NetworkJsonLoader {
  // আপনার ডোমেইন============================================================
  // আপনার ডোমেইন============================================================
  static const String baseUrl = "https://appmaker.com/assets/";

  static Future<List<dynamic>> loadJsonList(String filePath) async {
    // filePath example: 'assets/questions.json' বা 'assets/salat_doyas.json'
    // আমরা শুধু file name টা নিবো: 'questions.json' বা 'salat_doyas.json'
    final fileName = filePath.split('/').last;

    print('🔄 লোড করার চেষ্টা: $fileName');

    // ১ম চেষ্টা: নেটওয়ার্ক থেকে লোড
    try {
      print('🌐 নেটওয়ার্ক থেকে লোড: $fileName');
      final networkData = await _loadFromNetwork(fileName);
      print('✅ নেটওয়ার্ক থেকে সফল: $fileName');
      return networkData;
    } catch (e) {
      print('❌ নেটওয়ার্ক ব্যর্থ ($fileName): $e');
    }

    // ২য় চেষ্টা: লোকাল asset থেকে লোড
    try {
      print('📁 লোকাল asset থেকে লোড: $filePath');
      final localData = await _loadFromAsset(filePath);
      print('✅ লোকাল asset থেকে সফল: $filePath');
      return localData;
    } catch (e) {
      print('❌ লোকাল asset ব্যর্থ ($filePath): $e');
    }

    // ৩য় চেষ্টা: ডিফল্ট ডেটা
    print('⚠️ সকল সোর্স ব্যর্থ, ডিফল্ট ডেটা ব্যবহার: $fileName');
    return _getDefaultData(fileName);
  }

  // network_json_loader.dart - _loadFromNetwork মেথডে এডিট করুন
  static Future<List<dynamic>> _loadFromNetwork(String fileName) async {
    final url = '$baseUrl$fileName';
    print('🔗 নেটওয়ার্ক URL: $url');

    final httpClient = HttpClient();

    try {
      httpClient.connectionTimeout = Duration(seconds: 8);

      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close().timeout(Duration(seconds: 10));

      print('📊 HTTP Status Code: ${response.statusCode}');
      print('📊 Content-Type: ${response.headers.contentType}');

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();

        // ✅ Debug: প্রথম 500 character দেখুন
        final previewLength = responseBody.length < 500
            ? responseBody.length
            : 500;
        print('📄 Response preview (first $previewLength chars):');
        print(responseBody.substring(0, previewLength));

        try {
          final jsonData = json.decode(responseBody);

          if (jsonData is List) return jsonData;
          if (jsonData is Map) return [jsonData];

          throw Exception('অবৈধ JSON ফরম্যাট');
        } catch (e) {
          print('❌ JSON decode error: $e');
          throw Exception('Invalid JSON format from server');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('নেটওয়ার্ক টাইমআউট');
    } on SocketException {
      throw Exception('ইন্টারনেট সংযোগ নেই');
    } catch (e) {
      throw Exception('নেটওয়ার্ক ত্রুটি: $e');
    } finally {
      httpClient.close();
    }
  }

  static Future<List<dynamic>> _loadFromAsset(String filePath) async {
    try {
      final String response = await rootBundle.loadString(filePath);
      final data = json.decode(response);

      if (data is List) return data;
      if (data is Map) return [data];

      throw Exception('লোকাল JSON ফরম্যাট অবৈধ');
    } catch (e) {
      throw Exception('লোকাল asset লোড ব্যর্থ: $e');
    }
  }

  // ফাইল অনুযায়ী ডিফল্ট ডেটা
  static List<dynamic> _getDefaultData(String fileName) {
    print('📋 ডিফল্ট ডেটা ব্যবহার: $fileName');

    // ফাইল নাম অনুযায়ী আলাদা ডিফল্ট ডেটা
    switch (fileName) {
      case 'questions.json':
        return _getDefaultQuestions();
      case 'salat_doyas.json':
        return _getDefaultSalatDoyas();
      case 'quranic_doyas.json':
        return _getDefaultQuranicDoyas();
      case 'copple_doya.json':
        return _getDefaultCoppleDoyas();
      case 'morning_evening_doya.json':
        return _getDefaultMorningEveningDoyas();
      case 'daily_life_doyas.json':
        return _getDefaultDailyLifeDoyas();
      case 'rog_mukti_doyas.json':
        return _getDefaultNamajAmol();
      case 'fasting_doyas.json':
        return _getDefaultFastingDoyas();
      case 'misc_doyas.json':
        return _getDefaultMiscDoyas();
      default:
        return _getGenericDefaultData();
    }
  }

  // বিভিন্ন ধরনের ডিফল্ট ডেটা
  static List<dynamic> _getDefaultQuestions() {
    return [
      {
        'question': 'ইসলামের প্রথম রুকন কী?',
        'options': ['নামাজ', 'রোজা', 'কালিমা', 'হজ্জ'],
        'answer': 'কালিমa',
      },
    ];
  }

  static List<dynamic> _getDefaultSalatDoyas() {
    return [
      {
        'title': 'তাকবিরাতুল ইহরাম',
        'bangla': 'আল্লাহু আকবার',
        'arabic': 'اللهُ أَكْبَرُ',
        'transliteration': 'আল্লাহু আকবার',
        'meaning': 'আল্লাহ সর্বশ্রেষ্ঠ',
        'reference': 'সহীহ বুখারী: ৭৮৯',
      },
    ];
  }

  static List<dynamic> _getDefaultQuranicDoyas() {
    return [
      {
        'title': 'বিসমিল্লাহ',
        'bangla': 'বিসমিল্লাহির রাহমানির রাহীম',
        'arabic': 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
        'transliteration': 'বিসমিল্লাহির রাহমানির রাহীম',
        'meaning': 'আল্লাহর নামে শুরু করছি যিনি পরম করুণাময়, অতি দয়ালু।',
        'reference': 'সূরা ফাতিহা: ১',
      },
    ];
  }

  // অন্যান্য ডিফল্ট ডেটা মেথডগুলো এখানে যোগ করুন...
  static List<dynamic> _getDefaultCoppleDoyas() => [_getGenericDua()];

  static List<dynamic> _getDefaultMorningEveningDoyas() => [_getGenericDua()];

  static List<dynamic> _getDefaultDailyLifeDoyas() => [_getGenericDua()];

  static List<dynamic> _getDefaultNamajAmol() => [_getGenericDua()];

  static List<dynamic> _getDefaultFastingDoyas() => [_getGenericDua()];

  static List<dynamic> _getDefaultMiscDoyas() => [_getGenericDua()];

  static Map<String, dynamic> _getGenericDua() {
    return {
      'title': 'দোয়া',
      'bangla': 'দোয়া লোড হতে সমস্যা হচ্ছে',
      'arabic': 'بِسْمِ اللهِ',
      'transliteration': 'বিসমিল্লাহ',
      'meaning': 'আল্লাহর নামে শুরু করছি',
      'reference': 'ডিফল্ট ডেটা',
    };
  }

  static List<dynamic> _getGenericDefaultData() {
    return [_getGenericDua()];
  }
}
