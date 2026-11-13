/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/features/workout/workout_summary_screen.dart';

void main() {
  testWidgets('workout summary does not overflow on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final exerciseData = ExerciseDataDC(
      id: 'barbell_bench_press',
      name: 'Barbell Bench Press With A Very Long Exercise Name',
      level: Level.INTERMEDIATE,
      category: Category.STRENGTH,
      equipment: Equipment.BARBELL,
      primaryMuscles: const [Muscle.CHEST],
      secondaryMuscles: const [Muscle.TRICEPS, Muscle.SHOULDERS],
      instructions: const [],
      images: const [],
      isCustomExercise: false,
    );

    final exercise = Exercise(
      id: 1,
      exerciseDataId: exerciseData.id,
      notes: '',
      setMode: SetMode.LOAD,
      restTime: 90,
      position: 0,
      workoutId: 1,
    );

    final workoutData = WorkoutWithExercisesAndSets(
      workout: Workout(
        id: 1,
        routineId: 0,
        notes: '',
        title: 'A Very Long Upper Body Hypertrophy Workout Title',
        state: WorkoutState.COMPLETED,
        timeElapsed: 3725,
        position: 0,
        created: DateTime(2026, 11, 12, 16),
        completed: DateTime(2026, 11, 12, 17),
        isTemporal: false,
      ),
      exercisesWithSets: [
        ExerciseWithSets(
          exercise: exercise,
          exerciseDC: exerciseData,
          sets: [
            WorkoutSet(
              id: 1,
              load: 125.5,
              weightUnit: WeightUnit.kg,
              reps: 12,
              elapsedTime: 0,
              completed: true,
              setType: SetType.NORMAL,
              rpe: 8.0,
              rir: 2,
              exerciseId: exercise.id,
            ),
            WorkoutSet(
              id: 2,
              load: 130.0,
              weightUnit: WeightUnit.kg,
              reps: 10,
              elapsedTime: 0,
              completed: true,
              setType: SetType.FAILURE,
              rpe: 10.0,
              rir: 0,
              exerciseId: exercise.id,
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: WorkoutSummaryScreen(workoutData: workoutData),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('Workout Completed!'), findsOneWidget);
  });
}
