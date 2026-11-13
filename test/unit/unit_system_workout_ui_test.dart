/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/components/exercise_card.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/util/unit_system.dart';
import 'package:nexc_flutter/features/workout/workout_summary_screen.dart';

ExerciseDataDC _exerciseData() {
  return const ExerciseDataDC(
    id: 'back_squat',
    name: 'Barbell Back Squat',
    level: Level.INTERMEDIATE,
    category: Category.POWERLIFTING,
    primaryMuscles: [Muscle.QUADRICEPS],
    secondaryMuscles: [Muscle.GLUTES],
    instructions: ['Squat down'],
    images: [],
    isCustomExercise: false,
  );
}

ExerciseWithSets _exerciseWithSets({double load = 0.0}) {
  return ExerciseWithSets(
    exercise: const Exercise(
      id: 1,
      exerciseDataId: 'back_squat',
      notes: '',
      setMode: SetMode.LOAD,
      restTime: 120,
      position: 0,
      workoutId: 1,
    ),
    exerciseDC: _exerciseData(),
    sets: [
      WorkoutSet(
        id: 1,
        load: load,
        weightUnit: WeightUnit.kg,
        reps: 5,
        elapsedTime: 0,
        completed: false,
        setType: SetType.NORMAL,
        exerciseId: 1,
      ),
    ],
  );
}

Future<SharedPreferences> _prefs(UnitSystem system) async {
  SharedPreferences.setMockInitialValues({'unit_system': system.name});
  return SharedPreferences.getInstance();
}

Future<void> _pumpCard(
  WidgetTester tester, {
  required UnitSystem system,
  double load = 0.0,
  void Function(double load, int setId)? onLoad,
}) async {
  final prefs = await _prefs(system);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseCard(
              index: 0,
              exerciseWithSets: _exerciseWithSets(load: load),
              workout: false,
              addSet: (_) {},
              onDetail: (_, _) {},
              onDelete: (_) {},
              deleteSet: (_) {},
              updateExerciseNotes: (_, _) {},
              updateExerciseRestTime: (_, _) {},
              updateExerciseSetMode: (_, _) {},
              updateSetTime: (_, _) {},
              updateSetReps: (_, _) {},
              updateSetLoad: onLoad ?? (_, _) {},
              updateSetCompleted: (_, _) {},
              showInfo: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

final Finder _loadField = find.byWidgetPredicate(
  (widget) =>
      widget is TextField &&
      widget.keyboardType ==
          const TextInputType.numberWithOptions(decimal: true),
);

String _loadText(WidgetTester tester) {
  return tester.widget<TextField>(_loadField).controller!.text;
}

final WorkoutWithExercisesAndSets _summaryWorkoutData =
    WorkoutWithExercisesAndSets(
      workout: Workout(
        id: 1,
        routineId: 0,
        notes: '',
        title: 'Leg Day Push',
        state: WorkoutState.COMPLETED,
        timeElapsed: 3665,
        position: 0,
        created: DateTime(2026, 1, 1),
        completed: DateTime(2026, 1, 1),
        isTemporal: false,
      ),
      exercisesWithSets: [
        ExerciseWithSets(
          exercise: const Exercise(
            id: 1,
            exerciseDataId: 'back_squat',
            notes: '',
            setMode: SetMode.LOAD,
            restTime: 120,
            position: 0,
            workoutId: 1,
          ),
          exerciseDC: _exerciseData(),
          sets: const [
            WorkoutSet(
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
            WorkoutSet(
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
            WorkoutSet(
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
          ],
        ),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseCard unit system', () {
    testWidgets('entering 45 lb stores 20.41 kg', (tester) async {
      double? storedLoad;
      await _pumpCard(
        tester,
        system: UnitSystem.imperial,
        onLoad: (load, _) => storedLoad = load,
      );

      await tester.enterText(_loadField, '45');
      await tester.pump();

      expect(storedLoad, isNotNull);
      expect(storedLoad!, closeTo(20.41165665, 1e-6));
    });

    testWidgets('a 20.41 kg set displays as 45 lb', (tester) async {
      await _pumpCard(tester, system: UnitSystem.imperial, load: 20.41);

      expect(_loadText(tester), equals('45'));
      expect(find.text('lb'), findsOneWidget);
    });

    testWidgets('metric input is stored unchanged and labelled kg', (
      tester,
    ) async {
      double? storedLoad;
      await _pumpCard(
        tester,
        system: UnitSystem.metric,
        load: 100.0,
        onLoad: (load, _) => storedLoad = load,
      );

      expect(_loadText(tester), equals('100'));
      expect(find.text('kg'), findsOneWidget);

      await tester.enterText(_loadField, '82.5');
      await tester.pump();

      expect(storedLoad, closeTo(82.5, 1e-9));
    });
  });

  group('formatWorkoutSummaryText unit system', () {
    test('metric stays identical to the previous output', () {
      final summary = formatWorkoutSummaryText(_summaryWorkoutData);

      expect(summary, contains('Total Volume: 975.0 kg'));
      expect(
        summary,
        contains('Set 1: 120.0 kg x 5 reps (Done, RPE 8, RIR 2)'),
      );
      expect(
        summary,
        contains('Set 2: 125.0 kg x 3 reps (Done, RPE 9.5, RIR 0)'),
      );
      expect(summary, contains('Set 3: 130.0 kg x 1 reps (Incomplete)'));
    });

    test('imperial reports volume and per-set loads in pounds', () {
      final summary = formatWorkoutSummaryText(
        _summaryWorkoutData,
        unitSystem: UnitSystem.imperial,
      );

      expect(summary, contains('Total Volume: 2149.5 lb'));
      expect(
        summary,
        contains('Set 1: 264.6 lb x 5 reps (Done, RPE 8, RIR 2)'),
      );
      expect(
        summary,
        contains('Set 2: 275.6 lb x 3 reps (Done, RPE 9.5, RIR 0)'),
      );
      expect(summary, contains('Set 3: 286.6 lb x 1 reps (Incomplete)'));
      expect(summary.contains(' kg'), isFalse);
    });
  });

  group('WorkoutSummaryScreen unit system', () {
    testWidgets('volume, density, e1RM and clipboard use pounds', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String clipboardContent = '';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboardContent = (call.arguments as Map)['text'] as String;
              return null;
            }
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      final prefs = await _prefs(UnitSystem.imperial);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            home: WorkoutSummaryScreen(workoutData: _summaryWorkoutData),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('2150 lb'), findsOneWidget);
      expect(find.textContaining('lb/s'), findsOneWidget);

      final e1rmText = tester
          .widgetList<Text>(find.textContaining('e1RM:'))
          .map((text) => text.data ?? '')
          .join();
      expect(e1rmText, contains('lb'));

      await tester.tap(find.text('Copy to Clipboard'));
      await tester.pump();

      expect(clipboardContent, contains('Total Volume: 2149.5 lb'));
      expect(clipboardContent, contains('264.6 lb x 5 reps'));

      await tester.pumpWidget(const SizedBox());
    });
  });
}
