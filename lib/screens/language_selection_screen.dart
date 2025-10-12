import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final VoidCallback onLanguageSelected;

  const LanguageSelectionScreen({super.key, required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // আইকন বা লোগো
                Icon(Icons.language, size: 80, color: Colors.green[800]),
                const SizedBox(height: 32),

                // টাইটেল
                Text(
                  'ভাষা নির্বাচন করুন / Select Language',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                    fontFamily: 'HindSiliguri',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  'অনুগ্রহ করে আপনার পছন্দের ভাষা নির্বাচন করুন\nPlease select your preferred language',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                    fontFamily: 'HindSiliguri',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // বাংলা বাটন
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectLanguage(context, 'bn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'বাংলা',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HindSiliguri',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ইংরেজি বাটন
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectLanguage(context, 'en'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.green[800]!),
                      ),
                    ),
                    child: const Text(
                      'English',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectLanguage(
    BuildContext context,
    String languageCode,
  ) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    try {
      await languageProvider.setLanguage(languageCode);
      onLanguageSelected();
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageCode == 'bn'
                ? 'ভাষা সেট করতে সমস্যা হয়েছে'
                : 'Failed to set language',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
