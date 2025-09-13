import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'json_loader.dart'; // আপনার JsonLoader ক্লাস ইম্পোর্ট করুন

class NamajAmol extends StatefulWidget {
  const NamajAmol({Key? key}) : super(key: key);

  @override
  State<NamajAmol> createState() => _NamajAmolState();
}

class _NamajAmolState extends State<NamajAmol>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> dailySuras = []; // খালি লিস্ট দিয়ে শুরু করুন
  bool _isLoading = true; // লোডিং স্টেট ট্র্যাক করার জন্য

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadJsonData(); // JSON ডেটা লোড করার মেথড কল করুন
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  // JSON ডেটা লোড করার মেথড
  Future<void> _loadJsonData() async {
    try {
      final loadedData = await JsonLoader.loadJsonList(
        'assets/namaj_amol.json',
      );

      // List<dynamic> কে List<Map<String, dynamic>> এ কনভার্ট করুন
      final List<Map<String, dynamic>> convertedData = loadedData
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();

      setState(() {
        dailySuras = convertedData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading JSON data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  Widget buildSura(Map<String, dynamic> sura, int index) {
    final bool isExpanded = expandedIndex == index;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.04;
    final double titleFont = screenWidth * 0.05;
    final double arabicFont = screenWidth * 0.07;
    final double transliterationFont = screenWidth * 0.05;
    final double meaningFont = screenWidth * 0.045;
    final double referenceFont = screenWidth * 0.035;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: horizontalPadding),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          children: [
            ListTile(
              tileColor: isExpanded ? Colors.green[200] : Colors.green[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                sura['title'] ?? '',
                style: TextStyle(
                  fontSize: titleFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.black54,
                size: screenWidth * 0.06,
              ),
              onTap: () {
                setState(() {
                  expandedIndex = isExpanded ? null : index;
                });
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: isExpanded
                  ? Padding(
                      key: ValueKey('expanded_$index'),
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...List<Widget>.from(
                            (sura['ayat'] as List<dynamic>).map(
                              (ay) => Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: SelectableText(
                                      ay['arabic'] ?? '',
                                      style: TextStyle(
                                        fontSize: arabicFont,
                                        fontFamily: 'Amiri',
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.015),
                                  Text(
                                    ay['transliteration'] ?? '',
                                    style: TextStyle(
                                      fontSize: transliterationFont,
                                      fontStyle: FontStyle.italic,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.green[200]
                                          : Colors.green[900],
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(height: screenWidth * 0.015),
                                  Text(
                                    'অর্থ: ${ay['meaning'] ?? ''}',
                                    style: TextStyle(
                                      fontSize: meaningFont,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[300]
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(height: screenWidth * 0.03),
                                ],
                              ),
                            ),
                          ),
                          if ((sura['reference'] ?? '').isNotEmpty)
                            Text(
                              'নোটঃ ${sura['reference']}',
                              style: TextStyle(
                                fontSize: referenceFont,
                                fontStyle: FontStyle.italic,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.deepPurple,
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'ফরজ নামাজ পরবর্তী জিকির',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: dailySuras.length,
                    itemBuilder: (context, index) =>
                        buildSura(dailySuras[index], index),
                  ),
          ),
          if (_isBannerAdReady)
            SafeArea(
              child: SizedBox(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
      ),
    );
  }
}
