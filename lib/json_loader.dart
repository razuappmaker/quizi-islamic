import 'dart:convert';
import 'package:flutter/services.dart';

class JsonLoader {
  static Future<Map<String, dynamic>> loadJson(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Error loading JSON from $assetPath: $e');
      return {};
    }
  }

  static Future<List<dynamic>> loadJsonList(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Error loading JSON from $assetPath: $e');
      return [];
    }
  }
}
