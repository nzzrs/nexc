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

ExerciseWithSets _exercise({
  required String dataId,
  required int exerciseId,
  required int workoutId,
  required List<WorkoutSet> sets,
}) {
  return ExerciseWithSets(
    exercise: Exercise(
      id: exerciseId,
      exerciseDataId: dataId,
      notes: '',
      setMode: SetMode.LOAD,
      restTime: 90,
      position: 0,
      workoutId: workoutId,
    ),
    exerciseDC: _exerciseData(dataId),
    sets: sets,
  );
}

Workout _workout({
  required int routineId,
  required WorkoutState state,
  required String title,
  required DateTime now,
}) {
  return Workout(
    id: 0,
    routineId: routineId,
    notes: '',
    title: title,
    state: state,
    timeElapsed: 1800,
    position: 0,
    created: now,
    completed: now,
    isTemporal: false,
  );
}

WorkoutSet _set({
  required int id,
  required int exerciseId,
  required double load,
  required int reps,
  required bool completed,
}) {
  return WorkoutSet(
    id: id,
    load: load,
    weightUnit: WeightUnit.kg,
    reps: reps,
    elapsedTime: 0,
    completed: completed,
    setType: SetType.NORMAL,
    exerciseId: exerciseId,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('updateRoutineWithCompletedSetValues', () {
    late AppDatabase db;
    late WorkoutRepository repo;

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
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'updates routine rows and leaves the completed workout untouched',
      () async {
        final now = DateTime.now();

        final routineExercises = [
          _exercise(
            dataId: 'bench',
            exerciseId: 100,
            workoutId: 0,
            sets: [
              _set(
                id: 1,
                exerciseId: 100,
                load: 50.0,
                reps: 8,
                completed: false,
              ),
              _set(
                id: 2,
                exerciseId: 100,
                load: 50.0,
                reps: 8,
                completed: false,
              ),
            ],
          ),
        ];
        final routineWorkoutId = await repo.addWorkoutWithExercisesAndSets(
          WorkoutWithExercisesAndSets(
            workout: _workout(
              routineId: 0,
              state: WorkoutState.ROUTINE,
              title: 'Push Day',
              now: now,
            ),
            exercisesWithSets: routineExercises,
          ),
        );

        final routineBefore = await repo.getWorkoutWithExercisesAndSets(
          routineWorkoutId,
        );
        expect(routineBefore, isNotNull);
        final routineExerciseId =
            routineBefore!.exercisesWithSets.single.exercise.id;
        final routineSetIds = routineBefore.exercisesWithSets.single.sets
            .map((s) => s.id)
            .toList();

        final workoutExercises = [
          _exercise(
            dataId: 'bench',
            exerciseId: 200,
            workoutId: 0,
            sets: [
              _set(
                id: 101,
                exerciseId: 200,
                load: 55.0,
                reps: 6,
                completed: true,
              ),
              _set(
                id: 102,
                exerciseId: 200,
                load: 60.0,
                reps: 5,
                completed: false,
              ),
            ],
          ),
        ];
        final completedWorkoutId = await repo.addWorkoutWithExercisesAndSets(
          WorkoutWithExercisesAndSets(
            workout: _workout(
              routineId: routineWorkoutId,
              state: WorkoutState.COMPLETED,
              title: 'Push Day',
              now: now.add(const Duration(hours: 1)),
            ),
            exercisesWithSets: workoutExercises,
          ),
        );

        final completedBefore = await repo.getWorkoutWithExercisesAndSets(
          completedWorkoutId,
        );
        expect(completedBefore, isNotNull);

        final updatedRoutine = await repo.updateRoutineWithCompletedSetValues(
          routineId: routineWorkoutId,
          workoutExercises: workoutExercises,
        );

        expect(updatedRoutine, isNotNull);
        expect(updatedRoutine!.workout.id, routineWorkoutId);
        expect(updatedRoutine.workout.state, WorkoutState.ROUTINE);
        expect(updatedRoutine.workout.title, 'Push Day');
        expect(
          updatedRoutine.exercisesWithSets.single.exercise.id,
          routineExerciseId,
        );
        expect(
          updatedRoutine.exercisesWithSets.single.sets.map((s) => s.id),
          routineSetIds,
        );
        expect(
          updatedRoutine.exercisesWithSets.single.sets.map((s) => s.load),
          [55.0, 50.0],
        );
        expect(
          updatedRoutine.exercisesWithSets.single.sets.map((s) => s.reps),
          [6, 8],
        );

        final routineFromDb = await repo.getWorkoutWithExercisesAndSets(
          routineWorkoutId,
        );
        expect(routineFromDb, isNotNull);
        expect(routineFromDb!.workout.state, WorkoutState.ROUTINE);
        expect(routineFromDb.exercisesWithSets.single.sets.map((s) => s.load), [
          55.0,
          50.0,
        ]);
        expect(routineFromDb.exercisesWithSets.single.sets.map((s) => s.reps), [
          6,
          8,
        ]);
        expect(
          routineFromDb.exercisesWithSets.single.sets.map((s) => s.completed),
          [false, false],
        );

        final completedAfter = await repo.getWorkoutWithExercisesAndSets(
          completedWorkoutId,
        );
        expect(completedAfter, isNotNull);
        expect(completedAfter!.workout.state, WorkoutState.COMPLETED);
        expect(completedAfter.workout.routineId, routineWorkoutId);
        expect(
          completedAfter.exercisesWithSets.single.sets.map((s) => s.load),
          [55.0, 60.0],
        );
        expect(
          completedAfter.exercisesWithSets.single.sets.map((s) => s.reps),
          [6, 5],
        );
        expect(
          completedAfter.exercisesWithSets.single.sets.map((s) => s.completed),
          [true, false],
        );
      },
    );

    test('returns null when the routine does not exist', () async {
      final result = await repo.updateRoutineWithCompletedSetValues(
        routineId: 999,
        workoutExercises: const [],
      );

      expect(result, isNull);
    });
  });
}
