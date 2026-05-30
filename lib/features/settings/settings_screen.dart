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
import '../../core/providers/settings_provider.dart';
import '../../core/db/enums.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showSingleChoiceDialog<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required T selectedValue,
    required String Function(T) labelBuilder,
    required void Function(T) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                return RadioListTile<T>(
                  title: Text(labelBuilder(option)),
                  value: option,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    if (value != null) {
                      onSelected(value);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _getLanguageLabel(Language lang) {
    switch (lang) {
      case Language.system:
        return 'System';
      case Language.english:
        return 'English';
      case Language.italian:
        return 'Italian';
      case Language.german:
        return 'German';
      case Language.dutch:
        return 'Dutch';
      case Language.czech:
        return 'Czech';
      case Language.simplifiedChinese:
        return 'Simplified Chinese';
      case Language.spanish:
        return 'Spanish';
    }
  }

  String _getFormulaLabel(OneRepMaxFormula formula) {
    switch (formula) {
      case OneRepMaxFormula.balanced:
        return 'Balanced';
      case OneRepMaxFormula.epley:
        return 'Epley';
      case OneRepMaxFormula.brzycki:
        return 'Brzycki';
      case OneRepMaxFormula.mcglothin:
        return 'McGlothin';
      case OneRepMaxFormula.lombardi:
        return 'Lombardi';
      case OneRepMaxFormula.mayhew:
        return 'Mayhew';
      case OneRepMaxFormula.oConner:
        return 'O\'Conner';
      case OneRepMaxFormula.wathen:
        return 'Wathen';
    }
  }

  String _getIntensityScaleLabel(IntensityScale scale) {
    switch (scale) {
      case IntensityScale.rpe:
        return 'RPE';
      case IntensityScale.rir:
        return 'RIR';
      case IntensityScale.both:
        return 'Both';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // Appearance
          _buildSectionHeader(context, 'Appearance'),
          _SettingItem(
            settingName: 'Theme',
            settingDesc: _getThemeModeLabel(settings.themeMode),
            icon: Icons.dark_mode_outlined,
            onClick: () {
              _showSingleChoiceDialog<ThemeMode>(
                context: context,
                title: 'Select theme',
                options: ThemeMode.values,
                selectedValue: settings.themeMode,
                labelBuilder: _getThemeModeLabel,
                onSelected: notifier.setThemeMode,
              );
            },
          ),
          _SettingItem(
            settingName: 'Material You',
            settingDesc: settings.materialMode ? 'Dynamic color enabled' : 'Dynamic color disabled',
            icon: Icons.color_lens_outlined,
            isChecked: settings.materialMode,
            onClick: () => notifier.setMaterialMode(!settings.materialMode),
          ),

          const SizedBox(height: 16),

          // General settings
          _buildSectionHeader(context, 'General settings'),
          _SettingItem(
            settingName: 'Language',
            settingDesc: _getLanguageLabel(settings.language),
            icon: Icons.translate,
            onClick: () {
              _showSingleChoiceDialog<Language>(
                context: context,
                title: 'Select language',
                options: Language.values,
                selectedValue: settings.language,
                labelBuilder: _getLanguageLabel,
                onSelected: notifier.setLanguage,
              );
            },
          ),
          _SettingItem(
            settingName: 'Keep screen on',
            settingDesc: settings.workoutScreenOn ? 'Screen will stay on' : 'Screen will turn off normally',
            icon: Icons.stay_current_portrait_outlined,
            isChecked: settings.workoutScreenOn,
            onClick: () => notifier.setWorkoutScreenOn(!settings.workoutScreenOn),
          ),
          _SettingItem(
            settingName: 'Rest timer sound',
            settingDesc: settings.restTimerSoundOn ? 'Sound enabled' : 'Sound disabled',
            icon: Icons.notifications_active_outlined,
            isChecked: settings.restTimerSoundOn,
            onClick: () => notifier.setRestTimerSoundOn(!settings.restTimerSoundOn),
          ),
          _SettingItem(
            settingName: 'Rest timer vibration',
            settingDesc: settings.restTimerVibrationOn ? 'Vibration enabled' : 'Vibration disabled',
            icon: Icons.vibration,
            isChecked: settings.restTimerVibrationOn,
            onClick: () => notifier.setRestTimerVibrationOn(!settings.restTimerVibrationOn),
          ),
          _SettingItem(
            settingName: 'Sticky status bar',
            settingDesc: settings.isWorkoutHeaderSticky ? 'Status bar is sticky' : 'Status bar is not sticky',
            icon: Icons.push_pin_outlined,
            isChecked: settings.isWorkoutHeaderSticky,
            onClick: () => notifier.setIsWorkoutHeaderSticky(!settings.isWorkoutHeaderSticky),
          ),
          _SettingItem(
            settingName: '1RM Formula',
            settingDesc: _getFormulaLabel(settings.oneRepMaxFormula),
            icon: Icons.calculate_outlined,
            onClick: () {
              _showSingleChoiceDialog<OneRepMaxFormula>(
                context: context,
                title: 'Select 1RM Formula',
                options: OneRepMaxFormula.values,
                selectedValue: settings.oneRepMaxFormula,
                labelBuilder: _getFormulaLabel,
                onSelected: notifier.setOneRepMaxFormula,
              );
            },
          ),
          _SettingItem(
            settingName: 'Sleep mode',
            settingDesc: settings.sleepModeEnabled ? 'Sleep mode enabled' : 'Sleep mode disabled',
            icon: Icons.bedtime_outlined,
            isChecked: settings.sleepModeEnabled,
            onClick: () => notifier.setSleepModeEnabled(!settings.sleepModeEnabled),
          ),
          _SettingItem(
            settingName: 'RPE/RIR intensity',
            settingDesc: settings.showRpe ? 'Show scale selection' : 'Hide scale selection',
            icon: Icons.timer_outlined,
            isChecked: settings.showRpe,
            onClick: () => notifier.setShowRpe(!settings.showRpe),
          ),
          if (settings.showRpe)
            _SettingItem(
              settingName: 'Intensity scale',
              settingDesc: _getIntensityScaleLabel(settings.intensityScale),
              icon: Icons.line_weight,
              onClick: () {
                _showSingleChoiceDialog<IntensityScale>(
                  context: context,
                  title: 'Select intensity scale',
                  options: IntensityScale.values,
                  selectedValue: settings.intensityScale,
                  labelBuilder: _getIntensityScaleLabel,
                  onSelected: notifier.setIntensityScale,
                );
              },
            ),
          _SettingItem(
            settingName: 'Backup & Restore',
            settingDesc: 'Backup and restore your data',
            icon: Icons.backup_outlined,
            onClick: () {
              Navigator.pushNamed(context, '/backup');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String settingName;
  final String settingDesc;
  final IconData icon;
  final VoidCallback onClick;
  final bool? isChecked;

  const _SettingItem({
    required this.settingName,
    required this.settingDesc,
    required this.icon,
    required this.onClick,
    this.isChecked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onClick,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settingName,
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settingDesc,
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isChecked != null)
                  Switch(
                    value: isChecked!,
                    onChanged: (val) => onClick(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
