// main.dart - CORRECTED VERSION
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/in_app_purchase_manager.dart';
import 'ad_helper.dart';
import 'managers/home_page.dart'; // ✅ সঠিক path

// Route Observer global ভাবে declare করুন - শুধু একবার
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Mobile Ads SDK ইনিশিয়ালাইজ করুন
  MobileAds.instance.initialize();

  try {
    await InAppPurchaseManager().initialize();
    await AdHelper.initialize();
  } catch (e) {
    print('Initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        if (languageProvider.currentLanguage.isEmpty) {
          return _buildLoadingScreen();
        }

        return MaterialApp(
          title: languageProvider.isEnglish
              ? 'Islamic Day - Global Bangladeshi'
              : 'ইসলামিক ডে - বৈশ্বিক বাংলাদেশী',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: _buildTheme(languageProvider.isEnglish, Brightness.light),
          darkTheme: _buildTheme(languageProvider.isEnglish, Brightness.dark),
          navigatorObservers: [routeObserver],
          // ✅ Route observer যোগ করুন
          home: SplashScreen(),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
              ),
              const SizedBox(height: 20),
              Text(
                'লোড হচ্ছে...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[800],
                  fontFamily: 'HindSiliguri',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme(bool isEnglish, Brightness brightness) {
    return ThemeData(
      primarySwatch: Colors.green,
      brightness: brightness,
      fontFamily: isEnglish ? 'Roboto' : 'HindSiliguri',
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.green[800],
        elevation: 4,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}
