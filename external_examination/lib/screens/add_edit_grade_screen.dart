import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grade.dart';
import '../providers/grade_provider.dart';

class AddEditGradeScreen extends StatefulWidget {
  const AddEditGradeScreen({super.key});

  @override
  State<AddEditGradeScreen> createState() => _AddEditGradeScreenState();
}

class _AddEditGradeScreenState extends State<AddEditGradeScreen> {
  final _form = GlobalKey<FormState>();
  final _courseCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  final _obtCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  String _assessment = 'Midterm';
  DateTime _date = DateTime.now();
  DateTime? _deadline;
  String? _filePath;

  @override
  void dispose() {
    _courseCtrl.dispose();
    _maxCtrl.dispose();
    _obtCtrl.dispose();
    _remarksCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add/Edit Grade',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _courseCtrl,
              decoration: const InputDecoration(labelText: 'Course Code'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _assessment,
              items: const [
                DropdownMenuItem(value: 'Midterm', child: Text('Midterm')),
                DropdownMenuItem(value: 'Final', child: Text('Final')),
                DropdownMenuItem(
                  value: 'Assignment',
                  child: Text('Assignment'),
                ),
              ],
              onChanged: (v) => setState(() => _assessment = v ?? 'Midterm'),
              decoration: const InputDecoration(labelText: 'Assessment Type'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max Marks'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter valid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _obtCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Obtained Marks',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 0) return 'Enter valid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _termCtrl,
              decoration: const InputDecoration(
                labelText: 'Term/Semester (e.g., Fall 2025)',
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _remarksCtrl,
              decoration: const InputDecoration(labelText: 'Remarks'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InputDatePickerFormField(
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: _date,
                    onDateSubmitted: (d) => setState(() => _date = d),
                    onDateSaved: (d) => setState(() => _date = d),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Re-evaluation Deadline'),
                      TextButton.icon(
                        icon: const Icon(Icons.event_outlined),
                        label: Text(
                          _deadline == null
                              ? 'Select date'
                              : _deadline!.toLocal().toString().split(' ')[0],
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _deadline ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null)
                            setState(() => _deadline = picked);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(
                      _filePath == null ? 'Attach Marksheet' : 'Attached',
                    ),
                    onPressed: () async {
                      final res = await FilePicker.platform.pickFiles();
                      if (res != null && res.files.isNotEmpty) {
                        setState(() => _filePath = res.files.first.path);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Grade'),
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;
                    final g = Grade(
                      courseCode: _courseCtrl.text.trim(),
                      assessmentType: _assessment,
                      maxMarks: int.parse(_maxCtrl.text),
                      obtainedMarks: int.parse(_obtCtrl.text),
                      date: _date,
                      remarks: _remarksCtrl.text.trim().isEmpty
                          ? null
                          : _remarksCtrl.text.trim(),
                      term: _termCtrl.text.trim().isEmpty
                          ? null
                          : _termCtrl.text.trim(),
                      scannedMarksheetPath: _filePath,
                      reevalDeadline: _deadline,
                    );
                    await context.read<GradeProvider>().addGrade(g);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Grade saved')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
