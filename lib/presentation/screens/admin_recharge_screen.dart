// Admin Recherche screen

import 'package:flutter/material.dart';
import 'package:islamicquiz/core/utils/admin_checker.dart'; // ✅ সঠিক import
import 'package:islamicquiz/core/managers/point_manager.dart';
import 'package:islamicquiz/presentation/screens/admin_login_screen.dart';

class AdminRechargeScreen extends StatefulWidget {
  const AdminRechargeScreen({Key? key}) : super(key: key);

  @override
  State<AdminRechargeScreen> createState() => _AdminRechargeScreenState();
}

class _AdminRechargeScreenState extends State<AdminRechargeScreen> {
  List<Map<String, dynamic>> _rechargeRequests = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await AdminChecker.isAdmin();
      setState(() {
        _isAdmin = isAdmin;
      });

      if (_isAdmin) {
        _loadRechargeRequests();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Admin status check error: $e");
      setState(() {
        _isLoading = false;
        _isAdmin = false;
      });
    }
  }

  Future<void> _loadRechargeRequests() async {
    try {
      final requests = await PointManager.getGiftHistory();
      setState(() {
        _rechargeRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      print("গিফট রিকোয়েস্ট লোড করতে ত্রুটি: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logoutAdmin() async {
    await AdminChecker.logoutAdmin();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  // 🔥 যদি ইউজার এডমিন না হয়, লগিন প্রম্পট দেখাবে
  Widget _buildAdminLoginPrompt() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('এক্সেস ডিনাইড'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'এক্সেস ডিনাইড',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'আপনার এই প্যানেল এক্সেস করার অনুমতি নেই।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text('এডমিন লগিন'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('হোমে ফিরে যান'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // রিচার্জ রিকোয়েস্ট স্ট্যাটাস আপডেট
  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await PointManager.updateGiftStatus(requestId, newStatus);
      await _loadRechargeRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ রিকোয়েস্ট $newStatus করা হয়েছে"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ আপডেট করতে ত্রুটি: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 যদি এডমিন না হয়, লগিন প্রম্পট দেখাবে
    if (!_isAdmin) {
      return _buildAdminLoginPrompt();
    }

    final pendingRequests = _rechargeRequests
        .where((r) => r['status'] == 'pending')
        .toList();
    final completedRequests = _rechargeRequests
        .where((r) => r['status'] == 'completed')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("গিফট রিকোয়েস্ট (এডমিন)"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRechargeRequests,
            tooltip: "রিফ্রেশ",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logoutAdmin,
            tooltip: "লগআউট",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Material(
                    color: Colors.green[800],
                    child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.pending_actions),
                          text: "বিচারাধীন (${pendingRequests.length})",
                        ),
                        Tab(
                          icon: const Icon(Icons.history),
                          text: "সম্পন্ন (${completedRequests.length})",
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // বিচারাধীন ট্যাব
                        pendingRequests.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 64,
                                      color: Colors.green,
                                    ),
                                    SizedBox(height: 16),
                                    Text("কোন বিচারাধীন রিকোয়েস্ট নেই"),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: pendingRequests.length,
                                itemBuilder: (context, index) {
                                  final request = pendingRequests[index];
                                  return _buildRequestCard(request, true);
                                },
                              ),

                        // সম্পন্ন ট্যাব
                        completedRequests.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text("কোন সম্পন্ন রিকোয়েস্ট নেই"),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: completedRequests.length,
                                itemBuilder: (context, index) {
                                  final request = completedRequests[index];
                                  return _buildRequestCard(request, false);
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // এডমিন স্ক্রিনের _buildRequestCard ফাংশনে
  // এডমিন স্ক্রিনের _buildRequestCard ফাংশনে - FIXED VERSION
  Widget _buildRequestCard(Map<String, dynamic> request, bool isPending) {
    // 🔥 FIX: Convert points to String
    final pointsUsed = request['pointsUsed'];
    final pointsText = pointsUsed != null
        ? pointsUsed is int
              ? '$pointsUsed'
              : pointsUsed.toString()
        : '0';

    // 🔥 FIX: Safe access for processedAt field
    final processedAt = request['processedAt'];
    final showProcessedDate = !isPending && processedAt != null;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          isPending ? Icons.pending : Icons.check_circle,
          color: isPending ? Colors.orange : Colors.green,
          size: 30,
        ),
        title: Text(
          request['mobileNumber'] ?? 'নম্বর নেই',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPending ? Colors.orange : Colors.green,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request['userEmail'] ?? 'ইমেইল নেই'),
            Text("তারিখ: ${_formatDate(request['requestedAt'])}"),
            if (showProcessedDate) Text("সম্পন্ন: ${_formatDate(processedAt)}"),
            // 🔥 FIXED: Safe access
          ],
        ),
        trailing: Text(
          "$pointsText পয়েন্ট", // 🔥 FIXED
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        onTap: () => _showRequestDetails(request),
      ),
    );
  }

  // _showRequestDetails ফাংশনে পয়েন্ট দেখানোর অংশ
  void _showRequestDetails(Map<String, dynamic> request) {
    // 🔥 FIX: Convert points to String
    final pointsUsed = request['pointsUsed'];
    final pointsText = pointsUsed != null
        ? pointsUsed is int
              ? '$pointsUsed'
              : pointsUsed.toString()
        : '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("গিফট রিকোয়েস্ট ডিটেইলস"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("ইউজার:", request['userEmail'] ?? 'নাই'),
            _buildDetailRow("মোবাইল:", request['mobileNumber'] ?? 'নাই'),
            _buildDetailRow("পয়েন্ট:", "$pointsText পয়েন্ট"), // 🔥 FIXED
            _buildDetailRow("স্ট্যাটাস:", _getStatusText(request['status'])),
            _buildDetailRow(
              "রিকোয়েস্ট তারিখ:",
              _formatDate(request['requestedAt']),
            ),
            if (request['processedAt'] != null)
              _buildDetailRow(
                "প্রসেস তারিখ:",
                _formatDate(request['processedAt']),
              ),
          ],
        ),
        actions: [
          if (request['status'] == 'pending') ...[
            TextButton(
              onPressed: () {
                final requestId =
                    request['id']?.toString() ?? ''; // 🔥 FIX: Safe access
                if (requestId.isNotEmpty) {
                  _updateRequestStatus(requestId, 'rejected');
                }
              },
              child: const Text(
                "বাতিল করুন",
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final requestId =
                    request['id']?.toString() ?? ''; // 🔥 FIX: Safe access
                if (requestId.isNotEmpty) {
                  _updateRequestStatus(requestId, 'completed');
                  Navigator.pop(context);
                  _showRechargeCompletedDialog(request);
                }
              },
              child: const Text("গিফট সম্পন্ন"),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("বন্ধ করুন"),
          ),
        ],
      ),
    );
  }

  void _showRechargeCompletedDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("✅ গিফট সম্পন্ন"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("আপনি এই ইউজারকে গিফট দিয়ে দিয়েছেন?"),
            const SizedBox(height: 10),
            Text(
              "মোবাইল: ${request['mobileNumber']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "পরিমাণ: বিশেষ পুরুস্কার",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "রিমাইন্ডার: ইউজারকে নোটিফাই করুন যে গিফট প্রদান করা হয়েছে",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ঠিক আছে"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'বিচারাধীন';
      case 'completed':
        return 'সম্পন্ন';
      case 'rejected':
        return 'বাতিল';
      default:
        return status;
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "তারিখ নেই";
    }
  }
}
