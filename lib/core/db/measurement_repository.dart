/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import '../providers/db_provider.dart';

class MeasurementRepository {
  final AppDatabase db;

  MeasurementRepository(this.db);

  Stream<List<Measurement>> getAllMeasurements() {
    return (db.select(db.measurements)
          ..orderBy([(m) => OrderingTerm(expression: m.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> upsertMeasurement(Measurement measurement) {
    return db.into(db.measurements).insertOnConflictUpdate(measurement);
  }

  Future<void> deleteMeasurement(Measurement measurement) {
    return db.delete(db.measurements).delete(measurement);
  }

  Future<void> deleteById(int id) {
    return (db.delete(db.measurements)..where((m) => m.id.equals(id))).go();
  }

  Future<Measurement?> getLastMeasurementByCutoff(DateTime cutoff) {
    final query = db.select(db.measurements)
      ..where((m) => CustomExpression<bool>(
            "date <= '${const IsoDateTimeConverter().toSql(cutoff)}'",
          ))
      ..orderBy([(m) => OrderingTerm(expression: m.date, mode: OrderingMode.desc)])
      ..limit(1);
    return query.getSingleOrNull();
  }
}

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final db = ref.watch(dbProvider);
  return MeasurementRepository(db);
});
