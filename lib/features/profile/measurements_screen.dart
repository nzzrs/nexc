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
import 'package:fl_chart/fl_chart.dart';
import '../../core/db/app_database.dart';
import '../../core/db/measurement_repository.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/components/nexc_scaffold.dart';

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  void _showAddMeasurement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMeasurementDialog(),
    );
  }

  Widget _buildBodyTab(
    BuildContext context,
    ThemeData theme,
    List<BodyMeasurement> weightLogs,
    List<AdvancedBodyMeasurement> advBodyLogs,
    bool enableAdvanced,
  ) {
    // Weight spots
    final chronologicalWeight = weightLogs.reversed.toList();
    final weightSpots = chronologicalWeight.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.bodyWeight);
    }).toList();

    // Fat / Muscle / Waist spots if enabled
    List<FlSpot> fatSpots = [];
    List<AdvancedBodyMeasurement> chronologicalFat = [];
    List<FlSpot> muscleSpots = [];
    List<AdvancedBodyMeasurement> chronologicalMuscle = [];
    List<FlSpot> waistSpots = [];
    List<AdvancedBodyMeasurement> chronologicalWaist = [];

    if (enableAdvanced) {
      final fatLogs = advBodyLogs.where((l) => l.bodyFatPercentage != null).toList();
      final muscleLogs = advBodyLogs.where((l) => l.muscleMassPercentage != null).toList();
      final waistLogs = advBodyLogs.where((l) => l.waistCircumference != null).toList();

      chronologicalFat = fatLogs.reversed.toList();
      fatSpots = chronologicalFat.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.bodyFatPercentage!.toDouble());
      }).toList();

      chronologicalMuscle = muscleLogs.reversed.toList();
      muscleSpots = chronologicalMuscle.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.muscleMassPercentage!.toDouble());
      }).toList();

      chronologicalWaist = waistLogs.reversed.toList();
      waistSpots = chronologicalWaist.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.waistCircumference!);
      }).toList();
    }

    // Merge logs for combined history
    final List<dynamic> mergedLogs = [...weightLogs, ...advBodyLogs];
    mergedLogs.sort((a, b) {
      final dateA = (a is BodyMeasurement) ? a.date : (a as AdvancedBodyMeasurement).date;
      final dateB = (b is BodyMeasurement) ? b.date : (b as AdvancedBodyMeasurement).date;
      return dateB.compareTo(dateA);
    });

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (weightSpots.length >= 2) ...[
          _buildChartCard(theme, "Weight Progress", weightSpots, chronologicalWeight.map((l) => l.date).toList(), "kg"),
          const SizedBox(height: 16),
        ],
        if (enableAdvanced) ...[
          if (fatSpots.length >= 2) ...[
            _buildChartCard(theme, "Body Fat %", fatSpots, chronologicalFat.map((l) => l.date).toList(), "%"),
            const SizedBox(height: 16),
          ],
          if (muscleSpots.length >= 2) ...[
            _buildChartCard(theme, "Muscle Mass %", muscleSpots, chronologicalMuscle.map((l) => l.date).toList(), "%"),
            const SizedBox(height: 16),
          ],
          if (waistSpots.length >= 2) ...[
            _buildChartCard(theme, "Waist Circumference", waistSpots, chronologicalWaist.map((l) => l.date).toList(), "cm"),
            const SizedBox(height: 16),
          ],
        ],
        Text(
          "Body History",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (mergedLogs.isEmpty)
          const Center(child: Text("No body measurements recorded yet."))
        else
          ...mergedLogs.map((log) {
            final dateStr = (log is BodyMeasurement)
                ? "${log.date.month}/${log.date.day}/${log.date.year}"
                : "${(log as AdvancedBodyMeasurement).date.month}/${log.date.day}/${log.date.year}";

            if (log is BodyMeasurement) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    "Weight: ${log.bodyWeight} kg",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Date: $dateStr"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete log?"),
                          content: const Text("Are you sure you want to delete this weight measurement?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(measurementRepositoryProvider).deleteMeasurement(log);
                      }
                    },
                  ),
                ),
              );
            } else {
              // AdvancedBodyMeasurement
              final adv = log as AdvancedBodyMeasurement;
              final bf = adv.bodyFatPercentage != null ? "${adv.bodyFatPercentage}% BF" : "";
              final mus = adv.muscleMassPercentage != null ? "${adv.muscleMassPercentage}% Muscle" : "";
              final waist = adv.waistCircumference != null ? "${adv.waistCircumference}cm Waist" : "";
              final details = [bf, mus, waist].where((s) => s.isNotEmpty).join(", ");
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    details.isEmpty ? "Advanced Entry" : details,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Date: $dateStr"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete log?"),
                          content: const Text("Are you sure you want to delete this advanced body log?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final db = ref.read(measurementRepositoryProvider).db;
                        await (db.delete(db.advancedBodyMeasurements)..where((m) => m.id.equals(adv.id))).go();
                      }
                    },
                  ),
                ),
              );
            }
          }),
      ],
    );
  }

  Widget _buildSleepTab(
    BuildContext context,
    ThemeData theme,
    List<SleepMeasurement> sleepLogs,
    List<AdvancedSleepMeasurement> advSleepLogs,
    bool enableAdvanced,
  ) {
    // Sleep duration spots
    final chronologicalSleep = sleepLogs.where((l) => l.sleepDuration != null).toList().reversed.toList();
    final sleepSpots = chronologicalSleep.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.sleepDuration!);
    }).toList();

    // Sleeping RHR & HRV spots
    final chronologicalRhr = sleepLogs.where((l) => l.sleepingRHR != null).toList().reversed.toList();
    final rhrSpots = chronologicalRhr.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.sleepingRHR!.toDouble());
    }).toList();

    final chronologicalHrv = sleepLogs.where((l) => l.sleepingHRV != null).toList().reversed.toList();
    final hrvSpots = chronologicalHrv.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.sleepingHRV!.toDouble());
    }).toList();

    // Awake spots
    List<FlSpot> awakeSpots = [];
    List<AdvancedSleepMeasurement> chronologicalAwake = [];

    // Time in Bed spots
    List<FlSpot> tibSpots = [];
    List<AdvancedSleepMeasurement> chronologicalTib = [];

    // Awakenings spots
    List<FlSpot> awakeningsSpots = [];
    List<AdvancedSleepMeasurement> chronologicalAwakenings = [];

    if (enableAdvanced) {
      final awakeLogs = advSleepLogs.where((l) => l.totalAwakeTime != null).toList();
      chronologicalAwake = awakeLogs.reversed.toList();
      awakeSpots = chronologicalAwake.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.totalAwakeTime!);
      }).toList();

      final tibLogs = advSleepLogs.where((l) => l.timeInBed != null).toList();
      chronologicalTib = tibLogs.reversed.toList();
      tibSpots = chronologicalTib.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.timeInBed!);
      }).toList();

      final awakeningsLogs = advSleepLogs.where((l) => l.numberOfAwakenings != null).toList();
      chronologicalAwakenings = awakeningsLogs.reversed.toList();
      awakeningsSpots = chronologicalAwakenings.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.numberOfAwakenings!.toDouble());
      }).toList();
    }

    // Merge logs
    final List<dynamic> mergedLogs = [...sleepLogs, ...advSleepLogs];
    mergedLogs.sort((a, b) {
      final dateA = (a is SleepMeasurement) ? a.date : (a as AdvancedSleepMeasurement).date;
      final dateB = (b is SleepMeasurement) ? b.date : (b as AdvancedSleepMeasurement).date;
      return dateB.compareTo(dateA);
    });

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (sleepSpots.length >= 2) ...[
          _buildChartCard(theme, "Sleep Duration", sleepSpots, chronologicalSleep.map((l) => l.date).toList(), "h"),
          const SizedBox(height: 16),
        ],
        if (rhrSpots.length >= 2) ...[
          _buildChartCard(theme, "Sleeping RHR", rhrSpots, chronologicalRhr.map((l) => l.date).toList(), "bpm"),
          const SizedBox(height: 16),
        ],
        if (hrvSpots.length >= 2) ...[
          _buildChartCard(theme, "Sleeping HRV", hrvSpots, chronologicalHrv.map((l) => l.date).toList(), "ms"),
          const SizedBox(height: 16),
        ],
        if (enableAdvanced && awakeSpots.length >= 2) ...[
          _buildChartCard(theme, "Time Awake", awakeSpots, chronologicalAwake.map((l) => l.date).toList(), "h"),
          const SizedBox(height: 16),
        ],
        if (enableAdvanced && tibSpots.length >= 2) ...[
          _buildChartCard(theme, "Time in Bed", tibSpots, chronologicalTib.map((l) => l.date).toList(), "h"),
          const SizedBox(height: 16),
        ],
        if (enableAdvanced && awakeningsSpots.length >= 2) ...[
          _buildChartCard(theme, "Number of Awakenings", awakeningsSpots, chronologicalAwakenings.map((l) => l.date).toList(), ""),
          const SizedBox(height: 16),
        ],
        Text(
          "Sleep History",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (mergedLogs.isEmpty)
          const Center(child: Text("No sleep logs recorded yet."))
        else
          ...mergedLogs.map((log) {
            final dateStr = (log is SleepMeasurement)
                ? "${log.date.month}/${log.date.day}/${log.date.year}"
                : "${(log as AdvancedSleepMeasurement).date.month}/${log.date.day}/${log.date.year}";

            if (log is SleepMeasurement) {
              final dur = log.sleepDuration != null ? "${log.sleepDuration} hrs" : "";
              final rhr = log.sleepingRHR != null ? "${log.sleepingRHR} bpm RHR" : "";
              final hrv = log.sleepingHRV != null ? "${log.sleepingHRV} ms HRV" : "";
              final details = [dur, rhr, hrv].where((s) => s.isNotEmpty).join(", ");
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    details.isEmpty ? "Sleep Entry" : details,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Date: $dateStr"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete log?"),
                          content: const Text("Are you sure you want to delete this sleep log?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(measurementRepositoryProvider).deleteSleepMeasurement(log);
                      }
                    },
                  ),
                ),
              );
            } else {
              // AdvancedSleepMeasurement
              final adv = log as AdvancedSleepMeasurement;
              final tib = adv.timeInBed != null ? "${adv.timeInBed} hrs Bed" : "";
              final awake = adv.totalAwakeTime != null ? "${adv.totalAwakeTime} hrs Awake" : "";
              final awakenings = adv.numberOfAwakenings != null ? "${adv.numberOfAwakenings} awakenings" : "";
              final details = [tib, awake, awakenings].where((s) => s.isNotEmpty).join(", ");
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    details.isEmpty ? "Adv Sleep Entry" : details,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Date: $dateStr"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete log?"),
                          content: const Text("Are you sure you want to delete this advanced sleep log?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(measurementRepositoryProvider).deleteAdvancedSleepMeasurement(adv);
                      }
                    },
                  ),
                ),
              );
            }
          }),
      ],
    );
  }

  Widget _buildActivityTab(BuildContext context, ThemeData theme, List<ActivityMeasurement> logs) {
    if (logs.isEmpty) {
      return const Center(child: Text("No activity logs recorded yet."));
    }

    final stepsLogs = logs.where((l) => l.dailySteps != null).toList();
    final chronologicalSteps = stepsLogs.reversed.toList();
    final spots = chronologicalSteps.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.dailySteps!.toDouble());
    }).toList();

    final calLogs = logs.where((l) => l.activeEnergyBurned != null).toList();
    final chronologicalCals = calLogs.reversed.toList();
    final calSpots = chronologicalCals.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.activeEnergyBurned!);
    }).toList();

    final vo2Logs = logs.where((l) => l.vo2Max != null).toList();
    final chronologicalVo2 = vo2Logs.reversed.toList();
    final vo2Spots = chronologicalVo2.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.vo2Max!);
    }).toList();

    final rhrLogs = logs.where((l) => l.wakingRHR != null).toList();
    final chronologicalRhr = rhrLogs.reversed.toList();
    final rhrSpots = chronologicalRhr.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.wakingRHR!.toDouble());
    }).toList();

    final hrvLogs = logs.where((l) => l.wakingHRV != null).toList();
    final chronologicalHrv = hrvLogs.reversed.toList();
    final hrvSpots = chronologicalHrv.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.wakingHRV!.toDouble());
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (spots.length >= 2) ...[
          _buildChartCard(theme, "Daily Steps", spots, chronologicalSteps.map((l) => l.date).toList(), "steps"),
          const SizedBox(height: 16),
        ],
        if (calSpots.length >= 2) ...[
          _buildChartCard(theme, "Calories Active", calSpots, chronologicalCals.map((l) => l.date).toList(), "kcal"),
          const SizedBox(height: 16),
        ],
        if (vo2Spots.length >= 2) ...[
          _buildChartCard(theme, "VO2 Max", vo2Spots, chronologicalVo2.map((l) => l.date).toList(), "ml/kg"),
          const SizedBox(height: 16),
        ],
        if (rhrSpots.length >= 2) ...[
          _buildChartCard(theme, "Waking RHR", rhrSpots, chronologicalRhr.map((l) => l.date).toList(), "bpm"),
          const SizedBox(height: 16),
        ],
        if (hrvSpots.length >= 2) ...[
          _buildChartCard(theme, "Waking HRV", hrvSpots, chronologicalHrv.map((l) => l.date).toList(), "ms"),
          const SizedBox(height: 16),
        ],
        Text(
          "Activity History",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...logs.map((log) {
          final dateStr = "${log.date.month}/${log.date.day}/${log.date.year}";
          final steps = log.dailySteps != null ? "${log.dailySteps} steps" : "";
          final cal = log.activeEnergyBurned != null ? "${log.activeEnergyBurned} kcal" : "";
          final vo2 = log.vo2Max != null ? "VO2: ${log.vo2Max}" : "";
          final rhr = log.wakingRHR != null ? "${log.wakingRHR} bpm RHR" : "";
          final hrv = log.wakingHRV != null ? "${log.wakingHRV} ms HRV" : "";
          final details = [steps, cal, vo2, rhr, hrv].where((s) => s.isNotEmpty).join(", ");

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                details.isEmpty ? "Activity Entry" : details,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Date: $dateStr"),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete log?"),
                      content: const Text("Are you sure you want to delete this activity log?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(measurementRepositoryProvider).deleteActivityMeasurement(log);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChartCard(ThemeData theme, String title, List<FlSpot> spots, List<DateTime> dates, String unit) {
    if (spots.isEmpty) return const SizedBox.shrink();

    final values = spots.map((s) => s.y).toList();
    final latest = values.isNotEmpty ? values.last : 0.0;
    final avg = values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0.0;
    final minVal = values.isNotEmpty ? values.reduce(min) : 0.0;
    final maxVal = values.isNotEmpty ? values.reduce(max) : 0.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant.withOpacity(0.4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(theme, "Latest", "${latest.toStringAsFixed(1)} $unit"),
                _buildMetricItem(theme, "Average", "${avg.toStringAsFixed(1)} $unit"),
                _buildMetricItem(theme, "Min/Max", "${minVal.toStringAsFixed(1)} - ${maxVal.toStringAsFixed(1)} $unit"),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.onPrimary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.3),
                            theme.colorScheme.primary.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (val, meta) {
                          return Text(
                            val.toStringAsFixed(0),
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
                          if (idx >= 0 && idx < dates.length) {
                            final date = dates[idx];
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                "${date.month}/${date.day}",
                                style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => theme.colorScheme.secondaryContainer,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            "${spot.y.toStringAsFixed(1)} $unit",
                            theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ) ??
                                const TextStyle(),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    // Build active tabs list
    final List<Map<String, dynamic>> activeTabs = [];
    activeTabs.add({
      'title': 'Body',
      'icon': Icons.accessibility_new,
      'type': 'body',
    });

    if (settings.enableSleep) {
      activeTabs.add({
        'title': 'Sleep',
        'icon': Icons.hotel,
        'type': 'sleep',
      });
    }

    if (settings.enableActivity) {
      activeTabs.add({
        'title': 'Activity',
        'icon': Icons.directions_run,
        'type': 'activity',
      });
    }

    if (activeTabs.length == 1) {
      return NexcScaffold(
        title: const Text("Measurements"),
        navigateBack: () => Navigator.pop(context),
        fabIcon: const Icon(Icons.add),
        fabText: "Add Log",
        fabAction: () => _showAddMeasurement(context),
        content: (context, padding) {
          return Padding(
            padding: EdgeInsets.only(top: padding.top),
            child: Builder(builder: (context) {
              final weightAsync = ref.watch(allMeasurementsProvider);
              final advBodyAsync = ref.watch(allAdvancedBodyMeasurementsProvider);

              return weightAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (weightLogs) => advBodyAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                  data: (advBodyLogs) => _buildBodyTab(context, theme, weightLogs, advBodyLogs, true),
                ),
              );
            }),
          );
        },
      );
    }

    return DefaultTabController(
      length: activeTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Measurements"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            isScrollable: false,
            tabAlignment: TabAlignment.fill,
            tabs: activeTabs.map<Widget>((tab) {
              return Tab(
                text: tab['title'],
                icon: Icon(tab['icon']),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: activeTabs.map<Widget>((tab) {
            final type = tab['type'];
            if (type == 'body') {
              final weightAsync = ref.watch(allMeasurementsProvider);
              final advBodyAsync = ref.watch(allAdvancedBodyMeasurementsProvider);

              return weightAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (weightLogs) => advBodyAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                  data: (advBodyLogs) => _buildBodyTab(context, theme, weightLogs, advBodyLogs, true),
                ),
              );
            } else if (type == 'sleep') {
              final sleepAsync = ref.watch(allSleepMeasurementsProvider);
              final advSleepAsync = ref.watch(allAdvancedSleepMeasurementsProvider);

              return sleepAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (sleepLogs) => advSleepAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                  data: (advSleepLogs) => _buildSleepTab(context, theme, sleepLogs, advSleepLogs, true),
                ),
              );
            } else {
              // activity
              final activityAsync = ref.watch(allActivityMeasurementsProvider);
              return activityAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (logs) => _buildActivityTab(context, theme, logs),
              );
            }
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text("Add Log"),
          onPressed: () => _showAddMeasurement(context),
        ),
      ),
    );
  }
}

