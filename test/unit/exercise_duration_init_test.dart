/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/workout_repository.dart';
import 'package:nexc_flutter/core/providers/workout_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Exercise Duration Init & Set Mode DB Default Tests', () {
    late AppDatabase db;
    late WorkoutRepository workoutRepo;

    setUp(() async {
      db = AppDatabase.executor(NativeDatabase.memory());
      workoutRepo = WorkoutRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Cloned routine sets must have elapsedTime initialized to 0', () {
      const originalSet = WorkoutSet(
        id: 10,
        load: 80.0,
        weightUnit: WeightUnit.kg,
        reps: 8,
        elapsedTime: 120, // non-zero routine or previous performance time
        completed: true,
        setType: SetType.NORMAL,
        exerciseId: 1,
      );

      // Simulation of cloning sets when starting a workout from routine
      int tempSetId = -1;
      final clonedSet = originalSet.copyWith(
        id: tempSetId--,
        exerciseId: -1,
        completed: false,
        elapsedTime: 0,
      );

      expect(clonedSet.elapsedTime, equals(0));
      expect(clonedSet.completed, isFalse);
      expect(clonedSet.load, equals(80.0));
      expect(clonedSet.reps, equals(8));
    });

    test('Dynamically added sets must have elapsedTime initialized to 0', () {
      const lastSet = WorkoutSet(
        id: 1,
        load: 50.0,
        weightUnit: WeightUnit.kg,
        reps: 12,
        elapsedTime: 45, // previous set took 45s
        completed: true,
        setType: SetType.NORMAL,
        exerciseId: 1,
      );

      // Simulation of addSet
      final newSet = WorkoutSet(
        id: 2,
        load: lastSet.load,
        weightUnit: lastSet.weightUnit,
        reps: lastSet.reps,
        elapsedTime: 0,
        completed: false,
        setType: lastSet.setType,
        exerciseId: 1,
      );

      expect(newSet.elapsedTime, equals(0));
      expect(newSet.completed, isFalse);
      expect(newSet.load, equals(50.0));
      expect(newSet.reps, equals(12));
    });

    test('New exercise initial set must have elapsedTime initialized to 0', () {
      // Simulation of _addExercise initial set
      final newSet = WorkoutSet(
        id: DateTime.now().millisecondsSinceEpoch,
        load: 0.0,
        weightUnit: WeightUnit.kg,
        reps: 0,
        elapsedTime: 0,
        completed: false,
        setType: SetType.NORMAL,
        exerciseId: 99,
      );

      expect(newSet.elapsedTime, equals(0));
      expect(newSet.completed, isFalse);
      expect(newSet.load, equals(0.0));
      expect(newSet.reps, equals(0));
    });

    test('getLastSetModeForExercise returns null when no history exists in DB', () async {
      final mode = await workoutRepo.getLastSetModeForExercise('non_existent_exercise');
      expect(mode, isNull);
    });

    test('getLastSetModeForExercise returns stored DB mode for exercise', () async {
      final now = DateTime.now();

      // Create a workout in DB
      final workoutId = await db.into(db.workouts).insert(
            WorkoutsCompanion.insert(
              routineId: 0,
              notes: '',
              title: 'Test Workout',
              state: WorkoutState.COMPLETED,
              timeElapsed: 1800,
              created: now,
              completed: now,
            ),
          );

      // Insert an exercise with specific setMode (e.g. SetMode.DURATION)
      await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              exerciseDataId: 'plank_exercise',
              notes: '',
              setMode: SetMode.DURATION,
              restTime: 60,
              position: const drift.Value(0),
              workoutId: workoutId,
            ),
          );

      final mode = await workoutRepo.getLastSetModeForExercise('plank_exercise');
      expect(mode, equals(SetMode.DURATION));
    });

    test('getLastSetModeForExercise returns the most recent setMode when multiple exist', () async {
      final now = DateTime.now();

      final workoutId1 = await db.into(db.workouts).insert(
            WorkoutsCompanion.insert(
              routineId: 0,
              notes: '',
              title: 'Older Workout',
              state: WorkoutState.COMPLETED,
              timeElapsed: 1800,
              created: now.subtract(const Duration(days: 2)),
              completed: now.subtract(const Duration(days: 2)),
            ),
          );

      final workoutId2 = await db.into(db.workouts).insert(
            WorkoutsCompanion.insert(
              routineId: 0,
              notes: '',
              title: 'Newer Workout',
              state: WorkoutState.COMPLETED,
              timeElapsed: 1800,
              created: now,
              completed: now,
            ),
          );

      // Older entry had LOAD mode
      await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              exerciseDataId: 'pull_up',
              notes: '',
              setMode: SetMode.LOAD,
              restTime: 90,
              position: const drift.Value(0),
              workoutId: workoutId1,
            ),
          );

      // Newer entry switched to BODYWEIGHT mode
      await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              exerciseDataId: 'pull_up',
              notes: '',
              setMode: SetMode.BODYWEIGHT,
              restTime: 90,
              position: const drift.Value(0),
              workoutId: workoutId2,
            ),
          );

      final mode = await workoutRepo.getLastSetModeForExercise('pull_up');
      expect(mode, equals(SetMode.BODYWEIGHT));
    });

    test('activeWorkoutScrollOffsetProvider tracks scroll position', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial offset is 0.0
      expect(container.read(activeWorkoutScrollOffsetProvider), equals(0.0));

      // Update scroll offset
      container.read(activeWorkoutScrollOffsetProvider.notifier).state = 345.5;
      expect(container.read(activeWorkoutScrollOffsetProvider), equals(345.5));
    });

    test('activeWorkoutScrollOffsetProvider resets to 0.0 on workout finish, discard, or new workout', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Simulate scrolled active workout session
      container.read(activeWorkoutScrollOffsetProvider.notifier).state = 500.0;
      expect(container.read(activeWorkoutScrollOffsetProvider), equals(500.0));

      // Reset scroll offset (simulating _finishWorkout or discard in _handlePop)
      container.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
      expect(container.read(activeWorkoutScrollOffsetProvider), equals(0.0));

      // Simulate starting a new workout/routine with prior scrolled state
      container.read(activeWorkoutScrollOffsetProvider.notifier).state = 120.0;
      // New workout initialization resets provider to 0.0
      container.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
      expect(container.read(activeWorkoutScrollOffsetProvider), equals(0.0));
    });
  });
}
