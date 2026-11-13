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
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/util/unit_system.dart';
import '../../core/components/nexc_scaffold.dart';

import 'log_measurement_screen.dart';

/// Converts body-weight chart spots stored in kilograms to [system].
///
/// Metric spots are returned untouched; imperial spots are converted for
/// rendering so the chart axis and tooltips share the selected unit.
List<FlSpot> convertWeightSpots(List<FlSpot> spots, UnitSystem system) {
  if (system == UnitSystem.metric) return spots;
  return spots
      .map((spot) => FlSpot(spot.x, fromKilograms(spot.y, system)))
      .toList();
}

String formatDoubleHours(double hours) {
  final totalMinutes = (hours * 60).round();
  final hrs = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;
  if (hrs > 0) {
    if (mins > 0) {
      return "${hrs}h ${mins}m";
    }
    return "${hrs}h";
  }
  return "${mins}m";
}

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  void _showAddMeasurement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogMeasurementScreen()),
    );
  }

  Widget _buildBodyTab(
    BuildContext context,
    ThemeData theme,
    List<BodyMeasurement> weightLogs,
    List<AdvancedBodyMeasurement> advBodyLogs,
    bool enableAdvanced,
    UnitSystem unitSystem,
  ) {
    final l10n = context.l10n;
    // Weight spots, converted from canonical kilograms for display.
    final chronologicalWeight = weightLogs.reversed.toList();
    final weightSpots = convertWeightSpots(
      chronologicalWeight.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.bodyWeight);
      }).toList(),
      unitSystem,
    );

    // Fat / Muscle / Waist spots if enabled
    List<FlSpot> fatSpots = [];
    List<AdvancedBodyMeasurement> chronologicalFat = [];
    List<FlSpot> muscleSpots = [];
    List<AdvancedBodyMeasurement> chronologicalMuscle = [];
    List<FlSpot> waistSpots = [];
    List<AdvancedBodyMeasurement> chronologicalWaist = [];

    if (enableAdvanced) {
      final fatLogs = advBodyLogs
          .where((l) => l.bodyFatPercentage != null)
          .toList();
      final muscleLogs = advBodyLogs
          .where((l) => l.muscleMassPercentage != null)
          .toList();
      final waistLogs = advBodyLogs
          .where((l) => l.waistCircumference != null)
          .toList();

      chronologicalFat = fatLogs.reversed.toList();
      fatSpots = chronologicalFat.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value.bodyFatPercentage!.toDouble(),
        );
      }).toList();

      chronologicalMuscle = muscleLogs.reversed.toList();
      muscleSpots = chronologicalMuscle.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value.muscleMassPercentage!.toDouble(),
        );
      }).toList();

      chronologicalWaist = waistLogs.reversed.toList();
      waistSpots = chronologicalWaist.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.waistCircumference!);
      }).toList();
    }

    // Merge logs for combined history
    final List<dynamic> mergedLogs = [...weightLogs, ...advBodyLogs];
    mergedLogs.sort((a, b) {
      final dateA = (a is BodyMeasurement)
          ? a.date
          : (a as AdvancedBodyMeasurement).date;
      final dateB = (b is BodyMeasurement)
          ? b.date
          : (b as AdvancedBodyMeasurement).date;
      return dateB.compareTo(dateA);
    });

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (weightSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.weightProgress,
            weightSpots,
            chronologicalWeight.map((l) => l.date).toList(),
            unitSystem.suffix,
          ),
          const SizedBox(height: 16),
        ],
        if (enableAdvanced) ...[
          if (fatSpots.length >= 2) ...[
            _buildChartCard(
              context,
              theme,
              l10n.bodyFatPercent,
              fatSpots,
              chronologicalFat.map((l) => l.date).toList(),
              "%",
            ),
            const SizedBox(height: 16),
          ],
          if (muscleSpots.length >= 2) ...[
            _buildChartCard(
              context,
              theme,
              l10n.muscleMassPercent,
              muscleSpots,
              chronologicalMuscle.map((l) => l.date).toList(),
              "%",
            ),
            const SizedBox(height: 16),
          ],
          if (waistSpots.length >= 2) ...[
            _buildChartCard(
              context,
              theme,
              l10n.waistCircumference,
              waistSpots,
              chronologicalWaist.map((l) => l.date).toList(),
              "cm",
            ),
            const SizedBox(height: 16),
          ],
        ],
        Text(
          l10n.bodyHistory,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (mergedLogs.isEmpty)
          Center(child: Text(l10n.noBodyMeasurements))
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
                    l10n.weightWithValue(
                      formatWeight(
                        log.bodyWeight,
                        unitSystem,
                        suffix: unitSystem.suffix,
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(l10n.dateWithValue(dateStr)),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.deleteLog),
                          content: Text(l10n.deleteWeightConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                l10n.delete,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref
                            .read(measurementRepositoryProvider)
                            .deleteMeasurement(log);
                      }
                    },
                  ),
                ),
              );
            } else {
              // AdvancedBodyMeasurement
              final adv = log as AdvancedBodyMeasurement;
              final bf = adv.bodyFatPercentage != null
                  ? l10n.bodyFatValue('${adv.bodyFatPercentage}')
                  : "";
              final mus = adv.muscleMassPercentage != null
                  ? l10n.muscleMassValue('${adv.muscleMassPercentage}')
                  : "";
              final waist = adv.waistCircumference != null
                  ? l10n.waistValue('${adv.waistCircumference}')
                  : "";
              final details = [
                bf,
                mus,
                waist,
              ].where((s) => s.isNotEmpty).join(", ");
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    details.isEmpty ? l10n.advancedEntry : details,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(l10n.dateWithValue(dateStr)),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.deleteLog),
                          content: Text(l10n.deleteAdvancedBodyConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                l10n.delete,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final db = ref.read(measurementRepositoryProvider).db;
                        await (db.delete(
                          db.advancedBodyMeasurements,
                        )..where((m) => m.id.equals(adv.id))).go();
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
    final l10n = context.l10n;
    // Sleep duration spots
    final chronologicalSleep = sleepLogs
        .where((l) => l.sleepDuration != null)
        .toList()
        .reversed
        .toList();
    final sleepSpots = chronologicalSleep.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.sleepDuration!);
    }).toList();

    // Sleeping RHR & HRV spots
    final chronologicalRhr = sleepLogs
        .where((l) => l.sleepingRHR != null)
        .toList()
        .reversed
        .toList();
    final rhrSpots = chronologicalRhr.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.sleepingRHR!.toDouble());
    }).toList();

    final chronologicalHrv = sleepLogs
        .where((l) => l.sleepingHRV != null)
        .toList()
        .reversed
        .toList();
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
      final awakeLogs = advSleepLogs
          .where((l) => l.totalAwakeTime != null)
          .toList();
      chronologicalAwake = awakeLogs.reversed.toList();
      awakeSpots = chronologicalAwake.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.totalAwakeTime!);
      }).toList();

      final tibLogs = advSleepLogs.where((l) => l.timeInBed != null).toList();
      chronologicalTib = tibLogs.reversed.toList();
      tibSpots = chronologicalTib.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.timeInBed!);
      }).toList();

      final awakeningsLogs = advSleepLogs
          .where((l) => l.numberOfAwakenings != null)
          .toList();
      chronologicalAwakenings = awakeningsLogs.reversed.toList();
      awakeningsSpots = chronologicalAwakenings.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value.numberOfAwakenings!.toDouble(),
        );
      }).toList();
    }

    // Merge logs
    final List<dynamic> mergedLogs = [...sleepLogs, ...advSleepLogs];
    mergedLogs.sort((a, b) {
      final dateA = (a is SleepMeasurement)
          ? a.date
          : (a as AdvancedSleepMeasurement).date;
      final dateB = (b is SleepMeasurement)
          ? b.date
          : (b as AdvancedSleepMeasurement).date;
      return dateB.compareTo(dateA);
    });

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (sleepSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.sleepDuration,
            sleepSpots,
            chronologicalSleep.map((l) => l.date).toList(),
            "h",
          ),
          const SizedBox(height: 16),
        ],
        if (rhrSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.sleepingRhr,
            rhrSpots,
            chronologicalRhr.map((l) => l.date).toList(),
            "bpm",
          ),
          const SizedBox(height: 16),
        ],
        if (hrvSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.sleepingHrv,
            hrvSpots,
            chronologicalHrv.map((l) => l.date).toList(),
            "ms",
          ),
          const SizedBox(height: 16),
        ],
        if (enableAdvanced && awakeSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.timeAwake,
            awakeSpots,
            chronologicalAwake.map((l) => l.date).toList(),
            "h",
          ),
          const SizedBox(height: 16),
        ],
        if (enableAdvanced && tibSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.timeInBed,
            tibSpots,
            chronologicalTib.map((l) => l.date).toList(),
            "h",
          ),
          const SizedBox(height: 16),
        ],
        if (enableAdvanced && awakeningsSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.numberOfAwakenings,
            awakeningsSpots,
            chronologicalAwakenings.map((l) => l.date).toList(),
            "",
          ),
          const SizedBox(height: 16),
        ],
        Text(
          l10n.sleepHistory,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (mergedLogs.isEmpty)
          Center(child: Text(l10n.noSleepLogs))
        else
          ...mergedLogs.map((log) {
            final dateStr = (log is SleepMeasurement)
                ? "${log.date.month}/${log.date.day}/${log.date.year}"
                : "${(log as AdvancedSleepMeasurement).date.month}/${log.date.day}/${log.date.year}";

            if (log is SleepMeasurement) {
              final dur = log.sleepDuration != null
                  ? formatDoubleHours(log.sleepDuration!)
                  : "";
              final rhr = log.sleepingRHR != null
                  ? l10n.sleepingRhrValue('${log.sleepingRHR}')
                  : "";
              final hrv = log.sleepingHRV != null
                  ? l10n.sleepingHrvValue('${log.sleepingHRV}')
                  : "";
              final details = [
                dur,
                rhr,
                hrv,
              ].where((s) => s.isNotEmpty).join(", ");
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    details.isEmpty ? l10n.sleepEntry : details,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(l10n.dateWithValue(dateStr)),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.deleteLog),
                          content: Text(l10n.deleteSleepConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                l10n.delete,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref
                            .read(measurementRepositoryProvider)
                            .deleteSleepMeasurement(log);
                      }
                    },
                  ),
                ),
              );
            } else {
              // AdvancedSleepMeasurement
              final adv = log as AdvancedSleepMeasurement;
              final tib = adv.timeInBed != null
                  ? l10n.sleepMetricBed(formatDoubleHours(adv.timeInBed!))
                  : "";
              final awake = adv.totalAwakeTime != null
                  ? l10n.sleepMetricAwake(
                      formatDoubleHours(adv.totalAwakeTime!),
                    )
                  : "";
              final longest = adv.longestAwakePeriod != null
                  ? l10n.sleepMetricLongestAwake(
                      formatDoubleHours(adv.longestAwakePeriod!),
                    )
                  : "";
              final awakenings = adv.numberOfAwakenings != null
                  ? l10n.awakeningsCount(adv.numberOfAwakenings ?? 0)
                  : "";
              final details = [
                tib,
                awake,
                longest,
                awakenings,
              ].where((s) => s.isNotEmpty).join(", ");
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    details.isEmpty ? l10n.advSleepEntry : details,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(l10n.dateWithValue(dateStr)),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.deleteLog),
                          content: Text(l10n.deleteAdvancedSleepConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                l10n.delete,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref
                            .read(measurementRepositoryProvider)
                            .deleteAdvancedSleepMeasurement(adv);
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

  Widget _buildActivityTab(
    BuildContext context,
    ThemeData theme,
    List<ActivityMeasurement> logs,
  ) {
    final l10n = context.l10n;
    if (logs.isEmpty) {
      return Center(child: Text(l10n.noActivityLogs));
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
          _buildChartCard(
            context,
            theme,
            l10n.dailySteps,
            spots,
            chronologicalSteps.map((l) => l.date).toList(),
            "steps",
          ),
          const SizedBox(height: 16),
        ],
        if (calSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.caloriesActive,
            calSpots,
            chronologicalCals.map((l) => l.date).toList(),
            "kcal",
          ),
          const SizedBox(height: 16),
        ],
        if (vo2Spots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.vo2Max,
            vo2Spots,
            chronologicalVo2.map((l) => l.date).toList(),
            "ml/kg",
          ),
          const SizedBox(height: 16),
        ],
        if (rhrSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.wakingRhr,
            rhrSpots,
            chronologicalRhr.map((l) => l.date).toList(),
            "bpm",
          ),
          const SizedBox(height: 16),
        ],
        if (hrvSpots.length >= 2) ...[
          _buildChartCard(
            context,
            theme,
            l10n.wakingHrv,
            hrvSpots,
            chronologicalHrv.map((l) => l.date).toList(),
            "ms",
          ),
          const SizedBox(height: 16),
        ],
        Text(
          l10n.activityHistory,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...logs.map((log) {
          final dateStr = "${log.date.month}/${log.date.day}/${log.date.year}";
          final steps = log.dailySteps != null
              ? l10n.stepsCount('${log.dailySteps}')
              : "";
          final cal = log.activeEnergyBurned != null
              ? l10n.kcalValue('${log.activeEnergyBurned}')
              : "";
          final vo2 = log.vo2Max != null
              ? l10n.vo2WithValue('${log.vo2Max}')
              : "";
          final rhr = log.wakingRHR != null
              ? l10n.wakingRhrValue('${log.wakingRHR}')
              : "";
          final hrv = log.wakingHRV != null
              ? l10n.wakingHrvValue('${log.wakingHRV}')
              : "";
          final details = [
            steps,
            cal,
            vo2,
            rhr,
            hrv,
          ].where((s) => s.isNotEmpty).join(", ");

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                details.isEmpty ? l10n.activityEntry : details,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l10n.dateWithValue(dateStr)),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.deleteLog),
                      content: Text(l10n.deleteActivityConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            l10n.delete,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref
                        .read(measurementRepositoryProvider)
                        .deleteActivityMeasurement(log);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    ThemeData theme,
    String title,
    List<FlSpot> spots,
    List<DateTime> dates,
    String unit,
  ) {
    if (spots.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final values = spots.map((s) => s.y).toList();
    final latest = values.isNotEmpty ? values.last : 0.0;
    final avg = values.isNotEmpty
        ? values.reduce((a, b) => a + b) / values.length
        : 0.0;
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
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(
                  theme,
                  l10n.latestLabel,
                  "${latest.toStringAsFixed(1)} $unit",
                ),
                _buildMetricItem(
                  theme,
                  l10n.averageLabel,
                  "${avg.toStringAsFixed(1)} $unit",
                ),
                _buildMetricItem(
                  theme,
                  l10n.minMaxLabel,
                  "${minVal.toStringAsFixed(1)} - ${maxVal.toStringAsFixed(1)} $unit",
                ),
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
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.1,
                      ),
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
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
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
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          theme.colorScheme.secondaryContainer,
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
    final l10n = context.l10n;

    // Build active tabs list
    final List<Map<String, dynamic>> activeTabs = [];
    activeTabs.add({
      'title': 'Body',
      'icon': Icons.accessibility_new,
      'type': 'body',
    });

    if (settings.enableSleep) {
      activeTabs.add({'title': 'Sleep', 'icon': Icons.hotel, 'type': 'sleep'});
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
        title: Text(l10n.measurementsTitle),
        navigateBack: () => Navigator.pop(context),
        fabIcon: const Icon(Icons.add),
        fabText: l10n.addLog,
        fabAction: () => _showAddMeasurement(context),
        content: (context, padding) {
          return Padding(
            padding: EdgeInsets.only(top: padding.top),
            child: Builder(
              builder: (context) {
                final weightAsync = ref.watch(allMeasurementsProvider);
                final advBodyAsync = ref.watch(
                  allAdvancedBodyMeasurementsProvider,
                );

                return weightAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text(l10n.errorWithMessage('$err'))),
                  data: (weightLogs) => advBodyAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Center(child: Text(l10n.errorWithMessage('$err'))),
                    data: (advBodyLogs) => _buildBodyTab(
                      context,
                      theme,
                      weightLogs,
                      advBodyLogs,
                      true,
                      settings.unitSystem,
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    return DefaultTabController(
      length: activeTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.measurementsTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            isScrollable: false,
            tabAlignment: TabAlignment.fill,
            tabs: activeTabs.map<Widget>((tab) {
              return Tab(text: tab['title'], icon: Icon(tab['icon']));
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: activeTabs.map<Widget>((tab) {
            final type = tab['type'];
            if (type == 'body') {
              final weightAsync = ref.watch(allMeasurementsProvider);
              final advBodyAsync = ref.watch(
                allAdvancedBodyMeasurementsProvider,
              );

              return weightAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text(l10n.errorWithMessage('$err'))),
                data: (weightLogs) => advBodyAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text(l10n.errorWithMessage('$err'))),
                  data: (advBodyLogs) => _buildBodyTab(
                    context,
                    theme,
                    weightLogs,
                    advBodyLogs,
                    true,
                    settings.unitSystem,
                  ),
                ),
              );
            } else if (type == 'sleep') {
              final sleepAsync = ref.watch(allSleepMeasurementsProvider);
              final advSleepAsync = ref.watch(
                allAdvancedSleepMeasurementsProvider,
              );

              return sleepAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text(l10n.errorWithMessage('$err'))),
                data: (sleepLogs) => advSleepAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text(l10n.errorWithMessage('$err'))),
                  data: (advSleepLogs) => _buildSleepTab(
                    context,
                    theme,
                    sleepLogs,
                    advSleepLogs,
                    true,
                  ),
                ),
              );
            } else {
              // activity
              final activityAsync = ref.watch(allActivityMeasurementsProvider);
              return activityAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text(l10n.errorWithMessage('$err'))),
                data: (logs) => _buildActivityTab(context, theme, logs),
              );
            }
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: Text(l10n.addLog),
          onPressed: () => _showAddMeasurement(context),
        ),
      ),
    );
  }
}

