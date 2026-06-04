/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
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

  DateTime weekStart(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    // weekday is 1 for Monday, 7 for Sunday.
    return cleanDate.subtract(Duration(days: date.weekday - 1));
  }

  final now = DateTime.now();
  final currentWeekStart = weekStart(now);
  final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));

  final workoutWeeks = workouts.map((w) => weekStart(w.workout.completed)).toSet();

  DateTime checkWeek;
  if (workoutWeeks.contains(currentWeekStart)) {
    checkWeek = currentWeekStart;
  } else if (workoutWeeks.contains(previousWeekStart)) {
    checkWeek = previousWeekStart;
  } else {
    return 0;
  }

  int streak = 0;
  while (workoutWeeks.contains(checkWeek)) {
    streak++;
    checkWeek = checkWeek.subtract(const Duration(days: 7));
  }

  return streak;
});

final allMeasurementsProvider = StreamProvider<List<BodyMeasurement>>((ref) {
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.getAllMeasurements();
});

final allAdvancedBodyMeasurementsProvider = StreamProvider<List<AdvancedBodyMeasurement>>((ref) {
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.getAllAdvancedBodyMeasurements();
});

final allSleepMeasurementsProvider = StreamProvider<List<SleepMeasurement>>((ref) {
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.getAllSleepMeasurements();
});

final allAdvancedSleepMeasurementsProvider = StreamProvider<List<AdvancedSleepMeasurement>>((ref) {
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.getAllAdvancedSleepMeasurements();
});

final allActivityMeasurementsProvider = StreamProvider<List<ActivityMeasurement>>((ref) {
  final repo = ref.watch(measurementRepositoryProvider);
  return repo.getAllActivityMeasurements();
});
