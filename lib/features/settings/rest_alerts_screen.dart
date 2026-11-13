/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark
 * usage; see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the
 * project root.
 */

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/rest_alert_audio.dart';

/// Sound and vibration preferences for the rest timer.
///
/// The sub-page keeps the two dependent toggles together and offers a way to
/// preview the alert without starting a workout.
class RestAlertsScreen extends ConsumerStatefulWidget {
  const RestAlertsScreen({super.key});

  @override
  ConsumerState<RestAlertsScreen> createState() => _RestAlertsScreenState();
}

class _RestAlertsScreenState extends ConsumerState<RestAlertsScreen> {
  bool _testing = false;

  Future<void> _testAlert() async {
    if (_testing) return;
    setState(() => _testing = true);
    final SettingsState settings = ref.read(settingsProvider);
    try {
      if (settings.restTimerVibrationOn && !kIsWeb) {
        if (await Vibration.hasVibrator()) {
          await Vibration.vibrate(pattern: <int>[0, 400, 100, 400]);
        }
      }
      if (settings.restTimerSoundOn) {
        final AudioPlayer player = AudioPlayer();
        try {
          await playRestAlert(player, AssetSource(restAlertSoundAsset));
        } finally {
          await player.dispose();
        }
      }
    } catch (_) {
      // A missing audio device or vibrator must never block the preview.
    } finally {
      if (mounted) setState(() => _testing = false);
    }
    if (!mounted) return;
    NexcSnack.show(context, context.l10n.testAlert);
  }

  @override
  Widget build(BuildContext context) {
    final SettingsState settings = ref.watch(settingsProvider);
    final SettingsNotifier notifier = ref.read(settingsProvider.notifier);
    final l10n = context.l10n;

    return NexcPage(
      title: l10n.restAlerts,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NexcSection(
              title: l10n.workoutAlerts,
              description: l10n.restAlertsDesc,
              children: [
                NexcTile.toggle(
                  title: l10n.restTimerSound,
                  subtitle: settings.restTimerSoundOn
                      ? l10n.soundEnabled
                      : l10n.soundDisabled,
                  icon: NexcIcons.sound,
                  value: settings.restTimerSoundOn,
                  onChanged: notifier.setRestTimerSoundOn,
                ),
                NexcTile.toggle(
                  title: l10n.restTimerVibration,
                  subtitle: settings.restTimerVibrationOn
                      ? l10n.vibrationEnabled
                      : l10n.vibrationDisabled,
                  icon: NexcIcons.vibration,
                  value: settings.restTimerVibrationOn,
                  onChanged: notifier.setRestTimerVibrationOn,
                ),
                Padding(
                  padding: const EdgeInsets.all(NexcSpacing.lg),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton.tonalIcon(
                      onPressed: _testing ? null : _testAlert,
                      icon: const Icon(NexcIcons.restAlerts, size: 20),
                      label: Text(l10n.testAlert),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: NexcSpacing.xl),
          ],
        ),
      ),
    );
  }
}
