// lib/utils/data_deletion_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:islamicquiz/providers/language_provider.dart';
import 'package:islamicquiz/utils/point_manager.dart';

class DataDeletionManager {
  // Delete All Data Dialog Show করার মেথড
  static void showDeleteDataDialog(BuildContext context) {
    // প্রথমে drawer বন্ধ করুন
    Navigator.pop(context);

    // LanguageProvider access
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    // তারপর dialog show করুন
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text(
                languageProvider.isEnglish
                    ? 'Delete All Data'
                    : 'সব তথ্য মুছুন',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languageProvider.isEnglish
                    ? '⚠️ Important Information:'
                    : '⚠️ গুরুত্বপূর্ণ তথ্য:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              SizedBox(height: 12),
              Text(
                languageProvider.isEnglish
                    ? '• This app does NOT collect or store your personal data (name, mobile number, etc.)\n'
                          '• All data is stored locally on your device only\n'
                          '• Uninstalling the app will permanently delete:\n'
                          '  - All your points and rewards\n'
                          '  - Quiz progress and history\n'
                          '  - Profile information\n'
                          '  - Premium features (if any)'
                    : '• এই অ্যাপটি আপনার ব্যক্তিগত তথ্য (নাম, মোবাইল নম্বর ইত্যাদি) সংগ্রহ বা সংরক্ষণ করে না\n'
                          '• সমস্ত ডাটা শুধুমাত্র আপনার ডিভাইসে স্থানীয়ভাবে সংরক্ষিত হয়\n'
                          '• অ্যাপ আনইনস্টল করলে স্থায়ীভাবে মুছে যাবে:\n'
                          '  - আপনার সকল পয়েন্ট ও রিওয়ার্ড\n'
                          '  - কুইজ প্রোগ্রেস ও হিস্ট্রি\n'
                          '  - প্রোফাইল তথ্য\n'
                          '  - প্রিমিয়াম ফিচার (যদি থাকে)',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              SizedBox(height: 16),
              Text(
                languageProvider.isEnglish
                    ? 'Do you want to delete ALL data now?'
                    : 'আপনি কি এখনই সকল ডাটা মুছতে চান?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                languageProvider.isEnglish ? 'Cancel' : 'বাতিল',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),

            // Delete Button
            ElevatedButton(
              onPressed: () async {
                await _deleteAllUserData(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                languageProvider.isEnglish ? 'Delete All' : 'সব মুছুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // সকল ইউজার ডাটা ডিলিট করার মেথড
  static Future<void> _deleteAllUserData(BuildContext context) async {
    try {
      // Dialog বন্ধ করুন
      Navigator.of(context).pop();

      // LanguageProvider access
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );

      // Loading dialog show করুন
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.red),
                SizedBox(height: 16),
                Text(
                  languageProvider.isEnglish
                      ? 'Deleting all data...'
                      : 'সকল ডাটা মুছছে...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      );

      // PointManager দিয়ে সকল ডাটা রিসেট করুন
      await PointManager.completeReset();

      // Loading dialog বন্ধ করুন
      Navigator.of(context).pop();

      // Success message show করুন
      _showSuccessMessage(context);
    } catch (e) {
      // Error হলে loading dialog বন্ধ করুন
      Navigator.of(context).pop();

      // Error message show করুন
      _showErrorMessage(context, e.toString());
    }
  }

  // Success message show করার মেথড
  static void _showSuccessMessage(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                languageProvider.isEnglish ? 'Success' : 'সফল',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: Text(
            languageProvider.isEnglish
                ? 'All data has been successfully deleted.'
                : 'সকল ডাটা সফলভাবে মুছে ফেলা হয়েছে।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                languageProvider.isEnglish ? 'OK' : 'ঠিক আছে',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Error message show করার মেথড
  static void _showErrorMessage(BuildContext context, String error) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                languageProvider.isEnglish ? 'Error' : 'ত্রুটি',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            languageProvider.isEnglish
                ? 'Failed to delete data: $error'
                : 'ডাটা মুছতে ব্যর্থ: $error',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.isEnglish ? 'OK' : 'ঠিক আছে'),
            ),
          ],
        );
      },
    );
  }
}
