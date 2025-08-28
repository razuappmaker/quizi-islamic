import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> with SingleTickerProviderStateMixin {
  double qiblaDirection = 294.0; // Approximate angle to Makkah
  double currentDirection = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("কিবলা দিক"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("কম্পাস পাওয়া যাচ্ছে না");
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            double? direction = snapshot.data!.heading;
            if (direction == null) {
              return const Text("কম্পাস সেন্সর পাওয়া যাচ্ছে না");
            }

            // Smooth animation
            _animation = Tween<double>(begin: currentDirection, end: direction)
                .animate(_controller)
              ..addListener(() {
                setState(() {});
              });

            _controller.forward(from: 0);
            currentDirection = direction;

            double angle = (qiblaDirection - _animation.value) * (pi / 180);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass background
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/compass.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Compass needle (rotates)
                    Transform.rotate(
                      angle: -_animation.value * (pi / 180),
                      child: const Icon(Icons.explore, size: 250, color: Colors.blueAccent),
                    ),

                    // Qibla direction arrow (fixed)
                    Transform.rotate(
                      angle: angle,
                      child: const Icon(Icons.navigation, size: 60, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "লাল তীর মক্কার দিকে নির্দেশ করছে",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
