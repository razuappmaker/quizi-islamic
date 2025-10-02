// widgets/location_modal.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  String _searchQuery = '';

  // দেশ ও শহরের লিস্ট
  final List<Map<String, dynamic>> _locations = [
    // বাংলাদেশের শহরগুলো
    {
      "country": "বাংলাদেশ",
      "city": "ঢাকা",
      "lat": 23.8103,
      "lon": 90.4125,
      "flag": Colors.green,
    },
    {
      "country": "বাংলাদেশ",
      "city": "চট্টগ্রাম",
      "lat": 22.3569,
      "lon": 91.7832,
      "flag": Colors.green,
    },
    {
      "country": "বাংলাদেশ",
      "city": "খুলনা",
      "lat": 22.8456,
      "lon": 89.5403,
      "flag": Colors.green,
    },
    {
      "country": "বাংলাদেশ",
      "city": "রাজশাহী",
      "lat": 24.3745,
      "lon": 88.6042,
      "flag": Colors.green,
    },
    {
      "country": "বাংলাদেশ",
      "city": "সিলেট",
      "lat": 24.8949,
      "lon": 91.8687,
      "flag": Colors.green,
    },
    {
      "country": "বাংলাদেশ",
      "city": "বরিশাল",
      "lat": 22.7010,
      "lon": 90.3535,
      "flag": Colors.green,
    },
    {
      "country": "বাংলাদেশ",
      "city": "রংপুর",
      "lat": 25.7439,
      "lon": 89.2752,
      "flag": Colors.green,
    },

    // সৌদি আরব
    {
      "country": "সৌদি আরব",
      "city": "রিয়াদ",
      "lat": 24.7136,
      "lon": 46.6753,
      "flag": Colors.green,
    },
    {
      "country": "সৌদি আরব",
      "city": "জেদ্দা",
      "lat": 21.4858,
      "lon": 39.1925,
      "flag": Colors.green,
    },
    {
      "country": "সৌদি আরব",
      "city": "মক্কা",
      "lat": 21.4225,
      "lon": 39.8262,
      "flag": Colors.green,
    },
    {
      "country": "সৌদি আরব",
      "city": "মদিনা",
      "lat": 24.5247,
      "lon": 39.5692,
      "flag": Colors.green,
    },

    // সংযুক্ত আরব আমিরাত
    {
      "country": "সংযুক্ত আরব আমিরাত",
      "city": "দুবাই",
      "lat": 25.2048,
      "lon": 55.2708,
      "flag": Colors.red,
    },
    {
      "country": "সংযুক্ত আরব আমিরাত",
      "city": "আবুধাবি",
      "lat": 24.4539,
      "lon": 54.3773,
      "flag": Colors.red,
    },
    {
      "country": "সংযুক্ত আরব আমিরাত",
      "city": "শারজাহ",
      "lat": 25.3463,
      "lon": 55.4209,
      "flag": Colors.red,
    },

    // কুয়েত
    {
      "country": "কুয়েত",
      "city": "কুয়েত সিটি",
      "lat": 29.3759,
      "lon": 47.9774,
      "flag": Colors.green,
    },
    {
      "country": "কুয়েত",
      "city": "আল-জাহরা",
      "lat": 29.3720,
      "lon": 47.9781,
      "flag": Colors.green,
    },
    {
      "country": "কুয়েত",
      "city": "হাওলি",
      "lat": 29.3378,
      "lon": 48.0173,
      "flag": Colors.green,
    },

    // কাতার
    {
      "country": "কাতার",
      "city": "দোহা",
      "lat": 25.2854,
      "lon": 51.5310,
      "flag": Colors.brown,
    },
    {
      "country": "কাতার",
      "city": "আল খোর",
      "lat": 25.6523,
      "lon": 51.5261,
      "flag": Colors.brown,
    },
    // ওমান
    {
      "country": "ওমান",
      "city": "মাস্কাট",
      "lat": 23.5859,
      "lon": 58.4059,
      "flag": Colors.green,
    },

    // বাহরাইন
    {
      "country": "বাহরাইন",
      "city": "মানামা",
      "lat": 26.2285,
      "lon": 50.5860,
      "flag": Colors.red,
    },

    // জর্ডান
    {
      "country": "জর্ডান",
      "city": "আম্মান",
      "lat": 31.9454,
      "lon": 35.9284,
      "flag": Colors.red,
    },

    // লেবানন
    {
      "country": "লেবানন",
      "city": "বেইরুট",
      "lat": 33.8938,
      "lon": 35.5018,
      "flag": Colors.red,
    },

    // ইতালি
    {
      "country": "ইতালি",
      "city": "রোম",
      "lat": 41.9028,
      "lon": 12.4964,
      "flag": Colors.green,
    },

    // গ্রিস
    {
      "country": "গ্রিস",
      "city": "এথেন্স",
      "lat": 37.9838,
      "lon": 23.7275,
      "flag": Colors.blue,
    },

    // দক্ষিণ কোরিয়া
    {
      "country": "দক্ষিণ কোরিয়া",
      "city": "সিউল",
      "lat": 37.5665,
      "lon": 126.9780,
      "flag": Colors.red,
    },

    // মালদ্বীপ
    {
      "country": "মালদ্বীপ",
      "city": "মালে",
      "lat": 4.1755,
      "lon": 73.5093,
      "flag": Colors.red,
    },

    // অন্যান্য দেশ
    {
      "country": "মালয়েশিয়া",
      "city": "কুয়ালালামপুর",
      "lat": 3.1390,
      "lon": 101.6869,
      "flag": Colors.red,
    },
    {
      "country": "যুক্তরাষ্ট্র",
      "city": "নিউ ইয়র্ক",
      "lat": 40.7128,
      "lon": -74.0060,
      "flag": Colors.blue,
    },
    {
      "country": "যুক্তরাষ্ট্র",
      "city": "লস অ্যাঞ্জেলেস",
      "lat": 34.0522,
      "lon": -118.2437,
      "flag": Colors.blue,
    },
    {
      "country": "যুক্তরাজ্য",
      "city": "লন্ডন",
      "lat": 51.5074,
      "lon": -0.1278,
      "flag": Colors.blue,
    },
    {
      "country": "কানাডা",
      "city": "টরন্টো",
      "lat": 43.6532,
      "lon": -79.3832,
      "flag": Colors.red,
    },
    {
      "country": "ভারত",
      "city": "মুম্বাই",
      "lat": 19.0760,
      "lon": 72.8777,
      "flag": Colors.orange,
    },
    {
      "country": "ভারত",
      "city": "দিল্লী",
      "lat": 28.6139,
      "lon": 77.2090,
      "flag": Colors.orange,
    },
    {
      "country": "পাকিস্তান",
      "city": "করাচি",
      "lat": 24.8607,
      "lon": 67.0011,
      "flag": Colors.green,
    },
    {
      "country": "তুরস্ক",
      "city": "ইস্তানবুল",
      "lat": 41.0082,
      "lon": 28.9784,
      "flag": Colors.red,
    },
    {
      "country": "ইন্দোনেশিয়া",
      "city": "জাকার্তা",
      "lat": -6.2088,
      "lon": 106.8456,
      "flag": Colors.red,
    },
    {
      "country": "সিঙ্গাপুর",
      "city": "সিঙ্গাপুর",
      "lat": 1.3521,
      "lon": 103.8198,
      "flag": Colors.red,
    },
    {
      "country": "জাপান",
      "city": "টোকিও",
      "lat": 35.6762,
      "lon": 139.6503,
      "flag": Colors.red,
    },
    {
      "country": "চীন",
      "city": "বেইজিং",
      "lat": 39.9042,
      "lon": 116.4074,
      "flag": Colors.red,
    },
    {
      "country": "অস্ট্রেলিয়া",
      "city": "সিডনি",
      "lat": -33.8688,
      "lon": 151.2093,
      "flag": Colors.blue,
    },
  ];

  // সার্চ করা লোকেশন ফিল্টার করা
  List<Map<String, dynamic>> get _filteredLocations {
    if (_searchQuery.isEmpty) {
      return _locations;
    }
    return _locations.where((location) {
      final country = location['country'].toString().toLowerCase();
      final city = location['city'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return country.contains(query) || city.contains(query);
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("লোকেশন পারমিশন প্রয়োজন")));
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("সেটিংস থেকে লোকেশন পারমিশন দিন")),
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
      String cityName = "বর্তমান অবস্থান";
      String countryName = "অজানা দেশ";

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
              "বর্তমান অবস্থান";
          countryName = placemark.country ?? "অজানা দেশ";

          // খুব দীর্ঘ নাম সংক্ষিপ্ত করুন
          if (cityName.length > 20) {
            cityName = cityName.substring(0, 20) + '...';
          }
        }
      } catch (e) {
        print("Geocoding error: $e");
        // জিওকোডিং ফেইল করলে ডিফল্ট ভ্যালু ব্যবহার করুন
        cityName = "বর্তমান অবস্থান";
        countryName = "অজানা দেশ";
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
      ).showSnackBar(SnackBar(content: Text("বর্তমান লোকেশন সেট করা হয়েছে")));
    } catch (e) {
      print("Location error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("লোকেশন পাওয়া যায়নি: ${e.toString()}")),
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
                            "দেশ ও শহর নির্বাচন করুন",
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
                              hintText: "দেশ বা শহর খুঁজুন...",
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
                            "${_filteredLocations.length}টি ফলাফল",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // দেশের লিস্ট
                  Expanded(
                    child: _filteredLocations.isEmpty
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
                                  "কোন ফলাফল পাওয়া যায়নি",
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
                                countryName: location['country'],
                                cityName: location['city'],
                                latitude: location['lat'],
                                longitude: location['lon'],
                                flagColor: location['flag'],
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
                        "বাতিল",
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
    required String countryName,
    required String cityName,
    required double latitude,
    required double longitude,
    required Color flagColor,
  }) {
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
              color: flagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: flagColor.withOpacity(0.3)),
            ),
            child: Icon(Icons.location_on, color: flagColor, size: 20),
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
            widget.onLocationModeChanged(
              'manual',
              latitude,
              longitude,
              cityName,
              countryName,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$cityName, $countryName সেট করা হয়েছে"),
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
            "লোকেশন পরিবর্তন করুন",
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
                "অটোমেটিক লোকেশন",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: widget.currentLocationMode == 'auto'
                      ? Colors.blue.shade800
                      : Theme.of(context).colorScheme.onBackground,
                ),
              ),
              subtitle: Text(
                "আপনার বর্তমান লোকেশন ব্যবহার করুন",
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
                    "লোকেশন ডিটেক্ট করা হচ্ছে...",
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
                "ম্যানুয়াল লোকেশন",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: widget.currentLocationMode == 'manual'
                      ? Colors.orange.shade800
                      : Theme.of(context).colorScheme.onBackground,
                ),
              ),
              subtitle: Text(
                "লিস্ট থেকে দেশ ও শহর নির্বাচন করুন",
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
                    "লোকেশন পরিবর্তন করলে নামাজের সময় স্বয়ংক্রিয়ভাবে আপডেট হবে",
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
                "বাতিল",
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
