/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/db/enums.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/macro_totals.dart';
import '../../l10n/app_localizations.dart';
import 'add_meal_item_screen.dart';

class EditMealPlanNotifier extends StateNotifier<MealPlanWithMealsAndItems?> {
  final Ref ref;
  final int id;

  EditMealPlanNotifier(this.ref, this.id) : super(null) {
    _load(id);
  }

  void _load(int id) async {
    final MealRepository repo = ref.read(mealRepositoryProvider);
    if (id != 0) {
      final MealPlanWithMealsAndItems? plan = await repo
          .getMealPlanWithMealsAndItems(id);
      if (plan != null) {
        state = plan;
        return;
      }
    }
    state = MealPlanWithMealsAndItems(
      mealPlan: MealPlan(
        id: id,
        parentPlanId: 0,
        title: '',
        notes: '',
        state: MealPlanState.TEMPLATE,
        created: DateTime.now(),
        completed: DateTime.now(),
        isTemporal: false,
      ),
      meals: const <MealWithItems>[],
    );
  }

  void updateMealPlanInfo(String title, String notes) {
    if (state == null) return;
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan.copyWith(title: title, notes: notes),
      meals: state!.meals,
    );
  }

  void updateMealPlanMacros(double? protein, double? carbs, double? fats) {
    if (state == null) return;
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan.copyWith(
        targetProtein: Value(protein),
        targetCarbs: Value(carbs),
        targetFats: Value(fats),
      ),
      meals: state!.meals,
    );
  }

  void addMeal(Meal meal) {
    if (state == null) return;
    final List<MealWithItems> updatedMeals =
        List<MealWithItems>.from(state!.meals)..add(
          MealWithItems(
            meal: meal.copyWith(
              mealPlanId: state!.mealPlan.id,
              position: state!.meals.length,
            ),
            items: const <MealItemWithDetails>[],
          ),
        );
    updatedMeals.sort(_byTime);
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  void deleteMeal(int mealId) {
    if (state == null) return;
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: state!.meals
          .where((MealWithItems meal) => meal.meal.id != mealId)
          .toList(),
    );
  }

  void addMealItem(
    int mealId,
    MealItem item,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) {
    if (state == null) return;
    final List<MealWithItems> updatedMeals = state!.meals.map((
      MealWithItems meal,
    ) {
      if (meal.meal.id != mealId) return meal;
      return MealWithItems(
        meal: meal.meal,
        items: List<MealItemWithDetails>.from(meal.items)
          ..add(_detailFor(item, products, recipes)),
      );
    }).toList();
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  /// Replaces an item in place without deleting it first, so cancelling the
  /// picker keeps the original data.
  void replaceMealItem(
    int mealId,
    int oldItemId,
    MealItem item,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) {
    if (state == null) return;
    final List<MealWithItems> updatedMeals = state!.meals.map((
      MealWithItems meal,
    ) {
      if (meal.meal.id != mealId) return meal;
      return MealWithItems(
        meal: meal.meal,
        items: meal.items.map((MealItemWithDetails detail) {
          if (detail.mealItem.id != oldItemId) return detail;
          return _detailFor(
            item.copyWith(
              id: oldItemId,
              consumed: detail.mealItem.consumed,
              position: detail.mealItem.position,
            ),
            products,
            recipes,
          );
        }).toList(),
      );
    }).toList();
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  void deleteMealItem(int mealId, int itemId) {
    if (state == null) return;
    final List<MealWithItems> updatedMeals = state!.meals.map((
      MealWithItems meal,
    ) {
      if (meal.meal.id != mealId) return meal;
      return MealWithItems(
        meal: meal.meal,
        items: meal.items
            .where((MealItemWithDetails detail) => detail.mealItem.id != itemId)
            .toList(),
      );
    }).toList();
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  void updateMealItemAmount(int mealId, int itemId, double newAmount) {
    _mapItem(mealId, itemId, (MealItemWithDetails detail) {
      return MealItemWithDetails(
        mealItem: detail.mealItem.copyWith(amount: newAmount),
        product: detail.product,
        recipe: detail.recipe,
      );
    });
  }

  void updateMealItemUnit(int mealId, int itemId, AmountUnit newUnit) {
    _mapItem(mealId, itemId, (MealItemWithDetails detail) {
      return MealItemWithDetails(
        mealItem: detail.mealItem.copyWith(amountUnit: newUnit),
        product: detail.product,
        recipe: detail.recipe,
      );
    });
  }

  void updateMealName(int mealId, String name) {
    if (state == null) return;
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: state!.meals.map((MealWithItems meal) {
        if (meal.meal.id != mealId) return meal;
        return meal.copyWith(meal: meal.meal.copyWith(name: name));
      }).toList(),
    );
  }

  void updateMealTime(int mealId, LocalTime newTime) {
    if (state == null) return;
    final List<MealWithItems> updatedMeals = state!.meals.map((
      MealWithItems meal,
    ) {
      if (meal.meal.id != mealId) return meal;
      return meal.copyWith(meal: meal.meal.copyWith(time: newTime));
    }).toList()..sort(_byTime);
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: updatedMeals,
    );
  }

  Future<void> save() async {
    if (state == null) return;
    await ref
        .read(mealRepositoryProvider)
        .saveMealPlanWithMealsAndItems(state!);
  }

  void _mapItem(
    int mealId,
    int itemId,
    MealItemWithDetails Function(MealItemWithDetails detail) update,
  ) {
    if (state == null) return;
    state = MealPlanWithMealsAndItems(
      mealPlan: state!.mealPlan,
      meals: state!.meals.map((MealWithItems meal) {
        if (meal.meal.id != mealId) return meal;
        return MealWithItems(
          meal: meal.meal,
          items: meal.items.map((MealItemWithDetails detail) {
            if (detail.mealItem.id != itemId) return detail;
            return update(detail);
          }).toList(),
        );
      }).toList(),
    );
  }

  MealItemWithDetails _detailFor(
    MealItem item,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) {
    return MealItemWithDetails(
      mealItem: item,
      product: item.type == MealItemType.PRODUCT
          ? products.firstWhereOrNull((Product p) => p.id == item.targetId)
          : null,
      recipe: item.type == MealItemType.RECIPE
          ? recipes.firstWhereOrNull(
              (RecipeWithIngredients r) => r.recipe.id == item.targetId,
            )
          : null,
    );
  }

  static int _byTime(MealWithItems a, MealWithItems b) {
    final int aMinutes = a.meal.time.hour * 60 + a.meal.time.minute;
    final int bMinutes = b.meal.time.hour * 60 + b.meal.time.minute;
    return aMinutes.compareTo(bMinutes);
  }
}

