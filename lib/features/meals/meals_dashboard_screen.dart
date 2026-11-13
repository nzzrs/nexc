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
import '../../core/db/meal_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/providers/settings_provider.dart';
import 'add_meal_item_screen.dart';
import '../../core/util/day_window_helper.dart';

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
  if (item.amountUnit == AmountUnit.ML) {
    return "ml";
  }
  if (product != null && product.units.isNotEmpty) {
    return product.units;
  }
  return "g";
}

class MealsDashboardScreen extends ConsumerStatefulWidget {
  const MealsDashboardScreen({super.key});

  @override
  ConsumerState<MealsDashboardScreen> createState() =>
      _MealsDashboardScreenState();
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

  void _showAddMealItemDialog(
    BuildContext context,
    int mealId,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealItemScreen(
          mealId: mealId,
          products: products,
          recipes: recipes,
        ),
      ),
    );
  }

  void _showReplaceDialog(
    BuildContext context,
    int itemId,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealItemScreen(
          mealId: 0,
          isReplace: true,
          replaceItemId: itemId,
          products: products,
          recipes: recipes,
        ),
      ),
    );
  }

  void _showOptionsDialog(
    BuildContext context,
    int itemId,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) {
    final theme = Theme.of(context);
    final plan = ref.read(todayMealPlanProvider).value;
    MealItemWithDetails? targetDetail;
    for (final m in plan?.meals ?? []) {
      for (final d in m.items) {
        if (d.mealItem.id == itemId) {
          targetDetail = d;
          break;
        }
      }
    }
    final itemName = targetDetail?.displayName ?? context.l10n.mealItemFallback;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(itemName),
        content: Text(context.l10n.chooseActionForItem),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    if (targetDetail != null) {
                      await ref
                          .read(mealRepositoryProvider)
                          .deleteMealItem(targetDetail.mealItem);
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(context.l10n.delete),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showReplaceDialog(context, itemId, products, recipes);
                  },
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: Text(context.l10n.replaceAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditGoalsDialog(
    BuildContext context,
    double currentProt,
    double currentCarb,
    double currentFat,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditTodayGoalsDialog(
        currentProt: currentProt,
        currentCarb: currentCarb,
        currentFat: currentFat,
        onConfirm: (newProt, newCarb, newFat) async {
          await ref
              .read(settingsProvider.notifier)
              .setTargetMacros(newProt, newCarb, newFat);
        },
      ),
    );
  }

  void _handleAddSnack(
    BuildContext context,
    MealPlanWithMealsAndItems plan,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) async {
    final now = DateTime.now();
    final repo = ref.read(mealRepositoryProvider);

    // Find existing meal named exactly "Snack" in the plan
    final snackMeals = plan.meals.where((m) => m.meal.name == "Snack").toList();
    Meal? targetSnackMeal;

    if (snackMeals.isNotEmpty) {
      // Sort to get the latest by time or position
      snackMeals.sort((a, b) => a.meal.position.compareTo(b.meal.position));
      final latestSnack = snackMeals.last.meal;

      // Compare times
      final snackTime = latestSnack.time;

      // Calculate minutes difference
      final diffMinutes =
          (now.hour * 60 + now.minute) -
          (snackTime.hour * 60 + snackTime.minute);
      if (diffMinutes.abs() <= 30) {
        targetSnackMeal = latestSnack;
      }
    }

    int mealId;
    if (targetSnackMeal != null) {
      mealId = targetSnackMeal.id;
    } else {
      // Create new Snack meal
      final nowLocal = LocalTime(now.hour, now.minute);
      mealId = await repo.addMealToPlan(
        mealPlanId: plan.mealPlan.id,
        name: "Snack",
        time: nowLocal,
      );
    }

    if (context.mounted) {
      _showAddMealItemDialog(context, mealId, products, recipes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final templatesAsync = ref.watch(mealTemplatesProvider);
    final todayPlanAsync = ref.watch(todayMealPlanProvider);
    final productsAsync = ref.watch(allProductsProvider);
    final recipesAsync = ref.watch(allRecipesProvider);
    final settings = ref.watch(settingsProvider);

    final todayPlan = todayPlanAsync.value;
    if (todayPlanAsync.hasValue && todayPlan == null) {
      Future.microtask(() {
        ref.read(mealRepositoryProvider).startEmptyTracking();
      });
    }
    final products = productsAsync.value ?? [];
    final recipes = recipesAsync.value ?? [];

    final selectedTab = _tabController.index;

    return Scaffold(
      floatingActionButton: selectedTab == 1
          ? FloatingActionButton.extended(
              heroTag: 'create_meal_plan_fab',
              onPressed: () {
                Navigator.pushNamed(context, '/meals/edit-plan', arguments: 0);
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.createMealPlan),
            )
          : (selectedTab == 0 && todayPlan != null)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'add_meal_fab',
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  onPressed: () async {
                    final now = DateTime.now();
                    final repo = ref.read(mealRepositoryProvider);
                    final meals = todayPlan.meals;
                    await repo.addMealToPlan(
                      mealPlanId: todayPlan.mealPlan.id,
                      name: "Meal ${meals.length + 1}",
                      time: LocalTime(now.hour, now.minute),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    l10n.addMeal,
                    style: const TextStyle(fontSize: 13),
                  ),
                  extendedPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'add_snack_fab',
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  onPressed: () =>
                      _handleAddSnack(context, todayPlan, products, recipes),
                  icon: const Icon(Icons.apple, size: 28),
                  label: Text(
                    l10n.addSnack,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  extendedPadding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.todayPlanTab),
              Tab(text: l10n.mealPlansTab),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Today's Plan
                todayPlanAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text(l10n.errorWithMessage('$err'))),
                  data: (plan) {
                    if (plan == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.selectMealPlanForToday,
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
                              label: Text(l10n.goToMealPlans),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(mealRepositoryProvider)
                                    .startEmptyTracking();
                              },
                              icon: const Icon(Icons.edit_note),
                              label: Text(l10n.startLogging),
                            ),
                          ],
                        ),
                      );
                    }

                    final meals = plan.meals;

                    // Totals calculations
                    double totalProtConsumed = 0.0;
                    double totalCarbConsumed = 0.0;
                    double totalFatConsumed = 0.0;

                    for (final m in meals) {
                      for (final detail in m.items) {
                        final scale = detail.macroScale;
                        double itemProt = 0.0;
                        double itemCarb = 0.0;
                        double itemFat = 0.0;

                        if (detail.mealItem.type == MealItemType.PRODUCT &&
                            detail.product != null) {
                          itemProt = detail.product!.proteins * scale;
                          itemCarb = detail.product!.carbs * scale;
                          itemFat = detail.product!.fats * scale;
                        } else if (detail.mealItem.type ==
                                MealItemType.RECIPE &&
                            detail.recipe != null) {
                          for (final ing in detail.recipe!.ingredients) {
                            final ingScale =
                                (ing.ingredient.amount / 100.0) * scale;
                            itemProt += ing.product.proteins * ingScale;
                            itemCarb += ing.product.carbs * ingScale;
                            itemFat += ing.product.fats * ingScale;
                          }
                        }

                        if (detail.mealItem.consumed) {
                          totalProtConsumed += itemProt;
                          totalCarbConsumed += itemCarb;
                          totalFatConsumed += itemFat;
                        }
                      }
                    }

                    final targetProt = settings.targetProtein;
                    final targetCarb = settings.targetCarbs;
                    final targetFat = settings.targetFats;

                    final sortedMeals = List<MealWithItems>.from(plan.meals)
                      ..sort((a, b) {
                        final aMin = DayWindowHelper.getMinutesFromDayStart(
                          a.meal.time,
                          settings.dayStartHour,
                          0,
                        );
                        final bMin = DayWindowHelper.getMinutesFromDayStart(
                          b.meal.time,
                          settings.dayStartHour,
                          0,
                        );
                        return aMin.compareTo(bMin);
                      });

                    final consumedMacrosAsync = ref.watch(
                      todayTotalConsumedMacrosProvider,
                    );
                    final consumed =
                        consumedMacrosAsync.value ??
                        ConsumedMacros(
                          protein: totalProtConsumed,
                          carbs: totalCarbConsumed,
                          fats: totalFatConsumed,
                        );

                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        TodayMacrosCard(
                          protConsumed: consumed.protein,
                          protTarget: targetProt,
                          carbConsumed: consumed.carbs,
                          carbTarget: targetCarb,
                          fatConsumed: consumed.fats,
                          fatTarget: targetFat,
                          onEditGoals: () => _showEditGoalsDialog(
                            context,
                            targetProt,
                            targetCarb,
                            targetFat,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...sortedMeals.map((mealWithItems) {
                          return MealTrackCard(
                            key: ValueKey(mealWithItems.meal.id),
                            mealWithItems: mealWithItems,
                            onItemToggle: (item) {
                              ref
                                  .read(mealRepositoryProvider)
                                  .updateMealItem(
                                    item.copyWith(consumed: !item.consumed),
                                  );
                            },
                            onTimeClick: (mealId) async {
                              final meal = mealWithItems.meal;
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: meal.time.hour,
                                  minute: meal.time.minute,
                                ),
                              );
                              if (picked != null) {
                                ref
                                    .read(mealRepositoryProvider)
                                    .updateMealTime(
                                      meal.id,
                                      LocalTime(picked.hour, picked.minute),
                                    );
                              }
                            },
                            onNameClick: (itemId) {
                              _showOptionsDialog(
                                context,
                                itemId,
                                products,
                                recipes,
                              );
                            },
                            onAddClick: (mealId) {
                              _showAddMealItemDialog(
                                context,
                                mealId,
                                products,
                                recipes,
                              );
                            },
                          );
                        }),
                        if (sortedMeals.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton.outlined(
                                  style: IconButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                    side: BorderSide(
                                      color: theme.colorScheme.error,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(l10n.discardTodayMeals),
                                        content: Text(
                                          l10n.discardTodayMealsMessage,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(l10n.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(
                                              l10n.discard,
                                              style: TextStyle(
                                                color: theme.colorScheme.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref
                                          .read(mealRepositoryProvider)
                                          .deleteMealPlan(plan.mealPlan);
                                      await ref
                                          .read(settingsProvider.notifier)
                                          .restorePrePlanTargetMacros();
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                                const SizedBox(width: 16),
                                IconButton.filled(
                                  style: IconButton.styleFrom(
                                    padding: const EdgeInsets.all(12),
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(l10n.saveTodayMeals),
                                        content: Text(
                                          l10n.saveTodayMealsMessage,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(l10n.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(l10n.save),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref
                                          .read(mealRepositoryProvider)
                                          .saveTodayMeals(plan);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.todayMealsLogged,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.check),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),

                // Tab 1: Meal Plans
                templatesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text(l10n.errorWithMessage('$err'))),
                  data: (planList) {
                    if (planList.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.noMealPlansYet,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 16.0,
                        bottom: 80.0,
                      ),
                      itemCount: planList.length,
                      itemBuilder: (context, index) {
                        final plan = planList[index];
                        final isSelected =
                            todayPlan?.mealPlan.parentPlanId ==
                            plan.mealPlan.id;

                        return Padding(
                          key: ValueKey(plan.mealPlan.id),
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: MealPlanCard(
                            planWithMeals: plan,
                            isSelected: isSelected,
                            onClick: () {
                              Navigator.pushNamed(
                                context,
                                '/meals/track-plan',
                                arguments: plan.mealPlan.id,
                              );
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(l10n.deleteMealPlan),
                                  content: Text(
                                    l10n.deleteMealPlanConfirm(
                                      plan.mealPlan.title,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
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
                                    .deleteMealPlan(plan.mealPlan);
                              }
                            },
                            onSelect: () async {
                              bool proceed = true;
                              if (todayPlan != null &&
                                  todayPlan.meals.any(
                                    (m) => m.items.isNotEmpty,
                                  )) {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(l10n.changeMealPlan),
                                    content: Text(l10n.changeMealPlanMessage),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(l10n.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          l10n.proceed,
                                          style: TextStyle(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                proceed = (confirm == true);
                              }
                              if (proceed) {
                                await ref
                                    .read(mealRepositoryProvider)
                                    .selectMealPlanForToday(plan);
                                final targetP =
                                    plan.mealPlan.targetProtein ?? 0.0;
                                final targetC =
                                    plan.mealPlan.targetCarbs ?? 0.0;
                                final targetF = plan.mealPlan.targetFats ?? 0.0;
                                final isZeroOrNull =
                                    (targetP <= 0.0 &&
                                    targetC <= 0.0 &&
                                    targetF <= 0.0);
                                final shouldOverride =
                                    !settings.defaultMacrosOverrideMealPlan &&
                                    !isZeroOrNull;
                                if (shouldOverride) {
                                  await ref
                                      .read(settingsProvider.notifier)
                                      .overwriteTargetMacrosWithPlan(
                                        targetP,
                                        targetC,
                                        targetF,
                                      );
                                }
                              }
                            },
                            onDeselect: () async {
                              if (todayPlan != null) {
                                await ref
                                    .read(mealRepositoryProvider)
                                    .deleteMealPlan(todayPlan.mealPlan);
                                await ref
                                    .read(settingsProvider.notifier)
                                    .restorePrePlanTargetMacros();
                              }
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
    final l10n = context.l10n;

    return Card(
      color: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.todaysMacros,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: theme.colorScheme.onSecondaryContainer.withValues(
                    alpha: 0.7,
                  ),
                  onPressed: onEditGoals,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularMacroIndicator(
                  label: l10n.proteinLabel,
                  consumed: protConsumed,
                  target: protTarget,
                  color: Colors.blue,
                ),
                CircularMacroIndicator(
                  label: l10n.carbsLabel,
                  consumed: carbConsumed,
                  target: carbTarget,
                  color: Colors.orange,
                ),
                CircularMacroIndicator(
                  label: l10n.fatsLabel,
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

class CircularMacroIndicator extends StatefulWidget {
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
  State<CircularMacroIndicator> createState() => _CircularMacroIndicatorState();
}

class _CircularMacroIndicatorState extends State<CircularMacroIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    final progress = widget.target > 0
        ? (widget.consumed / widget.target).clamp(0.0, 1.0)
        : 0.0;
    _progressAnim = Tween<double>(
      begin: 0.0,
      end: progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _countAnim = Tween<double>(
      begin: 0.0,
      end: widget.consumed,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(covariant CircularMacroIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumed != widget.consumed ||
        oldWidget.target != widget.target) {
      final oldProgress = _progressAnim.value;
      final oldCount = _countAnim.value;
      final newProgress = widget.target > 0
          ? (widget.consumed / widget.target).clamp(0.0, 1.0)
          : 0.0;
      _progressAnim = Tween<double>(begin: oldProgress, end: newProgress)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _countAnim = Tween<double>(begin: oldCount, end: widget.consumed).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color indicatorColor = widget.color;
    if (widget.target > 0) {
      if (widget.consumed > widget.target * 1.05) {
        indicatorColor = Colors.red;
      } else if (widget.consumed >= widget.target * 0.95) {
        indicatorColor = Colors.green;
      }
    }
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
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
                    value: _progressAnim.value,
                    backgroundColor: indicatorColor.withValues(alpha: 0.15),
                    color: indicatorColor,
                    strokeWidth: 6,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _countAnim.value.toStringAsFixed(0),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: indicatorColor == widget.color
                            ? theme.colorScheme.onSecondaryContainer
                            : indicatorColor,
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 24,
                      color: theme.colorScheme.onSecondaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                    Text(
                      widget.target.toStringAsFixed(0),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        );
      },
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
    final l10n = context.l10n;
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: onTimeClick != null
                                ? () => onTimeClick!(meal.id)
                                : null,
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
                            child: _InlineMealNameEditor(
                              meal: meal,
                              onConfirm: (newName) {
                                ref
                                    .read(mealRepositoryProvider)
                                    .updateMeal(meal.copyWith(name: newName));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isPortable
                                  ? theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.5)
                                  : theme.colorScheme.errorContainer.withValues(
                                      alpha: 0.5,
                                    ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPortable ? l10n.portable : l10n.homeOnly,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isPortable
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              ref
                                  .read(mealRepositoryProvider)
                                  .updateMeal(
                                    meal.copyWith(atHome: !meal.atHome),
                                  );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: meal.atHome
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : theme.colorScheme.secondaryContainer
                                          .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: meal.atHome
                                      ? Colors.green.withValues(alpha: 0.5)
                                      : theme.colorScheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    meal.atHome
                                        ? Icons.home
                                        : Icons.restaurant_menu,
                                    size: 12,
                                    color: meal.atHome
                                        ? Colors.green[800]
                                        : theme
                                              .colorScheme
                                              .onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    meal.atHome ? l10n.atHome : l10n.outside,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: meal.atHome
                                          ? Colors.green[800]
                                          : theme
                                                .colorScheme
                                                .onSecondaryContainer,
                                    ),
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
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: theme.colorScheme.error,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.deleteMeal),
                        content: Text(l10n.deleteMealConfirm(meal.name)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              l10n.delete,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref
                          .read(mealRepositoryProvider)
                          .db
                          .delete(ref.read(mealRepositoryProvider).db.meals)
                          .delete(meal);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            _InlineMealNotesEditor(
              meal: meal,
              onConfirm: (newNotes) {
                ref
                    .read(mealRepositoryProvider)
                    .updateMeal(meal.copyWith(notes: newNotes));
              },
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            ...mealWithItems.items.map((detail) {
              final name = detail.mealItem.type == MealItemType.PRODUCT
                  ? (detail.product?.name ?? l10n.unknownProduct)
                  : (detail.recipe?.recipe.name ?? l10n.unknownRecipe);

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
                                  onTap: onNameClick != null
                                      ? () => onNameClick!(detail.mealItem.id)
                                      : null,
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.errorContainer
                                          .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      l10n.homeOnly,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color:
                                            theme.colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  if (detail.mealItem.amountUnit ==
                                          AmountUnit.UNITS &&
                                      detail.product != null)
                                    Text(
                                      l10n.edibleEquivalent(
                                        (detail.mealItem.amount *
                                                getEdibleWeightPerUnit(
                                                  detail.product!,
                                                ))
                                            .toStringAsFixed(0),
                                      ),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
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
                                  ref
                                      .read(mealRepositoryProvider)
                                      .updateMealItemAmount(
                                        detail.mealItem.id,
                                        newAmount,
                                      );
                                },
                              ),
                              const SizedBox(width: 3),
                              PopupMenuButton<AmountUnit>(
                                offset: const Offset(0, 30),
                                onSelected: (newUnit) {
                                  ref
                                      .read(mealRepositoryProvider)
                                      .updateMealItem(
                                        detail.mealItem.copyWith(
                                          amountUnit: newUnit,
                                        ),
                                      );
                                },
                                itemBuilder: (context) {
                                  final list = <PopupMenuEntry<AmountUnit>>[
                                    PopupMenuItem(
                                      value: AmountUnit.GRAMS,
                                      child: Text(
                                        detail.product?.units.isNotEmpty == true
                                            ? detail.product!.units
                                            : "g",
                                      ),
                                    ),
                                  ];
                                  if (detail.mealItem.type ==
                                      MealItemType.PRODUCT) {
                                    final prod = detail.product;
                                    if (prod != null) {
                                      if (prod.canMeasureInMl) {
                                        list.add(
                                          const PopupMenuItem(
                                            value: AmountUnit.ML,
                                            child: Text("ml"),
                                          ),
                                        );
                                      }
                                      if (prod.canMeasureInUnits) {
                                        list.add(
                                          const PopupMenuItem(
                                            value: AmountUnit.UNITS,
                                            child: Text("units"),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    list.add(
                                      const PopupMenuItem(
                                        value: AmountUnit.UNITS,
                                        child: Text("units"),
                                      ),
                                    );
                                  }
                                  return list;
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        getUnitLabel(
                                          detail.mealItem,
                                          detail.product,
                                        ),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
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
                onPressed: onAddClick != null
                    ? () => onAddClick!(meal.id)
                    : null,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addItemToMealLower),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMealNameEditor extends StatefulWidget {
  final Meal meal;
  final void Function(String) onConfirm;

  const _InlineMealNameEditor({required this.meal, required this.onConfirm});

  @override
  State<_InlineMealNameEditor> createState() => _InlineMealNameEditorState();
}

class _InlineMealNameEditorState extends State<_InlineMealNameEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.meal.name);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _save();
    }
  }

  void _save() {
    final val = _controller.text.trim();
    if (val.isNotEmpty && val != widget.meal.name) {
      widget.onConfirm(val);
    }
  }

  @override
  void didUpdateWidget(covariant _InlineMealNameEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.meal.name != widget.meal.name && !_focusNode.hasFocus) {
      _controller.text = widget.meal.name;
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
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        border: InputBorder.none,
      ),
      onFieldSubmitted: (_) => _save(),
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
    _controller = TextEditingController(
      text: formatDouble(widget.mealItem.amount),
    );
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
    if (oldWidget.mealItem.amount != widget.mealItem.amount &&
        !_focusNode.hasFocus) {
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
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
    _protController = TextEditingController(
      text: formatDouble(widget.currentProt),
    );
    _carbController = TextEditingController(
      text: formatDouble(widget.currentCarb),
    );
    _fatController = TextEditingController(
      text: formatDouble(widget.currentFat),
    );
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editDailyMacroGoals),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _protController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.proteinG),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _carbController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.carbsG),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fatController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.fatsG),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            final p =
                double.tryParse(_protController.text) ?? widget.currentProt;
            final c =
                double.tryParse(_carbController.text) ?? widget.currentCarb;
            final f = double.tryParse(_fatController.text) ?? widget.currentFat;
            widget.onConfirm(p, c, f);
            Navigator.pop(context);
          },
          child: Text(l10n.save),
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
  final VoidCallback? onDeselect;

  const MealPlanCard({
    super.key,
    required this.planWithMeals,
    required this.isSelected,
    required this.onClick,
    required this.onDelete,
    required this.onSelect,
    this.onDeselect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final plan = planWithMeals.mealPlan;
    final meals = planWithMeals.meals;

    // Totals calculations
    double totalProt = 0.0;
    double totalCarb = 0.0;
    double totalFat = 0.0;

    for (final m in meals) {
      for (final detail in m.items) {
        final scale = detail.macroScale;
        if (detail.mealItem.type == MealItemType.PRODUCT &&
            detail.product != null) {
          totalProt += detail.product!.proteins * scale;
          totalCarb += detail.product!.carbs * scale;
          totalFat += detail.product!.fats * scale;
        } else if (detail.mealItem.type == MealItemType.RECIPE &&
            detail.recipe != null) {
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
                    child: Row(
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
                        if (plan.isTemporal) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: theme.colorScheme.secondary,
                          ),
                        ],
                      ],
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
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
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
                  l10n.scheduledMeals(
                    meals.length,
                    meals.map((m) => m.meal.name).join(', '),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildMacroChip(
                          context,
                          "P",
                          totalProt,
                          theme.colorScheme.primaryContainer,
                        ),
                        _buildMacroChip(
                          context,
                          "C",
                          totalCarb,
                          theme.colorScheme.tertiaryContainer,
                        ),
                        _buildMacroChip(
                          context,
                          "F",
                          totalFat,
                          theme.colorScheme.errorContainer,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isSelected)
                    InputChip(
                      label: Text(l10n.selectedLabel),
                      selected: true,
                      onSelected: onDeselect != null
                          ? (_) => onDeselect!()
                          : null,
                      avatar: const Icon(Icons.check, size: 16),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: onSelect,
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: Text(l10n.selectLabel),
                    ),
                ],
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
      backgroundColor: color.withValues(alpha: 0.6),
      label: Text(
        context.l10n.macroChip(label, valStr),
        style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
      ),
    );
  }
}

class _InlineMealNotesEditor extends StatefulWidget {
  final Meal meal;
  final void Function(String) onConfirm;

  const _InlineMealNotesEditor({required this.meal, required this.onConfirm});

  @override
  State<_InlineMealNotesEditor> createState() => _InlineMealNotesEditorState();
}

class _InlineMealNotesEditorState extends State<_InlineMealNotesEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.meal.notes);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _save();
    }
  }

  void _save() {
    final val = _controller.text.trim();
    if (val != widget.meal.notes) {
      widget.onConfirm(val);
    }
  }

  @override
  void didUpdateWidget(covariant _InlineMealNotesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.meal.notes != widget.meal.notes && !_focusNode.hasFocus) {
      _controller.text = widget.meal.notes;
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
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: null,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        border: InputBorder.none,
        hintText: context.l10n.addNoteHint,
      ),
      onFieldSubmitted: (_) => _save(),
    );
  }
}
