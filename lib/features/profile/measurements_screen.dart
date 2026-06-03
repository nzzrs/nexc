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

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(allMeasurementsProvider);
    final theme = Theme.of(context);

    return NexcScaffold(
      title: const Text("Measurements"),
      navigateBack: () => Navigator.pop(context),
      fabIcon: const Icon(Icons.add),
      fabText: "Add Log",
      fabAction: () => _showAddMeasurement(context),
      content: (context, padding) {
        return measurementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (logs) {
            if (logs.isEmpty) {
              return const Center(child: Text("No measurements recorded yet."));
            }

            final nonNullLogs = logs.whereType<BodyMeasurement>().toList();
            if (nonNullLogs.isEmpty) {
              return const Center(child: Text("No measurements recorded yet."));
            }

            // Create spots for chart
            final chronologicalLogs = nonNullLogs.reversed.toList();
            final spots = chronologicalLogs.asMap().entries.map((entry) {
              final idx = entry.key;
              final val = entry.value.bodyWeight;
              return FlSpot(idx.toDouble(), val);
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (spots.length >= 2) ...[
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Weight Progress",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    color: theme.colorScheme.primary,
                                    barWidth: 3,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: theme.colorScheme.primary.withOpacity(0.15),
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
                                          "${val.toStringAsFixed(1)}kg",
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
                                        if (idx >= 0 && idx < chronologicalLogs.length) {
                                          final date = chronologicalLogs[idx].date;
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  "Log History",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                 ...nonNullLogs.map((log) {
                  final dateStr = "${log.date.month}/${log.date.day}/${log.date.year}";
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        "Weight: ${log.bodyWeight} kg",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Date: $dateStr",
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        onPressed: () {
                          ref.read(measurementRepositoryProvider).deleteMeasurement(log);
                        },
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
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
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _bfController.dispose();
    _muscleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Log Measurement"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Body Weight (kg)"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bfController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Body Fat % (optional)"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _muscleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Muscle Mass % (optional)"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: "Notes"),
            ),
          ],
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
            final w = double.tryParse(_weightController.text) ?? 0.0;
            if (w > 0.0) {
              final bf = int.tryParse(_bfController.text) ?? 0;
              final m = int.tryParse(_muscleController.text) ?? 0;
              final newLog = BodyMeasurement(
                id: Random().nextInt(1000000),
                bodyWeight: w,
                date: DateTime.now(),
              );
              await ref.read(measurementRepositoryProvider).upsertMeasurement(newLog);
              
              if (bf > 0 || m > 0) {
                final advLog = AdvancedBodyMeasurement(
                  id: Random().nextInt(1000000),
                  bodyFatPercentage: Value(bf > 0 ? bf : null),
                  muscleMassPercentage: Value(m > 0 ? m : null),
                  date: DateTime.now(),
                );
                final db = ref.read(measurementRepositoryProvider).db;
                await db.into(db.advancedBodyMeasurements).insertOnConflictUpdate(advLog);
              }
              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
        ),
      ],
    );
  }
}
