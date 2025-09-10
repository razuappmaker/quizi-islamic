import 'package:flutter/material.dart';

class KalemaPage extends StatelessWidget {
  const KalemaPage({super.key});

  final List<Map<String, String>> kalemaList = const [
    {
      "title": "কালেমা তাইয়্যেবা",
      "text": "লা-ইলাহা ইল্লাল্লাহু মুহাম্মাদুর রাসূলুল্লাহ।"
    },
    {
      "title": "কালেমা শাহাদাত",
      "text": "আশহাদু আল্লা-ইলাহা ইল্লাল্লাহু ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসূলুহু।"
    },
    {
      "title": "কালেমা তামজীদ",
      "text": "সুবহানাল্লাহি ওয়াল হামদুলিল্লাহি ওয়ালা-ইলাহা ইল্লাল্লাহু ওয়াল্লাহু আকবার।"
    },
    {
      "title": "কালেমা তাওহীদ",
      "text": "লা-ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকালাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ইউহই ওয়াইউমীতু, ওয়াহুয়া হাইয়্যুন লা ইয়ামুতু আবাদান, যুল জালালি ওয়াল ইকরাম, বিয়াদিহিল খইর, ওয়াহুয়া আলা কুল্লি শাইইন কদীর।"
    },
    {
      "title": "কালেমা রুদ্দে কুফর",
      "text": "আল্লাহুম্মা ইন্নি আউযু বিকা মিন আন উশরিকা বিকা শাইয়ান ওয়া আনা আ’লামু বিহি, ওয়াসতাগফিরুকা লিমা লা আ’লামু বিহি তুবতু আনহু, ওয়া তাবাররাতু মিনাল কুফরি ওয়াশশিরকি ওয়াল কিজবি ওয়াল গীবাতি ওয়াল বিদ’আতি ওয়ান্নামীমাতি ওয়াল ফাওয়াহিশি ওয়ালবুহতানি ওয়ালমা’আসী কুল্লিহা, আসলামতু ওয়া আ’মানতু ওয়া আকুলু লা-ইলাহা ইল্লাল্লাহু মুহাম্মাদুর রাসূলুল্লাহ।"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("কালেমা সমূহ"),
        backgroundColor: Colors.green[800],
      ),
      body: ListView.builder(
        itemCount: kalemaList.length,
        itemBuilder: (context, index) {
          final kalema = kalemaList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                kalema["title"]!,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  kalema["text"]!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
