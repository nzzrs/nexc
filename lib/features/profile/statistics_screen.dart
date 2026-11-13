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

import '../../core/components/body_heatmap.dart';
import '../../core/components/nexc_badge.dart';
import '../../core/components/nexc_chart_card.dart';
import '../../core/components/nexc_macro.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_stat_tile.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/macro_totals.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final AsyncValue<List<WorkoutWithExercisesAndSets>> workoutsAsync = ref
        .watch(completedWorkoutsProvider);
    final AsyncValue<List<MealPlanWithMealsAndItems>> mealLogsAsync = ref.watch(
      profileMealLogsProvider,
    );

    return NexcPage(
      title: l10n.statisticsTitle,
      body: ListView(
        padding: const EdgeInsets.only(
          top: NexcSpacing.sm,
          bottom: NexcSpacing.xl,
        ),
        children: [
          workoutsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(NexcSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (Object error, StackTrace stack) => Padding(
              padding: const EdgeInsets.all(NexcSpacing.lg),
              child: Text(
                l10n.errorLoadingWorkouts('$error'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            data: (List<WorkoutWithExercisesAndSets> workouts) =>
                _WorkoutMetrics(workouts: workouts),
          ),
          mealLogsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (Object error, StackTrace stack) => Padding(
              padding: const EdgeInsets.all(NexcSpacing.lg),
              child: Text(
                l10n.errorLoadingNutrition('$error'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            data: (List<MealPlanWithMealsAndItems> logs) {
              if (logs.isEmpty) return const SizedBox.shrink();
              return _NutritionMetrics(logs: logs);
            },
          ),
        ],
      ),
    );
  }
}

class _WorkoutMetrics extends StatelessWidget {
  final List<WorkoutWithExercisesAndSets> workouts;

  const _WorkoutMetrics({required this.workouts});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final int totalWorkouts = workouts.length;
    int totalSeconds = 0;
    final Map<Muscle, int> muscleTargetCounts = <Muscle, int>{};

    for (final WorkoutWithExercisesAndSets workout in workouts) {
      totalSeconds += workout.workout.timeElapsed;
      for (final ExerciseWithSets exercise in workout.exercisesWithSets) {
        for (final Muscle muscle in exercise.exerciseDC.primaryMuscles) {
          muscleTargetCounts[muscle] = (muscleTargetCounts[muscle] ?? 0) + 1;
        }
      }
    }

    final int totalMinutes = totalSeconds ~/ 60;
    final double averageMinutes = totalWorkouts > 0
        ? totalSeconds / 60 / totalWorkouts
        : 0;
    final String averageDuration = formatDecimal(
      averageMinutes,
      maxDecimals: 1,
    );

    final List<MapEntry<Muscle, int>> sortedMuscles =
        muscleTargetCounts.entries.toList()..sort(
          (MapEntry<Muscle, int> a, MapEntry<Muscle, int> b) =>
              b.value.compareTo(a.value),
        );
    final int maxCount = sortedMuscles.isEmpty ? 0 : sortedMuscles.first.value;
    final Map<Muscle, double> intensities = <Muscle, double>{
      for (final MapEntry<Muscle, int> entry in muscleTargetCounts.entries)
        entry.key: maxCount > 0 ? entry.value / maxCount : 0.0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NexcSection(
          title: l10n.workoutMetrics,
          children: [
            Padding(
              padding: const EdgeInsets.all(NexcSpacing.lg),
              child: Column(
                children: [
                  NexcStatTile(
                    label: l10n.totalWorkouts,
                    value: formatCount(totalWorkouts),
                    icon: NexcIcons.workout,
                    tone: NexcBadgeTone.info,
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  NexcStatTile(
                    label: l10n.totalActiveTime,
                    value: l10n.minutesValue(formatCount(totalMinutes)),
                    icon: NexcIcons.timer,
                    tone: NexcBadgeTone.info,
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  NexcStatTile(
                    label: l10n.averageSession,
                    value: l10n.minutesValue(averageDuration),
                    icon: NexcIcons.overview,
                    tone: NexcBadgeTone.info,
                  ),
                ],
              ),
            ),
          ],
        ),
        NexcSection(
          title: l10n.targetedMusclesHeatmap,
          padded: true,
          children: [BodyHeatmap(intensities: intensities)],
        ),
        NexcSection(
          title: l10n.topTargetMuscles,
          children: sortedMuscles.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.all(NexcSpacing.lg),
                    child: Text(l10n.noMuscleData),
                  ),
                ]
              : [
                  for (final MapEntry<Muscle, int> entry in sortedMuscles.take(
                    5,
                  ))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NexcSpacing.lg,
                        vertical: NexcSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _muscleLabel(entry.key),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(width: NexcSpacing.sm),
                          NexcBadge(
                            l10n.timesCount(entry.value),
                            tone: NexcBadgeTone.info,
                          ),
                        ],
                      ),
                    ),
                ],
        ),
      ],
    );
  }

  /// Sentence-cases the canonical English muscle name.
  String _muscleLabel(Muscle muscle) {
    final String name = muscle.toJson();
    if (name.isEmpty) return name;
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }
}

