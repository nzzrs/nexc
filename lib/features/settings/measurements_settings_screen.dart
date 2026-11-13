/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';

class MeasurementsSettingsScreen extends ConsumerWidget {
  const MeasurementsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.measurementsSettings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            l10n.measurementsSettingsDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          _buildToggleCard(
            context,
            icon: Icons.hotel_outlined,
            title: l10n.sleepMeasurements,
            subtitle: l10n.sleepMeasurementsDesc,
            value: settings.enableSleep,
            onChanged: (v) => notifier.setEnableSleep(v),
          ),
          const SizedBox(height: 8),

          _buildToggleCard(
            context,
            icon: Icons.nights_stay_outlined,
            title: l10n.advancedSleepMeasurements,
            subtitle: l10n.advancedSleepMeasurementsDesc,
            value: settings.enableAdvancedSleep,
            onChanged: (v) => notifier.setEnableAdvancedSleep(v),
          ),
          const SizedBox(height: 8),

          _buildToggleCard(
            context,
            icon: Icons.directions_run_outlined,
            title: l10n.activityMeasurements,
            subtitle: l10n.activityMeasurementsDesc,
            value: settings.enableActivity,
            onChanged: (v) => notifier.setEnableActivity(v),
          ),
          const SizedBox(height: 8),

          _buildToggleCard(
            context,
            icon: Icons.accessibility_new_outlined,
            title: l10n.advancedBodyMeasurements,
            subtitle: l10n.advancedBodyMeasurementsDesc,
            value: settings.enableAdvancedBody,
            onChanged: (v) => notifier.setEnableAdvancedBody(v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}
