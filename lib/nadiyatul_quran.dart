// Nadiyatul Quaran
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'ad_helper.dart';

class NadiyatulQuran extends StatefulWidget {
  const NadiyatulQuran({Key? key}) : super(key: key);

  @override
  State<NadiyatulQuran> createState() => _NadiyatulQuranState();
}

class _NadiyatulQuranState extends State<NadiyatulQuran> {
  BannerAd? _bannerAd;
  Map<String, int> _pdfPageCounts = {};

  final List<Map<String, String>> guides = [
    {
      "title": "নামাজ পরবর্তী আমল",
      "path": "assets/pdf/nadiyatul_quran.pdf",
      "description": "নামাজের পর পড়ার গুরুত্বপূর্ণ দোয়া ও আমলসমূহ",
    },
    {
      "title": "ওমরাহ গাইড",
      "path": "assets/pdf/umrah_guide.pdf",
      "description": "ওমরাহ পালনের সম্পূর্ণ ধাপে ধাপে গাইড",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadPdfInfo();
  }

  void _loadBannerAd() async {
    final canShow = await AdHelper.canShowBannerAd();
    if (canShow) {
      _bannerAd = AdHelper.createBannerAd(
        AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) async {
            await AdHelper.recordBannerAdShown();
            setState(() {});
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      )..load();
    }
  }

  Future<void> _loadPdfInfo() async {
    for (var guide in guides) {
      try {
        // PDF পৃষ্ঠা সংখ্যা লোড করার সিমুলেশন
        _pdfPageCounts[guide["path"]!] =
            32; // ধরে নিচ্ছি প্রতিটি PDF-এ ১২ পৃষ্ঠা আছে
      } catch (e) {
        print("Error loading PDF info for ${guide['path']}: $e");
        _pdfPageCounts[guide["path"]!] = 0;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void openPdf(String title, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdvancedPdfViewerPage(title: title, assetPath: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'কোরআন শিক্ষা',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildPdfCard(
                    title: "নামাজ পরবর্তী আমল",
                    path: "assets/pdf/nadiyatul_quran.pdf",
                    description: "নামাজের পর পড়ার গুরুত্বপূর্ণ দোয়া ও আমলসমূহ",
                    pageCount:
                        _pdfPageCounts["assets/pdf/nadiyatul_quran.pdf"] ?? 0,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildPdfCard(
                    title: "ওমরাহ গাইড",
                    path: "assets/pdf/umrah_guide.pdf",
                    description: "ওমরাহ পালনের সম্পূর্ণ ধাপে ধাপে গাইড",
                    pageCount:
                        _pdfPageCounts["assets/pdf/umrah_guide.pdf"] ?? 0,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          if (_bannerAd != null)
            SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfCard({
    required String title,
    required String path,
    required String description,
    required int pageCount,
    required bool isDark,
  }) {
    // ছবির পাথ ম্যাপিং
    String imagePath = "";
    if (path == "assets/pdf/nadiyatul_quran.pdf") {
      imagePath = "assets/images/nadiyatul_quran_preview.png";
    } else if (path == "assets/pdf/umrah_guide.pdf") {
      imagePath = "assets/images/umrah_guide_preview.png";
    }

    return Card(
      elevation: 6,
      shadowColor: Colors.green.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.green[900]!, Colors.green[800]!]
                : [Colors.white, Colors.green[50]!],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => openPdf(title, path),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ছবি প্রিভিউ সেকশন
                      Container(
                        width: 100,
                        height: 140,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.green[800] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isDark
                                ? Colors.green[600]!
                                : Colors.green[200]!,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            width: 100,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // যদি ছবি লোড না হয় তাহলে ডিফল্ট ভিউ দেখাবে
                              return Container(
                                color: isDark
                                    ? Colors.green[800]
                                    : Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.article,
                                      size: 40,
                                      color: isDark
                                          ? Colors.green[200]
                                          : Colors.green[600],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "প্রিভিউ",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? Colors.green[300]
                                            : Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // কন্টেন্ট সেকশন
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.green[900],
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.green[200]
                                    : Colors.green[700],
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // PDF তথ্য
                            Row(
                              children: [
                                _buildInfoChip(
                                  icon: Icons.pages,
                                  text: "$pageCount পৃষ্ঠা",
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  icon: Icons.timer,
                                  text: "১০-১৫ মিনিট",
                                  isDark: isDark,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // অ্যাকশন বাটন
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green[600]!,
                                    Colors.green[700]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "পিডিএফ পড়ুন",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.green[800]!.withOpacity(0.5)
            : Colors.green[100]!,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? Colors.green[200] : Colors.green[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.green[200] : Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}

// উন্নত PDF ভিউয়ার পেজ
class AdvancedPdfViewerPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const AdvancedPdfViewerPage({
    Key? key,
    required this.title,
    required this.assetPath,
  }) : super(key: key);

  @override
  State<AdvancedPdfViewerPage> createState() => _AdvancedPdfViewerPageState();
}

class _AdvancedPdfViewerPageState extends State<AdvancedPdfViewerPage> {
  final PdfViewerController _pdfController = PdfViewerController();
  BannerAd? _bannerAd;
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 32; // ডিফল্ট হিসেবে 12 ধরে নিচ্ছি
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _initializePdf();
  }

  void _loadBannerAd() async {
    final canShow = await AdHelper.canShowBannerAd();
    if (canShow) {
      _bannerAd = AdHelper.createBannerAd(
        AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) async {
            await AdHelper.recordBannerAdShown();
            setState(() {});
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      )..load();
    }
  }

  void _initializePdf() {
    // PDF লোড হওয়ার পর কলব্যাক
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  Future<void> _downloadPDF() async {
    try {
      final bytes = await DefaultAssetBundle.of(context).load(widget.assetPath);
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/${widget.title}.pdf");
      await file.writeAsBytes(bytes.buffer.asUint8List());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ডাউনলোড সম্পন্ন: ${widget.title}"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ডাউনলোড ব্যর্থ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sharePDF() async {
    try {
      final bytes = await DefaultAssetBundle.of(context).load(widget.assetPath);
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/${widget.title}.pdf");
      await file.writeAsBytes(bytes.buffer.asUint8List());
      Share.shareXFiles([XFile(file.path)], text: widget.title);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("শেয়ার করতে ব্যর্থ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToPage(int pageNumber) {
    if (pageNumber >= 1 && pageNumber <= _totalPages) {
      _pdfController.jumpToPage(pageNumber);
      setState(() {
        _currentPage = pageNumber;
      });
    }
  }

  void _showReadingGuide() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "পড়ার গাইড",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildGuideItem("📖", "প্রথমে সম্পূর্ণ PDF টি একবার দেখে নিন"),
            _buildGuideItem("🔍", "জরুরি অংশগুলো জুম করে দেখুন"),
            _buildGuideItem(
              "📑",
              "পৃষ্ঠা নেভিগেশন ব্যবহার করে সহজে চলাফেরা করুন",
            ),
            _buildGuideItem("💾", "প্রয়োজনে ডাউনলোড করে নিন"),
            _buildGuideItem("📤", "অন্যদের সাথে শেয়ার করুন"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "বুঝেছি",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // পৃষ্ঠা সংখ্যা ইনপুট ডায়ালগ
  void _showPageInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("পৃষ্ঠা নং লিখুন"),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "১ থেকে $_totalPages এর মধ্যে লিখুন",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final page = int.tryParse(value);
            if (page != null && page >= 1 && page <= _totalPages) {
              _goToPage(page);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("বাতিল"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outlined),
            tooltip: "পড়ার গাইড",
            onPressed: _showReadingGuide,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _zoomLevel += 0.2;
                _pdfController.zoomLevel = _zoomLevel;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 3.0);
                _pdfController.zoomLevel = _zoomLevel;
              });
            },
          ),
          IconButton(icon: const Icon(Icons.download), onPressed: _downloadPDF),
          IconButton(icon: const Icon(Icons.share), onPressed: _sharePDF),
        ],
      ),
      body: Column(
        children: [
          // PDF নেভিগেশন কন্ট্রোল
          Container(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: () => _goToPage(1),
                ),
                IconButton(
                  icon: const Icon(Icons.navigate_before),
                  onPressed: () => _goToPage(_currentPage - 1),
                ),

                // পৃষ্ঠা ইনডিকেটর - ট্যাপ করলে ডায়ালগ খুলবে
                Expanded(
                  child: GestureDetector(
                    onTap: _showPageInputDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "পৃষ্ঠা: $_currentPage/$_totalPages",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.navigate_next),
                  onPressed: () => _goToPage(_currentPage + 1),
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: () => _goToPage(_totalPages),
                ),
              ],
            ),
          ),

          // PDF ভিউয়ার
          Expanded(
            child: Stack(
              children: [
                SfPdfViewer.asset(
                  widget.assetPath,
                  controller: _pdfController,
                  onPageChanged: (PdfPageChangedDetails details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                    });
                  },
                ),

                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green[700]!,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "PDF লোড হচ্ছে...",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (_bannerAd != null)
            SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),

      // ফ্লোটিং অ্যাকশন বাটন
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showPageInputDialog,
            backgroundColor: Colors.blue[700],
            mini: true,
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _showReadingGuide,
            backgroundColor: Colors.green[700],
            child: const Icon(Icons.help_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
