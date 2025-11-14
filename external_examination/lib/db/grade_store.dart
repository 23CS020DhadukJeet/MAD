import '../models/grade.dart';

abstract class GradeStore {
  Future<void> init();
  Future<List<Grade>> getAll();
  Future<List<Grade>> getRecent({int limit = 10});
  Future<int> insert(Grade g);
  Future<int> update(Grade g);
  Future<int> delete(int id);
}