import 'dart:math';
import 'package:flutter/foundation.dart';
import '../db/repository.dart';
import '../db/grade_store.dart';
import '../models/grade.dart';
import '../utils/gpa_utils.dart';

class GradeProvider extends ChangeNotifier {
  late final GradeRepository _repo;
  GradeStore get _store => _repo.store;

  final List<Grade> _grades = [];
  List<Grade> get grades => List.unmodifiable(_grades);

  // Filters
  String _searchQuery = '';
  String? _termFilter;
  String? get termFilter => _termFilter;
  String get searchQuery => _searchQuery;

  double get overallGpa => computeGPA(_grades);
  Map<String, double> get gpaByTerm => termWiseGpa(_grades);

  List<Grade> get recentGrades {
    final list = List.of(_grades);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(10).toList();
  }

  Future<void> initialize() async {
    _repo = GradeRepository();
    await _repo.init();
    final data = await _store.getAll();
    _grades
      ..clear()
      ..addAll(data);
    // Apply course code mapping to existing records if needed
    await _applyCourseCodeMapping();
    if (_grades.isEmpty) {
      await _seedDefaults();
    }
    notifyListeners();
  }

  Future<void> addGrade(Grade g) async {
    final id = await _store.insert(g);
    _grades.add(Grade(
      id: id,
      courseCode: g.courseCode,
      assessmentType: g.assessmentType,
      maxMarks: g.maxMarks,
      obtainedMarks: g.obtainedMarks,
      date: g.date,
      remarks: g.remarks,
      term: g.term,
      scannedMarksheetPath: g.scannedMarksheetPath,
      reevalDeadline: g.reevalDeadline,
    ));
    notifyListeners();
  }

  Future<void> updateGrade(Grade g) async {
    await _store.update(g);
    final idx = _grades.indexWhere((x) => x.id == g.id);
    if (idx >= 0) _grades[idx] = g;
    notifyListeners();
  }

  Future<void> deleteGrade(int id) async {
    await _store.delete(id);
    _grades.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  void setSearch(String q) {
    _searchQuery = q.trim();
    notifyListeners();
  }

  void setTermFilter(String? term) {
    _termFilter = term;
    notifyListeners();
  }

  Iterable<String> get allTerms => _grades.map((g) => g.term ?? 'Unknown').toSet();
  Iterable<String> get allCourses => _grades.map((g) => g.courseCode).toSet();

  List<Grade> filteredGrades() {
    return _grades.where((g) {
      final matchesSearch = _searchQuery.isEmpty ||
          g.courseCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.assessmentType.toLowerCase().contains(_searchQuery.toLowerCase());
    
      final matchesTerm = _termFilter == null || (_termFilter == 'All') || (g.term == _termFilter);
      return matchesSearch && matchesTerm;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  DateTime? nearestDeadline() {
    final upcoming = _grades
        .where((g) => g.reevalDeadline != null && g.reevalDeadline!.isAfter(DateTime.now()))
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.reevalDeadline!.compareTo(b.reevalDeadline!));
    return upcoming.first.reevalDeadline;
  }

  Future<void> _seedDefaults() async {
    final rng = Random();
    // Course -> Code mapping
    final courseCodes = <String, String>{
      'MAD': 'MAD (CSE309)',
      'FSD': 'FSD (CSE304)',
      'SGP': 'SGP (CSE305)',
      'ML': 'ML (CSE303)',
      'HS': 'HS (HS131.02)',
      'TOC': 'TOC (CSE302)',
      'SE': 'SE (CSE301)',
      'RM': 'RM (CSE310)',
    };
    final courses = courseCodes.keys.toList();
    final types = ['Assignment', 'Midterm', 'Final'];
    final termLabels = ['Sem-4 2025', 'Sem-5 2025'];
    final now = DateTime.now();

    int _maxForType(String t) {
      switch (t) {
        case 'Midterm':
          return 30;
        case 'Final':
          return 100;
        case 'Assignment':
        default:
          return 10;
      }
    }

    for (final c in courses) {
      for (final term in termLabels) {
        for (final t in types) {
          final max = _maxForType(t);
          // Generate obtained marks scaled to the max (roughly 60%..90%).
          final obt = (max * (0.6 + rng.nextDouble() * 0.3)).round();
          final date = now.subtract(Duration(days: rng.nextInt(40)));
          final g = Grade(
            courseCode: courseCodes[c]!,
            assessmentType: t,
            maxMarks: max,
            obtainedMarks: obt,
            date: date,
            term: term,
            remarks: obt >= (0.8 * max).round() ? 'Good performance' : 'Above average',
            reevalDeadline: rng.nextBool() ? now.add(Duration(days: 20 + rng.nextInt(20))) : null,
          );
          await addGrade(g);
        }
      }
    }
  }

  Future<void> _applyCourseCodeMapping() async {
    // Ensure existing stored grades show the course code alongside the course name
    final mapping = <String, String>{
      'MAD': 'MAD (CSE309)',
      'FSD': 'FSD (CSE304)',
      'SGP': 'SGP (CSE305)',
      'ML': 'ML (CSE303)',
      'HS': 'HS (HS131.02)',
      'TOC': 'TOC (CSE302)',
      'SE': 'SE (CSE301)',
      'RM': 'RM (CSE310)',
    };
    String _renameTerm(String? t) {
      if (t == null || t.isEmpty) return t ?? '';
      var result = t;
      // Case-insensitive replacements preserving year text
      result = result.replaceAll(RegExp('(?i)fall'), 'Sem-4');
      result = result.replaceAll(RegExp('(?i)summer'), 'Sem-4');
      result = result.replaceAll(RegExp('(?i)winter'), 'Sem-5');
      return result;
    }
    for (final g in List<Grade>.from(_grades)) {
      final target = mapping[g.courseCode];
      // Only update if it's a known course and not already mapped
      if (target != null && g.courseCode != target) {
        final updated = Grade(
          id: g.id,
          courseCode: target,
          assessmentType: g.assessmentType,
          maxMarks: g.maxMarks,
          obtainedMarks: g.obtainedMarks,
          date: g.date,
          remarks: g.remarks,
          // Migrate term naming to Sem-4/Sem-5
          term: _renameTerm(g.term),
          scannedMarksheetPath: g.scannedMarksheetPath,
          reevalDeadline: g.reevalDeadline,
        );
        await updateGrade(updated);
      } else if (g.term != null) {
        // Even if course code mapping isn't needed, still migrate term naming.
        final updated = Grade(
          id: g.id,
          courseCode: g.courseCode,
          assessmentType: g.assessmentType,
          maxMarks: g.maxMarks,
          obtainedMarks: g.obtainedMarks,
          date: g.date,
          remarks: g.remarks,
          term: _renameTerm(g.term),
          scannedMarksheetPath: g.scannedMarksheetPath,
          reevalDeadline: g.reevalDeadline,
        );
        await updateGrade(updated);
      }
    }
  }
}