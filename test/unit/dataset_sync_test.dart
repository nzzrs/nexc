/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:nexc_flutter/core/db/dataset_repository.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/providers/db_provider.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exercise ids introduced by the upstream dataset and missing from the
/// previous Nexc dataset.
const List<String> _upstreamOnlyIds = [
  'Arch_Hang',
  'Assisted_Bodyweight_Squat',
  'Banded_Nordic_Curl',
  'Banded_Nordic_Curl_Negatives',
  'Beginner_Shrimp_Squat',
  'Bodyweight_Reverse_Hyperextension',
  'Bottom_Pushup_Hold',
  'Cobra_Stretch',
  'Eccentric_Hamstring_Slide',
  'Eccentric_Parallel_Bar_Dip',
  'Eccentric_Pullups',
  'Eccentric_Single_Leg_Hamstring_Slide',
  'GMB_Wrist_Prep',
  'Hamstring_Slide',
  'Horizontal_Row',
  'Incline_Row',
  'Intermediate_Shrimp_Squat',
  'Jumping_Jacks',
  'Nordic_Curl',
  'Parallel_Bar_Support_Hold',
  'Partial_ROM_Pistol_Squat',
  'Pike_Hanging_Leg_Raises',
  'Pistol_Squat',
  'Plank_Shoulder_Taps',
  'Pseudo_Planche_Pushup',
  'Ring_Pushup',
  'Ring_Support_Hold',
  'RTO_PPPU',
  'RTO_Pushup',
  'RTO_Support_Hold',
  'Shrimp_Squat',
  'Single_Leg_Hamstring_Slide',
  'Squat_Sky_Reaches',
  'Tucked_Hanging_Leg_Raises',
  'Vertical_Row',
  'Wall_Sit',
  'Weighted_Horizontal_Row',
  'Wide_Row',
  'Yuri_Shoulder_Band_Warmup',
];

List<Map<String, dynamic>> _loadDataset() {
  final file = File('assets/exercises.json');
  final decoded = json.decode(file.readAsStringSync()) as List<dynamic>;
  return decoded.cast<Map<String, dynamic>>();
}

String _assetPathFor(String datasetImagePath) {
  return 'assets/exercise_images/${datasetImagePath.replaceAll('/', '_')}';
}

Future<(AppDatabase, ProviderContainer)> _createContainer({
  int pastVersionCode = -1,
}) async {
  SharedPreferences.setMockInitialValues({'pastVersionCode': pastVersionCode});
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase.executor(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [
      dbProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  return (db, container);
}

ExerciseDataDC _customExercise() {
  return const ExerciseDataDC(
    id: 'custom_test_exercise',
    name: 'Custom Test Exercise',
    level: Level.BEGINNER,
    primaryMuscles: [],
    secondaryMuscles: [],
    instructions: ['Keep going.'],
    category: Category.STRENGTH,
    images: [],
    isCustomExercise: true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // rootBundle-based import tests need the asset bundle to be available.
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('exercises.json parses with 912 unique exercise ids', () {
    final dataset = _loadDataset();

    expect(dataset, hasLength(912));
    final ids = dataset.map((exercise) => exercise['id'] as String).toList();
    expect(ids.toSet(), hasLength(912));
  });

  test('all 39 upstream-only exercise ids are present', () {
    final ids = _loadDataset()
        .map((exercise) => exercise['id'] as String)
        .toSet();

    expect(_upstreamOnlyIds, hasLength(39));
    for (final id in _upstreamOnlyIds) {
      expect(ids, contains(id), reason: 'Missing exercise $id');
    }
  });

  test('every dataset image path maps to an existing asset file', () {
    final dataset = _loadDataset();
    final missing = <String>[];

    for (final exercise in dataset) {
      final images = (exercise['images'] as List<dynamic>).cast<String>();
      for (final image in images) {
        if (!File(_assetPathFor(image)).existsSync()) {
          missing.add('${exercise['id']}: $image');
        }
      }
    }

    expect(missing, isEmpty, reason: 'Missing images: $missing');
  });

  test('importing the dataset yields 912 exercise rows', () async {
    final (db, container) = await _createContainer();
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    await container.read(datasetRepositoryProvider).updateDatasetOnAppUpdate(1);

    final rows = await db.select(db.exerciseData).get();
    expect(rows, hasLength(912));
  });

  test(
    'stale pastVersionCode triggers a reload and preserves custom exercises',
    () async {
      final (db, container) = await _createContainer(pastVersionCode: 1);
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      // Populate the dataset at a newer version, then simulate a stale stored
      // version while keeping a populated table (> 500 rows) so only the
      // version comparison can trigger the reload.
      await container
          .read(datasetRepositoryProvider)
          .updateDatasetOnAppUpdate(5);
      await container.read(settingsProvider.notifier).setPastVersionCode(1);
      await db.into(db.exerciseData).insertOnConflictUpdate(_customExercise());

      await container
          .read(datasetRepositoryProvider)
          .updateDatasetOnAppUpdate(5);

      final rows = await db.select(db.exerciseData).get();
      expect(rows, hasLength(913));
      expect(
        rows.where((row) => row.id == 'custom_test_exercise'),
        hasLength(1),
      );
      expect(container.read(settingsProvider).pastVersionCode, 5);
    },
  );

  test('newer stored version does not trigger a reload', () async {
    final (db, container) = await _createContainer();
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    await container.read(datasetRepositoryProvider).updateDatasetOnAppUpdate(5);

    // Mark a dataset row with a sentinel so a re-import would overwrite it.
    await (db.update(
      db.exerciseData,
    )..where((row) => row.id.equals('3_4_Sit-Up'))).write(
      const ExerciseDataDC(
        id: '3_4_Sit-Up',
        name: 'Sentinel Name',
        level: Level.BEGINNER,
        primaryMuscles: [],
        secondaryMuscles: [],
        instructions: [],
        category: Category.STRENGTH,
        images: [],
        isCustomExercise: false,
      ),
    );

    // Downgrade the current version code: stored 5 >= current 4, no reload.
    await container.read(datasetRepositoryProvider).updateDatasetOnAppUpdate(4);

    final row = await (db.select(
      db.exerciseData,
    )..where((row) => row.id.equals('3_4_Sit-Up'))).getSingle();
    expect(row.name, 'Sentinel Name');
  });
}
