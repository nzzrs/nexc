/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/db/app_database.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/db/meal_repository.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/components/nexc_scaffold.dart';
import 'meals_dashboard_screen.dart';

class EditMealPlanNotifier extends StateNotifier<MealPlanWithMealsAndItems?> {
  final Ref ref;
  final int id;

  EditMealPlanNotifier(this.ref, this.id) : super(null) {
    _load(id);
  }

  void _load(int id) async {
    final repo = ref.read(mealRepositoryProvider);
    if (id != 0) {
      final plan = await repo.getMealPlanWithMealsAndItems(id);
      if (plan != null) {
        state = plan;
        return;
      }
    }
    state = MealPlanWithMealsAndItems(
      mealPlan: MealPlan(
        id: id,
        parentPlanId: 0,
        title: "New Meal Plan",
        notes: "",
        state: MealPlanState.TEMPLATE,
        created: DateTime.now(),
        completed: DateTime.now(),
        isTemporal: false,
      ),
      meals: [],
    );
  }

  void updateMealPlanInfo(String title, String notes) {
    if (state == null) return;
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan.copyWith(title: title, notes: notes),
      meals: state!.meals,
    );
  }

  void updateMealPlanMacros(double? prot, double? carbs, double? fats) {
    if (state == null) return;
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan.copyWith(
        targetProtein: Value(prot),
        targetCarbs: Value(carbs),
        targetFats: Value(fats),
      ),
      meals: state!.meals,
    );
  }

  void addMeal(Meal meal) {
    if (state == null) return;
    final updatedMeals = List<MealWithItems>.from(state!.meals)
      ..add(MealWithItems(
        meal: meal.copyWith(mealPlanId: state!.mealPlan.id, position: state!.meals.length),
        items: [],
      ));
    updatedMeals.sort((a, b) {
      final aMinutes = a.meal.time.hour * 60 + a.meal.time.minute;
      final bMinutes = b.meal.time.hour * 60 + b.meal.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  void deleteMeal(int mealId) {
    if (state == null) return;
    final updatedMeals = state!.meals.where((m) => m.meal.id != mealId).toList();
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  void addMealItem(int mealId, MealItem item, List<Product> products, List<RecipeWithIngredients> recipes) {
    if (state == null) return;
    final updatedMeals = state!.meals.map((m) {
      if (m.meal.id == mealId) {
        final detail = MealItemWithDetails(
          mealItem: item.copyWith(mealId: mealId, position: m.items.length),
          product: products.firstWhereOrNull((p) => p.id == item.targetId),
          recipe: recipes.firstWhereOrNull((r) => r.recipe.id == item.targetId),
        );
        return MealWithItems(
          meal: m.meal,
          items: List<MealItemWithDetails>.from(m.items)..add(detail),
        );
      }
      return m;
    }).toList();
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  void deleteMealItem(int mealId, int itemId) {
    if (state == null) return;
    final updatedMeals = state!.meals.map((m) {
      if (m.meal.id == mealId) {
        return MealWithItems(
          meal: m.meal,
          items: m.items.where((it) => it.mealItem.id != itemId).toList(),
        );
      }
      return m;
    }).toList();
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  void updateMealItemAmount(int mealId, int itemId, double newAmount) {
    if (state == null) return;
    final updatedMeals = state!.meals.map((m) {
      if (m.meal.id == mealId) {
        return MealWithItems(
          meal: m.meal,
          items: m.items.map((it) {
            if (it.mealItem.id == itemId) {
              return MealItemWithDetails(
                mealItem: it.mealItem.copyWith(amount: newAmount),
                product: it.product,
                recipe: it.recipe,
              );
            }
            return it;
          }).toList(),
        );
      }
      return m;
    }).toList();
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  void updateMealItemUnit(int mealId, int itemId, AmountUnit newUnit) {
    if (state == null) return;
    final updatedMeals = state!.meals.map((m) {
      if (m.meal.id == mealId) {
        return MealWithItems(
          meal: m.meal,
          items: m.items.map((it) {
            if (it.mealItem.id == itemId) {
              return MealItemWithDetails(
                mealItem: it.mealItem.copyWith(amountUnit: newUnit),
                product: it.product,
                recipe: it.recipe,
              );
            }
            return it;
          }).toList(),
        );
      }
      return m;
    }).toList();
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  void updateMealName(int mealId, String name) {
    if (state == null) return;
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: state!.meals.map((m) {
        if (m.meal.id == mealId) {
          return m.copyWith(meal: m.meal.copyWith(name: name));
        }
        return m;
      }).toList(),
    );
  }

  void updateMealTime(int mealId, LocalTime newTime) {
    if (state == null) return;
    final updatedMeals = state!.meals.map((m) {
      if (m.meal.id == mealId) {
        return m.copyWith(meal: m.meal.copyWith(time: newTime));
      }
      return m;
    }).toList();
    updatedMeals.sort((a, b) {
      final aTime = a.meal.time;
      final bTime = b.meal.time;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      final aMinutes = aTime.hour * 60 + aTime.minute;
      final bMinutes = bTime.hour * 60 + bTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  Future<void> save(VoidCallback onSuccess) async {
    if (state == null) return;
    final repo = ref.read(mealRepositoryProvider);
    await repo.saveMealPlanWithMealsAndItems(state!);
    onSuccess();
  }
}

void showFloatingToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 100,
      left: 50,
      right: 50,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () {
    entry.remove();
  });
}

final editMealPlanProvider = StateNotifierProvider.autoDispose.family<EditMealPlanNotifier, MealPlanWithMealsAndItems?, int>((ref, id) {
  return EditMealPlanNotifier(ref, id);
});

class EditMealPlanScreen extends ConsumerStatefulWidget {
  final int mealPlanId;

  const EditMealPlanScreen({
    super.key,
    required this.mealPlanId,
  });

  @override
  ConsumerState<EditMealPlanScreen> createState() => _EditMealPlanScreenState();
}

class _EditMealPlanScreenState extends ConsumerState<EditMealPlanScreen> {
  MealPlanWithMealsAndItems? _initialPlan;

  bool _hasChanges(MealPlanWithMealsAndItems current) {
    if (widget.mealPlanId == 0) {
      final hasTitle = current.mealPlan.title.trim().isNotEmpty && current.mealPlan.title != "New Meal Plan";
      final hasNotes = current.mealPlan.notes.trim().isNotEmpty;
      final hasMeals = current.meals.isNotEmpty;
      return hasTitle || hasNotes || hasMeals;
    }
    if (_initialPlan == null) return false;
    if (current.mealPlan.title != _initialPlan!.mealPlan.title) return true;
    if (current.mealPlan.notes != _initialPlan!.mealPlan.notes) return true;
    if (current.meals.length != _initialPlan!.meals.length) return true;

    for (int i = 0; i < current.meals.length; i++) {
      final curM = current.meals[i];
      final initM = _initialPlan!.meals[i];
      if (curM.meal.name != initM.meal.name) return true;
      if (curM.meal.time.hour != initM.meal.time.hour ||
          curM.meal.time.minute != initM.meal.time.minute) return true;
      if (curM.items.length != initM.items.length) return true;
      for (int j = 0; j < curM.items.length; j++) {
        final curIt = curM.items[j].mealItem;
        final initIt = initM.items[j].mealItem;
        if (curIt.targetId != initIt.targetId ||
            curIt.amount != initIt.amount ||
            curIt.amountUnit != initIt.amountUnit ||
            curIt.type != initIt.type) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = ref.watch(editMealPlanProvider(widget.mealPlanId));
    final products = ref.watch(allProductsProvider).value ?? [];
    final recipes = ref.watch(allRecipesProvider).value ?? [];
    final isNew = widget.mealPlanId == 0;
    if (plan == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double currentProt = 0.0;
    double currentCarb = 0.0;
    double currentFat = 0.0;
    for (final m in plan.meals) {
      for (final detail in m.items) {
        final scale = detail.macroScale;
        if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
          currentProt += detail.product!.proteins * scale;
          currentCarb += detail.product!.carbs * scale;
          currentFat += detail.product!.fats * scale;
        } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
          for (final ing in detail.recipe!.ingredients) {
            final ingScale = (ing.ingredient.amount / 100.0) * scale;
            currentProt += ing.product.proteins * ingScale;
            currentCarb += ing.product.carbs * ingScale;
            currentFat += ing.product.fats * ingScale;
          }
        }
      }
    }

    if (_initialPlan == null) {
      // Store initial plan on first load
      _initialPlan = plan;
    }

    Future<void> _handlePop() async {
      if (!_hasChanges(plan)) {
        Navigator.pop(context);
        return;
      }

      final confirmed = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text('Do you want to discard your changes or save them?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'discard'),
                child: Text('DISCARD', style: TextStyle(color: theme.colorScheme.error)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'save'),
                child: const Text('SAVE'),
              ),
            ],
          );
        },
      );

      if (confirmed == 'discard') {
        if (mounted) {
          Navigator.pop(context);
        }
      } else if (confirmed == 'save') {
        if (plan.mealPlan.title.trim().isEmpty) {
          showFloatingToast(context, "Title cannot be empty");
          return;
        }
        ref.read(editMealPlanProvider(widget.mealPlanId).notifier).save(() {
          showFloatingToast(context, "Meal plan saved");
          Navigator.pop(context);
        });
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handlePop();
      },
      child: NexcScaffold(
        title: Text(isNew ? "Create Meal Plan" : "Edit Meal Plan"),
        navigateBack: _handlePop,
        actions: [
          () {
            ref.read(editMealPlanProvider(widget.mealPlanId).notifier).save(() {
              showFloatingToast(context, "Meal plan saved");
              Navigator.pop(context);
            });
          }
        ],
        actionsIcons: const [Icon(Icons.check)],
        actionsEnabled: [plan.mealPlan.title.trim().isNotEmpty],
        content: (context, padding) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: plan.mealPlan.title,
              onChanged: (val) {
                ref
                    .read(editMealPlanProvider(widget.mealPlanId).notifier)
                    .updateMealPlanInfo(val, plan.mealPlan.notes);
              },
              decoration: const InputDecoration(
                labelText: "Plan Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: plan.mealPlan.notes,
              onChanged: (val) {
                ref
                    .read(editMealPlanProvider(widget.mealPlanId).notifier)
                    .updateMealPlanInfo(plan.mealPlan.title, val);
              },
              decoration: const InputDecoration(
                labelText: "Notes/Goal",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text(
              "Target Macros",
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: plan.mealPlan.targetProtein?.toStringAsFixed(0) ?? "",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Protein (g)",
                      helperText: "Sum: ${currentProt.toStringAsFixed(0)}g",
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      ref.read(editMealPlanProvider(widget.mealPlanId).notifier).updateMealPlanMacros(
                        parsed,
                        plan.mealPlan.targetCarbs,
                        plan.mealPlan.targetFats,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: plan.mealPlan.targetCarbs?.toStringAsFixed(0) ?? "",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Carbs (g)",
                      helperText: "Sum: ${currentCarb.toStringAsFixed(0)}g",
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      ref.read(editMealPlanProvider(widget.mealPlanId).notifier).updateMealPlanMacros(
                        plan.mealPlan.targetProtein,
                        parsed,
                        plan.mealPlan.targetFats,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: plan.mealPlan.targetFats?.toStringAsFixed(0) ?? "",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Fats (g)",
                      helperText: "Sum: ${currentFat.toStringAsFixed(0)}g",
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      ref.read(editMealPlanProvider(widget.mealPlanId).notifier).updateMealPlanMacros(
                        plan.mealPlan.targetProtein,
                        plan.mealPlan.targetCarbs,
                        parsed,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Meals",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final now = DateTime.now();
                    final meal = Meal(
                      id: Random().nextInt(10000000),
                      mealPlanId: widget.mealPlanId,
                      name: "Meal ${plan.meals.length + 1}",
                      time: LocalTime(now.hour, now.minute),
                      notes: "",
                      position: plan.meals.length,
                    );
                    ref.read(editMealPlanProvider(widget.mealPlanId).notifier).addMeal(meal);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Meal"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.meals.map((mealWithItems) {
              return MealEditCard(
                key: ValueKey(mealWithItems.meal.id),
                mealWithItems: mealWithItems,
                onDeleteMeal: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Meal"),
                      content: Text("Are you sure you want to delete '${mealWithItems.meal.name}'?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text("Delete", style: TextStyle(color: theme.colorScheme.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref
                        .read(editMealPlanProvider(widget.mealPlanId).notifier)
                        .deleteMeal(mealWithItems.meal.id);
                  }
                },
                onAddItemClick: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddMealItemDialog(
                      products: products,
                      recipes: recipes,
                      onDismiss: () => Navigator.pop(context),
                      onConfirm: (type, targetId, amount, amountUnit) {
                        final newItem = MealItem(
                          id: Random().nextInt(10000000), // Unique ID in memory
                          mealId: mealWithItems.meal.id,
                          type: type,
                          targetId: targetId,
                          amount: amount,
                          amountUnit: amountUnit,
                          consumed: false,
                          position: 0,
                        );
                        ref
                            .read(editMealPlanProvider(widget.mealPlanId).notifier)
                            .addMealItem(mealWithItems.meal.id, newItem, products, recipes);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                onDeleteItem: (itemId) {
                  ref
                      .read(editMealPlanProvider(widget.mealPlanId).notifier)
                      .deleteMealItem(mealWithItems.meal.id, itemId);
                },
                onReplaceItem: (oldItemId) {
                  ref
                      .read(editMealPlanProvider(widget.mealPlanId).notifier)
                      .deleteMealItem(mealWithItems.meal.id, oldItemId);
                  showDialog(
                    context: context,
                    builder: (context) => AddMealItemDialog(
                      products: products,
                      recipes: recipes,
                      onDismiss: () => Navigator.pop(context),
                      onConfirm: (type, targetId, amount, amountUnit) {
                        final newItem = MealItem(
                          id: Random().nextInt(10000000), // Unique ID in memory
                          mealId: mealWithItems.meal.id,
                          type: type,
                          targetId: targetId,
                          amount: amount,
                          amountUnit: amountUnit,
                          consumed: false,
                          position: 0,
                        );
                        ref
                            .read(editMealPlanProvider(widget.mealPlanId).notifier)
                            .addMealItem(mealWithItems.meal.id, newItem, products, recipes);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                widgetRef: ref,
              );
            }),
          ],
        );
      },
    ),
  );
}
}

class MealEditCard extends StatelessWidget {
  final MealWithItems mealWithItems;
  final VoidCallback onDeleteMeal;
  final VoidCallback onAddItemClick;
  final void Function(int) onDeleteItem;
  final void Function(int) onReplaceItem;
  final WidgetRef widgetRef;

  const MealEditCard({
    super.key,
    required this.mealWithItems,
    required this.onDeleteMeal,
    required this.onAddItemClick,
    required this.onDeleteItem,
    required this.onReplaceItem,
    required this.widgetRef,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meal = mealWithItems.meal;
    final timeStr =
        '${meal.time.hour.toString().padLeft(2, '0')}:${meal.time.minute.toString().padLeft(2, '0')}';

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
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: meal.time.hour, minute: meal.time.minute),
                          );
                          if (picked != null) {
                            widgetRef
                                .read(editMealPlanProvider(meal.mealPlanId).notifier)
                                .updateMealTime(meal.id, LocalTime(picked.hour, picked.minute));
                          }
                        },
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
                        child: TextFormField(
                          initialValue: meal.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            widgetRef
                                .read(editMealPlanProvider(meal.mealPlanId).notifier)
                                .updateMealName(meal.id, val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  onPressed: onDeleteMeal,
                ),
              ],
            ),
            if (meal.notes.isNotEmpty) ...[
              Text(
                meal.notes,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
            ],
            const Divider(),
            ...mealWithItems.items.map((detail) {
              final name = detail.mealItem.type == MealItemType.PRODUCT
                  ? (detail.product?.name ?? "Unknown Product")
                  : (detail.recipe?.recipe.name ?? "Unknown Recipe");

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Edit Item"),
                                    content: const Text("Select an action for this item."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          onReplaceItem(detail.mealItem.id);
                                        },
                                        child: const Text("Replace"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          onDeleteItem(detail.mealItem.id);
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(color: theme.colorScheme.error),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text(
                                name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InlineAmountEditor(
                                mealItem: detail.mealItem,
                                onConfirm: (newAmount) {
                                  widgetRef
                                      .read(editMealPlanProvider(meal.mealPlanId).notifier)
                                      .updateMealItemAmount(meal.id, detail.mealItem.id, newAmount);
                                },
                              ),
                              const SizedBox(width: 3),
                              PopupMenuButton<AmountUnit>(
                                offset: const Offset(0, 30),
                                onSelected: (newUnit) {
                                  widgetRef
                                      .read(editMealPlanProvider(meal.mealPlanId).notifier)
                                      .updateMealItemUnit(meal.id, detail.mealItem.id, newUnit);
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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAddItemClick,
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Item"),
            ),
          ],
        ),
      ),
    );
  }
}
