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

  Future<void> save(VoidCallback onSuccess) async {
    if (state == null) return;
    final repo = ref.read(mealRepositoryProvider);
    await repo.saveMealPlanWithMealsAndItems(state!);
    onSuccess();
  }
}

final editMealPlanProvider = StateNotifierProvider.family<EditMealPlanNotifier, MealPlanWithMealsAndItems?, int>((ref, id) {
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = ref.watch(editMealPlanProvider(widget.mealPlanId));
    final products = ref.watch(allProductsProvider).value ?? [];
    final recipes = ref.watch(allRecipesProvider).value ?? [];

    if (plan == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return NexcScaffold(
      title: const Text("Create Meal Plan"),
      navigateBack: () => Navigator.pop(context),
      actions: [
        () {
          ref.read(editMealPlanProvider(widget.mealPlanId).notifier).save(() {
            Navigator.pop(context);
          });
        }
      ],
      actionsDescription: const ["Save"],
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
                    showDialog(
                      context: context,
                      builder: (context) => AddMealDialog(
                        onDismiss: () => Navigator.pop(context),
                        onConfirm: (meal) {
                          ref.read(editMealPlanProvider(widget.mealPlanId).notifier).addMeal(meal);
                          Navigator.pop(context);
                        },
                      ),
                    );
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
                onDeleteMeal: () {
                  ref
                      .read(editMealPlanProvider(widget.mealPlanId).notifier)
                      .deleteMeal(mealWithItems.meal.id);
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
              );
            }),
          ],
        );
      },
    );
  }
}

class MealEditCard extends StatelessWidget {
  final MealWithItems mealWithItems;
  final VoidCallback onDeleteMeal;
  final VoidCallback onAddItemClick;
  final void Function(int) onDeleteItem;
  final void Function(int) onReplaceItem;

  const MealEditCard({
    super.key,
    required this.mealWithItems,
    required this.onDeleteMeal,
    required this.onAddItemClick,
    required this.onDeleteItem,
    required this.onReplaceItem,
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
                      meal.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$name: ${detail.mealItem.amount.toStringAsFixed(0)}g/units",
                      style: theme.textTheme.bodyMedium,
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (val) {
                        if (val == "replace") {
                          onReplaceItem(detail.mealItem.id);
                        } else if (val == "delete") {
                          onDeleteItem(detail.mealItem.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "replace", child: Text("Replace")),
                        PopupMenuItem(
                          value: "delete",
                          child: Text(
                            "Delete",
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onAddItemClick,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Add Food / Recipe"),
            )
          ],
        ),
      ),
    );
  }
}

class AddMealDialog extends StatefulWidget {
  final VoidCallback onDismiss;
  final void Function(Meal) onConfirm;

  const AddMealDialog({
    super.key,
    required this.onDismiss,
    required this.onConfirm,
  });

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _errorText;
  LocalTime _selectedTime = const LocalTime(12, 0);

  @override
  void initState() {
    super.initState();
    _timeController.text =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _validate(String val) {
    final parts = val.split(':');
    if (parts.length != 2) {
      setState(() => _errorText = 'Use HH:MM format');
      return;
    }
    final hour = int.tryParse(parts[0]);
    final min = int.tryParse(parts[1]);
    if (hour == null || hour < 0 || hour > 23 || min == null || min < 0 || min > 59) {
      setState(() => _errorText = 'Invalid hour (0-23) or minute (0-59)');
      return;
    }
    setState(() {
      _errorText = null;
      _selectedTime = LocalTime(hour, min);
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = LocalTime(picked.hour, picked.minute);
        _timeController.text =
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Meal Slot"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Meal Name"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                labelText: "Time (HH:MM)",
                errorText: _errorText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _selectTime(context),
                ),
              ),
              onChanged: _validate,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: "How to eat/Notes"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onDismiss, child: const Text("Cancel")),
        TextButton(
          onPressed: _errorText == null
              ? () {
                  final name = _nameController.text.trim();
                  final notes = _notesController.text.trim();
                  if (name.isNotEmpty) {
                    widget.onConfirm(
                      Meal(
                        id: Random().nextInt(10000000), // unique memory ID
                        mealPlanId: 0,
                        name: name,
                        time: _selectedTime,
                        notes: notes,
                        position: 0,
                      ),
                    );
                  }
                }
              : null,
          child: const Text("Add"),
        ),
      ],
    );
  }
}
