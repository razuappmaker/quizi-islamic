import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'ad_helper.dart';
import '../providers/language_provider.dart';

class NadiyatulQuran extends StatefulWidget {
  const NadiyatulQuran({Key? key}) : super(key: key);

  @override
  State<NadiyatulQuran> createState() => _NadiyatulQuranState();
}

class _NadiyatulQuranState extends State<NadiyatulQuran> {
  BannerAd? _bannerAd;
  Map<String, int> _pdfPageCounts = {};
  bool _isBannerAdLoaded = false;
  bool _showEnglishWarning = true; // ✅ ইংরেজি ইউজারদের জন্য সতর্কবার্তা

  List<Map<String, String>> guides = [];

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _loadPdfGuides();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    languageProvider.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) {
      _loadPdfGuides();
    }
  }

  Future<void> _loadPdfGuides() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final isEnglish = languageProvider.isEnglish;

      final jsonFile = isEnglish
          ? 'assets/en_pdf_guides.json'
          : 'assets/pdf_guides.json';

      final String response = await DefaultAssetBundle.of(
        context,
      ).loadString(jsonFile);
      final List<dynamic> data = json.decode(response);

      if (mounted) {
        setState(() {
          guides = data
              .map<Map<String, String>>(
                (item) => {
                  "title": item['title'] ?? '',
                  "path": item['path'] ?? '',
                  "description": item['description'] ?? '',
                  "pages": item['pages'] ?? '0',
                  "duration": item['duration'] ?? '10-15 min',
                },
              )
              .toList();
        });
      }

      _loadPdfInfo();
    } catch (e) {
      print('Error loading PDF guides: $e');
      _setDefaultData();
    }
  }

  void _setDefaultData() {
    setState(() {
      guides = [
        {
          "title": "নাদিয়াতুল কোরআন",
          "path": "assets/pdf/nadiyatul_quran.pdf",
          "description": "সহজ কুরআন শিক্ষা",
          "pages": "32",
          "duration": "১০-১৫ মিনিট",
        },
        {
          "title": "ওমরাহ গাইড",
          "path": "assets/pdf/umrah_guide.pdf",
          "description": "ওমরাহ পালনের সম্পূর্ণ ধাপে ধাপে গাইড",
          "pages": "28",
          "duration": "১৫-২০ মিনিট",
        },
      ];
    });
  }

  Future<void> _initializeAds() async {
    try {
      await AdHelper.initialize();
      _loadBannerAd();
    } catch (e) {
      debugPrint('Failed to initialize ads: $e');
    }
  }

  void _loadBannerAd() async {
    final canShow = await AdHelper.canShowBannerAd();
    if (!canShow) return;

    try {
      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) async {
            print('Adaptive banner ad loaded successfully');
            await AdHelper.recordBannerAdShown();
            setState(() {
              _isBannerAdLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('Adaptive Banner Ad failed to load: $error');
            ad.dispose();
            setState(() {
              _isBannerAdLoaded = false;
            });
          },
          onAdClicked: (ad) {
            AdHelper.recordAdClick();
          },
        ),
      );
      _bannerAd!.load();
    } catch (e) {
      debugPrint('Error creating adaptive banner: $e');
      _isBannerAdLoaded = false;
    }
  }

  Future<void> _loadPdfInfo() async {
    for (var guide in guides) {
      try {
        _pdfPageCounts[guide["path"]!] = int.parse(guide["pages"] ?? "0");
      } catch (e) {
        print("Error loading PDF info for ${guide['path']}: $e");
        _pdfPageCounts[guide["path"]!] = 0;
      }
    }
    setState(() {});
  }

  // ✅ ইংরেজি ইউজারদের জন্য সতর্কবার্তা ডায়ালগ
  void _showEnglishWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[800]),
              const SizedBox(width: 8),
              const Text(
                "Important Information",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "These PDFs are available only in Bengali language. They have not been translated to English. The same PDF will be used for all language users.",
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showEnglishWarning = false;
                });
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    languageProvider.removeListener(_onLanguageChanged);
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

  Widget _buildAdaptiveBannerWidget(BannerAd banner) {
    return Container(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: banner),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.isEnglish;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          isEnglish ? 'Quran Learning' : 'কোরআন শিক্ষা',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ),
        actions: [
          // ✅ শুধুমাত্র ইংরেজি ইউজারদের জন্য এবং একবারের বেশি না দেখালে আইকন দেখান
          if (isEnglish && _showEnglishWarning)
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.yellow[700]),
              tooltip: "Important Information",
              onPressed: _showEnglishWarningDialog,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ✅ ইংরেজি ইউজারদের জন্য ব্যানার (শুধুমাত্র একবার দেখাবে)
            if (isEnglish && _showEnglishWarning)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[800],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "PDFs are in Bengali only. Tap for details.",
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.orange[700],
                      ),
                      onPressed: () {
                        setState(() {
                          _showEnglishWarning = false;
                        });
                      },
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: mediaQuery.padding.bottom,
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
                child: guides.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          ...List<Widget>.generate(guides.length, (index) {
                            final guide = guides[index];
                            return _buildPdfCard(
                              title: guide["title"]!,
                              path: guide["path"]!,
                              description: guide["description"]!,
                              pageCount: _pdfPageCounts[guide["path"]!] ?? 0,
                              duration: guide["duration"]!,
                              isDark: isDark,
                              isEnglish: isEnglish,
                            );
                          }),
                        ],
                      ),
              ),
            ),

            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                width: mediaQuery.size.width,
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                color: Colors.transparent,
                margin: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
                child: _buildAdaptiveBannerWidget(_bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfCard({
    required String title,
    required String path,
    required String description,
    required int pageCount,
    required String duration,
    required bool isDark,
    required bool isEnglish,
  }) {
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
                                      isEnglish ? "Preview" : "প্রিভিউ",
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

                            Row(
                              children: [
                                _buildInfoChip(
                                  icon: Icons.pages,
                                  text: isEnglish
                                      ? "$pageCount Pages"
                                      : "$pageCount পৃষ্ঠা",
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  icon: Icons.timer,
                                  text: duration,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

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
                                    isEnglish ? "Read PDF" : "পিডিএফ পড়ুন",
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
  bool _isBannerAdLoaded = false;
  int _currentPage = 1;
  int _totalPages = 32;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _initializePdf();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    languageProvider.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeAds() async {
    try {
      await AdHelper.initialize();
      _loadBannerAd();
    } catch (e) {
      debugPrint('Failed to initialize ads: $e');
    }
  }

  void _loadBannerAd() async {
    final canShow = await AdHelper.canShowBannerAd();
    if (!canShow) return;

    try {
      _bannerAd = await AdHelper.createAdaptiveBannerAdWithFallback(
        context,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) async {
            print('PDF Viewer Adaptive banner ad loaded successfully');
            await AdHelper.recordBannerAdShown();
            setState(() {
              _isBannerAdLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('PDF Viewer Adaptive Banner Ad failed to load: $error');
            ad.dispose();
            setState(() {
              _isBannerAdLoaded = false;
            });
          },
          onAdClicked: (ad) {
            AdHelper.recordAdClick();
          },
        ),
      );
      _bannerAd!.load();
    } catch (e) {
      debugPrint('Error creating PDF viewer adaptive banner: $e');
      _isBannerAdLoaded = false;
    }
  }

  void _initializePdf() {
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
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final isEnglish = languageProvider.isEnglish;

      final ByteData data = await rootBundle.load(widget.assetPath);
      final List<int> bytes = data.buffer.asUint8List();

      final Directory? downloadsDir = await getExternalStorageDirectory();

      if (downloadsDir == null) {
        throw Exception(
          isEnglish
              ? 'Download directory not found'
              : 'ডাউনলোড ডিরেক্টরি পাওয়া যায়নি',
        );
      }

      final String filePath = '${downloadsDir.path}/${widget.title}.pdf';
      final File file = File(filePath);

      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEnglish
                  ? "Download completed: ${widget.title}.pdf"
                  : "ডাউনলোড সম্পন্ন: ${widget.title}.pdf",
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: isEnglish ? "Open Folder" : "ফোল্ডার দেখুন",
              onPressed: () {
                _openDownloadsFolder(downloadsDir.path);
              },
            ),
          ),
        );
      }

      print('PDF downloaded: $filePath');
    } catch (e) {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final isEnglish = languageProvider.isEnglish;

      print('PDF download failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEnglish
                  ? "Download failed: ${e.toString()}"
                  : "ডাউনলোড ব্যর্থ: ${e.toString()}",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openDownloadsFolder(String path) async {
    try {
      final Directory downloadsDir = Directory(path);
      if (await downloadsDir.exists()) {
        print('Download folder: $path');
      }
    } catch (e) {
      print('Error opening folder: $e');
    }
  }

  Future<void> _sharePDF() async {
    try {
      final ByteData data = await rootBundle.load(widget.assetPath);
      final List<int> bytes = data.buffer.asUint8List();

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/${widget.title}.pdf';
      final File tempFile = File(tempPath);

      await tempFile.writeAsBytes(bytes, flush: true);

      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final isEnglish = languageProvider.isEnglish;

      await Share.shareXFiles(
        [XFile(tempPath)],
        text: isEnglish
            ? '${widget.title} - Islamic Guide'
            : '${widget.title} - ইসলামিক গাইড',
        subject: widget.title,
      );
    } catch (e) {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final isEnglish = languageProvider.isEnglish;

      print('PDF share failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEnglish
                  ? "Share failed: ${e.toString()}"
                  : "শেয়ার করতে ব্যর্থ: ${e.toString()}",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isEnglish = languageProvider.isEnglish;

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
              isEnglish ? "Reading Guide" : "পড়ার গাইড",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildGuideItem(
              "📖",
              isEnglish
                  ? "First, browse through the entire PDF once"
                  : "প্রথমে সম্পূর্ণ PDF টি একবার দেখে নিন",
            ),
            _buildGuideItem(
              "🔍",
              isEnglish
                  ? "Zoom in to see important parts"
                  : "জরুরি অংশগুলো জুম করে দেখুন",
            ),
            _buildGuideItem(
              "📑",
              isEnglish
                  ? "Use page navigation to move around easily"
                  : "পৃষ্ঠা নেভিগেশন ব্যবহার করে সহজে চলাফেরা করুন",
            ),
            _buildGuideItem(
              "💾",
              isEnglish ? "Download if needed" : "প্রয়োজনে ডাউনলোড করে নিন",
            ),
            _buildGuideItem(
              "📤",
              isEnglish ? "Share with others" : "অন্যদের সাথে শেয়ার করুন",
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isEnglish ? "Got it" : "বুঝেছি",
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

  void _showPageInputDialog() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isEnglish = languageProvider.isEnglish;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEnglish ? "Enter Page Number" : "পৃষ্ঠা নং লিখুন"),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: isEnglish
                ? "Enter between 1 and $_totalPages"
                : "১ থেকে $_totalPages এর মধ্যে লিখুন",
            border: const OutlineInputBorder(),
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
            child: Text(isEnglish ? "Cancel" : "বাতিল"),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveBannerWidget(BannerAd banner) {
    return Container(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: banner),
    );
  }

  @override
  void dispose() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    languageProvider.removeListener(_onLanguageChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.isEnglish;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outlined),
            tooltip: isEnglish ? "Reading Guide" : "পড়ার গাইড",
            onPressed: _showReadingGuide,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: isEnglish ? "Zoom In" : "জুম ইন",
            onPressed: () {
              setState(() {
                _zoomLevel += 0.2;
                _pdfController.zoomLevel = _zoomLevel;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: isEnglish ? "Zoom Out" : "জুম আউট",
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 3.0);
                _pdfController.zoomLevel = _zoomLevel;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPDF,
            tooltip: isEnglish ? "Download PDF" : "PDF ডাউনলোড করুন",
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePDF,
            tooltip: isEnglish ? "Share PDF" : "PDF শেয়ার করুন",
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    tooltip: isEnglish ? "First Page" : "প্রথম পৃষ্ঠা",
                    onPressed: () => _goToPage(1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_before),
                    tooltip: isEnglish ? "Previous Page" : "আগের পৃষ্ঠা",
                    onPressed: () => _goToPage(_currentPage - 1),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: _showPageInputDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isEnglish
                                ? "Page: $_currentPage/$_totalPages"
                                : "পৃষ্ঠা: $_currentPage/$_totalPages",
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
                    tooltip: isEnglish ? "Next Page" : "পরবর্তী পৃষ্ঠা",
                    onPressed: () => _goToPage(_currentPage + 1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.last_page),
                    tooltip: isEnglish ? "Last Page" : "শেষ পৃষ্ঠা",
                    onPressed: () => _goToPage(_totalPages),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
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
                                isEnglish
                                    ? "Loading PDF..."
                                    : "PDF লোড হচ্ছে...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                width: mediaQuery.size.width,
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                color: Colors.transparent,
                margin: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
                child: _buildAdaptiveBannerWidget(_bannerAd!),
              ),
          ],
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showPageInputDialog,
            backgroundColor: Colors.blue[700],
            mini: true,
            tooltip: isEnglish ? "Search Page" : "পৃষ্ঠা খুঁজুন",
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _showReadingGuide,
            backgroundColor: Colors.green[700],
            tooltip: isEnglish ? "Reading Guide" : "পড়ার গাইড",
            child: const Icon(Icons.help_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
