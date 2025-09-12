import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // এই লাইনটি যোগ করুন

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  String? cityName = "Loading...";
  String? countryName = "Loading...";
  double? _lastHeading;
  double _smoothHeading = 0.0;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          cityName = placemarks[0].locality ?? "Unknown City";
          countryName = placemarks[0].country ?? "Unknown Country";
        });
      }
    } catch (e) {
      print("Location fetch error: $e");
    }
  }

  double _applySmoothing(double newHeading) {
    if (_lastHeading == null) {
      _lastHeading = newHeading;
      _smoothHeading = newHeading;
    } else {
      _smoothHeading = _smoothHeading + 0.1 * (newHeading - _smoothHeading);
      _lastHeading = newHeading;
    }
    return _smoothHeading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("কিবলা"), backgroundColor: Colors.green),
      body: FutureBuilder<Position>(
        future: Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("লোকেশন পাওয়া যায়নি"));
          } else {
            final position = snapshot.data!;
            const double kaabaLat = 21.4225;
            const double kaabaLng = 39.8262;

            double deltaLng = (kaabaLng - position.longitude) * pi / 180;
            double lat1 = position.latitude * pi / 180;
            double lat2 = kaabaLat * pi / 180;

            double y = sin(deltaLng);
            double x = cos(lat1) * tan(lat2) - sin(lat1) * cos(deltaLng);
            double qiblaAngle = atan2(y, x) * 180 / pi;
            qiblaAngle = (qiblaAngle + 360) % 360;

            return StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                double? heading = snapshot.data?.heading;
                if (heading == null) {
                  return const Center(child: Text("কম্পাস ডেটা পাওয়া যায়নি"));
                }

                double smoothHeading = _applySmoothing(heading);
                double rotation =
                    ((qiblaAngle - smoothHeading) * (pi / 180) * -1);

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$cityName, $countryName",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 4),
                            ),
                          ),
                          Transform.rotate(
                            angle: rotation,
                            child: const Icon(
                              Icons.navigation,
                              size: 80,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "কিবলা নির্দেশিকা দেখানো হচ্ছে",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
