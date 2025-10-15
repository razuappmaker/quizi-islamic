// screens/language_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../providers/language_provider.dart';
import '../managers/home_page.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await AwesomeNotifications().initialize(null, [
        NotificationChannel(
          channelKey: 'prayer_times_channel',
          channelName: 'Prayer Times Notifications',
          channelDescription: 'Notifications for prayer times',
          defaultColor: Colors.green,
          ledColor: Colors.green,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),
      ]);
    } catch (e) {
      print('Notification initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.green[100],
                child: const CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
              ),
              const SizedBox(height: 40),

              // Title Section
              Text(
                'ভাষা নির্বাচন করুন / Choose Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'আপনি কোন ভাষায় অ্যাপটি ব্যবহার করতে চান?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.green[700]),
              ),
              Text(
                'Which language would you like to use the app in?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),

              // Language Buttons
              _buildLanguageButton(
                language: 'বাংলা',
                flag: '🇧🇩',
                description: 'Bangla',
                languageCode: 'bn',
              ),
              const SizedBox(height: 20),
              _buildLanguageButton(
                language: 'English',
                flag: '🇺🇸',
                description: 'English',
                languageCode: 'en',
              ),
              const SizedBox(height: 30),

              if (_isLoading)
                Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green[700]!,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'সেটআপ হচ্ছে... / Setting up...',
                      style: TextStyle(color: Colors.green[800], fontSize: 14),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required String language,
    required String flag,
    required String description,
    required String languageCode,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.green[300],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[300]!, width: 2),
        ),
        child: ListTile(
          leading: Text(flag, style: const TextStyle(fontSize: 28)),
          title: Text(
            language,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green[900],
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.green[700]),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.green[700],
            size: 16,
          ),
          onTap: () => _onLanguageSelected(languageCode),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _onLanguageSelected(String languageCode) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );

      // Save language preference
      await languageProvider.setLanguage(languageCode);

      // Request permissions
      await _requestPermissions(languageCode);

      // Navigate to home page
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print('Language selection error: $e');
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(languageCode);
      }
    }
  }

  Future<void> _requestPermissions(String languageCode) async {
    try {
      final isEnglish = languageCode == 'en';

      // Location Permission
      final locationStatus = await Geolocator.requestPermission();
      print('Location Permission Status: $locationStatus');

      // Notification Permission
      final notificationPermission = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
      print('Notification Permission Result: $notificationPermission');

      // Optional: Show info if permissions are denied
      if ((locationStatus == LocationPermission.denied ||
              locationStatus == LocationPermission.deniedForever) &&
          context.mounted) {
        _showPermissionInfo(
          isEnglish
              ? "📍 Location access is recommended for accurate prayer times. You can enable it later in app settings."
              : "📍 সঠিক নামাজের সময়ের জন্য লোকেশন এক্সেস সুপারিশকৃত। আপনি পরে অ্যাপ সেটিংসে এটি সক্ষম করতে পারবেন।",
        );
      }
    } catch (e) {
      print('Permission request error: $e');
    }
  }

  void _showPermissionInfo(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.blue[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  void _showErrorDialog(String languageCode) {
    final isEnglish = languageCode == 'en';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEnglish ? 'Error' : 'ত্রুটি',
          style: TextStyle(color: Colors.red[700]),
        ),
        content: Text(
          isEnglish
              ? 'Failed to save language preference. Please try again.'
              : 'ভাষা পছন্দ সংরক্ষণ করতে ব্যর্থ হয়েছে। দয়া করে আবার চেষ্টা করুন।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isEnglish ? 'OK' : 'ঠিক আছে'),
          ),
        ],
      ),
    );
  }
}
