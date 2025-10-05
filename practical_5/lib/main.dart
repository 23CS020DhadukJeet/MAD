import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

void main() {
  runApp(const ResumeMakerApp());
}

class ResumeMakerApp extends StatelessWidget {
  const ResumeMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume Maker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const ResumeHomePage(),
    );
  }
}

class ResumeHomePage extends StatefulWidget {
  const ResumeHomePage({super.key});

  @override
  State<ResumeHomePage> createState() => _ResumeHomePageState();
}

class _ResumeHomePageState extends State<ResumeHomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController educationController = TextEditingController();

  // ✅ Dynamic Skills
  final TextEditingController skillInputController = TextEditingController();
  final List<String> skills = [];

  // ✅ Dynamic Work Experience
  final TextEditingController experienceInputController =
      TextEditingController();
  final List<String> experiences = [];

  void addSkill() {
    final skill = skillInputController.text.trim();
    if (skill.isNotEmpty) {
      setState(() => skills.add(skill));
      skillInputController.clear();
    }
  }

  void removeSkill(String skill) {
    setState(() => skills.remove(skill));
  }

  void addExperience() {
    final exp = experienceInputController.text.trim();
    if (exp.isNotEmpty) {
      setState(() => experiences.add(exp));
      experienceInputController.clear();
    }
  }

  void removeExperience(String exp) {
    setState(() => experiences.remove(exp));
  }

  void clearAll() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    educationController.clear();
    skills.clear();
    experiences.clear();
    skillInputController.clear();
    experienceInputController.clear();
    setState(() {});
  }

  void generateResume() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  nameController.text,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                    '${emailController.text} ${phoneController.text.isNotEmpty ? " • ${phoneController.text}" : ""}'),
                pw.Divider(thickness: 2, color: PdfColors.grey),

                pw.SizedBox(height: 10),
                pw.Text('Education',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(educationController.text),

                pw.SizedBox(height: 10),
                pw.Text('Experience',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ...experiences.map((exp) => pw.Bullet(text: exp)),

                pw.SizedBox(height: 10),
                pw.Text('Skills',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: skills
                      .map((skill) => pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.indigo100,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Text(skill),
                          ))
                      .toList(),
                )
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Widget buildTextField(
      String label, IconData icon, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
        ),
      ),
    );
  }

  Widget buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Skills",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: skillInputController,
                decoration: const InputDecoration(
                  labelText: "Enter a skill",
                  prefixIcon: Icon(Icons.star, color: Colors.indigo),
                ),
                onSubmitted: (_) => addSkill(),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: addSkill,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map((skill) => Chip(
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => removeSkill(skill),
                    backgroundColor: Colors.indigo.shade50,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Work Experience",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: experienceInputController,
                decoration: const InputDecoration(
                  labelText: "Enter role, company, duration",
                  prefixIcon: Icon(Icons.work, color: Colors.indigo),
                ),
                onSubmitted: (_) => addExperience(),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: addExperience,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: experiences
              .map((exp) => ListTile(
                    tileColor: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    leading: const Icon(Icons.work, color: Colors.indigo),
                    title: Text(exp),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => removeExperience(exp),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Resume Maker'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Fill Your Details',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(),
                    buildTextField('Full Name', Icons.person, nameController),
                    buildTextField('Email', Icons.email, emailController),
                    buildTextField('Phone Number', Icons.phone, phoneController),
                    buildTextField('Education', Icons.school, educationController,
                        maxLines: 3),
                    const SizedBox(height: 10),
                    buildExperienceSection(),
                    const SizedBox(height: 10),
                    buildSkillsSection(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: generateResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate Resume'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: clearAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.delete),
              label: const Text('Clear All'),
            ),
          ],
        ),
      ),
    );
  }
}
