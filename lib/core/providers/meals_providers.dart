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
import '../db/app_database.dart';
import '../db/enums.dart';
import '../db/relations.dart';
import '../db/meal_repository.dart';

final mealTemplatesProvider = StreamProvider<List<MealPlanWithMealsAndItems>>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getMealPlansWithMealsAndItemsByState(MealPlanState.TEMPLATE);
});

final todayMealPlanProvider = StreamProvider<MealPlanWithMealsAndItems?>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  final now = DateTime.now();
  return repo.getMealPlansWithMealsAndItemsByState(MealPlanState.LOGGED).map((list) {
    return list.firstWhereOrNull(
      (mp) =>
          mp.mealPlan.created.year == now.year &&
          mp.mealPlan.created.month == now.month &&
          mp.mealPlan.created.day == now.day,
    );
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

