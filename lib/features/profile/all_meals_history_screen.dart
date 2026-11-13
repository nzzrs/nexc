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
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';

class AllMealsHistoryScreen extends ConsumerWidget {
  const AllMealsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final mealLogsAsync = ref.watch(profileMealLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allMealsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: mealLogsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text(l10n.errorWithMessage('$err'))),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(child: Text(l10n.noMealLogHistory));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final planWithMeals = logs[index];
              final plan = planWithMeals.mealPlan;
              final meals = planWithMeals.meals;

              // Totals calculations
              double totalProt = 0.0;
              double totalCarb = 0.0;
              double totalFat = 0.0;
              int totalItems = 0;
              int consumedCount = 0;

              for (final m in meals) {
                for (final detail in m.items) {
                  totalItems++;
                  if (detail.mealItem.consumed) {
                    consumedCount++;

                    final scale = detail.macroScale;
                    if (detail.mealItem.type == MealItemType.PRODUCT &&
                        detail.product != null) {
                      totalProt += detail.product!.proteins * scale;
                      totalCarb += detail.product!.carbs * scale;
                      totalFat += detail.product!.fats * scale;
                    } else if (detail.mealItem.type == MealItemType.RECIPE &&
                        detail.recipe != null) {
                      for (final ing in detail.recipe!.ingredients) {
                        final ingScale =
                            (ing.ingredient.amount / 100.0) * scale;
                        totalProt += ing.product.proteins * ingScale;
                        totalCarb += ing.product.carbs * ingScale;
                        totalFat += ing.product.fats * ingScale;
                      }
                    }
                  }
                }
              }

              final formatter =
                  "${plan.created.month}/${plan.created.day}/${plan.created.year} ${plan.created.hour.toString().padLeft(2, '0')}:${plan.created.minute.toString().padLeft(2, '0')}";

              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/meals/track-plan',
                              arguments: plan.id,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(l10n.eatenOn(formatter)),
                              Text(
                                l10n.progressItemsEaten(
                                  consumedCount,
                                  totalItems,
                                ),
                              ),
                              Text(
                                l10n.macrosPrefixLine(
                                  totalProt.toStringAsFixed(1),
                                  totalCarb.toStringAsFixed(1),
                                  totalFat.toStringAsFixed(1),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.deleteMealLog),
                              content: Text(l10n.deleteMealLogConfirm),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    l10n.delete,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            ref
                                .read(mealRepositoryProvider)
                                .deleteMealPlan(plan);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