class AddMeasurementDialog extends ConsumerStatefulWidget {
  const AddMeasurementDialog({super.key});

  @override
  ConsumerState<AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends ConsumerState<AddMeasurementDialog> {
  final _weightController = TextEditingController();
  final _bfController = TextEditingController();
  final _muscleController = TextEditingController();
  final _waistController = TextEditingController();

  final _sleepDurController = TextEditingController();
  final _sleepRhrController = TextEditingController();
  final _sleepHrvController = TextEditingController();

  final _tibController = TextEditingController();
  final _awakeController = TextEditingController();
  final _awakeningsController = TextEditingController();

  final _stepsController = TextEditingController();
  final _activeEnergyController = TextEditingController();
  final _vo2Controller = TextEditingController();
  final _wakingRhrController = TextEditingController();
  final _wakingHrvController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _bfController.dispose();
    _muscleController.dispose();
    _waistController.dispose();
    _sleepDurController.dispose();
    _sleepRhrController.dispose();
    _sleepHrvController.dispose();
    _tibController.dispose();
    _awakeController.dispose();
    _awakeningsController.dispose();
    _stepsController.dispose();
    _activeEnergyController.dispose();
    _vo2Controller.dispose();
    _wakingRhrController.dispose();
    _wakingHrvController.dispose();
    super.dispose();
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isDecimal = true}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    final hasAdvancedBody = settings.enableAdvancedBody;
    final hasSleep = settings.enableSleep;
    final hasAdvancedSleep = settings.enableAdvancedSleep;
    final hasActivity = settings.enableActivity;
    final hasManyFields = hasAdvancedBody || hasSleep || hasAdvancedSleep || hasActivity;
    final dialogWidth = hasManyFields ? 550.0 : 340.0;

