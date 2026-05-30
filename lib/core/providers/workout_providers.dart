/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/enums.dart';
import '../db/relations.dart';
import '../db/workout_repository.dart';

final routinesProvider = StreamProvider<List<WorkoutWithExercisesAndSets>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchWorkoutsWithExercisesAndSetsByState(WorkoutState.ROUTINE);
});

final runningWorkoutProvider = StreamProvider<WorkoutWithExercisesAndSets?>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchWorkoutsWithExercisesAndSetsByState(WorkoutState.RUNNING).map((list) => list.firstOrNull);
});
