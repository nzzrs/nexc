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
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/db/app_database.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/db/meal_repository.dart';
import '../../core/providers/meals_providers.dart';

String formatDouble(double val) {
  if (val == val.toInt().toDouble()) {
    return val.toInt().toString();
  }
  return val.toString();
}

String getUnitLabel(MealItem item, Product? product) {
  if (item.amountUnit == AmountUnit.UNITS) {
    return "units";
  }
  if (product != null && product.units.isNotEmpty) {
    return product.units;
  }
  return "g";
}

class MealsDashboardScreen extends ConsumerStatefulWidget {
  const MealsDashboardScreen({super.key});

  @override
  ConsumerState<MealsDashboardScreen> createState() => _MealsDashboardScreenState();
}

class _MealsDashboardScreenState extends ConsumerState<MealsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddMealDialog(BuildContext context, int planId) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Meal"),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Meal Name",
              hintText: "e.g. Breakfast, Snack",
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final now = DateTime.now();
                final localTime = LocalTime(now.hour, now.minute);
                await ref.read(mealRepositoryProvider).addMealToPlan(
                      mealPlanId: planId,
                      name: name,
                      time: localTime,
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

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

  void _showOptionsDialog(BuildContext context, int itemId, List<Product> products, List<RecipeWithIngredients> recipes) {
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
              final plan = ref.read(todayMealPlanProvider).value;
              MealItem? targetItem;
              for (final m in plan?.meals ?? []) {
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
    final templatesAsync = ref.watch(mealTemplatesProvider);
    final todayPlanAsync = ref.watch(todayMealPlanProvider);
    final productsAsync = ref.watch(allProductsProvider);
    final recipesAsync = ref.watch(allRecipesProvider);

    final todayPlan = todayPlanAsync.value;
    final products = productsAsync.value ?? [];
    final recipes = recipesAsync.value ?? [];

    final selectedTab = _tabController.index;

    return Scaffold(
      floatingActionButton: selectedTab == 0
          ? (todayPlan != null
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddMealDialog(context, todayPlan.mealPlan.id),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Meal"),
                )
              : null)
          : FloatingActionButton.extended(
              onPressed: () async {
                final repo = ref.read(mealRepositoryProvider);
                final newPlan = MealPlan(
                  id: 0,
                  parentPlanId: 0,
                  title: "New Meal Plan",
                  notes: "",
                  state: MealPlanState.TEMPLATE,
                  created: DateTime.now(),
                  completed: DateTime.now(),
                );
                final id = await repo.saveMealPlanWithMealsAndItems(
                  MealPlanWithMealsAndItems(mealPlan: newPlan, meals: []),
                );
                if (mounted) {
                  Navigator.pushNamed(context, '/meals/edit-plan', arguments: id);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Create Meal Plan"),
            ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Today's plan"),
              Tab(text: "Meal plans"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Today's Plan
                todayPlanAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                  data: (plan) {
                    if (plan == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Select a meal plan for today",
                              style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () {
                                _tabController.animateTo(1);
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text("Go to Meal Plans"),
                            ),
                          ],
                        ),
                      );
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
                              final meal = mealWithItems.meal;
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: meal.time.hour, minute: meal.time.minute),
                              );
                              if (picked != null) {
                                ref.read(mealRepositoryProvider).updateMealTime(
                                      meal.id,
                                      LocalTime(picked.hour, picked.minute),
                                    );
                              }
                            },
                            onNameClick: (itemId) {
                              _showOptionsDialog(context, itemId, products, recipes);
                            },
                            onAddClick: (mealId) {
                              _showAddMealItemDialog(context, mealId, products, recipes);
                            },
                          );
                        }),
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),

                // Tab 1: Meal Plans
                templatesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                  data: (planList) {
                    if (planList.isEmpty) {
                      return Center(
                        child: Text(
                          "No meal plans yet",
                          style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: planList.length,
                      itemBuilder: (context, index) {
                        final plan = planList[index];
                        final isSelected = todayPlan?.mealPlan.parentPlanId == plan.mealPlan.id;

                        return Padding(
                          key: ValueKey(plan.mealPlan.id),
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: MealPlanCard(
                            planWithMeals: plan,
                            isSelected: isSelected,
                            onClick: () {
                              Navigator.pushNamed(
                                context,
                                '/meals/edit-plan',
                                arguments: plan.mealPlan.id,
                              );
                            },
                            onDelete: () {
                              ref.read(mealRepositoryProvider).deleteMealPlan(plan.mealPlan);
                            },
                            onSelect: () {
                              ref.read(mealRepositoryProvider).selectMealPlanForToday(plan);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TodayMacrosCard extends StatelessWidget {
  final double protConsumed;
  final double protTarget;
  final double carbConsumed;
  final double carbTarget;
  final double fatConsumed;
  final double fatTarget;
  final VoidCallback onEditGoals;

  const TodayMacrosCard({
    super.key,
    required this.protConsumed,
    required this.protTarget,
    required this.carbConsumed,
    required this.carbTarget,
    required this.fatConsumed,
    required this.fatTarget,
    required this.onEditGoals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Macros",
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                  onPressed: onEditGoals,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularMacroIndicator(
                  label: "Protein",
                  consumed: protConsumed,
                  target: protTarget,
                  color: Colors.blue,
                ),
                CircularMacroIndicator(
                  label: "Carbs",
                  consumed: carbConsumed,
                  target: carbTarget,
                  color: Colors.orange,
                ),
                CircularMacroIndicator(
                  label: "Fats",
                  consumed: fatConsumed,
                  target: fatTarget,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircularMacroIndicator extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final Color color;

  const CircularMacroIndicator({
    super.key,
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    Color indicatorColor = color;
    if (target > 0) {
      if (consumed > target * 1.05) {
        indicatorColor = Colors.red;
      } else if (consumed >= target * 0.95) {
        indicatorColor = Colors.green;
      }
    }
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: indicatorColor.withOpacity(0.15),
                color: indicatorColor,
                strokeWidth: 6,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${consumed.toStringAsFixed(0)}g",
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: indicatorColor == color
                            ? theme.colorScheme.onSecondaryContainer
                            : indicatorColor,
                      ),
                ),
                Text(
                  "/${target.toStringAsFixed(0)}g",
                  style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
              ),
        ),
      ],
    );
  }
}

class MealTrackCard extends ConsumerWidget {
  final MealWithItems mealWithItems;
  final void Function(MealItem) onItemToggle;
  final void Function(int)? onTimeClick;
  final void Function(int)? onNameClick;
  final void Function(int)? onAddClick;
  final void Function(int)? onReplaceItem;
  final void Function(int)? onDeleteItem;

  const MealTrackCard({
    super.key,
    required this.mealWithItems,
    required this.onItemToggle,
    this.onTimeClick,
    this.onNameClick,
    this.onAddClick,
    this.onReplaceItem,
    this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final meal = mealWithItems.meal;
    final timeStr =
        '${meal.time.hour.toString().padLeft(2, '0')}:${meal.time.minute.toString().padLeft(2, '0')}';
    final isPortable = mealWithItems.isMealPortable;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: onTimeClick != null ? () => onTimeClick!(meal.id) : null,
                            child: Text(
                              timeStr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              meal.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPortable
                              ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                              : theme.colorScheme.errorContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPortable ? "Portable" : "Home only",
                          style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isPortable
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onErrorContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (meal.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                meal.notes,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            ...mealWithItems.items.map((detail) {
              final name = detail.mealItem.type == MealItemType.PRODUCT
                  ? (detail.product?.name ?? "Unknown Product")
                  : (detail.recipe?.recipe.name ?? "Unknown Recipe");

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: detail.mealItem.consumed,
                      onChanged: (_) => onItemToggle(detail.mealItem),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: onNameClick != null ? () => onNameClick!(detail.mealItem.id) : null,
                                  child: Text(
                                    name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                if (!detail.isItemPortable) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.errorContainer.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "Home only",
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: theme.colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  if (detail.mealItem.amountUnit == AmountUnit.UNITS && detail.product != null)
                                    Text(
                                      "≈ ${(detail.mealItem.amount * getEdibleWeightPerUnit(detail.product!)).toStringAsFixed(0)}g edible",
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InlineAmountEditor(
                                mealItem: detail.mealItem,
                                onConfirm: (newAmount) {
                                  ref.read(mealRepositoryProvider).updateMealItemAmount(detail.mealItem.id, newAmount);
                                },
                              ),
                              const SizedBox(width: 3),
                              PopupMenuButton<AmountUnit>(
                                offset: const Offset(0, 30),
                                onSelected: (newUnit) {
                                  ref.read(mealRepositoryProvider).updateMealItem(
                                        detail.mealItem.copyWith(amountUnit: newUnit),
                                      );
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: AmountUnit.GRAMS,
                                    child: Text(detail.product?.units.isNotEmpty == true ? detail.product!.units : "g"),
                                  ),
                                  PopupMenuItem(
                                    value: AmountUnit.UNITS,
                                    child: const Text("units"),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        getUnitLabel(detail.mealItem, detail.product),
                                        style: theme.textTheme.labelMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: onAddClick != null ? () => onAddClick!(meal.id) : null,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add item to meal"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InlineAmountEditor extends StatefulWidget {
  final MealItem mealItem;
  final void Function(double) onConfirm;

  const InlineAmountEditor({
    super.key,
    required this.mealItem,
    required this.onConfirm,
  });

  @override
  State<InlineAmountEditor> createState() => _InlineAmountEditorState();
}

class _InlineAmountEditorState extends State<InlineAmountEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: formatDouble(widget.mealItem.amount));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _save();
    }
  }

  void _save() {
    final val = double.tryParse(_controller.text);
    if (val != null && val > 0 && val != widget.mealItem.amount) {
      widget.onConfirm(val);
    }
  }

  @override
  void didUpdateWidget(covariant InlineAmountEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mealItem.amount != widget.mealItem.amount && !_focusNode.hasFocus) {
      _controller.text = formatDouble(widget.mealItem.amount);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 60,
      height: 32,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _save(),
      ),
    );
  }
}

class EditTodayGoalsDialog extends StatefulWidget {
  final double currentProt;
  final double currentCarb;
  final double currentFat;
  final void Function(double, double, double) onConfirm;

  const EditTodayGoalsDialog({
    super.key,
    required this.currentProt,
    required this.currentCarb,
    required this.currentFat,
    required this.onConfirm,
  });

  @override
  State<EditTodayGoalsDialog> createState() => _EditTodayGoalsDialogState();
}

class _EditTodayGoalsDialogState extends State<EditTodayGoalsDialog> {
  late TextEditingController _protController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    _protController = TextEditingController(text: formatDouble(widget.currentProt));
    _carbController = TextEditingController(text: formatDouble(widget.currentCarb));
    _fatController = TextEditingController(text: formatDouble(widget.currentFat));
  }

  @override
  void dispose() {
    _protController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Daily Macro Goals"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _protController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Protein (g)"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _carbController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Carbs (g)"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Fats (g)"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final p = double.tryParse(_protController.text) ?? widget.currentProt;
            final c = double.tryParse(_carbController.text) ?? widget.currentCarb;
            final f = double.tryParse(_fatController.text) ?? widget.currentFat;
            widget.onConfirm(p, c, f);
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

class MealPlanCard extends StatelessWidget {
  final MealPlanWithMealsAndItems planWithMeals;
  final bool isSelected;
  final VoidCallback onClick;
  final VoidCallback onDelete;
  final VoidCallback onSelect;

  const MealPlanCard({
    super.key,
    required this.planWithMeals,
    required this.isSelected,
    required this.onClick,
    required this.onDelete,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = planWithMeals.mealPlan;
    final meals = planWithMeals.meals;

    // Totals calculations
    double totalProt = 0.0;
    double totalCarb = 0.0;
    double totalFat = 0.0;

    for (final m in meals) {
      for (final detail in m.items) {
        final scale = detail.macroScale;
        if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
          totalProt += detail.product!.proteins * scale;
          totalCarb += detail.product!.carbs * scale;
          totalFat += detail.product!.fats * scale;
        } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
          for (final ing in detail.recipe!.ingredients) {
            final ingScale = (ing.ingredient.amount / 100.0) * scale;
            totalProt += ing.product.proteins * ingScale;
            totalCarb += ing.product.carbs * ingScale;
            totalFat += ing.product.fats * ingScale;
          }
        }
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected) ...[
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (plan.notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  plan.notes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              if (meals.isNotEmpty) ...[
                Text(
                  "${meals.length} scheduled meals (${meals.map((m) => m.meal.name).join(', ')})",
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
              ],
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildMacroChip(context, "P", totalProt, theme.colorScheme.primaryContainer),
                  _buildMacroChip(context, "C", totalCarb, theme.colorScheme.tertiaryContainer),
                  _buildMacroChip(context, "F", totalFat, theme.colorScheme.errorContainer),
                ],
              ),
              const SizedBox(height: 12),
              if (isSelected)
                InputChip(
                  label: const Text("Active today"),
                  selected: true,
                  onSelected: (_) {},
                  avatar: const Icon(Icons.check, size: 16),
                )
              else
                OutlinedButton.icon(
                  onPressed: onSelect,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text("Select"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroChip(
    BuildContext context,
    String label,
    double val,
    Color color,
  ) {
    final theme = Theme.of(context);
    final valStr = "${val.toStringAsFixed(0)}g";
    return Chip(
      labelPadding: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      backgroundColor: color.withOpacity(0.6),
      label: Text(
        "$label: $valStr",
        style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
      ),
    );
  }
}

class AddMealItemDialog extends StatefulWidget {
  final List<Product> products;
  final List<RecipeWithIngredients> recipes;
  final VoidCallback onDismiss;
  final void Function(MealItemType type, int targetId, double amount, AmountUnit amountUnit) onConfirm;

  const AddMealItemDialog({
    super.key,
    required this.products,
    required this.recipes,
    required this.onDismiss,
    required this.onConfirm,
  });

  @override
  State<AddMealItemDialog> createState() => _AddMealItemDialogState();
}

class _AddMealItemDialogState extends State<AddMealItemDialog> {
  MealItemType _type = MealItemType.PRODUCT;
  String _searchQuery = "";
  int? _selectedProductId;
  int? _selectedRecipeId;
  final TextEditingController _amountController = TextEditingController();
  AmountUnit _amountUnit = AmountUnit.GRAMS;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProducts = _searchQuery.isEmpty
        ? widget.products
        : widget.products
            .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    final filteredRecipes = _searchQuery.isEmpty
        ? widget.recipes
        : widget.recipes
            .where((r) => r.recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    final isItemSelected = _selectedProductId != null || _selectedRecipeId != null;

    return AlertDialog(
      title: const Text("Add Item to Meal"),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ChoiceChip(
                    label: const Text("Product"),
                    selected: _type == MealItemType.PRODUCT,
                    onSelected: (selected) {
                      if (selected) setState(() => _type = MealItemType.PRODUCT);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Recipe"),
                    selected: _type == MealItemType.RECIPE,
                    onSelected: (selected) {
                      if (selected) setState(() => _type = MealItemType.RECIPE);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_type == MealItemType.PRODUCT && _selectedProductId != null) ...[
                Builder(builder: (context) {
                  final prod = widget.products.firstWhereOrNull((p) => p.id == _selectedProductId);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(prod?.name ?? ""),
                      subtitle: Text("${prod?.proteins}g P | ${prod?.carbs}g C | ${prod?.fats}g F"),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _selectedProductId = null),
                      ),
                    ),
                  );
                }),
              ] else if (_type == MealItemType.RECIPE && _selectedRecipeId != null) ...[
                Builder(builder: (context) {
                  final rec = widget.recipes.firstWhereOrNull((r) => r.recipe.id == _selectedRecipeId);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(rec?.recipe.name ?? ""),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _selectedRecipeId = null),
                      ),
                    ),
                  );
                }),
              ] else ...[
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Search food...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _type == MealItemType.PRODUCT ? filteredProducts.length : filteredRecipes.length,
                    itemBuilder: (context, idx) {
                      if (_type == MealItemType.PRODUCT) {
                        final p = filteredProducts[idx];
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text("${p.proteins}g P | ${p.carbs}g C | ${p.fats}g F"),
                          onTap: () => setState(() => _selectedProductId = p.id),
                        );
                      } else {
                        final r = filteredRecipes[idx];
                        return ListTile(
                          title: Text(r.recipe.name),
                          onTap: () => setState(() => _selectedRecipeId = r.recipe.id),
                        );
                      }
                    },
                  ),
                ),
              ],
              if (isItemSelected) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text("Grams"),
                      selected: _amountUnit == AmountUnit.GRAMS,
                      onSelected: (selected) {
                        if (selected) setState(() => _amountUnit = AmountUnit.GRAMS);
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Units"),
                      selected: _amountUnit == AmountUnit.UNITS,
                      onSelected: (selected) {
                        if (selected) setState(() => _amountUnit = AmountUnit.UNITS);
                      },
                    ),
                  ],
                ),
                if (_amountUnit == AmountUnit.UNITS && _type == MealItemType.PRODUCT) ...[
                  const SizedBox(height: 4),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _amountController,
                    builder: (context, value, _) {
                      final prod = widget.products.firstWhereOrNull((p) => p.id == _selectedProductId);
                      if (prod != null) {
                        final val = double.tryParse(value.text) ?? 1.0;
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "≈ ${(val * getEdibleWeightPerUnit(prod)).toStringAsFixed(0)}g edible mass",
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ],
              if (isItemSelected) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Amount"),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onDismiss, child: const Text("Cancel")),
        TextButton(
          onPressed: isItemSelected
              ? () {
                  final targetId = _type == MealItemType.PRODUCT ? _selectedProductId : _selectedRecipeId;
                  final amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (targetId != null && amount > 0.0) {
                    widget.onConfirm(_type, targetId, amount, _amountUnit);
                  }
                }
              : null,
          child: const Text("Add"),
        ),
      ],
    );
  }
}
