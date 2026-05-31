/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'app_database.dart';
import 'enums.dart';

class ExerciseWithSets {
  final Exercise exercise;
  final ExerciseDC exerciseDC;
  final List<WorkoutSet> sets;

  ExerciseWithSets({
    required this.exercise,
    required this.exerciseDC,
    required this.sets,
  });

  ExerciseWithSets copyWith({
    Exercise? exercise,
    ExerciseDC? exerciseDC,
    List<WorkoutSet>? sets,
  }) {
    return ExerciseWithSets(
      exercise: exercise ?? this.exercise,
      exerciseDC: exerciseDC ?? this.exerciseDC,
      sets: sets ?? this.sets,
    );
  }
}

class WorkoutWithExercisesAndSets {
  final Workout workout;
  final List<ExerciseWithSets> exercisesWithSets;

  WorkoutWithExercisesAndSets({
    required this.workout,
    required this.exercisesWithSets,
  });

  WorkoutWithExercisesAndSets copyWith({
    Workout? workout,
    List<ExerciseWithSets>? exercisesWithSets,
  }) {
    return WorkoutWithExercisesAndSets(
      workout: workout ?? this.workout,
      exercisesWithSets: exercisesWithSets ?? this.exercisesWithSets,
    );
  }
}

class RecipeIngredientWithProduct {
  final RecipeIngredient ingredient;
  final Product product;

  RecipeIngredientWithProduct({
    required this.ingredient,
    required this.product,
  });
}

class RecipeWithIngredients {
  final Recipe recipe;
  final List<RecipeIngredientWithProduct> ingredients;

  RecipeWithIngredients({
    required this.recipe,
    required this.ingredients,
  });
}

class MealItemWithDetails {
  final MealItem mealItem;
  final Product? product;
  final RecipeWithIngredients? recipe;

  MealItemWithDetails({
    required this.mealItem,
    this.product,
    this.recipe,
  });
}

class MealWithItems {
  final Meal meal;
  final List<MealItemWithDetails> items;

  MealWithItems({
    required this.meal,
    required this.items,
  });
}

class MealPlanWithMealsAndItems {
  final MealPlan mealPlan;
  final List<MealWithItems> meals;

  MealPlanWithMealsAndItems({
    required this.mealPlan,
    required this.meals,
  });
}

extension RecipeWithIngredientsExt on RecipeWithIngredients {
  bool get isRecipePortable =>
      recipe.isPortable && ingredients.every((ing) => ing.product.isPortable);
}

double getEdibleWeightPerUnit(Product p) {
  if (p.edibleQtyPerUnit > 0) return p.edibleQtyPerUnit;
  final name = p.name.toLowerCase();
  if (name.contains('banana')) return 118.0;
  if (name.contains('egg')) return 50.0;
  if (name.contains('apple')) return 150.0;
  if (name.contains('orange')) return 130.0;
  return 100.0; // fallback
}

extension MealItemWithDetailsExt on MealItemWithDetails {
  bool get isItemPortable {
    switch (mealItem.type) {
      case MealItemType.PRODUCT:
        return product?.isPortable ?? true;
      case MealItemType.RECIPE:
        return recipe?.isRecipePortable ?? true;
    }
  }

  double get macroScale {
    if (mealItem.type == MealItemType.PRODUCT) {
      final prod = product;
      if (prod != null) {
        if (mealItem.amountUnit == AmountUnit.UNITS) {
          final unitWeight = getEdibleWeightPerUnit(prod);
          return (mealItem.amount * unitWeight) / 100.0;
        }
      }
    }
    return mealItem.amount / 100.0;
  }
}

extension MealWithItemsExt on MealWithItems {
  bool get isMealPortable => items.every((item) => item.isItemPortable);
}

