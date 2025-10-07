class Member {
  final String id;
  String name;
  String phone;
  String email;
  String planName;
  DateTime? planStartDate;
  DateTime? planEndDate;
  String? notes;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.planName,
    this.planStartDate,
    this.planEndDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'planName': planName,
      'planStartDate': planStartDate?.millisecondsSinceEpoch,
      'planEndDate': planEndDate?.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory Member.fromMap(Map<dynamic, dynamic> map) {
    return Member(
      id: map['id'] as String,
      name: (map['name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      planName: (map['planName'] ?? '') as String,
      planStartDate: map['planStartDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['planStartDate'] as int)
          : null,
      planEndDate: map['planEndDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['planEndDate'] as int)
          : null,
      notes: map['notes'] as String?,
    );
  }
}