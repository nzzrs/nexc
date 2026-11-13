/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import '../db/enums.dart';
import '../db/relations.dart';

/// Canonical macro aggregation used by dashboard, plans, statistics, history
/// and the profile screen.
///
/// Keeping one implementation removes the seven duplicated accumulation loops
/// that used to drift apart between screens.
class MacroTotals {
  final double protein;
  final double carbs;
  final double fats;
  final double calories;

  const MacroTotals({
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.calories = 0,
  });

  static const MacroTotals zero = MacroTotals();

  MacroTotals operator +(MacroTotals other) => MacroTotals(
    protein: protein + other.protein,
    carbs: carbs + other.carbs,
    fats: fats + other.fats,
    calories: calories + other.calories,
  );

  MacroTotals operator *(double factor) => MacroTotals(
    protein: protein * factor,
    carbs: carbs * factor,
    fats: fats * factor,
    calories: calories * factor,
  );

  bool get isEmpty => protein == 0 && carbs == 0 && fats == 0 && calories == 0;

  /// Calories implied by the macro split (4/4/9 kcal per gram).
  double get impliedCalories => protein * 4 + carbs * 4 + fats * 9;

  /// Aggregates one logged item, honouring product and recipe portions.
  static MacroTotals ofItem(MealItemWithDetails item) {
    final double scale = item.macroScale;
    double protein = 0;
    double carbs = 0;
    double fats = 0;
    double calories = 0;

    if (item.mealItem.type == MealItemType.PRODUCT && item.product != null) {
      final Product product = item.product!;
      protein = product.proteins * scale;
      carbs = product.carbs * scale;
      fats = product.fats * scale;
      calories = (product.kcal ?? 0) * scale;
    } else if (item.mealItem.type == MealItemType.RECIPE &&
        item.recipe != null) {
      for (final RecipeIngredientWithProduct ingredient
          in item.recipe!.ingredients) {
        final double ingredientScale =
            (ingredient.ingredient.amount / 100.0) * scale;
        protein += ingredient.product.proteins * ingredientScale;
        carbs += ingredient.product.carbs * ingredientScale;
        fats += ingredient.product.fats * ingredientScale;
        calories += (ingredient.product.kcal ?? 0) * ingredientScale;
      }
    }

    return MacroTotals(
      protein: protein,
      carbs: carbs,
      fats: fats,
      calories: calories,
    );
  }

  /// Aggregates a list of items, optionally only the consumed ones.
  static MacroTotals ofItems(
    Iterable<MealItemWithDetails> items, {
    bool consumedOnly = false,
  }) {
    MacroTotals totals = zero;
    for (final MealItemWithDetails item in items) {
      if (consumedOnly && !item.mealItem.consumed) continue;
      totals += ofItem(item);
    }
    return totals;
  }

  /// Aggregates one meal, optionally only the consumed items.
  static MacroTotals ofMeal(MealWithItems meal, {bool consumedOnly = false}) {
    return ofItems(meal.items, consumedOnly: consumedOnly);
  }

  /// Aggregates a whole plan, optionally only the consumed items.
  static MacroTotals ofPlan(
    MealPlanWithMealsAndItems plan, {
    bool consumedOnly = false,
  }) {
    MacroTotals totals = zero;
    for (final MealWithItems meal in plan.meals) {
      totals += ofMeal(meal, consumedOnly: consumedOnly);
    }
    return totals;
  }

  /// Number of items in a plan, split into consumed and total counts.
  static ({int consumed, int total}) itemCount(MealPlanWithMealsAndItems plan) {
    int consumed = 0;
    int total = 0;
    for (final MealWithItems meal in plan.meals) {
      for (final MealItemWithDetails item in meal.items) {
        total++;
        if (item.mealItem.consumed) consumed++;
      }
    }
    return (consumed: consumed, total: total);
  }
}
