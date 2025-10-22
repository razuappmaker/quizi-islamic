// splash screen
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:islamicquiz/presentation/features/home/home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _permissionsRequested = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Parallel initialization for better performance
      await _initializeNotifications();
      await _requestPermissions();
    } catch (e) {
      print('App initialization error: $e');
    }

    // Navigate after 2 seconds regardless of initialization result
    _navigateToHome();
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
      // Request permissions without waiting too long
      unawaited(Geolocator.requestPermission());
      unawaited(AwesomeNotifications().requestPermissionToSendNotifications());

      setState(() {
        _permissionsRequested = true;
      });
    } catch (e) {
      print('Permission request error: $e');
    }
  }

  void _navigateToHome() {
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with professional styling
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Main title
            const Text(
              "ইসলামিক ডে",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            const Text(
              "Digital Assistant for Muslims",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 24),

            // Loading indicator
            if (!_permissionsRequested)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
          ],
        ),
      ),
    );
  }
}
