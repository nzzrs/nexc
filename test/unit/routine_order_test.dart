/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/db/workout_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('Routine order', () {
    late AppDatabase db;
    late WorkoutRepository repo;

    setUp(() {
      db = AppDatabase.executor(NativeDatabase.memory());
      repo = WorkoutRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<int> insertRoutine({
      required String title,
      required DateTime created,
      int? position,
      bool isTemporal = false,
    }) {
      return db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              routineId: 0,
              notes: '',
              title: title,
              state: WorkoutState.ROUTINE,
              timeElapsed: 0,
              created: created,
              completed: created,
              position: position == null
                  ? const drift.Value.absent()
                  : drift.Value(position),
              isTemporal: drift.Value(isTemporal),
            ),
          );
    }

    Future<int> insertCompleted({
      required String title,
      required DateTime created,
      required DateTime completed,
      int? position,
    }) {
      return db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              routineId: 0,
              notes: '',
              title: title,
              state: WorkoutState.COMPLETED,
              timeElapsed: 0,
              created: created,
              completed: completed,
              position: position == null
                  ? const drift.Value.absent()
                  : drift.Value(position),
            ),
          );
    }

    test('routines are ordered by position and then created', () async {
      final base = DateTime(2026, 1, 1);
      await insertRoutine(title: 'Third', created: base, position: 2);
      await insertRoutine(
        title: 'First',
        created: base.add(const Duration(days: 1)),
        position: 0,
      );
      await insertRoutine(
        title: 'Fourth',
        created: base.add(const Duration(days: 2)),
        position: 1,
      );
      await insertRoutine(
        title: 'Second',
        created: base.add(const Duration(days: 3)),
        position: 1,
      );

      final routines = await repo
          .watchWorkoutsByState(WorkoutState.ROUTINE)
          .first;

      expect(
        routines.map((w) => w.title).toList(),
        equals(['First', 'Fourth', 'Second', 'Third']),
      );
    });

    test('updateRoutinePositions persists the new order', () async {
      final base = DateTime(2026, 1, 1);
      final firstId = await insertRoutine(
        title: 'First',
        created: base,
        position: 0,
      );
      final secondId = await insertRoutine(
        title: 'Second',
        created: base.add(const Duration(days: 1)),
        position: 1,
      );
      final thirdId = await insertRoutine(
        title: 'Third',
        created: base.add(const Duration(days: 2)),
        position: 2,
      );

      final routines = await repo
          .watchWorkoutsByState(WorkoutState.ROUTINE)
          .first;
      final reordered = [
        routines.firstWhere((w) => w.id == thirdId),
        routines.firstWhere((w) => w.id == firstId),
        routines.firstWhere((w) => w.id == secondId),
      ];

      await repo.updateRoutinePositions(reordered);

      final reloaded = await repo
          .watchWorkoutsByState(WorkoutState.ROUTINE)
          .first;
      expect(
        reloaded.map((w) => w.title).toList(),
        equals(['Third', 'First', 'Second']),
      );
      expect(reloaded.map((w) => w.position).toList(), equals([0, 1, 2]));

      final stored = await (db.select(
        db.workouts,
      )..where((w) => w.state.equalsValue(WorkoutState.ROUTINE))).get();
      final positionsById = {for (final w in stored) w.id: w.position};
      expect(positionsById[thirdId], equals(0));
      expect(positionsById[firstId], equals(1));
      expect(positionsById[secondId], equals(2));
    });

    test(
      'new routines are appended after the current maximum position',
      () async {
        final base = DateTime(2026, 1, 1);
        final existingId = await insertRoutine(
          title: 'Existing',
          created: base,
          position: 5,
        );

        final newOneId = await repo.addWorkoutWithExercisesAndSets(
          WorkoutWithExercisesAndSets(
            workout: Workout(
              id: 0,
              routineId: 0,
              notes: '',
              title: 'New one',
              state: WorkoutState.ROUTINE,
              timeElapsed: 0,
              created: base.add(const Duration(days: 1)),
              completed: base.add(const Duration(days: 1)),
              position: 0,
              isTemporal: false,
            ),
            exercisesWithSets: const [],
          ),
        );
        final newTwoId = await repo.addWorkoutWithExercisesAndSets(
          WorkoutWithExercisesAndSets(
            workout: Workout(
              id: 0,
              routineId: 0,
              notes: '',
              title: 'New two',
              state: WorkoutState.ROUTINE,
              timeElapsed: 0,
              created: base.add(const Duration(days: 2)),
              completed: base.add(const Duration(days: 2)),
              position: 0,
              isTemporal: false,
            ),
            exercisesWithSets: const [],
          ),
        );

        final routines = await repo
            .watchWorkoutsByState(WorkoutState.ROUTINE)
            .first;
        expect(
          routines.map((w) => w.title).toList(),
          equals(['Existing', 'New one', 'New two']),
        );
        final positionsById = {for (final w in routines) w.id: w.position};
        expect(positionsById[existingId], equals(5));
        expect(positionsById[newOneId], equals(6));
        expect(positionsById[newTwoId], equals(7));
      },
    );

    test('completed workouts keep completion descending order', () async {
      final base = DateTime(2026, 1, 1);
      await insertCompleted(
        title: 'Oldest completion',
        created: base,
        completed: base,
        position: 0,
      );
      await insertCompleted(
        title: 'Newest completion',
        created: base.add(const Duration(days: 1)),
        completed: base.add(const Duration(days: 3)),
        position: 1,
      );
      await insertCompleted(
        title: 'Middle completion',
        created: base.add(const Duration(days: 2)),
        completed: base.add(const Duration(days: 2)),
        position: 2,
      );

      final completed = await repo
          .watchWorkoutsByState(WorkoutState.COMPLETED)
          .first;

      expect(
        completed.map((w) => w.title).toList(),
        equals(['Newest completion', 'Middle completion', 'Oldest completion']),
      );
    });

    test(
      'v22 database gains workouts.position and keeps created order',
      () async {
        await db.close();
        final tempDir = Directory.systemTemp.createTempSync(
          'nexc_routine_order_migration',
        );
        final dbFile = File('${tempDir.path}/nexc_database.db');

        final legacy = sqlite3.open(dbFile.path);
        legacy.execute('''
          CREATE TABLE workouts (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            routineId INTEGER NOT NULL,
            notes TEXT NOT NULL,
            title TEXT NOT NULL,
            state TEXT NOT NULL,
            timeElapsed INTEGER NOT NULL,
            created TEXT NOT NULL,
            completed TEXT NOT NULL,
            isTemporal INTEGER NOT NULL DEFAULT 0
          );
        ''');
        legacy.execute('''
          INSERT INTO workouts (
            routineId, notes, title, state, timeElapsed, created, completed,
            isTemporal
          ) VALUES
            (0, '', 'Routine A', 'ROUTINE', 0,
             '2026-01-01T08:00:00.000', '2026-01-01T08:00:00.000', 0),
            (0, '', 'Routine B', 'ROUTINE', 0,
             '2026-01-02T08:00:00.000', '2026-01-02T08:00:00.000', 0),
            (0, '', 'Routine C', 'ROUTINE', 0,
             '2026-01-03T08:00:00.000', '2026-01-03T08:00:00.000', 0);
        ''');
        legacy.execute('PRAGMA user_version = 22;');
        legacy.dispose();

        final migrated = AppDatabase.executor(NativeDatabase(dbFile));
        addTearDown(() async {
          await migrated.close();
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        });

        final columns = await migrated
            .customSelect('PRAGMA table_info(workouts)')
            .get();
        expect(
          columns.map((row) => row.read<String>('name')),
          contains('position'),
        );

        final stored = await migrated.select(migrated.workouts).get();
        expect(stored, hasLength(3));
        expect(stored.map((w) => w.position).toList(), equals([0, 0, 0]));

        final migratedRepo = WorkoutRepository(migrated);
        final routines = await migratedRepo
            .watchWorkoutsByState(WorkoutState.ROUTINE)
            .first;
        expect(
          routines.map((w) => w.title).toList(),
          equals(['Routine A', 'Routine B', 'Routine C']),
        );

        final version = await migrated
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.read<int>('user_version'), equals(23));
      },
    );
  });
}
