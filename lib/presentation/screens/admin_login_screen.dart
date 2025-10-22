// screens/admin_login_screen.dart
import 'package:flutter/material.dart';
import '../../core/utils/admin_checker.dart'; // ✅ সঠিক import
import 'admin_recharge_screen.dart'; // ✅ AdminRechargeScreen import যোগ করুন

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  String _errorMessage = '';

  Future<void> _login() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'পাসওয়ার্ড দিন';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final isSuccess = await AdminChecker.loginAsAdmin(_passwordController.text);

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminRechargeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'ভুল পাসওয়ার্ড!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'এডমিন লগিন',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'শুধুমাত্র অথোরাইজড personnel',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Login Form
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: 'এডমিন পাসওয়ার্ড',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _login(),
                        ),

                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'লগিন করুন',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('ব্যাক টু হোম'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Security Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.security, color: Colors.orange, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'সিকিউরিটি নোটিশ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'এই প্যানেল শুধুমাত্র অথোরাইজড personnel-এর জন্য।未经授权的访问禁止。',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
