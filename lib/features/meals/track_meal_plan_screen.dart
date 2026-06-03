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
import '../../core/db/enums.dart';
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planAsync = ref.watch(mealPlanStreamProvider(widget.mealPlanId));

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
          title: const Text(
            "Meal Plan Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          navigateBack: () => Navigator.pop(context),
          actions: [
            () {
              Navigator.pushNamed(
                context,
                '/meals/edit-plan',
                arguments: plan.mealPlan.id,
              );
            }
          ],
          actionsIcons: const [Icon(Icons.edit)],
          actionsDescription: const ["Edit"],
          content: (context, padding) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.mealPlan.title,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (plan.mealPlan.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            plan.mealPlan.notes,
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStaticMacro("P", targetProt, Colors.blue, theme),
                            _buildStaticMacro("C", targetCarb, Colors.orange, theme),
                            _buildStaticMacro("F", targetFat, Colors.purple, theme),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...meals.map((mealWithItems) {
                  final timeStr = '${mealWithItems.meal.time.hour.toString().padLeft(2, '0')}:${mealWithItems.meal.time.minute.toString().padLeft(2, '0')}';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                timeStr,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                mealWithItems.meal.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          ...mealWithItems.items.map((detail) {
                            final name = detail.mealItem.type == MealItemType.PRODUCT
                                ? (detail.product?.name ?? "Unknown Product")
                                : (detail.recipe?.recipe.name ?? "Unknown Recipe");
                            final unit = getUnitLabel(detail.mealItem, detail.product);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(name, style: theme.textTheme.bodyMedium),
                                  Text(
                                    "${formatDouble(detail.mealItem.amount)} $unit",
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStaticMacro(String label, double val, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          "${val.toStringAsFixed(0)}g",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
