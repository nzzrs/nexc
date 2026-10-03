/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../db/enums.dart';
import '../db/relations.dart';
import '../db/meal_repository.dart';

import '../providers/db_provider.dart';

import '../util/day_window_helper.dart';
import 'settings_provider.dart';

class ConsumedMacros {
  final double protein;
  final double carbs;
  final double fats;
  final double calories;

  const ConsumedMacros({
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fats = 0.0,
    this.calories = 0.0,
  });

  ConsumedMacros operator +(ConsumedMacros other) {
    return ConsumedMacros(
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fats: fats + other.fats,
      calories: calories + other.calories,
    );
  }
}

ConsumedMacros calculateMealItemMacros(MealItemWithDetails detail) {
  final scale = detail.macroScale;
  double prot = 0.0;
  double carb = 0.0;
  double fat = 0.0;
  double kcal = 0.0;

  if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
    prot = detail.product!.proteins * scale;
    carb = detail.product!.carbs * scale;
    fat = detail.product!.fats * scale;
    kcal = (detail.product!.kcal ?? 0.0) * scale;
  } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
    for (final ing in detail.recipe!.ingredients) {
      final ingScale = (ing.ingredient.amount / 100.0) * scale;
      prot += ing.product.proteins * ingScale;
      carb += ing.product.carbs * ingScale;
      fat += ing.product.fats * ingScale;
      kcal += (ing.product.kcal ?? 0.0) * ingScale;
    }
  }

  return ConsumedMacros(
    protein: prot,
    carbs: carb,
    fats: fat,
    calories: kcal,
  );
}

final mealTemplatesProvider = StreamProvider<List<MealPlanWithMealsAndItems>>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getMealPlansWithMealsAndItemsByState(MealPlanState.TEMPLATE);
});

final todayMealPlanProvider = StreamProvider<MealPlanWithMealsAndItems?>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  final dayStartHour = settings.dayStartHour;
  final now = DateTime.now();
  return repo.getMealPlansWithMealsAndItemsByState(MealPlanState.ACTIVE).map((list) {
    return list.firstWhereOrNull(
      (mp) => DayWindowHelper.isWithinDayWindow(
        mp.mealPlan.created,
        now,
        dayStartHour,
        0,
      ),
    );
  });
});

final todayTotalConsumedMacrosProvider = StreamProvider<ConsumedMacros>((ref) {
  final db = ref.watch(dbProvider);
  final repo = ref.watch(mealRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  final dayStartHour = settings.dayStartHour;

  // Watch mealItems so ticking consumed or adding meals/items immediately triggers re-computation
  return db.select(db.mealItems).watch().asyncMap((_) async {
    final activeList = await repo.getMealPlansWithMealsAndItemsByState(MealPlanState.ACTIVE).first;
    final loggedList = await repo.getMealPlansWithMealsAndItemsByState(MealPlanState.LOGGED).first;

    ConsumedMacros total = const ConsumedMacros();
    final now = DateTime.now();

    for (final planWithMeals in activeList) {
      if (DayWindowHelper.isWithinDayWindow(planWithMeals.mealPlan.created, now, dayStartHour, 0)) {
        for (final meal in planWithMeals.meals) {
          for (final item in meal.items) {
            if (item.mealItem.consumed) {
              total += calculateMealItemMacros(item);
            }
          }
        }
      }
    }

    for (final planWithMeals in loggedList) {
      final checkDate = planWithMeals.mealPlan.completed;
      if (DayWindowHelper.isWithinDayWindow(checkDate, now, dayStartHour, 0)) {
        for (final meal in planWithMeals.meals) {
          for (final item in meal.items) {
            if (item.mealItem.consumed) {
              total += calculateMealItemMacros(item);
            }
          }
        }
      }
    }

    return total;
  });
});

final allProductsProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getAllProducts();
});

final allRecipesProvider = StreamProvider<List<RecipeWithIngredients>>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getAllRecipes();
});

final mealPlanStreamProvider = StreamProvider.family<MealPlanWithMealsAndItems?, int>((ref, id) {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.watchMealPlanWithMealsAndItems(id);
});

final productUsageCountsProvider = StreamProvider<Map<int, int>>((ref) {
  final db = ref.watch(dbProvider);
  return db.select(db.mealItems).watch().map((items) {
    final map = <int, int>{};
    for (final item in items) {
      if (item.type == MealItemType.PRODUCT) {
        map[item.targetId] = (map[item.targetId] ?? 0) + 1;
      }
    }
    return map;
  });
});

final inStockProductIdsProvider = StreamProvider<Set<int>>((ref) {
  final db = ref.watch(dbProvider);
  return db.select(db.productStocks).watch().map((stocks) {
    return stocks
        .where((s) => s.quantity > 0.0)
        .map((s) => s.productId)
        .toSet();
  });
});

