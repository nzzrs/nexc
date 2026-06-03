/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;

import '../db/app_database.dart';
import '../db/enums.dart';
import '../db/relations.dart';
import '../db/workout_repository.dart';
import '../db/meal_repository.dart';
import '../db/dataset_repository.dart';
import '../providers/db_provider.dart';

class BackupManager {
  final AppDatabase db;
  final WorkoutRepository workoutRepo;
  final MealRepository mealRepo;
  final DatasetRepository datasetRepo;

  BackupManager({
    required this.db,
    required this.workoutRepo,
    required this.mealRepo,
    required this.datasetRepo,
  });

  Future<void> exportDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'nexc_database'));
    if (await dbFile.exists()) {
      final tempDir = await getTemporaryDirectory();
      final backupFile = File(p.join(tempDir.path, 'nexc_database_backup.db'));
      await dbFile.copy(backupFile.path);
      await Share.shareXFiles([XFile(backupFile.path)], subject: 'Nexc Database Backup');
    }
  }

  Future<bool> importDatabase() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return false;

    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'nexc_database'));
    final shmFile = File(p.join(dbFolder.path, 'nexc_database-shm'));
    final walFile = File(p.join(dbFolder.path, 'nexc_database-wal'));

    // Close connection to prevent sqlite corruption and handle lock
    await db.close();

    final selectedFile = File(result.files.single.path!);
    await selectedFile.copy(dbFile.path);

    if (await shmFile.exists()) await shmFile.delete();
    if (await walFile.exists()) await walFile.delete();

    return true;
  }

  Future<void> exportWorkoutPlans() async {
    // routines = workouts where state is ROUTINE
    final workouts = await db.select(db.workouts).get();
    final routines = workouts.where((w) => w.state == WorkoutState.ROUTINE).toList();

    final List<Map<String, dynamic>> exportList = [];
    for (final routine in routines) {
      final routineWithEx = await workoutRepo.getWorkoutWithExercisesAndSets(routine.id);
      if (routineWithEx != null) {
        exportList.add({
          'title': routineWithEx.workout.title,
          'notes': routineWithEx.workout.notes,
          'timeElapsed': routineWithEx.workout.timeElapsed,
          'created': routineWithEx.workout.created.toIso8601String(),
          'completed': routineWithEx.workout.completed.toIso8601String(),
          'state': routineWithEx.workout.state.name,
          'exercises': routineWithEx.exercisesWithSets.map((e) => {
            'exerciseId': e.exerciseDC.id,
            'name': e.exerciseDC.name,
            'notes': e.exercise.notes,
            'setMode': e.exercise.setMode.name,
            'restTime': e.exercise.restTime,
            'supersetGroupId': e.exercise.supersetId?.toString(),
            'sets': e.sets.map((s) => {
              'load': s.load,
              'reps': s.reps,
              'elapsedTime': s.elapsedTime,
              'rpe': s.rpe?.toString() ?? '',
              'intensityScale1': s.intensityScale1 ?? 0,
              'completed': s.completed,
            }).toList(),
          }).toList(),
        });
      }
    }

    final jsonString = jsonEncode(exportList);
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, 'nexc_workout_plans.json'));
    await file.writeAsString(jsonString);
    await Share.shareXFiles([XFile(file.path)], subject: 'Nexc Workout Plans');
  }

  Future<bool> importWorkoutPlans() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      for (final item in data) {
        final workout = Workout(
          id: 0,
          routineId: 0,
          notes: item['notes'] ?? '',
          title: item['title'] ?? '',
          state: WorkoutState.ROUTINE,
          timeElapsed: item['timeElapsed'] ?? 0,
          created: DateTime.tryParse(item['created'] ?? '') ?? DateTime.now(),
          completed: DateTime.tryParse(item['completed'] ?? '') ?? DateTime.now(),
        );

        final List<dynamic> exercisesJson = item['exercises'] ?? [];
        final List<ExerciseWithSets> exercisesWithSets = [];

        final supersetMapping = <String, int>{};

        for (final exJson in exercisesJson) {
          final exerciseId = exJson['exerciseId'] ?? '';
          var exerciseDC = await datasetRepo.getExerciseFromId(exerciseId);
          if (exerciseDC == null) {
            exerciseDC = ExerciseDataDC(
              id: exerciseId,
              name: exJson['name'] ?? '',
              level: Level.BEGINNER,
              primaryMuscles: [],
              secondaryMuscles: [],
              instructions: [],
              category: Category.STRENGTH,
              images: [],
              isCustomExercise: true,
            );
            await datasetRepo.upsertExercise(exerciseDC);
          }

          int? supersetId;
          final sGroupId = exJson['supersetGroupId'];
          if (sGroupId != null && sGroupId.toString().isNotEmpty) {
            supersetId = supersetMapping.putIfAbsent(
              sGroupId.toString(),
              () => DateTime.now().microsecondsSinceEpoch % 1000000,
            );
          }

          final List<dynamic> setsJson = exJson['sets'] ?? [];
          final sets = setsJson.map((s) => WorkoutSet(
            id: 0,
            load: (s['load'] as num?)?.toDouble() ?? 0.0,
            reps: s['reps'] ?? 0,
            elapsedTime: s['elapsedTime'] ?? 0,
            completed: s['completed'] ?? true,
            rpe: double.tryParse(s['rpe']?.toString() ?? ''),
            intensityScale1: s['intensityScale1'] ?? s['intensityScale'],
            exerciseId: 0,
          )).toList();

          exercisesWithSets.add(ExerciseWithSets(
            exercise: Exercise(
              id: 0,
              exerciseDataId: exerciseId,
              notes: exJson['notes'] ?? '',
              setMode: SetMode.values.firstWhere(
                (m) => m.name == exJson['setMode'],
                orElse: () => SetMode.LOAD,
              ),
              restTime: exJson['restTime'] ?? 0,
              supersetId: supersetId,
              workoutId: 0,
              position: exJson['position'] ?? 0,
            ),
            exerciseDC: exerciseDC,
            sets: sets,
          ));
        }

        await workoutRepo.addWorkoutWithExercisesAndSets(
          WorkoutWithExercisesAndSets(
            workout: workout,
            exercisesWithSets: exercisesWithSets,
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> exportExercises() async {
    final customExercises = await (db.select(db.exerciseData)..where((d) => d.isCustomExercise.equals(true))).get();
    final List<Map<String, dynamic>> exportList = customExercises.map((e) => {
      'id': e.id,
      'name': e.name,
      'force': e.force?.name,
      'level': e.level.name,
      'mechanic': e.mechanic?.name,
      'equipment': e.equipment?.name,
      'primaryMuscles': e.primaryMuscles.map((m) => m.name).toList(),
      'secondaryMuscles': e.secondaryMuscles.map((m) => m.name).toList(),
      'instructions': e.instructions,
      'category': e.category.name,
      'images': e.images,
      'isCustomExercise': e.isCustomExercise,
    }).toList();

    final jsonString = jsonEncode(exportList);
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, 'nexc_exercises.json'));
    await file.writeAsString(jsonString);
    await Share.shareXFiles([XFile(file.path)], subject: 'Nexc Custom Exercises');
  }

  Future<bool> importExercises() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      for (final item in data) {
        final exercise = ExerciseDataDC(
          id: item['id'] ?? '',
          name: item['name'] ?? '',
          force: Force.values.firstWhereOrNull((f) => f.name == item['force']),
          level: Level.values.firstWhere((l) => l.name == item['level'], orElse: () => Level.BEGINNER),
          mechanic: Mechanic.values.firstWhereOrNull((m) => m.name == item['mechanic']),
          equipment: Equipment.values.firstWhereOrNull((e) => e.name == item['equipment']),
          primaryMuscles: (item['primaryMuscles'] as List<dynamic>?)
                  ?.map((m) => MuscleExt.fromJson(m as String))
                  .toList() ?? [],
          secondaryMuscles: (item['secondaryMuscles'] as List<dynamic>?)
                  ?.map((m) => MuscleExt.fromJson(m as String))
                  .toList() ?? [],
          instructions: List<String>.from(item['instructions'] ?? []),
          category: Category.values.firstWhere((c) => c.name == item['category'], orElse: () => Category.STRENGTH),
          images: List<String>.from(item['images'] ?? []),
          isCustomExercise: true,
        );
        await datasetRepo.upsertExercise(exercise);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> exportMealPlans() async {
    // get Templates
    final plansStream = mealRepo.getMealPlansWithMealsAndItemsByState(MealPlanState.TEMPLATE);
    final plans = await plansStream.first;

    final List<Map<String, dynamic>> exportList = plans.map((pPlan) => {
      'title': pPlan.mealPlan.title,
      'notes': pPlan.mealPlan.notes,
      'state': pPlan.mealPlan.state.name,
      'created': pPlan.mealPlan.created.toIso8601String(),
      'completed': pPlan.mealPlan.completed.toIso8601String(),
      'meals': pPlan.meals.map((meal) => {
        'name': meal.meal.name,
        'time': meal.meal.time.toString(),
        'notes': meal.meal.notes,
        'position': meal.meal.position,
        'items': meal.items.map((item) => {
          'type': item.mealItem.type.name,
          'amount': item.mealItem.amount,
          'amountUnit': item.mealItem.amountUnit.name,
          'consumed': item.mealItem.consumed,
          'position': item.mealItem.position,
          'product': item.product == null ? null : {
            'name': item.product!.name,
            'weight': item.product!.weight,
            'defaultUnits': item.product!.defaultUnits,
            'edibleQtyPerUnit': item.product!.edibleQtyPerUnit,
            'proteins': item.product!.proteins,
            'carbsAvailable': item.product!.carbsAvailable,
            'fats': item.product!.fats,
            'isSupplement': item.product!.isSupplement,
            'isPortable': item.product!.isPortable,
          },
          'recipe': item.recipe == null ? null : {
            'name': item.recipe!.recipe.name,
            'instructions': item.recipe!.recipe.instructions,
            'isPortable': item.recipe!.recipe.isPortable,
            'ingredients': item.recipe!.ingredients.map((ing) => {
              'amount': ing.ingredient.amount,
              'product': {
                'name': ing.product.name,
                'weight': ing.product.weight,
                'defaultUnits': ing.product.defaultUnits,
                'edibleQtyPerUnit': ing.product.edibleQtyPerUnit,
                'proteins': ing.product.proteins,
                'carbsAvailable': ing.product.carbsAvailable,
                'fats': ing.product.fats,
                'isSupplement': ing.product.isSupplement,
                'isPortable': ing.product.isPortable,
              }
            }).toList(),
          },
        }).toList(),
      }).toList(),
    }).toList();

    final jsonString = jsonEncode(exportList);
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, 'nexc_meal_plans.json'));
    await file.writeAsString(jsonString);
    await Share.shareXFiles([XFile(file.path)], subject: 'Nexc Meal Plans');
  }

  Future<bool> importMealPlans() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      final productCache = await db.select(db.products).get();
      final mutableProductCache = productCache.toList();

      final recipesList = await mealRepo.getAllRecipes().first;
      final mutableRecipeCache = recipesList.toList();

      for (final item in data) {
        final mealPlan = MealPlan(
          id: 0,
          parentPlanId: 0,
          title: item['title'] ?? '',
          notes: item['notes'] ?? '',
          state: MealPlanState.TEMPLATE,
          created: DateTime.tryParse(item['created'] ?? '') ?? DateTime.now(),
          completed: DateTime.tryParse(item['completed'] ?? '') ?? DateTime.now(),
        );

        final List<dynamic> mealsJson = item['meals'] ?? [];
        final List<MealWithItems> mealsWithItems = [];

        for (final mJson in mealsJson) {
          final meal = Meal(
            id: 0,
            mealPlanId: 0,
            name: mJson['name'] ?? '',
            time: LocalTime.parse(mJson['time'] ?? '12:00'),
            notes: mJson['notes'] ?? '',
            position: mJson['position'] ?? 0,
          );

          final List<dynamic> itemsJson = mJson['items'] ?? [];
          final List<MealItemWithDetails> items = [];

          for (final itJson in itemsJson) {
            final type = MealItemType.values.firstWhere(
              (t) => t.name == itJson['type'],
              orElse: () => MealItemType.PRODUCT,
            );

            int targetId = 0;
            Product? itemProduct;
            RecipeWithIngredients? itemRecipe;

            if (type == MealItemType.PRODUCT && itJson['product'] != null) {
              final pJson = itJson['product'];
              final pName = pJson['name'] ?? '';
              var matched = mutableProductCache.firstWhereOrNull((p) => p.name.toLowerCase() == pName.toString().toLowerCase());
              if (matched == null) {
                final newProduct = Product(
                  id: 0,
                  name: pName,
                  weight: (pJson['weight'] as num?)?.toDouble() ?? 0.0,
                  defaultUnits: pJson['defaultUnits'] ?? pJson['units'] ?? 'g',
                  edibleQtyPerUnit: (pJson['edibleQtyPerUnit'] as num?)?.toDouble() ?? 0.0,
                  proteins: (pJson['proteins'] as num?)?.toDouble() ?? 0.0,
                  carbsAvailable: (pJson['carbsAvailable'] as num?)?.toDouble() ?? (pJson['carbs'] as num?)?.toDouble() ?? 0.0,
                  fats: (pJson['fats'] as num?)?.toDouble() ?? 0.0,
                  isSupplement: pJson['isSupplement'] ?? false,
                  isPortable: pJson['isPortable'] ?? true,
                );
                final id = await mealRepo.saveProduct(newProduct);
                matched = newProduct.copyWith(id: id);
                mutableProductCache.add(matched);
              }
              targetId = matched.id;
              itemProduct = matched;
            } else if (type == MealItemType.RECIPE && itJson['recipe'] != null) {
              final rJson = itJson['recipe'];
              final rName = rJson['name'] ?? '';
              var matched = mutableRecipeCache.firstWhereOrNull((r) => r.recipe.name.toLowerCase() == rName.toString().toLowerCase());
              if (matched == null) {
                final List<dynamic> ingsJson = rJson['ingredients'] ?? [];
                final List<RecipeIngredientWithProduct> ingredientRelations = [];

                for (final ingJson in ingsJson) {
                  final ingProdJson = ingJson['product'];
                  final ingProdName = ingProdJson['name'] ?? '';
                  var ingProduct = mutableProductCache.firstWhereOrNull((p) => p.name.toLowerCase() == ingProdName.toString().toLowerCase());
                  if (ingProduct == null) {
                    final newProduct = Product(
                      id: 0,
                      name: ingProdName,
                      weight: (ingProdJson['weight'] as num?)?.toDouble() ?? 0.0,
                      defaultUnits: ingProdJson['defaultUnits'] ?? ingProdJson['units'] ?? 'g',
                      edibleQtyPerUnit: (ingProdJson['edibleQtyPerUnit'] as num?)?.toDouble() ?? 0.0,
                      proteins: (ingProdJson['proteins'] as num?)?.toDouble() ?? 0.0,
                      carbsAvailable: (ingProdJson['carbsAvailable'] as num?)?.toDouble() ?? (ingProdJson['carbs'] as num?)?.toDouble() ?? 0.0,
                      fats: (ingProdJson['fats'] as num?)?.toDouble() ?? 0.0,
                      isSupplement: ingProdJson['isSupplement'] ?? false,
                      isPortable: ingProdJson['isPortable'] ?? true,
                    );
                    final id = await mealRepo.saveProduct(newProduct);
                    ingProduct = newProduct.copyWith(id: id);
                    mutableProductCache.add(ingProduct);
                  }
                  ingredientRelations.add(RecipeIngredientWithProduct(
                    ingredient: RecipeIngredient(
                      id: 0,
                      recipeId: 0,
                      productId: ingProduct.id,
                      amount: (ingJson['amount'] as num?)?.toDouble() ?? 0.0,
                    ),
                    product: ingProduct,
                  ));
                }

                final newRecipe = Recipe(
                  id: 0,
                  name: rName,
                  instructions: rJson['instructions'] ?? '',
                  isPortable: rJson['isPortable'] ?? true,
                );

                final recipeData = RecipeWithIngredients(
                  recipe: newRecipe,
                  ingredients: ingredientRelations,
                );

                final id = await mealRepo.saveRecipeWithIngredients(recipeData);
                matched = RecipeWithIngredients(
                  recipe: newRecipe.copyWith(id: id),
                  ingredients: ingredientRelations,
                );
                mutableRecipeCache.add(matched);
              }
              targetId = matched.recipe.id;
              itemRecipe = matched;
            }

            items.add(MealItemWithDetails(
              mealItem: MealItem(
                id: 0,
                mealId: 0,
                type: type,
                targetId: targetId,
                amount: (itJson['amount'] as num?)?.toDouble() ?? 0.0,
                amountUnit: AmountUnit.values.firstWhere(
                  (au) => au.name == itJson['amountUnit'],
                  orElse: () => AmountUnit.GRAMS,
                ),
                consumed: itJson['consumed'] ?? false,
                position: itJson['position'] ?? 0,
              ),
              product: itemProduct,
              recipe: itemRecipe,
            ));
          }

          mealsWithItems.add(MealWithItems(
            meal: meal,
            items: items,
          ));
        }

        await mealRepo.saveMealPlanWithMealsAndItems(
          MealPlanWithMealsAndItems(
            mealPlan: mealPlan,
            meals: mealsWithItems,
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

final backupManagerProvider = Provider<BackupManager>((ref) {
  final db = ref.watch(dbProvider);
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final mealRepo = ref.watch(mealRepositoryProvider);
  final datasetRepo = ref.watch(datasetRepositoryProvider);

  return BackupManager(
    db: db,
    workoutRepo: workoutRepo,
    mealRepo: mealRepo,
    datasetRepo: datasetRepo,
  );
});
