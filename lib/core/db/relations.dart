/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'app_database.dart';
export 'app_database.dart';
import 'enums.dart';

class ExerciseWithSets {
  final Exercise exercise;
  final ExerciseDataDC exerciseDC;
  final List<WorkoutSet> sets;

  ExerciseWithSets({
    required this.exercise,
    required this.exerciseDC,
    required this.sets,
  });

  ExerciseWithSets copyWith({
    Exercise? exercise,
    ExerciseDataDC? exerciseDC,
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

  MealItemWithDetails copyWith({
    MealItem? mealItem,
    Product? product,
    RecipeWithIngredients? recipe,
  }) {
    return MealItemWithDetails(
      mealItem: mealItem ?? this.mealItem,
      product: product ?? this.product,
      recipe: recipe ?? this.recipe,
    );
  }
}

class MealWithItems {
  final Meal meal;
  final List<MealItemWithDetails> items;

  MealWithItems({
    required this.meal,
    required this.items,
  });

  MealWithItems copyWith({
    Meal? meal,
    List<MealItemWithDetails>? items,
  }) {
    return MealWithItems(
      meal: meal ?? this.meal,
      items: items ?? this.items,
    );
  }
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
  final double unitW;
  if (p.unitWeight != null && p.unitWeight! > 0) {
    unitW = p.unitWeight!.toDouble();
  } else {
    final name = p.name.toLowerCase();
    if (name.contains('banana')) {
      unitW = 120.0;
    } else if (name.contains('egg')) {
      unitW = 57.0;
    } else if (name.contains('apple')) {
      unitW = 182.0;
    } else if (name.contains('orange')) {
      unitW = 150.0;
    } else {
      unitW = 100.0;
    }
  }
  final edibleFraction = p.edibleQtyPerUnit ?? 1.0;
  return unitW * edibleFraction;
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

