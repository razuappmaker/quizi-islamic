import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.green[800],
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'আমরা আপনার ব্যক্তিগত তথ্য নিরাপদে সংরক্ষণ করি এবং কোনো তৃতীয় পক্ষের সাথে শেয়ার করি না। '
              'এই অ্যাপ ব্যবহারের মাধ্যমে আপনি এই নীতিমালা মেনে নিচ্ছেন।',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
