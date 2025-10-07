// widgets/location_modal.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LocationModal extends StatefulWidget {
  final String currentLocationMode;
  final Function(String, double?, double?, String?, String?)
  onLocationModeChanged;

  const LocationModal({
    Key? key,
    required this.currentLocationMode,
    required this.onLocationModeChanged,
  }) : super(key: key);

  @override
  State<LocationModal> createState() => _LocationModalState();
}

class _LocationModalState extends State<LocationModal> {
  bool _isLoading = false;
  bool _isLoadingLocations = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _locations = [];

  // Language Texts
  static const Map<String, Map<String, String>> _texts = {
    'changeLocation': {'en': 'Change Location', 'bn': 'লোকেশন পরিবর্তন করুন'},
    'autoLocation': {'en': 'Automatic Location', 'bn': 'অটোমেটিক লোকেশন'},
    'autoLocationDesc': {
      'en': 'Use your current location',
      'bn': 'আপনার বর্তমান লোকেশন ব্যবহার করুন',
    },
    'manualLocation': {'en': 'Manual Location', 'bn': 'ম্যানুয়াল লোকেশন'},
    'manualLocationDesc': {
      'en': 'Select country and city from list',
      'bn': 'লিস্ট থেকে দেশ ও শহর নির্বাচন করুন',
    },
    'selectCountryCity': {
      'en': 'Select Country & City',
      'bn': 'দেশ ও শহর নির্বাচন করুন',
    },
    'searchPlaceholder': {
      'en': 'Search country or city...',
      'bn': 'দেশ বা শহর খুঁজুন...',
    },
    'resultsFound': {'en': 'results found', 'bn': 'টি ফলাফল'},
    'noResults': {'en': 'No results found', 'bn': 'কোন ফলাফল পাওয়া যায়নি'},
    'locationInfo': {
      'en': 'Changing location will automatically update prayer times',
      'bn': 'লোকেশন পরিবর্তন করলে নামাজের সময় স্বয়ংক্রিয়ভাবে আপডেট হবে',
    },
    'cancel': {'en': 'Cancel', 'bn': 'বাতিল'},
    'locationPermission': {
      'en': 'Location permission required',
      'bn': 'লোকেশন পারমিশন প্রয়োজন',
    },
    'grantPermission': {
      'en': 'Grant location permission from settings',
      'bn': 'সেটিংস থেকে লোকেশন পারমিশন দিন',
    },
    'locationSet': {
      'en': 'Current location set',
      'bn': 'বর্তমান লোকেশন সেট করা হয়েছে',
    },
    'locationNotFound': {
      'en': 'Location not found: ',
      'bn': 'লোকেশন পাওয়া যায়নি: ',
    },
    'detectingLocation': {
      'en': 'Detecting location...',
      'bn': 'লোকেশন ডিটেক্ট করা হচ্ছে...',
    },
    'locationSelected': {'en': 'selected', 'bn': 'সেট করা হয়েছে'},
    'loadingLocations': {
      'en': 'Loading locations...',
      'bn': 'লোকেশন লোড হচ্ছে...',
    },
    'errorLoadingLocations': {
      'en': 'Error loading locations',
      'bn': 'লোকেশন লোড করতে সমস্যা',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadLocationsFromJson();
  }

  // Helper method to get text based on current language
  String _text(String key, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final langKey = languageProvider.isEnglish ? 'en' : 'bn';
    return _texts[key]?[langKey] ?? key;
  }

  // JSON থেকে লোকেশন লোড করা
  Future<void> _loadLocationsFromJson() async {
    setState(() {
      _isLoadingLocations = true;
    });

    try {
      // JSON ফাইল লোড করুন
      String data = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/districts.json');

      final jsonResult = jsonDecode(data);

      // JSON ডাটা প্রসেস করুন
      List<Map<String, dynamic>> loadedLocations = [];

      if (jsonResult is List) {
        for (var item in jsonResult) {
          loadedLocations.add({
            "country": item['country'] ?? "Bangladesh",
            "countryBn": item['countryBn'] ?? "বাংলাদেশ",
            "city": item['city'] ?? "",
            "cityBn": item['cityBn'] ?? "",
            "lat": item['lat'] ?? 23.8103,
            "lon": item['lon'] ?? 90.4125,
            "flag": _getFlagColor(item['country'] ?? "Bangladesh"),
          });
        }
      }

      setState(() {
        _locations = loadedLocations;
        _isLoadingLocations = false;
      });
    } catch (e) {
      print("Error loading locations from JSON: $e");

      // Fallback: যদি JSON লোড না হয় তাহলে ডিফল্ট লোকেশন ব্যবহার করুন
      _loadDefaultLocations();
    }
  }

  // ডিফল্ট লোকেশন লোড করা (যদি JSON ফেইল হয়)
  void _loadDefaultLocations() {
    setState(() {
      _locations = [
        {
          "country": "Bangladesh",
          "countryBn": "বাংলাদেশ",
          "city": "Dhaka",
          "cityBn": "ঢাকা",
          "lat": 23.8103,
          "lon": 90.4125,
          "flag": Colors.green,
        },
        {
          "country": "Bangladesh",
          "countryBn": "বাংলাদেশ",
          "city": "Chittagong",
          "cityBn": "চট্টগ্রাম",
          "lat": 22.3569,
          "lon": 91.7832,
          "flag": Colors.green,
        },
        {
          "country": "Bangladesh",
          "countryBn": "বাংলাদেশ",
          "city": "Khulna",
          "cityBn": "খুলনা",
          "lat": 22.8456,
          "lon": 89.5403,
          "flag": Colors.green,
        },
      ];
      _isLoadingLocations = false;
    });
  }

  // দেশ অনুযায়ী ফ্ল্যাগ কালার
  Color _getFlagColor(String country) {
    switch (country) {
      case "Bangladesh":
        return Colors.green;
      case "Saudi Arabia":
        return Colors.green;
      case "United Arab Emirates":
        return Colors.red;
      case "India":
        return Colors.orange;
      case "Pakistan":
        return Colors.green;
      case "United States":
        return Colors.blue;
      case "United Kingdom":
        return Colors.blue;
      case "Turkey":
        return Colors.red;
      case "Malaysia":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get city and country name based on language
  String _getCityName(Map<String, dynamic> location, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.isEnglish ? location['city'] : location['cityBn'];
  }

  String _getCountryName(Map<String, dynamic> location, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.isEnglish
        ? location['country']
        : location['countryBn'];
  }

  // সার্চ করা লোকেশন ফিল্টার করা
  List<Map<String, dynamic>> get _filteredLocations {
    if (_searchQuery.isEmpty) {
      return _locations;
    }
    return _locations.where((location) {
      final country = location['country'].toString().toLowerCase();
      final countryBn = location['countryBn'].toString().toLowerCase();
      final city = location['city'].toString().toLowerCase();
      final cityBn = location['cityBn'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      return country.contains(query) ||
          countryBn.contains(query) ||
          city.contains(query) ||
          cityBn.contains(query);
    }).toList();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // লোকেশন পারমিশন চেক
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_text('locationPermission', context))),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_text('grantPermission', context))),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // বর্তমান লোকেশন পাওয়া
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // রিভার্স জিওকোডিং করে ঠিকানা পাওয়া
      String cityName = _text('currentLocation', context);
      String countryName = _text('unknownCountry', context);

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          cityName =
              placemark.locality ??
              placemark.subAdministrativeArea ??
              placemark.administrativeArea ??
              _text('currentLocation', context);
          countryName = placemark.country ?? _text('unknownCountry', context);

          // খুব দীর্ঘ নাম সংক্ষিপ্ত করুন
          if (cityName.length > 20) {
            cityName = cityName.substring(0, 20) + '...';
          }
        }
      } catch (e) {
        print("Geocoding error: $e");
        // জিওকোডিং ফেইল করলে ডিফল্ট ভ্যালু ব্যবহার করুন
        cityName = _text('currentLocation', context);
        countryName = _text('unknownCountry', context);
      }

      // লোকেশন মোড পরিবর্তন
      widget.onLocationModeChanged(
        'auto',
        position.latitude,
        position.longitude,
        cityName,
        countryName,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_text('locationSet', context))));
    } catch (e) {
      print("Location error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_text('locationNotFound', context)}${e.toString()}"),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showManualLocationOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final bottomPadding = mediaQuery.padding.bottom;
        final screenHeight = mediaQuery.size.height;
        final containerHeight = screenHeight * 0.85;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: containerHeight,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + bottomPadding,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // ড্রাগ হ্যান্ডেল
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // হেডার
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _text('selectCountryCity', context),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 22),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // সার্চ বার
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: _text('searchPlaceholder', context),
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                            ),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ফলাফল কাউন্ট
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text(
                            "${_filteredLocations.length} ${_text('resultsFound', context)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // লোকেশন লোডিং বা লিস্ট
                  Expanded(
                    child: _isLoadingLocations
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _text('loadingLocations', context),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _filteredLocations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _text('noResults', context),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredLocations.length,
                            itemBuilder: (context, index) {
                              final location = _filteredLocations[index];
                              return _buildLocationItem(
                                context: context,
                                location: location,
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 12),

                  // বাতিল বাটন
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _text('cancel', context),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // লোকেশন আইটেম বিল্ড করার জন্য হেল্পার মেথড
  Widget _buildLocationItem({
    required BuildContext context,
    required Map<String, dynamic> location,
  }) {
    final cityName = _getCityName(location, context);
    final countryName = _getCountryName(location, context);

    // সম্পূর্ণ লোকেশন স্ট্রিং তৈরি করুন - "খুলনা, বাংলাদেশ" ফরম্যাটে
    String fullLocationName = "$cityName, $countryName";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: location['flag'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: location['flag'].withOpacity(0.3)),
            ),
            child: Icon(Icons.location_on, color: location['flag'], size: 20),
          ),
          title: Text(
            cityName,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            countryName,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 14),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          onTap: () {
            Navigator.pop(context); // দেশ সিলেক্ট মডাল বন্ধ

            // সম্পূর্ণ লোকেশন স্ট্রিং পাঠান - "খুলনা, বাংলাদেশ"
            widget.onLocationModeChanged(
              'manual',
              location['lat'],
              location['lon'],
              fullLocationName, // "খুলনা, বাংলাদেশ" ফরম্যাটে
              countryName,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "$fullLocationName ${_text('locationSelected', context)}",
                ),
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context); // মূল লোকেশন মডাল বন্ধ
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Text(
            _text('changeLocation', context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),

          const SizedBox(height: 16),

          // Option 1: Automatic Location
          Container(
            decoration: BoxDecoration(
              color: widget.currentLocationMode == 'auto'
                  ? Colors.blue.shade50
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: widget.currentLocationMode == 'auto'
                  ? Border.all(color: Colors.blue.shade200)
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.my_location, color: Colors.blue, size: 20),
              ),
              title: Text(
                _text('autoLocation', context),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: widget.currentLocationMode == 'auto'
                      ? Colors.blue.shade800
                      : Theme.of(context).colorScheme.onBackground,
                ),
              ),
              subtitle: Text(
                _text('autoLocationDesc', context),
                style: TextStyle(fontSize: 12),
              ),
              trailing: widget.currentLocationMode == 'auto'
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.green, size: 16),
                    )
                  : null,
              onTap: _isLoading ? null : _getCurrentLocation,
            ),
          ),

          if (_isLoading) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _text('detectingLocation', context),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Option 2: Manual Location
          Container(
            decoration: BoxDecoration(
              color: widget.currentLocationMode == 'manual'
                  ? Colors.orange.shade50
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: widget.currentLocationMode == 'manual'
                  ? Border.all(color: Colors.orange.shade200)
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.map, color: Colors.orange, size: 20),
              ),
              title: Text(
                _text('manualLocation', context),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: widget.currentLocationMode == 'manual'
                      ? Colors.orange.shade800
                      : Theme.of(context).colorScheme.onBackground,
                ),
              ),
              subtitle: Text(
                _text('manualLocationDesc', context),
                style: TextStyle(fontSize: 12),
              ),
              trailing: widget.currentLocationMode == 'manual'
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.green, size: 16),
                    )
                  : null,
              onTap: _showManualLocationOptions,
            ),
          ),

          const SizedBox(height: 16),

          // Information Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _text('locationInfo', context),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                _text('cancel', context),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
