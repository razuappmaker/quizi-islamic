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

  void _selectManualLocation() {
    // বাংলাদেশের ডিফল্ট লোকেশন (ঢাকা)
    widget.onLocationModeChanged(
      'manual',
      23.8103,
      90.4125,
      "ঢাকা",
      "বাংলাদেশ",
    );
    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("ঢাকা, বাংলাদেশ সেট করা হয়েছে")));
  }

  //--------all country name adde here ----
  void _showManualLocationOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // গুরুত্বপূর্ণ: স্ক্রলিং সক্ষম করুন
      backgroundColor: Colors.transparent,
      builder: (context) {
        // ডিভাইসের স্ক্রিন সাইজ অনুযায়ী কন্টেইনার হাইট সেট করুন
        final screenHeight = MediaQuery.of(context).size.height;
        final containerHeight = screenHeight * 0.7; // স্ক্রিনের 70% হাইট নিন

        return Container(
          height: containerHeight, // ডায়নামিক হাইট
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ড্রাগ হ্যান্ডেল
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "দেশ নির্বাচন করুন",
                      style: TextStyle(
                        fontSize: screenHeight < 600 ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: screenHeight < 600 ? 20 : 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // সার্চ বার (যদি প্রয়োজন হয়)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "দেশ খুঁজুন...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey.shade600),
                    hintStyle: TextStyle(
                      fontSize: screenHeight < 600 ? 14 : 16,
                    ),
                  ),
                  style: TextStyle(fontSize: screenHeight < 600 ? 14 : 16),
                ),
              ),

              const SizedBox(height: 10),

              // দেশের লিস্ট - Expanded ব্যবহার করে স্ক্রলযোগ্য করা
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    // বাংলাদেশ
                    // বাংলাদেশ - ঢাকা
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "বাংলাদেশ",
                      cityName: "ঢাকা",
                      latitude: 23.8103,
                      longitude: 90.4125,
                      flagColor: Colors.green,
                    ),

                    // বাংলাদেশ - চট্টগ্রাম
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "বাংলাদেশ",
                      cityName: "চট্টগ্রাম",
                      latitude: 22.3569,
                      longitude: 91.7832,
                      flagColor: Colors.green,
                    ),

                    // বাংলাদেশ - খুলনা
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "বাংলাদেশ",
                      cityName: "খুলনা",
                      latitude: 22.8456,
                      longitude: 89.5403,
                      flagColor: Colors.green,
                    ),

                    // বাংলাদেশ - রাজশাহী
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "বাংলাদেশ",
                      cityName: "রাজশাহী",
                      latitude: 24.3745,
                      longitude: 88.6042,
                      flagColor: Colors.green,
                    ),

                    // বাংলাদেশ - সিলেট
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "বাংলাদেশ",
                      cityName: "সিলেট",
                      latitude: 24.8949,
                      longitude: 91.8687,
                      flagColor: Colors.green,
                    ),

                    // বাংলাদেশ - বরিশাল
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "বাংলাদেশ",
                      cityName: "বরিশাল",
                      latitude: 22.7010,
                      longitude: 90.3535,
                      flagColor: Colors.green,
                    ),

                    // বাংলাদেশ - রংপুর
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "বাংলাদেশ",
                      cityName: "রংপুর",
                      latitude: 25.7439,
                      longitude: 89.2752,
                      flagColor: Colors.green,
                    ),

                    // সৌদি আরব - রিয়াদ
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "সৌদি আরব",
                      cityName: "রিয়াদ",
                      latitude: 24.7136,
                      longitude: 46.6753,
                      flagColor: Colors.green,
                    ),

                    // সৌদি আরব - জেদ্দা
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "সৌদি আরব",
                      cityName: "জেদ্দা",
                      latitude: 21.4858,
                      longitude: 39.1925,
                      flagColor: Colors.green,
                    ),

                    // সংযুক্ত আরব আমিরাত - দুবাই
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "সংযুক্ত আরব আমিরাত",
                      cityName: "দুবাই",
                      latitude: 25.2048,
                      longitude: 55.2708,
                      flagColor: Colors.red,
                    ),

                    // সংযুক্ত আরব আমিরাত - আবুধাবি
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "সংযুক্ত আরব আমিরাত",
                      cityName: "আবুধাবি",
                      latitude: 24.4539,
                      longitude: 54.3773,
                      flagColor: Colors.red,
                    ),
                    // কুয়েত - কুয়েত সিটি
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কুয়েত",
                      cityName: "কুয়েত সিটি",
                      latitude: 29.3759,
                      longitude: 47.9774,
                      flagColor: Colors.green,
                    ),

                    // কুয়েত - আল-জাহরা
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কুয়েত",
                      cityName: "আল-জাহরা",
                      latitude: 29.3720,
                      longitude: 47.9781,
                      flagColor: Colors.green,
                    ),
                    // কুয়েত - হাওলি
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কুয়েত",
                      cityName: "হাওলি",
                      latitude: 29.3378,
                      longitude: 48.0173,
                      flagColor: Colors.green,
                    ),

                    // কুয়েত - ফাহাহিল
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কুয়েত",
                      cityName: "ফাহাহিল",
                      latitude: 29.2935,
                      longitude: 48.0587,
                      flagColor: Colors.green,
                    ),

                    // কুয়েত - সাবাহ আল-সালিম
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কুয়েত",
                      cityName: "সাবাহ আল-সালিম",
                      latitude: 29.3451,
                      longitude: 47.9756,
                      flagColor: Colors.green,
                    ),

                    // কুয়েত - আল-আহমেদী
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কুয়েত",
                      cityName: "আল-আহমেদী",
                      latitude: 29.3065,
                      longitude: 48.0825,
                      flagColor: Colors.green,
                    ),

                    // কাতার - দোহা
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কাতার",
                      cityName: "দোহা",
                      latitude: 25.2854,
                      longitude: 51.5310,
                      flagColor: Colors.brown,
                    ),

                    // কাতার - আল খোর
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কাতার",
                      cityName: "আল খোর",
                      latitude: 25.6523,
                      longitude: 51.5261,
                      flagColor: Colors.brown,
                    ),

                    // মালয়েশিয়া - কুয়ালালামপুর
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "মালয়েশিয়া",
                      cityName: "কুয়ালালামপুর",
                      latitude: 3.1390,
                      longitude: 101.6869,
                      flagColor: Colors.red,
                    ),

                    // মালয়েশিয়া - পেনাং
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "মালয়েশিয়া",
                      cityName: "পেনাং",
                      latitude: 5.4164,
                      longitude: 100.3327,
                      flagColor: Colors.red,
                    ),

                    // যুক্তরাষ্ট্র - নিউ ইয়র্ক
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "যুক্তরাষ্ট্র",
                      cityName: "নিউ ইয়র্ক",
                      latitude: 40.7128,
                      longitude: -74.0060,
                      flagColor: Colors.blue,
                    ),

                    // যুক্তরাষ্ট্র - লস অ্যাঞ্জেলেস
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "যুক্তরাষ্ট্র",
                      cityName: "লস অ্যাঞ্জেলেস",
                      latitude: 34.0522,
                      longitude: -118.2437,
                      flagColor: Colors.blue,
                    ),

                    // যুক্তরাজ্য - লন্ডন
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "যুক্তরাজ্য",
                      cityName: "লন্ডন",
                      latitude: 51.5074,
                      longitude: -0.1278,
                      flagColor: Colors.blue,
                    ),

                    // যুক্তরাজ্য - ম্যানচেস্টার
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "যুক্তরাজ্য",
                      cityName: "ম্যানচেস্টার",
                      latitude: 53.4808,
                      longitude: -2.2426,
                      flagColor: Colors.blue,
                    ),

                    // কানাডা - টরন্টো
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কানাডা",
                      cityName: "টরন্টো",
                      latitude: 43.6532,
                      longitude: -79.3832,
                      flagColor: Colors.red,
                    ),

                    // কানাডা - ভ্যাঙ্কুভার
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "কানাডা",
                      cityName: "ভ্যাঙ্কুভার",
                      latitude: 49.2827,
                      longitude: -123.1207,
                      flagColor: Colors.red,
                    ),
                    // ওমান - মাস্কাট
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "ওমান",
                      cityName: "মাস্কাট",
                      latitude: 23.5859,
                      longitude: 58.4059,
                      flagColor: Colors.red,
                    ),

                    // ওমান - সেলালাহ
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "ওমান",
                      cityName: "সেলালাহ",
                      latitude: 17.0194,
                      longitude: 54.0894,
                      flagColor: Colors.red,
                    ),

                    // বাহরাইন - মানামা
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "বাহরাইন",
                      cityName: "মানামা",
                      latitude: 26.2235,
                      longitude: 50.5876,
                      flagColor: Colors.red,
                    ),

                    // জর্ডান - আম্মান
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "জর্ডান",
                      cityName: "আম্মান",
                      latitude: 31.9454,
                      longitude: 35.9284,
                      flagColor: Colors.red,
                    ),

                    // লেবানন - বেইরুত
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "লেবানন",
                      cityName: "বেইরুত",
                      latitude: 33.8938,
                      longitude: 35.5018,
                      flagColor: Colors.red,
                    ),

                    // সিঙ্গাপুর - সিঙ্গাপুর
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "সিঙ্গাপুর",
                      cityName: "সিঙ্গাপুর",
                      latitude: 1.3521,
                      longitude: 103.8198,
                      flagColor: Colors.red,
                    ),

                    // থাইল্যান্ড - ব্যাংকক
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "থাইল্যান্ড",
                      cityName: "ব্যাংকক",
                      latitude: 13.7563,
                      longitude: 100.5018,
                      flagColor: Colors.red,
                    ),

                    // ভারত - মুম্বাই
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "ভারত",
                      cityName: "মুম্বাই",
                      latitude: 19.0760,
                      longitude: 72.8777,
                      flagColor: Colors.orange,
                    ),

                    // ভিয়েতনাম - হো চি মিন সিটি
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "ভিয়েতনাম",
                      cityName: "হো চি মিন সিটি",
                      latitude: 10.7769,
                      longitude: 106.7009,
                      flagColor: Colors.red,
                    ),

                    // মিশর - কায়রো
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "মিশর",
                      cityName: "কায়রো",
                      latitude: 30.0444,
                      longitude: 31.2357,
                      flagColor: Colors.red,
                    ),

                    // দক্ষিণ আফ্রিকা - জোহানেসবার্গ
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "দক্ষিণ আফ্রিকা",
                      cityName: "জোহানেসবার্গ",
                      latitude: -26.2041,
                      longitude: 28.0473,
                      flagColor: Colors.green,
                    ),

                    // ইতালি - রোম
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "ইতালি",
                      cityName: "রোম",
                      latitude: 41.9028,
                      longitude: 12.4964,
                      flagColor: Colors.green,
                    ),

                    // স্পেন - মাদ্রিদ
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "স্পেন",
                      cityName: "মাদ্রিদ",
                      latitude: 40.4168,
                      longitude: -3.7038,
                      flagColor: Colors.red,
                    ),

                    // নেদারল্যান্ডস - আমস্টারডাম
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "নেদারল্যান্ডস",
                      cityName: "আমস্টারডাম",
                      latitude: 52.3676,
                      longitude: 4.9041,
                      flagColor: Colors.red,
                    ),

                    // সুইডেন - স্টকহোম
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "সুইডেন",
                      cityName: "স্টকহোম",
                      latitude: 59.3293,
                      longitude: 18.0686,
                      flagColor: Colors.blue,
                    ),

                    // নরওয়ে - অসলো
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "নরওয়ে",
                      cityName: "ওসলো",
                      latitude: 59.9139,
                      longitude: 10.7522,
                      flagColor: Colors.red,
                    ),

                    // ডেনমার্ক - কোপেনহেগেন
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "ডেনমার্ক",
                      cityName: "কোপেনহেগেন",
                      latitude: 55.6761,
                      longitude: 12.5683,
                      flagColor: Colors.red,
                    ),

                    // ব্রাজিল - সাও পাওলো
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "ব্রাজিল",
                      cityName: "সাও পাওলো",
                      latitude: -23.5505,
                      longitude: -46.6333,
                      flagColor: Colors.green,
                    ),

                    // আর্জেন্টিনা - বুয়েন্স আয়রেস
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "আর্জেন্টিনা",
                      cityName: "বুয়েন্স আয়রেস",
                      latitude: -34.6037,
                      longitude: -58.3816,
                      flagColor: Colors.lightBlue,
                    ),

                    // মেক্সিকো - মেক্সিকো সিটি
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "মেক্সিকো",
                      cityName: "মেক্সিকো সিটি",
                      latitude: 19.4326,
                      longitude: -99.1332,
                      flagColor: Colors.green,
                    ),

                    // নিউজিল্যান্ড - ওয়েলিংটন
                    _buildCountryItem(
                      context: context,
                      screenHeight: screenHeight,
                      countryName: "নিউজিল্যান্ড",
                      cityName: "ওয়েলিংটন",
                      latitude: -41.2865,
                      longitude: 174.7762,
                      flagColor: Colors.black,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // বাতিল বাটন
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight < 600 ? 12 : 16,
                    ),
                  ),
                  child: Text(
                    "বাতিল",
                    style: TextStyle(fontSize: screenHeight < 600 ? 14 : 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // দেশের আইটেম বিল্ড করার জন্য হেল্পার মেথড
  Widget _buildCountryItem({
    required BuildContext context,
    required double screenHeight,
    required String countryName,
    required String cityName,
    required double latitude,
    required double longitude,
    required Color flagColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: ListTile(
        leading: Container(
          width: screenHeight < 600 ? 36 : 40,
          height: screenHeight < 600 ? 36 : 40,
          decoration: BoxDecoration(
            color: flagColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: flagColor.withOpacity(0.5)),
          ),
          child: Icon(
            Icons.flag,
            color: flagColor,
            size: screenHeight < 600 ? 18 : 20,
          ),
        ),
        title: Text(
          countryName,
          style: TextStyle(
            fontSize: screenHeight < 600 ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          cityName,
          style: TextStyle(
            fontSize: screenHeight < 600 ? 12 : 14,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
          size: screenHeight < 600 ? 20 : 24,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenHeight < 600 ? 8 : 12,
          vertical: screenHeight < 600 ? 4 : 8,
        ),
        minLeadingWidth: screenHeight < 600 ? 40 : 48,
        onTap: () {
          // প্রথমে বর্তমান মডাল বন্ধ করুন
          Navigator.pop(context);

          // তারপর মূল মডাল বন্ধ করুন এবং লোকেশন সেট করুন
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

          // মূল লোকেশন মডাল বন্ধ করুন
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

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
          ListTile(
            leading: Icon(Icons.my_location, color: Colors.blue),
            title: Text("অটোমেটিক (বর্তমান লোকেশন)"),
            subtitle: Text("আপনার বর্তমান লোকেশন ব্যবহার করুন"),
            trailing: widget.currentLocationMode == 'auto'
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: _isLoading ? null : _getCurrentLocation,
          ),

          if (_isLoading) ...[
            const SizedBox(height: 10),
            Center(child: CircularProgressIndicator()),
            const SizedBox(height: 10),
          ],

          // Divider
          Divider(height: 30),

          // Option 2: Manual Location
          ListTile(
            leading: Icon(Icons.map, color: Colors.orange),
            title: Text("মানুয়াল (দেশ নির্বাচন)"),
            subtitle: Text("লিস্ট থেকে দেশ নির্বাচন করুন"),
            trailing: widget.currentLocationMode == 'manual'
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: _showManualLocationOptions,
          ),

          const SizedBox(height: 20),

          // Information Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "লোকেশন পরিবর্তন করলে নামাজের সময় স্বয়ংক্রিয়ভাবে আপডেট হবে",
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("বাতিল"),
            ),
          ),
        ],
      ),
    );
  }
}
