/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/util/exercise_set_mode_helper.dart';

ExerciseDataDC _exercise({
  required Category category,
  Equipment? equipment,
  List<Muscle> primaryMuscles = const [Muscle.CHEST],
}) {
  return ExerciseDataDC(
    id: 'test_exercise',
    name: 'Test Exercise',
    level: Level.BEGINNER,
    category: category,
    equipment: equipment,
    primaryMuscles: primaryMuscles,
    secondaryMuscles: const [],
    instructions: const [],
    images: const [],
    isCustomExercise: false,
  );
}

void main() {
  group('defaultSetModeForExercise', () {
    test('stretching and cardio use duration mode', () {
      expect(
        defaultSetModeForExercise(_exercise(category: Category.STRETCHING)),
        SetMode.DURATION,
      );
      expect(
        defaultSetModeForExercise(_exercise(category: Category.CARDIO)),
        SetMode.DURATION,
      );
    });

    test('bodyweight equipment uses bodyweight mode', () {
      for (final equipment in [
        Equipment.BODY_ONLY,
        Equipment.FOAM_ROLL,
        Equipment.EXERCISE_BALL,
        Equipment.BANDS,
      ]) {
        expect(
          defaultSetModeForExercise(
            _exercise(category: Category.STRENGTH, equipment: equipment),
          ),
          SetMode.BODYWEIGHT,
        );
      }
    });

    test('loaded equipment uses load mode', () {
      for (final equipment in [
        Equipment.BARBELL,
        Equipment.DUMBBELL,
        Equipment.MACHINE,
        Equipment.CABLE,
        Equipment.KETTLEBELLS,
      ]) {
        expect(
          defaultSetModeForExercise(
            _exercise(category: Category.STRENGTH, equipment: equipment),
          ),
          SetMode.LOAD,
        );
      }
    });

    test('unknown or missing equipment falls back to load mode', () {
      expect(
        defaultSetModeForExercise(_exercise(category: Category.STRENGTH)),
        SetMode.LOAD,
      );
    });
  });
}
