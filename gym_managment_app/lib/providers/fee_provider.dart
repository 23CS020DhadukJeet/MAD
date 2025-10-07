import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/fee_payment.dart';
import '../services/database_service.dart';

class FeeProvider extends ChangeNotifier {
  final Box _box = DatabaseService.paymentsBox;

  List<FeePayment> getMemberPayments(String memberId) {
    return _box.values
        .whereType<Map>()
        .map((m) => FeePayment.fromMap(m))
        .where((p) => p.memberId == memberId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addPayment(FeePayment payment) async {
    await _box.put(payment.id, payment.toMap());
    notifyListeners();
  }

  Future<void> updatePayment(FeePayment payment) async {
    await _box.put(payment.id, payment.toMap());
    notifyListeners();
  }

  Future<void> deletePayment(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}