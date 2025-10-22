import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../../../core/constants/ad_helper.dart';
import '../../providers/language_provider.dart';
import '../../../core/constants/app_colors.dart';

class NadiyatulQuran extends StatefulWidget {
  const NadiyatulQuran({Key? key}) : super(key: key);

  @override
  State<NadiyatulQuran> createState() => _NadiyatulQuranState();
}

class _NadiyatulQuranState extends State<NadiyatulQuran> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _showEnglishWarning = true;

  // ✅ সরাসরি গাইডস ডেটা সেট করা
  List<Map<String, String>> guides = [
    {
      "title": "নাদিয়াতুল কোরআন",
      "path": "assets/pdf/nadiyatul_quran.pdf",
      "description": "সহজ কুরআন শিক্ষা",
      "pages": "32",
      "duration": "২৫-৩০ দিন",
    },
    {
      "title": "ওমরাহ গাইড",
      "path": "assets/pdf/umrah_guide.pdf",
      "description": "ওমরাহ পালনের সম্পূর্ণ ধাপে ধাপে গাইড",
      "pages": "2",
      "duration": "১০-১৫ মিনিট",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAds();
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
            await AdHelper.recordBannerAdShown();
            setState(() => _isBannerAdLoaded = true);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('Adaptive Banner Ad failed to load: $error');
            ad.dispose();
            setState(() => _isBannerAdLoaded = false);
          },
          onAdClicked: (ad) => AdHelper.recordAdClick(),
        ),
      );
      _bannerAd!.load();
    } catch (e) {
      debugPrint('Error creating adaptive banner: $e');
      _isBannerAdLoaded = false;
    }
  }

  void _showEnglishWarningDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.getAccentColor('orange', isDark),
            ),
            const SizedBox(width: 8),
            Text(
              "Important Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDark),
              ),
            ),
          ],
        ),
        content: Text(
          "These PDFs are available only in Bengali language. They have not been translated to English. The same PDF will be used for all language users.",
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _showEnglishWarning = false);
            },
            child: Text(
              "OK",
              style: TextStyle(color: AppColors.getPrimaryColor(isDark)),
            ),
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

  void openPdf(String title, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CleanPdfViewerPage(title: title, assetPath: path),
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
        backgroundColor: AppColors.getAppBarColor(isDark),
        title: Text(
          isEnglish ? 'Quran Learning' : 'কোরআন শিক্ষা',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ),
        actions: [
          if (isEnglish && _showEnglishWarning)
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.white),
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
            if (isEnglish && _showEnglishWarning)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getAccentColor(
                    'orange',
                    isDark,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.getAccentColor(
                      'orange',
                      isDark,
                    ).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.getAccentColor('orange', isDark),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "PDFs are in Bengali only. Tap for details.",
                        style: TextStyle(
                          color: AppColors.getAccentColor('orange', isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.getAccentColor('orange', isDark),
                      ),
                      onPressed: () =>
                          setState(() => _showEnglishWarning = false),
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
                child: ListView(
                  children: guides
                      .map(
                        (guide) => _buildPdfCard(
                          title: guide["title"]!,
                          path: guide["path"]!,
                          description: guide["description"]!,
                          pageCount: int.parse(guide["pages"]!),
                          // ✅ সরাসরি pages parse করা
                          duration: guide["duration"]!,
                          isDark: isDark,
                          isEnglish: isEnglish,
                        ),
                      )
                      .toList(),
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
      elevation: 4,
      shadowColor: AppColors.getPrimaryColor(isDark).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.getBorderColor(isDark).withOpacity(0.2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => openPdf(title, path),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.getBorderColor(isDark),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        width: 80,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.getSurfaceColor(isDark),
                          child: Icon(
                            Icons.picture_as_pdf,
                            size: 30,
                            color: AppColors.getPrimaryColor(isDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextColor(isDark),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.getTextSecondaryColor(isDark),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildInfoChip(
                              icon: Icons.pages,
                              text:
                                  "$pageCount ${isEnglish ? 'Pages' : 'পৃষ্ঠা'}",
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
                      ],
                    ),
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
        color: AppColors.getPrimaryColor(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.getPrimaryColor(isDark)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.getPrimaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class CleanPdfViewerPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const CleanPdfViewerPage({
    Key? key,
    required this.title,
    required this.assetPath,
  }) : super(key: key);

  @override
  State<CleanPdfViewerPage> createState() => _CleanPdfViewerPageState();
}

class _CleanPdfViewerPageState extends State<CleanPdfViewerPage> {
  final PdfViewerController _pdfController = PdfViewerController();
  BannerAd? _bannerAd;
  bool _isLoading = true;
  bool _isBannerAdLoaded = false;
  int _currentPage = 1;
  int _totalPages = 32;
  bool _showPageNav = false;

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _initializePdf();
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
            await AdHelper.recordBannerAdShown();
            setState(() => _isBannerAdLoaded = true);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            setState(() => _isBannerAdLoaded = false);
          },
          onAdClicked: (ad) => AdHelper.recordAdClick(),
        ),
      );
      _bannerAd!.load();
    } catch (e) {
      _isBannerAdLoaded = false;
    }
  }

  void _initializePdf() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => _isLoading = false);
      });
    });
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
      );
    } catch (e) {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final isEnglish = languageProvider.isEnglish;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEnglish ? "Share failed" : "শেয়ার করতে ব্যর্থ"),
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
      setState(() => _currentPage = pageNumber);
    }
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
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.getAppBarColor(isDark),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _sharePDF,
            tooltip: "Share PDF",
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (_showPageNav)
              Container(
                margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(isDark).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        size: 20,
                        color: AppColors.getPrimaryColor(isDark),
                      ),
                      onPressed: () => _goToPage(_currentPage - 1),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 36),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getCardColor(isDark),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "$_currentPage / $_totalPages",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(isDark),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppColors.getPrimaryColor(isDark),
                      ),
                      onPressed: () => _goToPage(_currentPage + 1),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 36),
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
                        setState(() => _currentPage = details.newPageNumber);
                      },
                      onTap: (PdfGestureDetails details) {
                        setState(() => _showPageNav = !_showPageNav);
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
                                  AppColors.getPrimaryColor(isDark),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Loading PDF...",
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
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => setState(() => _showPageNav = !_showPageNav),
        backgroundColor: AppColors.getPrimaryColor(isDark),
        child: Icon(
          _showPageNav ? Icons.close : Icons.navigation,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
