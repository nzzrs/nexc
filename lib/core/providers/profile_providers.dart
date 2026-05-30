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
import '../db/meal_repository.dart';
import '../db/measurement_repository.dart';

enum WorkoutChart { DURATION, VOLUME, REPS }

class Point {
  final List<double> yValues;
  final String xValue;
  final int? workoutId;

  Point({
    required this.yValues,
    required this.xValue,
    this.workoutId,
  });
}

final completedWorkoutsProvider = StreamProvider<List<WorkoutWithExercisesAndSets>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchWorkoutsWithExercisesAndSetsByState(WorkoutState.COMPLETED);
});

final profileMealLogsProvider = StreamProvider<List<MealPlanWithMealsAndItems>>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getMealPlansWithMealsAndItemsByState(MealPlanState.LOGGED);
});

final workoutChartModeProvider = StateProvider<WorkoutChart>((ref) {
  return WorkoutChart.DURATION;
});

final profilePointsProvider = FutureProvider<List<Point>>((ref) async {
  final workouts = ref.watch(completedWorkoutsProvider).value ?? [];
  final chartMode = ref.watch(workoutChartModeProvider);
  final measurementRepo = ref.watch(measurementRepositoryProvider);

  final List<Point> points = [];

  for (final w in workouts) {
    final measurement = await measurementRepo.getLastMeasurementByCutoff(w.workout.completed);
    final bodyWeight = measurement?.bodyWeight ?? 0.0;

    double yVal = 0.0;
    switch (chartMode) {
      case WorkoutChart.DURATION:
        yVal = w.workout.timeElapsed / 60.0;
        break;
      case WorkoutChart.VOLUME:
        double totalVol = 0.0;
        for (final exe in w.exercisesWithSets) {
          final includeBodyweight = exe.exercise.setMode == SetMode.BODYWEIGHT ||
              exe.exercise.setMode == SetMode.BODYWEIGHT_WITH_LOAD;

          double exeVol = 0.0;
          for (final set in exe.sets) {
            if (set.completed) {
              exeVol += (set.load + (includeBodyweight ? bodyWeight : 0.0)) * set.reps;
            }
          }
          totalVol += exeVol;
        }
        yVal = totalVol;
        break;
      case WorkoutChart.REPS:
        int totalReps = 0;
        for (final exe in w.exercisesWithSets) {
          for (final set in exe.sets) {
            if (set.completed) {
              totalReps += set.reps;
            }
          }
        }
        yVal = totalReps.toDouble();
        break;
    }

    final dateStr =
        "${w.workout.completed.month}/${w.workout.completed.day}/${w.workout.completed.year.toString().substring(w.workout.completed.year.toString().length - 2)}";

    points.add(Point(
      yValues: [yVal],
      xValue: dateStr,
      workoutId: w.workout.id,
    ));
  }

  // Reverse to make it chronological (workouts query is ordered by completed desc)
  return points.reversed.toList();
});

final profileWeekStreakProvider = Provider<int>((ref) {
  final workouts = ref.watch(completedWorkoutsProvider).value ?? [];
  if (workouts.isEmpty) return 0;

  final now = DateTime.now();
  final mostRecentWorkoutDate = workouts.first.workout.completed;

  if (now.difference(mostRecentWorkoutDate).inDays > 7) {
    return 0;
  }

  int breakIndex = -1;
  for (int i = 0; i < workouts.length - 1; i++) {
    final newerWorkout = workouts[i];
    final olderWorkout = workouts[i + 1];
    final daysBetween = newerWorkout.workout.completed.difference(olderWorkout.workout.completed).inDays;
    if (daysBetween > 7) {
      breakIndex = i;
      break;
    }
  }

  final DateTime streakStartDate;
  if (breakIndex == -1) {
    streakStartDate = workouts.last.workout.completed;
  } else {
    streakStartDate = workouts[breakIndex].workout.completed;
  }

  final weeks = (now.difference(streakStartDate).inDays / 7).floor();
  return weeks;
});
