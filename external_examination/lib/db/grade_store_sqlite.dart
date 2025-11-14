import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/grade.dart';
import 'grade_store.dart';

class GradeStoreSqlite implements GradeStore {
  Database? _db;

  @override
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'grades_tracker.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE grades(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            courseCode TEXT NOT NULL,
            assessmentType TEXT NOT NULL,
            maxMarks INTEGER NOT NULL,
            obtainedMarks INTEGER NOT NULL,
            date INTEGER NOT NULL,
            remarks TEXT,
            term TEXT,
            scannedMarksheetPath TEXT,
            reevalDeadline INTEGER
          );
        ''');
      },
    );
  }

  Database get _database => _db!;

  @override
  Future<List<Grade>> getAll() async {
    final rows = await _database.query('grades', orderBy: 'date DESC');
    return rows.map((e) => Grade.fromMap(e)).toList();
  }

  @override
  Future<List<Grade>> getRecent({int limit = 10}) async {
    final rows = await _database.query('grades', orderBy: 'date DESC', limit: limit);
    return rows.map((e) => Grade.fromMap(e)).toList();
  }

  @override
  Future<int> insert(Grade g) async {
    return _database.insert('grades', g.toMap());
  }

  @override
  Future<int> update(Grade g) async {
    return _database.update('grades', g.toMap(), where: 'id = ?', whereArgs: [g.id]);
  }

  @override
  Future<int> delete(int id) async {
    return _database.delete('grades', where: 'id = ?', whereArgs: [id]);
  }
}