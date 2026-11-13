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

import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/db/app_database.dart';
import '../../core/db/measurement_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/unit_system.dart';

/// Form that records every enabled measurement category in one save.
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

  final Map<String, String?> _errors = <String, String?>{};
  bool _saving = false;

  static const String _weightKey = 'weight';
  static const String _bfKey = 'bf';
  static const String _muscleKey = 'muscle';
  static const String _waistKey = 'waist';
  static const String _sleepHrKey = 'sleepHr';
  static const String _sleepMinKey = 'sleepMin';
  static const String _sleepRhrKey = 'sleepRhr';
  static const String _sleepHrvKey = 'sleepHrv';
  static const String _tibHrKey = 'tibHr';
  static const String _tibMinKey = 'tibMin';
  static const String _awakeHrKey = 'awakeHr';
  static const String _awakeMinKey = 'awakeMin';
  static const String _longestHrKey = 'longestHr';
  static const String _longestMinKey = 'longestMin';
  static const String _awakeningsKey = 'awakenings';
  static const String _stepsKey = 'steps';
  static const String _energyKey = 'energy';
  static const String _vo2Key = 'vo2';
  static const String _wakingRhrKey = 'wakingRhr';
  static const String _wakingHrvKey = 'wakingHrv';

  List<TextEditingController> get _controllers => <TextEditingController>[
    _weightController,
    _bfController,
    _muscleController,
    _waistController,
    _sleepDurHrController,
    _sleepDurMinController,
    _sleepRhrController,
    _sleepHrvController,
    _tibHrController,
    _tibMinController,
    _awakeHrController,
    _awakeMinController,
    _longestAwakeHrController,
    _longestAwakeMinController,
    _awakeningsController,
    _stepsController,
    _activeEnergyController,
    _vo2Controller,
    _wakingRhrController,
    _wakingHrvController,
  ];

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _parseDuration(
    TextEditingController hours,
    TextEditingController minutes,
  ) {
    final String hoursText = hours.text.trim();
    final String minutesText = minutes.text.trim();
    if (hoursText.isEmpty && minutesText.isEmpty) return null;
    final double h = double.tryParse(hoursText.replaceAll(',', '.')) ?? 0.0;
    final double m = double.tryParse(minutesText.replaceAll(',', '.')) ?? 0.0;
    return h + (m / 60.0);
  }

  String _invalidFieldMessage(String label) {
    return context.l10n.errorWithMessage(label);
  }

  /// Validates a numeric field, returning true when the text is acceptable.
  bool _validateNumber(
    String key,
    TextEditingController controller,
    String label, {
    bool integer = false,
    bool positive = false,
    bool minutes = false,
  }) {
    final String text = controller.text.trim();
    if (text.isEmpty) return true;
    final double? value = double.tryParse(text.replaceAll(',', '.'));
    final bool invalid =
        value == null ||
        !value.isFinite ||
        value < 0 ||
        (positive && value <= 0) ||
        (integer && value != value.roundToDouble()) ||
        (minutes && value > 59);
    if (invalid) {
      _errors[key] = _invalidFieldMessage(label);
      return false;
    }
    return true;
  }

  bool _validate(SettingsState settings) {
    _errors.clear();
    final l10n = context.l10n;
    bool valid = true;

    final String weightLabel = l10n.bodyWeightWithUnit(
      settings.unitSystem.suffix,
    );
    final String weightText = _weightController.text.trim();
    if (weightText.isNotEmpty) {
      final double? kilograms = parseWeight(weightText, settings.unitSystem);
      if (kilograms == null || kilograms <= 0) {
        _errors[_weightKey] = _invalidFieldMessage(weightLabel);
        valid = false;
      }
    }

    if (settings.enableAdvancedBody) {
      valid =
          _validateNumber(
            _bfKey,
            _bfController,
            l10n.bodyFatPercent,
            integer: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _muscleKey,
            _muscleController,
            l10n.muscleMassPercent,
            integer: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _waistKey,
            _waistController,
            l10n.waistCm,
            positive: true,
          ) &&
          valid;
    }

    if (settings.enableSleep) {
      valid =
          _validateNumber(
            _sleepHrKey,
            _sleepDurHrController,
            l10n.sleepDuration,
            integer: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _sleepMinKey,
            _sleepDurMinController,
            l10n.sleepDuration,
            integer: true,
            minutes: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _sleepRhrKey,
            _sleepRhrController,
            l10n.sleepingRhr,
            integer: true,
            positive: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _sleepHrvKey,
            _sleepHrvController,
            l10n.sleepingHrv,
            integer: true,
            positive: true,
          ) &&
          valid;
    }

    if (settings.enableAdvancedSleep) {
      valid =
          _validateNumber(
            _tibHrKey,
            _tibHrController,
            l10n.timeInBed,
            integer: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _tibMinKey,
            _tibMinController,
            l10n.timeInBed,
            integer: true,
            minutes: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _awakeHrKey,
            _awakeHrController,
            l10n.totalAwakeTime,
            integer: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _awakeMinKey,
            _awakeMinController,
            l10n.totalAwakeTime,
            integer: true,
            minutes: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _longestHrKey,
            _longestAwakeHrController,
            l10n.longestAwakePeriod,
            integer: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _longestMinKey,
            _longestAwakeMinController,
            l10n.longestAwakePeriod,
            integer: true,
            minutes: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _awakeningsKey,
            _awakeningsController,
            l10n.numberOfAwakenings,
            integer: true,
          ) &&
          valid;
    }

    if (settings.enableActivity) {
      valid =
          _validateNumber(
            _stepsKey,
            _stepsController,
            l10n.dailySteps,
            integer: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _energyKey,
            _activeEnergyController,
            l10n.caloriesActive,
            positive: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _vo2Key,
            _vo2Controller,
            l10n.vo2Max,
            positive: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _wakingRhrKey,
            _wakingRhrController,
            l10n.wakingRhr,
            integer: true,
            positive: true,
          ) &&
          valid;
      valid =
          _validateNumber(
            _wakingHrvKey,
            _wakingHrvController,
            l10n.wakingHrv,
            integer: true,
            positive: true,
          ) &&
          valid;
    }

    final bool anyValue = _controllers.any(
      (TextEditingController controller) => controller.text.trim().isNotEmpty,
    );
    if (!anyValue) {
      _errors[_weightKey] = _invalidFieldMessage(weightLabel);
      valid = false;
    }

    setState(() {});
    return valid;
  }

  int? _intValue(TextEditingController controller) {
    final String text = controller.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  Future<void> _save() async {
    if (_saving) return;
    final SettingsState settings = ref.read(settingsProvider);
    if (!_validate(settings)) return;

    setState(() => _saving = true);
    final DateTime now = DateTime.now();
    final MeasurementRepository repository = ref.read(
      measurementRepositoryProvider,
    );

    // Body weight, stored in kilograms.
    final String weightText = _weightController.text.trim();
    if (weightText.isNotEmpty) {
      final double? kilograms = parseWeight(weightText, settings.unitSystem);
      if (kilograms != null && kilograms > 0) {
        await repository.upsertMeasurement(
          BodyMeasurement(
            id: Random().nextInt(1000000),
            bodyWeight: kilograms,
            date: now,
          ),
        );
      }
    }

    if (settings.enableAdvancedBody) {
      final int? bf = _intValue(_bfController);
      final int? muscle = _intValue(_muscleController);
      final double? waist = double.tryParse(
        _waistController.text.trim().replaceAll(',', '.'),
      );
      if (bf != null || muscle != null || waist != null) {
        await repository.upsertAdvancedBodyMeasurement(
          AdvancedBodyMeasurement(
            id: Random().nextInt(1000000),
            bodyFatPercentage: bf,
            muscleMassPercentage: muscle,
            waistCircumference: waist,
            date: now,
          ),
        );
      }
    }

    if (settings.enableSleep) {
      final double? duration = _parseDuration(
        _sleepDurHrController,
        _sleepDurMinController,
      );
      final int? rhr = _intValue(_sleepRhrController);
      final int? hrv = _intValue(_sleepHrvController);
      if (duration != null || rhr != null || hrv != null) {
        await repository.upsertSleepMeasurement(
          SleepMeasurement(
            id: Random().nextInt(1000000),
            sleepDuration: duration,
            sleepingRHR: rhr,
            sleepingHRV: hrv,
            date: now,
          ),
        );
      }
    }

    if (settings.enableAdvancedSleep) {
      final double? timeInBed = _parseDuration(
        _tibHrController,
        _tibMinController,
      );
      final double? awake = _parseDuration(
        _awakeHrController,
        _awakeMinController,
      );
      final double? longest = _parseDuration(
        _longestAwakeHrController,
        _longestAwakeMinController,
      );
      final int? awakenings = _intValue(_awakeningsController);
      if (timeInBed != null ||
          awake != null ||
          longest != null ||
          awakenings != null) {
        await repository.upsertAdvancedSleepMeasurement(
          AdvancedSleepMeasurement(
            id: Random().nextInt(1000000),
            timeInBed: timeInBed,
            totalAwakeTime: awake,
            longestAwakePeriod: longest,
            numberOfAwakenings: awakenings,
            date: now,
          ),
        );
      }
    }

    if (settings.enableActivity) {
      final int? steps = _intValue(_stepsController);
      final double? energy = double.tryParse(
        _activeEnergyController.text.trim().replaceAll(',', '.'),
      );
      final double? vo2 = double.tryParse(
        _vo2Controller.text.trim().replaceAll(',', '.'),
      );
      final int? wakingRhr = _intValue(_wakingRhrController);
      final int? wakingHrv = _intValue(_wakingHrvController);
      if (steps != null ||
          energy != null ||
          vo2 != null ||
          wakingRhr != null ||
          wakingHrv != null) {
        await repository.upsertActivityMeasurement(
          ActivityMeasurement(
            id: Random().nextInt(1000000),
            dailySteps: steps,
            activeEnergyBurned: energy,
            vo2Max: vo2,
            wakingRHR: wakingRhr,
            wakingHRV: wakingHrv,
            date: now,
          ),
        );
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _field({
    required String fieldKey,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool decimal = true,
  }) {
    return TextField(
      key: ValueKey<String>(fieldKey),
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        errorText: _errors[fieldKey],
      ),
      onChanged: (String value) {
        if (_errors[fieldKey] != null) {
          setState(() => _errors.remove(fieldKey));
        }
      },
    );
  }

  Widget _durationField({
    required String hourKey,
    required String minuteKey,
    required TextEditingController hourController,
    required TextEditingController minuteController,
    required String label,
    required IconData icon,
  }) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: NexcSpacing.sm),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: NexcSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        _responsivePair(
          _field(
            fieldKey: hourKey,
            controller: hourController,
            label: l10n.hrsShort,
            icon: NexcIcons.timer,
            decimal: false,
          ),
          _field(
            fieldKey: minuteKey,
            controller: minuteController,
            label: l10n.minShort,
            icon: NexcIcons.timer,
            decimal: false,
          ),
        ),
      ],
    );
  }

  /// Stacks two fields below 420dp so long labels keep their room.
  Widget _responsivePair(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              const SizedBox(height: NexcSpacing.md),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: NexcSpacing.md),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsState settings = ref.watch(settingsProvider);
    final l10n = context.l10n;

    return NexcPage(
      title: l10n.logMeasurement,
      body: ListView(
        padding: const EdgeInsets.only(bottom: NexcSpacing.xxl),
        children: [
          NexcSection(
            title: l10n.sectionBody,
            padded: true,
            children: [
              _field(
                fieldKey: _weightKey,
                controller: _weightController,
                label: l10n.bodyWeightWithUnit(settings.unitSystem.suffix),
                icon: NexcIcons.measurements,
              ),
            ],
          ),
          if (settings.enableAdvancedBody)
            NexcSection(
              title: l10n.advancedBodyMetrics,
              padded: true,
              children: [
                _responsivePair(
                  _field(
                    fieldKey: _bfKey,
                    controller: _bfController,
                    label: l10n.bodyFatPercent,
                    icon: NexcIcons.statistics,
                    decimal: false,
                  ),
                  _field(
                    fieldKey: _muscleKey,
                    controller: _muscleController,
                    label: l10n.muscleMassPercent,
                    icon: NexcIcons.exercises,
                    decimal: false,
                  ),
                ),
                const SizedBox(height: NexcSpacing.md),
                _field(
                  fieldKey: _waistKey,
                  controller: _waistController,
                  label: l10n.waistCm,
                  icon: NexcIcons.units,
                ),
              ],
            ),
          if (settings.enableSleep)
            NexcSection(
              title: l10n.sleepMetrics,
              padded: true,
              children: [
                _durationField(
                  hourKey: _sleepHrKey,
                  minuteKey: _sleepMinKey,
                  hourController: _sleepDurHrController,
                  minuteController: _sleepDurMinController,
                  label: l10n.sleepDuration,
                  icon: NexcIcons.timer,
                ),
                const SizedBox(height: NexcSpacing.md),
                _responsivePair(
                  _field(
                    fieldKey: _sleepRhrKey,
                    controller: _sleepRhrController,
                    label: l10n.sleepingRhr,
                    icon: NexcIcons.statistics,
                    decimal: false,
                  ),
                  _field(
                    fieldKey: _sleepHrvKey,
                    controller: _sleepHrvController,
                    label: l10n.sleepingHrvMs,
                    icon: NexcIcons.statistics,
                    decimal: false,
                  ),
                ),
              ],
            ),
          if (settings.enableAdvancedSleep)
            NexcSection(
              title: l10n.advancedSleepMetrics,
              padded: true,
              children: [
                _durationField(
                  hourKey: _tibHrKey,
                  minuteKey: _tibMinKey,
                  hourController: _tibHrController,
                  minuteController: _tibMinController,
                  label: l10n.timeInBed,
                  icon: NexcIcons.timer,
                ),
                const SizedBox(height: NexcSpacing.md),
                _durationField(
                  hourKey: _awakeHrKey,
                  minuteKey: _awakeMinKey,
                  hourController: _awakeHrController,
                  minuteController: _awakeMinController,
                  label: l10n.totalAwakeTime,
                  icon: NexcIcons.timer,
                ),
                const SizedBox(height: NexcSpacing.md),
                _durationField(
                  hourKey: _longestHrKey,
                  minuteKey: _longestMinKey,
                  hourController: _longestAwakeHrController,
                  minuteController: _longestAwakeMinController,
                  label: l10n.longestAwakePeriod,
                  icon: NexcIcons.timer,
                ),
                const SizedBox(height: NexcSpacing.md),
                _field(
                  fieldKey: _awakeningsKey,
                  controller: _awakeningsController,
                  label: l10n.numberOfAwakenings,
                  icon: NexcIcons.statistics,
                  decimal: false,
                ),
              ],
            ),
          if (settings.enableActivity)
            NexcSection(
              title: l10n.activityMetrics,
              padded: true,
              children: [
                _responsivePair(
                  _field(
                    fieldKey: _stepsKey,
                    controller: _stepsController,
                    label: l10n.dailySteps,
                    icon: NexcIcons.exercises,
                    decimal: false,
                  ),
                  _field(
                    fieldKey: _energyKey,
                    controller: _activeEnergyController,
                    label: l10n.caloriesKcal,
                    icon: NexcIcons.streak,
                  ),
                ),
                const SizedBox(height: NexcSpacing.md),
                _responsivePair(
                  _field(
                    fieldKey: _vo2Key,
                    controller: _vo2Controller,
                    label: l10n.vo2Max,
                    icon: NexcIcons.intensity,
                  ),
                  _field(
                    fieldKey: _wakingRhrKey,
                    controller: _wakingRhrController,
                    label: l10n.wakingRhr,
                    icon: NexcIcons.statistics,
                    decimal: false,
                  ),
                ),
                const SizedBox(height: NexcSpacing.md),
                _field(
                  fieldKey: _wakingHrvKey,
                  controller: _wakingHrvController,
                  label: l10n.wakingHrvMs,
                  icon: NexcIcons.statistics,
                  decimal: false,
                ),
              ],
            ),
        ],
      ),
      bottomBar: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(NexcIcons.check),
          label: Text(l10n.saveMeasurement),
        ),
      ),
    );
  }
}
