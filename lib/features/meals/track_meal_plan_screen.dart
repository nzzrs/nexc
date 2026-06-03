/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/db/app_database.dart';
import '../../core/db/enums.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/components/nexc_scaffold.dart';
import 'meals_dashboard_screen.dart';

class TrackMealPlanScreen extends ConsumerStatefulWidget {
  final int mealPlanId;

  const TrackMealPlanScreen({
    super.key,
    required this.mealPlanId,
  });

  @override
  ConsumerState<TrackMealPlanScreen> createState() => _TrackMealPlanScreenState();
}

class _TrackMealPlanScreenState extends ConsumerState<TrackMealPlanScreen> {
  void _showAddMealItemDialog(BuildContext context, int mealId, List<Product> products, List<RecipeWithIngredients> recipes) {
    showDialog(
      context: context,
      builder: (context) => AddMealItemDialog(
        products: products,
        recipes: recipes,
        onDismiss: () => Navigator.pop(context),
        onConfirm: (type, targetId, amount, amountUnit) {
          ref.read(mealRepositoryProvider).addMealItemToMeal(
                mealId: mealId,
                type: type,
                targetId: targetId,
                amount: amount,
                amountUnit: amountUnit,
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showReplaceDialog(BuildContext context, int itemId, List<Product> products, List<RecipeWithIngredients> recipes) {
    showDialog(
      context: context,
      builder: (context) => AddMealItemDialog(
        products: products,
        recipes: recipes,
        onDismiss: () => Navigator.pop(context),
        onConfirm: (type, targetId, amount, amountUnit) {
          ref.read(mealRepositoryProvider).replaceMealItemInMeal(
                oldItemId: itemId,
                newType: type,
                newTargetId: targetId,
                newAmount: amount,
                newAmountUnit: amountUnit,
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, int itemId, MealPlanWithMealsAndItems plan, List<Product> products, List<RecipeWithIngredients> recipes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Meal Item Options"),
        content: const Text("Select action for this item in today's session."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showReplaceDialog(context, itemId, products, recipes);
            },
            child: const Text("Replace"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final repo = ref.read(mealRepositoryProvider);
              MealItem? targetItem;
              for (final m in plan.meals) {
                for (final d in m.items) {
                  if (d.mealItem.id == itemId) {
                    targetItem = d.mealItem;
                  }
                }
              }
              if (targetItem != null) {
                await repo.deleteMealItem(targetItem);
              }
            },
            child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _showEditGoalsDialog(BuildContext context, MealPlanWithMealsAndItems plan, double defProt, double defCarb, double defFat) {
    final currentProt = plan.mealPlan.targetProtein ?? defProt;
    final currentCarb = plan.mealPlan.targetCarbs ?? defCarb;
    final currentFat = plan.mealPlan.targetFats ?? defFat;

    showDialog(
      context: context,
      builder: (context) => EditTodayGoalsDialog(
        currentProt: currentProt,
        currentCarb: currentCarb,
        currentFat: currentFat,
        onConfirm: (newProt, newCarb, newFat) async {
          final repo = ref.read(mealRepositoryProvider);
          await repo.saveMealPlanWithMealsAndItems(
            MealPlanWithMealsAndItems(
              mealPlan: plan.mealPlan.copyWith(
                targetProtein: Value(newProt),
                targetCarbs: Value(newCarb),
                targetFats: Value(newFat),
              ),
              meals: plan.meals,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planAsync = ref.watch(mealPlanStreamProvider(widget.mealPlanId));
    final productsAsync = ref.watch(allProductsProvider);
    final recipesAsync = ref.watch(allRecipesProvider);

    final products = productsAsync.value ?? [];
    final recipes = recipesAsync.value ?? [];

    return planAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (plan) {
        if (plan == null) {
          return const Scaffold(body: Center(child: Text("Meal plan not found")));
        }

        final meals = plan.meals;

        // Totals calculations
        double totalProtTarget = 0.0;
        double totalCarbTarget = 0.0;
        double totalFatTarget = 0.0;

        double totalProtConsumed = 0.0;
        double totalCarbConsumed = 0.0;
        double totalFatConsumed = 0.0;

        for (final m in meals) {
          for (final detail in m.items) {
            final scale = detail.macroScale;
            double itemProt = 0.0;
            double itemCarb = 0.0;
            double itemFat = 0.0;

            if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
              itemProt = detail.product!.proteins * scale;
              itemCarb = detail.product!.carbs * scale;
              itemFat = detail.product!.fats * scale;
            } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
              for (final ing in detail.recipe!.ingredients) {
                final ingScale = (ing.ingredient.amount / 100.0) * scale;
                itemProt += ing.product.proteins * ingScale;
                itemCarb += ing.product.carbs * ingScale;
                itemFat += ing.product.fats * ingScale;
              }
            }

            totalProtTarget += itemProt;
            totalCarbTarget += itemCarb;
            totalFatTarget += itemFat;

            if (detail.mealItem.consumed) {
              totalProtConsumed += itemProt;
              totalCarbConsumed += itemCarb;
              totalFatConsumed += itemFat;
            }
          }
        }

        final targetProt = plan.mealPlan.targetProtein != null && plan.mealPlan.targetProtein! > 0
            ? plan.mealPlan.targetProtein!
            : totalProtTarget;
        final targetCarb = plan.mealPlan.targetCarbs != null && plan.mealPlan.targetCarbs! > 0
            ? plan.mealPlan.targetCarbs!
            : totalCarbTarget;
        final targetFat = plan.mealPlan.targetFats != null && plan.mealPlan.targetFats! > 0
            ? plan.mealPlan.targetFats!
            : totalFatTarget;

        return NexcScaffold(
          title: Text(
            plan.mealPlan.title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          navigateBack: () => Navigator.pop(context),
          content: (context, padding) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TodayMacrosCard(
                  protConsumed: totalProtConsumed,
                  protTarget: targetProt,
                  carbConsumed: totalCarbConsumed,
                  carbTarget: targetCarb,
                  fatConsumed: totalFatConsumed,
                  fatTarget: targetFat,
                  onEditGoals: () => _showEditGoalsDialog(context, plan, totalProtTarget, totalCarbTarget, totalFatTarget),
                ),
                const SizedBox(height: 12),
                ...meals.map((mealWithItems) {
                  return MealTrackCard(
                    key: ValueKey(mealWithItems.meal.id),
                    mealWithItems: mealWithItems,
                    onItemToggle: (item) {
                      ref.read(mealRepositoryProvider).updateMealItem(
                            item.copyWith(consumed: !item.consumed),
                          );
                    },
                    onTimeClick: (mealId) async {
                      final meal = plan.meals.firstWhere((m) => m.meal.id == mealId).meal;
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: meal.time.hour, minute: meal.time.minute),
                      );
                      if (picked != null) {
                        ref.read(mealRepositoryProvider).updateMealTime(
                              mealId,
                              LocalTime(picked.hour, picked.minute),
                            );
                      }
                    },
                    onNameClick: (itemId) {
                      _showOptionsDialog(context, itemId, plan, products, recipes);
                    },
                    onAddClick: (mealId) {
                      _showAddMealItemDialog(context, mealId, products, recipes);
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}
