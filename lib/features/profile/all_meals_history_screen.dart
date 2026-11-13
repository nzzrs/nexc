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

import '../../core/components/nexc_async_view.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_page.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/util/format.dart';
import '../../core/util/macro_totals.dart';
import 'profile_screen.dart';

class AllMealsHistoryScreen extends ConsumerWidget {
  const AllMealsHistoryScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MealPlanWithMealsAndItems log,
  ) async {
    final l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: l10n.deleteMealLog,
      message: l10n.deleteMealLogConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed != true) return;
    await ref.read(mealRepositoryProvider).deleteMealPlan(log.mealPlan);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final AsyncValue<List<MealPlanWithMealsAndItems>> mealLogsAsync = ref.watch(
      profileMealLogsProvider,
    );

    return NexcPage(
      title: l10n.allMealsTitle,
      body: NexcAsyncView<List<MealPlanWithMealsAndItems>>(
        value: mealLogsAsync,
        isEmpty: (List<MealPlanWithMealsAndItems> logs) => logs.isEmpty,
        empty: NexcEmptyState(
          icon: NexcIcons.mealHistory,
          title: l10n.emptyHistoryTitle,
          message: l10n.noMealLogHistory,
        ),
        errorTitle: (Object error) => l10n.errorWithMessage('$error'),
        builder: (List<MealPlanWithMealsAndItems> logs) {
          return NexcGroupedHistoryList(
            entries: [
              for (final MealPlanWithMealsAndItems log in logs)
                _entry(context, ref, log),
            ],
          );
        },
      ),
    );
  }

  NexcHistoryEntry _entry(
    BuildContext context,
    WidgetRef ref,
    MealPlanWithMealsAndItems log,
  ) {
    final l10n = context.l10n;
    final MealPlan plan = log.mealPlan;
    final MacroTotals totals = MacroTotals.ofPlan(log, consumedOnly: true);
    final ({int consumed, int total}) count = MacroTotals.itemCount(log);
    final String eatenAt =
        '${context.formatShortDate(plan.created)} · '
        '${context.formatTimeOfDay(TimeOfDay.fromDateTime(plan.created))}';

    return NexcHistoryEntry(
      date: plan.created,
      icon: NexcIcons.mealHistory,
      title: plan.title,
      meta: [
        l10n.eatenOn(eatenAt),
        l10n.progressItemsEaten(count.consumed, count.total),
        l10n.macrosPrefixLine(
          formatDecimal(totals.protein, maxDecimals: 1),
          formatDecimal(totals.carbs, maxDecimals: 1),
          formatDecimal(totals.fats, maxDecimals: 1),
        ),
      ],
      onTap: () {
        Navigator.pushNamed(context, '/meals/track-plan', arguments: plan.id);
      },
      onDelete: () => _delete(context, ref, log),
      deleteLabel: l10n.deleteMealLog,
    );
  }
}
