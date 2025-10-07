import 'dart:async';
import 'package:flutter/material.dart';
import 'package:islamicquiz/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:islamicquiz/managers/home_page.dart'; // ✅ সঠিক path

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _permissionsRequested = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestPermissions();
  }

  Future<void> _initializeNotifications() async {
    try {
      await AwesomeNotifications().initialize(null, [
        NotificationChannel(
          channelKey: 'prayer_times_channel',
          channelName: 'Prayer Times Notifications',
          channelDescription: 'Notifications for prayer times',
          defaultColor: Colors.green,
          ledColor: Colors.green,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          soundSource: 'resource://raw/res_custom_notification',
        ),
      ]);
    } catch (e) {
      print('Notification initialization error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // লোকেশন পারমিশন রিকোয়েস্ট
      final locationStatus = await Geolocator.requestPermission();
      print('Location Permission Status: $locationStatus');

      // Awesome Notifications পারমিশন রিকোয়েস্ট
      final notificationPermission = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
      print('Notification Permission Result: $notificationPermission');

      setState(() {
        _permissionsRequested = true;
      });

      // ৩ সেকেন্ড অপেক্ষা করার পর হোম পেজে নেভিগেট করবে
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ), // ✅ const যোগ করুন
          );
        }
      });
    } catch (e) {
      print('Permission request error: $e');
      // error হলে direct navigate করবে
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ), // ✅ const যোগ করুন
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 75,
              backgroundImage: const AssetImage('assets/images/logo.png'),
            ),
            const SizedBox(height: 20),
            const Text(
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
            const SizedBox(height: 20),
            if (!_permissionsRequested)
              Column(
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "অনুমতি অনুরোধ করা হচ্ছে...",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
