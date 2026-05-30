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
import 'enums.dart';
import 'relations.dart';
import '../providers/db_provider.dart';

class WorkoutRepository {
  final AppDatabase db;

  WorkoutRepository(this.db);

  Stream<List<Workout>> watchWorkoutsByState(WorkoutState state) {
    return (db.select(db.workouts)
          ..where((w) => w.state.equalsValue(state))
          ..orderBy([
            (w) => OrderingTerm(
                expression: state == WorkoutState.COMPLETED ? w.completed : w.created,
                mode: state == WorkoutState.COMPLETED ? OrderingMode.desc : OrderingMode.asc)
          ]))
        .watch();
  }

  Stream<List<WorkoutWithExercisesAndSets>> watchWorkoutsWithExercisesAndSetsByState(WorkoutState state) {
    final query = db.select(db.workouts)
      ..where((w) => w.state.equalsValue(state))
      ..orderBy([
        (w) => OrderingTerm(
            expression: state == WorkoutState.COMPLETED ? w.completed : w.created,
            mode: state == WorkoutState.COMPLETED ? OrderingMode.desc : OrderingMode.asc)
      ]);

    return query
        .join([
          leftOuterJoin(db.exercises, db.exercises.workoutId.equalsExp(db.workouts.id)),
          leftOuterJoin(db.dataset, db.dataset.id.equalsExp(db.exercises.idExerciseDC)),
          leftOuterJoin(db.sets, db.sets.exerciseId.equalsExp(db.exercises.id)),
        ])
        .watch()
        .map((rows) => _groupRowsToWorkouts(rows));
  }

  Future<WorkoutWithExercisesAndSets?> getWorkoutWithExercisesAndSets(int workoutId) async {
    final query = db.select(db.workouts)..where((w) => w.id.equals(workoutId));
    final rows = await query.join([
      leftOuterJoin(db.exercises, db.exercises.workoutId.equalsExp(db.workouts.id)),
      leftOuterJoin(db.dataset, db.dataset.id.equalsExp(db.exercises.idExerciseDC)),
      leftOuterJoin(db.sets, db.sets.exerciseId.equalsExp(db.exercises.id)),
    ]).get();

    final list = _groupRowsToWorkouts(rows);
    return list.isNotEmpty ? list.first : null;
  }

  Future<Workout?> getWorkoutFromRoutineIDAndState(int routineId, WorkoutState state) async {
    final query = db.select(db.workouts)
      ..where((w) => w.routineId.equals(routineId) & w.state.equalsValue(state));
    return query.getSingleOrNull();
  }

  Future<List<WorkoutWithExercisesAndSets>> getCompletedWorkoutsWithExercisesAndSetsFromRoutine(int routineId) async {
    final query = db.select(db.workouts)
      ..where((w) => w.routineId.equals(routineId) & w.state.equalsValue(WorkoutState.COMPLETED))
      ..orderBy([(w) => OrderingTerm(expression: w.completed, mode: OrderingMode.desc)]);

    final rows = await query.join([
      leftOuterJoin(db.exercises, db.exercises.workoutId.equalsExp(db.workouts.id)),
      leftOuterJoin(db.dataset, db.dataset.id.equalsExp(db.exercises.idExerciseDC)),
      leftOuterJoin(db.sets, db.sets.exerciseId.equalsExp(db.exercises.id)),
    ]).get();

    return _groupRowsToWorkouts(rows);
  }

  Future<int> addWorkout(Workout workout) {
    return db.into(db.workouts).insert(workout.toCompanion(true));
  }

  Future<void> updateWorkout(Workout workout) {
    return db.update(db.workouts).replace(workout);
  }

  Future<void> deleteWorkout(Workout workout) {
    return db.delete(db.workouts).delete(workout);
  }

  Future<int> addExercise(Exercise exercise) {
    return db.into(db.exercises).insert(exercise.toCompanion(true));
  }

  Future<void> updateExercise(Exercise exercise) {
    return db.update(db.exercises).replace(exercise);
  }

  Future<void> deleteExercise(Exercise exercise) {
    return db.delete(db.exercises).delete(exercise);
  }

  Future<int> addSet(WorkoutSet set) {
    return db.into(db.sets).insert(set.toCompanion(true));
  }

  Future<void> updateSet(WorkoutSet set) {
    return db.update(db.sets).replace(set);
  }

  Future<void> deleteSet(WorkoutSet set) {
    return db.delete(db.sets).delete(set);
  }

  Future<List<Exercise>> getExercisesFromWorkout(int workoutId) {
    final query = db.select(db.exercises)
      ..where((e) => e.workoutId.equals(workoutId))
      ..orderBy([(e) => OrderingTerm(expression: e.position, mode: OrderingMode.asc)]);
    return query.get();
  }

