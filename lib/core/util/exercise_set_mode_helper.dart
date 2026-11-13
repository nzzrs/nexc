/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Central resolution of the exercise set mode stored/derived from exercise data.
 */

import '../db/app_database.dart';
import '../db/enums.dart';

/// Resolves the default [SetMode] for an exercise from its database metadata.
///
/// Categories and equipment are the source of truth stored in
/// [ExerciseDataDC]. A previously stored mode always takes precedence at the
/// call site; this helper is only the deterministic fallback.
SetMode defaultSetModeForExercise(ExerciseDataDC exercise) {
  if (exercise.category == Category.STRETCHING ||
      exercise.category == Category.CARDIO) {
    return SetMode.DURATION;
  }

  if (exercise.equipment == Equipment.BODY_ONLY ||
      exercise.equipment == Equipment.FOAM_ROLL ||
      exercise.equipment == Equipment.EXERCISE_BALL ||
      exercise.equipment == Equipment.BANDS) {
    return SetMode.BODYWEIGHT;
  }

  return SetMode.LOAD;
}
