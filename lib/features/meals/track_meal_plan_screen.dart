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

import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_macro.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/db/enums.dart';
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

class TrackMealPlanScreen extends ConsumerWidget {
  final int mealPlanId;

  const TrackMealPlanScreen({super.key, required this.mealPlanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<MealPlanWithMealsAndItems?> planAsync = ref.watch(
      mealPlanStreamProvider(mealPlanId),
    );

    return planAsync.when(
      loading: () => NexcPage(
        title: l10n.mealPlanDetails,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stack) => NexcPage(
        title: l10n.mealPlanDetails,
        body: Center(child: Text(l10n.errorWithMessage('$error'))),
      ),
      data: (MealPlanWithMealsAndItems? plan) {
        if (plan == null) {
          return NexcPage(
            title: l10n.mealPlanDetails,
            body: NexcEmptyState(
              icon: NexcIcons.warning,
              title: l10n.mealPlanNotFound,
            ),
          );
        }
        return _TrackPlanView(plan: plan);
      },
    );
  }
}

class _TrackPlanView extends StatelessWidget {
  final MealPlanWithMealsAndItems plan;

  const _TrackPlanView({required this.plan});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;
    final MacroTotals planned = MacroTotals.ofPlan(plan);
    final MacroTotals consumed = MacroTotals.ofPlan(plan, consumedOnly: true);
    final ({int consumed, int total}) counts = MacroTotals.itemCount(plan);
    final double targetProtein = (plan.mealPlan.targetProtein ?? 0) > 0
        ? plan.mealPlan.targetProtein!
        : planned.protein;
    final double targetCarbs = (plan.mealPlan.targetCarbs ?? 0) > 0
        ? plan.mealPlan.targetCarbs!
        : planned.carbs;
    final double targetFats = (plan.mealPlan.targetFats ?? 0) > 0
        ? plan.mealPlan.targetFats!
        : planned.fats;

    return NexcPage(
      title: plan.mealPlan.title,
      subtitle: plan.meals.isEmpty
          ? l10n.mealPlanDetails
          : l10n.progressItemsEaten(counts.consumed, counts.total),
      bottomBar: FilledButton.icon(
        onPressed: () => Navigator.pushNamed(
          context,
          '/meals/edit-plan',
          arguments: plan.mealPlan.id,
        ),
        icon: const Icon(NexcIcons.edit, size: 18),
        label: Text(l10n.edit),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          NexcSpacing.lg,
          NexcSpacing.md,
          NexcSpacing.lg,
          NexcSpacing.xxl,
        ),
        children: [
          if (plan.mealPlan.notes.isNotEmpty) ...[
            Text(
              plan.mealPlan.notes,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: NexcSpacing.md),
          ],
          NexcSection(
            title: l10n.targetMacros,
            padded: true,
            spaced: false,
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
          ),
          const SizedBox(height: NexcSpacing.lg),
          if (plan.meals.isEmpty)
            NexcEmptyState(
              icon: NexcIcons.mealsIdle,
              title: l10n.emptyHistoryTitle,
              message: l10n.emptyHistoryMessage,
            )
          else
            for (final MealWithItems meal in plan.meals) ...[
              _TrackMealCard(mealWithItems: meal),
              const SizedBox(height: NexcSpacing.md),
            ],
        ],
      ),
    );
  }
}

class _TrackMealCard extends StatelessWidget {
  final MealWithItems mealWithItems;

  const _TrackMealCard({required this.mealWithItems});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Meal meal = mealWithItems.meal;
    final MacroTotals totals = MacroTotals.ofMeal(mealWithItems);
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
                Text(
                  timeLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: NexcSpacing.sm),
                Expanded(
                  child: Text(
                    meal.name,
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
            if (mealWithItems.items.isNotEmpty) ...[
              const Divider(height: NexcSpacing.xl),
              for (final MealItemWithDetails detail in mealWithItems.items)
                _TrackItemRow(detail: detail),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackItemRow extends StatelessWidget {
  final MealItemWithDetails detail;

  const _TrackItemRow({required this.detail});

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
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: NexcSpacing.sm),
          Text(
            '${formatDecimal(detail.mealItem.amount)} $unit',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