class _NutritionMetrics extends StatelessWidget {
  final List<MealPlanWithMealsAndItems> logs;

  const _NutritionMetrics({required this.logs});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final int days = logs.length;
    MacroTotals totals = MacroTotals.zero;
    for (final MealPlanWithMealsAndItems log in logs) {
      totals += MacroTotals.ofPlan(log);
    }
    final MacroTotals average = totals * (1 / days);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NexcSection(
          title: l10n.nutritionInsights(days),
          children: [
            Padding(
              padding: const EdgeInsets.all(NexcSpacing.lg),
              child: Column(
                children: [
                  NexcStatTile(
                    label: l10n.avgCalories,
                    value: formatDecimal(
                      average.impliedCalories,
                      maxDecimals: 0,
                    ),
                    unit: 'kcal',
                    icon: NexcIcons.macros,
                    tone: NexcBadgeTone.warning,
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  NexcStatTile(
                    label: l10n.avgProtein,
                    value: formatDecimal(average.protein, maxDecimals: 1),
                    unit: 'g',
                    icon: NexcIcons.macros,
                    tone: NexcBadgeTone.info,
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  NexcStatTile(
                    label: l10n.avgCarbs,
                    value: formatDecimal(average.carbs, maxDecimals: 1),
                    unit: 'g',
                    icon: NexcIcons.macros,
                    tone: NexcBadgeTone.success,
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  NexcStatTile(
                    label: l10n.avgFats,
                    value: formatDecimal(average.fats, maxDecimals: 1),
                    unit: 'g',
                    icon: NexcIcons.macros,
                    tone: NexcBadgeTone.neutral,
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
          child: _MacroChart(average: average),
        ),
      ],
    );
  }
}

class _MacroChart extends StatelessWidget {
  final MacroTotals average;

  const _MacroChart({required this.average});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final l10n = context.l10n;

    final double proteinKcal = average.protein * 4;
    final double carbsKcal = average.carbs * 4;
    final double fatsKcal = average.fats * 9;
    final double totalKcal = proteinKcal + carbsKcal + fatsKcal;

    final Color proteinColor = NexcMacroColors.protein(scheme);
    final Color carbsColor = NexcMacroColors.carbs(scheme);
    final Color fatsColor = NexcMacroColors.fats(scheme);

    String percent(double value) => totalKcal > 0
        ? '${formatDecimal(value / totalKcal * 100, maxDecimals: 0)}%'
        : '0%';

    return NexcChartCard(
      title: l10n.macrosDistribution,
      emptyMessage: totalKcal <= 0 ? l10n.noMacroData : null,
      legend: totalKcal <= 0
          ? const []
          : [
              NexcChartLegend(
                label:
                    '${l10n.proteinLabel} '
                    '${formatDecimal(average.protein, maxDecimals: 1)}g '
                    '(${percent(proteinKcal)})',
                color: proteinColor,
              ),
              NexcChartLegend(
                label:
                    '${l10n.carbsLabel} '
                    '${formatDecimal(average.carbs, maxDecimals: 1)}g '
                    '(${percent(carbsKcal)})',
                color: carbsColor,
              ),
              NexcChartLegend(
                label:
                    '${l10n.fatsLabel} '
                    '${formatDecimal(average.fats, maxDecimals: 1)}g '
                    '(${percent(fatsKcal)})',
                color: fatsColor,
              ),
            ],
      child: SizedBox(
        height: 160,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 36,
            sections: [
              _section(
                value: proteinKcal,
                title: percent(proteinKcal),
                color: proteinColor,
                onColor: scheme.onPrimary,
              ),
              _section(
                value: carbsKcal,
                title: percent(carbsKcal),
                color: carbsColor,
                onColor: scheme.onTertiary,
              ),
              _section(
                value: fatsKcal,
                title: percent(fatsKcal),
                color: fatsColor,
                onColor: scheme.onSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _section({
    required double value,
    required String title,
    required Color color,
    required Color onColor,
  }) {
    return PieChartSectionData(
      value: value > 0 ? value : 0.01,
      title: title,
      color: color,
      radius: 28,
      titleStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: onColor,
      ),
    );
  }
}