    return AlertDialog(
      title: const Text("Log Measurement"),
      content: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Body weight - always visible
              _buildField(_weightController, "Body Weight (kg)", Icons.scale),
              const SizedBox(height: 16),

              if (settings.enableAdvancedBody) ...[
                const Divider(),
                const SizedBox(height: 8),
                const Text("Advanced Body Metrics", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildField(_bfController, "Body Fat %", Icons.percent)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(_muscleController, "Muscle Mass %", Icons.fitness_center)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(_waistController, "Waist (cm)", Icons.straighten),
                const SizedBox(height: 16),
              ],

              if (settings.enableSleep) ...[
                const Divider(),
                const SizedBox(height: 8),
                const Text("Sleep Metrics", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildField(_sleepDurController, "Sleep (hrs)", Icons.hotel)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(_sleepRhrController, "Sleeping RHR", Icons.favorite)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(_sleepHrvController, "Sleeping HRV (ms)", Icons.monitor_heart),
                const SizedBox(height: 16),
              ],

              if (settings.enableAdvancedSleep) ...[
                const Divider(),
                const SizedBox(height: 8),
                const Text("Advanced Sleep Metrics", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildField(_tibController, "Time in Bed (hrs)", Icons.bed)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(_awakeController, "Awake (hrs)", Icons.wb_sunny)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(_awakeningsController, "Number of Awakenings", Icons.alarm_on, isDecimal: false),
                const SizedBox(height: 16),
              ],

              if (settings.enableActivity) ...[
                const Divider(),
                const SizedBox(height: 8),
                const Text("Activity Metrics", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildField(_stepsController, "Daily Steps", Icons.directions_walk, isDecimal: false)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(_activeEnergyController, "Calories (kcal)", Icons.local_fire_department)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildField(_vo2Controller, "VO2 Max", Icons.speed)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(_wakingRhrController, "Waking RHR", Icons.favorite_border, isDecimal: false)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(_wakingHrvController, "Waking HRV (ms)", Icons.healing, isDecimal: false),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () async {
            final now = DateTime.now();

            // Save body weight if entered
            final w = double.tryParse(_weightController.text) ?? 0.0;
            if (w > 0.0) {
              final newLog = BodyMeasurement(
                id: Random().nextInt(1000000),
                bodyWeight: w,
                date: now,
              );
              await ref.read(measurementRepositoryProvider).upsertMeasurement(newLog);
            }

            // Save Advanced Body
            if (settings.enableAdvancedBody) {
              final bf = int.tryParse(_bfController.text);
              final mus = int.tryParse(_muscleController.text);
              final waist = double.tryParse(_waistController.text);
              if (bf != null || mus != null || waist != null) {
                final advBodyLog = AdvancedBodyMeasurement(
                  id: Random().nextInt(1000000),
                  bodyFatPercentage: bf,
                  muscleMassPercentage: mus,
                  waistCircumference: waist,
                  date: now,
                );
                final db = ref.read(measurementRepositoryProvider).db;
                await db.into(db.advancedBodyMeasurements).insertOnConflictUpdate(advBodyLog);
              }
            }

            // Save Sleep
            if (settings.enableSleep) {
              final sleepDur = double.tryParse(_sleepDurController.text);
              final sleepRhr = int.tryParse(_sleepRhrController.text);
              final sleepHrv = int.tryParse(_sleepHrvController.text);
              if (sleepDur != null || sleepRhr != null || sleepHrv != null) {
                final sleepLog = SleepMeasurement(
                  id: Random().nextInt(1000000),
                  sleepDuration: sleepDur,
                  sleepingRHR: sleepRhr,
                  sleepingHRV: sleepHrv,
                  date: now,
                );
                await ref.read(measurementRepositoryProvider).upsertSleepMeasurement(sleepLog);
              }
            }

            // Save Advanced Sleep
            if (settings.enableAdvancedSleep) {
              final tib = double.tryParse(_tibController.text);
              final awake = double.tryParse(_awakeController.text);
              final awakenings = int.tryParse(_awakeningsController.text);
              if (tib != null || awake != null || awakenings != null) {
                final advSleepLog = AdvancedSleepMeasurement(
                  id: Random().nextInt(1000000),
                  timeInBed: tib,
                  totalAwakeTime: awake,
                  numberOfAwakenings: awakenings,
                  date: now,
                );
                await ref.read(measurementRepositoryProvider).upsertAdvancedSleepMeasurement(advSleepLog);
              }
            }

            // Save Activity
            if (settings.enableActivity) {
              final steps = int.tryParse(_stepsController.text);
              final activeEnergy = double.tryParse(_activeEnergyController.text);
              final vo2 = double.tryParse(_vo2Controller.text);
              final wakingRhr = int.tryParse(_wakingRhrController.text);
              final wakingHrv = int.tryParse(_wakingHrvController.text);
              if (steps != null || activeEnergy != null || vo2 != null || wakingRhr != null || wakingHrv != null) {
                final activityLog = ActivityMeasurement(
                  id: Random().nextInt(1000000),
                  dailySteps: steps,
                  activeEnergyBurned: activeEnergy,
                  vo2Max: vo2,
                  wakingRHR: wakingRhr,
                  wakingHRV: wakingHrv,
                  date: now,
                );
                await ref.read(measurementRepositoryProvider).upsertActivityMeasurement(activityLog);
              }
            }

            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
