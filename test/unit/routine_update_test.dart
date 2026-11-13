/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/util/routine_update.dart';

ExerciseDataDC _dc(String id) {
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

ExerciseWithSets _exercise({
  required String dataId,
  required int exerciseId,
  required SetMode setMode,
  required List<WorkoutSet> sets,
}) {
  return ExerciseWithSets(
    exercise: Exercise(
      id: exerciseId,
      exerciseDataId: dataId,
      notes: '',
      setMode: setMode,
      restTime: 90,
      position: 0,
      workoutId: 1,
    ),
    exerciseDC: _dc(dataId),
    sets: sets,
  );
}

WorkoutSet _set({
  required int id,
  required int exerciseId,
  double load = 0.0,
  int reps = 0,
  int elapsedTime = 0,
  bool completed = false,
  SetType setType = SetType.NORMAL,
  WeightUnit weightUnit = WeightUnit.kg,
}) {
  return WorkoutSet(
    id: id,
    load: load,
    weightUnit: weightUnit,
    reps: reps,
    elapsedTime: elapsedTime,
    completed: completed,
    setType: setType,
    exerciseId: exerciseId,
  );
}

void main() {
  group('withValuesOfCompletedSets', () {
    test('copies values of completed sets only and keeps routine identity', () {
      final routine = [
        _exercise(
          dataId: 'bench',
          exerciseId: 11,
          setMode: SetMode.LOAD,
          sets: [
            _set(id: 1, exerciseId: 11, load: 50.0, reps: 8),
            _set(id: 2, exerciseId: 11, load: 50.0, reps: 8),
            _set(id: 3, exerciseId: 11, load: 50.0, reps: 8),
          ],
        ),
      ];
      final workout = [
        _exercise(
          dataId: 'bench',
          exerciseId: 99,
          setMode: SetMode.LOAD,
          sets: [
            _set(id: 101, exerciseId: 99, load: 55.0, reps: 6, completed: true),
            _set(id: 102, exerciseId: 99, load: 60.0, reps: 5),
          ],
        ),
      ];

      final updated = withValuesOfCompletedSets(
        routine: routine,
        workout: workout,
      ).single;

      expect(updated.exercise.id, 11);
      expect(updated.sets.map((s) => s.id), [1, 2, 3]);
      expect(updated.sets.map((s) => s.load), [55.0, 50.0, 50.0]);
      expect(updated.sets.map((s) => s.reps), [6, 8, 8]);
      expect(updated.sets.map((s) => s.completed), [false, false, false]);
      expect(
        updated.sets.map((s) => s.weightUnit),
        everyElement(WeightUnit.kg),
      );
    });

    test('keeps the number of sets of the routine', () {
      final routine = [
        _exercise(
          dataId: 'bench',
          exerciseId: 11,
          setMode: SetMode.BODYWEIGHT,
          sets: [_set(id: 1, exerciseId: 11, reps: 10)],
        ),
      ];
      final workout = [
        _exercise(
          dataId: 'bench',
          exerciseId: 99,
          setMode: SetMode.BODYWEIGHT,
          sets: [
            _set(id: 101, exerciseId: 99, reps: 12, completed: true),
            _set(id: 102, exerciseId: 99, reps: 11, completed: true),
          ],
        ),
      ];

      final updated = withValuesOfCompletedSets(
        routine: routine,
        workout: workout,
      ).single;

      expect(updated.sets.map((s) => s.reps), [12]);
    });

    test('ignores exercises whose set mode changed', () {
      final routine = [
        _exercise(
          dataId: 'bench',
          exerciseId: 11,
          setMode: SetMode.LOAD,
          sets: [_set(id: 1, exerciseId: 11, load: 50.0, reps: 8)],
        ),
      ];
      final workout = [
        _exercise(
          dataId: 'bench',
          exerciseId: 99,
          setMode: SetMode.BODYWEIGHT,
          sets: [_set(id: 101, exerciseId: 99, reps: 12, completed: true)],
        ),
      ];

      final updated = withValuesOfCompletedSets(
        routine: routine,
        workout: workout,
      );

      expect(updated.single.exercise.setMode, routine.single.exercise.setMode);
      expect(updated.single.sets.single.id, 1);
      expect(updated.single.sets.single.load, 50.0);
      expect(updated.single.sets.single.reps, 8);
    });

    test('ignores exercises missing from the workout', () {
      final routine = [
        _exercise(
          dataId: 'bench',
          exerciseId: 11,
          setMode: SetMode.LOAD,
          sets: [_set(id: 1, exerciseId: 11, load: 50.0, reps: 8)],
        ),
      ];
      final workout = [
        _exercise(
          dataId: 'squat',
          exerciseId: 99,
          setMode: SetMode.LOAD,
          sets: [
            _set(
              id: 101,
              exerciseId: 99,
              load: 100.0,
              reps: 5,
              completed: true,
            ),
          ],
        ),
      ];

      final updated = withValuesOfCompletedSets(
        routine: routine,
        workout: workout,
      );

      expect(updated.single.exercise.id, 11);
      expect(updated.single.sets.single.load, 50.0);
      expect(updated.single.sets.single.reps, 8);
    });

    test('matches repeated exercises by occurrence in order', () {
      final routine = [
        _exercise(
          dataId: 'running',
          exerciseId: 11,
          setMode: SetMode.DURATION,
          sets: [_set(id: 1, exerciseId: 11, elapsedTime: 60)],
        ),
        _exercise(
          dataId: 'running',
          exerciseId: 12,
          setMode: SetMode.DURATION,
          sets: [_set(id: 2, exerciseId: 12, elapsedTime: 60)],
        ),
      ];
      final workout = [
        _exercise(
          dataId: 'running',
          exerciseId: 99,
          setMode: SetMode.DURATION,
          sets: [
            _set(id: 101, exerciseId: 99, elapsedTime: 300, completed: true),
          ],
        ),
        _exercise(
          dataId: 'running',
          exerciseId: 100,
          setMode: SetMode.DURATION,
          sets: [
            _set(id: 102, exerciseId: 100, elapsedTime: 120, completed: true),
          ],
        ),
      ];

      final updated = withValuesOfCompletedSets(
        routine: routine,
        workout: workout,
      );

      expect(updated.map((e) => e.sets.single.elapsedTime), [300, 120]);
      expect(updated.map((e) => e.sets.single.id), [1, 2]);
    });

    test('ignores workout sets beyond the routine range', () {
      final routine = [
        _exercise(
          dataId: 'bench',
          exerciseId: 11,
          setMode: SetMode.LOAD,
          sets: [_set(id: 1, exerciseId: 11, load: 50.0, reps: 8)],
        ),
      ];
      final workout = [
        _exercise(
          dataId: 'bench',
          exerciseId: 99,
          setMode: SetMode.LOAD,
          sets: [
            _set(id: 101, exerciseId: 99, load: 55.0, reps: 6, completed: true),
            _set(id: 102, exerciseId: 99, load: 60.0, reps: 5, completed: true),
          ],
        ),
      ];

      final updated = withValuesOfCompletedSets(
        routine: routine,
        workout: workout,
      ).single;

      expect(updated.sets.length, 1);
      expect(updated.sets.single.load, 55.0);
      expect(updated.sets.single.reps, 6);
    });

    test('leaves routine untouched when workout has no completed sets', () {
      final routine = [
        _exercise(
          dataId: 'bench',
          exerciseId: 11,
          setMode: SetMode.LOAD,
          sets: [_set(id: 1, exerciseId: 11, load: 50.0, reps: 8)],
        ),
      ];
      final workout = [
        _exercise(
          dataId: 'bench',
          exerciseId: 99,
          setMode: SetMode.LOAD,
          sets: [_set(id: 101, exerciseId: 99, load: 55.0, reps: 6)],
        ),
      ];

      final updated = withValuesOfCompletedSets(
        routine: routine,
        workout: workout,
      ).single;

      expect(updated.sets.single.load, 50.0);
      expect(updated.sets.single.reps, 8);
      expect(updated.sets.single.completed, isFalse);
    });
  });
}