  Future<List<WorkoutSet>> getSetsFromExercise(int exerciseId) {
    final query = db.select(db.sets)..where((s) => s.exerciseId.equals(exerciseId));
    return query.get();
  }

  Future<int> addWorkoutWithExercisesAndSets(WorkoutWithExercisesAndSets data) {
    return db.transaction(() async {
      final workout = data.workout;
      int workoutId;

      if (workout.id == 0) {
        final now = DateTime.now();
        workoutId = await db.into(db.workouts).insert(
              WorkoutsCompanion.insert(
                routineId: workout.routineId,
                notes: workout.notes,
                title: workout.title,
                state: workout.state,
                timeElapsed: workout.timeElapsed,
                created: workout.state == WorkoutState.ROUTINE ? now : now,
                completed: now,
              ),
            );
      } else {
        await db.update(db.workouts).replace(workout);
        workoutId = workout.id;
      }

      final exercisesWithSets = data.exercisesWithSets;
      
      // Get old exercises
      final oldExercises = await (db.select(db.exercises)..where((e) => e.workoutId.equals(workoutId))).get();
      final oldExercisesMap = {for (var e in oldExercises) e.id: e};
      final newExercisesMap = {for (var e in exercisesWithSets) e.exercise.id: e};

      // Delete exercises not in new list
      for (final oldId in oldExercisesMap.keys) {
        if (!newExercisesMap.containsKey(oldId)) {
          await (db.delete(db.exercises)..where((e) => e.id.equals(oldId))).go();
        }
      }

      // Add or update exercises and sets
      for (final exWithSet in exercisesWithSets) {
        int exerciseId;
        final exercise = exWithSet.exercise;
        if (oldExercisesMap.containsKey(exercise.id)) {
          await db.update(db.exercises).replace(exercise);
          exerciseId = exercise.id;
        } else {
          exerciseId = await db.into(db.exercises).insert(
                ExercisesCompanion.insert(
                  idExerciseDC: exercise.idExerciseDC,
                  notes: exercise.notes,
                  setMode: exercise.setMode,
                  restTime: exercise.restTime,
                  position: Value(exercise.position),
                  supersetId: Value(exercise.supersetId),
                  workoutId: workoutId,
                ),
              );
        }

        final newSets = exWithSet.sets;
        final oldSets = await (db.select(db.sets)..where((s) => s.exerciseId.equals(exerciseId))).get();
        final oldSetsMap = {for (var s in oldSets) s.id: s};
        final newSetsMap = {for (var s in newSets) s.id: s};

        // Delete sets not in new list
        for (final oldSetId in oldSetsMap.keys) {
          if (!newSetsMap.containsKey(oldSetId)) {
            await (db.delete(db.sets)..where((s) => s.id.equals(oldSetId))).go();
          }
        }

        // Add or update sets
        for (final set in newSets) {
          if (oldSetsMap.containsKey(set.id)) {
            await db.update(db.sets).replace(set);
          } else {
            await db.into(db.sets).insert(
                  SetsCompanion.insert(
                    load: set.load,
                    reps: set.reps,
                    elapsedTime: set.elapsedTime,
                    completed: set.completed,
                    rpe: Value(set.rpe),
                    rir: Value(set.rir),
                    intensityScale: Value(set.intensityScale),
                    exerciseId: exerciseId,
                  ),
                );
          }
        }
      }

      return workoutId;
    });
  }

  List<WorkoutWithExercisesAndSets> _groupRowsToWorkouts(List<TypedResult> rows) {
    final workoutsMap = <int, Workout>{};
    final exercisesMap = <int, Map<int, ExerciseWithSets>>{};

    for (final row in rows) {
      final workout = row.readTable(db.workouts);
      final exercise = row.readTableOrNull(db.exercises);
      final exerciseDC = row.readTableOrNull(db.dataset);
      final set = row.readTableOrNull(db.sets);

      workoutsMap[workout.id] = workout;

      if (exercise != null && exerciseDC != null) {
        final exerciseIdMap = exercisesMap.putIfAbsent(workout.id, () => <int, ExerciseWithSets>{});
        final exerciseWithSets = exerciseIdMap.putIfAbsent(exercise.id, () {
          return ExerciseWithSets(
            exercise: exercise,
            exerciseDC: exerciseDC,
            sets: [],
          );
        });

        if (set != null) {
          if (!exerciseWithSets.sets.any((s) => s.id == set.id)) {
            exerciseWithSets.sets.add(set);
          }
        }
      }
    }

    return workoutsMap.entries.map((entry) {
      final workoutId = entry.key;
      final workout = entry.value;
      final exerciseIdMap = exercisesMap[workoutId] ?? {};
      final exercisesList = exerciseIdMap.values.toList()
        ..sort((a, b) => a.exercise.position.compareTo(b.exercise.position));
      return WorkoutWithExercisesAndSets(
        workout: workout,
        exercisesWithSets: exercisesList,
      );
    }).toList();
  }

