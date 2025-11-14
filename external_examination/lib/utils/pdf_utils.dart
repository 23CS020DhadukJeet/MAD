import 'package:flutter/material.dart' as m;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/grade.dart';
import 'gpa_utils.dart';

Future<void> exportTranscriptPdf(m.BuildContext context, List<Grade> grades) async {
  final doc = pw.Document();
  final overall = computeGPA(grades).toStringAsFixed(2);

  doc.addPage(
    pw.MultiPage(
      build: (ctx) => [
        pw.Header(level: 0, child: pw.Text('Transcript', style: pw.TextStyle(fontSize: 24))),
        pw.Paragraph(text: 'Overall GPA: $overall'),
        pw.Table.fromTextArray(
          headers: ['Course', 'Assessment', 'Marks', 'Date', 'Term'],
          data: grades
              .map((g) => [
                    g.courseCode,
                    g.assessmentType,
                    '${g.obtainedMarks}/${g.maxMarks}',
                    g.displayDate,
                    g.term ?? '',
                  ])
              .toList(),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => doc.save());
}