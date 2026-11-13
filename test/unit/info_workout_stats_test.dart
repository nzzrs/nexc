/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/util/workout_stats_helper.dart';

Exercise _exercise({required int id, required String dataId}) {
  return Exercise(
    id: id,
    exerciseDataId: dataId,
    notes: '',
    setMode: SetMode.LOAD,
    restTime: 90,
    position: id,
    workoutId: 1,
  );
}

ExerciseDataDC _exerciseData({
  required String id,
  required String name,
  required Muscle primaryMuscle,
}) {
  return ExerciseDataDC(
    id: id,
    name: name,
    level: Level.INTERMEDIATE,
    category: Category.STRENGTH,
    primaryMuscles: [primaryMuscle],
    secondaryMuscles: const [],
    instructions: const [],
    images: const [],
    isCustomExercise: false,
  );
}

WorkoutSet _set({
  required int id,
  required double load,
  required int reps,
  bool completed = true,
  SetType setType = SetType.NORMAL,
}) {
  return WorkoutSet(
    id: id,
    load: load,
    weightUnit: WeightUnit.kg,
    reps: reps,
    elapsedTime: 0,
    completed: completed,
    setType: setType,
    exerciseId: 1,
  );
}

WorkoutWithExercisesAndSets _workout(List<ExerciseWithSets> exercises) {
  return WorkoutWithExercisesAndSets(
    workout: Workout(
      id: 1,
      routineId: 0,
      notes: '',
      title: 'Test Workout',
      state: WorkoutState.COMPLETED,
      timeElapsed: 1800,
      created: DateTime(2026, 1, 1),
      completed: DateTime(2026, 1, 1),
      isTemporal: false,
    ),
    exercisesWithSets: exercises,
  );
}

void main() {
  group('InfoWorkoutScreen performance metrics', () {
    test(
      'getBestEstimatedOneRepMax picks the highest completed working set',
      () {
        final bench = ExerciseWithSets(
          exercise: _exercise(id: 1, dataId: 'bench'),
          exerciseDC: _exerciseData(
            id: 'bench',
            name: 'Bench Press',
            primaryMuscle: Muscle.CHEST,
          ),
          sets: [
            _set(id: 1, load: 100, reps: 1, setType: SetType.WARMUP),
            _set(id: 2, load: 100, reps: 8),
            _set(id: 3, load: 120, reps: 4, completed: false),
          ],
        );
        final squat = ExerciseWithSets(
          exercise: _exercise(id: 2, dataId: 'squat'),
          exerciseDC: _exerciseData(
            id: 'squat',
            name: 'Barbell Squat',
            primaryMuscle: Muscle.QUADRICEPS,
          ),
          sets: [
            _set(id: 4, load: 150, reps: 5),
            _set(id: 5, load: 60, reps: 10, setType: SetType.WARMUP),
          ],
        );

        final best = WorkoutStatsHelper.getBestEstimatedOneRepMax(
          _workout([bench, squat]),
        );

        expect(best, isNotNull);
        expect(best!.exerciseName, equals('Barbell Squat'));
        expect(best.estimatedOneRepMax, greaterThan(160.0));
        expect(best.estimatedOneRepMax, lessThan(175.0));
      },
    );

    test(
      'getBestEstimatedOneRepMax returns null without completed working sets',
      () {
        final bench = ExerciseWithSets(
          exercise: _exercise(id: 1, dataId: 'bench'),
          exerciseDC: _exerciseData(
            id: 'bench',
            name: 'Bench Press',
            primaryMuscle: Muscle.CHEST,
          ),
          sets: [
            _set(id: 1, load: 100, reps: 8, completed: false),
            _set(id: 2, load: 100, reps: 10, setType: SetType.WARMUP),
          ],
        );

        expect(
          WorkoutStatsHelper.getBestEstimatedOneRepMax(_workout([bench])),
          isNull,
        );
        expect(
          WorkoutStatsHelper.getBestEstimatedOneRepMax(
            _workout(const <ExerciseWithSets>[]),
          ),
          isNull,
        );
      },
    );
  });
}
