import '../models/grade.dart';

double gradePointFromPercentage(double pct) {
  // Simple 10-point scale mapping.
  if (pct >= 90) return 10;
  if (pct >= 80) return 9;
  if (pct >= 70) return 8;
  if (pct >= 60) return 7;
  if (pct >= 50) return 6;
  if (pct >= 40) return 5;
  return 0;
}

double computeGPA(List<Grade> grades) {
  if (grades.isEmpty) return 0;
  final points = grades.map((g) => gradePointFromPercentage(g.percentage)).toList();
  return points.reduce((a, b) => a + b) / points.length;
}

Map<String, double> termWiseGpa(List<Grade> grades) {
  final map = <String, List<Grade>>{};
  for (final g in grades) {
    final key = g.term ?? 'Unknown';
    map.putIfAbsent(key, () => []).add(g);
  }
  return map.map((key, value) => MapEntry(key, computeGPA(value)));
}