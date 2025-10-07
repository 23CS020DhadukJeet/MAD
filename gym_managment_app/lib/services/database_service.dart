import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  static const String membersBoxName = 'members';
  static const String paymentsBoxName = 'payments';
  static const String attendanceBoxName = 'attendance';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(membersBoxName);
    await Hive.openBox(paymentsBoxName);
    await Hive.openBox(attendanceBoxName);
  }

  static Box<dynamic> get membersBox => Hive.box(membersBoxName);
  static Box<dynamic> get paymentsBox => Hive.box(paymentsBoxName);
  static Box<dynamic> get attendanceBox => Hive.box(attendanceBoxName);

  static String generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}