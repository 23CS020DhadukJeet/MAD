class FeePayment {
  final String id;
  final String memberId;
  double amount;
  DateTime date;
  String status; // 'paid' or 'unpaid'
  DateTime? dueDate;

  FeePayment({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.date,
    this.status = 'paid',
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'status': status,
      'dueDate': dueDate?.millisecondsSinceEpoch,
    };
  }

  factory FeePayment.fromMap(Map<dynamic, dynamic> map) {
    return FeePayment(
      id: map['id'] as String,
      memberId: map['memberId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      status: (map['status'] ?? 'paid') as String,
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
          : null,
    );
  }
}