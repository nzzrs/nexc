/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/components/exercise_card.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/util/unit_system.dart';
import 'package:nexc_flutter/features/workout/barbell_calculator_sheet.dart';

ExerciseDataDC _exerciseData() {
  return ExerciseDataDC(
    id: 'Barbell_Squat',
    name: 'Barbell Squat',
    level: Level.BEGINNER,
    category: Category.STRENGTH,
    primaryMuscles: const [Muscle.QUADRICEPS],
    secondaryMuscles: const [],
    instructions: const ['Squat with a barbell.'],
    images: const [],
    isCustomExercise: false,
  );
}

ExerciseWithSets _exerciseWithSets({
  SetMode setMode = SetMode.LOAD,
  double load = 100.0,
  int sets = 1,
}) {
  return ExerciseWithSets(
    exercise: Exercise(
      id: 1,
      exerciseDataId: 'Barbell_Squat',
      notes: '',
      setMode: setMode,
      restTime: 90,
      position: 0,
      workoutId: 1,
    ),
    exerciseDC: _exerciseData(),
    sets: [
      for (int i = 0; i < sets; i++)
        WorkoutSet(
          id: i + 1,
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

Widget _exerciseCard(SharedPreferences prefs, ExerciseWithSets exercise) {
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ExerciseCard(
            index: 0,
            exerciseWithSets: exercise,
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
            updateSetLoad: (_, _) {},
            updateSetCompleted: (_, _) {},
            showInfo: (_) {},
          ),
        ),
      ),
    ),
  );
}

Future<SharedPreferences> _prefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseCard plate calculator', () {
    testWidgets('opens the sheet and shows the plates per side', (
      tester,
    ) async {
      final prefs = await _prefs({'unit_system': 'metric'});
      await tester.pumpWidget(_exerciseCard(prefs, _exerciseWithSets()));
      await tester.pump();

      await tester.tap(find.byTooltip('Plate calculator'));
      await tester.pumpAndSettle();

      expect(find.byType(BarbellCalculatorSheet), findsOneWidget);
      expect(find.text('Plate calculator'), findsOneWidget);
      expect(find.text('Per side'), findsOneWidget);

      // 100 kg with a 20 kg bar: 25 + 15 per side.
      expect(find.byKey(const ValueKey<String>('plate_25.0')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('plate_15.0')), findsOneWidget);
      expect(find.text('× 1'), findsNWidgets(2));
      expect(find.textContaining('Closest achievable: 100 kg'), findsOneWidget);
      expect(find.textContaining('Cannot hit exactly'), findsNothing);
    });

    testWidgets('honours the imperial unit system and remembers a new bar', (
      tester,
    ) async {
      final prefs = await _prefs({'unit_system': 'imperial'});
      await tester.pumpWidget(
        _exerciseCard(
          prefs,
          _exerciseWithSets(load: toKilograms(225.0, UnitSystem.imperial)),
        ),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Plate calculator'));
      await tester.pumpAndSettle();

      // 225 lb with a 45 lb bar: 2 x 45 lb per side.
      expect(
        find.byKey(
          ValueKey<String>('plate_${toKilograms(45.0, UnitSystem.imperial)}'),
        ),
        findsOneWidget,
      );
      expect(find.text('45 lb'), findsWidgets);
      expect(find.text('× 2'), findsOneWidget);
      expect(find.textContaining('Closest achievable: 225 lb'), findsOneWidget);

      await tester.tap(find.text('35 lb'));
      await tester.pumpAndSettle();

      expect(
        prefs.getDouble('default_bar_weight_kg'),
        closeTo(toKilograms(35.0, UnitSystem.imperial), 1e-9),
      );
    });

    testWidgets('hides the button for set modes without load', (tester) async {
      final prefs = await _prefs({'unit_system': 'metric'});
      await tester.pumpWidget(
        _exerciseCard(prefs, _exerciseWithSets(setMode: SetMode.BODYWEIGHT)),
      );
      await tester.pump();

      expect(find.byTooltip('Plate calculator'), findsNothing);
    });
  });

  group('BarbellCalculatorSheet', () {
    testWidgets('warns about a remainder and shows the closest total', (
      tester,
    ) async {
      final prefs = await _prefs({
        'unit_system': 'metric',
        'default_bar_weight_kg': 20.0,
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            home: Scaffold(
              body: BarbellCalculatorSheet(initialTargetWeightKg: 52.5),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Include small plates'));
      await tester.pump();

      expect(find.textContaining('Cannot hit exactly'), findsOneWidget);
      expect(find.textContaining('left over per side'), findsOneWidget);
      expect(find.textContaining('Closest achievable: 50 kg'), findsOneWidget);
    });
  });
}
