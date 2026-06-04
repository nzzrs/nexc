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

  Stream<List<BodyMeasurement>> getAllMeasurements() {
    return (db.select(db.bodyMeasurements)
          ..orderBy([(m) => OrderingTerm(expression: m.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> upsertMeasurement(BodyMeasurement measurement) {
    return db.into(db.bodyMeasurements).insertOnConflictUpdate(measurement);
  }

  Future<void> deleteMeasurement(BodyMeasurement measurement) {
    return db.delete(db.bodyMeasurements).delete(measurement);
  }

  Future<void> deleteById(int id) {
    return (db.delete(db.bodyMeasurements)..where((m) => m.id.equals(id))).go();
  }

  Future<BodyMeasurement?> getLastMeasurementByCutoff(DateTime cutoff) {
    final query = db.select(db.bodyMeasurements)
      ..where((m) => CustomExpression<bool>(
            "date <= '${const IsoDateTimeConverter().toSql(cutoff)}'",
          ))
      ..orderBy([(m) => OrderingTerm(expression: m.date, mode: OrderingMode.desc)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> prepopulateDefaultMeasurements() async {
    final list = await db.select(db.bodyMeasurements).get();
    if (list.isNotEmpty) return;

    final now = DateTime.now();
    final bodyData = [
      BodyMeasurement(
        id: 1,
        bodyWeight: 78.5,
        date: now.subtract(const Duration(days: 14)),
      ),
      BodyMeasurement(
        id: 2,
        bodyWeight: 79.0,
        date: now.subtract(const Duration(days: 7)),
      ),
      BodyMeasurement(
        id: 3,
        bodyWeight: 79.5,
        date: now,
      ),
    ];

    for (final m in bodyData) {
      await db.into(db.bodyMeasurements).insertOnConflictUpdate(m);
    }

    final advancedData = [
      AdvancedBodyMeasurement(
        id: 1,
        bodyFatPercentage: 16,
        muscleMassPercentage: 42,
        date: now.subtract(const Duration(days: 14)),
      ),
      AdvancedBodyMeasurement(
        id: 2,
        bodyFatPercentage: 15,
        muscleMassPercentage: 43,
        date: now.subtract(const Duration(days: 7)),
      ),
      AdvancedBodyMeasurement(
        id: 3,
        bodyFatPercentage: 15,
        muscleMassPercentage: 44,
        date: now,
      ),
    ];

    for (final m in advancedData) {
      await db.into(db.advancedBodyMeasurements).insertOnConflictUpdate(m);
    }
  }

  Stream<List<AdvancedBodyMeasurement>> getAllAdvancedBodyMeasurements() {
    return (db.select(db.advancedBodyMeasurements)
          ..orderBy([(m) => OrderingTerm(expression: m.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> upsertAdvancedBodyMeasurement(AdvancedBodyMeasurement measurement) {
    return db.into(db.advancedBodyMeasurements).insertOnConflictUpdate(measurement);
  }

  Future<void> deleteAdvancedBodyMeasurement(AdvancedBodyMeasurement measurement) {
    return db.delete(db.advancedBodyMeasurements).delete(measurement);
  }

  Stream<List<SleepMeasurement>> getAllSleepMeasurements() {
    return (db.select(db.sleepMeasurements)
          ..orderBy([(m) => OrderingTerm(expression: m.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> upsertSleepMeasurement(SleepMeasurement measurement) {
    return db.into(db.sleepMeasurements).insertOnConflictUpdate(measurement);
  }

  Future<void> deleteSleepMeasurement(SleepMeasurement measurement) {
    return db.delete(db.sleepMeasurements).delete(measurement);
  }

  Stream<List<AdvancedSleepMeasurement>> getAllAdvancedSleepMeasurements() {
    return (db.select(db.advancedSleepMeasurements)
          ..orderBy([(m) => OrderingTerm(expression: m.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> upsertAdvancedSleepMeasurement(AdvancedSleepMeasurement measurement) {
    return db.into(db.advancedSleepMeasurements).insertOnConflictUpdate(measurement);
  }

  Future<void> deleteAdvancedSleepMeasurement(AdvancedSleepMeasurement measurement) {
    return db.delete(db.advancedSleepMeasurements).delete(measurement);
  }

  Stream<List<ActivityMeasurement>> getAllActivityMeasurements() {
    return (db.select(db.activityMeasurements)
          ..orderBy([(m) => OrderingTerm(expression: m.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> upsertActivityMeasurement(ActivityMeasurement measurement) {
    return db.into(db.activityMeasurements).insertOnConflictUpdate(measurement);
  }

  Future<void> deleteActivityMeasurement(ActivityMeasurement measurement) {
    return db.delete(db.activityMeasurements).delete(measurement);
  }
}

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final db = ref.watch(dbProvider);
  return MeasurementRepository(db);
});
