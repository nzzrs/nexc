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
import '../../core/db/app_database.dart';
import '../../core/db/enums.dart';
import '../../core/db/meal_repository.dart';
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
        double totalCostTarget = 0.0;

        double totalProtConsumed = 0.0;
        double totalCarbConsumed = 0.0;
        double totalFatConsumed = 0.0;
        double totalCostConsumed = 0.0;

        for (final m in meals) {
          for (final detail in m.items) {
            final scale = detail.mealItem.amount / 100.0;
            double itemProt = 0.0;
            double itemCarb = 0.0;
            double itemFat = 0.0;
            double itemCost = 0.0;

            if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
              itemProt = detail.product!.proteins * scale;
              itemCarb = detail.product!.carbs * scale;
              itemFat = detail.product!.fats * scale;
              final costFactor = detail.product!.weight > 0
                  ? detail.mealItem.amount / detail.product!.weight
                  : 0.0;
              itemCost = detail.product!.cost * costFactor;
            } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
              for (final ing in detail.recipe!.ingredients) {
                final ingScale = (ing.ingredient.amount / 100.0) * scale;
                itemProt += ing.product.proteins * ingScale;
                itemCarb += ing.product.carbs * ingScale;
                itemFat += ing.product.fats * ingScale;
                final costFactor = ing.product.weight > 0
                    ? (ing.ingredient.amount * scale) / ing.product.weight
                    : 0.0;
                itemCost += ing.product.cost * costFactor;
              }
            }

            totalProtTarget += itemProt;
            totalCarbTarget += itemCarb;
            totalFatTarget += itemFat;
            totalCostTarget += itemCost;

            if (detail.mealItem.consumed) {
              totalProtConsumed += itemProt;
              totalCarbConsumed += itemCarb;
              totalFatConsumed += itemFat;
              totalCostConsumed += itemCost;
            }
          }
        }

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
                  protTarget: totalProtTarget,
                  carbConsumed: totalCarbConsumed,
                  carbTarget: totalCarbTarget,
                  fatConsumed: totalFatConsumed,
                  fatTarget: totalFatTarget,
                  costConsumed: totalCostConsumed,
                  costTarget: totalCostTarget,
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
                    onTimeClick: (mealId) {
                      final meal = plan.meals.firstWhere((m) => m.meal.id == mealId).meal;
                      showDialog(
                        context: context,
                        builder: (context) => EditTimeDialog(
                          initialTime: meal.time,
                          onDismiss: () => Navigator.pop(context),
                          onConfirm: (newTime) {
                            ref.read(mealRepositoryProvider).updateMealTime(mealId, newTime);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    onAmountClick: (itemId, initialAmt) {
                      showDialog(
                        context: context,
                        builder: (context) => EditAmountDialog(
                          initialAmount: initialAmt,
                          onDismiss: () => Navigator.pop(context),
                          onConfirm: (newAmt) {
                            ref.read(mealRepositoryProvider).updateMealItemAmount(itemId, newAmt);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    onNameClick: (itemId) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Meal Item Options"),
                          content: const Text("Select action for this item in today's session."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AddMealItemDialog(
                                    products: products,
                                    recipes: recipes,
                                    onDismiss: () => Navigator.pop(context),
                                    onConfirm: (type, targetId, amount) {
                                      ref.read(mealRepositoryProvider).replaceMealItemInMeal(
                                            oldItemId: itemId,
                                            newType: type,
                                            newTargetId: targetId,
                                            newAmount: amount,
                                          );
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
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
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onAddClick: (mealId) {
                      showDialog(
                        context: context,
                        builder: (context) => AddMealItemDialog(
                          products: products,
                          recipes: recipes,
                          onDismiss: () => Navigator.pop(context),
                          onConfirm: (type, targetId, amount) {
                            ref.read(mealRepositoryProvider).addMealItemToMeal(
                                  mealId: mealId,
                                  type: type,
                                  targetId: targetId,
                                  amount: amount,
                                );
                            Navigator.pop(context);
                          },
                        ),
                      );
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
