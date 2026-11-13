/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/features/workout/workout_summary_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.now();
  final testWorkout = Workout(
    id: 1,
    routineId: 0,
    notes: 'Great workout',
    title: 'Leg Day Push',
    state: WorkoutState.COMPLETED,
    timeElapsed: 3665, // 61m 05s
    created: now,
    completed: now,
    isTemporal: false,
  );

  const testExerciseDC = ExerciseDataDC(
    id: 'back_squat',
    name: 'Barbell Back Squat',
    level: Level.INTERMEDIATE,
    primaryMuscles: [Muscle.QUADRICEPS],
    secondaryMuscles: [Muscle.GLUTES],
    instructions: ['Squat down'],
    category: Category.POWERLIFTING,
    images: [],
    isCustomExercise: false,
  );

  const testExercise = Exercise(
    id: 1,
    exerciseDataId: 'back_squat',
    notes: '',
    setMode: SetMode.LOAD,
    restTime: 120, // 2m 0s
    position: 0,
    workoutId: 1,
  );

  final testSets = [
    const WorkoutSet(
      id: 101,
      load: 120.0,
      weightUnit: WeightUnit.kg,
      reps: 5,
      elapsedTime: 0,
      completed: true,
      setType: SetType.NORMAL,
      rpe: 8.0,
      rir: 2,
      exerciseId: 1,
    ),
    const WorkoutSet(
      id: 102,
      load: 125.0,
      weightUnit: WeightUnit.kg,
      reps: 3,
      elapsedTime: 0,
      completed: true,
      setType: SetType.NORMAL,
      rpe: 9.5,
      rir: 0,
      exerciseId: 1,
    ),
    const WorkoutSet(
      id: 103,
      load: 130.0,
      weightUnit: WeightUnit.kg,
      reps: 1,
      elapsedTime: 0,
      completed: false,
      setType: SetType.NORMAL,
      rpe: null,
      rir: null,
      exerciseId: 1,
    ),
  ];

  final testWorkoutData = WorkoutWithExercisesAndSets(
    workout: testWorkout,
    exercisesWithSets: [
      ExerciseWithSets(
        exercise: testExercise,
        exerciseDC: testExerciseDC,
        sets: testSets,
      ),
    ],
  );

  group('formatWorkoutSummaryText Intensity Scale Tests', () {
    test('IntensityScale.none completely excludes RPE and RIR labels', () {
      final summary = formatWorkoutSummaryText(testWorkoutData, intensityScale: IntensityScale.none);

      expect(summary, contains('Workout Summary: Leg Day Push'));
      expect(summary, contains('Duration: 61:05'));
      expect(summary, contains('Completed Sets: 2/3'));
      expect(summary, contains('Set 1: 120.0 kg x 5 reps (Done)'));
      expect(summary, contains('Set 2: 125.0 kg x 3 reps (Done)'));
      expect(summary, contains('Set 3: 130.0 kg x 1 reps (Incomplete)'));
      expect(summary.contains('RPE'), isFalse);
      expect(summary.contains('RIR'), isFalse);
    });

    test('IntensityScale.rpe includes RPE but omits RIR', () {
      final summary = formatWorkoutSummaryText(testWorkoutData, intensityScale: IntensityScale.rpe);

      expect(summary, contains('Set 1: 120.0 kg x 5 reps (Done, RPE 8)'));
      expect(summary, contains('Set 2: 125.0 kg x 3 reps (Done, RPE 9.5)'));
      expect(summary, contains('Set 3: 130.0 kg x 1 reps (Incomplete)'));
      expect(summary.contains('RPE 8'), isTrue);
      expect(summary.contains('RPE 9.5'), isTrue);
      expect(summary.contains('RIR'), isFalse);
    });

    test('IntensityScale.rir includes RIR but omits RPE', () {
      final summary = formatWorkoutSummaryText(testWorkoutData, intensityScale: IntensityScale.rir);

      expect(summary, contains('Set 1: 120.0 kg x 5 reps (Done, RIR 2)'));
      expect(summary, contains('Set 2: 125.0 kg x 3 reps (Done, RIR 0)'));
      expect(summary, contains('Set 3: 130.0 kg x 1 reps (Incomplete)'));
      expect(summary.contains('RIR 2'), isTrue);
      expect(summary.contains('RIR 0'), isTrue);
      expect(summary.contains('RPE'), isFalse);
    });

    test('IntensityScale.both includes both RPE and RIR when present', () {
      final summary = formatWorkoutSummaryText(testWorkoutData, intensityScale: IntensityScale.both);

      expect(summary, contains('Set 1: 120.0 kg x 5 reps (Done, RPE 8, RIR 2)'));
      expect(summary, contains('Set 2: 125.0 kg x 3 reps (Done, RPE 9.5, RIR 0)'));
      expect(summary, contains('Set 3: 130.0 kg x 1 reps (Incomplete)'));
    });
  });

  group('WorkoutSummaryScreen Clipboard Copy Integration Tests', () {
    String clipboardContent = '';

    setUp(() {
      clipboardContent = '';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            clipboardContent = (methodCall.arguments as Map)['text'] as String;
            return null;
          } else if (methodCall.method == 'Clipboard.getData') {
            return {'text': clipboardContent};
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    testWidgets('Copy to Clipboard respects IntensityScale.none from settingsProvider', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({
        'intensity_scale': IntensityScale.none.index,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSummaryScreen(workoutData: testWorkoutData),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final copyButton = find.text('Copy to Clipboard');
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pump();

      expect(find.text('Detailed summary copied to clipboard'), findsOneWidget);

      final clipData = await Clipboard.getData(Clipboard.kTextPlain);
      expect(clipData, isNotNull);
      final copiedText = clipData!.text!;

      expect(copiedText, contains('Workout Summary: Leg Day Push'));
      expect(copiedText.contains('RPE'), isFalse);
      expect(copiedText.contains('RIR'), isFalse);

      // Unmount to stop confetti repeating animation
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Copy to Clipboard respects IntensityScale.both from settingsProvider', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({
        'intensity_scale': IntensityScale.both.index,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSummaryScreen(workoutData: testWorkoutData),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final copyButton = find.text('Copy to Clipboard');
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pump();

      expect(find.text('Detailed summary copied to clipboard'), findsOneWidget);

      final clipData = await Clipboard.getData(Clipboard.kTextPlain);
      expect(clipData, isNotNull);
      final copiedText = clipData!.text!;

      expect(copiedText, contains('Workout Summary: Leg Day Push'));
      expect(copiedText, contains('RPE 8, RIR 2'));
      expect(copiedText, contains('RPE 9.5, RIR 0'));

      // Unmount to stop confetti repeating animation
      await tester.pumpWidget(const SizedBox());
    });
  });
}