/// Legacy helper kept for callers outside the meals feature.
void showFloatingToast(BuildContext context, String message) {
  NexcSnack.show(context, message);
}

final editMealPlanProvider = StateNotifierProvider.autoDispose
    .family<EditMealPlanNotifier, MealPlanWithMealsAndItems?, int>((ref, id) {
      return EditMealPlanNotifier(ref, id);
    });

int _nextMealId(MealPlanWithMealsAndItems plan) {
  final int lowest = plan.meals
      .map((MealWithItems meal) => meal.meal.id)
      .fold<int>(0, (int min, int id) => id < min ? id : min);
  return lowest - 1;
}

int _nextItemId(MealWithItems meal) {
  final int lowest = meal.items
      .map((MealItemWithDetails detail) => detail.mealItem.id)
      .fold<int>(0, (int min, int id) => id < min ? id : min);
  return lowest - 1;
}

enum _ItemAction { replace, delete }

class EditMealPlanScreen extends ConsumerStatefulWidget {
  final int mealPlanId;

  const EditMealPlanScreen({super.key, required this.mealPlanId});

  @override
  ConsumerState<EditMealPlanScreen> createState() => _EditMealPlanScreenState();
}

class _EditMealPlanScreenState extends ConsumerState<EditMealPlanScreen> {
  MealPlanWithMealsAndItems? _initialPlan;
  bool _saving = false;

  EditMealPlanNotifier get _notifier =>
      ref.read(editMealPlanProvider(widget.mealPlanId).notifier);

