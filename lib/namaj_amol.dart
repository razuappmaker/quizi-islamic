import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'ad_helper.dart'; // ✅ আপনার ad_helper.dart ইমপোর্ট

class NamajAmol extends StatefulWidget {
  const NamajAmol({Key? key}) : super(key: key);

  @override
  State<NamajAmol> createState() => _NamajAmolState();
}

class _NamajAmolState extends State<NamajAmol> {
  BannerAd? _bannerAd;

  final List<Map<String, String>> guides = [
    {"title": "ওমরাহ গাইড", "path": "assets/pdf/umrah_guide.pdf"},
    {"title": "হজ্ব গাইড", "path": "assets/pdf/hajj_guide.pdf"},
    {"title": "নামাজ পরবর্তী আমল", "path": "assets/pdf/namaj_amol.pdf"},
    {"title": "নিয়মাবলী", "path": "assets/pdf/rules.pdf"},
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
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

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void openPdf(String title, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(title: title, assetPath: path),
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
          'ইসলামিক গাইড',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: guides.length,
              itemBuilder: (context, index) {
                final item = guides[index];
                return GestureDetector(
                  onTap: () => openPdf(item["title"]!, item["path"]!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green[900] : Colors.green[100],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 48,
                          color: isDark ? Colors.green[200] : Colors.green[800],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
}

// ✅ PDF Viewer Page
class PdfViewerPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const PdfViewerPage({Key? key, required this.title, required this.assetPath})
    : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final PdfViewerController _pdfController = PdfViewerController();
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
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

  Future<void> _downloadPDF() async {
    final bytes = await DefaultAssetBundle.of(context).load(widget.assetPath);
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/${widget.title}.pdf");
    await file.writeAsBytes(bytes.buffer.asUint8List());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Downloaded: ${file.path}")));
  }

  Future<void> _sharePDF() async {
    final bytes = await DefaultAssetBundle.of(context).load(widget.assetPath);
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/${widget.title}.pdf");
    await file.writeAsBytes(bytes.buffer.asUint8List());
    Share.shareXFiles([XFile(file.path)], text: widget.title);
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
            icon: const Icon(Icons.zoom_in),
            onPressed: () => _pdfController.zoomLevel += 0.5,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => _pdfController.zoomLevel -= 0.5,
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            tooltip: "Fit to Page",
            onPressed: () => _pdfController.zoomLevel = 1.0,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: "Fit to Width",
            onPressed: () => _pdfController.zoomLevel = 2.5,
          ),
          IconButton(icon: const Icon(Icons.download), onPressed: _downloadPDF),
          IconButton(icon: const Icon(Icons.share), onPressed: _sharePDF),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              child: SfPdfViewer.asset(
                widget.assetPath,
                controller: _pdfController,
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
}
