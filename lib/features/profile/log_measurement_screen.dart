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
import '../../core/db/app_database.dart';
import '../../core/db/measurement_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/util/unit_system.dart';

class LogMeasurementScreen extends ConsumerStatefulWidget {
  const LogMeasurementScreen({super.key});

  @override
  ConsumerState<LogMeasurementScreen> createState() =>
      _LogMeasurementScreenState();
}

class _LogMeasurementScreenState extends ConsumerState<LogMeasurementScreen> {
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

  Future<void> _save() async {
    final settings = ref.read(settingsProvider);
    final now = DateTime.now();

    // Save body weight if entered
    final w = parseWeight(_weightController.text, settings.unitSystem) ?? 0.0;
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
      final awake = _parseDuration(_awakeHrController, _awakeMinController);
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
      final activeEnergy = double.tryParse(_activeEnergyController.text);
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

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.logMeasurement),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontWeight: FontWeight.bold),
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

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: Text(l10n.saveMeasurement),
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
