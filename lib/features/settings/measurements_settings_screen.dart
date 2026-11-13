/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../l10n/app_localizations.dart';

/// Chooses which measurement categories are tracked.
///
/// Advanced sleep depends on sleep: it stays visible but disabled while its
/// parent category is off.
class MeasurementsSettingsScreen extends ConsumerWidget {
  const MeasurementsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsState settings = ref.watch(settingsProvider);
    final SettingsNotifier notifier = ref.read(settingsProvider.notifier);
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    return NexcPage(
      title: l10n.measurementsSettings,
      body: ListView(
        padding: const EdgeInsets.only(
          top: NexcSpacing.md,
          bottom: NexcSpacing.xxl,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NexcSpacing.lg + NexcSpacing.xs,
              0,
              NexcSpacing.lg + NexcSpacing.xs,
              NexcSpacing.md,
            ),
            child: Text(
              l10n.measurementsSettingsDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          NexcSection(
            title: l10n.sectionBody,
            children: [
              NexcTile.toggle(
                icon: NexcIcons.measurements,
                title: l10n.advancedBodyMeasurements,
                subtitle: l10n.advancedBodyMeasurementsDesc,
                value: settings.enableAdvancedBody,
                onChanged: notifier.setEnableAdvancedBody,
              ),
            ],
          ),
          NexcSection(
            title: l10n.sleepMetrics,
            children: [
              NexcTile.toggle(
                icon: NexcIcons.restAlerts,
                title: l10n.sleepMeasurements,
                subtitle: l10n.sleepMeasurementsDesc,
                value: settings.enableSleep,
                onChanged: notifier.setEnableSleep,
              ),
              NexcTile.toggle(
                icon: NexcIcons.statistics,
                title: l10n.advancedSleepMeasurements,
                subtitle: l10n.advancedSleepMeasurementsDesc,
                value: settings.enableAdvancedSleep,
                enabled: settings.enableSleep,
                indent: true,
                onChanged: notifier.setEnableAdvancedSleep,
              ),
            ],
          ),
          NexcSection(
            title: l10n.activityMetrics,
            children: [
              NexcTile.toggle(
                icon: NexcIcons.workout,
                title: l10n.activityMeasurements,
                subtitle: l10n.activityMeasurementsDesc,
                value: settings.enableActivity,
                onChanged: notifier.setEnableActivity,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
