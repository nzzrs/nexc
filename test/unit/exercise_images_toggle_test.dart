/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/components/exercise_card.dart';
import 'package:nexc_flutter/core/db/dataset_repository.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/features/exercises/exercises_screen.dart';
import 'package:nexc_flutter/features/exercises/info_exercise_screen.dart';
import 'package:nexc_flutter/features/settings/settings_screen.dart';

const _imagePaths = ['3_4_Sit-Up/0.webp'];

ExerciseDataDC _exerciseData({List<String> images = _imagePaths}) {
  return ExerciseDataDC(
    id: '3_4_Sit-Up',
    name: '3/4 Sit-Up',
    level: Level.BEGINNER,
    category: Category.STRENGTH,
    primaryMuscles: const [Muscle.ABDOMINALS],
    secondaryMuscles: const [],
    instructions: const ['Lie on your back.'],
    images: images,
    isCustomExercise: false,
  );
}

ExerciseWithSets _exerciseWithSets({List<String> images = _imagePaths}) {
  return ExerciseWithSets(
    exercise: Exercise(
      id: 1,
      exerciseDataId: '3_4_Sit-Up',
      notes: '',
      setMode: SetMode.LOAD,
      restTime: 90,
      position: 0,
      workoutId: 1,
    ),
    exerciseDC: _exerciseData(images: images),
    sets: [
      WorkoutSet(
        id: 1,
        load: 10,
        weightUnit: WeightUnit.kg,
        reps: 10,
        elapsedTime: 0,
        completed: false,
        setType: SetType.NORMAL,
        exerciseId: 1,
      ),
    ],
  );
}

/// Serves a single exercise without opening a database, so widget tests stay
/// free of drift streams and their pending timers.
class _FakeDatasetRepository implements DatasetRepository {
  _FakeDatasetRepository(this.exercise);

  final ExerciseDataDC exercise;

  @override
  Stream<List<ExerciseDataDC>> getDataset() => Stream.value([exercise]);

  @override
  Future<ExerciseDataDC?> getExerciseFromId(String id) async =>
      id == exercise.id ? exercise : null;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used');
}

Future<SharedPreferences> _prefsWith({required bool showImages}) async {
  SharedPreferences.setMockInitialValues({'show_exercise_images': showImages});
  return SharedPreferences.getInstance();
}

Widget _exerciseCard(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ExerciseCard(
            index: 0,
            exerciseWithSets: _exerciseWithSets(),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('showExerciseImages setting', () {
    test('defaults to false', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.showExerciseImages, isFalse);
      expect(prefs.getBool('show_exercise_images'), isNull);
    });

    test('persists under show_exercise_images', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      await notifier.setShowExerciseImages(true);

      expect(notifier.state.showExerciseImages, isTrue);
      expect(prefs.getBool('show_exercise_images'), isTrue);

      final reloaded = SettingsNotifier(prefs);
      addTearDown(reloaded.dispose);
      expect(reloaded.state.showExerciseImages, isTrue);
    });
  });

  group('ExerciseCard images', () {
    testWidgets('hidden when the setting is off', (tester) async {
      final prefs = await _prefsWith(showImages: false);
      await tester.pumpWidget(_exerciseCard(prefs));
      await tester.pump();

      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('shown when the setting is on', (tester) async {
      final prefs = await _prefsWith(showImages: true);
      await tester.pumpWidget(_exerciseCard(prefs));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('ExercisesScreen images', () {
    Future<void> pumpScreen(
      WidgetTester tester, {
      required bool showImages,
    }) async {
      final prefs = await _prefsWith(showImages: showImages);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            datasetRepositoryProvider.overrideWithValue(
              _FakeDatasetRepository(_exerciseData()),
            ),
          ],
          child: const MaterialApp(home: ExercisesScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('hides list thumbnails when off', (tester) async {
      await pumpScreen(tester, showImages: false);

      expect(find.text('3/4 Sit-Up'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('shows list thumbnails when on', (tester) async {
      await pumpScreen(tester, showImages: true);

      expect(find.text('3/4 Sit-Up'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('InfoExerciseScreen images', () {
    Future<void> pumpScreen(
      WidgetTester tester, {
      required bool showImages,
    }) async {
      final prefs = await _prefsWith(showImages: showImages);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            datasetRepositoryProvider.overrideWithValue(
              _FakeDatasetRepository(_exerciseData()),
            ),
          ],
          child: const MaterialApp(
            home: InfoExerciseScreen(exerciseId: '3_4_Sit-Up'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('hides the hero image when off', (tester) async {
      await pumpScreen(tester, showImages: false);

      expect(find.text('3/4 Sit-Up'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('shows the hero image when on', (tester) async {
      await pumpScreen(tester, showImages: true);

      expect(find.text('3/4 Sit-Up'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      // Dispose the screen so its auto-advance timer is cancelled.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });

  group('SettingsScreen images toggle', () {
    testWidgets('shows the appearance entry and flips the label', (
      tester,
    ) async {
      final prefs = await _prefsWith(showImages: false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Show exercise images'), findsOneWidget);
      expect(find.text('Images hidden'), findsOneWidget);

      await tester.tap(find.text('Show exercise images'));
      await tester.pump();

      expect(find.text('Images shown'), findsOneWidget);
      expect(prefs.getBool('show_exercise_images'), isTrue);
    });
  });
}
