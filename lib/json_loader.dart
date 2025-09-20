import 'dart:convert';
import 'package:flutter/services.dart';

class JsonLoader {
  static Future<List<dynamic>> loadJsonList(String assetPath) async {
    try {
      print('Loading JSON from: $assetPath'); // Debug line
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      print(
        'Successfully loaded ${jsonList.length} items from $assetPath',
      ); // Debug
      return jsonList;
    } catch (e) {
      print('Error loading JSON from $assetPath: $e'); // Debug
      throw Exception('Failed to load $assetPath: $e');
    }
  }
}