  bool _hasChanges(MealPlanWithMealsAndItems current) {
    if (widget.mealPlanId == 0) {
      return current.mealPlan.title.trim().isNotEmpty ||
          current.mealPlan.notes.trim().isNotEmpty ||
          current.meals.isNotEmpty;
    }
    final MealPlanWithMealsAndItems? initial = _initialPlan;
    if (initial == null) return false;
    if (current.mealPlan.title != initial.mealPlan.title) return true;
    if (current.mealPlan.notes != initial.mealPlan.notes) return true;
    if (current.mealPlan.targetProtein != initial.mealPlan.targetProtein) {
      return true;
    }
    if (current.mealPlan.targetCarbs != initial.mealPlan.targetCarbs) {
      return true;
    }
    if (current.mealPlan.targetFats != initial.mealPlan.targetFats) {
      return true;
    }
    if (current.meals.length != initial.meals.length) return true;

    for (int i = 0; i < current.meals.length; i++) {
      final MealWithItems currentMeal = current.meals[i];
      final MealWithItems initialMeal = initial.meals[i];
      if (currentMeal.meal.name != initialMeal.meal.name) return true;
      if (currentMeal.meal.time.hour != initialMeal.meal.time.hour ||
          currentMeal.meal.time.minute != initialMeal.meal.time.minute) {
        return true;
      }
      if (currentMeal.meal.notes != initialMeal.meal.notes) return true;
      if (currentMeal.items.length != initialMeal.items.length) return true;
      for (int j = 0; j < currentMeal.items.length; j++) {
        final MealItem currentItem = currentMeal.items[j].mealItem;
        final MealItem initialItem = initialMeal.items[j].mealItem;
        if (currentItem.targetId != initialItem.targetId ||
            currentItem.amount != initialItem.amount ||
            currentItem.amountUnit != initialItem.amountUnit ||
            currentItem.type != initialItem.type) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> _save({
    required MealPlanWithMealsAndItems plan,
    required bool close,
  }) async {
    final AppLocalizations l10n = context.l10n;
    if (plan.mealPlan.title.trim().isEmpty) {
      NexcSnack.show(context, l10n.titleCannotBeEmpty);
      return false;
    }
    if (_saving) return false;
    setState(() => _saving = true);
    await _notifier.save();
    if (!mounted) return false;
    setState(() => _saving = false);
    NexcSnack.show(context, l10n.mealPlanSaved);
    if (close) Navigator.pop(context);
    return true;
  }

  Future<void> _handlePop(MealPlanWithMealsAndItems plan) async {
    if (!_hasChanges(plan)) {
      Navigator.pop(context);
      return;
    }
    final AppLocalizations l10n = context.l10n;
    final bool? decision = await NexcConfirmSheet.show(
      context: context,
      title: l10n.discardChangesTitle,
      message: l10n.discardChangesMessage,
      confirmLabel: l10n.saveAction,
      secondaryLabel: l10n.discardAction,
      cancelLabel: l10n.cancel,
    );
    if (!mounted || decision == null) return;
    if (decision) {
      await _save(plan: plan, close: true);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickTime(Meal meal) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: meal.time.hour, minute: meal.time.minute),
    );
    if (picked == null) return;
    _notifier.updateMealTime(meal.id, LocalTime(picked.hour, picked.minute));
  }

  Future<void> _addItem(
    MealWithItems meal,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) async {
    final List<MealItemPick>? picks = await Navigator.push<List<MealItemPick>>(
      context,
      MaterialPageRoute<List<MealItemPick>>(
        builder: (BuildContext context) =>
            AddMealItemScreen(products: products, recipes: recipes),
      ),
    );
    if (picks == null || picks.isEmpty || !mounted) return;
    for (final MealItemPick pick in picks) {
      final MealPlanWithMealsAndItems? current = ref.read(
        editMealPlanProvider(widget.mealPlanId),
      );
      final MealWithItems currentMeal =
          current?.meals.firstWhereOrNull(
            (MealWithItems entry) => entry.meal.id == meal.meal.id,
          ) ??
          meal;
      final int itemId = _nextItemId(currentMeal);
      _notifier.addMealItem(
        meal.meal.id,
        MealItem(
          id: itemId,
          mealId: meal.meal.id,
          type: pick.type,
          targetId: pick.targetId,
          amount: pick.amount,
          amountUnit: pick.unit,
          consumed: false,
          position: meal.items.length,
        ),
        products,
        recipes,
      );
    }
  }

  Future<void> _replaceItem(
    MealWithItems meal,
    MealItemWithDetails detail,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) async {
    final List<MealItemPick>? picks = await Navigator.push<List<MealItemPick>>(
      context,
      MaterialPageRoute<List<MealItemPick>>(
        builder: (BuildContext context) => AddMealItemScreen(
          products: products,
          recipes: recipes,
          isReplace: true,
          replaceItemId: detail.mealItem.id,
        ),
      ),
    );
    // Cancelling the picker leaves the original item untouched.
    if (picks == null || picks.isEmpty || !mounted) return;
    final MealItemPick pick = picks.first;
    _notifier.replaceMealItem(
      meal.meal.id,
      detail.mealItem.id,
      MealItem(
        id: detail.mealItem.id,
        mealId: meal.meal.id,
        type: pick.type,
        targetId: pick.targetId,
        amount: pick.amount,
        amountUnit: pick.unit,
        consumed: detail.mealItem.consumed,
        position: detail.mealItem.position,
      ),
      products,
      recipes,
    );
  }

  Future<void> _showItemActions(
    MealWithItems meal,
    MealItemWithDetails detail,
    List<Product> products,
    List<RecipeWithIngredients> recipes,
  ) async {
    final _ItemAction? action = await showModalBottomSheet<_ItemAction>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) =>
          _ItemActionsSheet(itemName: detail.displayName),
    );
    if (action == null || !mounted) return;
    switch (action) {
      case _ItemAction.replace:
        await _replaceItem(meal, detail, products, recipes);
      case _ItemAction.delete:
        _notifier.deleteMealItem(meal.meal.id, detail.mealItem.id);
    }
  }

