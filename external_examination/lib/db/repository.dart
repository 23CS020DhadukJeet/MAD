import 'package:flutter/foundation.dart';

import 'grade_store.dart';
import 'grade_store_sqlite.dart';
import 'grade_store_web.dart';

class GradeRepository {
  late final GradeStore store;

  GradeRepository() {
    store = kIsWeb ? GradeStoreWeb() : GradeStoreSqlite();
  }

  Future<void> init() => store.init();
}