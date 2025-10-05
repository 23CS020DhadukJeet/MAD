import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}


int add(int a, int b) => a + b;
int subtract(int a, int b) => a - b;
int multiply(int a, int b) => a * b;
String divide(int a, int b) {
  if (b == 0) return "Cannot divide by zero!";
  return (a / b).toStringAsFixed(2);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kids Calculator",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();
  String _result = "";

  void _calculate(String operation) {
    final int? num1 = int.tryParse(_num1Controller.text);
    final int? num2 = int.tryParse(_num2Controller.text);

    if (num1 == null || num2 == null) {
      setState(() {
        _result = "Please enter valid numbers!";
      });
      return;
    }

    String answer;
    switch (operation) {
      case "add":
        answer = add(num1, num2).toString();
        break;
      case "subtract":
        answer = subtract(num1, num2).toString();
        break;
      case "multiply":
        answer = multiply(num1, num2).toString();
        break;
      case "divide":
        answer = divide(num1, num2);
        break;
      default:
        answer = "Unknown operation!";
    }

    setState(() {
      _result = "Answer: $answer";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade50,
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Learn Math Easily!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _num1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter first number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _num2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter second number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, minimumSize: const Size(120, 50)),
                  onPressed: () => _calculate("add"),
                  child: const Text(" Add", style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, minimumSize: const Size(120, 50)),
                  onPressed: () => _calculate("subtract"),
                  child: const Text(" Subtract", style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, minimumSize: const Size(120, 50)),
                  onPressed: () => _calculate("multiply"),
                  child: const Text(" Multiply", style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, minimumSize: const Size(120, 50)),
                  onPressed: () => _calculate("divide"),
                  child: const Text(" Divide", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),

            const SizedBox(height: 30),
            Text(
              _result,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 64, 28, 125)),
            )
          ],
        ),
      ),
    );
  }
}