class AddMeasurementDialog extends ConsumerStatefulWidget {
  const AddMeasurementDialog({super.key});

  @override
  ConsumerState<AddMeasurementDialog> createState() =>
      _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends ConsumerState<AddMeasurementDialog> {
  final _weightController = TextEditingController();
  final _bfController = TextEditingController();
  final _muscleController = TextEditingController();
  final _waistController = TextEditingController();

  final _sleepDurHrController = TextEditingController();
  final _sleepDurMinController = TextEditingController();
  final _sleepRhrController = TextEditingController();
  final _sleepHrvController = TextEditingController();

  final _tibHrController = TextEditingController();
  final _tibMinController = TextEditingController();
  final _awakeHrController = TextEditingController();
  final _awakeMinController = TextEditingController();
  final _longestAwakeHrController = TextEditingController();
  final _longestAwakeMinController = TextEditingController();
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
    _sleepDurHrController.dispose();
    _sleepDurMinController.dispose();
    _sleepRhrController.dispose();
    _sleepHrvController.dispose();
    _tibHrController.dispose();
    _tibMinController.dispose();
    _awakeHrController.dispose();
    _awakeMinController.dispose();
    _longestAwakeHrController.dispose();
    _longestAwakeMinController.dispose();
    _awakeningsController.dispose();
    _stepsController.dispose();
    _activeEnergyController.dispose();
    _vo2Controller.dispose();
    _wakingRhrController.dispose();
    _wakingHrvController.dispose();
    super.dispose();
  }

