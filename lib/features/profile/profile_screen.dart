/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/db/enums.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekStreak = ref.watch(profileWeekStreakProvider);
    final workoutsAsync = ref.watch(completedWorkoutsProvider);
    final mealLogsAsync = ref.watch(profileMealLogsProvider);
    final pointsAsync = ref.watch(profilePointsProvider);
    final chartMode = ref.watch(workoutChartModeProvider);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 10),
        StreakCard(weekStreak: weekStreak),
        const SizedBox(height: 16),
        // Menu Option Buttons Rows
        Row(
          children: [
            Expanded(
              child: _MenuButton(
                text: "Exercises",
                icon: Icons.search,
                onPressed: () {
                  Navigator.pushNamed(context, '/exercises', arguments: false);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MenuButton(
                text: "Statistics",
                icon: Icons.bar_chart,
                onPressed: () {
                  _showWipSnackBar(context, "Statistics Screen");
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MenuButton(
                text: "Measurements",
                icon: Icons.monitor_weight_outlined,
                onPressed: () {
                  _showWipSnackBar(context, "Measurements Screen");
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MenuButton(
                text: "Calendar",
                icon: Icons.calendar_month,
                onPressed: () {
                  Navigator.pushNamed(context, '/calendar');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MenuButton(
                text: "Products",
                icon: Icons.inventory_2_outlined,
                onPressed: () {
                  Navigator.pushNamed(context, '/meals/products');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MenuButton(
                text: "Recipes",
                icon: Icons.restaurant,
                onPressed: () {
                  Navigator.pushNamed(context, '/meals/recipes');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Overview Section
        Text(
          "Overview",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        pointsAsync.when(
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SizedBox(height: 200, child: Center(child: Text("Error loading chart: $err"))),
          data: (points) {
            final decimalCount = chartMode == WorkoutChart.DURATION ? 0 : 2;
            final suffix = chartMode == WorkoutChart.DURATION
                ? "m"
                : chartMode == WorkoutChart.VOLUME
                    ? "kg"
                    : "";
            return NexcCartesianChart(
              points: points,
              decimalCount: decimalCount,
              suffix: suffix,
              chartMode: chartMode,
              updateChartMode: (mode) {
                ref.read(workoutChartModeProvider.notifier).state = mode;
              },
              onEntrySelection: (workoutId) {
                Navigator.pushNamed(context, '/workout', arguments: workoutId);
              },
            );
          },
        ),
        const SizedBox(height: 24),
        // Your Workouts Section
        Text(
          "Your workouts",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        workoutsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (workouts) {
            if (workouts.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.fitness_center, size: 48, color: theme.colorScheme.primary.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        "Start completing workouts to see your history here.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: workouts.map((w) {
                final durationStr = '${(w.workout.timeElapsed ~/ 60)} min';
                final dateStr =
                    "${w.workout.completed.month}/${w.workout.completed.day}/${w.workout.completed.year}";
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(w.workout.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Finished on: $dateStr\nDuration: $durationStr"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, '/workout', arguments: w.workout.id);
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        // Your Meals Section
        Text(
          "Your meals",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        mealLogsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (logs) {
            if (logs.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.restaurant, size: 48, color: theme.colorScheme.primary.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        "No meal log history yet",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: logs.map((planWithMeals) {
                final plan = planWithMeals.mealPlan;
                final meals = planWithMeals.meals;

                // Totals calculations
                double totalProt = 0.0;
                double totalCarb = 0.0;
                double totalFat = 0.0;
                double totalCost = 0.0;
                int totalItems = 0;
                int consumedCount = 0;

                for (final m in meals) {
                  for (final detail in m.items) {
                    totalItems++;
                    if (detail.mealItem.consumed) consumedCount++;

                    final scale = detail.macroScale;
                    if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
                      totalProt += detail.product!.proteins * scale;
                      totalCarb += detail.product!.carbs * scale;
                      totalFat += detail.product!.fats * scale;
                      final grams = detail.mealItem.amountUnit == AmountUnit.UNITS
                          ? detail.mealItem.amount * getEdibleWeightPerUnit(detail.product!)
                          : detail.mealItem.amount;
                      final costFactor = detail.product!.weight > 0
                          ? grams / detail.product!.weight
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

                final formatter =
                    "${plan.created.month}/${plan.created.day}/${plan.created.year} ${plan.created.hour.toString().padLeft(2, '0')}:${plan.created.minute.toString().padLeft(2, '0')}";

                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/meals/track-plan',
                                arguments: plan.id,
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text("Eaten on: $formatter"),
                                Text("Progress: $consumedCount / $totalItems items eaten"),
                                Text(
                                  "Macros: P ${totalProt.toStringAsFixed(1)}g | C ${totalCarb.toStringAsFixed(1)}g | F ${totalFat.toStringAsFixed(1)}g",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Est. Cost: \$${totalCost.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                          onPressed: () {
                            ref.read(mealRepositoryProvider).deleteMealPlan(plan);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showWipSnackBar(BuildContext context, String screenName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$screenName - Work in Progress"),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class StreakCard extends StatefulWidget {
  final int weekStreak;

  const StreakCard({
    super.key,
    required this.weekStreak,
  });

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  int _clicks = 0;
  Timer? _decayTimer;

  @override
  void initState() {
    super.initState();
    _decayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_clicks > 0) {
        setState(() {
          _clicks--;
        });
      }
    });
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intensity = (widget.weekStreak * 2 + _clicks).clamp(0, 52) / 52.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Color.lerp(
            theme.colorScheme.outlineVariant,
            theme.colorScheme.primary,
            intensity,
          )!,
          width: intensity > 0.6 ? 2.5 : 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          setState(() {
            _clicks = (_clicks + 1).clamp(0, 40);
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 48,
                color: Color.lerp(
                  Colors.orange.withOpacity(0.5),
                  Colors.red,
                  intensity,
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Week Streak: ${widget.weekStreak}",
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _clicks > 15 ? "🔥 Super Active!" : "Keep moving!",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
    );
  }
}

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
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Workout Performance",
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                DropdownButton<WorkoutChart>(
                  value: chartMode,
                  onChanged: (val) {
                    if (val != null) updateChartMode(val);
                  },
                  items: WorkoutChart.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(
                        mode == WorkoutChart.DURATION
                            ? "Duration"
                            : mode == WorkoutChart.VOLUME
                                ? "Volume"
                                : "Reps",
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: points.isEmpty
                  ? Center(
                      child: Text(
                        "No data yet",
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        barGroups: points.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final pt = entry.value;
                          final yVal = pt.yValues.firstOrNull ?? 0.0;
                          return BarChartGroupData(
                            x: idx,
                            barRods: [
                              BarChartRodData(
                                toY: yVal,
                                color: theme.colorScheme.primary,
                                width: 14,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (val, meta) {
                                return Text(
                                  val.toStringAsFixed(decimalCount) + (suffix ?? ""),
                                  style: theme.textTheme.labelSmall,
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx >= 0 && idx < points.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      points[idx].xValue,
                                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          touchCallback: (event, response) {
                            if (event is FlTapUpEvent && response != null && response.spot != null) {
                              final idx = response.spot!.touchedBarGroupIndex;
                              if (idx >= 0 && idx < points.length) {
                                final workoutId = points[idx].workoutId;
                                if (workoutId != null) {
                                  onEntrySelection(workoutId);
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
