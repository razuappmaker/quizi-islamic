import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'ad_helper.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage>
    with SingleTickerProviderStateMixin {
  String cityName = "লোড হচ্ছে...";
  String countryName = "";
  double? qiblaAngle;
  bool _isLocationLoaded = false;
  double _lastLatitude = 23.8103;
  double _lastLongitude = 90.4125;
  double? _currentHeading;
  bool _isPermissionDenied = false;
  bool _isLoading = true;
  bool _showCompassInstructions = true;
  bool _isInternetAvailable = true;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Cache variables
  Position? _cachedPosition;
  bool _isFirstLoad = true;

  // Banner Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initialize Ads
    AdHelper.initialize();

    // Create & load banner ad
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Banner Ad failed to load: $error');
        },
      ),
    );
    _bannerAd!.load();

    _checkInternetConnection();
    _loadLastLocation();
    _getLocationAndCalculateQibla();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isInternetAvailable = connectivityResult != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
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
    if (_isLocationLoaded && _cachedPosition != null) return;

    setState(() {
      _isLoading = true;
    });

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
            _isLoading = false;
          });
          _calculateQiblaWithLastLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isPermissionDenied = true;
          _isLoading = false;
        });
        _calculateQiblaWithLastLocation();
        return;
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(const Duration(seconds: 15));

        _cachedPosition = position;
        _lastLatitude = position.latitude;
        _lastLongitude = position.longitude;

        // Only try to get city/country name if internet is available
        if (_isInternetAvailable) {
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
            print("Geocoding error: $e");
            // Even if geocoding fails, we can still calculate Qibla
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
        } else {
          // No internet, use saved location or coordinates
          await _saveLocation(
            position.latitude,
            position.longitude,
            "সেভ করা অবস্থান",
            "",
          );
          setState(() {
            cityName = "সেভ করা অবস্থান";
            countryName = "";
          });
        }
      } catch (e) {
        print("Position error: $e");
        _calculateQiblaWithLastLocation();
        return;
      }

      _calculateQiblaAngle(position.latitude, position.longitude);
    } catch (e) {
      print("General error: $e");
      _calculateQiblaWithLastLocation();
    } finally {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  void _calculateQiblaWithLastLocation() {
    setState(() {
      cityName = "সেভ করা অবস্থান";
    });
    _calculateQiblaAngle(_lastLatitude, _lastLongitude);
    setState(() {
      _isLoading = false;
    });
    _animationController.forward();
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

  void _toggleCompassInstructions() {
    setState(() {
      _showCompassInstructions = !_showCompassInstructions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "কিবলা নির্দেশনা",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _toggleCompassInstructions,
            tooltip: "কম্পাস নির্দেশনা",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Internet status indicator
                    if (!_isInternetAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: 18,
                              color: Colors.orange[800],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "ইন্টারনেট সংযোগ নেই, সেভ করা লোকেশন ব্যবহার করা হচ্ছে",
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Header with location information
                    FadeTransition(
                      opacity: _animation,
                      child: Container(
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              "স্থানাঙ্ক: ${_lastLatitude.toStringAsFixed(4)}, ${_lastLongitude.toStringAsFixed(4)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Compass Section
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Colors.green),
                            SizedBox(height: 16),
                            Text(
                              "কিবলা দিকনির্দেশ লোড হচ্ছে...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      StreamBuilder<CompassEvent>(
                        stream: FlutterCompass.events,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 50,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "কম্পাস লোড করতে সমস্যা হচ্ছে\nমোবাইলটি সামান্য নাড়ান বা রিফ্রESH করুন",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            );
                          }

                          double? heading = snapshot.data?.heading;
                          _currentHeading = heading;
                          double rotation = 0;
                          if (heading != null && qiblaAngle != null) {
                            rotation =
                                ((qiblaAngle! - heading) * (pi / 180) * -1);
                          }

                          return Column(
                            children: [
                              _buildCompassUI(rotation, heading ?? 0),
                              if (_showCompassInstructions)
                                _buildCompassInstructions(),
                            ],
                          );
                        },
                      ),

                    const SizedBox(height: 30),

                    // Information Section
                    // Information Section
                    FadeTransition(
                      opacity: _animation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
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
                            Text(
                              "💡 নির্দেশনা",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildQuranInstructionRow(
                              "জামাতের সাথে নামাজ আদায় করুন",
                              "সুরা আল-বাকারা: ৪৩",
                              Icons.menu_book,
                            ),
                            const SizedBox(height: 8),
                            _buildQuranInstructionRow(
                              "যেখানেই থাকুন নামাজ প্রতিষ্ঠা করুন",
                              "সুরা আল-বাকারা: ১১৫",
                              Icons.menu_book,
                            ),
                            const SizedBox(height: 8),
                            _buildQuranInstructionRow(
                              "নামাজের সময় হলে তা আদায়ে অবহেলা করবেন না",
                              "সুরা আল-বাকারা: ২৩৮",
                              Icons.menu_book,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Permission Denied Message
                    if (_isPermissionDenied)
                      FadeTransition(
                        opacity: _animation,
                        child: Container(
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
                      ),

                    const SizedBox(height: 20),

                    // Refresh Button
                    FadeTransition(
                      opacity: _animation,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _animationController.reset();
                          });
                          _checkInternetConnection();
                          _getLocationAndCalculateQibla();
                        },
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
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Banner Ad at bottom
            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                color: Colors.transparent,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
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

  Widget _buildCompassInstructions() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compass_calibration,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "কম্পাস ব্যবহার নির্দেশিকা",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInstructionRow(
            "মোবাইলটি সামনে-পিছনে বা ডানে-বামে ঘুরান",
            Icons.rotate_right,
          ),
          const SizedBox(height: 8),
          _buildInstructionRow(
            "কম্পাস সঠিকভাবে কাজ করার জন্য ফোনটি সমতল রাখুন",
            Icons.stay_current_landscape,
          ),
          const SizedBox(height: 8),
          _buildInstructionRow(
            "লাল তীরটি কিবলার দিক নির্দেশ করবে",
            Icons.navigation,
          ),
          const SizedBox(height: 8),
          _buildInstructionRow(
            "ইন্টারনেট ছাড়াই কাজ করে, শুধু জিপিএস চালু রাখুন",
            Icons.wifi_off,
          ),
          const SizedBox(height: 8),
          _buildInstructionRow(
            "কম্পাস ক্যালিব্রেট করতে মোবাইলটি ∞ আকারে ঘুরান",
            Icons.autorenew,
          ),
        ],
      ),
    );
  }

  // নির্দেশনা দেখানো জন্য মেথড বানানো হয়েছে
  Widget _buildQuranInstructionRow(
    String text,
    String reference,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                reference,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
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
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: CustomPaint(
                  painter: CompassDirectionsPainter(
                    textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
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
                      child: Icon(
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    "কিবলা দিক",
                    "${qiblaAngle?.toStringAsFixed(1) ?? 0}°",
                  ),
                  _buildInfoItem(
                    "বর্তমান দিক",
                    "${heading.toStringAsFixed(1)}°",
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: qiblaAngle != null
                    ? (360 - (qiblaAngle! - heading).abs()) / 360
                    : 0,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.1),
                color: Theme.of(context).colorScheme.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                qiblaAngle != null
                    ? _getAlignmentText((qiblaAngle! - heading).abs())
                    : "",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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

class CompassDirectionsPainter extends CustomPainter {
  final Color textColor;

  CompassDirectionsPainter({this.textColor = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = textColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw directions (N, E, S, W)
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw North
    textPainter.text = TextSpan(
      text: 'N',
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - radius + 10),
    );

    // Draw East
    textPainter.text = TextSpan(
      text: 'E',
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx + radius - 20, center.dy - textPainter.height / 2),
    );

    // Draw South
    textPainter.text = TextSpan(
      text: 'S',
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + radius - 25),
    );

    // Draw West
    textPainter.text = TextSpan(
      text: 'W',
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - radius + 10, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
