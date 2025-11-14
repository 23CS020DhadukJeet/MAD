import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grade.dart';
import '../providers/grade_provider.dart';
import '../utils/gpa_utils.dart';
import '../utils/pdf_utils.dart';

class ForecastScreen extends StatefulWidget {
  static const routeName = '/forecast';
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final List<Grade> _hypothetical = [];
  final _courseCtrl = TextEditingController();
  final _maxCtrl = TextEditingController(text: '100');
  final _obtCtrl = TextEditingController(text: '80');

  @override
  void dispose() {
    _courseCtrl.dispose();
    _maxCtrl.dispose();
    _obtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actual = context.watch<GradeProvider>().grades;
    final combined = [...actual, ..._hypothetical];
    final forecastGpa = computeGPA(combined);

    return Scaffold(
      appBar: AppBar(title: const Text('GPA Forecast & Export')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _courseCtrl,
                    decoration: const InputDecoration(labelText: 'Course Code'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _obtCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Obt'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final c = _courseCtrl.text.trim().isEmpty ? 'COURSE' : _courseCtrl.text.trim();
                    final max = int.tryParse(_maxCtrl.text) ?? 100;
                    final obt = int.tryParse(_obtCtrl.text) ?? 80;
                    setState(() {
                      _hypothetical.add(Grade(
                        courseCode: c,
                        assessmentType: 'Forecast',
                        maxMarks: max,
                        obtainedMarks: obt,
                        date: DateTime.now(),
                      ));
                    });
                  },
                  child: const Text('Add Hypothetical'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Forecast GPA: ${forecastGpa.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                OutlinedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Export Transcript PDF'),
                  onPressed: () async {
                    await exportTranscriptPdf(context, actual);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _hypothetical.length,
                itemBuilder: (_, i) {
                  final g = _hypothetical[i];
                  return ListTile(
                    title: Text('${g.courseCode} • ${g.obtainedMarks}/${g.maxMarks}'),
                    subtitle: Text('Forecast • ${g.percentage.toStringAsFixed(1)}%'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _hypothetical.removeAt(i)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}