  double? _parseDuration(TextEditingController hr, TextEditingController min) {
    final hStr = hr.text.trim();
    final mStr = min.text.trim();
    if (hStr.isEmpty && mStr.isEmpty) return null;
    final h = double.tryParse(hStr) ?? 0.0;
    final m = double.tryParse(mStr) ?? 0.0;
    return h + (m / 60.0);
  }

  Widget _buildDurationField(
    BuildContext context,
    TextEditingController hrController,
    TextEditingController minController,
    String label,
    IconData icon,
  ) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: hrController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.hrsShort,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.minShort,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isDecimal = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = context.l10n;

    final hasAdvancedBody = settings.enableAdvancedBody;
    final hasSleep = settings.enableSleep;
    final hasAdvancedSleep = settings.enableAdvancedSleep;
    final hasActivity = settings.enableActivity;
    final hasManyFields =
        hasAdvancedBody || hasSleep || hasAdvancedSleep || hasActivity;
    final dialogWidth = hasManyFields ? 550.0 : 340.0;

    return AlertDialog(
      title: Text(l10n.logMeasurement),
      content: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Body weight - always visible
              _buildField(
                _weightController,
                l10n.bodyWeightWithUnit(settings.unitSystem.suffix),
                Icons.scale,
              ),
              const SizedBox(height: 16),

              if (settings.enableAdvancedBody) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  l10n.advancedBodyMetrics,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        _bfController,
                        l10n.bodyFatPercent,
                        Icons.percent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        _muscleController,
                        l10n.muscleMassPercent,
                        Icons.fitness_center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(_waistController, l10n.waistCm, Icons.straighten),
                const SizedBox(height: 16),
              ],

