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
import '../../core/db/relations.dart';
import '../../core/db/meal_repository.dart';
import '../../core/providers/meals_providers.dart';

class MealsDashboardScreen extends ConsumerStatefulWidget {
  const MealsDashboardScreen({super.key});

  @override
  ConsumerState<MealsDashboardScreen> createState() => _MealsDashboardScreenState();
}

class _MealsDashboardScreenState extends ConsumerState<MealsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dialog state variables
  int? _editTimeMealId;
  int? _editAmountItemId;
  double _editAmountInitial = 0.0;
  int? _addMealId;
  int? _optionsItemId;
  int? _replaceItemId;

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
      floatingActionButton: selectedTab == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                final repo = ref.read(mealRepositoryProvider);
                // Create a blank template in the database
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
            )
          : null,
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
                              setState(() {
                                _editTimeMealId = mealId;
                              });
                            },
                            onAmountClick: (itemId, initialAmt) {
                              setState(() {
                                _editAmountItemId = itemId;
                                _editAmountInitial = initialAmt;
                              });
                            },
                            onNameClick: (itemId) {
                              setState(() {
                                _optionsItemId = itemId;
                              });
                            },
                            onAddClick: (mealId) {
                              setState(() {
                                _addMealId = mealId;
                              });
                            },
                          );
                        }),
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
      // Dialogs
      bottomSheet: _buildDialogs(context, todayPlan, products, recipes),
    );
  }

  Widget? _buildDialogs(
    BuildContext context,
    MealPlanWithMealsAndItems? todayPlan,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) {
    if (_editTimeMealId != null) {
      final meal = todayPlan?.meals.firstWhere((m) => m.meal.id == _editTimeMealId).meal;
      if (meal != null) {
        return EditTimeDialog(
          initialTime: meal.time,
          onDismiss: () => setState(() => _editTimeMealId = null),
          onConfirm: (newTime) {
            ref.read(mealRepositoryProvider).updateMealTime(_editTimeMealId!, newTime);
            setState(() => _editTimeMealId = null);
          },
        );
      }
    }

    if (_editAmountItemId != null) {
      return EditAmountDialog(
        initialAmount: _editAmountInitial,
        onDismiss: () => setState(() => _editAmountItemId = null),
        onConfirm: (newAmt) {
          ref.read(mealRepositoryProvider).updateMealItemAmount(_editAmountItemId!, newAmt);
          setState(() => _editAmountItemId = null);
        },
      );
    }

    if (_optionsItemId != null) {
      return AlertDialog(
        title: const Text("Meal Item Options"),
        content: const Text("Select action for this item in today's session."),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _replaceItemId = _optionsItemId;
                _optionsItemId = null;
              });
            },
            child: const Text("Replace"),
          ),
          TextButton(
            onPressed: () async {
              final itemId = _optionsItemId!;
              setState(() => _optionsItemId = null);
              final repo = ref.read(mealRepositoryProvider);
              // Find and delete
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
        ],
      );
    }

    if (_replaceItemId != null) {
      return AddMealItemDialog(
        products: products,
        recipes: recipes,
        onDismiss: () => setState(() => _replaceItemId = null),
        onConfirm: (type, targetId, amount) {
          ref.read(mealRepositoryProvider).replaceMealItemInMeal(
                oldItemId: _replaceItemId!,
                newType: type,
                newTargetId: targetId,
                newAmount: amount,
              );
          setState(() => _replaceItemId = null);
        },
      );
    }

    if (_addMealId != null) {
      return AddMealItemDialog(
        products: products,
        recipes: recipes,
        onDismiss: () => setState(() => _addMealId = null),
        onConfirm: (type, targetId, amount) {
          ref.read(mealRepositoryProvider).addMealItemToMeal(
                mealId: _addMealId!,
                type: type,
                targetId: targetId,
                amount: amount,
              );
          setState(() => _addMealId = null);
        },
      );
    }

    return null;
  }
}

