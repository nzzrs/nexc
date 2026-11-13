/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import '../db/relations.dart';

/// Returns [routine] with the values of the completed sets of [workout].
///
/// Exercises are matched by exercise data id and occurrence index, and only
/// when the set mode is identical. For every routine set whose matching workout
/// set is completed, `load`, `reps` and `elapsedTime` are copied. All other
/// fields (ids, ownership, set count and completion flags) are preserved.
List<ExerciseWithSets> withValuesOfCompletedSets({
  required List<ExerciseWithSets> routine,
  required List<ExerciseWithSets> workout,
}) {
  final updated = <ExerciseWithSets>[];

  for (var index = 0; index < routine.length; index++) {
    final routineExercise = routine[index];
    final dataId = routineExercise.exerciseDC.id;
    final occurrence = routine
        .take(index)
        .where((exercise) => exercise.exerciseDC.id == dataId)
        .length;
    final matches = workout
        .where((exercise) => exercise.exerciseDC.id == dataId)
        .toList();
    final workoutExercise = occurrence < matches.length
        ? matches[occurrence]
        : null;

    if (workoutExercise == null ||
        workoutExercise.exercise.setMode != routineExercise.exercise.setMode) {
      updated.add(routineExercise);
      continue;
    }

    final sets = <WorkoutSet>[];
    for (var setIndex = 0; setIndex < routineExercise.sets.length; setIndex++) {
      final routineSet = routineExercise.sets[setIndex];
      final workoutSet = setIndex < workoutExercise.sets.length
          ? workoutExercise.sets[setIndex]
          : null;

      if (workoutSet != null && workoutSet.completed) {
        sets.add(
          routineSet.copyWith(
            load: workoutSet.load,
            reps: workoutSet.reps,
            elapsedTime: workoutSet.elapsedTime,
          ),
        );
      } else {
        sets.add(routineSet);
      }
    }

    updated.add(routineExercise.copyWith(sets: sets));
  }

  return updated;
}