              if (settings.enableSleep) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  l10n.sleepMetrics,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildDurationField(
                  context,
                  _sleepDurHrController,
                  _sleepDurMinController,
                  l10n.sleepDuration,
                  Icons.hotel,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        _sleepRhrController,
                        l10n.sleepingRhr,
                        Icons.favorite,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        _sleepHrvController,
                        l10n.sleepingHrvMs,
                        Icons.monitor_heart,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              if (settings.enableAdvancedSleep) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  l10n.advancedSleepMetrics,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildDurationField(
                  context,
                  _tibHrController,
                  _tibMinController,
                  l10n.timeInBed,
                  Icons.bed,
                ),
                const SizedBox(height: 12),
                _buildDurationField(
                  context,
                  _awakeHrController,
                  _awakeMinController,
                  l10n.totalAwakeTime,
                  Icons.wb_sunny,
                ),
                const SizedBox(height: 12),
                _buildDurationField(
                  context,
                  _longestAwakeHrController,
                  _longestAwakeMinController,
                  l10n.longestAwakePeriod,
                  Icons.alarm,
                ),
                const SizedBox(height: 12),
                _buildField(
                  _awakeningsController,
                  l10n.numberOfAwakenings,
                  Icons.alarm_on,
                  isDecimal: false,
                ),
                const SizedBox(height: 16),
              ],

