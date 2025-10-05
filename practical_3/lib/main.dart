import 'package:flutter/material.dart';

void main() {
  runApp(const MatchWordApp());
}

class MatchWordApp extends StatelessWidget {
  const MatchWordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Match Image & Word",
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MatchGamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MatchGamePage extends StatefulWidget {
  const MatchGamePage({super.key});

  @override
  State<MatchGamePage> createState() => _MatchGamePageState();
}

class _MatchGamePageState extends State<MatchGamePage> {
  // Sample data
  final List<Map<String, dynamic>> questions = [
    {
      "image": "assets/images/apple.jpg",
      "answer": "Apple",
      "options": ["Apple", "Ball", "Cat"]
    },
    {
      "image": "assets/images/ball.jpg",
      "answer": "Ball",
      "options": ["Dog", "Ball", "Fish"]
    },
    {
      "image": "assets/images/cat.jpg",
      "answer": "Cat",
      "options": ["Cat", "Rat", "Sun"]
    },
  ];

  int currentIndex = 0;
  String feedbackMessage = "";

  void checkAnswer(String selected) {
    String correct = questions[currentIndex]["answer"];
    setState(() {
      if (selected == correct) {
        feedbackMessage = "✅ Correct!";
      } else {
        feedbackMessage = "❌ Try Again!";
      }
    });
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        feedbackMessage = "";
      });
    } else {
      setState(() {
        feedbackMessage = "🎉 Game Completed!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Match Image & Word"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image display
            Expanded(
              child: Center(
                child: Image.asset(
                  question["image"],
                  height: 200,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Options
            Column(
              children: question["options"].map<Widget>((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => checkAnswer(option),
                    child: Text(option,
                        style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Feedback message
            Text(
              feedbackMessage,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Next button
            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Next", style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}
