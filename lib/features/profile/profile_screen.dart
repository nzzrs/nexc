/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/nexc_action_grid.dart';
import '../../core/components/nexc_chart_card.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_history_tile.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_segmented.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/macro_totals.dart';
import '../../core/util/unit_system.dart';

/// Converts a volume chart point from kilograms to the selected unit.
///
/// Duration and reps points are unaffected, and metric points are returned
/// untouched so canonical values never drift.
Point convertChartPointToUnit(
  Point point,
  WorkoutChart mode,
  UnitSystem system,
) {
  if (mode != WorkoutChart.volume || system == UnitSystem.metric) {
    return point;
  }
  return Point(
    yValues: point.yValues
        .map((double value) => fromKilograms(value, system))
        .toList(),
    xValue: point.xValue,
    workoutId: point.workoutId,
  );
}

/// Profile tab: hub of every secondary area plus recent activity.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _push(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final int weekStreak = ref.watch(profileWeekStreakProvider);
    final AsyncValue<List<WorkoutWithExercisesAndSets>> workoutsAsync = ref
        .watch(completedWorkoutsProvider);
    final AsyncValue<List<MealPlanWithMealsAndItems>> mealLogsAsync = ref.watch(
      profileMealLogsProvider,
    );
    final AsyncValue<List<Point>> pointsAsync = ref.watch(
      profilePointsProvider,
    );
    final WorkoutChart chartMode = ref.watch(workoutChartModeProvider);
    final SettingsState settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.only(
        top: NexcSpacing.md,
        bottom: NexcSpacing.xl,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
          child: StreakCard(weekStreak: weekStreak),
        ),
        const SizedBox(height: NexcSpacing.xl),
        NexcSection(
          title: l10n.sectionProgress,
          padded: true,
          children: [
            NexcActionGrid(
              items: [
                NexcActionItem(
                  icon: NexcIcons.statistics,
                  label: l10n.statisticsMenu,
                  onTap: () => _push(context, '/profile/statistics'),
                ),
                NexcActionItem(
                  icon: NexcIcons.calendar,
                  label: l10n.calendarTitle,
                  onTap: () => _push(context, '/calendar'),
                ),
                NexcActionItem(
                  icon: NexcIcons.workoutHistory,
                  label: l10n.workoutHistoryTitle,
                  onTap: () => _push(context, '/profile/all-workouts'),
                ),
                NexcActionItem(
                  icon: NexcIcons.mealHistory,
                  label: l10n.mealHistoryTitle,
                  onTap: () => _push(context, '/profile/all-meals'),
                ),
              ],
            ),
          ],
        ),
        NexcSection(
          title: l10n.sectionBody,
          padded: true,
          children: [
            NexcActionGrid(
              items: [
                NexcActionItem(
                  icon: NexcIcons.measurements,
                  label: l10n.measurementsMenu,
                  onTap: () => _push(context, '/profile/measurements'),
                ),
                NexcActionItem(
                  icon: NexcIcons.personalInfo,
                  label: l10n.personalInfo,
                  onTap: () => _push(context, '/profile/personal-info'),
                ),
              ],
            ),
          ],
        ),
        NexcSection(
          title: l10n.sectionLibrary,
          padded: true,
          children: [
            NexcActionGrid(
              items: [
                NexcActionItem(
                  icon: NexcIcons.exercises,
                  label: l10n.exercisesLabel,
                  onTap: () => _push(context, '/exercises', arguments: false),
                ),
                NexcActionItem(
                  icon: NexcIcons.products,
                  label: l10n.productsTab,
                  onTap: () => _push(context, '/meals/products'),
                ),
                NexcActionItem(
                  icon: NexcIcons.recipes,
                  label: l10n.recipesTab,
                  onTap: () => _push(context, '/meals/recipes'),
                ),
              ],
            ),
          ],
        ),
        if (settings.enableStockTracking)
          NexcSection(
            title: l10n.sectionInventory,
            padded: true,
            children: [
              NexcActionGrid(
                items: [
                  NexcActionItem(
                    icon: NexcIcons.stock,
                    label: l10n.stockTitle,
                    onTap: () => _push(context, '/profile/stock'),
                  ),
                ],
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
          child: pointsAsync.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stack) => Text(
              l10n.errorLoadingChart('$error'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            data: (List<Point> points) {
              final int decimalCount = chartMode == WorkoutChart.duration
                  ? 0
                  : 2;
              final String suffix = chartMode == WorkoutChart.volume
                  ? settings.unitSystem.suffix
                  : '';
              final List<Point> displayPoints = points
                  .map(
                    (Point point) => convertChartPointToUnit(
                      point,
                      chartMode,
                      settings.unitSystem,
                    ),
                  )
                  .toList();
              return NexcCartesianChart(
                points: displayPoints,
                decimalCount: decimalCount,
                suffix: suffix,
                chartMode: chartMode,
                updateChartMode: (WorkoutChart mode) {
                  ref.read(workoutChartModeProvider.notifier).state = mode;
                },
                onEntrySelection: (int workoutId) {
                  _push(context, '/info-workout', arguments: workoutId);
                },
              );
            },
          ),
        ),
        const SizedBox(height: NexcSpacing.xl),
        _RecentHeader(
          title: l10n.yourWorkouts,
          onViewAll: () => _push(context, '/profile/all-workouts'),
        ),
        const SizedBox(height: NexcSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
          child: workoutsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(NexcSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (Object error, StackTrace stack) => Text(
              l10n.errorWithMessage('$error'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            data: (List<WorkoutWithExercisesAndSets> workouts) {
              if (workouts.isEmpty) {
                return NexcEmptyState(
                  icon: NexcIcons.workoutIdle,
                  title: l10n.emptyHistoryTitle,
                  message: l10n.startCompletingWorkouts,
                );
              }
              return Column(
                children: [
                  for (final WorkoutWithExercisesAndSets item in workouts.take(
                    3,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(bottom: NexcSpacing.sm),
                      child: NexcHistoryTile(
                        icon: NexcIcons.workout,
                        title: item.workout.title,
                        meta: [
                          l10n.finishedOnDuration(
                            context.formatShortDate(item.workout.completed),
                            formatDurationShort(item.workout.timeElapsed),
                          ),
                        ],
                        onTap: () => _push(
                          context,
                          '/info-workout',
                          arguments: item.workout.id,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (settings.enableMealTracking) ...[
          const SizedBox(height: NexcSpacing.lg),
          _RecentHeader(
            title: l10n.yourMeals,
            onViewAll: () => _push(context, '/profile/all-meals'),
          ),
          const SizedBox(height: NexcSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
            child: mealLogsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(NexcSpacing.lg),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (Object error, StackTrace stack) => Text(
                l10n.errorWithMessage('$error'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              data: (List<MealPlanWithMealsAndItems> logs) {
                if (logs.isEmpty) {
                  return NexcEmptyState(
                    icon: NexcIcons.mealsIdle,
                    title: l10n.emptyHistoryTitle,
                    message: l10n.noMealLogHistory,
                  );
                }
                return Column(
                  children: [
                    for (final MealPlanWithMealsAndItems log in logs.take(3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: NexcSpacing.sm),
                        child: _MealHistoryTile(
                          log: log,
                          onDelete: () async {
                            final bool? confirmed = await NexcConfirmSheet.show(
                              context: context,
                              title: l10n.deleteMealLog,
                              message: l10n.deleteMealLogConfirm,
                              confirmLabel: l10n.delete,
                              cancelLabel: l10n.cancel,
                              destructive: true,
                            );
                            if (confirmed != true) return;
                            await ref
                                .read(mealRepositoryProvider)
                                .deleteMealPlan(log.mealPlan);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Streak summary with a plain tonal surface; no glow or tap animation.
class StreakCard extends StatelessWidget {
  final int weekStreak;

  const StreakCard({super.key, required this.weekStreak});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return Material(
      color: theme.colorScheme.secondaryContainer,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.lgRadius),
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.lg),
        child: Row(
          children: [
            Icon(
              NexcIcons.streak,
              size: 32,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: NexcSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.weekStreak(weekStreak),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.keepMoving,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _RecentHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onViewAll, child: Text(context.l10n.viewAll)),
        ],
      ),
    );
  }
}

class _MealHistoryTile extends StatelessWidget {
  final MealPlanWithMealsAndItems log;
  final Future<void> Function() onDelete;

  const _MealHistoryTile({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final MealPlan plan = log.mealPlan;
    final MacroTotals totals = MacroTotals.ofPlan(log, consumedOnly: true);
    final ({int consumed, int total}) count = MacroTotals.itemCount(log);
    final String eatenAt =
        '${context.formatShortDate(plan.created)} · '
        '${context.formatTimeOfDay(TimeOfDay.fromDateTime(plan.created))}';

    return NexcHistoryTile(
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
      onDelete: () => onDelete(),
      deleteLabel: l10n.deleteMealLog,
    );
  }
}

/// One row of a [NexcGroupedHistoryList].
class NexcHistoryEntry {
  final DateTime date;
  final IconData icon;
  final String title;
  final List<String> meta;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? deleteLabel;

  const NexcHistoryEntry({
    required this.date,
    required this.icon,
    required this.title,
    this.meta = const [],
    this.onTap,
    this.onDelete,
    this.deleteLabel,
  });
}

/// Month-grouped history list shared by the workout and meal history screens.
class NexcGroupedHistoryList extends StatelessWidget {
  final List<NexcHistoryEntry> entries;

  const NexcGroupedHistoryList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> rows = <Widget>[];
    int? lastYear;
    int? lastMonth;

    for (final NexcHistoryEntry entry in entries) {
      final bool newMonth =
          entry.date.year != lastYear || entry.date.month != lastMonth;
      if (newMonth) {
        lastYear = entry.date.year;
        lastMonth = entry.date.month;
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NexcSpacing.lg,
              NexcSpacing.lg,
              NexcSpacing.lg,
              NexcSpacing.sm,
            ),
            child: Text(
              context.formatMonthYear(entry.date),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NexcSpacing.lg,
            0,
            NexcSpacing.lg,
            NexcSpacing.sm,
          ),
          child: NexcHistoryTile(
            icon: entry.icon,
            title: entry.title,
            meta: entry.meta,
            onTap: entry.onTap,
            onDelete: entry.onDelete,
            deleteLabel: entry.deleteLabel,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: NexcSpacing.xl),
      children: rows,
    );
  }
}

/// Bar chart card for workout duration, volume and reps.
class NexcCartesianChart extends StatelessWidget {
  final List<Point> points;
  final int decimalCount;
  final String? suffix;
  final WorkoutChart chartMode;
  final void Function(WorkoutChart) updateChartMode;
  final void Function(int) onEntrySelection;

  const NexcCartesianChart({
    super.key,
    required this.points,
    required this.decimalCount,
    required this.suffix,
    required this.chartMode,
    required this.updateChartMode,
    required this.onEntrySelection,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;

    return NexcChartCard(
      title: l10n.workoutPerformance,
      emptyMessage: points.isEmpty ? l10n.noDataYet : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: NexcSegmented<WorkoutChart>(
              selected: chartMode,
              onChanged: updateChartMode,
              segments: [
                (
                  value: WorkoutChart.duration,
                  label: l10n.durationLabel,
                  icon: null,
                ),
                (
                  value: WorkoutChart.volume,
                  label: l10n.volumeLabel,
                  icon: null,
                ),
                (value: WorkoutChart.reps, label: l10n.repsLabel, icon: null),
              ],
            ),
          ),
          const SizedBox(height: NexcSpacing.lg),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: points.asMap().entries.map((
                  MapEntry<int, Point> entry,
                ) {
                  final int idx = entry.key;
                  final Point pt = entry.value;
                  final double yVal = pt.yValues.firstOrNull ?? 0.0;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: yVal,
                        color: theme.colorScheme.primary,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(NexcShapes.xs),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (double val, TitleMeta meta) {
                        return Text(
                          val.toStringAsFixed(decimalCount) + (suffix ?? ''),
                          style: theme.textTheme.labelSmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double val, TitleMeta meta) {
                        final int idx = val.toInt();
                        if (idx >= 0 && idx < points.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              points[idx].xValue,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchCallback:
                      (FlTouchEvent event, BarTouchResponse? response) {
                        if (event is FlTapUpEvent &&
                            response != null &&
                            response.spot != null) {
                          final int idx = response.spot!.touchedBarGroupIndex;
                          if (idx >= 0 && idx < points.length) {
                            final int? workoutId = points[idx].workoutId;
                            if (workoutId != null) onEntrySelection(workoutId);
                          }
                        }
                      },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
