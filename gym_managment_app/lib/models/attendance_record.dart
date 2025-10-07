class AttendanceRecord {
  final String id;
  final String memberId;
  DateTime date;
  bool present;

  AttendanceRecord({
    required this.id,
    required this.memberId,
    required this.date,
    this.present = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'date': date.millisecondsSinceEpoch,
      'present': present,
    };
  }

  factory AttendanceRecord.fromMap(Map<dynamic, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String,
      memberId: map['memberId'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      present: (map['present'] ?? true) as bool,
    );
  }
}