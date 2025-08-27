import 'dart:async';
import 'package:flutter/material.dart';
import 'package:islamicquiz/main.dart';  // আপনার মূল হোম পেজের ফাইল নাম এখানে বসাবেন

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // ৩ সেকেন্ড অপেক্ষা করার পর হোম পেজে নেভিগেট করবে
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()), // আপনার হোম পেজ ক্লাস
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,  // আপনার পছন্দমতো ব্যাকগ্রাউন্ড কালার
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 75,  // 150 / 2
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),  // আপনার splash লোগো ছবি (assets ফোল্ডারে রাখা)
            SizedBox(height: 20),
            Text(
              "আল্লাহর পথে চলার জন্য\nইসলামের জ্ঞান জরুরি।\n\n'ইসলামিক কুইজ'\nআপনার পথপ্রদর্শক।",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.5,
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