class TodayMacrosCard extends StatelessWidget {
  final double protConsumed;
  final double protTarget;
  final double carbConsumed;
  final double carbTarget;
  final double fatConsumed;
  final double fatTarget;
  final double costConsumed;
  final double costTarget;

  const TodayMacrosCard({
    super.key,
    required this.protConsumed,
    required this.protTarget,
    required this.carbConsumed,
    required this.carbTarget,
    required this.fatConsumed,
    required this.fatTarget,
    required this.costConsumed,
    required this.costTarget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final costExceeded = costConsumed > costTarget && costTarget > 0;

    return Card(
      color: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Macros",
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularMacroIndicator(
                  label: "Protein",
                  consumed: protConsumed,
                  target: protTarget,
                  color: theme.colorScheme.primary,
                ),
                CircularMacroIndicator(
                  label: "Carbs",
                  consumed: carbConsumed,
                  target: carbTarget,
                  color: theme.colorScheme.tertiary,
                ),
                CircularMacroIndicator(
                  label: "Fats",
                  consumed: fatConsumed,
                  target: fatTarget,
                  color: theme.colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cost Progress",
                  style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                ),
                Chip(
                  backgroundColor: costExceeded
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  label: Text(
                    "\$${costConsumed.toStringAsFixed(2)} / \$${costTarget.toStringAsFixed(2)}",
                    style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: costExceeded
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            )
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
    final isExceeded = consumed > target;
    final theme = Theme.of(context);
    final indicatorColor = isExceeded ? theme.colorScheme.error : color;

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
                        color: isExceeded
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSecondaryContainer,
                      ),
                ),
                if (isExceeded)
                  Text(
                    "+${(consumed - target).toStringAsFixed(0)}g",
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                  )
                else
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

class MealTrackCard extends StatelessWidget {
  final MealWithItems mealWithItems;
  final void Function(MealItem) onItemToggle;
  final void Function(int)? onTimeClick;
  final void Function(int, double)? onAmountClick;
  final void Function(int)? onNameClick;
  final void Function(int)? onAddClick;

  const MealTrackCard({
    super.key,
    required this.mealWithItems,
    required this.onItemToggle,
    this.onTimeClick,
    this.onAmountClick,
    this.onNameClick,
    this.onAddClick,
  });

  @override
  Widget build(BuildContext context) {
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
              children: [
                Row(
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
                    Text(
                      meal.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (onAddClick != null) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        onPressed: () => onAddClick!(meal.id),
                        color: theme.colorScheme.primary,
                      ),
                    ]
                  ],
                ),
                Text(
                  isPortable ? "🎒 Portable" : "🏠 Home only",
                  style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isPortable ? theme.colorScheme.primary : theme.colorScheme.error,
                      ),
                ),
              ],
            ),
            if (meal.notes.isNotEmpty) ...[
              const SizedBox(height: 2),
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
                  children: [
                    Checkbox(
                      value: detail.mealItem.consumed,
                      onChanged: (_) => onItemToggle(detail.mealItem),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                                const SizedBox(width: 6),
                                const Text("🏠", style: TextStyle(fontSize: 12)),
                              ]
                            ],
                          ),
                          ChoiceChip(
                            selected: false,
                            onSelected: onAmountClick != null
                                ? (_) => onAmountClick!(detail.mealItem.id, detail.mealItem.amount)
                                : null,
                            label: Text(
                              "${detail.mealItem.amount.toStringAsFixed(0)}g",
                              style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
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
    double totalCost = 0.0;

    for (final m in meals) {
      for (final detail in m.items) {
        final scale = detail.mealItem.amount / 100.0;
        if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
          totalProt += detail.product!.proteins * scale;
          totalCarb += detail.product!.carbs * scale;
          totalFat += detail.product!.fats * scale;
          final costFactor = detail.product!.weight > 0
              ? detail.mealItem.amount / detail.product!.weight
              : 0.0;
          totalCost += detail.product!.cost * costFactor;
        } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
          for (final ing in detail.recipe!.ingredients) {
            final ingScale = (ing.ingredient.amount / 100.0) * scale;
            totalProt += ing.product.proteins * ingScale;
            totalCarb += ing.product.carbs * ingScale;
            totalFat += ing.product.fats * ingScale;
            final costFactor = ing.product.weight > 0
                ? (ing.ingredient.amount * scale) / ing.product.weight
                : 0.0;
            totalCost += ing.product.cost * costFactor;
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
                  _buildMacroChip(context, "\$", totalCost, theme.colorScheme.secondaryContainer, isCost: true),
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
    Color color, {
    bool isCost = false,
  }) {
    final theme = Theme.of(context);
    final valStr = isCost ? "\$${val.toStringAsFixed(2)}" : "${val.toStringAsFixed(0)}g";
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

class EditTimeDialog extends StatefulWidget {
  final LocalTime initialTime;
  final VoidCallback onDismiss;
  final void Function(LocalTime) onConfirm;

  const EditTimeDialog({
    super.key,
    required this.initialTime,
    required this.onDismiss,
    required this.onConfirm,
  });

  @override
  State<EditTimeDialog> createState() => _EditTimeDialogState();
}

class _EditTimeDialogState extends State<EditTimeDialog> {
  late TextEditingController _hourController;
  late TextEditingController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController =
        TextEditingController(text: widget.initialTime.hour.toString().padLeft(2, '0'));
    _minuteController =
        TextEditingController(text: widget.initialTime.minute.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Meal Time"),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _hourController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Hour"),
            ),
          ),
          const SizedBox(width: 8),
          const Text(":", style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _minuteController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Minute"),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onDismiss, child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            final h = int.tryParse(_hourController.text) ?? widget.initialTime.hour;
            final m = int.tryParse(_minuteController.text) ?? widget.initialTime.minute;
            widget.onConfirm(LocalTime(h.clamp(0, 23), m.clamp(0, 59)));
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

class EditAmountDialog extends StatefulWidget {
  final double initialAmount;
  final VoidCallback onDismiss;
  final void Function(double) onConfirm;

  const EditAmountDialog({
    super.key,
    required this.initialAmount,
    required this.onDismiss,
    required this.onConfirm,
  });

  @override
  State<EditAmountDialog> createState() => _EditAmountDialogState();
}

class _EditAmountDialogState extends State<EditAmountDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Quantity"),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: "Amount (grams / units)"),
      ),
      actions: [
        TextButton(onPressed: widget.onDismiss, child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            final val = double.tryParse(_controller.text) ?? widget.initialAmount;
            widget.onConfirm(val);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

class AddMealItemDialog extends StatefulWidget {
  final List<Product> products;
  final List<RecipeWithIngredients> recipes;
  final VoidCallback onDismiss;
  final void Function(MealItemType type, int targetId, double amount) onConfirm;

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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    return AlertDialog(
      title: const Text("Add Item to Meal"),
      content: SingleChildScrollView(
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
            TextField(
              decoration: const InputDecoration(labelText: "Search"),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Select"),
              value: _type == MealItemType.PRODUCT ? _selectedProductId : _selectedRecipeId,
              items: _type == MealItemType.PRODUCT
                  ? filteredProducts
                      .map((p) => DropdownMenuItem<int>(value: p.id, child: Text(p.name)))
                      .toList()
                  : filteredRecipes
                      .map((r) =>
                          DropdownMenuItem<int>(value: r.recipe.id, child: Text(r.recipe.name)))
                      .toList(),
              onChanged: (val) {
                setState(() {
                  if (_type == MealItemType.PRODUCT) {
                    _selectedProductId = val;
                  } else {
                    _selectedRecipeId = val;
                  }
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Amount (grams / units)"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onDismiss, child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            final targetId = _type == MealItemType.PRODUCT ? _selectedProductId : _selectedRecipeId;
            final amount = double.tryParse(_amountController.text) ?? 0.0;
            if (targetId != null && amount > 0.0) {
              widget.onConfirm(_type, targetId, amount);
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
