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
import 'measurement_repository.dart';
import '../providers/db_provider.dart';
import '../providers/settings_provider.dart';

class DatasetRepository {
  final AppDatabase db;
  final Ref ref;

  DatasetRepository(this.db, this.ref);

  Stream<List<ExerciseDataDC>> getDataset() {
    return (db.select(db.exerciseData)..orderBy([(d) => OrderingTerm(expression: d.name)]))
        .watch();
  }

  Stream<List<ExerciseDataDC>> getCustomExercises() {
    return (db.select(db.exerciseData)..where((d) => d.isCustomExercise.equals(true)))
        .watch();
  }

  Future<void> upsertExercise(ExerciseDataDC exercise) {
    return db.into(db.exerciseData).insertOnConflictUpdate(exercise);
  }

  Future<void> deleteExercise(ExerciseDataDC exercise) {
    return db.delete(db.exerciseData).delete(exercise);
  }

  Future<ExerciseDataDC?> getExerciseFromId(String id) {
    return (db.select(db.exerciseData)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  Stream<ExerciseDataDC?> getExerciseFlowFromId(String id) {
    return (db.select(db.exerciseData)..where((d) => d.id.equals(id))).watchSingleOrNull();
  }

  Future<void> updateDatasetOnAppUpdate(int currentVersionCode) async {
    final settings = ref.read(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final mealRepo = ref.read(mealRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final measurementRepo = ref.read(measurementRepositoryProvider);

    // Prepopulate defaults if database is empty
    await mealRepo.prepopulateDefaultMealPlans();
    await measurementRepo.prepopulateDefaultMeasurements();

    final pastVersion = settings.pastVersionCode;

    // Load and parse foods.json if database is missing products or on app update
    final productsCountExpr = db.products.id.count();
    final productsCountQuery = db.selectOnly(db.products)..addColumns([productsCountExpr]);
    final productsCountResult = await productsCountQuery.getSingle();
    final productsCount = productsCountResult.read(productsCountExpr) ?? 0;

    if (productsCount < 500 || pastVersion != currentVersionCode) {
      final jsonString = await rootBundle.loadString('assets/foods.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final List<Product> products = jsonList.map<Product>((map) {
        return Product(
          id: map['id'] as int,
          name: map['name'] as String,
          mlToGFactor: map['mlToGFactor'] as int?,
          defaultUnits: map['defaultUnits'] as String?,
          edibleQtyPerUnit: (map['edibleQtyPerUnit'] as num?)?.toDouble(),
          kcal: (map['kcal'] as num?)?.toDouble(),
          proteins: (map['proteins'] as num?)?.toDouble() ?? 0.0,
          carbsByDifference: (map['carbsByDifference'] as num?)?.toDouble(),
          carbsAvailable: (map['carbsAvailable'] as num?)?.toDouble(),
          dietaryFiber: (map['dietaryFiber'] as num?)?.toDouble(),
          fats: (map['fats'] as num?)?.toDouble() ?? 0.0,
          isSupplement: map['isSupplement'] as bool? ?? false,
          isPortable: map['isPortable'] as bool? ?? true,
          isStockRaw: map['isStockRaw'] as bool? ?? false,
        );
      }).toList();

      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(db.products, products);
      });
    }

    final existingExercises = await db.select(db.exerciseData).get();

    if (existingExercises.length < 500 || pastVersion != currentVersionCode) {

      // 2. Load and parse exercises.json
      final jsonString = await rootBundle.loadString('assets/exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final List<ExerciseDataDC> exercises = jsonList.map((map) {
        return ExerciseDataDC(
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
        batch.insertAllOnConflictUpdate(db.exerciseData, exercises);
      });

      // 4. Update pastVersionCode
      await settingsNotifier.setPastVersionCode(currentVersionCode);
    }
    await workoutRepo.prepopulateDefaultWorkoutRoutines();
  }
}

final datasetRepositoryProvider = Provider<DatasetRepository>((ref) {
  final db = ref.watch(dbProvider);
  return DatasetRepository(db, ref);
});
