import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/attendance_record.dart';
import '../services/database_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final Box _box = DatabaseService.attendanceBox;

  List<AttendanceRecord> getMemberAttendance(String memberId) {
    return _box.values
        .whereType<Map>()
        .map((m) => AttendanceRecord.fromMap(m))
        .where((a) => a.memberId == memberId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> markAttendance(String memberId, DateTime date, bool present) async {
    final id = '${memberId}_${date.toIso8601String()}';
    final record = AttendanceRecord(id: id, memberId: memberId, date: date, present: present);
    await _box.put(id, record.toMap());
    notifyListeners();
  }

  // Add delete to complete CRUD for attendance records
  Future<void> deleteAttendance(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}