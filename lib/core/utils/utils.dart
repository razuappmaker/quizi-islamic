// utils.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/language_provider.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  bool? shouldExit = false;

  // Language provider থেকে ভাষা লোড করুন
  final languageProvider = Provider.of<LanguageProvider>(
    context,
    listen: false,
  );
  final isEnglish = languageProvider.isEnglish;

  // ভাষা অনুযায়ী টেক্সট সেট করুন
  final Map<String, String> texts = {
    'title': isEnglish ? 'Exit App' : 'অ্যাপ থেকে বের হোন',
    'message': isEnglish
        ? 'Would you like to stay with this good deed for a while?\n\nDo you really want to exit the app?'
        : 'চাইলে এই নেক কাজের সাথে কিছুক্ষণ থাকতে পারেন।\n\nআপনি কি অ্যাপ থেকে সত্যি বের হতে চান?',
    'stay': isEnglish ? 'Stay in App' : 'অ্যাপে থাকুন',
    'exit': isEnglish ? 'Exit App' : 'বের হোন',
  };

  await showDialog(
    context: context,
    barrierDismissible: false, // User কে dialog এর বাইরে ক্লিক করতে দিবে না
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.exit_to_app, color: Colors.orange),
          SizedBox(width: 10),
          Text(texts['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(texts['message']!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      actions: [
        // Stay in App বাটন
        TextButton(
          onPressed: () {
            shouldExit = false;
            Navigator.of(context).pop();
          },
          child: Text(
            texts['stay']!,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
          ),
        ),
        // Exit App বাটন
        TextButton(
          onPressed: () {
            shouldExit = true;
            Navigator.of(context).pop();
          },
          child: Text(
            texts['exit']!,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  return shouldExit ?? false;
}
