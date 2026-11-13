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

import '../../core/components/nexc_badge.dart';
import '../../core/components/nexc_choice_sheet.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_macro.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/db/enums.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/day_window_helper.dart';
import '../../core/util/format.dart';
import '../../core/util/macro_totals.dart';
import '../../l10n/app_localizations.dart';
import 'add_meal_item_screen.dart';

enum _DashboardAction { addItem, logSnack, newPlan }

enum _MealMenuAction { editDetails, deleteMeal }

enum _PlanMenuAction { select, deselect, delete }

class MealsDashboardScreen extends ConsumerStatefulWidget {
  const MealsDashboardScreen({super.key});

  @override
  ConsumerState<MealsDashboardScreen> createState() =>
      _MealsDashboardScreenState();
}

class _MealsDashboardScreenState extends ConsumerState<MealsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Rebuild once per index change instead of once per animation frame.
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == _tabIndex) return;
    setState(() => _tabIndex = _tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openActionSheet(MealPlanWithMealsAndItems? plan) async {
    final l10n = context.l10n;
    final _DashboardAction? action =
        await NexcChoiceSheet.show<_DashboardAction>(
          context: context,
          title: l10n.addFood,
          options: [
            NexcChoiceOption(
              value: _DashboardAction.addItem,
              label: l10n.addItemToMeal,
              icon: NexcIcons.meals,
              enabled: plan != null && plan.meals.isNotEmpty,
            ),
            NexcChoiceOption(
              value: _DashboardAction.logSnack,
              label: l10n.addSnack,
              icon: NexcIcons.mealsIdle,
              enabled: plan != null,
            ),
            NexcChoiceOption(
              value: _DashboardAction.newPlan,
              label: l10n.createMealPlan,
              icon: NexcIcons.calendar,
            ),
          ],
        );
    if (!mounted || action == null) return;
    switch (action) {
      case _DashboardAction.addItem:
        if (plan == null || plan.meals.isEmpty) return;
        await _pickMealThenAddItem(plan);
      case _DashboardAction.logSnack:
        if (plan == null) return;
        await _logSnack(plan);
      case _DashboardAction.newPlan:
        await Navigator.pushNamed(context, '/meals/edit-plan', arguments: 0);
    }
  }

  Future<void> _pickMealThenAddItem(MealPlanWithMealsAndItems plan) async {
    final bool useSnackName =
        plan.meals.length == 1 &&
        plan.meals.first.meal.name == context.l10n.addSnack;
    if (useSnackName) {
      await _addItemToMeal(plan.meals.first.meal.id, consumed: true);
      return;
    }
    final MealWithItems? meal = await NexcChoiceSheet.show<MealWithItems>(
      context: context,
      title: context.l10n.addItemToMeal,
      options: [
        for (final MealWithItems entry in plan.meals)
          NexcChoiceOption(
            value: entry,
            label: entry.meal.name,
            description: _formatTime(entry.meal.time),
            icon: NexcIcons.mealsIdle,
          ),
      ],
    );
    if (!mounted || meal == null) return;
    final bool isSnack = meal.meal.name == context.l10n.addSnack;
    await _addItemToMeal(meal.meal.id, consumed: isSnack);
  }

  Future<void> _addItemToMeal(int mealId, {bool consumed = false}) async {
    final List<MealItemPick>? picks = await Navigator.push<List<MealItemPick>>(
      context,
      MaterialPageRoute<List<MealItemPick>>(
        builder: (BuildContext context) => AddMealItemScreen(
          products: ref.read(allProductsProvider).value ?? const <Product>[],
          recipes:
              ref.read(allRecipesProvider).value ??
              const <RecipeWithIngredients>[],
        ),
      ),
    );
    if (picks == null || picks.isEmpty) return;
    final MealRepository repo = ref.read(mealRepositoryProvider);
    for (final MealItemPick pick in picks) {
      await repo.addMealItemToMeal(
        mealId: mealId,
        type: pick.type,
        targetId: pick.targetId,
        amount: pick.amount,
        amountUnit: pick.unit,
        consumed: consumed ? true : null,
      );
    }
  }

  Future<void> _replaceItem(MealItemWithDetails detail) async {
    final List<MealItemPick>? picks = await Navigator.push<List<MealItemPick>>(
      context,
      MaterialPageRoute<List<MealItemPick>>(
        builder: (BuildContext context) => AddMealItemScreen(
          products: ref.read(allProductsProvider).value ?? const <Product>[],
          recipes:
              ref.read(allRecipesProvider).value ??
              const <RecipeWithIngredients>[],
          isReplace: true,
          replaceItemId: detail.mealItem.id,
        ),
      ),
    );
    if (picks == null || picks.isEmpty) return;
    final MealItemPick pick = picks.first;
    await ref
        .read(mealRepositoryProvider)
        .replaceMealItemInMeal(
          oldItemId: detail.mealItem.id,
          newType: pick.type,
          newTargetId: pick.targetId,
          newAmount: pick.amount,
          newAmountUnit: pick.unit,
        );
  }

  Future<void> _logSnack(MealPlanWithMealsAndItems plan) async {
    final DateTime now = DateTime.now();
    final MealRepository repo = ref.read(mealRepositoryProvider);
    final String snackName = context.l10n.addSnack;
    final List<Meal> snacks =
        plan.meals
            .map((MealWithItems entry) => entry.meal)
            .where((Meal meal) => meal.name == snackName)
            .toList()
          ..sort((Meal a, Meal b) => a.position.compareTo(b.position));

    Meal? target;
    if (snacks.isNotEmpty) {
      final Meal latest = snacks.last;
      final int diffMinutes =
          (now.hour * 60 + now.minute) -
          (latest.time.hour * 60 + latest.time.minute);
      if (diffMinutes.abs() <= 30) target = latest;
    }

    final int mealId =
        target?.id ??
        await repo.addMealToPlan(
          mealPlanId: plan.mealPlan.id,
          name: snackName,
          time: LocalTime(now.hour, now.minute),
        );
    if (!mounted) return;
    await _addItemToMeal(mealId, consumed: true);
  }

  Future<void> _editMealDetails(Meal meal) async {
    final ({String name, String notes, bool atHome})? result =
        await _MealDetailsSheet.show(context, meal);
    if (result == null || !mounted) return;
    await ref
        .read(mealRepositoryProvider)
        .updateMeal(
          meal.copyWith(
            name: result.name,
            notes: result.notes,
            atHome: result.atHome,
          ),
        );
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
    if (confirmed != true || !mounted) return;
    final MealRepository repo = ref.read(mealRepositoryProvider);
    await repo.db.delete(repo.db.meals).delete(meal);
  }

  Future<void> _pickMealTime(Meal meal) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: meal.time.hour, minute: meal.time.minute),
    );
    if (picked == null) return;
    await ref
        .read(mealRepositoryProvider)
        .updateMealTime(meal.id, LocalTime(picked.hour, picked.minute));
  }

  Future<void> _editGoals(SettingsState settings) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => EditTodayGoalsDialog(
        currentProt: settings.targetProtein,
        currentCarb: settings.targetCarbs,
        currentFat: settings.targetFats,
        onConfirm: (double protein, double carbs, double fats) {
          ref
              .read(settingsProvider.notifier)
              .setTargetMacros(protein, carbs, fats);
        },
      ),
    );
  }

  Future<void> _discardToday(MealPlanWithMealsAndItems plan) async {
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: context.l10n.discardTodayMeals,
      message: context.l10n.discardTodayMealsMessage,
      confirmLabel: context.l10n.discard,
      cancelLabel: context.l10n.cancel,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    final MealRepository repo = ref.read(mealRepositoryProvider);
    await repo.deleteMealPlan(plan.mealPlan);
    await ref.read(settingsProvider.notifier).restorePrePlanTargetMacros();
  }

  Future<void> _saveToday(MealPlanWithMealsAndItems plan) async {
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: context.l10n.saveTodayMeals,
      message: context.l10n.saveTodayMealsMessage,
      confirmLabel: context.l10n.save,
      cancelLabel: context.l10n.cancel,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(mealRepositoryProvider).saveTodayMeals(plan);
    if (!mounted) return;
    NexcSnack.show(context, context.l10n.todayMealsLogged);
  }

  Future<void> _selectPlan(
    MealPlanWithMealsAndItems plan,
    MealPlanWithMealsAndItems? today,
  ) async {
    if (today != null &&
        today.meals.any((MealWithItems m) => m.items.isNotEmpty)) {
      final bool? proceed = await NexcConfirmSheet.show(
        context: context,
        title: context.l10n.changeMealPlan,
        message: context.l10n.changeMealPlanMessage,
        confirmLabel: context.l10n.proceed,
        cancelLabel: context.l10n.cancel,
      );
      if (proceed != true || !mounted) return;
    }
    await ref.read(mealRepositoryProvider).selectMealPlanForToday(plan);
    final double targetP = plan.mealPlan.targetProtein ?? 0.0;
    final double targetC = plan.mealPlan.targetCarbs ?? 0.0;
    final double targetF = plan.mealPlan.targetFats ?? 0.0;
    final bool isZeroOrNull =
        targetP <= 0.0 && targetC <= 0.0 && targetF <= 0.0;
    final SettingsState settings = ref.read(settingsProvider);
    if (!settings.defaultMacrosOverrideMealPlan && !isZeroOrNull) {
      await ref
          .read(settingsProvider.notifier)
          .overwriteTargetMacrosWithPlan(targetP, targetC, targetF);
    }
  }

  Future<void> _deselectPlan(MealPlanWithMealsAndItems plan) async {
    final MealRepository repo = ref.read(mealRepositoryProvider);
    await repo.deleteMealPlan(plan.mealPlan);
    await ref.read(settingsProvider.notifier).restorePrePlanTargetMacros();
  }

  Future<void> _deletePlan(MealPlanWithMealsAndItems plan) async {
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: context.l10n.deleteMealPlan,
      message: context.l10n.deleteMealPlanConfirm(plan.mealPlan.title),
      confirmLabel: context.l10n.delete,
      cancelLabel: context.l10n.cancel,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(mealRepositoryProvider).deleteMealPlan(plan.mealPlan);
  }

  void _openPlan(MealPlanWithMealsAndItems plan) {
    Navigator.pushNamed(
      context,
      '/meals/track-plan',
      arguments: plan.mealPlan.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final SettingsState settings = ref.watch(settingsProvider);
    final AsyncValue<MealPlanWithMealsAndItems?> todayPlanAsync = ref.watch(
      todayMealPlanProvider,
    );
    final AsyncValue<List<MealPlanWithMealsAndItems>> templatesAsync = ref
        .watch(mealTemplatesProvider);
    final MealPlanWithMealsAndItems? todayPlan = todayPlanAsync.value;
    final bool hasTodayMeals =
        todayPlan != null &&
        todayPlan.meals.any((MealWithItems meal) => meal.items.isNotEmpty);

    return NexcPage(
      title: l10n.tabMeals,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'meals_contextual_fab',
        onPressed: () => _openActionSheet(todayPlan),
        icon: const Icon(NexcIcons.add),
        label: Text(l10n.addAction),
      ),
      bottomBar: _tabIndex == 0 && hasTodayMeals
          ? Row(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => _discardToday(todayPlan),
                  icon: const Icon(NexcIcons.delete, size: 18),
                  label: Text(l10n.discard),
                ),
                const SizedBox(width: NexcSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _saveToday(todayPlan),
                    icon: const Icon(NexcIcons.check, size: 18),
                    label: Text(l10n.save),
                  ),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NexcSpacing.lg,
              vertical: NexcSpacing.xs,
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.todayPlanTab),
                Tab(text: l10n.mealPlansTab),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(todayPlanAsync, settings),
                _buildPlansTab(templatesAsync, todayPlan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab(
    AsyncValue<MealPlanWithMealsAndItems?> todayPlanAsync,
    SettingsState settings,
  ) {
    final l10n = context.l10n;
    if (todayPlanAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (todayPlanAsync.hasError) {
      return Center(
        child: Text(l10n.errorWithMessage('${todayPlanAsync.error}')),
      );
    }
    final MealPlanWithMealsAndItems? plan = todayPlanAsync.value;
    if (plan == null) {
      return ListView(
        padding: const EdgeInsets.all(NexcSpacing.lg),
        children: [
          NexcEmptyState(
            icon: NexcIcons.mealsIdle,
            title: l10n.selectMealPlanForToday,
            actionLabel: l10n.goToMealPlans,
            onAction: () => _tabController.animateTo(1),
          ),
          const SizedBox(height: NexcSpacing.sm),
          Center(
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(mealRepositoryProvider).startEmptyTracking();
              },
              icon: const Icon(NexcIcons.edit, size: 18),
              label: Text(l10n.startLogging),
            ),
          ),
        ],
      );
    }

    final List<MealWithItems> sortedMeals = List<MealWithItems>.from(plan.meals)
      ..sort((MealWithItems a, MealWithItems b) {
        final int aMinutes = DayWindowHelper.getMinutesFromDayStart(
          a.meal.time,
          settings.dayStartHour,
          0,
        );
        final int bMinutes = DayWindowHelper.getMinutesFromDayStart(
          b.meal.time,
          settings.dayStartHour,
          0,
        );
        return aMinutes.compareTo(bMinutes);
      });
    final MacroTotals consumed = MacroTotals.ofPlan(plan, consumedOnly: true);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        NexcSpacing.lg,
        NexcSpacing.md,
        NexcSpacing.lg,
        NexcSpacing.xxl,
      ),
      children: [
        TodayMacroSummaryCard(
          consumed: consumed,
          targetProtein: settings.targetProtein,
          targetCarbs: settings.targetCarbs,
          targetFats: settings.targetFats,
          onEditGoals: () => _editGoals(settings),
        ),
        const SizedBox(height: NexcSpacing.lg),
        if (sortedMeals.isEmpty)
          Center(
            child: OutlinedButton.icon(
              onPressed: () async {
                final DateTime now = DateTime.now();
                await ref
                    .read(mealRepositoryProvider)
                    .addMealToPlan(
                      mealPlanId: plan.mealPlan.id,
                      name: l10n.mealNumber(1),
                      time: LocalTime(now.hour, now.minute),
                    );
              },
              icon: const Icon(NexcIcons.add, size: 18),
              label: Text(l10n.addMeal),
            ),
          )
        else
          for (final MealWithItems meal in sortedMeals) ...[
            MealTrackCard(
              key: ValueKey<int>(meal.meal.id),
              mealWithItems: meal,
              onEditDetails: () => _editMealDetails(meal.meal),
              onDeleteMeal: () => _deleteMeal(meal.meal),
              onTimeTap: () => _pickMealTime(meal.meal),
              onAddItem: () => _addItemToMeal(
                meal.meal.id,
                consumed: meal.meal.name == l10n.addSnack,
              ),
              onReplaceItem: _replaceItem,
            ),
            const SizedBox(height: NexcSpacing.md),
          ],
      ],
    );
  }

  Widget _buildPlansTab(
    AsyncValue<List<MealPlanWithMealsAndItems>> templatesAsync,
    MealPlanWithMealsAndItems? todayPlan,
  ) {
    final l10n = context.l10n;
    if (templatesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (templatesAsync.hasError) {
      return Center(
        child: Text(l10n.errorWithMessage('${templatesAsync.error}')),
      );
    }
    final List<MealPlanWithMealsAndItems> plans =
        List<MealPlanWithMealsAndItems>.from(
          templatesAsync.value ?? const <MealPlanWithMealsAndItems>[],
        )..sort(
          (MealPlanWithMealsAndItems a, MealPlanWithMealsAndItems b) => a
              .mealPlan
              .title
              .toLowerCase()
              .compareTo(b.mealPlan.title.toLowerCase()),
        );
    if (plans.isEmpty) {
      return NexcEmptyState(
        icon: NexcIcons.calendar,
        title: l10n.noMealPlansYet,
        actionLabel: l10n.createMealPlan,
        onAction: () =>
            Navigator.pushNamed(context, '/meals/edit-plan', arguments: 0),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        NexcSpacing.lg,
        NexcSpacing.md,
        NexcSpacing.lg,
        NexcSpacing.xxl + NexcSpacing.section,
      ),
      itemCount: plans.length,
      itemBuilder: (BuildContext context, int index) {
        final MealPlanWithMealsAndItems plan = plans[index];
        final bool isSelected =
            todayPlan != null &&
            (todayPlan.mealPlan.id == plan.mealPlan.id ||
                todayPlan.mealPlan.parentPlanId == plan.mealPlan.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: NexcSpacing.md),
          child: MealPlanCard(
            key: ValueKey<int>(plan.mealPlan.id),
            planWithMeals: plan,
            isSelected: isSelected,
            onOpen: () => _openPlan(plan),
            onSelect: () => _selectPlan(plan, todayPlan),
            onDeselect: () => _deselectPlan(plan),
            onDelete: () => _deletePlan(plan),
          ),
        );
      },
    );
  }

  String _formatTime(LocalTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

/// Hero card for today's macro progress.
class TodayMacroSummaryCard extends StatelessWidget {
  final MacroTotals consumed;
  final double targetProtein;
  final double targetCarbs;
  final double targetFats;
  final VoidCallback onEditGoals;

  const TodayMacroSummaryCard({
    super.key,
    required this.consumed,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFats,
    required this.onEditGoals,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;

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
              children: [
                Expanded(
                  child: Text(
                    l10n.todaysMacros,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.editDailyMacroGoals,
                  onPressed: onEditGoals,
                  icon: const Icon(NexcIcons.edit, size: 20),
                ),
              ],
            ),
            const SizedBox(height: NexcSpacing.sm),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool compact = constraints.maxWidth < 340;
                final Widget ring = NexcMacroRing(
                  protein: consumed.protein,
                  carbs: consumed.carbs,
                  fats: consumed.fats,
                  targetProtein: targetProtein,
                  targetCarbs: targetCarbs,
                  targetFats: targetFats,
                  size: compact ? 108 : 124,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatDecimal(consumed.calories),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        l10n.unitKcal,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
                final Widget bars = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NexcMacroBar(
                      label: l10n.proteinLabel,
                      value: consumed.protein,
                      target: targetProtein,
                      color: NexcMacroColors.protein(scheme),
                    ),
                    NexcMacroBar(
                      label: l10n.carbsLabel,
                      value: consumed.carbs,
                      target: targetCarbs,
                      color: NexcMacroColors.carbs(scheme),
                    ),
                    NexcMacroBar(
                      label: l10n.fatsLabel,
                      value: consumed.fats,
                      target: targetFats,
                      color: NexcMacroColors.fats(scheme),
                    ),
                  ],
                );
                if (compact) {
                  return Column(
                    children: [
                      ring,
                      const SizedBox(height: NexcSpacing.md),
                      bars,
                    ],
                  );
                }
                return Row(
                  children: [
                    ring,
                    const SizedBox(width: NexcSpacing.lg),
                    Expanded(child: bars),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsible meal card used by the today tab.
class MealTrackCard extends ConsumerStatefulWidget {
  final MealWithItems mealWithItems;
  final VoidCallback onEditDetails;
  final VoidCallback onDeleteMeal;
  final VoidCallback onTimeTap;
  final VoidCallback onAddItem;
  final Future<void> Function(MealItemWithDetails detail) onReplaceItem;

  const MealTrackCard({
    super.key,
    required this.mealWithItems,
    required this.onEditDetails,
    required this.onDeleteMeal,
    required this.onTimeTap,
    required this.onAddItem,
    required this.onReplaceItem,
  });

  @override
  ConsumerState<MealTrackCard> createState() => _MealTrackCardState();
}

class _MealTrackCardState extends ConsumerState<MealTrackCard> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  Meal get _meal => widget.mealWithItems.meal;

  String get _timeLabel =>
      '${_meal.time.hour.toString().padLeft(2, '0')}:'
      '${_meal.time.minute.toString().padLeft(2, '0')}';

  Future<void> _toggleItem(MealItem item) async {
    await ref
        .read(mealRepositoryProvider)
        .updateMealItem(item.copyWith(consumed: !item.consumed));
  }

  Future<void> _editAmount(MealItemWithDetails detail) async {
    final ({double amount, AmountUnit unit})? result =
        await showMealItemQuantitySheet(
          context: context,
          initialAmount: detail.mealItem.amount,
          initialUnit: detail.mealItem.amountUnit,
          product: detail.product,
          isRecipe: detail.mealItem.type == MealItemType.RECIPE,
        );
    if (result == null || !mounted) return;
    await ref
        .read(mealRepositoryProvider)
        .updateMealItem(
          detail.mealItem.copyWith(
            amount: result.amount,
            amountUnit: result.unit,
          ),
        );
  }

  Future<void> _deleteItem(MealItemWithDetails detail) async {
    final String name = detail.mealItem.type == MealItemType.PRODUCT
        ? (detail.product?.name ?? context.l10n.unknownProduct)
        : (detail.recipe?.recipe.name ?? context.l10n.unknownRecipe);
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: context.l10n.delete,
      message: context.l10n.deleteMealConfirm(name),
      confirmLabel: context.l10n.delete,
      cancelLabel: context.l10n.cancel,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(mealRepositoryProvider).deleteMealItem(detail.mealItem);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;
    final MacroTotals totals = MacroTotals.ofMeal(widget.mealWithItems);
    final int eaten = widget.mealWithItems.items
        .where((MealItemWithDetails item) => item.mealItem.consumed)
        .length;
    final int totalItems = widget.mealWithItems.items.length;
    final bool portable = widget.mealWithItems.isMealPortable;

    return Material(
      color: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.lgRadius),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(NexcSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: widget.onTimeTap,
                              borderRadius: NexcShapes.xsRadius,
                              child: Text(
                                _timeLabel,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: NexcSpacing.sm),
                            Expanded(
                              child: Text(
                                _meal.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: NexcSpacing.xs),
                        NexcMacroChips(
                          protein: totals.protein,
                          carbs: totals.carbs,
                          fats: totals.fats,
                          showCalories: totals.calories > 0,
                          calories: totals.calories,
                        ),
                        const SizedBox(height: NexcSpacing.xs),
                        Wrap(
                          spacing: NexcSpacing.xs,
                          runSpacing: NexcSpacing.xs,
                          children: [
                            if (portable)
                              NexcBadge(
                                l10n.portable,
                                tone: NexcBadgeTone.success,
                                icon: NexcIcons.check,
                              )
                            else
                              NexcBadge(
                                l10n.homeOnly,
                                tone: NexcBadgeTone.warning,
                                icon: NexcIcons.warning,
                              ),
                            NexcBadge(
                              _meal.atHome ? l10n.atHome : l10n.outside,
                              tone: NexcBadgeTone.neutral,
                              icon: _meal.atHome
                                  ? Icons.home_outlined
                                  : Icons.restaurant_outlined,
                            ),
                          ],
                        ),
                        if (totalItems > 0) ...[
                          const SizedBox(height: NexcSpacing.xs),
                          Text(
                            l10n.progressItemsEaten(eaten, totalItems),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<_MealMenuAction>(
                    tooltip: l10n.moreOptions,
                    icon: const Icon(NexcIcons.more),
                    onSelected: (_MealMenuAction action) {
                      switch (action) {
                        case _MealMenuAction.editDetails:
                          widget.onEditDetails();
                        case _MealMenuAction.deleteMeal:
                          widget.onDeleteMeal();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<_MealMenuAction>(
                        value: _MealMenuAction.editDetails,
                        child: Row(
                          children: [
                            const Icon(NexcIcons.edit, size: 20),
                            const SizedBox(width: NexcSpacing.md),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem<_MealMenuAction>(
                        value: _MealMenuAction.deleteMeal,
                        child: Row(
                          children: [
                            Icon(
                              NexcIcons.delete,
                              size: 20,
                              color: scheme.error,
                            ),
                            const SizedBox(width: NexcSpacing.md),
                            Text(
                              l10n.deleteMeal,
                              style: TextStyle(color: scheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: NexcSpacing.md),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: NexcMotion.short,
                      child: const Icon(NexcIcons.expand),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NexcSpacing.lg,
                0,
                NexcSpacing.lg,
                NexcSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(),
                  if (widget.mealWithItems.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: NexcSpacing.md,
                      ),
                      child: Text(
                        l10n.addItemToMealLower,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    for (final MealItemWithDetails detail
                        in widget.mealWithItems.items)
                      _MealItemRow(
                        detail: detail,
                        onToggle: () => _toggleItem(detail.mealItem),
                        onEditAmount: () => _editAmount(detail),
                        onReplace: () => widget.onReplaceItem(detail),
                        onDelete: () => _deleteItem(detail),
                      ),
                  const SizedBox(height: NexcSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: widget.onAddItem,
                      icon: const Icon(NexcIcons.add, size: 18),
                      label: Text(l10n.addItemToMealLower),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum _ItemMenuAction { replace, delete }

class _MealItemRow extends StatelessWidget {
  final MealItemWithDetails detail;
  final VoidCallback onToggle;
  final VoidCallback onEditAmount;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  const _MealItemRow({
    required this.detail,
    required this.onToggle,
    required this.onEditAmount,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;
    final String name = detail.mealItem.type == MealItemType.PRODUCT
        ? (detail.product?.name ?? l10n.unknownProduct)
        : (detail.recipe?.recipe.name ?? l10n.unknownRecipe);
    final MacroTotals macros = MacroTotals.ofItem(detail);
    final String unit = mealItemUnitLabel(
      context,
      detail.mealItem,
      detail.product,
    );
    final String subtitle =
        detail.mealItem.amountUnit == AmountUnit.UNITS && detail.product != null
        ? l10n.edibleEquivalent(
            formatDecimal(
              detail.mealItem.amount * getEdibleWeightPerUnit(detail.product!),
            ),
          )
        : l10n.macrosCompact(
            formatDecimal(macros.protein),
            formatDecimal(macros.carbs),
            formatDecimal(macros.fats),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NexcSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: detail.mealItem.consumed,
            onChanged: (_) => onToggle(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: NexcSpacing.xs),
          Tooltip(
            message: l10n.portionAmount,
            child: TextButton(
              onPressed: onEditAmount,
              child: Text(
                '${formatDecimal(detail.mealItem.amount)} $unit',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          PopupMenuButton<_ItemMenuAction>(
            tooltip: l10n.moreOptions,
            icon: const Icon(NexcIcons.more, size: 20),
            onSelected: (_ItemMenuAction action) {
              switch (action) {
                case _ItemMenuAction.replace:
                  onReplace();
                case _ItemMenuAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<_ItemMenuAction>(
                value: _ItemMenuAction.replace,
                child: Row(
                  children: [
                    const Icon(NexcIcons.edit, size: 20),
                    const SizedBox(width: NexcSpacing.md),
                    Text(l10n.replaceAction),
                  ],
                ),
              ),
              PopupMenuItem<_ItemMenuAction>(
                value: _ItemMenuAction.delete,
                child: Row(
                  children: [
                    Icon(NexcIcons.delete, size: 20, color: scheme.error),
                    const SizedBox(width: NexcSpacing.md),
                    Text(l10n.delete, style: TextStyle(color: scheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Plan card for the plans tab.
class MealPlanCard extends StatelessWidget {
  final MealPlanWithMealsAndItems planWithMeals;
  final bool isSelected;
  final VoidCallback onOpen;
  final VoidCallback onSelect;
  final VoidCallback onDeselect;
  final VoidCallback onDelete;

  const MealPlanCard({
    super.key,
    required this.planWithMeals,
    required this.isSelected,
    required this.onOpen,
    required this.onSelect,
    required this.onDeselect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;
    final MealPlan plan = planWithMeals.mealPlan;
    final MacroTotals totals = MacroTotals.ofPlan(planWithMeals);
    final ({int consumed, int total}) counts = MacroTotals.itemCount(
      planWithMeals,
    );

    return Material(
      color: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.lgRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(NexcSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (plan.notes.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            plan.notes,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: NexcSpacing.sm),
                    NexcBadge(
                      l10n.selectedLabel,
                      tone: NexcBadgeTone.info,
                      icon: NexcIcons.check,
                    ),
                  ],
                  PopupMenuButton<_PlanMenuAction>(
                    tooltip: l10n.moreOptions,
                    icon: const Icon(NexcIcons.more),
                    onSelected: (_PlanMenuAction action) {
                      switch (action) {
                        case _PlanMenuAction.select:
                          onSelect();
                        case _PlanMenuAction.deselect:
                          onDeselect();
                        case _PlanMenuAction.delete:
                          onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<_PlanMenuAction>(
                        value: isSelected
                            ? _PlanMenuAction.deselect
                            : _PlanMenuAction.select,
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? NexcIcons.close : NexcIcons.play,
                              size: 20,
                            ),
                            const SizedBox(width: NexcSpacing.md),
                            Text(isSelected ? l10n.remove : l10n.selectLabel),
                          ],
                        ),
                      ),
                      PopupMenuItem<_PlanMenuAction>(
                        value: _PlanMenuAction.delete,
                        child: Row(
                          children: [
                            Icon(
                              NexcIcons.delete,
                              size: 20,
                              color: scheme.error,
                            ),
                            const SizedBox(width: NexcSpacing.md),
                            Text(
                              l10n.deleteMealPlan,
                              style: TextStyle(color: scheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: NexcSpacing.sm),
              NexcMacroChips(
                protein: totals.protein,
                carbs: totals.carbs,
                fats: totals.fats,
                showCalories: totals.calories > 0,
                calories: totals.calories,
              ),
              if (planWithMeals.meals.isNotEmpty) ...[
                const SizedBox(height: NexcSpacing.xs),
                Text(
                  l10n.scheduledMeals(
                    planWithMeals.meals.length,
                    planWithMeals.meals
                        .map((MealWithItems meal) => meal.meal.name)
                        .join(', '),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: NexcSpacing.xs),
                Text(
                  l10n.progressItemsEaten(counts.consumed, counts.total),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (!isSelected) ...[
                const SizedBox(height: NexcSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: onSelect,
                    icon: const Icon(NexcIcons.play, size: 18),
                    label: Text(l10n.selectLabel),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Edit name, notes and location of a meal.
class _MealDetailsSheet extends StatefulWidget {
  final Meal meal;

  const _MealDetailsSheet({required this.meal});

  static Future<({String name, String notes, bool atHome})?> show(
    BuildContext context,
    Meal meal,
  ) {
    return showModalBottomSheet<({String name, String notes, bool atHome})>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => _MealDetailsSheet(meal: meal),
    );
  }

  @override
  State<_MealDetailsSheet> createState() => _MealDetailsSheetState();
}

class _MealDetailsSheetState extends State<_MealDetailsSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.meal.name,
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.meal.notes,
  );
  late bool _atHome = widget.meal.atHome;

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, (
      name: name,
      notes: _notes.text.trim(),
      atHome: _atHome,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NexcSpacing.xl,
        NexcSpacing.sm,
        NexcSpacing.xl,
        NexcSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.edit, style: theme.textTheme.headlineSmall),
          const SizedBox(height: NexcSpacing.lg),
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.nameLabel),
          ),
          const SizedBox(height: NexcSpacing.md),
          TextField(
            controller: _notes,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.notes,
              hintText: l10n.addNoteHint,
            ),
          ),
          const SizedBox(height: NexcSpacing.sm),
          NexcTile.toggle(
            title: _atHome ? l10n.atHome : l10n.outside,
            value: _atHome,
            onChanged: (bool value) => setState(() => _atHome = value),
            icon: _atHome ? Icons.home_outlined : Icons.restaurant_outlined,
          ),
          const SizedBox(height: NexcSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: NexcSpacing.sm),
              FilledButton(onPressed: _submit, child: Text(l10n.save)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Daily macro goal editor, shared by the today card.
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
  late final TextEditingController _protein = TextEditingController(
    text: formatDecimal(widget.currentProt),
  );
  late final TextEditingController _carbs = TextEditingController(
    text: formatDecimal(widget.currentCarb),
  );
  late final TextEditingController _fats = TextEditingController(
    text: formatDecimal(widget.currentFat),
  );

  @override
  void dispose() {
    _protein.dispose();
    _carbs.dispose();
    _fats.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editDailyMacroGoals),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _protein,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.proteinG),
            ),
            const SizedBox(height: NexcSpacing.md),
            TextField(
              controller: _carbs,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.carbsG),
            ),
            const SizedBox(height: NexcSpacing.md),
            TextField(
              controller: _fats,
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
        FilledButton(
          onPressed: () {
            final double protein =
                double.tryParse(_protein.text) ?? widget.currentProt;
            final double carbs =
                double.tryParse(_carbs.text) ?? widget.currentCarb;
            final double fats =
                double.tryParse(_fats.text) ?? widget.currentFat;
            widget.onConfirm(protein, carbs, fats);
            Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
