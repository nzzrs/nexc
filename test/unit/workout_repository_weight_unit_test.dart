/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/db/workout_repository.dart';

ExerciseDataDC _exerciseData(String id) {
  return ExerciseDataDC(
    id: id,
    name: id,
    level: Level.BEGINNER,
    category: Category.STRENGTH,
    primaryMuscles: const [Muscle.CHEST],
    secondaryMuscles: const [],
    instructions: const [],
    images: const [],
    isCustomExercise: false,
  );
}

WorkoutSet _set({
  required int id,
  required double load,
  required WeightUnit weightUnit,
  int exerciseId = 0,
}) {
  return WorkoutSet(
    id: id,
    load: load,
    weightUnit: weightUnit,
    reps: 5,
    elapsedTime: 0,
    completed: true,
    setType: SetType.NORMAL,
    exerciseId: exerciseId,
  );
}

WorkoutWithExercisesAndSets _workoutWithSet({
  required int workoutId,
  required int exerciseId,
  required List<WorkoutSet> sets,
  String title = 'Push Day',
}) {
  final now = DateTime(2026, 11, 12, 18);
  return WorkoutWithExercisesAndSets(
    workout: Workout(
      id: workoutId,
      routineId: 0,
      notes: '',
      title: title,
      state: WorkoutState.COMPLETED,
      timeElapsed: 1800,
      position: 0,
      created: now,
      completed: now,
      isTemporal: false,
    ),
    exercisesWithSets: [
      ExerciseWithSets(
        exercise: Exercise(
          id: exerciseId,
          exerciseDataId: 'bench',
          notes: '',
          setMode: SetMode.LOAD,
          restTime: 90,
          position: 0,
          workoutId: workoutId,
        ),
        exerciseDC: _exerciseData('bench'),
        sets: sets,
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository repo;
  late int exerciseId;

  setUp(() async {
    db = AppDatabase.executor(NativeDatabase.memory());
    repo = WorkoutRepository(db);
    await db
        .into(db.exerciseData)
        .insert(
          ExerciseDataCompanion.insert(
            id: 'bench',
            name: 'Bench Press',
            level: Level.BEGINNER,
            primaryMuscles: const [Muscle.CHEST],
            secondaryMuscles: const [Muscle.TRICEPS],
            instructions: const [],
            category: Category.STRENGTH,
            images: const [],
            isCustomExercise: false,
          ),
        );
    final workoutId = await db
        .into(db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            routineId: 0,
            notes: '',
            title: 'Seed',
            state: WorkoutState.ROUTINE,
            timeElapsed: 0,
            created: DateTime(2026, 11, 12),
            completed: DateTime(2026, 11, 12),
          ),
        );
    exerciseId = await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            exerciseDataId: 'bench',
            workoutId: workoutId,
            notes: '',
            setMode: SetMode.LOAD,
            restTime: 90,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('canonical kilogram storage', () {
    test('addSet converts pounds before inserting', () async {
      await repo.addSet(
        _set(
          id: 0,
          load: 100,
          weightUnit: WeightUnit.lbs,
          exerciseId: exerciseId,
        ),
      );

      final stored = await repo.getSetsFromExercise(exerciseId);
      expect(stored.single.load, closeTo(45.359237, 1e-9));
      expect(stored.single.weightUnit, WeightUnit.kg);
    });

    test('updateSet converts pounds before replacing', () async {
      final id = await repo.addSet(
        _set(
          id: 0,
          load: 60,
          weightUnit: WeightUnit.kg,
          exerciseId: exerciseId,
        ),
      );

      await repo.updateSet(
        _set(
          id: id,
          load: 100,
          weightUnit: WeightUnit.lbs,
          exerciseId: exerciseId,
        ),
      );

      final stored = await repo.getSetsFromExercise(exerciseId);
      expect(stored.single.load, closeTo(45.359237, 1e-9));
      expect(stored.single.weightUnit, WeightUnit.kg);
    });

    test('new workout sets are stored in kilograms', () async {
      final workoutId = await repo.addWorkoutWithExercisesAndSets(
        _workoutWithSet(
          workoutId: 0,
          exerciseId: 0,
          sets: [_set(id: 0, load: 45, weightUnit: WeightUnit.lbs)],
        ),
      );

      final stored = await repo.getWorkoutWithExercisesAndSets(workoutId);
      final set = stored!.exercisesWithSets.single.sets.single;
      expect(set.load, closeTo(20.41165665, 1e-9));
      expect(set.weightUnit, WeightUnit.kg);
    });

    test('existing workout sets are converted when updated', () async {
      final workoutId = await repo.addWorkoutWithExercisesAndSets(
        _workoutWithSet(
          workoutId: 0,
          exerciseId: 0,
          sets: [_set(id: 0, load: 60, weightUnit: WeightUnit.kg)],
        ),
      );

      final before = await repo.getWorkoutWithExercisesAndSets(workoutId);
      final existingExercise = before!.exercisesWithSets.single.exercise;
      final existingSet = before.exercisesWithSets.single.sets.single;

      await repo.addWorkoutWithExercisesAndSets(
        _workoutWithSet(
          workoutId: workoutId,
          exerciseId: existingExercise.id,
          sets: [
            _set(
              id: existingSet.id,
              load: 100,
              weightUnit: WeightUnit.lbs,
              exerciseId: existingExercise.id,
            ),
          ],
        ),
      );

      final after = await repo.getWorkoutWithExercisesAndSets(workoutId);
      final set = after!.exercisesWithSets.single.sets.single;
      expect(set.load, closeTo(45.359237, 1e-9));
      expect(set.weightUnit, WeightUnit.kg);
    });

    test(
      'backup import shaped payload lands canonically in kilograms',
      () async {
        // Mirrors how BackupManager builds sets from imported JSON.
        final jsonSet = <String, dynamic>{
          'load': 225.0,
          'weightUnit': 'lbs',
          'reps': 5,
          'elapsedTime': 0,
          'setType': 'NORMAL',
          'completed': true,
        };

        final importedSet = WorkoutSet(
          id: 0,
          load: (jsonSet['load'] as num).toDouble(),
          weightUnit: WeightUnit.values.firstWhere(
            (u) =>
                u.name.toLowerCase() ==
                jsonSet['weightUnit'].toString().toLowerCase(),
            orElse: () => WeightUnit.kg,
          ),
          reps: (jsonSet['reps'] as num).toInt(),
          elapsedTime: (jsonSet['elapsedTime'] as num).toInt(),
          completed: jsonSet['completed'] as bool,
          setType: SetType.NORMAL,
          exerciseId: 0,
        );
        expect(importedSet.weightUnit, WeightUnit.lbs);

        final workoutId = await repo.addWorkoutWithExercisesAndSets(
          _workoutWithSet(workoutId: 0, exerciseId: 0, sets: [importedSet]),
        );

        final stored = await repo.getWorkoutWithExercisesAndSets(workoutId);
        final set = stored!.exercisesWithSets.single.sets.single;
        expect(set.load, closeTo(102.05828325, 1e-8));
        expect(set.weightUnit, WeightUnit.kg);
      },
    );
  });
}
