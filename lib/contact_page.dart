import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  // ফোন কল করার ফাংশন
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Error হ্যান্ডেল করতে পারেন এখানে
    }
  }

  // ইমেইল করার ফাংশন
  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'ইসলামিক কুইজ অ্যাপ সম্পর্কিত',
        'body': 'আপনার বার্তা এখানে লিখুন',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Error হ্যান্ডেল করতে পারেন এখানে
    }
  }

  // সোশ্যাল আইকন ক্লিক করলে লিঙ্ক খোলা
  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Error হ্যান্ডেল করতে পারেন এখানে
    }
  }

  @override
  Widget build(BuildContext context) {
    final greenColor = Colors.green.shade800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('যোগাযোগ'),
        backgroundColor: greenColor,
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'আপনার প্রশ্ন ও পরামর্শ জানান',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: greenColor,
              ),
            ),
            const SizedBox(height: 20),

            // ফোন কার্ড
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 6,
              shadowColor: greenColor.withOpacity(0.4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: greenColor,
                  child: const Icon(Icons.phone, color: Colors.white),
                ),
                title: const Text(
                  'ফোন নম্বর',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('+৮৮০১৭২৪১৮৪২৭১'),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text('কল করুন'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => _makePhoneCall('+8801724184271'),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ইমেইল কার্ড
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 6,
              shadowColor: greenColor.withOpacity(0.4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: greenColor,
                  child: const Icon(Icons.email, color: Colors.white),
                ),
                title: const Text(
                  'ইমেইল',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('razu.appmaker@gmail.com'),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('ইমেইল পাঠান'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => _sendEmail('razu.appmaker@gmail.com.com'),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ঠিকানা কার্ড
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 6,
              shadowColor: greenColor.withOpacity(0.4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: greenColor,
                  child: const Icon(Icons.location_on, color: Colors.white),
                ),
                title: const Text(
                  'ঠিকানা',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('হাউজঃ ১৪৭/৭, রোডঃ ১০, ইসিবি চত্বর, ক্যান্টনমেন্ট, ঢাকা, বাংলাদেশ'),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'আমাদের সোশ্যাল মিডিয়া',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: greenColor,
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 40),
                _socialIcon(
                  url: 'https://www.facebook.com/RazuInspires',
                  iconUrl: 'https://img.icons8.com/color/48/000000/facebook-new.png',
                  onTap: _openUrl,
                ),
                const SizedBox(width: 60),
                _socialIcon(
                  url: 'https://wa.me/8801724184271?text=Assalamu%20Alaikum%20Bhai',
                  iconUrl: 'https://img.icons8.com/color/48/000000/whatsapp',
                  onTap: _openUrl,
                ),
                const SizedBox(width: 60),
                _socialIcon(
                  url: 'https://m.me/RazuInspires',  // Messenger প্রোফাইল লিঙ্ক
                  iconUrl: 'https://img.icons8.com/color/48/000000/facebook-messenger.png',  // Messenger আইকন URL
                  onTap: _openUrl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon({
    required String url,
    required String iconUrl,
    required Function(String) onTap,
  }) {
    return InkWell(
      onTap: () => onTap(url),
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            iconUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
