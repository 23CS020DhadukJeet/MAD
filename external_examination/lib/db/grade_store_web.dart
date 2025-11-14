import '../models/grade.dart';
import 'grade_store.dart';

/// Simple in-memory store for web preview. Not persistent.
class GradeStoreWeb implements GradeStore {
  final List<Grade> _grades = [];
  int _autoId = 1;

  @override
  Future<void> init() async {}

  @override
  Future<List<Grade>> getAll() async {
    _grades.sort((a, b) => b.date.compareTo(a.date));
    return List.of(_grades);
  }

  @override
  Future<List<Grade>> getRecent({int limit = 10}) async {
    final all = await getAll();
    return all.take(limit).toList();
  }

  @override
  Future<int> insert(Grade g) async {
    final id = _autoId++;
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
    return id;
  }

  @override
  Future<int> update(Grade g) async {
    final idx = _grades.indexWhere((x) => x.id == g.id);
    if (idx >= 0) {
      _grades[idx] = g;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> delete(int id) async {
    _grades.removeWhere((x) => x.id == id);
    return 1;
  }
}