  Future<void> _editItemQuantity(
    MealWithItems meal,
    MealItemWithDetails detail,
  ) async {
    final ({double amount, AmountUnit unit})? result =
        await showMealItemQuantitySheet(
          context: context,
          initialAmount: detail.mealItem.amount,
          initialUnit: detail.mealItem.amountUnit,
          product: detail.product,
          isRecipe: detail.mealItem.type == MealItemType.RECIPE,
          title: detail.displayName,
        );
    if (result == null || !mounted) return;
    _notifier.updateMealItemAmount(
      meal.meal.id,
      detail.mealItem.id,
      result.amount,
    );
    _notifier.updateMealItemUnit(meal.meal.id, detail.mealItem.id, result.unit);
  }

  Future<void> _deleteMeal(Meal meal) async {
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: context.l10n.deleteMeal,
      message: context.l10n.deleteMealConfirm(meal.name),
      confirmLabel: context.l10n.delete,
      cancelLabel: context.l10n.cancel,
      destructive: true,
    );
    if (confirmed != true) return;
    _notifier.deleteMeal(meal.id);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final MealPlanWithMealsAndItems? plan = ref.watch(
      editMealPlanProvider(widget.mealPlanId),
    );
    final List<Product> products =
        ref.watch(allProductsProvider).value ?? const <Product>[];
    final List<RecipeWithIngredients> recipes =
        ref.watch(allRecipesProvider).value ?? const <RecipeWithIngredients>[];
    final bool isNew = widget.mealPlanId == 0;

