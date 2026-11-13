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
import '../../core/util/unit_system.dart';

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
            child: RadioGroup<T>(
              groupValue: selectedValue,
              onChanged: (value) {
                if (value != null) {
                  onSelected(value);
                  Navigator.pop(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((option) {
                  return RadioListTile<T>(
                    title: Text(labelBuilder(option)),
                    value: option,
                  );
                }).toList(),
              ),
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

  String _getIntensityScaleLabel(IntensityScale scale) {
    switch (scale) {
      case IntensityScale.none:
        return 'None (disabled)';
      case IntensityScale.rpe:
        return 'RPE';
      case IntensityScale.rir:
        return 'RIR';
      case IntensityScale.both:
        return 'Both';
    }
  }

  String _getUnitSystemLabel(UnitSystem system) {
    switch (system) {
      case UnitSystem.metric:
        return 'Metric';
      case UnitSystem.imperial:
        return 'Imperial';
    }
  }

  String _getRoutineUpdateModeLabel(RoutineUpdateMode mode) {
    switch (mode) {
      case RoutineUpdateMode.never:
        return 'Never';
      case RoutineUpdateMode.always:
        return 'Always';
      case RoutineUpdateMode.ask:
        return 'Ask';
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
          _SettingItem(
            settingName: 'Show exercise images',
            settingDesc: settings.showExerciseImages ? 'Images shown' : 'Images hidden',
            icon: Icons.image_outlined,
            isChecked: settings.showExerciseImages,
            onClick: () => notifier.setShowExerciseImages(!settings.showExerciseImages),
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
            settingName: 'Unit system',
            settingDesc: _getUnitSystemLabel(settings.unitSystem),
            icon: Icons.scale_outlined,
            onClick: () {
              _showSingleChoiceDialog<UnitSystem>(
                context: context,
                title: 'Select unit system',
                options: UnitSystem.values,
                selectedValue: settings.unitSystem,
                labelBuilder: _getUnitSystemLabel,
                onSelected: notifier.setUnitSystem,
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
            settingName: 'Sticky workout status bar',
            settingDesc: settings.isWorkoutHeaderSticky ? 'Status bar is sticky' : 'Status bar is not sticky',
            icon: Icons.push_pin_outlined,
            isChecked: settings.isWorkoutHeaderSticky,
            onClick: () => notifier.setIsWorkoutHeaderSticky(!settings.isWorkoutHeaderSticky),
          ),
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
            onInfoClick: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Intensity Scales (RPE & RIR)'),
                  content: const Text(
                    '• RPE (Rate of Perceived Exertion): A 1-10 scale measuring how hard a set felt. 10 is maximum effort (no more reps possible), 9 means you could do 1 more rep, 8 means 2 more, etc.\n\n'
                    '• RIR (Reps in Reserve): The number of reps you could have performed before hitting failure. 0 RIR is equivalent to 10 RPE.\n\n'
                    'Use them to monitor and adjust intensity dynamically without always going to absolute muscle failure.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),

          _SettingItem(
            settingName: 'Update routine after workout',
            settingDesc: _getRoutineUpdateModeLabel(settings.routineUpdateMode),
            icon: Icons.refresh,
            onClick: () {
              _showSingleChoiceDialog<RoutineUpdateMode>(
                context: context,
                title: 'Update routine after workout',
                options: RoutineUpdateMode.values,
                selectedValue: settings.routineUpdateMode,
                labelBuilder: _getRoutineUpdateModeLabel,
                onSelected: notifier.setRoutineUpdateMode,
              );
            },
          ),

          _SettingItem(
            settingName: 'Scroll wheel input',
            settingDesc: settings.useScrollWheelForInput
                ? 'Tap a value to open the picker'
                : 'Inline text fields',
            icon: Icons.unfold_more,
            isChecked: settings.useScrollWheelForInput,
            onClick: () => notifier.setUseScrollWheelForInput(!settings.useScrollWheelForInput),
          ),
          if (settings.useScrollWheelForInput)
            _SettingItem(
              settingName: 'Dismiss scroll wheel automatically',
              settingDesc: settings.dismissScrollWheelInputAutomatically
                  ? 'Closes after a short pause'
                  : 'Confirm with Done',
              icon: Icons.close_fullscreen,
              isChecked: settings.dismissScrollWheelInputAutomatically,
              onClick: () => notifier.setDismissScrollWheelInputAutomatically(
                !settings.dismissScrollWheelInputAutomatically,
              ),
            ),

          const SizedBox(height: 16),

          // Navigation buttons
          _buildSectionHeader(context, 'Data & Configuration'),
          _SettingItem(
            settingName: 'Measurements Settings',
            settingDesc: 'Configure which measurements to track',
            icon: Icons.monitor_weight_outlined,
            onClick: () {
              Navigator.pushNamed(context, '/settings/measurements');
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

          const SizedBox(height: 16),

          // Features Configuration
          _buildSectionHeader(context, 'Features Configuration'),
          _SettingItem(
            settingName: 'Meal Tracking',
            settingDesc: settings.enableMealTracking ? 'Meal tracking enabled' : 'Meal tracking disabled',
            icon: Icons.restaurant_outlined,
            isChecked: settings.enableMealTracking,
            onClick: () => notifier.setEnableMealTracking(!settings.enableMealTracking),
          ),
          if (settings.enableMealTracking) ...[
            _SettingItem(
              settingName: 'Day start hour',
              settingDesc: 'New day starts at ${settings.dayStartHour.toString().padLeft(2, '0')}:00',
              icon: Icons.access_time,
              onClick: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: settings.dayStartHour, minute: 0),
                );
                if (picked != null) {
                  notifier.setDayStartHour(picked.hour);
                }
              },
            ),
            _SettingItem(
              settingName: 'Default macros override plans',
              settingDesc: settings.defaultMacrosOverrideMealPlan
                  ? 'Default target macros always override meal plan targets'
                  : 'Meal plan targets take precedence when available',
              icon: Icons.lock_outline,
              isChecked: settings.defaultMacrosOverrideMealPlan,
              onClick: () => notifier.setDefaultMacrosOverrideMealPlan(!settings.defaultMacrosOverrideMealPlan),
            ),
          ],
          _SettingItem(
            settingName: 'Stock Tracking',
            settingDesc: !settings.enableMealTracking
                ? 'Requires Meal Tracking'
                : (settings.enableStockTracking ? 'Stock tracking enabled' : 'Stock tracking disabled'),
            icon: Icons.inventory_2_outlined,
            isChecked: settings.enableStockTracking,
            enabled: settings.enableMealTracking,
            onClick: () => notifier.setEnableStockTracking(!settings.enableStockTracking),
          ),

          const SizedBox(height: 16),

          // AI Integrations
          _buildSectionHeader(context, 'AI Integrations'),
          _SettingItem(
            settingName: 'AI Stock Logging',
            settingDesc: 'Log stock via receipt photo uploads',
            icon: Icons.receipt_long_outlined,
            isChecked: settings.enableAiStockLogging,
            onClick: () => notifier.setEnableAiStockLogging(!settings.enableAiStockLogging),
          ),
          _SettingItem(
            settingName: 'AI Product Creation',
            settingDesc: 'Autofill nutrition details using AI predictions',
            icon: Icons.auto_awesome_outlined,
            isChecked: settings.enableAiProductCreation,
            onClick: () => notifier.setEnableAiProductCreation(!settings.enableAiProductCreation),
          ),

          // Workout AI Generator
          _buildSectionHeader(context, 'AI Features & Privacy'),
          _SettingItem(
            settingName: 'AI Workout Creator',
            settingDesc: settings.aiWorkoutGenerationEnabled
                ? 'AI assisted workout generation enabled'
                : 'AI assisted workout generation disabled',
            icon: Icons.fitness_center_outlined,
            isChecked: settings.aiWorkoutGenerationEnabled,
            onClick: () => notifier.setAiWorkoutGenerationEnabled(!settings.aiWorkoutGenerationEnabled),
          ),
          if (settings.aiWorkoutGenerationEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingItem(
                    settingName: 'Include User Statistics',
                    settingDesc: settings.aiAllowUserStats
                        ? 'Workout volume, streak & metrics shared'
                        : 'User statistics hidden from AI',
                    icon: Icons.query_stats_outlined,
                    isChecked: settings.aiAllowUserStats,
                    onClick: () => notifier.setAiAllowUserStats(!settings.aiAllowUserStats),
                  ),
                  _SettingItem(
                    settingName: 'Include Meal History',
                    settingDesc: settings.aiAllowMealHistory
                        ? 'Recent nutrition & logged meals shared'
                        : 'Meal history hidden from AI',
                    icon: Icons.restaurant_menu_outlined,
                    isChecked: settings.aiAllowMealHistory,
                    onClick: () => notifier.setAiAllowMealHistory(!settings.aiAllowMealHistory),
                  ),
                  _SettingItem(
                    settingName: 'Include Workout History',
                    settingDesc: settings.aiAllowWorkoutHistory
                        ? 'Completed workouts & routine records shared'
                        : 'Workout history hidden from AI',
                    icon: Icons.history_outlined,
                    isChecked: settings.aiAllowWorkoutHistory,
                    onClick: () => notifier.setAiAllowWorkoutHistory(!settings.aiAllowWorkoutHistory),
                  ),
                  _SettingItem(
                    settingName: 'Include User Preferences',
                    settingDesc: settings.aiAllowUserPreferences
                        ? 'Equipment & personal training notes shared'
                        : 'User preferences hidden from AI',
                    icon: Icons.person_pin_outlined,
                    isChecked: settings.aiAllowUserPreferences,
                    onClick: () => notifier.setAiAllowUserPreferences(!settings.aiAllowUserPreferences),
                  ),
                  _SettingItem(
                    settingName: 'Include Measurements',
                    settingDesc: settings.aiAllowMeasurements
                        ? 'Weight & body measurements shared'
                        : 'Measurements hidden from AI',
                    icon: Icons.straighten_outlined,
                    isChecked: settings.aiAllowMeasurements,
                    onClick: () => notifier.setAiAllowMeasurements(!settings.aiAllowMeasurements),
                  ),
                ],
              ),
            ),
          ],

          if (settings.enableAiStockLogging ||
              settings.enableAiProductCreation ||
              settings.aiWorkoutGenerationEnabled) ...[
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI API Configuration',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: settings.aiProvider,
                      decoration: const InputDecoration(
                        labelText: 'API Provider',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'gemini', child: Text('Gemini API (AI Studio)')),
                        DropdownMenuItem(value: 'openrouter', child: Text('OpenRouter')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          notifier.setAiProvider(val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: settings.aiToken,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'API Token / Key',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => notifier.setAiToken(val),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: settings.aiModel,
                      decoration: InputDecoration(
                        labelText: 'Model Name',
                        hintText: settings.aiProvider == 'gemini' ? 'gemini-1.5-flash' : 'google/gemini-2.5-flash',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) => notifier.setAiModel(val),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
  final VoidCallback? onInfoClick;
  final bool enabled;

  const _SettingItem({
    required this.settingName,
    required this.settingDesc,
    required this.icon,
    required this.onClick,
    this.isChecked,
    this.onInfoClick,
    this.enabled = true,
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: enabled ? 0.3 : 0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: enabled ? onClick : null,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
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
                  if (onInfoClick != null)
                    IconButton(
                      icon: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      onPressed: enabled ? onInfoClick : null,
                    ),
                  if (isChecked != null)
                    Switch(
                      value: isChecked!,
                      onChanged: enabled ? (val) => onClick() : null,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
