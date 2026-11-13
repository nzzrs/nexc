/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/util/macro_totals.dart';

Product _product({
  double proteins = 10,
  double carbs = 20,
  double fats = 5,
  double kcal = 165,
  int? unitWeight,
}) {
  return Product(
    id: 1,
    name: 'Test product',
    defaultUnits: 'g',
    edibleQtyPerUnit: 1,
    kcal: kcal,
    proteins: proteins,
    carbsAvailable: carbs,
    fats: fats,
    isSupplement: false,
    isPortable: true,
    isStockRaw: false,
    unitWeight: unitWeight,
  );
}

MealItemWithDetails _item({
  required double amount,
  Product? product,
  RecipeWithIngredients? recipe,
  bool consumed = false,
  AmountUnit unit = AmountUnit.GRAMS,
}) {
  return MealItemWithDetails(
    mealItem: MealItem(
      id: 1,
      mealId: 1,
      type: recipe == null ? MealItemType.PRODUCT : MealItemType.RECIPE,
      amount: amount,
      amountUnit: unit,
      consumed: consumed,
      position: 0,
      targetId: recipe?.recipe.id ?? product?.id ?? 0,
    ),
    product: product,
    recipe: recipe,
  );
}

MealPlanWithMealsAndItems _plan(List<MealItemWithDetails> items) {
  return MealPlanWithMealsAndItems(
    mealPlan: MealPlan(
      id: 1,
      parentPlanId: 0,
      title: 'Plan',
      notes: '',
      state: MealPlanState.ACTIVE,
      created: DateTime(2026, 1, 1),
      completed: DateTime(2026, 1, 1),
      targetProtein: 0,
      targetCarbs: 0,
      targetFats: 0,
      isTemporal: false,
    ),
    meals: [
      MealWithItems(
        meal: Meal(
          id: 1,
          mealPlanId: 1,
          name: 'Meal',
          time: const LocalTime(12, 0),
          notes: '',
          position: 0,
          atHome: true,
        ),
        items: items,
      ),
    ],
  );
}

void main() {
  group('MacroTotals', () {
    test('scales product macros by grams', () {
      final MacroTotals totals = MacroTotals.ofItem(
        _item(amount: 150, product: _product()),
      );

      expect(totals.protein, closeTo(15, 0.001));
      expect(totals.carbs, closeTo(30, 0.001));
      expect(totals.fats, closeTo(7.5, 0.001));
      expect(totals.calories, closeTo(247.5, 0.001));
    });

    test('scales product macros by units', () {
      final MacroTotals totals = MacroTotals.ofItem(
        _item(
          amount: 2,
          unit: AmountUnit.UNITS,
          product: _product(unitWeight: 50),
        ),
      );

      // 2 units * 50 g = 100 g -> factor 1.
      expect(totals.protein, closeTo(10, 0.001));
      expect(totals.carbs, closeTo(20, 0.001));
    });

    test('aggregates a recipe through its ingredients', () {
      final Product ingredient = _product(proteins: 5, carbs: 10, fats: 2);
      final RecipeWithIngredients recipe = RecipeWithIngredients(
        recipe: Recipe(
          id: 1,
          name: 'Recipe',
          instructions: '',
          isPortable: true,
        ),
        ingredients: [
          RecipeIngredientWithProduct(
            ingredient: RecipeIngredient(
              id: 1,
              recipeId: 1,
              productId: ingredient.id,
              amount: 200,
            ),
            product: ingredient,
          ),
        ],
      );

      final MacroTotals totals = MacroTotals.ofItem(
        _item(amount: 100, recipe: recipe),
      );

      expect(totals.protein, closeTo(10, 0.001));
      expect(totals.carbs, closeTo(20, 0.001));
      expect(totals.fats, closeTo(4, 0.001));
    });

    test('consumedOnly filters items and counts progress', () {
      final MealPlanWithMealsAndItems plan = _plan([
        _item(amount: 100, product: _product(), consumed: true),
        _item(amount: 100, product: _product(), consumed: false),
      ]);

      expect(MacroTotals.ofPlan(plan).protein, closeTo(20, 0.001));
      expect(
        MacroTotals.ofPlan(plan, consumedOnly: true).protein,
        closeTo(10, 0.001),
      );

      final count = MacroTotals.itemCount(plan);
      expect(count.consumed, 1);
      expect(count.total, 2);
    });
  });
}
