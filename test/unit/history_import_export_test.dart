/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/db/workout_repository.dart';
import 'package:nexc_flutter/core/db/meal_repository.dart';
import 'package:nexc_flutter/core/db/stock_repository.dart';
import 'package:nexc_flutter/core/db/dataset_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository workoutRepo;
  late MealRepository mealRepo;
  late StockRepository stockRepo;
  late DatasetRepository datasetRepo;

  setUp(() async {
    db = AppDatabase.executor(NativeDatabase.memory());
    workoutRepo = WorkoutRepository(db);
    mealRepo = MealRepository(db);
    stockRepo = StockRepository(db);
    datasetRepo = DatasetRepository(db);

    // Seed test custom exercise
    await datasetRepo.upsertExercise(const ExerciseDataDC(
      id: 'barbell_squat',
      name: 'Barbell Back Squat',
      level: Level.INTERMEDIATE,
      primaryMuscles: [Muscle.QUADRICEPS],
      secondaryMuscles: [Muscle.GLUTES],
      instructions: ['Squat down', 'Drive up'],
      category: Category.POWERLIFTING,
      images: [],
      isCustomExercise: true,
    ));

    await datasetRepo.upsertExercise(const ExerciseDataDC(
      id: 'bench_press',
      name: 'Bench Press',
      level: Level.BEGINNER,
      primaryMuscles: [Muscle.CHEST],
      secondaryMuscles: [Muscle.TRICEPS],
      instructions: ['Lower bar to chest', 'Press up'],
      category: Category.POWERLIFTING,
      images: [],
      isCustomExercise: true,
    ));

    // Seed test product
    await db.into(db.products).insert(
          ProductsCompanion.insert(
            id: const drift.Value(501),
            name: 'Rolled Oats',
            edibleQtyPerUnit: const drift.Value(1.0),
            defaultUnits: const drift.Value('g'),
            kcal: const drift.Value(389.0),
            proteins: 16.9,
            carbsAvailable: const drift.Value(66.3),
            fats: 6.9,
            isSupplement: false,
            isPortable: const drift.Value(true),
          ),
        );

    await stockRepo.ensureDefaultHouse();
  });

  tearDown(() async {
    await db.close();
  });

  group('History Import & Export Round-Trip Serialization Tests', () {
    test('Workout history export and import round-trip JSON serialization preserves all details', () async {
      final completedTime = DateTime(2026, 9, 30, 18, 45, 0);
      final createdTime = DateTime(2026, 9, 30, 17, 30, 0);

      // 1. Create a completed workout directly in the database
      final workoutId = await db.into(db.workouts).insert(
            WorkoutsCompanion.insert(
              routineId: 0,
              title: 'Leg Day Heavy',
              notes: 'Hit high intensity PRs',
              state: WorkoutState.COMPLETED,
              timeElapsed: 4500,
              created: createdTime,
              completed: completedTime,
              isTemporal: const drift.Value(false),
            ),
          );

      final ex1Id = await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              exerciseDataId: 'barbell_squat',
              workoutId: workoutId,
              notes: 'Felt strong',
              setMode: SetMode.LOAD,
              restTime: 180,
              position: const drift.Value(0),
            ),
          );

      await db.into(db.sets).insert(
            SetsCompanion.insert(
              exerciseId: ex1Id,
              load: 140.0,
              reps: 5,
              elapsedTime: 35,
              completed: true,
              rpe: const drift.Value(8.5),
              rir: const drift.Value(1),
            ),
          );

      await db.into(db.sets).insert(
            SetsCompanion.insert(
              exerciseId: ex1Id,
              load: 145.0,
              reps: 3,
              elapsedTime: 40,
              completed: true,
              rpe: const drift.Value(9.5),
              rir: const drift.Value(0),
            ),
          );

      // Verify database contains this completed workout
      final originalWorkout = await workoutRepo.getWorkoutWithExercisesAndSets(workoutId);
      expect(originalWorkout, isNotNull);
      expect(originalWorkout!.workout.state, equals(WorkoutState.COMPLETED));

      // 2. Export completed workouts to JSON
      final completedWorkouts = await (db.select(db.workouts)
            ..where((w) => w.state.equalsValue(WorkoutState.COMPLETED)))
          .get();

      final exportList = <Map<String, dynamic>>[];
      for (final w in completedWorkouts) {
        final wData = await workoutRepo.getWorkoutWithExercisesAndSets(w.id);
        if (wData != null) {
          exportList.add({
            'title': wData.workout.title,
            'notes': wData.workout.notes,
            'state': wData.workout.state.name,
            'timeElapsed': wData.workout.timeElapsed,
            'created': wData.workout.created.toIso8601String(),
            'completed': wData.workout.completed.toIso8601String(),
            'exercises': wData.exercisesWithSets.map((e) => {
              'exerciseId': e.exerciseDC.id,
              'name': e.exerciseDC.name,
              'notes': e.exercise.notes,
              'setMode': e.exercise.setMode.name,
              'restTime': e.exercise.restTime,
              'position': e.exercise.position,
              'sets': e.sets.map((s) => {
                'load': s.load,
                'reps': s.reps,
                'elapsedTime': s.elapsedTime,
                'rpe': s.rpe,
                'rir': s.rir,
                'completed': s.completed,
              }).toList(),
            }).toList(),
          });
        }
      }

      final jsonString = jsonEncode(exportList);
      expect(jsonString.contains('Leg Day Heavy'), isTrue);
      expect(jsonString.contains('140.0'), isTrue);
      expect(jsonString.contains('COMPLETED'), isTrue);

      // 3. Clear database to simulate restore onto clean state / new device
      await db.delete(db.sets).go();
      await db.delete(db.exercises).go();
      await db.delete(db.workouts).go();

      expect((await db.select(db.workouts).get()).isEmpty, isTrue);

      // 4. Import from JSON back into database
      final List<dynamic> importedList = jsonDecode(jsonString);
      for (final item in importedList) {
        final importedWorkout = Workout(
          id: 0,
          routineId: 0,
          title: item['title'] ?? '',
          notes: item['notes'] ?? '',
          state: WorkoutState.values.firstWhere((s) => s.name == item['state'], orElse: () => WorkoutState.COMPLETED),
          timeElapsed: item['timeElapsed'] ?? 0,
          position: 0,
          created: DateTime.parse(item['created']),
          completed: DateTime.parse(item['completed']),
          isTemporal: false,
        );

        final exercises = <ExerciseWithSets>[];
        for (final exJson in (item['exercises'] as List<dynamic>)) {
          final exerciseDC = await datasetRepo.getExerciseFromId(exJson['exerciseId']);
          expect(exerciseDC, isNotNull);

          final sets = (exJson['sets'] as List<dynamic>).map((s) => WorkoutSet(
            id: 0,
            load: (s['load'] as num).toDouble(),
            weightUnit: WeightUnit.values.firstWhere(
              (u) => u.name.toLowerCase() == (s['weightUnit']?.toString().toLowerCase()),
              orElse: () => WeightUnit.kg,
            ),
            reps: s['reps'] as int,
            elapsedTime: s['elapsedTime'] as int,
            completed: s['completed'] as bool,
            setType: SetType.values.firstWhere(
              (st) => st.name.toLowerCase() == (s['setType']?.toString().toLowerCase()),
              orElse: () => SetType.NORMAL,
            ),
            rpe: (s['rpe'] as num?)?.toDouble(),
            rir: s['rir'] as int?,
            exerciseId: 0,
          )).toList();

          exercises.add(ExerciseWithSets(
            exercise: Exercise(
              id: 0,
              exerciseDataId: exJson['exerciseId'],
              notes: exJson['notes'] ?? '',
              setMode: SetMode.values.firstWhere((m) => m.name == exJson['setMode']),
              restTime: exJson['restTime'] ?? 0,
              position: exJson['position'] ?? 0,
              workoutId: 0,
            ),
            exerciseDC: exerciseDC!,
            sets: sets,
          ));
        }

        await workoutRepo.addWorkoutWithExercisesAndSets(WorkoutWithExercisesAndSets(
          workout: importedWorkout,
          exercisesWithSets: exercises,
        ));
      }

      // 5. Verify restored workout integrity
      final restoredWorkouts = await (db.select(db.workouts)
            ..where((w) => w.state.equalsValue(WorkoutState.COMPLETED)))
          .get();
      expect(restoredWorkouts.length, equals(1));

      final restored = await workoutRepo.getWorkoutWithExercisesAndSets(restoredWorkouts.first.id);
      expect(restored, isNotNull);
      expect(restored!.workout.title, equals('Leg Day Heavy'));
      expect(restored.workout.state, equals(WorkoutState.COMPLETED));
      expect(restored.workout.completed, equals(completedTime));
      expect(restored.exercisesWithSets.length, equals(1));

      final ex = restored.exercisesWithSets.first;
      expect(ex.exerciseDC.id, equals('barbell_squat'));
      expect(ex.sets.length, equals(2));
      expect(ex.sets[0].load, equals(140.0));
      expect(ex.sets[0].reps, equals(5));
      expect(ex.sets[0].rpe, equals(8.5));
      expect(ex.sets[0].rir, equals(1));
      expect(ex.sets[1].load, equals(145.0));
      expect(ex.sets[1].rpe, equals(9.5));
      expect(ex.sets[1].rir, equals(0));
    });

    test('Meal history export and import round-trip JSON serialization preserves logged meals and items', () async {
      final eatenDate = DateTime(2026, 10, 1, 8, 30, 0);

      // Create a logged meal plan in DB
      final planId = await db.into(db.mealPlans).insert(
            MealPlansCompanion.insert(
              parentPlanId: 0,
              title: 'Morning Breakfast Log',
              notes: 'Pre-workout carbs',
              state: MealPlanState.LOGGED,
              created: eatenDate,
              completed: eatenDate,
              targetProtein: const drift.Value(30.0),
              targetCarbs: const drift.Value(80.0),
              targetFats: const drift.Value(15.0),
              isTemporal: const drift.Value(true),
            ),
          );

      final mealId = await db.into(db.meals).insert(
            MealsCompanion.insert(
              mealPlanId: planId,
              name: 'Breakfast',
              time: const LocalTime(8, 30),
              notes: 'Oatmeal bowl',
              position: 0,
              atHome: const drift.Value(true),
            ),
          );

      await db.into(db.mealItems).insert(
            MealItemsCompanion.insert(
              mealId: mealId,
              type: MealItemType.PRODUCT,
              targetId: 501, // Rolled Oats
              amount: 100.0,
              amountUnit: const drift.Value(AmountUnit.GRAMS),
              consumed: true,
              position: 0,
            ),
          );

      // Export meal history
      final loggedPlans = await (db.select(db.mealPlans)
            ..where((p) => p.state.equalsValue(MealPlanState.LOGGED)))
          .get();

      final exportList = <Map<String, dynamic>>[];
      for (final p in loggedPlans) {
        final planWithMeals = await mealRepo.watchMealPlanWithMealsAndItems(p.id).first;
        if (planWithMeals != null) {
          exportList.add({
            'title': planWithMeals.mealPlan.title,
            'notes': planWithMeals.mealPlan.notes,
            'state': planWithMeals.mealPlan.state.name,
            'created': planWithMeals.mealPlan.created.toIso8601String(),
            'completed': planWithMeals.mealPlan.completed.toIso8601String(),
            'meals': planWithMeals.meals.map((m) => {
              'name': m.meal.name,
              'time': m.meal.time.toString(),
              'notes': m.meal.notes,
              'atHome': m.meal.atHome,
              'items': m.items.map((it) => {
                'type': it.mealItem.type.name,
                'targetId': it.mealItem.targetId,
                'productName': it.product?.name,
                'amount': it.mealItem.amount,
                'amountUnit': it.mealItem.amountUnit.name,
                'consumed': it.mealItem.consumed,
              }).toList(),
            }).toList(),
          });
        }
      }

      final jsonString = jsonEncode(exportList);
      expect(jsonString.contains('Morning Breakfast Log'), isTrue);
      expect(jsonString.contains('Rolled Oats'), isTrue);

      // Clear meals
      await db.delete(db.mealItems).go();
      await db.delete(db.meals).go();
      await db.delete(db.mealPlans).go();

      // Import back
      final List<dynamic> importedList = jsonDecode(jsonString);
      for (final pJson in importedList) {
        final plan = MealPlan(
          id: 0,
          parentPlanId: 0,
          title: pJson['title'],
          notes: pJson['notes'],
          state: MealPlanState.values.firstWhere((s) => s.name == pJson['state']),
          created: DateTime.parse(pJson['created']),
          completed: DateTime.parse(pJson['completed']),
          isTemporal: true,
        );

        final mealsWithItems = <MealWithItems>[];
        for (final mJson in (pJson['meals'] as List<dynamic>)) {
          final meal = Meal(
            id: 0,
            mealPlanId: 0,
            name: mJson['name'],
            time: LocalTime.parse(mJson['time']),
            notes: mJson['notes'],
            position: 0,
            atHome: mJson['atHome'] ?? true,
          );

          final items = <MealItemWithDetails>[];
          for (final itJson in (mJson['items'] as List<dynamic>)) {
            final product = await (db.select(db.products)..where((p) => p.id.equals(itJson['targetId']))).getSingleOrNull();
            items.add(MealItemWithDetails(
              mealItem: MealItem(
                id: 0,
                mealId: 0,
                type: MealItemType.values.firstWhere((t) => t.name == itJson['type']),
                targetId: itJson['targetId'],
                amount: (itJson['amount'] as num).toDouble(),
                amountUnit: AmountUnit.values.firstWhere((u) => u.name == itJson['amountUnit']),
                consumed: itJson['consumed'],
                position: 0,
              ),
              product: product,
            ));
          }
          mealsWithItems.add(MealWithItems(meal: meal, items: items));
        }

        await mealRepo.saveMealPlanWithMealsAndItems(MealPlanWithMealsAndItems(
          mealPlan: plan,
          meals: mealsWithItems,
        ));
      }

      // Verify restored meal plan
      final restoredPlans = await (db.select(db.mealPlans)
            ..where((p) => p.state.equalsValue(MealPlanState.LOGGED)))
          .get();
      expect(restoredPlans.length, equals(1));
      expect(restoredPlans.first.title, equals('Morning Breakfast Log'));

      final restoredWithItems = await mealRepo.watchMealPlanWithMealsAndItems(restoredPlans.first.id).first;
      expect(restoredWithItems!.meals.length, equals(1));
      expect(restoredWithItems.meals.first.items.length, equals(1));
      expect(restoredWithItems.meals.first.items.first.mealItem.amount, equals(100.0));
      expect(restoredWithItems.meals.first.items.first.mealItem.consumed, isTrue);
    });

    test('Meal history import suppresses stock mutations: stock quantities remain strictly unchanged', () async {
      // 1. Establish initial stock for Rolled Oats (product 501): 800 grams
      final houses = await stockRepo.getHouses();
      final defaultHouseId = houses.first.id;

      await stockRepo.saveStock(
        productId: 501,
        houseId: defaultHouseId,
        quantity: 800.0,
        minTriggerQuantity: 200.0,
        inputUnit: 'g',
      );

      final initialStocks = await stockRepo.getStocksWithProductForHouse(defaultHouseId);
      final oatsStock = initialStocks.firstWhere((s) => s.product.id == 501);
      expect(oatsStock.stock.quantity, equals(800.0));
      expect(oatsStock.stock.quantityGrams, equals(800.0));

      // 2. Simulate meal history import with 250g of oats consumed
      final historyMeal = MealPlanWithMealsAndItems(
        mealPlan: MealPlan(
          id: 0,
          parentPlanId: 0,
          title: 'Historical Logged Meal',
          notes: 'Consumed yesterday',
          state: MealPlanState.LOGGED,
          created: DateTime.now().subtract(const Duration(days: 1)),
          completed: DateTime.now().subtract(const Duration(days: 1)),
          isTemporal: true,
        ),
        meals: [
          MealWithItems(
            meal: const Meal(
              id: 0,
              mealPlanId: 0,
              name: 'Lunch',
              time: LocalTime(13, 0),
              notes: '',
              position: 0,
              atHome: true,
            ),
            items: [
              MealItemWithDetails(
                mealItem: const MealItem(
                  id: 0,
                  mealId: 0,
                  type: MealItemType.PRODUCT,
                  targetId: 501,
                  amount: 250.0,
                  amountUnit: AmountUnit.GRAMS,
                  consumed: true,
                  position: 0,
                ),
                product: oatsStock.product,
              ),
            ],
          )
        ],
      );

      // Save as historical meal plan without stock deduction
      await mealRepo.saveMealPlanWithMealsAndItems(historyMeal);

      // 3. Verify stock quantities are UNCHANGED (suppressed, still 800.0g, not 550.0g)
      final postImportStocks = await stockRepo.getStocksWithProductForHouse(defaultHouseId);
      final postOatsStock = postImportStocks.firstWhere((s) => s.product.id == 501);

      expect(postOatsStock.stock.quantity, equals(800.0),
          reason: 'Importing historical logged meals must not deplete current pantry inventory');
      expect(postOatsStock.stock.quantityGrams, equals(800.0));
    });
  });
}
