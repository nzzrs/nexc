/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/components/exercise_card.dart';
import 'package:nexc_flutter/core/components/wavy_progress_indicators.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/features/edit_workout/edit_workout_screen.dart';
import 'package:nexc_flutter/features/workout/workout_screen.dart';
import 'package:nexc_flutter/features/workout/workout_summary_screen.dart';

const ExerciseDataDC _exerciseData = ExerciseDataDC(
  id: 'back_squat',
  name: 'Barbell Back Squat With An Extra Long Name',
  level: Level.INTERMEDIATE,
  category: Category.POWERLIFTING,
  equipment: Equipment.BARBELL,
  primaryMuscles: <Muscle>[Muscle.QUADRICEPS],
  secondaryMuscles: <Muscle>[Muscle.GLUTES],
  instructions: <String>['Squat down'],
  images: <String>[],
  isCustomExercise: false,
);

ExerciseWithSets _exercise({
  int id = 1,
  SetMode setMode = SetMode.LOAD,
  String notes = '',
  int? supersetId,
  List<WorkoutSet>? sets,
}) {
  return ExerciseWithSets(
    exercise: Exercise(
      id: id,
      exerciseDataId: _exerciseData.id,
      notes: notes,
      setMode: setMode,
      restTime: 120,
      position: id,
      supersetId: supersetId,
      workoutId: 1,
    ),
    exerciseDC: _exerciseData,
    sets:
        sets ??
        <WorkoutSet>[
          WorkoutSet(
            id: id * 10 + 1,
            load: 100,
            weightUnit: WeightUnit.kg,
            reps: 5,
            elapsedTime: 0,
            completed: false,
            setType: SetType.NORMAL,
            exerciseId: id,
          ),
        ],
  );
}

Future<SharedPreferences> _prefs() async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'unit_system': 'metric',
  });
  return SharedPreferences.getInstance();
}

Widget _withSize(Widget child, {bool reduceMotion = false}) {
  return MediaQuery(
    data: MediaQueryData(
      size: const Size(360, 640),
      textScaler: const TextScaler.linear(1.3),
      disableAnimations: reduceMotion,
    ),
    child: child,
  );
}

Widget _cardHarness(
  SharedPreferences prefs, {
  required ExerciseWithSets exercise,
  bool workout = true,
  bool showRpe = false,
  List<WorkoutSet>? previous,
  void Function(bool completed, int setId)? onCompleted,
  void Function(double load, int setId)? onLoad,
  bool reduceMotion = false,
}) {
  return ProviderScope(
    overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      home: _withSize(
        Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ExerciseCard(
              index: 0,
              exerciseWithSets: exercise,
              workout: workout,
              previousPerformances: previous,
              showRpe: showRpe,
              intensityScale: IntensityScale.both,
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
              updateSetCompleted: onCompleted ?? (_, _) {},
              showInfo: (_) {},
            ),
          ),
        ),
        reduceMotion: reduceMotion,
      ),
    ),
  );
}

WorkoutWithExercisesAndSets _summaryData() {
  final ExerciseWithSets exercise = _exercise(
    sets: <WorkoutSet>[
      const WorkoutSet(
        id: 11,
        load: 125.5,
        weightUnit: WeightUnit.kg,
        reps: 12,
        elapsedTime: 0,
        completed: true,
        setType: SetType.WARMUP,
        rpe: 8,
        rir: 2,
        exerciseId: 1,
      ),
      const WorkoutSet(
        id: 12,
        load: 130,
        weightUnit: WeightUnit.kg,
        reps: 10,
        elapsedTime: 0,
        completed: false,
        setType: SetType.FAILURE,
        rpe: 10,
        rir: 0,
        exerciseId: 1,
      ),
    ],
  );

  return WorkoutWithExercisesAndSets(
    workout: Workout(
      id: 1,
      routineId: 0,
      notes: '',
      title: 'A Very Long Upper Body Hypertrophy Workout Title',
      state: WorkoutState.COMPLETED,
      timeElapsed: 3725,
      position: 0,
      created: DateTime(2026, 11, 12),
      completed: DateTime(2026, 11, 12),
      isTemporal: false,
    ),
    exercisesWithSets: <ExerciseWithSets>[exercise],
  );
}

