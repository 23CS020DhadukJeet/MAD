import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/member.dart';
import '../services/database_service.dart';

class MemberProvider extends ChangeNotifier {
  final Box _box = DatabaseService.membersBox;
  List<Member> _members = [];

  List<Member> get members => List.unmodifiable(_members);

  MemberProvider() {
    loadMembers();
  }

  void loadMembers() {
    _members = _box.values
        .whereType<Map>()
        .map((m) => Member.fromMap(m))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Member? getById(String id) {
    final map = _box.get(id);
    if (map is Map) return Member.fromMap(map);
    return null;
  }

  Future<void> addMember(Member member) async {
    await _box.put(member.id, member.toMap());
    loadMembers();
  }

  Future<void> updateMember(Member member) async {
    await _box.put(member.id, member.toMap());
    loadMembers();
  }

  Future<void> deleteMember(String id) async {
    await _box.delete(id);
    loadMembers();
  }
}