              if (settings.enableActivity) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  l10n.activityMetrics,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        _stepsController,
                        l10n.dailySteps,
                        Icons.directions_walk,
                        isDecimal: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        _activeEnergyController,
                        l10n.caloriesKcal,
                        Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        _vo2Controller,
                        l10n.vo2Max,
                        Icons.speed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        _wakingRhrController,
                        l10n.wakingRhr,
                        Icons.favorite_border,
                        isDecimal: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(
                  _wakingHrvController,
                  l10n.wakingHrvMs,
                  Icons.healing,
                  isDecimal: false,
                ),
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
            final w =
                parseWeight(_weightController.text, settings.unitSystem) ?? 0.0;
            if (w > 0.0) {
              final newLog = BodyMeasurement(
                id: Random().nextInt(1000000),
                bodyWeight: w,
                date: now,
              );
              await ref
                  .read(measurementRepositoryProvider)
                  .upsertMeasurement(newLog);
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
                await db
                    .into(db.advancedBodyMeasurements)
                    .insertOnConflictUpdate(advBodyLog);
              }
            }

            // Save Sleep
            if (settings.enableSleep) {
              final sleepDur = _parseDuration(
                _sleepDurHrController,
                _sleepDurMinController,
              );
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
                await ref
                    .read(measurementRepositoryProvider)
                    .upsertSleepMeasurement(sleepLog);
              }
            }

            // Save Advanced Sleep
            if (settings.enableAdvancedSleep) {
              final tib = _parseDuration(_tibHrController, _tibMinController);
              final awake = _parseDuration(
                _awakeHrController,
                _awakeMinController,
              );
              final longest = _parseDuration(
                _longestAwakeHrController,
                _longestAwakeMinController,
              );
              final awakenings = int.tryParse(_awakeningsController.text);
              if (tib != null ||
                  awake != null ||
                  longest != null ||
                  awakenings != null) {
                final advSleepLog = AdvancedSleepMeasurement(
                  id: Random().nextInt(1000000),
                  timeInBed: tib,
                  totalAwakeTime: awake,
                  longestAwakePeriod: longest,
                  numberOfAwakenings: awakenings,
                  date: now,
                );
                await ref
                    .read(measurementRepositoryProvider)
                    .upsertAdvancedSleepMeasurement(advSleepLog);
              }
            }

            // Save Activity
            if (settings.enableActivity) {
              final steps = int.tryParse(_stepsController.text);
              final activeEnergy = double.tryParse(
                _activeEnergyController.text,
              );
              final vo2 = double.tryParse(_vo2Controller.text);
              final wakingRhr = int.tryParse(_wakingRhrController.text);
              final wakingHrv = int.tryParse(_wakingHrvController.text);
              if (steps != null ||
                  activeEnergy != null ||
                  vo2 != null ||
                  wakingRhr != null ||
                  wakingHrv != null) {
                final activityLog = ActivityMeasurement(
                  id: Random().nextInt(1000000),
                  dailySteps: steps,
                  activeEnergyBurned: activeEnergy,
                  vo2Max: vo2,
                  wakingRHR: wakingRhr,
                  wakingHRV: wakingHrv,
                  date: now,
                );
                await ref
                    .read(measurementRepositoryProvider)
                    .upsertActivityMeasurement(activityLog);
              }
            }

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
