import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  String cityName = "লোড হচ্ছে...";
  String countryName = "";
  double? qiblaAngle;
  bool _isLocationLoaded = false;
  bool _hasError = false;
  double _lastLatitude = 23.8103;
  double _lastLongitude = 90.4125;
  double? _currentHeading;
  bool _isPermissionDenied = false;

  // Cache variables
  Position? _cachedPosition;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadLastLocation();
    if (_isFirstLoad) {
      _getLocationAndCalculateQibla();
      _isFirstLoad = false;
    }
  }

  Future<void> _loadLastLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _lastLatitude = prefs.getDouble('last_latitude') ?? 23.8103;
        _lastLongitude = prefs.getDouble('last_longitude') ?? 90.4125;
        cityName = prefs.getString('last_city') ?? "লোড হচ্ছে...";
        countryName = prefs.getString('last_country') ?? "";
      });
    } catch (e) {
      print("Last location load error: $e");
    }
  }

  Future<void> _saveLocation(
    double lat,
    double lng,
    String city,
    String country,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_latitude', lat);
      await prefs.setDouble('last_longitude', lng);
      await prefs.setString('last_city', city);
      await prefs.setString('last_country', country);
    } catch (e) {
      print("Location save error: $e");
    }
  }

  Future<void> _getLocationAndCalculateQibla() async {
    // যদি already loaded থাকে তবে নতুন করে load করার দরকার নেই
    if (_isLocationLoaded && _cachedPosition != null) {
      return;
    }

    try {
      setState(() {
        _isPermissionDenied = false;
      });

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isPermissionDenied = true;
          });
          _calculateQiblaWithLastLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isPermissionDenied = true;
        });
        _calculateQiblaWithLastLocation();
        return;
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 15));

        _cachedPosition = position; // Cache the position
        _lastLatitude = position.latitude;
        _lastLongitude = position.longitude;

        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).timeout(const Duration(seconds: 8));

          if (placemarks.isNotEmpty) {
            String newCity = placemarks[0].locality ?? "অজানা শহর";
            String newCountry = placemarks[0].country ?? "";

            setState(() {
              cityName = newCity;
              countryName = newCountry;
            });

            await _saveLocation(
              position.latitude,
              position.longitude,
              newCity,
              newCountry,
            );
          }
        } catch (e) {
          await _saveLocation(
            position.latitude,
            position.longitude,
            "অজানা শহর",
            "",
          );
          setState(() {
            cityName = "অজানা অবস্থান";
            countryName = "";
          });
        }
      } catch (e) {
        _calculateQiblaWithLastLocation();
        return;
      }

      _calculateQiblaAngle(position.latitude, position.longitude);
    } catch (e) {
      _calculateQiblaWithLastLocation();
    }
  }

  void _calculateQiblaWithLastLocation() {
    setState(() {
      cityName = "সেভ করা অবস্থান";
    });
    _calculateQiblaAngle(_lastLatitude, _lastLongitude);
  }

  void _calculateQiblaAngle(double latitude, double longitude) {
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    double deltaLng = (kaabaLng - longitude) * pi / 180;
    double lat1 = latitude * pi / 180;
    double lat2 = kaabaLat * pi / 180;

    double y = sin(deltaLng);
    double x = cos(lat1) * tan(lat2) - sin(lat1) * cos(deltaLng);
    double calculatedAngle = atan2(y, x) * 180 / pi;
    calculatedAngle = (calculatedAngle + 360) % 360;

    setState(() {
      qiblaAngle = calculatedAngle;
      _isLocationLoaded = true;
    });
  }

  void _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header with location information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cityName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (countryName.isNotEmpty)
                      Text(
                        countryName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade600,
                        ),
                      ),
                    if (cityName == "সেভ করা অবস্থান")
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "(সেভ করা লোকেশন ব্যবহার করা হচ্ছে)",
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Compass Section
              if (!_isLocationLoaded)
                const CircularProgressIndicator()
              else
                StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildStaticCompass();
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 10),
                          Text(
                            "কিবলা দিক: ${qiblaAngle!.toStringAsFixed(1)}°",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    }

                    double? heading = snapshot.data?.heading;
                    _currentHeading = heading;

                    if (heading == null) {
                      return _buildStaticCompass();
                    }

                    double rotation =
                        ((qiblaAngle! - heading) * (pi / 180) * -1);

                    return _buildCompassUI(rotation, heading);
                  },
                ),

              const SizedBox(height: 30),

              // Information and Notes Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "💡 নির্দেশনা",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionRow(
                      "১. লাল তীরের দিকে নামাজ পড়ুন",
                      Icons.arrow_forward,
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionRow(
                      "২. ফোনটি সমতল রাখুন",
                      Icons.stay_current_landscape,
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionRow(
                      "৩. কিছুটা ভুল থাকতে পারে, আল্লাহ তাওফিক দাতা",
                      Icons.info_outline,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Permission Denied Message
              if (_isPermissionDenied)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "লোকেশন এক্সেস প্রয়োজন",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "সঠিক কিবলা দিকনির্দেশের জন্য আপনার লোকেশন এক্সেস প্রয়োজন",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _openAppSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("সেটিংস খুলুন"),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Refresh Button
              ElevatedButton.icon(
                onPressed: _getLocationAndCalculateQibla,
                icon: const Icon(Icons.refresh),
                label: const Text("রিফ্রেশ করুন"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildStaticCompass() {
    return Column(
      children: [
        const Icon(Icons.explore, size: 120, color: Colors.green),
        const SizedBox(height: 20),
        Text(
          "কিবলা দিক: ${qiblaAngle!.toStringAsFixed(1)}°",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "কম্পাস এক্সেস করতে সমস্যা হচ্ছে",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCompassUI(double rotation, double heading) {
    return Column(
      children: [
        // Compass Container
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Compass background with directions
              Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF8F9FA),
                ),
              ),

              // Direction markers (N, E, S, W)
              ..._buildDirectionMarkers(),

              // Degree markers
              ..._buildDegreeMarkers(),

              // Qibla indicator
              Transform.rotate(
                angle: rotation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.navigation,
                        size: 60,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "কিবলা",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Center point
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Information panel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    "কিবলা দিক",
                    "${qiblaAngle!.toStringAsFixed(1)}°",
                  ),
                  _buildInfoItem(
                    "বর্তমান দিক",
                    "${heading.toStringAsFixed(1)}°",
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (360 - (qiblaAngle! - heading).abs()) / 360,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                _getAlignmentText((qiblaAngle! - heading).abs()),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDirectionMarkers() {
    return [
      // North
      Positioned(
        top: 10,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "N",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      // East
      Positioned(
        right: 10,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "E",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      // South
      Positioned(
        bottom: 10,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "S",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      // West
      Positioned(
        left: 10,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "W",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDegreeMarkers() {
    List<Widget> markers = [];
    for (int i = 0; i < 12; i++) {
      double angle = i * 30 * pi / 180;
      markers.add(
        Positioned(
          left: 125 + 110 * sin(angle),
          top: 125 - 110 * cos(angle),
          child: Container(
            width: 2,
            height: i % 3 == 0 ? 12 : 8,
            color: i % 3 == 0 ? Colors.green : Colors.grey,
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getAlignmentText(double difference) {
    if (difference < 5) return "পুরোপুরি সঠিক দিকে আছেন! 🎯";
    if (difference < 15) return "প্রায় সঠিক দিকে আছেন 👍";
    if (difference < 30) return "সামান্য adjustment প্রয়োজন";
    if (difference < 90) return "দিক পরিবর্তন প্রয়োজন";
    return "উল্টো দিকে আছেন, সম্পূর্ণ ঘুরে যান";
  }
}
