// utils.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/language_provider.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  bool shouldExit = false;

  // Language provider থেকে ভাষা লোড করুন
  final languageProvider = Provider.of<LanguageProvider>(
    context,
    listen: false,
  );
  final isEnglish = languageProvider.isEnglish;

  // ভাষা অনুযায়ী টেক্সট সেট করুন
  final Map<String, String> texts = {
    'title': isEnglish ? 'Warning' : 'সতর্কতা',
    'message': isEnglish
        ? 'Would you like to stay with this good deed for a while?\n\nDo you really want to exit the app?'
        : 'চাইলে এই নেক কাজের সাথে কিছুকক্ষণ থাকতে পারেন।\n\nআপনি কি অ্যাপ থেকে সত্যি বের হতে চান?',
    'no': isEnglish ? 'No' : 'না',
    'ok': isEnglish ? 'OK' : 'ঠিক আছে',
    'yes': isEnglish ? 'Yes' : 'হ্যাঁ',
  };

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 10),
          Text(texts['title']!),
        ],
      ),
      content: Text(texts['message']!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // No
          },
          child: Text(texts['no']!),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Ok
          },
          child: Text(texts['ok']!),
        ),
        TextButton(
          onPressed: () {
            shouldExit = true;
            Navigator.of(context).pop(); // Yes
          },
          child: Text(texts['yes']!),
        ),
      ],
    ),
  );

  return shouldExit;
}
