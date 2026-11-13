/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit / Nexc is subject to additional terms covering author attribution and trademark usage.
 */

import '../db/enums.dart';
import '../db/relations.dart';

/// Best estimated one-rep max found across a workout's completed working sets.
class BestEstimatedOneRepMax {
  final String exerciseName;
  final double estimatedOneRepMax;

  const BestEstimatedOneRepMax({
    required this.exerciseName,
    required this.estimatedOneRepMax,
  });
}

class WorkoutStatsHelper {
  /// Calculate estimated 1 Rep Max (1RM) using Brzycki formula:
  /// 1RM = load / (1.0278 - 0.0278 * reps)
  /// For reps == 1, 1RM = load. Returns 0.0 if reps <= 0 or load <= 0.
  static double calculateEstimatedOneRepMax(double load, int reps) {
    if (load <= 0 || reps <= 0) return 0.0;
    if (reps == 1) return load;
    if (reps >= 37) {
      // Brzycki formula breaks down above ~36 reps; fallback to Epley
      return load * (1.0 + reps / 30.0);
    }
    final oneRm = load / (1.0278 - (0.0278 * reps));
    return oneRm > 0 ? oneRm : 0.0;
  }

  /// Estimated 1RM for an entire exercise (highest estimated 1RM across completed non-warmup sets).
  static double calculateExerciseEstimatedOneRepMax(
    ExerciseWithSets exerciseWithSets,
  ) {
    double bestOneRm = 0.0;
    for (final s in exerciseWithSets.sets) {
      if (!s.completed) continue;
      if (s.setType == SetType.WARMUP) continue;
      final estimate = calculateEstimatedOneRepMax(s.load, s.reps);
      if (estimate > bestOneRm) {
        bestOneRm = estimate;
      }
    }
    return bestOneRm;
  }

  /// Best estimated 1RM exercise for a workout. Returns null when no completed
  /// working set has a positive load and rep count.
  static BestEstimatedOneRepMax? getBestEstimatedOneRepMax(
    WorkoutWithExercisesAndSets workoutWithExercisesAndSets,
  ) {
    BestEstimatedOneRepMax? best;
    for (final eWs in workoutWithExercisesAndSets.exercisesWithSets) {
      final oneRm = calculateExerciseEstimatedOneRepMax(eWs);
      if (oneRm <= 0) continue;
      if (best == null || oneRm > best.estimatedOneRepMax) {
        best = BestEstimatedOneRepMax(
          exerciseName: eWs.exerciseDC.name,
          estimatedOneRepMax: oneRm,
        );
      }
    }
    return best;
  }

  /// Total tonnage / volume for an exercise summing only completed sets that are NOT warmup sets.
  static double calculateExerciseTonnage(ExerciseWithSets exerciseWithSets) {
    double total = 0.0;
    for (final s in exerciseWithSets.sets) {
      if (s.completed && s.setType != SetType.WARMUP) {
        total += s.load * s.reps;
      }
    }
    return total;
  }

  /// Total tonnage / volume for a workout summing only completed sets that are NOT warmup sets.
  static double calculateWorkoutTonnage(
    WorkoutWithExercisesAndSets workoutWithExercisesAndSets,
  ) {
    double total = 0.0;
    for (final eWs in workoutWithExercisesAndSets.exercisesWithSets) {
      total += calculateExerciseTonnage(eWs);
    }
    return total;
  }

  /// Hard sets count (sets where completed == true, setType != WARMUP, and (rir <= 4 or rpe >= 6)).
  static int countHardSets(
    WorkoutWithExercisesAndSets workoutWithExercisesAndSets,
  ) {
    int count = 0;
    for (final eWs in workoutWithExercisesAndSets.exercisesWithSets) {
      for (final s in eWs.sets) {
        if (!s.completed || s.setType == SetType.WARMUP) continue;
        final isHardRir = s.rir != null && s.rir! <= 4;
        final isHardRpe = s.rpe != null && s.rpe! >= 6.0;
        if (isHardRir || isHardRpe) {
          count++;
        }
      }
    }
    return count;
  }

  /// Workout density = total tonnage / elapsed time in seconds.
  /// Returns 0.0 if elapsed time <= 0.
  static double calculateWorkoutDensity(
    WorkoutWithExercisesAndSets workoutWithExercisesAndSets,
  ) {
    final elapsed = workoutWithExercisesAndSets.workout.timeElapsed;
    if (elapsed <= 0) return 0.0;
    final tonnage = calculateWorkoutTonnage(workoutWithExercisesAndSets);
    return tonnage / elapsed;
  }

  /// Principal muscle group impacted by the workout based on the most frequent primary muscle in completed exercises.
  static Muscle? getPrimaryMuscleImpacted(
    WorkoutWithExercisesAndSets workoutWithExercisesAndSets,
  ) {
    final counts = <Muscle, int>{};
    for (final eWs in workoutWithExercisesAndSets.exercisesWithSets) {
      // Consider exercises that had at least one completed working set
      final hasCompletedSet = eWs.sets.any(
        (s) => s.completed && s.setType != SetType.WARMUP,
      );
      if (!hasCompletedSet && eWs.sets.isNotEmpty) continue;

      for (final m in eWs.exerciseDC.primaryMuscles) {
        counts[m] = (counts[m] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return null;
    Muscle? topMuscle;
    int maxCount = -1;
    for (final entry in counts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        topMuscle = entry.key;
      }
    }
    return topMuscle;
  }
}
