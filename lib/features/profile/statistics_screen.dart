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
import 'package:fl_chart/fl_chart.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/components/nexc_scaffold.dart';
import '../../core/components/body_heatmap.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(completedWorkoutsProvider);
    final mealLogsAsync = ref.watch(profileMealLogsProvider);
    final theme = Theme.of(context);

    return NexcScaffold(
      title: const Text("Statistics"),
      navigateBack: () => Navigator.pop(context),
      content: (context, padding) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Workouts Section
            workoutsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error loading workouts: $err")),
              data: (workouts) {
                final totalWorkouts = workouts.length;
                int totalMinutes = 0;
                final muscleTargetCounts = <Muscle, int>{};

                for (final w in workouts) {
                  totalMinutes += (w.workout.timeElapsed ~/ 60);
                  for (final ex in w.exercisesWithSets) {
                    for (final m in ex.exerciseDC.primaryMuscles) {
                      muscleTargetCounts[m] = (muscleTargetCounts[m] ?? 0) + 1;
                    }
                  }
                }

                final avgDuration = totalWorkouts > 0 ? (totalMinutes / totalWorkouts).toStringAsFixed(1) : "0";
                
                // Sort targeted muscles
                final sortedMuscles = muscleTargetCounts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Workout Metrics", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatRow("Total Workouts", "$totalWorkouts", Icons.fitness_center, theme),
                            const Divider(),
                            _buildStatRow("Total Active Time", "$totalMinutes mins", Icons.timer_outlined, theme),
                            const Divider(),
                            _buildStatRow("Average Session", "$avgDuration mins", Icons.query_stats, theme),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Targeted Muscles Heatmap", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      final maxCount = muscleTargetCounts.values.fold(0, (max, val) => val > max ? val : max);
                      final intensities = muscleTargetCounts.map(
                        (m, count) => MapEntry(m, maxCount > 0 ? count / maxCount : 0.0),
                      );
                      return BodyHeatmap(intensities: intensities);
                    }),
                    const SizedBox(height: 20),
                    Text("Top Target Muscles", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (sortedMuscles.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No muscle targeting data yet. Start tracking sets!"),
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: sortedMuscles.take(5).map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Chip(
                                      label: Text("${entry.value} times"),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Nutrition Stats Section
            mealLogsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => Center(child: Text("Error loading nutrition: $err")),
              data: (logs) {
                if (logs.isEmpty) return const SizedBox.shrink();

                              double totalProt = 0.0;
                double totalCarb = 0.0;
                double totalFat = 0.0;

                for (final planWithMeals in logs) {
                  for (final m in planWithMeals.meals) {
                    for (final detail in m.items) {
                      final scale = detail.macroScale;
                      if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
                        totalProt += detail.product!.proteins * scale;
                        totalCarb += detail.product!.carbs * scale;
                        totalFat += detail.product!.fats * scale;
                      } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
                        for (final ing in detail.recipe!.ingredients) {
                          final ingScale = (ing.ingredient.amount / 100.0) * scale;
                          totalProt += ing.product.proteins * ingScale;
                          totalCarb += ing.product.carbs * ingScale;
                          totalFat += ing.product.fats * ingScale;
                        }
                      }
                    }
                  }
                }

                final days = logs.length;
                final avgProt = totalProt / days;
                final avgCarb = totalCarb / days;
                final avgFat = totalFat / days;
                final avgKcal = (avgProt * 4) + (avgCarb * 4) + (avgFat * 9);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nutrition Insights (Last $days logs)", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatRow("Avg. Calories", "${avgKcal.toStringAsFixed(0)} kcal", Icons.local_fire_department, theme),
                            const Divider(),
                            _buildStatRow("Avg. Protein", "${avgProt.toStringAsFixed(1)}g", Icons.egg_outlined, theme),
                            const Divider(),
                            _buildStatRow("Avg. Carbs", "${avgCarb.toStringAsFixed(1)}g", Icons.grain, theme),
                            const Divider(),
                            _buildStatRow("Avg. Fats", "${avgFat.toStringAsFixed(1)}g", Icons.water_drop_outlined, theme),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMacrosChart(avgProt, avgCarb, avgFat, avgKcal, theme),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacrosChart(double prot, double carb, double fat, double totalKcal, ThemeData theme) {
    final protKcal = prot * 4.0;
    final carbKcal = carb * 4.0;
    final fatKcal = fat * 9.0;

    final protPct = totalKcal > 0 ? (protKcal / totalKcal * 100) : 0.0;
    final carbPct = totalKcal > 0 ? (carbKcal / totalKcal * 100) : 0.0;
    final fatPct = totalKcal > 0 ? (fatKcal / totalKcal * 100) : 0.0;

    const protColor = Color(0xFF42A5F5); // Blue
    const carbColor = Color(0xFFFFA726); // Orange
    const fatColor = Color(0xFFAB47BC); // Purple

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_outline, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Macros Distribution",
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (totalKcal <= 0)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text("No macro data available"),
                ),
              )
            else
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 32,
                        sections: [
                          PieChartSectionData(
                            value: protKcal > 0 ? protKcal : 0.01,
                            title: "${protPct.toStringAsFixed(0)}%",
                            color: protColor,
                            radius: 26,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: carbKcal > 0 ? carbKcal : 0.01,
                            title: "${carbPct.toStringAsFixed(0)}%",
                            color: carbColor,
                            radius: 26,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: fatKcal > 0 ? fatKcal : 0.01,
                            title: "${fatPct.toStringAsFixed(0)}%",
                            color: fatColor,
                            radius: 26,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMacroLegendItem("Protein", "${prot.toStringAsFixed(1)}g", "${protPct.toStringAsFixed(0)}%", protColor, theme),
                        const SizedBox(height: 8),
                        _buildMacroLegendItem("Carbs", "${carb.toStringAsFixed(1)}g", "${carbPct.toStringAsFixed(0)}%", carbColor, theme),
                        const SizedBox(height: 8),
                        _buildMacroLegendItem("Fats", "${fat.toStringAsFixed(1)}g", "${fatPct.toStringAsFixed(0)}%", fatColor, theme),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroLegendItem(String label, String grams, String pct, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Text("$grams ($pct)", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatRow(String title, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
