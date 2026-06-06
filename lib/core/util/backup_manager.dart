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
import '../db/stock_repository.dart';
import '../providers/db_provider.dart';

class ImportResult {
  final bool success;
  final String? error;
  const ImportResult({required this.success, this.error});
  const ImportResult.ok() : success = true, error = null;
  ImportResult.fail(String msg) : success = false, error = msg;
}

class BackupManager {
  final AppDatabase db;
  final WorkoutRepository workoutRepo;
  final MealRepository mealRepo;
  final DatasetRepository datasetRepo;
  final StockRepository stockRepo;

  BackupManager({
    required this.db,
    required this.workoutRepo,
    required this.mealRepo,
    required this.datasetRepo,
    required this.stockRepo,
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
              'rir': s.rir,
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

  Future<ImportResult> importWorkoutPlans() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return const ImportResult(success: false, error: 'No file selected');

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        final workout = Workout(
          id: 0,
          routineId: 0,
          notes: item['notes'] ?? '',
          title: item['title'] ?? '',
          state: WorkoutState.ROUTINE,
          timeElapsed: item['timeElapsed'] ?? 0,
          created: DateTime.tryParse(item['created'] ?? '') ?? DateTime.now(),
          completed: DateTime.tryParse(item['completed'] ?? '') ?? DateTime.now(),
          isTemporal: item['isTemporal'] ?? false,
        );

        final List<dynamic> exercisesJson = item['exercises'] ?? [];
        final List<ExerciseWithSets> exercisesWithSets = [];

        final supersetMapping = <String, int>{};

        for (int j = 0; j < exercisesJson.length; j++) {
          final exJson = exercisesJson[j];
          final exerciseId = exJson['exerciseId'] ?? '';
          if (exerciseId.toString().isEmpty) {
            return ImportResult.fail('Workout #${i + 1} exercise #${j + 1}: missing exerciseId');
          }
          final exerciseDC = await datasetRepo.getExerciseFromId(exerciseId);
          if (exerciseDC == null) {
            final exName = exJson['name'] ?? exerciseId;
            return ImportResult.fail(
              'Workout "${workout.title}", exercise #${j + 1}: '
              'exercise "$exName" ($exerciseId) not found in database. Import exercises first.',
            );
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
          final List<WorkoutSet> sets = setsJson.map((s) => WorkoutSet(
            id: 0,
            load: (s['load'] as num?)?.toDouble() ?? 0.0,
            reps: s['reps'] ?? 0,
            elapsedTime: s['elapsedTime'] ?? 0,
            completed: s['completed'] ?? true,
            rpe: double.tryParse(s['rpe']?.toString() ?? ''),
            rir: s['rir'] as int?,
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
      return const ImportResult.ok();
    } catch (e) {
      return ImportResult.fail(e.toString());
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

  Future<ImportResult> importExercises() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return const ImportResult(success: false, error: 'No file selected');

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        final id = item['id'];
        if (id == null || id.toString().isEmpty) {
          return ImportResult.fail('Exercise #${i + 1}: missing id field');
        }
        final exercise = ExerciseDataDC(
          id: id,
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
      return const ImportResult.ok();
    } catch (e) {
      return ImportResult.fail(e.toString());
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
        'atHome': meal.meal.atHome,
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

  Future<ImportResult> importMealPlans() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return const ImportResult(success: false, error: 'No file selected');

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      final productCache = await db.select(db.products).get();
      final mutableProductCache = productCache.toList();

      final recipesList = await mealRepo.getAllRecipes().first;
      final mutableRecipeCache = recipesList.toList();

      for (int pi = 0; pi < data.length; pi++) {
        final item = data[pi];
        final planTitle = item['title'] ?? 'Plan #${pi + 1}';
        final mealPlan = MealPlan(
          id: 0,
          parentPlanId: 0,
          title: planTitle,
          notes: item['notes'] ?? '',
          state: MealPlanState.TEMPLATE,
          created: DateTime.tryParse(item['created'] ?? '') ?? DateTime.now(),
          completed: DateTime.tryParse(item['completed'] ?? '') ?? DateTime.now(),
          isTemporal: item['isTemporal'] ?? false,
        );

        final List<dynamic> mealsJson = item['meals'] ?? [];
        final List<MealWithItems> mealsWithItems = [];

        for (int mi = 0; mi < mealsJson.length; mi++) {
          final mJson = mealsJson[mi];
          final meal = Meal(
            id: 0,
            mealPlanId: 0,
            name: mJson['name'] ?? '',
            time: LocalTime.parse(mJson['time'] ?? '12:00'),
            notes: mJson['notes'] ?? '',
            position: mJson['position'] ?? 0,
            atHome: mJson['atHome'] ?? true,
          );

          final List<dynamic> itemsJson = mJson['items'] ?? [];
          final List<MealItemWithDetails> items = [];

          for (int ii = 0; ii < itemsJson.length; ii++) {
            final itJson = itemsJson[ii];
            final type = MealItemType.values.firstWhere(
              (t) => t.name == itJson['type'],
              orElse: () => MealItemType.PRODUCT,
            );

            int targetId = 0;
            Product? itemProduct;
            RecipeWithIngredients? itemRecipe;

            if (type == MealItemType.PRODUCT) {
              String? pName;
              int? pId;
              if (itJson['product'] != null) {
                pName = itJson['product']['name'];
              } else if (itJson['targetId'] != null) {
                pId = itJson['targetId'] as int;
              }

              Product? matched;
              if (pName != null && pName.isNotEmpty) {
                matched = mutableProductCache.firstWhereOrNull((p) => p.name.toLowerCase() == pName?.toLowerCase());
              } else if (pId != null) {
                matched = mutableProductCache.firstWhereOrNull((p) => p.id == pId);
              }

              if (matched == null) {
                final display = pName ?? 'ID $pId';
                return ImportResult.fail(
                  'Plan "$planTitle", meal #${mi + 1}, item #${ii + 1}: '
                  'product "$display" not found in database. Please import products first.',
                );
              }
              targetId = matched.id;
              itemProduct = matched;
            } else if (type == MealItemType.RECIPE) {
              String? rName;
              int? rId;
              if (itJson['recipe'] != null) {
                rName = itJson['recipe']['name'];
              } else if (itJson['targetId'] != null) {
                rId = itJson['targetId'] as int;
              }

              RecipeWithIngredients? matched;
              if (rName != null && rName.isNotEmpty) {
                matched = mutableRecipeCache.firstWhereOrNull((r) => r.recipe.name.toLowerCase() == rName?.toLowerCase());
              } else if (rId != null) {
                matched = mutableRecipeCache.firstWhereOrNull((r) => r.recipe.id == rId);
              }

              if (matched == null) {
                final display = rName ?? 'ID $rId';
                return ImportResult.fail(
                  'Plan "$planTitle", meal #${mi + 1}, item #${ii + 1}: '
                  'recipe "$display" not found in database. Please import recipes first.',
                );
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
      return const ImportResult.ok();
    } catch (e) {
      return ImportResult.fail(e.toString());
    }
  }

  Future<void> exportAvailableExercisesDocumentation() async {
    final list = await db.select(db.exerciseData).get();
    final buffer = StringBuffer();
    buffer.writeln('# Nexc Available Exercises');
    buffer.writeln('\nUse these exact IDs (`exerciseId` field) when importing workout plans/routines.\n');
    buffer.writeln('| ID | Name | Category | Primary Muscles |');
    buffer.writeln('| :--- | :--- | :--- | :--- |');
    for (final ex in list) {
      final muscles = ex.primaryMuscles.map((m) => m.name).join(', ');
      buffer.writeln('| `${ex.id}` | ${ex.name} | ${ex.category.name} | $muscles |');
    }
    
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, 'nexc_available_exercises.md'));
    await file.writeAsString(buffer.toString());
    await Share.shareXFiles([XFile(file.path)], subject: 'Nexc Available Exercises List');
  }

  Future<void> exportProducts() async {
    final list = await db.select(db.products).get();
    final exportList = list.map((p) => <String, dynamic>{
      'name': p.name,
      'mlToGFactor': p.mlToGFactor,
      'defaultUnits': p.defaultUnits,
      'ediblePercent': p.ediblePercent,
      'kcal': p.kcal,
      'proteins': p.proteins,
      'carbsAvailable': p.carbsAvailable,
      'carbsByDifference': p.carbsByDifference,
      'dietaryFiber': p.dietaryFiber,
      'fats': p.fats,
      'isSupplement': p.isSupplement,
      'isPortable': p.isPortable,
    }).toList();
    
    final jsonString = jsonEncode(exportList);
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, 'nexc_products.json'));
    await file.writeAsString(jsonString);
    await Share.shareXFiles([XFile(file.path)], subject: 'Nexc Products Backup');
  }

  Future<ImportResult> importProducts() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return const ImportResult(success: false, error: 'No file selected');
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);
      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        final name = item['name'];
        if (name == null || name.toString().isEmpty) {
          return ImportResult.fail('Product #${i + 1}: missing name field');
        }

        final ediblePct = (item['ediblePercent'] as num?)?.toDouble() ?? 
                         ((item['edibleQtyPerUnit'] as num?)?.toDouble() != null ? (item['edibleQtyPerUnit'] * 100.0) : 100.0);

        final product = Product(
          id: 0,
          name: name,
          mlToGFactor: item['mlToGFactor'] as int?,
          defaultUnits: item['defaultUnits'] ?? item['units'],
          edibleQtyPerUnit: ediblePct / 100.0,
          kcal: (item['kcal'] as num?)?.toDouble(),
          proteins: (item['proteins'] as num?)?.toDouble() ?? 0.0,
          carbsAvailable: (item['carbsAvailable'] as num?)?.toDouble(),
          carbsByDifference: (item['carbsByDifference'] as num?)?.toDouble(),
          dietaryFiber: (item['dietaryFiber'] as num?)?.toDouble(),
          fats: (item['fats'] as num?)?.toDouble() ?? 0.0,
          isSupplement: item['isSupplement'] ?? false,
          isPortable: item['isPortable'] ?? true,
          isStockRaw: item['isStockRaw'] ?? false,
        );
        await mealRepo.saveProduct(product);
      }
      return const ImportResult.ok();
    } catch (e) {
      return ImportResult.fail(e.toString());
    }
  }

  Future<void> exportRecipes() async {
    final list = await db.select(db.recipes).get();
    final exportList = <Map<String, dynamic>>[];
    for (final recipe in list) {
      final ingredients = await (db.select(db.recipeIngredients)
            ..where((i) => i.recipeId.equals(recipe.id)))
          .get();
      
      final ingredientsExport = <Map<String, dynamic>>[];
      for (final ing in ingredients) {
        final product = await (db.select(db.products)
              ..where((p) => p.id.equals(ing.productId)))
            .getSingleOrNull();
        if (product != null) {
          ingredientsExport.add({
            'amount': ing.amount,
            'amountUnits': ing.amountUnits,
            'productName': product.name,
          });
        }
      }
      exportList.add({
        'name': recipe.name,
        'instructions': recipe.instructions,
        'isPortable': recipe.isPortable,
        'ingredients': ingredientsExport,
      });
    }
    
    final jsonString = jsonEncode(exportList);
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, 'nexc_recipes.json'));
    await file.writeAsString(jsonString);
    await Share.shareXFiles([XFile(file.path)], subject: 'Nexc Recipes Backup');
  }