    if (plan == null) {
      return NexcPage(
        title: isNew ? l10n.createMealPlan : l10n.editMealPlan,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _initialPlan ??= plan;
    final MacroTotals totals = MacroTotals.ofPlan(plan);
    final bool canSave = plan.mealPlan.title.trim().isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        await _handlePop(plan);
      },
      child: NexcPage(
        title: isNew ? l10n.createMealPlan : l10n.editMealPlan,
        bottomBar: FilledButton.icon(
          onPressed: canSave && !_saving
              ? () => _save(plan: plan, close: true)
              : null,
          icon: const Icon(NexcIcons.check, size: 18),
          label: Text(l10n.save),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NexcSpacing.lg,
            NexcSpacing.md,
            NexcSpacing.lg,
            NexcSpacing.xxl,
          ),
          children: [
            TextFormField(
              initialValue: plan.mealPlan.title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.planTitle,
                hintText: l10n.createMealPlan,
              ),
              onChanged: (String value) =>
                  _notifier.updateMealPlanInfo(value, plan.mealPlan.notes),
            ),
            const SizedBox(height: NexcSpacing.md),
            TextFormField(
              initialValue: plan.mealPlan.notes,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.notesGoal),
              onChanged: (String value) =>
                  _notifier.updateMealPlanInfo(plan.mealPlan.title, value),
            ),
            const SizedBox(height: NexcSpacing.xl),
            NexcSection(
              title: l10n.targetMacros,
              padded: true,
              spaced: false,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Widget protein = TextFormField(
                      initialValue: plan.mealPlan.targetProtein == null
                          ? ''
                          : formatDecimal(plan.mealPlan.targetProtein!),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.proteinG,
                        helperText: l10n.sumGrams(
                          formatDecimal(totals.protein),
                        ),
                      ),
                      onChanged: (String value) =>
                          _notifier.updateMealPlanMacros(
                            double.tryParse(value),
                            plan.mealPlan.targetCarbs,
                            plan.mealPlan.targetFats,
                          ),
                    );
                    final Widget carbs = TextFormField(
                      initialValue: plan.mealPlan.targetCarbs == null
                          ? ''
                          : formatDecimal(plan.mealPlan.targetCarbs!),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.carbsG,
                        helperText: l10n.sumGrams(formatDecimal(totals.carbs)),
                      ),
                      onChanged: (String value) =>
                          _notifier.updateMealPlanMacros(
                            plan.mealPlan.targetProtein,
                            double.tryParse(value),
                            plan.mealPlan.targetFats,
                          ),
                    );
                    final Widget fats = TextFormField(
                      initialValue: plan.mealPlan.targetFats == null
                          ? ''
                          : formatDecimal(plan.mealPlan.targetFats!),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.fatsG,
                        helperText: l10n.sumGrams(formatDecimal(totals.fats)),
                      ),
                      onChanged: (String value) =>
                          _notifier.updateMealPlanMacros(
                            plan.mealPlan.targetProtein,
                            plan.mealPlan.targetCarbs,
                            double.tryParse(value),
                          ),
                    );
                    if (constraints.maxWidth < 420) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          protein,
                          const SizedBox(height: NexcSpacing.md),
                          carbs,
                          const SizedBox(height: NexcSpacing.md),
                          fats,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: protein),
                        const SizedBox(width: NexcSpacing.md),
                        Expanded(child: carbs),
                        const SizedBox(width: NexcSpacing.md),
                        Expanded(child: fats),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: NexcSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.mealsLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final DateTime now = DateTime.now();
                    _notifier.addMeal(
                      Meal(
                        id: _nextMealId(plan),
                        mealPlanId: widget.mealPlanId,
                        name: l10n.mealNumber(plan.meals.length + 1),
                        time: LocalTime(now.hour, now.minute),
                        notes: '',
                        position: plan.meals.length,
                        atHome: true,
                      ),
                    );
                  },
                  icon: const Icon(NexcIcons.add, size: 18),
                  label: Text(l10n.addMeal),
                ),
              ],
            ),
            const SizedBox(height: NexcSpacing.md),
            if (plan.meals.isEmpty)
              Text(
                l10n.addItemToMealLower,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            for (final MealWithItems meal in plan.meals) ...[
              MealEditCard(
                key: ValueKey<int>(meal.meal.id),
                mealWithItems: meal,
                onDeleteMeal: () => _deleteMeal(meal.meal),
                onTimeTap: () => _pickTime(meal.meal),
                onNameChanged: (String name) =>
                    _notifier.updateMealName(meal.meal.id, name),
                onAddItem: () => _addItem(meal, products, recipes),
                onEditItemQuantity: (MealItemWithDetails detail) =>
                    _editItemQuantity(meal, detail),
                onItemActions: (MealItemWithDetails detail) =>
                    _showItemActions(meal, detail, products, recipes),
              ),
              const SizedBox(height: NexcSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemActionsSheet extends StatelessWidget {
  final String itemName;

  const _ItemActionsSheet({required this.itemName});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NexcSpacing.xl,
        NexcSpacing.sm,
        NexcSpacing.xl,
        NexcSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.editItem, style: theme.textTheme.headlineSmall),
          const SizedBox(height: NexcSpacing.xs),
          Text(
            itemName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: NexcSpacing.lg),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, _ItemAction.replace),
            icon: const Icon(NexcIcons.edit, size: 18),
            label: Text(l10n.replaceAction),
          ),
          const SizedBox(height: NexcSpacing.sm),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error),
            ),
            onPressed: () => Navigator.pop(context, _ItemAction.delete),
            icon: const Icon(NexcIcons.delete, size: 18),
            label: Text(l10n.delete),
          ),
          const SizedBox(height: NexcSpacing.sm),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}

