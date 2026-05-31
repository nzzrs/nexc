/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'enums.dart';
import 'meal_repository.dart';
import 'workout_repository.dart';
import '../providers/db_provider.dart';
import '../providers/settings_provider.dart';

class DatasetRepository {
  final AppDatabase db;
  final Ref ref;

  DatasetRepository(this.db, this.ref);

  Stream<List<ExerciseDC>> getDataset() {
    return (db.select(db.dataset)..orderBy([(d) => OrderingTerm(expression: d.name)]))
        .watch();
  }

  Stream<List<ExerciseDC>> getCustomExercises() {
    return (db.select(db.dataset)..where((d) => d.isCustomExercise.equals(true)))
        .watch();
  }

  Future<void> upsertExercise(ExerciseDC exercise) {
    return db.into(db.dataset).insertOnConflictUpdate(exercise);
  }

  Future<void> deleteExercise(ExerciseDC exercise) {
    return db.delete(db.dataset).delete(exercise);
  }

  Future<ExerciseDC?> getExerciseFromId(String id) {
    return (db.select(db.dataset)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  Stream<ExerciseDC?> getExerciseFlowFromId(String id) {
    return (db.select(db.dataset)..where((d) => d.id.equals(id))).watchSingleOrNull();
  }

  Future<void> updateDatasetOnAppUpdate(int currentVersionCode) async {
    final settings = ref.read(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final mealRepo = ref.read(mealRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);

    // Prepopulate defaults if database is empty
    await mealRepo.prepopulateDefaultMealPlans();
    await workoutRepo.prepopulateDefaultWorkoutRoutines();

    final pastVersion = settings.pastVersionCode;

    if (pastVersion != currentVersionCode) {
      // 2. Load and parse exercises.json
      final jsonString = await rootBundle.loadString('assets/exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final List<ExerciseDC> exercises = jsonList.map((map) {
        return ExerciseDC(
          id: map['id'] as String,
          name: map['name'] as String,
          force: map['force'] != null ? ForceExt.fromJson(map['force'] as String) : null,
          level: LevelExt.fromJson(map['level'] as String),
          mechanic: map['mechanic'] != null ? MechanicExt.fromJson(map['mechanic'] as String) : null,
          equipment: map['equipment'] != null ? EquipmentExt.fromJson(map['equipment'] as String) : null,
          primaryMuscles: (map['primaryMuscles'] as List).map((e) => MuscleExt.fromJson(e as String)).toList(),
          secondaryMuscles: (map['secondaryMuscles'] as List).map((e) => MuscleExt.fromJson(e as String)).toList(),
          instructions: List<String>.from(map['instructions'] as List),
          category: CategoryExt.fromJson(map['category'] as String),
          images: List<String>.from(map['images'] as List),
          isCustomExercise: map['isCustomExercise'] as bool? ?? false,
        );
      }).toList();

      // 3. Batch insert exercises
      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(db.dataset, exercises);
      });

      // 4. Update pastVersionCode
      await settingsNotifier.setPastVersionCode(currentVersionCode);
    }
  }
}

final datasetRepositoryProvider = Provider<DatasetRepository>((ref) {
  final db = ref.watch(dbProvider);
  return DatasetRepository(db, ref);
});