  Future<ImportResult> importRecipes() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return const ImportResult(success: false, error: 'No file selected');
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);
      
      final productCache = await db.select(db.products).get();
      final mutableProductCache = productCache.toList();

      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        final name = item['name'] ?? '';
        if (name.isEmpty) {
          return ImportResult.fail('Recipe #${i + 1}: missing name field');
        }
        final instructions = item['instructions'] ?? '';
        final isPortable = item['isPortable'] ?? true;
        
        final List<dynamic> ingsJson = item['ingredients'] ?? [];
        final List<RecipeIngredientWithProduct> ingredientRelations = [];
        
        for (int j = 0; j < ingsJson.length; j++) {
          final ingJson = ingsJson[j];
          final productName = ingJson['productName'] ?? '';
          if (productName.isEmpty) {
            return ImportResult.fail('Recipe "$name", ingredient #${j + 1}: missing productName');
          }
          var product = mutableProductCache.firstWhereOrNull((p) => p.name.toLowerCase() == productName.toString().toLowerCase());
          if (product == null) {
            return ImportResult.fail(
              'Recipe "$name", ingredient #${j + 1}: '
              'product "$productName" not found in database. Import products first.',
            );
          }
          ingredientRelations.add(RecipeIngredientWithProduct(
            ingredient: RecipeIngredient(
              id: 0,
              recipeId: 0,
              productId: product.id,
              amount: (ingJson['amount'] as num?)?.toDouble() ?? 0.0,
              amountUnits: ingJson['amountUnits'],
            ),
            product: product,
          ));
        }

        final recipeData = RecipeWithIngredients(
          recipe: Recipe(id: 0, name: name, instructions: instructions, isPortable: isPortable),
          ingredients: ingredientRelations,
        );
        await mealRepo.saveRecipeWithIngredients(recipeData);
      }
      return const ImportResult.ok();
    } catch (e) {
      return ImportResult.fail(e.toString());
    }
  }

  Future<void> exportStock() async {
    final houses = await stockRepo.getHouses();
    final exportList = <Map<String, dynamic>>[];

    for (final house in houses) {
      final stocks = await stockRepo.getStocksWithProductForHouse(house.id);
      exportList.add({
        'houseName': house.name,
        'items': stocks.map((s) => {
          'productName': s.product.name,
          'quantity': s.stock.quantity,
          'unit': s.product.defaultUnits ?? 'g',
          'minTriggerQuantity': s.stock.minTriggerQuantity,
        }).toList(),
      });
    }

    final jsonString = jsonEncode(exportList);
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, 'nexc_stock.json'));
    await file.writeAsString(jsonString);
    await Share.shareXFiles([XFile(file.path)], subject: 'Nexc Stock Backup');
  }

  Future<ImportResult> importStock() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) {
        return const ImportResult(success: false, error: 'No file selected');
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      final productCache = await db.select(db.products).get();
      final houseCache = await stockRepo.getHouses();

      for (int hi = 0; hi < data.length; hi++) {
        final houseJson = data[hi];
        final houseName = houseJson['houseName'] as String? ?? 'House #${hi + 1}';

        // Find or create house
        House? house = houseCache.firstWhereOrNull(
          (h) => h.name.toLowerCase() == houseName.toLowerCase(),
        );
        if (house == null) {
          await stockRepo.saveHouse(House(id: 0, name: houseName));
          final all = await stockRepo.getHouses();
          house = all.firstWhereOrNull((h) => h.name.toLowerCase() == houseName.toLowerCase());
          if (house == null) continue;
        }

        final List<dynamic> items = houseJson['items'] ?? [];
        for (int si = 0; si < items.length; si++) {
          final itemJson = items[si];
          final productName = itemJson['productName'] as String? ?? '';
          if (productName.isEmpty) continue;

          final product = productCache.firstWhereOrNull(
            (p) => p.name.toLowerCase() == productName.toLowerCase(),
          );
          if (product == null) {
            return ImportResult.fail(
              'House "$houseName", item #${si + 1}: '
              'product "$productName" not found in database. Import products first.',
            );
          }

          final quantity = (itemJson['quantity'] as num?)?.toDouble() ?? 0.0;
          final unit = itemJson['unit'] as String? ?? product.defaultUnits ?? 'g';
          final trigger = (itemJson['minTriggerQuantity'] as num?)?.toDouble();

          await stockRepo.saveStock(
            productId: product.id,
            houseId: house.id,
            quantity: quantity,
            minTriggerQuantity: trigger,
            inputUnit: unit,
          );
        }
      }
      return const ImportResult.ok();
    } catch (e) {
      return ImportResult.fail(e.toString());
    }
  }
}

final backupManagerProvider = Provider<BackupManager>((ref) {
  final db = ref.watch(dbProvider);
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final mealRepo = ref.watch(mealRepositoryProvider);
  final datasetRepo = ref.watch(datasetRepositoryProvider);
  final stockRepo = ref.watch(stockRepositoryProvider);

  return BackupManager(
    db: db,
    workoutRepo: workoutRepo,
    mealRepo: mealRepo,
    datasetRepo: datasetRepo,
    stockRepo: stockRepo,
  );
});
