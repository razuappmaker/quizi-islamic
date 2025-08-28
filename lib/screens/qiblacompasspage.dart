import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class QiblaCompassPage extends StatefulWidget {
  const QiblaCompassPage({super.key});

  @override
  _QiblaCompassPageState createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends State<QiblaCompassPage> {
  final double _qiblaDirection = 294; // মক্কার আনুমানিক ডিগ্রি (আপনার অবস্থান অনুযায়ী ভিন্ন হতে পারে)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("কিবলা কম্পাস")),
      body: Center(
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("কম্পাস সেন্সর পাওয়া যায়নি");
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            double? direction = snapshot.data!.heading;

            if (direction == null) {
              return const Text("কম্পাস সেন্সর পাওয়া যাচ্ছে না");
            }

            double qiblaAngle = (_qiblaDirection - direction) * (pi / 180);

            return Transform.rotate(
              angle: qiblaAngle,
              child: Image.asset(
                'assets/compass.png', // একটা কম্পাস ইমেজ রাখবেন
                height: 250,
                width: 250,
              ),
            );
          },
        ),
      ),
    );
  }
}
