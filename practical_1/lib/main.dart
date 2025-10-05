import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const KidsLearningApp());
}

class KidsLearningApp extends StatelessWidget {
  const KidsLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kids Learning",
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn Letters & Numbers"),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 5, // 5 cards per row
        childAspectRatio: 1, // keep square shape
        padding: const EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          ...['a', 'b', 'c', 'd', 'e'].map((letter) => LearningCard(
                text: letter,
                color: Colors.orange.shade400,
              )),
          ...['1', '2', '3', '4', '5'].map((digit) => LearningCard(
                text: digit,
                color: Colors.lightBlue.shade400,
              )),
        ],
      ),
    );
  }
}

class LearningCard extends StatelessWidget {
  final String text;
  final Color color;
  final FlutterTts flutterTts = FlutterTts();

  LearningCard({super.key, required this.text, required this.color});

  void _speak() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _speak,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 28, // smaller font
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
