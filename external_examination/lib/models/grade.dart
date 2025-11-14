import 'package:intl/intl.dart';

class Grade {
  int? id;
  final String courseCode;
  final String assessmentType; // Midterm/Final/Assignment
  final int maxMarks;
  final int obtainedMarks;
  final DateTime date;
  final String? remarks;
  final String? term; // e.g., "Fall 2025"
  final String? scannedMarksheetPath; // file path
  final DateTime? reevalDeadline;

  Grade({
    this.id,
    required this.courseCode,
    required this.assessmentType,
    required this.maxMarks,
    required this.obtainedMarks,
    required this.date,
    this.remarks,
    this.term,
    this.scannedMarksheetPath,
    this.reevalDeadline,
  });

  double get percentage => maxMarks == 0 ? 0 : (obtainedMarks / maxMarks) * 100.0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'courseCode': courseCode,
        'assessmentType': assessmentType,
        'maxMarks': maxMarks,
        'obtainedMarks': obtainedMarks,
        'date': date.millisecondsSinceEpoch,
        'remarks': remarks,
        'term': term,
        'scannedMarksheetPath': scannedMarksheetPath,
        'reevalDeadline': reevalDeadline?.millisecondsSinceEpoch,
      };

  factory Grade.fromMap(Map<String, dynamic> m) => Grade(
        id: m['id'] as int?,
        courseCode: m['courseCode'] as String,
        assessmentType: m['assessmentType'] as String,
        maxMarks: m['maxMarks'] as int,
        obtainedMarks: m['obtainedMarks'] as int,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        remarks: m['remarks'] as String?,
        term: m['term'] as String?,
        scannedMarksheetPath: m['scannedMarksheetPath'] as String?,
        reevalDeadline: m['reevalDeadline'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['reevalDeadline'] as int),
      );

  String get displayDate => DateFormat('dd MMM yyyy').format(date);
}