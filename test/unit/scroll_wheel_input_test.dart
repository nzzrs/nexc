/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/components/exercise_card.dart';
import 'package:nexc_flutter/core/components/input_modal_bottom_sheet.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/util/unit_system.dart';
import 'package:nexc_flutter/features/settings/settings_screen.dart';

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

ExerciseWithSets _exerciseWithSets({
  SetMode setMode = SetMode.LOAD,
  double load = 100.0,
  int reps = 5,
  int elapsedTime = 0,
}) {
  return ExerciseWithSets(
    exercise: Exercise(
      id: 1,
      exerciseDataId: 'back_squat',
      notes: '',
      setMode: setMode,
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
        reps: reps,
        elapsedTime: elapsedTime,
        completed: false,
        setType: SetType.NORMAL,
        exerciseId: 1,
      ),
    ],
  );
}

Future<SharedPreferences> _prefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Finder _decimalField() => find.byWidgetPredicate(
  (Widget widget) =>
      widget is TextField &&
      widget.keyboardType ==
          const TextInputType.numberWithOptions(decimal: true),
);

String _fieldText(WidgetTester tester, Finder finder) {
  return tester.widget<TextField>(finder.first).controller!.text;
}

Future<void> _pumpCard(
  WidgetTester tester, {
  required SharedPreferences prefs,
  required ExerciseWithSets Function() exercise,
  required void Function(double load) onLoad,
  required void Function(int reps) onReps,
  required void Function(int seconds) onTime,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ExerciseCard(
                  index: 0,
                  exerciseWithSets: exercise(),
                  workout: false,
                  addSet: (_) {},
                  onDetail: (_, _) {},
                  onDelete: (_) {},
                  deleteSet: (_) {},
                  updateExerciseNotes: (_, _) {},
                  updateExerciseRestTime: (_, _) {},
                  updateExerciseSetMode: (_, _) {},
                  updateSetTime: (seconds, _) {
                    onTime(seconds);
                    setState(() {});
                  },
                  updateSetReps: (reps, _) {
                    onReps(reps);
                    setState(() {});
                  },
                  updateSetLoad: (load, _) {
                    onLoad(load);
                    setState(() {});
                  },
                  updateSetCompleted: (_, _) {},
                  showInfo: (_) {},
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('scroll wheel input cells', () {
    testWidgets('tapping load opens the sheet and confirming stores kg', (
      tester,
    ) async {
      double load = 100.0;
      final SharedPreferences prefs = await _prefs({'unit_system': 'metric'});
      await _pumpCard(
        tester,
        prefs: prefs,
        exercise: () => _exerciseWithSets(load: load),
        onLoad: (double value) => load = value,
        onReps: (_) {},
        onTime: (_) {},
      );

      expect(find.byKey(const ValueKey<String>('load-cell-1')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('load-cell-1')));
      await tester.pumpAndSettle();

      expect(find.byType(InputModalBottomSheet), findsOneWidget);
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey<String>('input-sheet-value')),
            )
            .data,
        '100 kg',
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-quick-increment')),
      );
      await tester.pump();

      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey<String>('input-sheet-value')),
            )
            .data,
        '102.5 kg',
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-confirm')),
      );
      await tester.pumpAndSettle();

      expect(load, closeTo(102.5, 1e-9));
      expect(_fieldText(tester, _decimalField()), '102.5');
    });

    testWidgets('imperial display and step stay in pounds but store kg', (
      tester,
    ) async {
      double load = toKilograms(100, UnitSystem.imperial);
      final SharedPreferences prefs = await _prefs({'unit_system': 'imperial'});
      await _pumpCard(
        tester,
        prefs: prefs,
        exercise: () => _exerciseWithSets(load: load),
        onLoad: (double value) => load = value,
        onReps: (_) {},
        onTime: (_) {},
      );

      expect(_fieldText(tester, _decimalField()), '100');
      expect(find.text('lb'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('load-cell-1')));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey<String>('input-sheet-value')),
            )
            .data,
        '100 lb',
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-quick-increment')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-confirm')),
      );
      await tester.pumpAndSettle();

      expect(load, closeTo(toKilograms(105, UnitSystem.imperial), 1e-9));
      expect(_fieldText(tester, _decimalField()), '105');
    });

    testWidgets('reps sheet applies the selected rep count', (tester) async {
      int reps = 5;
      final SharedPreferences prefs = await _prefs({'unit_system': 'metric'});
      await _pumpCard(
        tester,
        prefs: prefs,
        exercise: () => _exerciseWithSets(reps: reps),
        onLoad: (_) {},
        onReps: (int value) => reps = value,
        onTime: (_) {},
      );

      await tester.tap(find.byKey(const ValueKey<String>('reps-cell-1')));
      await tester.pumpAndSettle();

      expect(find.byType(InputModalBottomSheet), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-quick-increment')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-confirm')),
      );
      await tester.pumpAndSettle();

      expect(reps, 10);
    });

    testWidgets('time sheet applies seconds in duration mode', (tester) async {
      int elapsed = 65;
      final SharedPreferences prefs = await _prefs({'unit_system': 'metric'});
      await _pumpCard(
        tester,
        prefs: prefs,
        exercise: () =>
            _exerciseWithSets(setMode: SetMode.DURATION, elapsedTime: elapsed),
        onLoad: (_) {},
        onReps: (_) {},
        onTime: (int value) => elapsed = value,
      );

      await tester.tap(find.byKey(const ValueKey<String>('time-cell-1')));
      await tester.pumpAndSettle();

      expect(find.byType(InputModalBottomSheet), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-quick-increment')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-confirm')),
      );
      await tester.pumpAndSettle();

      expect(elapsed, 95);
      expect(find.text('01:35'), findsOneWidget);
    });

    testWidgets('dismisses automatically after the last interaction', (
      tester,
    ) async {
      double load = 100.0;
      final SharedPreferences prefs = await _prefs({'unit_system': 'metric'});
      await _pumpCard(
        tester,
        prefs: prefs,
        exercise: () => _exerciseWithSets(load: load),
        onLoad: (double value) => load = value,
        onReps: (_) {},
        onTime: (_) {},
      );

      await tester.tap(find.byKey(const ValueKey<String>('load-cell-1')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-quick-increment')),
      );
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      expect(find.byType(InputModalBottomSheet), findsNothing);
      expect(load, closeTo(102.5, 1e-9));
    });

    testWidgets('stays open when automatic dismissal is disabled', (
      tester,
    ) async {
      final SharedPreferences prefs = await _prefs({
        'unit_system': 'metric',
        'dismiss_scroll_wheel_input_automatically': false,
      });
      await _pumpCard(
        tester,
        prefs: prefs,
        exercise: () => _exerciseWithSets(),
        onLoad: (_) {},
        onReps: (_) {},
        onTime: (_) {},
      );

      await tester.tap(find.byKey(const ValueKey<String>('load-cell-1')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-quick-increment')),
      );
      await tester.pump(const Duration(milliseconds: 2000));

      expect(find.byType(InputModalBottomSheet), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('input-sheet-cancel')),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('preference off keeps inline text fields', (tester) async {
      double load = 100.0;
      final SharedPreferences prefs = await _prefs({
        'unit_system': 'metric',
        'use_scroll_wheel_for_input': false,
      });
      await _pumpCard(
        tester,
        prefs: prefs,
        exercise: () => _exerciseWithSets(load: load),
        onLoad: (double value) => load = value,
        onReps: (_) {},
        onTime: (_) {},
      );

      expect(find.byKey(const ValueKey<String>('load-cell-1')), findsNothing);
      expect(_decimalField(), findsOneWidget);

      await tester.enterText(_decimalField(), '82.5');
      await tester.pump();

      expect(load, closeTo(82.5, 1e-9));
    });
  });

  group('scroll wheel input settings', () {
    test('defaults both preferences to true', () async {
      SharedPreferences.setMockInitialValues({});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SettingsNotifier notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.useScrollWheelForInput, isTrue);
      expect(notifier.state.dismissScrollWheelInputAutomatically, isTrue);
    });

    test('persists both preferences under their keys', () async {
      SharedPreferences.setMockInitialValues({});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SettingsNotifier notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      await notifier.setUseScrollWheelForInput(false);
      await notifier.setDismissScrollWheelInputAutomatically(false);

      expect(prefs.getBool('use_scroll_wheel_for_input'), isFalse);
      expect(
        prefs.getBool('dismiss_scroll_wheel_input_automatically'),
        isFalse,
      );
      expect(notifier.state.useScrollWheelForInput, isFalse);
      expect(notifier.state.dismissScrollWheelInputAutomatically, isFalse);
    });

    test('restores the stored preferences', () async {
      SharedPreferences.setMockInitialValues({
        'use_scroll_wheel_for_input': false,
        'dismiss_scroll_wheel_input_automatically': false,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SettingsNotifier notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.useScrollWheelForInput, isFalse);
      expect(notifier.state.dismissScrollWheelInputAutomatically, isFalse);
    });

    testWidgets('settings screen exposes and toggles both entries', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Scroll wheel input'), findsOneWidget);
      expect(find.text('Dismiss scroll wheel automatically'), findsOneWidget);

      await tester.tap(find.text('Scroll wheel input'));
      await tester.pump();

      expect(prefs.getBool('use_scroll_wheel_for_input'), isFalse);
      expect(find.text('Dismiss scroll wheel automatically'), findsNothing);
    });
  });
}
