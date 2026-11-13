/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Behaviour ported from LibreFit's BarbellCalculatorModalBottomSheet.kt
 * (commit 8db76211).
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/settings_provider.dart';
import '../../core/util/plate_calculator.dart';
import '../../core/util/unit_system.dart';

/// Opens the barbell plate calculator over the current screen.
Future<void> showBarbellCalculatorSheet(
  BuildContext context, {
  required double initialTargetWeightKg,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        BarbellCalculatorSheet(initialTargetWeightKg: initialTargetWeightKg),
  );
}

/// Calculates the plates needed per side for a target weight and bar.
///
/// All math runs in kilograms; values are displayed in the user's chosen unit
/// system. The selected bar is remembered in the settings provider.
class BarbellCalculatorSheet extends ConsumerStatefulWidget {
  const BarbellCalculatorSheet({
    super.key,
    required this.initialTargetWeightKg,
  });

  /// Target total weight, including the bar, in kilograms.
  final double initialTargetWeightKg;

  @override
  ConsumerState<BarbellCalculatorSheet> createState() =>
      _BarbellCalculatorSheetState();
}

class _BarbellCalculatorSheetState
    extends ConsumerState<BarbellCalculatorSheet> {
  late final TextEditingController _targetController;
  late double _targetKg;
  late double _barKg;
  bool _includeSmallPlates = true;

  @override
  void initState() {
    super.initState();
    final SettingsState settings = ref.read(settingsProvider);
    final UnitSystem system = settings.unitSystem;

    _targetKg =
        widget.initialTargetWeightKg.isFinite &&
            widget.initialTargetWeightKg > 0
        ? widget.initialTargetWeightKg
        : 0.0;
    _targetController = TextEditingController(
      text: _targetKg > 0 ? formatWeight(_targetKg, system) : '',
    );
    _barKg = _initialBarKg(settings);
  }

  /// Picks the remembered bar when it matches a standard bar, otherwise the
  /// standard bar the user is most likely to need.
  double _initialBarKg(SettingsState settings) {
    final List<double> bars = standardBarsFor(settings.unitSystem);
    final double? saved = settings.defaultBarWeightKg;
    if (saved != null) {
      for (final double bar in bars) {
        if ((bar - saved).abs() < 1e-6) return bar;
      }
    }
    return bars.first;
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _selectBar(double barKg) {
    setState(() => _barKg = barKg);
    ref.read(settingsProvider.notifier).setDefaultBarWeightKg(barKg);
  }

  void _confirm() {
    ref.read(settingsProvider.notifier).setDefaultBarWeightKg(_barKg);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final UnitSystem system = ref.watch(
      settingsProvider.select((settings) => settings.unitSystem),
    );
    final List<double> bars = standardBarsFor(system);
    final List<double> plates = filterSmallPlates(
      standardPlatesFor(system),
      includeSmallPlates: _includeSmallPlates,
      system: system,
    );
    final PlateBreakdown breakdown = calculatePlates(
      targetKg: _targetKg,
      barKg: _barKg,
      availablePlatesKg: plates,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Plate calculator',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('Bar', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final double bar in bars)
                    ChoiceChip(
                      label: Text(
                        formatWeight(bar, system, suffix: system.suffix),
                      ),
                      selected: (bar - _barKg).abs() < 1e-6,
                      onSelected: (_) => _selectBar(bar),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Target weight',
                  suffixText: system.suffix,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (String text) {
                  setState(() {
                    _targetKg = parseWeight(text, system) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Include small plates'),
                value: _includeSmallPlates,
                onChanged: (bool value) {
                  setState(() => _includeSmallPlates = value);
                },
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Per side',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (breakdown.platesPerSideKg.isEmpty)
                Text(
                  'No plates needed',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                for (final MapEntry<double, int> entry
                    in breakdown.platesPerSideKg.entries)
                  _PlateRow(
                    key: ValueKey<String>('plate_${entry.key}'),
                    label: formatWeight(
                      entry.key,
                      system,
                      suffix: system.suffix,
                    ),
                    count: entry.value,
                  ),
              const SizedBox(height: 12),
              if (breakdown.remainderKg > 1e-9)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cannot hit exactly — '
                          '${formatWeight(breakdown.remainderKg, system, suffix: system.suffix)} '
                          'left over per side',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'Closest achievable: '
                '${formatWeight(breakdown.closestAchievableKg, system, suffix: system.suffix)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _confirm, child: const Text('Done')),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlateRow extends StatelessWidget {
  const _PlateRow({super.key, required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '× $count',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