class MealEditCard extends StatelessWidget {
  final MealWithItems mealWithItems;
  final VoidCallback onDeleteMeal;
  final VoidCallback onTimeTap;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onAddItem;
  final ValueChanged<MealItemWithDetails> onEditItemQuantity;
  final ValueChanged<MealItemWithDetails> onItemActions;

  const MealEditCard({
    super.key,
    required this.mealWithItems,
    required this.onDeleteMeal,
    required this.onTimeTap,
    required this.onNameChanged,
    required this.onAddItem,
    required this.onEditItemQuantity,
    required this.onItemActions,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;
    final Meal meal = mealWithItems.meal;
    final String timeLabel =
        '${meal.time.hour.toString().padLeft(2, '0')}:'
        '${meal.time.minute.toString().padLeft(2, '0')}';

    return Material(
      color: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.lgRadius),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final Widget timeButton = TextButton(
                            onPressed: onTimeTap,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: NexcSpacing.sm,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              timeLabel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          );
                          final Widget nameField = TextFormField(
                            initialValue: meal.name,
                            textCapitalization: TextCapitalization.sentences,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: const InputDecoration(isDense: true),
                            onChanged: onNameChanged,
                          );
                          if (constraints.maxWidth < 280) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                timeButton,
                                const SizedBox(height: NexcSpacing.xs),
                                nameField,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              timeButton,
                              const SizedBox(width: NexcSpacing.xs),
                              Expanded(child: nameField),
                            ],
                          );
                        },
                  ),
                ),
                IconButton(
                  tooltip: l10n.deleteMeal,
                  onPressed: onDeleteMeal,
                  icon: Icon(NexcIcons.delete, color: scheme.error),
                ),
              ],
            ),
            if (meal.notes.isNotEmpty) ...[
              const SizedBox(height: NexcSpacing.xs),
              Text(
                meal.notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const Divider(height: NexcSpacing.xl),
            if (mealWithItems.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: NexcSpacing.sm),
                child: Text(
                  l10n.addItemToMealLower,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final MealItemWithDetails detail in mealWithItems.items)
                _ItemEditRow(
                  detail: detail,
                  onTapAmount: () => onEditItemQuantity(detail),
                  onMenu: () => onItemActions(detail),
                ),
            const SizedBox(height: NexcSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAddItem,
                icon: const Icon(NexcIcons.add, size: 18),
                label: Text(l10n.addItem),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemEditRow extends StatelessWidget {
  final MealItemWithDetails detail;
  final VoidCallback onTapAmount;
  final VoidCallback onMenu;

  const _ItemEditRow({
    required this.detail,
    required this.onTapAmount,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final String name = detail.mealItem.type == MealItemType.PRODUCT
        ? (detail.product?.name ?? l10n.unknownProduct)
        : (detail.recipe?.recipe.name ?? l10n.unknownRecipe);
    final String unit = mealItemUnitLabel(
      context,
      detail.mealItem,
      detail.product,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NexcSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: NexcSpacing.xs),
          TextButton(
            onPressed: onTapAmount,
            child: Text(
              '${formatDecimal(detail.mealItem.amount)} $unit',
              style: theme.textTheme.labelLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.moreOptions,
            onPressed: onMenu,
            icon: const Icon(NexcIcons.more, size: 20),
          ),
        ],
      ),
    );
  }
}
