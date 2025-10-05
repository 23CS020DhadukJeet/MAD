import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const EMICalculatorApp());
}

class EMICalculatorApp extends StatelessWidget {
  const EMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EMICalculatorScreen(),
    );
  }
}

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  _EMICalculatorScreenState createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  double _emiResult = 0.0;

  void _calculateEMI() {
    double principal = double.tryParse(_principalController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double time = double.tryParse(_timeController.text) ?? 0;

    double monthlyRate = rate / 12 / 100;
    double months = time * 12;

    double emi = (principal * monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);

    setState(() {
      _emiResult = emi.isNaN || emi.isInfinite ? 0.0 : emi;
    });
  }

  void _setLoanRate(double rate) {
    setState(() {
      _rateController.text = rate.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EMI Calculator"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _principalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Loan Amount (₹)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Interest Rate (%)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Time Period (Years)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Loan Type Buttons
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () => _setLoanRate(8),
                    child: const Text("Home Loan (8%)"),
                  ),
                  ElevatedButton(
                    onPressed: () => _setLoanRate(9),
                    child: const Text("Car Loan (9%)"),
                  ),
                  ElevatedButton(
                    onPressed: () => _setLoanRate(6),
                    child: const Text("Business Loan (6%)"),
                  ),
                  ElevatedButton(
                    onPressed: () => _setLoanRate(10),
                    child: const Text("Education Loan (10%)"),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateEMI,
                child: const Text("Calculate EMI"),
              ),
              const SizedBox(height: 30),
              Text(
                "Your Monthly EMI is: ₹ ${_emiResult.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