Widget _summaryHarness(SharedPreferences prefs, {bool reduceMotion = false}) {
  return ProviderScope(
    overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      home: _withSize(
        WorkoutSummaryScreen(workoutData: _summaryData()),
        reduceMotion: reduceMotion,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseCard responsive layout', () {
    testWidgets('renders at 360dp with 1.3 text scale without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final SharedPreferences prefs = await _prefs();
      final ExerciseWithSets exercise = _exercise(
        notes: 'Keep the bar close and brace hard.',
      );
      final List<WorkoutSet> previous = <WorkoutSet>[
        const WorkoutSet(
          id: 91,
          load: 90,
          weightUnit: WeightUnit.kg,
          reps: 8,
          elapsedTime: 0,
          completed: true,
          setType: SetType.NORMAL,
          exerciseId: 1,
        ),
      ];

      await tester.pumpWidget(
        _cardHarness(
          prefs,
          exercise: exercise,
          showRpe: true,
          previous: previous,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.text('Barbell Back Squat With An Extra Long Name'),
        findsOneWidget,
      );
      // Notes start collapsed behind the notes icon.
      expect(
        find.byKey(const ValueKey<String>('exercise-notes-1')),
        findsNothing,
      );
    });

    testWidgets('done control and load field update their callbacks', (
      tester,
    ) async {
      final SharedPreferences prefs = await _prefs();
      bool? completed;
      double? load;

      await tester.pumpWidget(
        _cardHarness(
          prefs,
          exercise: _exercise(),
          onCompleted: (bool value, int _) => completed = value,
          onLoad: (double value, int _) => load = value,
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(completed, isTrue);

      final Finder loadField = find.byWidgetPredicate(
        (Widget widget) =>
            widget is TextField &&
            widget.keyboardType ==
                const TextInputType.numberWithOptions(decimal: true),
      );
      await tester.enterText(loadField, '82.5');
      await tester.pump();
      expect(load, closeTo(82.5, 1e-9));
    });

    testWidgets('notes expand from the header action', (tester) async {
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(
        _cardHarness(prefs, exercise: _exercise(notes: 'Brace')),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('exercise-notes-1')),
        findsNothing,
      );
      await tester.tap(find.byTooltip('Notes'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('exercise-notes-1')),
        findsOneWidget,
      );
    });
  });

  group('Workout summary', () {
    testWidgets('does not overflow at 360dp with 1.3 text scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_summaryHarness(prefs));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Workout Completed!'), findsOneWidget);
    });

    testWidgets('exposes exactly one close action', (tester) async {
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_summaryHarness(prefs));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byTooltip('Close'), findsOneWidget);
      expect(find.text('Close'), findsNothing);
      expect(find.text('Copy to Clipboard'), findsOneWidget);
    });

    testWidgets('respects reduced motion and settles', (tester) async {
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_summaryHarness(prefs, reduceMotion: true));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Workout Completed!'), findsOneWidget);
    });
  });

  group('Wavy progress indicators', () {
    test('tiny values keep finite angles', () {
      for (final double value in <double>[1 / 240 - 1e-6, 1 / 240, 0.5, 1]) {
        expect(wavyActiveSegments(value), greaterThanOrEqualTo(1));
        final List<double> angles = wavyProgressAngles(value);
        expect(angles, isNotEmpty);
        for (final double angle in angles) {
          expect(angle.isFinite, isTrue);
        }
      }
      expect(wavyActiveSegments(0), 0);
      expect(wavyProgressAngles(0), isEmpty);
    });

    testWidgets('renders a tiny value with reduced motion and no exception', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _withSize(
            const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: CircularWavyProgressIndicator(value: 0.001),
                ),
              ),
            ),
            reduceMotion: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('linear indicator settles with reduced motion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _withSize(
            const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16),
                child: LinearWavyProgressIndicator(value: 0.002),
              ),
            ),
            reduceMotion: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Rest timer panel', () {
    testWidgets(
      'uses one indicator and explicit actions under reduced motion',
      (tester) async {
        int cancels = 0;
        int additions = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: _withSize(
              Scaffold(
                body: Center(
                  child: RestTimerBar(
                    remainingSeconds: 20,
                    initialSeconds: 60,
                    onCancel: () => cancels++,
                    onAddTime: () => additions++,
                  ),
                ),
              ),
              reduceMotion: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const ValueKey<String>('rest_timer_indicator')),
          findsOneWidget,
        );

        await tester.tap(find.text('+10s'));
        await tester.tap(find.text('Cancel'));
        await tester.pump();
        expect(additions, 1);
        expect(cancels, 1);
      },
    );
  });

  group('Edit workout supersets', () {
    test('new pair continues after the highest existing group', () {
      final List<ExerciseWithSets> exercises = <ExerciseWithSets>[
        _exercise(id: 1),
        _exercise(id: 2),
        _exercise(id: 3, supersetId: 5),
      ];

      final List<ExerciseWithSets> result = toggleSupersetGroup(exercises, 1);

      expect(result[0].exercise.supersetId, 6);
      expect(result[1].exercise.supersetId, 6);
      expect(result[2].exercise.supersetId, 5);
    });

    test('linking joins the previous exercise group', () {
      final List<ExerciseWithSets> exercises = <ExerciseWithSets>[
        _exercise(id: 1, supersetId: 3),
        _exercise(id: 2),
      ];

      final List<ExerciseWithSets> result = toggleSupersetGroup(exercises, 1);

      expect(result[0].exercise.supersetId, 3);
      expect(result[1].exercise.supersetId, 3);
    });

    test('toggling a linked exercise unlinks only that exercise', () {
      final List<ExerciseWithSets> exercises = <ExerciseWithSets>[
        _exercise(id: 1, supersetId: 2),
        _exercise(id: 2, supersetId: 2),
      ];

      final List<ExerciseWithSets> result = toggleSupersetGroup(exercises, 1);

      expect(result[0].exercise.supersetId, 2);
      expect(result[1].exercise.supersetId, isNull);
    });
  });
}
