/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'app_database.dart';
import 'enums.dart';
import 'relations.dart';
import '../providers/db_provider.dart';

class MealRepository {
  final AppDatabase db;

  MealRepository(this.db);

  Stream<List<Product>> getAllProducts() {
    return (db.select(db.products)..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .watch();
  }

  Future<Product?> getProduct(int id) {
    return (db.select(db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<int> saveProduct(Product product) async {
    if (product.id == 0) {
      return db.into(db.products).insert(product.toCompanion(true));
    } else {
      await db.update(db.products).replace(product);
      return product.id;
    }
  }

  Future<void> deleteProduct(Product product) {
    return db.delete(db.products).delete(product);
  }

  Stream<List<RecipeWithIngredients>> getAllRecipes() {
    final query = db.select(db.recipes);
    return query
        .join([
          leftOuterJoin(db.recipeIngredients, db.recipeIngredients.recipeId.equalsExp(db.recipes.id)),
          leftOuterJoin(db.products, db.products.id.equalsExp(db.recipeIngredients.productId)),
        ])
        .watch()
        .map((rows) => _groupRowsToRecipes(rows));
  }

  Future<RecipeWithIngredients?> getRecipe(int id) async {
    final query = db.select(db.recipes)..where((r) => r.id.equals(id));
    final rows = await query.join([
      leftOuterJoin(db.recipeIngredients, db.recipeIngredients.recipeId.equalsExp(db.recipes.id)),
      leftOuterJoin(db.products, db.products.id.equalsExp(db.recipeIngredients.productId)),
    ]).get();

    final list = _groupRowsToRecipes(rows);
    return list.isNotEmpty ? list.first : null;
  }

  Future<int> saveRecipeWithIngredients(RecipeWithIngredients data) {
    return db.transaction(() async {
      final recipe = data.recipe;
      int recipeId;
      if (recipe.id == 0) {
        recipeId = await db.into(db.recipes).insert(
              RecipesCompanion.insert(
                name: recipe.name,
                instructions: recipe.instructions,
                isPortable: recipe.isPortable,
              ),
            );
      } else {
        await db.update(db.recipes).replace(recipe);
        recipeId = recipe.id;
      }

      final ingredients = data.ingredients;
      // delete old ingredients
      await (db.delete(db.recipeIngredients)..where((ri) => ri.recipeId.equals(recipeId))).go();

      // insert new ingredients
      for (final ing in ingredients) {
        await db.into(db.recipeIngredients).insert(
              RecipeIngredientsCompanion.insert(
                recipeId: recipeId,
                productId: ing.product.id,
                amount: ing.ingredient.amount,
              ),
            );
      }

      return recipeId;
    });
  }

  Future<void> deleteRecipe(Recipe recipe) {
    return db.delete(db.recipes).delete(recipe);
  }

  Stream<List<MealPlan>> getMealPlansByState(MealPlanState state) {
    return (db.select(db.mealPlans)
          ..where((mp) => mp.state.equalsValue(state))
          ..orderBy([(mp) => OrderingTerm(expression: mp.created, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<MealPlanWithMealsAndItems>> getMealPlansWithMealsAndItemsByState(MealPlanState state) {
    final query = db.select(db.mealPlans)
      ..where((mp) => mp.state.equalsValue(state))
      ..orderBy([(mp) => OrderingTerm(expression: mp.created, mode: OrderingMode.desc)]);

    return query
        .join([
          leftOuterJoin(db.meals, db.meals.mealPlanId.equalsExp(db.mealPlans.id)),
          leftOuterJoin(db.mealItems, db.mealItems.mealId.equalsExp(db.meals.id)),
          leftOuterJoin(db.products, db.products.id.equalsExp(db.mealItems.targetId)),
        ])
        .watch()
        .map((rows) => _groupRowsToMealPlans(rows));
  }

  Future<MealPlanWithMealsAndItems?> getMealPlanWithMealsAndItems(int id) async {
    final query = db.select(db.mealPlans)..where((mp) => mp.id.equals(id));
    final rows = await query.join([
      leftOuterJoin(db.meals, db.meals.mealPlanId.equalsExp(db.mealPlans.id)),
      leftOuterJoin(db.mealItems, db.mealItems.mealId.equalsExp(db.meals.id)),
      leftOuterJoin(db.products, db.products.id.equalsExp(db.mealItems.targetId)),
    ]).get();

    final list = _groupRowsToMealPlans(rows);
    return list.isNotEmpty ? list.first : null;
  }

  Stream<MealPlanWithMealsAndItems?> watchMealPlanWithMealsAndItems(int id) {
    final query = db.select(db.mealPlans)..where((mp) => mp.id.equals(id));
    return query
        .join([
          leftOuterJoin(db.meals, db.meals.mealPlanId.equalsExp(db.mealPlans.id)),
          leftOuterJoin(db.mealItems, db.mealItems.mealId.equalsExp(db.meals.id)),
          leftOuterJoin(db.products, db.products.id.equalsExp(db.mealItems.targetId)),
        ])
        .watch()
        .map((rows) {
          final list = _groupRowsToMealPlans(rows);
          return list.isNotEmpty ? list.first : null;
        });
  }

  Future<MealPlan?> getMealPlan(int id) {
    return (db.select(db.mealPlans)..where((mp) => mp.id.equals(id))).getSingleOrNull();
  }

  Future<int> saveMealPlanWithMealsAndItems(MealPlanWithMealsAndItems data) {
    return db.transaction(() async {
      final plan = data.mealPlan;
      int planId;
      if (plan.id == 0) {
        planId = await db.into(db.mealPlans).insert(
              MealPlansCompanion.insert(
                parentPlanId: plan.parentPlanId,
                title: plan.title,
                notes: plan.notes,
                state: plan.state,
                created: plan.created,
                completed: plan.completed,
              ),
            );
      } else {
        await db.update(db.mealPlans).replace(plan);
        planId = plan.id;
      }

      final mealsList = data.meals;

      // delete old meals
      final oldMeals = await (db.select(db.meals)..where((m) => m.mealPlanId.equals(planId))).get();
      for (final m in oldMeals) {
        await (db.delete(db.mealItems)..where((mi) => mi.mealId.equals(m.id))).go();
      }
      await (db.delete(db.meals)..where((m) => m.mealPlanId.equals(planId))).go();

      // insert meals & items
      for (final mealWithItems in mealsList) {
        final mealId = await db.into(db.meals).insert(
              MealsCompanion.insert(
                mealPlanId: planId,
                name: mealWithItems.meal.name,
                time: mealWithItems.meal.time,
                notes: mealWithItems.meal.notes,
                position: mealWithItems.meal.position,
              ),
            );

        for (final itemDetail in mealWithItems.items) {
          await db.into(db.mealItems).insert(
                MealItemsCompanion.insert(
                  mealId: mealId,
                  type: itemDetail.mealItem.type,
                  targetId: itemDetail.mealItem.targetId,
                  amount: itemDetail.mealItem.amount,
                  consumed: itemDetail.mealItem.consumed,
                  position: itemDetail.mealItem.position,
                ),
              );
        }
      }

      return planId;
    });
  }

  Future<void> deleteMealPlan(MealPlan mealPlan) {
    return db.delete(db.mealPlans).delete(mealPlan);
  }

  Future<void> updateMealItem(MealItem mealItem) {
    return db.update(db.mealItems).replace(mealItem);
  }

  Future<void> deleteMealItem(MealItem mealItem) {
    return db.delete(db.mealItems).delete(mealItem);
  }

  Future<int> insertMealItem(MealItem mealItem) {
    return db.into(db.mealItems).insert(mealItem.toCompanion(true));
  }

  Future<void> updateMeal(Meal meal) {
    return db.update(db.meals).replace(meal);
  }

  Future<void> selectMealPlanForToday(MealPlanWithMealsAndItems template) async {
    return db.transaction(() async {
      final now = DateTime.now();
      final logsList = await (db.select(db.mealPlans)
            ..where((mp) => mp.state.equalsValue(MealPlanState.LOGGED)))
          .get();
      final existingTodayPlan = logsList.firstWhereOrNull(
        (mp) =>
            mp.created.year == now.year &&
            mp.created.month == now.month &&
            mp.created.day == now.day,
      );

      if (existingTodayPlan != null) {
        await db.delete(db.mealPlans).delete(existingTodayPlan);
      }

      final newPlan = MealPlan(
        id: 0,
        parentPlanId: template.mealPlan.id,
        title: template.mealPlan.title,
        notes: template.mealPlan.notes,
        state: MealPlanState.LOGGED,
        created: now,
        completed: now,
      );

      final newMeals = template.meals.map((m) {
        final newItems = m.items.map((item) {
          return MealItemWithDetails(
            mealItem: MealItem(
              id: 0,
              mealId: 0,
              type: item.mealItem.type,
              targetId: item.mealItem.targetId,
              amount: item.mealItem.amount,
              consumed: false,
              position: item.mealItem.position,
            ),
            product: item.product,
            recipe: item.recipe,
          );
        }).toList();

        return MealWithItems(
          meal: Meal(
            id: 0,
            mealPlanId: 0,
            name: m.meal.name,
            time: m.meal.time,
            notes: m.meal.notes,
            position: m.meal.position,
          ),
          items: newItems,
        );
      }).toList();

      await saveMealPlanWithMealsAndItems(
        MealPlanWithMealsAndItems(mealPlan: newPlan, meals: newMeals),
      );
    });
  }

  Future<void> updateMealTime(int mealId, LocalTime newTime) async {
    final oldMeal = await (db.select(db.meals)..where((m) => m.id.equals(mealId))).getSingle();
    await updateMeal(oldMeal.copyWith(time: newTime));
  }

  Future<void> updateMealItemAmount(int itemId, double newAmount) async {
    final oldItem = await (db.select(db.mealItems)..where((mi) => mi.id.equals(itemId))).getSingle();
    await updateMealItem(oldItem.copyWith(amount: newAmount));
  }

  Future<void> addMealItemToMeal({
    required int mealId,
    required MealItemType type,
    required int targetId,
    required double amount,
  }) async {
    final itemsList = await (db.select(db.mealItems)..where((mi) => mi.mealId.equals(mealId))).get();
    final maxPos = itemsList.map((i) => i.position).fold(-1, (prev, element) => element > prev ? element : prev);
    
    await insertMealItem(
      MealItem(
        id: 0,
        mealId: mealId,
        type: type,
        targetId: targetId,
        amount: amount,
        consumed: false,
        position: maxPos + 1,
      ),
    );
  }

  Future<void> replaceMealItemInMeal({
    required int oldItemId,
    required MealItemType newType,
    required int newTargetId,
    required double newAmount,
  }) async {
    await db.transaction(() async {
      final oldItem = await (db.select(db.mealItems)..where((mi) => mi.id.equals(oldItemId))).getSingle();
      await deleteMealItem(oldItem);
      await insertMealItem(
        MealItem(
          id: 0,
          mealId: oldItem.mealId,
          type: newType,
          targetId: newTargetId,
          amount: newAmount,
          consumed: false,
          position: oldItem.position,
        ),
      );
    });
  }

  Future<int> startEmptyTracking() async {
    final now = DateTime.now();
    final newPlan = MealPlan(
      id: 0,
      parentPlanId: 0,
      title: "Today's Meal Log",
      notes: "",
      state: MealPlanState.LOGGED,
      created: now,
      completed: now,
    );
    return saveMealPlanWithMealsAndItems(
      MealPlanWithMealsAndItems(mealPlan: newPlan, meals: []),
    );
  }


  Future<int> getMealPlansCount() async {
    final countExpr = db.mealPlans.id.count();
    final query = db.selectOnly(db.mealPlans)..addColumns([countExpr]);
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  Future<void> prepopulateDefaultMealPlans() async {
    final count = await getMealPlansCount();
    if (count > 0) return;

    // 1. Insert Products
    final productsList = [
      const Product(id: 10001, name: "Whole Milk", weight: 1000.0, cost: 1.20, quantity: 2, units: "ml", ediblePercent: 1.0, edibleQtyPerUnit: 0.0, proteins: 3.3, carbs: 4.7, fats: 3.6, isSupplement: false, isPortable: true),
      const Product(id: 10002, name: "Oatmeal Cookies", weight: 200.0, cost: 1.50, quantity: 5, units: "g", ediblePercent: 1.0, edibleQtyPerUnit: 0.0, proteins: 6.5, carbs: 65.0, fats: 15.0, isSupplement: false, isPortable: true),
      const Product(id: 10003, name: "Creatine Monohydrate", weight: 300.0, cost: 18.00, quantity: 1, units: "g", ediblePercent: 1.0, edibleQtyPerUnit: 0.0, proteins: 0.0, carbs: 0.0, fats: 0.0, isSupplement: true, isPortable: true),
      const Product(id: 10004, name: "Chicken Breast", weight: 1000.0, cost: 7.50, quantity: 1, units: "g", ediblePercent: 1.0, edibleQtyPerUnit: 0.0, proteins: 31.0, carbs: 0.0, fats: 3.6, isSupplement: false, isPortable: true),
      const Product(id: 10005, name: "Cooked Rice", weight: 1000.0, cost: 1.50, quantity: 3, units: "g", ediblePercent: 1.0, edibleQtyPerUnit: 0.0, proteins: 2.7, carbs: 28.0, fats: 0.3, isSupplement: false, isPortable: true),
      const Product(id: 10006, name: "Banana", weight: 150.0, cost: 0.30, quantity: 6, units: "g", ediblePercent: 0.65, edibleQtyPerUnit: 97.5, proteins: 1.1, carbs: 22.8, fats: 0.3, isSupplement: false, isPortable: true),
      const Product(id: 10007, name: "Whole Eggs", weight: 60.0, cost: 0.15, quantity: 30, units: "unit", ediblePercent: 0.88, edibleQtyPerUnit: 52.8, proteins: 13.0, carbs: 1.1, fats: 11.0, isSupplement: false, isPortable: true),
      const Product(id: 10008, name: "Fresh Spinach", weight: 250.0, cost: 1.20, quantity: 1, units: "g", ediblePercent: 0.95, edibleQtyPerUnit: 0.0, proteins: 2.9, carbs: 3.6, fats: 0.4, isSupplement: false, isPortable: false),
      const Product(id: 10009, name: "Grilled Salmon", weight: 200.0, cost: 6.00, quantity: 2, units: "g", ediblePercent: 1.0, edibleQtyPerUnit: 0.0, proteins: 25.0, carbs: 0.0, fats: 13.0, isSupplement: false, isPortable: false),
    ];

    for (final p in productsList) {
      await db.into(db.products).insert(p.toCompanion(true));
    }

    // 2. Insert Recipes
    final scrambledEggs = const Recipe(id: 20001, name: "Scrambled Eggs with Spinach", instructions: "Heat a pan with a drop of oil. Pour in 2 beaten eggs and clean spinach. Cook for 3 minutes.", isPortable: true);
    final scrambledIngredients = [
      RecipeIngredientWithProduct(ingredient: const RecipeIngredient(id: 0, recipeId: 20001, productId: 10007, amount: 120.0), product: productsList[6]),
      RecipeIngredientWithProduct(ingredient: const RecipeIngredient(id: 0, recipeId: 20001, productId: 10008, amount: 50.0), product: productsList[7]),
    ];
    await saveRecipeWithIngredients(RecipeWithIngredients(recipe: scrambledEggs, ingredients: scrambledIngredients));

    final salmonSalad = const Recipe(id: 20002, name: "Salmon Salad", instructions: "Mix grilled salmon with clean spinach and a splash of olive oil.", isPortable: true);
    final saladIngredients = [
      RecipeIngredientWithProduct(ingredient: const RecipeIngredient(id: 0, recipeId: 20002, productId: 10009, amount: 150.0), product: productsList[8]),
      RecipeIngredientWithProduct(ingredient: const RecipeIngredient(id: 0, recipeId: 20002, productId: 10008, amount: 50.0), product: productsList[7]),
    ];
    await saveRecipeWithIngredients(RecipeWithIngredients(recipe: salmonSalad, ingredients: saladIngredients));

    // 3. Insert Meal Plan
    final now = DateTime.now();
    final mealPlan = MealPlan(
      id: 30001,
      parentPlanId: 0,
      title: "Daily High-Protein & Supplement Plan",
      notes: "Focused day including natural food and pre/post training supplements.",
      state: MealPlanState.TEMPLATE,
      created: now,
      completed: now,
    );

    final m1 = const Meal(id: 40001, mealPlanId: 30001, name: "Breakfast & Supplementation", time: LocalTime(8, 0), notes: "Take immediately upon waking up with plenty of water.", position: 0);
    final m1Items = [
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40001, type: MealItemType.PRODUCT, targetId: 10001, amount: 250.0, consumed: false, position: 0), product: productsList[0]),
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40001, type: MealItemType.PRODUCT, targetId: 10002, amount: 50.0, consumed: false, position: 1), product: productsList[1]),
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40001, type: MealItemType.PRODUCT, targetId: 10003, amount: 5.0, consumed: false, position: 2), product: productsList[2]),
    ];

    final m2 = const Meal(id: 40002, mealPlanId: 30001, name: "Lunch", time: LocalTime(13, 30), notes: "Main meal of the day.", position: 1);
    final m2Items = [
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40002, type: MealItemType.PRODUCT, targetId: 10004, amount: 100.0, consumed: false, position: 0), product: productsList[3]),
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40002, type: MealItemType.PRODUCT, targetId: 10005, amount: 100.0, consumed: false, position: 1), product: productsList[4]),
    ];

    final m3 = const Meal(id: 40003, mealPlanId: 30001, name: "Pre-Workout Snack", time: LocalTime(17, 0), notes: "1 hour before training.", position: 2);
    final m3Items = [
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40003, type: MealItemType.PRODUCT, targetId: 10006, amount: 100.0, consumed: false, position: 0), product: productsList[5]),
    ];

    final m4 = const Meal(id: 40004, mealPlanId: 30001, name: "Dinner", time: LocalTime(21, 0), notes: "Light meal before sleeping.", position: 3);
    final m4Items = [
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40004, type: MealItemType.RECIPE, targetId: 20001, amount: 1.0, consumed: false, position: 0), recipe: RecipeWithIngredients(recipe: scrambledEggs, ingredients: scrambledIngredients)),
    ];

    final mealsList = [
      MealWithItems(meal: m1, items: m1Items),
      MealWithItems(meal: m2, items: m2Items),
      MealWithItems(meal: m3, items: m3Items),
      MealWithItems(meal: m4, items: m4Items),
    ];

    await saveMealPlanWithMealsAndItems(MealPlanWithMealsAndItems(mealPlan: mealPlan, meals: mealsList));

    // 4. Insert Second Meal Plan (Clean Bulk)
    final cleanBulkPlan = MealPlan(
      id: 30002,
      parentPlanId: 0,
      title: "Clean Bulk Meal Plan",
      notes: "Balanced calorie surplus plan for muscle building.",
      state: MealPlanState.TEMPLATE,
      created: now,
      completed: now,
    );

    final cleanBulkM1 = const Meal(id: 40005, mealPlanId: 30002, name: "Breakfast", time: LocalTime(7, 30), notes: "High carb and protein to start the day.", position: 0);
    final cleanBulkM1Items = [
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40005, type: MealItemType.RECIPE, targetId: 20001, amount: 1.5, consumed: false, position: 0), recipe: RecipeWithIngredients(recipe: scrambledEggs, ingredients: scrambledIngredients)),
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40005, type: MealItemType.PRODUCT, targetId: 10006, amount: 150.0, consumed: false, position: 1), product: productsList[5]),
    ];

    final cleanBulkM2 = const Meal(id: 40006, mealPlanId: 30002, name: "Lunch", time: LocalTime(13, 0), notes: "Post-workout nutrient replenishment.", position: 1);
    final cleanBulkM2Items = [
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40006, type: MealItemType.PRODUCT, targetId: 10004, amount: 150.0, consumed: false, position: 0), product: productsList[3]),
      MealItemWithDetails(mealItem: const MealItem(id: 0, mealId: 40006, type: MealItemType.PRODUCT, targetId: 10005, amount: 200.0, consumed: false, position: 1), product: productsList[4]),
    ];

    final cleanBulkMealsList = [
      MealWithItems(meal: cleanBulkM1, items: cleanBulkM1Items),
      MealWithItems(meal: cleanBulkM2, items: cleanBulkM2Items),
    ];

    await saveMealPlanWithMealsAndItems(MealPlanWithMealsAndItems(mealPlan: cleanBulkPlan, meals: cleanBulkMealsList));
  }

  List<RecipeWithIngredients> _groupRowsToRecipes(List<TypedResult> rows) {
    final recipesMap = <int, Recipe>{};
    final ingredientsMap = <int, List<RecipeIngredientWithProduct>>{};

    for (final row in rows) {
      final recipe = row.readTable(db.recipes);
      final ingredient = row.readTableOrNull(db.recipeIngredients);
      final product = row.readTableOrNull(db.products);

      recipesMap[recipe.id] = recipe;

      if (ingredient != null && product != null) {
        ingredientsMap.putIfAbsent(recipe.id, () => []).add(
              RecipeIngredientWithProduct(ingredient: ingredient, product: product),
            );
      }
    }

    return recipesMap.entries.map((entry) {
      return RecipeWithIngredients(
        recipe: entry.value,
        ingredients: ingredientsMap[entry.key] ?? [],
      );
    }).toList();
  }

  List<MealPlanWithMealsAndItems> _groupRowsToMealPlans(List<TypedResult> rows) {
    final planMap = <int, MealPlan>{};
    final mealsMap = <int, Map<int, MealWithItems>>{}; // planId -> (mealId -> MealWithItems)

    for (final row in rows) {
      final plan = row.readTable(db.mealPlans);
      final meal = row.readTableOrNull(db.meals);
      final item = row.readTableOrNull(db.mealItems);
      final product = row.readTableOrNull(db.products);

      planMap[plan.id] = plan;

      if (meal != null) {
        final planMeals = mealsMap.putIfAbsent(plan.id, () => <int, MealWithItems>{});
        final mealWithItems = planMeals.putIfAbsent(meal.id, () => MealWithItems(meal: meal, items: []));

        if (item != null) {
          if (!mealWithItems.items.any((mi) => mi.mealItem.id == item.id)) {
            mealWithItems.items.add(
              MealItemWithDetails(
                mealItem: item,
                product: product,
              ),
            );
          }
        }
      }
    }

    return planMap.entries.map((entry) {
      final planId = entry.key;
      final plan = entry.value;
      final planMeals = mealsMap[planId] ?? {};
      final sortedMeals = planMeals.values.toList()..sort((a, b) => a.meal.position.compareTo(b.meal.position));
      return MealPlanWithMealsAndItems(
        mealPlan: plan,
        meals: sortedMeals,
      );
    }).toList();
  }
}

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final db = ref.watch(dbProvider);
  return MealRepository(db);
});
