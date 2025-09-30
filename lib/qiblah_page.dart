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

  // ✅ Adaptive Banner Ad variables
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

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

    // ✅ Load adaptive bottom banner ad
    _loadBottomBannerAd();

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
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  // ✅ Adaptive Bottom Banner Ad লোড করার মেথড
  Future<void> _loadBottomBannerAd() async {
    try {
      // ✅ AdHelper ব্যবহার করে adaptive banner তৈরি করুন
      bool canShowAd = await AdHelper.canShowBannerAd();

      if (!canShowAd) {
        print('Bottom banner ad limit reached, not showing ad');
        return;
      }

      _bottomBannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Adaptive Bottom banner ad loaded successfully');
            if (mounted) {
              setState(() {
                _isBottomBannerAdReady = true;
              });
            }
            AdHelper.recordBannerAdShown();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Adaptive Bottom banner ad failed to load: $error');
            ad.dispose();
            _bottomBannerAd = null;
            if (mounted) {
              setState(() {
                _isBottomBannerAdReady = false;
              });
            }
          },
          onAdOpened: (Ad ad) {
            AdHelper.canClickAd().then((canClick) {
              if (canClick) {
                AdHelper.recordAdClick();
                print('Adaptive Bottom Banner ad clicked.');
              } else {
                print('Ad click limit reached');
              }
            });
          },
        ),
      );

      await _bottomBannerAd?.load();
    } catch (e) {
      print('Error loading adaptive bottom banner ad: $e');
      _bottomBannerAd?.dispose();
      _bottomBannerAd = null;
      if (mounted) {
        setState(() {
          _isBottomBannerAdReady = false;
        });
      }
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
          desiredAccuracy: LocationAccuracy.high, // উচ্চ নির্ভুলতা
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

    // Convert to radians
    double latRad = latitude * pi / 180;
    double lngRad = longitude * pi / 180;
    double kaabaLatRad = kaabaLat * pi / 180;
    double kaabaLngRad = kaabaLng * pi / 180;

    // Calculate the Qibla direction using spherical trigonometry
    double y = sin(kaabaLngRad - lngRad);
    double x =
        cos(latRad) * tan(kaabaLatRad) -
        sin(latRad) * cos(kaabaLngRad - lngRad);

    double qiblaDirection = atan2(y, x);
    double qiblaDirectionDegrees = qiblaDirection * 180 / pi;

    // Normalize to 0-360 degrees
    qiblaDirectionDegrees = (qiblaDirectionDegrees + 360) % 360;

    setState(() {
      qiblaAngle = qiblaDirectionDegrees;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "কিবলা কম্পাস",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _animationController.reset();
              });
              _checkInternetConnection();
              _getLocationAndCalculateQibla();
            },
            tooltip: "রিফ্রেশ করুন",
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _toggleCompassInstructions,
            tooltip: "কম্পাস নির্দেশনা",
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // ✅ REMOVE bottom padding from here - only keep top, left, right
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  // ❌ REMOVE: bottom: mediaQuery.padding.bottom,
                ),
                child: Column(
                  children: [
                    // Internet status indicator
                    if (!_isInternetAvailable)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: 20,
                              color: Colors.orange[800],
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "ইন্টারনেট সংযোগ নেই, সেভ করা লোকেশন ব্যবহার করা হচ্ছে",
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Your existing content...
                    _buildCompactLocationSection(isDarkMode),
                    const SizedBox(height: 24),

                    if (_isLoading)
                      _buildLoadingIndicator()
                    else
                      _buildProfessionalCompassSection(isDarkMode),

                    const SizedBox(height: 24),

                    if (_showCompassInstructions)
                      _buildInstructionsCard(isDarkMode),

                    const SizedBox(height: 16),

                    if (_isPermissionDenied) _buildPermissionCard(isDarkMode),

                    // ✅ ADD extra space at the bottom of content instead of padding
                    SizedBox(
                      height: _isBottomBannerAdReady
                          ? 20
                          : mediaQuery.padding.bottom + 20,
                    ),
                  ],
                ),
              ),
            ),

            // ✅ Adaptive Bottom Banner Ad - KEEP the margin here only
            if (_isBottomBannerAdReady && _bottomBannerAd != null)
              Container(
                width: double.infinity,
                height: _bottomBannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                margin: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
                // ✅ Only here
                child: AdWidget(ad: _bottomBannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ কম্প্যাক্ট লোকেশন সেকশন
  Widget _buildCompactLocationSection(bool isDarkMode) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.location_pin, color: Colors.green[600], size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cityName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (countryName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      countryName,
                      style: TextStyle(fontSize: 14, color: Colors.green[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (cityName == "সেভ করা অবস্থান") ...[
                    const SizedBox(height: 2),
                    Text(
                      "সেভ করা লোকেশন",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.gps_fixed,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "কিবলা দিকনির্দেশ লোড হচ্ছে...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ প্রফেশনাল কম্পাস সেকশন
  Widget _buildProfessionalCompassSection(bool isDarkMode) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildCompassError();
        }

        double? heading = snapshot.data?.heading;
        _currentHeading = heading;

        double rotation = 0;
        if (heading != null && qiblaAngle != null) {
          // সঠিক রোটেশন ক্যালকুলেশন
          rotation = ((qiblaAngle! - heading) * (pi / 180));
        }

        return Column(
          children: [
            _buildProfessionalCompassUI(rotation, heading ?? 0, isDarkMode),
            const SizedBox(height: 20),
            _buildDirectionInfo(heading ?? 0, isDarkMode),
          ],
        );
      },
    );
  }

  Widget _buildCompassError() {
    return Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 60),
        const SizedBox(height: 16),
        Text(
          "কম্পাস লোড করতে সমস্যা হচ্ছে\nমোবাইলটি সামান্য নাড়ান বা রিফ্রেশ করুন",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ✅ প্রফেশনাল কম্পাস UI
  Widget _buildProfessionalCompassUI(
    double rotation,
    double heading,
    bool isDarkMode,
  ) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // কম্পাস বেস
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  isDarkMode ? Colors.grey[900]! : Colors.grey[100]!,
                ],
              ),
              border: Border.all(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                width: 4,
              ),
            ),
            child: CustomPaint(
              painter: ProfessionalCompassPainter(
                textColor: isDarkMode ? Colors.white : Colors.black,
                heading: heading,
              ),
            ),
          ),

          // কিবলা ইন্ডিকেটর
          Transform.rotate(
            angle: rotation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // কিবলা তীর
                Container(
                  width: 4,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[700]!, Colors.red[400]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // কিবলা লেবেল
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    "🕋 কিবলা",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // সেন্টার টার্গেট
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red[700],
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),

          // নর্থ ইন্ডিকেটর
          Positioned(
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12),
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
        ],
      ),
    );
  }

  Widget _buildDirectionInfo(double heading, bool isDarkMode) {
    double difference = qiblaAngle != null ? (qiblaAngle! - heading).abs() : 0;
    difference = difference > 180 ? 360 - difference : difference;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                "কিবলা দিক",
                "${qiblaAngle?.toStringAsFixed(1) ?? '0'}°",
                Icons.explore,
                isDarkMode,
              ),
              _buildInfoItem(
                "বর্তমান দিক",
                "${heading.toStringAsFixed(1)}°",
                Icons.navigation,
                isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: qiblaAngle != null ? 1 - (difference / 180) : 0,
            backgroundColor: isDarkMode ? Colors.grey[600] : Colors.grey[200],
            color: _getProgressColor(difference),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 12),
          Text(
            _getAlignmentText(difference),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getTextColor(difference),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "ভারত: ${_lastLatitude.toStringAsFixed(4)}°, ${_lastLongitude.toStringAsFixed(4)}°",
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[600], size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double difference) {
    if (difference < 2) return Colors.green;
    if (difference < 5) return Colors.lightGreen;
    if (difference < 15) return Colors.orange;
    return Colors.red;
  }

  Color _getTextColor(double difference) {
    if (difference < 2) return Colors.green;
    if (difference < 5) return Colors.lightGreen;
    if (difference < 15) return Colors.orange;
    return Colors.red;
  }

  String _getAlignmentText(double difference) {
    if (difference < 1) return "🎯 সম্পূর্ণ সঠিক! নামাজ শুরু করুন";
    if (difference < 3) return "👍 অত্যন্ত সঠিক, নামাজের জন্য প্রস্তুত";
    if (difference < 8) return "👌 প্রায় সঠিক, সামান্য adjustment করুন";
    if (difference < 20) return "↔️ দিক ঠিক করুন, তারপর নামাজ পড়ুন";
    if (difference < 45) return "🔄 ফোনটি ঘুরিয়ে কিবলার দিক করুন";
    return "❌ সম্পূর্ণ ভুল দিক, ফোনটি ঘুরিয়ে নিন";
  }

  Widget _buildInstructionsCard(bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compass_calibration,
                  color: Colors.green[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "কম্পাস ব্যবহার নির্দেশিকা",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionRow(
              "📱 ফোনটি সমতল রাখুন এবং ঘুরান",
              Icons.phone_android,
            ),
            const SizedBox(height: 8),
            _buildInstructionRow(
              "🎯 লাল তীর কিবলার দিক দেখাবে",
              Icons.architecture,
            ),
            const SizedBox(height: 8),
            _buildInstructionRow("🧭 N দিয়ে উত্তর দিক চিন্হিত", Icons.explore),
            const SizedBox(height: 8),
            _buildInstructionRow(
              "✅ সবুজ বার দেখাবে কতটা সঠিক",
              Icons.check_circle,
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
        Icon(icon, size: 20, color: Colors.green[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildQuranInstructionRow(String text, String reference) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          reference,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionCard(bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.location_off, color: Colors.orange[800], size: 40),
            const SizedBox(height: 12),
            Text(
              "লোকেশন এক্সেস প্রয়োজন",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "সঠিক কিবলা দিকনির্দেশের জন্য লোকেশন এক্সেস দিন",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.orange[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openAppSettings,
              icon: const Icon(Icons.settings),
              label: const Text("সেটিংস খুলুন"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ প্রফেশনাল কম্পাস পেইন্টার
class ProfessionalCompassPainter extends CustomPainter {
  final Color textColor;
  final double heading;

  ProfessionalCompassPainter({
    this.textColor = Colors.black,
    required this.heading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = textColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // ডিগ্রী মার্কার্স
    for (int i = 0; i < 360; i += 30) {
      double angle = i * pi / 180;
      double x1 = center.dx + (radius - 20) * cos(angle);
      double y1 = center.dy + (radius - 20) * sin(angle);
      double x2 = center.dx + (radius - 5) * cos(angle);
      double y2 = center.dy + (radius - 5) * sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

      // প্রধান দিকগুলোর জন্য লেবেল
      if (i % 90 == 0) {
        TextPainter textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

        String direction = "";
        switch (i) {
          case 0:
            direction = "N";
            break;
          case 90:
            direction = "E";
            break;
          case 180:
            direction = "S";
            break;
          case 270:
            direction = "W";
            break;
        }

        textPainter.text = TextSpan(
          text: direction,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: direction == "N" ? 18 : 14,
          ),
        );
        textPainter.layout();

        double textX =
            center.dx + (radius - 35) * cos(angle) - textPainter.width / 2;
        double textY =
            center.dy + (radius - 35) * sin(angle) - textPainter.height / 2;

        textPainter.paint(canvas, Offset(textX, textY));
      }
    }

    // বর্তমান হেডিং লাইন
    final headingPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double headingAngle = heading * pi / 180;
    double hx = center.dx + radius * cos(headingAngle);
    double hy = center.dy + radius * sin(headingAngle);
    canvas.drawLine(center, Offset(hx, hy), headingPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