  Future<List<WorkoutSet>> getLastPerformanceSets(String exerciseIdDC) async {
    final completedWorkouts = await (db.select(db.workouts)
          ..where((w) => w.state.equalsValue(WorkoutState.COMPLETED))
          ..orderBy([(w) => OrderingTerm(expression: w.completed, mode: OrderingMode.desc)]))
        .get();

    for (final workout in completedWorkouts) {
      final exercises = await (db.select(db.exercises)
            ..where((e) => e.workoutId.equals(workout.id) & e.idExerciseDC.equals(exerciseIdDC)))
          .get();
      if (exercises.isNotEmpty) {
        return await (db.select(db.sets)
              ..where((s) => s.exerciseId.equals(exercises.first.id)))
            .get();
      }
    }
    return [];
  }

  Future<void> prepopulateDefaultWorkoutRoutines() async {
    final routines = await (db.select(db.workouts)
          ..where((w) => w.state.equalsValue(WorkoutState.ROUTINE)))
        .get();
    if (routines.isNotEmpty) return;

    final bpDC = await (db.select(db.dataset)..where((d) => d.id.equals('Barbell_Bench_Press_-_Medium_Grip'))).getSingleOrNull();
    final ipDC = await (db.select(db.dataset)..where((d) => d.id.equals('Barbell_Incline_Bench_Press_-_Medium_Grip'))).getSingleOrNull();

    if (bpDC != null && ipDC != null) {
      final now = DateTime.now();
      final workoutId = await db.into(db.workouts).insert(
            WorkoutsCompanion.insert(
              routineId: 0,
              notes: "A simple but effective push routine.",
              title: "Push Day Routine",
              state: WorkoutState.ROUTINE,
              timeElapsed: 0,
              created: now,
              completed: now,
            ),
          );

      final ex1Id = await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              idExerciseDC: bpDC.id,
              notes: "Focus on form and controlled descent.",
              setMode: SetMode.LOAD,
              restTime: 90,
              position: const Value(0),
              workoutId: workoutId,
            ),
          );

      for (int i = 0; i < 3; i++) {
        await db.into(db.sets).insert(
              SetsCompanion.insert(
                load: 80.0,
                reps: 8,
                elapsedTime: 0,
                completed: false,
                exerciseId: ex1Id,
              ),
            );
      }

      final ex2Id = await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              idExerciseDC: ipDC.id,
              notes: "Control the stretch at the bottom.",
              setMode: SetMode.LOAD,
              restTime: 90,
              position: const Value(1),
              workoutId: workoutId,
            ),
          );

      for (int i = 0; i < 3; i++) {
        await db.into(db.sets).insert(
              SetsCompanion.insert(
                load: 60.0,
                reps: 10,
                elapsedTime: 0,
                completed: false,
                exerciseId: ex2Id,
              ),
            );
      }
    }

    final dlDC = await (db.select(db.dataset)..where((d) => d.id.equals('Barbell_Deadlift'))).getSingleOrNull();
    final bcDC = await (db.select(db.dataset)..where((d) => d.id.equals('Barbell_Curl'))).getSingleOrNull();

    if (dlDC != null && bcDC != null) {
      final now = DateTime.now();
      final workoutId = await db.into(db.workouts).insert(
            WorkoutsCompanion.insert(
              routineId: 0,
              notes: "Classic deadlift and bicep curl combo.",
              title: "Pull Day Routine",
              state: WorkoutState.ROUTINE,
              timeElapsed: 0,
              created: now,
              completed: now,
            ),
          );

      final ex1Id = await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              idExerciseDC: dlDC.id,
              notes: "Keep your back straight and drive with the hips.",
              setMode: SetMode.LOAD,
              restTime: 120,
              position: const Value(0),
              workoutId: workoutId,
            ),
          );

      for (int i = 0; i < 3; i++) {
        await db.into(db.sets).insert(
              SetsCompanion.insert(
                load: 100.0,
                reps: 5,
                elapsedTime: 0,
                completed: false,
                exerciseId: ex1Id,
              ),
            );
      }

      final ex2Id = await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              idExerciseDC: bcDC.id,
              notes: "Do not swing the torso.",
              setMode: SetMode.LOAD,
              restTime: 60,
              position: const Value(1),
              workoutId: workoutId,
            ),
          );

      for (int i = 0; i < 3; i++) {
        await db.into(db.sets).insert(
              SetsCompanion.insert(
                load: 30.0,
                reps: 12,
                elapsedTime: 0,
                completed: false,
                exerciseId: ex2Id,
              ),
            );
      }
    }
  }
}

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final db = ref.watch(dbProvider);
  return WorkoutRepository(db);
});
