/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/util/workout_stats_helper.dart';

void main() {
  group('WorkoutStatsHelper Tests', () {
    test('calculateEstimatedOneRepMax uses Brzycki and handles edge cases', () {
      expect(WorkoutStatsHelper.calculateEstimatedOneRepMax(100.0, 1), equals(100.0));
      expect(WorkoutStatsHelper.calculateEstimatedOneRepMax(0.0, 10), equals(0.0));
      expect(WorkoutStatsHelper.calculateEstimatedOneRepMax(100.0, 0), equals(0.0));

      // 100 kg for 10 reps: 100 / (1.0278 - 0.278) = 100 / 0.7498 ≈ 133.36
      final rm10 = WorkoutStatsHelper.calculateEstimatedOneRepMax(100.0, 10);
      expect(rm10, greaterThan(130.0));
      expect(rm10, lessThan(135.0));
    });

    test('calculateExerciseTonnage sums only completed non-warmup sets', () {
      final ex = Exercise(
        id: 1,
        exerciseDataId: 'bench',
        notes: '',
        setMode: SetMode.LOAD,
        restTime: 90,
        position: 0,
        workoutId: 1,
      );
      final exDC = ExerciseDataDC(
        id: 'bench',
        name: 'Bench Press',
        level: Level.INTERMEDIATE,
        category: Category.STRENGTH,
        primaryMuscles: [Muscle.CHEST],
        secondaryMuscles: [Muscle.TRICEPS],
        instructions: const [],
        images: const [],
        isCustomExercise: false,
      );

      final sets = [
        const WorkoutSet(
          id: 1,
          load: 50.0,
          weightUnit: WeightUnit.kg,
          reps: 10,
          elapsedTime: 0,
          completed: true,
          setType: SetType.WARMUP,
          exerciseId: 1,
        ),
        const WorkoutSet(
          id: 2,
          load: 100.0,
          weightUnit: WeightUnit.kg,
          reps: 8,
          elapsedTime: 0,
          completed: true,
          setType: SetType.NORMAL,
          exerciseId: 1,
        ),
        const WorkoutSet(
          id: 3,
          load: 100.0,
          weightUnit: WeightUnit.kg,
          reps: 6,
          elapsedTime: 0,
          completed: false, // not completed
          setType: SetType.NORMAL,
          exerciseId: 1,
        ),
        const WorkoutSet(
          id: 4,
          load: 80.0,
          weightUnit: WeightUnit.kg,
          reps: 10,
          elapsedTime: 0,
          completed: true,
          setType: SetType.DROP,
          exerciseId: 1,
        ),
      ];

      final eWs = ExerciseWithSets(exercise: ex, exerciseDC: exDC, sets: sets);

      // Warmup (50*10=500) ignored.
      // Incomplete (100*6) ignored.
      // Set 2: 100*8 = 800. Set 4: 80*10 = 800. Total = 1600.
      final tonnage = WorkoutStatsHelper.calculateExerciseTonnage(eWs);
      expect(tonnage, equals(1600.0));
    });

    test('countHardSets respects rir <= 4 or rpe >= 6 and ignores warmups', () {
      final workout = Workout(
        id: 1,
        routineId: 0,
        notes: '',
        title: 'Push Day',
        state: WorkoutState.COMPLETED,
        timeElapsed: 3600,
        position: 0,
        created: DateTime.now(),
        completed: DateTime.now(),
        isTemporal: false,
      );

      final ex = Exercise(
        id: 1,
        exerciseDataId: 'bench',
        notes: '',
        setMode: SetMode.LOAD,
        restTime: 90,
        position: 0,
        workoutId: 1,
      );
      final exDC = ExerciseDataDC(
        id: 'bench',
        name: 'Bench Press',
        level: Level.INTERMEDIATE,
        category: Category.STRENGTH,
        primaryMuscles: [Muscle.CHEST],
        secondaryMuscles: [],
        instructions: const [],
        images: const [],
        isCustomExercise: false,
      );

      final sets = [
        const WorkoutSet(
          id: 1,
          load: 50.0,
          weightUnit: WeightUnit.kg,
          reps: 10,
          elapsedTime: 0,
          completed: true,
          setType: SetType.WARMUP,
          rpe: 7.0, // warmup ignored even with high rpe
          exerciseId: 1,
        ),
        const WorkoutSet(
          id: 2,
          load: 100.0,
          weightUnit: WeightUnit.kg,
          reps: 8,
          elapsedTime: 0,
          completed: true,
          setType: SetType.NORMAL,
          rpe: 8.0, // hard set
          rir: 2,
          exerciseId: 1,
        ),
        const WorkoutSet(
          id: 3,
          load: 100.0,
          weightUnit: WeightUnit.kg,
          reps: 8,
          elapsedTime: 0,
          completed: true,
          setType: SetType.NORMAL,
          rpe: 5.0, // rpe < 6, rir > 4 => not hard
          rir: 5,
          exerciseId: 1,
        ),
      ];

      final wWithEx = WorkoutWithExercisesAndSets(
        workout: workout,
        exercisesWithSets: [
          ExerciseWithSets(exercise: ex, exerciseDC: exDC, sets: sets),
        ],
      );

      expect(WorkoutStatsHelper.countHardSets(wWithEx), equals(1));
      expect(WorkoutStatsHelper.calculateWorkoutDensity(wWithEx), greaterThan(0.0));
      expect(WorkoutStatsHelper.getPrimaryMuscleImpacted(wWithEx), equals(Muscle.CHEST));
    });
  });
}
