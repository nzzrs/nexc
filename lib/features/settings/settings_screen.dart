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
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/db/enums.dart';
import '../../core/util/unit_system.dart';
import '../../l10n/app_localizations.dart';

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
              child: Text(context.l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  String _getThemeModeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeModeSystem;
      case ThemeMode.light:
        return l10n.themeModeLight;
      case ThemeMode.dark:
        return l10n.themeModeDark;
    }
  }

  String _getLanguageLabel(AppLocalizations l10n, Language lang) {
    switch (lang) {
      case Language.system:
        return l10n.languageSystem;
      case Language.arabic:
        return l10n.languageArabic;
      case Language.catalan:
        return l10n.languageCatalan;
      case Language.czech:
        return l10n.languageCzech;
      case Language.german:
        return l10n.languageGerman;
      case Language.english:
        return l10n.languageEnglish;
      case Language.spanish:
        return l10n.languageSpanish;
      case Language.french:
        return l10n.languageFrench;
      case Language.galician:
        return l10n.languageGalician;
      case Language.hindi:
        return l10n.languageHindi;
      case Language.indonesian:
        return l10n.languageIndonesian;
      case Language.italian:
        return l10n.languageItalian;
      case Language.korean:
        return l10n.languageKorean;
      case Language.dutch:
        return l10n.languageDutch;
      case Language.polish:
        return l10n.languagePolish;
      case Language.portuguese:
        return l10n.languagePortuguese;
      case Language.portugueseBrazil:
        return l10n.languagePortugueseBrazil;
      case Language.russian:
        return l10n.languageRussian;
      case Language.swedish:
        return l10n.languageSwedish;
      case Language.ukrainian:
        return l10n.languageUkrainian;
      case Language.urdu:
        return l10n.languageUrdu;
      case Language.simplifiedChinese:
        return l10n.languageSimplifiedChinese;
    }
  }

  String _getIntensityScaleLabel(AppLocalizations l10n, IntensityScale scale) {
    switch (scale) {
      case IntensityScale.none:
        return l10n.intensityScaleNone;
      case IntensityScale.rpe:
        return l10n.intensityScaleRpe;
      case IntensityScale.rir:
        return l10n.intensityScaleRir;
      case IntensityScale.both:
        return l10n.intensityScaleBoth;
    }
  }

  String _getUnitSystemLabel(AppLocalizations l10n, UnitSystem system) {
    switch (system) {
      case UnitSystem.metric:
        return l10n.unitSystemMetric;
      case UnitSystem.imperial:
        return l10n.unitSystemImperial;
    }
  }

  String _getRoutineUpdateModeLabel(
    AppLocalizations l10n,
    RoutineUpdateMode mode,
  ) {
    switch (mode) {
      case RoutineUpdateMode.never:
        return l10n.routineUpdateNever;
      case RoutineUpdateMode.always:
        return l10n.routineUpdateAlways;
      case RoutineUpdateMode.ask:
        return l10n.routineUpdateAsk;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // Appearance
          _buildSectionHeader(context, l10n.appearance),
          _SettingItem(
            settingName: l10n.theme,
            settingDesc: _getThemeModeLabel(l10n, settings.themeMode),
            icon: Icons.dark_mode_outlined,
            onClick: () {
              _showSingleChoiceDialog<ThemeMode>(
                context: context,
                title: l10n.selectTheme,
                options: ThemeMode.values,
                selectedValue: settings.themeMode,
                labelBuilder: (mode) => _getThemeModeLabel(l10n, mode),
                onSelected: notifier.setThemeMode,
              );
            },
          ),
          _SettingItem(
            settingName: l10n.materialYou,
            settingDesc: settings.materialMode
                ? l10n.dynamicColorEnabled
                : l10n.dynamicColorDisabled,
            icon: Icons.color_lens_outlined,
            isChecked: settings.materialMode,
            onClick: () => notifier.setMaterialMode(!settings.materialMode),
          ),
          _SettingItem(
            settingName: l10n.showExerciseImages,
            settingDesc: settings.showExerciseImages
                ? l10n.imagesShown
                : l10n.imagesHidden,
            icon: Icons.image_outlined,
            isChecked: settings.showExerciseImages,
            onClick: () =>
                notifier.setShowExerciseImages(!settings.showExerciseImages),
          ),

          const SizedBox(height: 16),

          // General settings
          _buildSectionHeader(context, l10n.generalSettings),
          _SettingItem(
            settingName: l10n.language,
            settingDesc: _getLanguageLabel(l10n, settings.language),
            icon: Icons.translate,
            onClick: () {
              _showSingleChoiceDialog<Language>(
                context: context,
                title: l10n.selectLanguage,
                options: Language.values,
                selectedValue: settings.language,
                labelBuilder: (language) => _getLanguageLabel(l10n, language),
                onSelected: notifier.setLanguage,
              );
            },
          ),
          _SettingItem(
            settingName: l10n.unitSystem,
            settingDesc: _getUnitSystemLabel(l10n, settings.unitSystem),
            icon: Icons.scale_outlined,
            onClick: () {
              _showSingleChoiceDialog<UnitSystem>(
                context: context,
                title: l10n.selectUnitSystem,
                options: UnitSystem.values,
                selectedValue: settings.unitSystem,
                labelBuilder: (system) => _getUnitSystemLabel(l10n, system),
                onSelected: notifier.setUnitSystem,
              );
            },
          ),
          _SettingItem(
            settingName: l10n.keepScreenOn,
            settingDesc: settings.workoutScreenOn
                ? l10n.screenWillStayOn
                : l10n.screenWillTurnOffNormally,
            icon: Icons.stay_current_portrait_outlined,
            isChecked: settings.workoutScreenOn,
            onClick: () =>
                notifier.setWorkoutScreenOn(!settings.workoutScreenOn),
          ),
          _SettingItem(
            settingName: l10n.restTimerSound,
            settingDesc: settings.restTimerSoundOn
                ? l10n.soundEnabled
                : l10n.soundDisabled,
            icon: Icons.notifications_active_outlined,
            isChecked: settings.restTimerSoundOn,
            onClick: () =>
                notifier.setRestTimerSoundOn(!settings.restTimerSoundOn),
          ),
          _SettingItem(
            settingName: l10n.restTimerVibration,
            settingDesc: settings.restTimerVibrationOn
                ? l10n.vibrationEnabled
                : l10n.vibrationDisabled,
            icon: Icons.vibration,
            isChecked: settings.restTimerVibrationOn,
            onClick: () => notifier.setRestTimerVibrationOn(
              !settings.restTimerVibrationOn,
            ),
          ),
          _SettingItem(
            settingName: l10n.stickyWorkoutStatusBar,
            settingDesc: settings.isWorkoutHeaderSticky
                ? l10n.statusBarIsSticky
                : l10n.statusBarIsNotSticky,
            icon: Icons.push_pin_outlined,
            isChecked: settings.isWorkoutHeaderSticky,
            onClick: () => notifier.setIsWorkoutHeaderSticky(
              !settings.isWorkoutHeaderSticky,
            ),
          ),
          _SettingItem(
            settingName: l10n.intensityScale,
            settingDesc: _getIntensityScaleLabel(l10n, settings.intensityScale),
            icon: Icons.line_weight,
            onClick: () {
              _showSingleChoiceDialog<IntensityScale>(
                context: context,
                title: l10n.selectIntensityScale,
                options: IntensityScale.values,
                selectedValue: settings.intensityScale,
                labelBuilder: (scale) => _getIntensityScaleLabel(l10n, scale),
                onSelected: notifier.setIntensityScale,
              );
            },
            onInfoClick: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.intensityScalesTitle),
                  content: Text(l10n.intensityScalesDescription),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.close),
                    ),
                  ],
                ),
              );
            },
          ),

          _SettingItem(
            settingName: l10n.updateRoutineAfterWorkout,
            settingDesc: _getRoutineUpdateModeLabel(
              l10n,
              settings.routineUpdateMode,
            ),
            icon: Icons.refresh,
            onClick: () {
              _showSingleChoiceDialog<RoutineUpdateMode>(
                context: context,
                title: l10n.updateRoutineAfterWorkout,
                options: RoutineUpdateMode.values,
                selectedValue: settings.routineUpdateMode,
                labelBuilder: (mode) => _getRoutineUpdateModeLabel(l10n, mode),
                onSelected: notifier.setRoutineUpdateMode,
              );
            },
          ),

          _SettingItem(
            settingName: l10n.scrollWheelInput,
            settingDesc: settings.useScrollWheelForInput
                ? l10n.tapValueToOpenPicker
                : l10n.inlineTextFields,
            icon: Icons.unfold_more,
            isChecked: settings.useScrollWheelForInput,
            onClick: () => notifier.setUseScrollWheelForInput(
              !settings.useScrollWheelForInput,
            ),
          ),
          if (settings.useScrollWheelForInput)
            _SettingItem(
              settingName: l10n.dismissScrollWheelAutomatically,
              settingDesc: settings.dismissScrollWheelInputAutomatically
                  ? l10n.closesAfterShortPause
                  : l10n.confirmWithDone,
              icon: Icons.close_fullscreen,
              isChecked: settings.dismissScrollWheelInputAutomatically,
              onClick: () => notifier.setDismissScrollWheelInputAutomatically(
                !settings.dismissScrollWheelInputAutomatically,
              ),
            ),

          const SizedBox(height: 16),

          // Navigation buttons
          _buildSectionHeader(context, l10n.dataAndConfiguration),
          _SettingItem(
            settingName: l10n.measurementsSettings,
            settingDesc: l10n.configureMeasurementsDesc,
            icon: Icons.monitor_weight_outlined,
            onClick: () {
              Navigator.pushNamed(context, '/settings/measurements');
            },
          ),
          _SettingItem(
            settingName: l10n.backupAndRestore,
            settingDesc: l10n.backupAndRestoreDesc,
            icon: Icons.backup_outlined,
            onClick: () {
              Navigator.pushNamed(context, '/backup');
            },
          ),

          const SizedBox(height: 16),

          // Features Configuration
          _buildSectionHeader(context, l10n.featuresConfiguration),
          _SettingItem(
            settingName: l10n.mealTracking,
            settingDesc: settings.enableMealTracking
                ? l10n.mealTrackingEnabled
                : l10n.mealTrackingDisabled,
            icon: Icons.restaurant_outlined,
            isChecked: settings.enableMealTracking,
            onClick: () =>
                notifier.setEnableMealTracking(!settings.enableMealTracking),
          ),
          if (settings.enableMealTracking) ...[
            _SettingItem(
              settingName: l10n.dayStartHour,
              settingDesc: l10n.newDayStartsAt(
                settings.dayStartHour.toString().padLeft(2, '0'),
              ),
              icon: Icons.access_time,
              onClick: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.dayStartHour,
                    minute: 0,
                  ),
                );
                if (picked != null) {
                  notifier.setDayStartHour(picked.hour);
                }
              },
            ),
            _SettingItem(
              settingName: l10n.defaultMacrosOverridePlans,
              settingDesc: settings.defaultMacrosOverrideMealPlan
                  ? l10n.defaultMacrosOverrideEnabledDesc
                  : l10n.defaultMacrosOverrideDisabledDesc,
              icon: Icons.lock_outline,
              isChecked: settings.defaultMacrosOverrideMealPlan,
              onClick: () => notifier.setDefaultMacrosOverrideMealPlan(
                !settings.defaultMacrosOverrideMealPlan,
              ),
            ),
          ],
          _SettingItem(
            settingName: l10n.stockTracking,
            settingDesc: !settings.enableMealTracking
                ? l10n.requiresMealTracking
                : (settings.enableStockTracking
                      ? l10n.stockTrackingEnabled
                      : l10n.stockTrackingDisabled),
            icon: Icons.inventory_2_outlined,
            isChecked: settings.enableStockTracking,
            enabled: settings.enableMealTracking,
            onClick: () =>
                notifier.setEnableStockTracking(!settings.enableStockTracking),
          ),

          const SizedBox(height: 16),

          // AI Integrations
          _buildSectionHeader(context, l10n.aiIntegrations),
          _SettingItem(
            settingName: l10n.aiStockLogging,
            settingDesc: l10n.aiStockLoggingDesc,
            icon: Icons.receipt_long_outlined,
            isChecked: settings.enableAiStockLogging,
            onClick: () => notifier.setEnableAiStockLogging(
              !settings.enableAiStockLogging,
            ),
          ),
          _SettingItem(
            settingName: l10n.aiProductCreation,
            settingDesc: l10n.aiProductCreationDesc,
            icon: Icons.auto_awesome_outlined,
            isChecked: settings.enableAiProductCreation,
            onClick: () => notifier.setEnableAiProductCreation(
              !settings.enableAiProductCreation,
            ),
          ),

          // Workout AI Generator
          _buildSectionHeader(context, l10n.aiFeaturesAndPrivacy),
          _SettingItem(
            settingName: l10n.aiWorkoutCreator,
            settingDesc: settings.aiWorkoutGenerationEnabled
                ? l10n.aiWorkoutGenerationEnabledDesc
                : l10n.aiWorkoutGenerationDisabledDesc,
            icon: Icons.fitness_center_outlined,
            isChecked: settings.aiWorkoutGenerationEnabled,
            onClick: () => notifier.setAiWorkoutGenerationEnabled(
              !settings.aiWorkoutGenerationEnabled,
            ),
          ),
          if (settings.aiWorkoutGenerationEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingItem(
                    settingName: l10n.includeUserStatistics,
                    settingDesc: settings.aiAllowUserStats
                        ? l10n.includeUserStatisticsEnabledDesc
                        : l10n.includeUserStatisticsDisabledDesc,
                    icon: Icons.query_stats_outlined,
                    isChecked: settings.aiAllowUserStats,
                    onClick: () => notifier.setAiAllowUserStats(
                      !settings.aiAllowUserStats,
                    ),
                  ),
                  _SettingItem(
                    settingName: l10n.includeMealHistory,
                    settingDesc: settings.aiAllowMealHistory
                        ? l10n.includeMealHistoryEnabledDesc
                        : l10n.includeMealHistoryDisabledDesc,
                    icon: Icons.restaurant_menu_outlined,
                    isChecked: settings.aiAllowMealHistory,
                    onClick: () => notifier.setAiAllowMealHistory(
                      !settings.aiAllowMealHistory,
                    ),
                  ),
                  _SettingItem(
                    settingName: l10n.includeWorkoutHistory,
                    settingDesc: settings.aiAllowWorkoutHistory
                        ? l10n.includeWorkoutHistoryEnabledDesc
                        : l10n.includeWorkoutHistoryDisabledDesc,
                    icon: Icons.history_outlined,
                    isChecked: settings.aiAllowWorkoutHistory,
                    onClick: () => notifier.setAiAllowWorkoutHistory(
                      !settings.aiAllowWorkoutHistory,
                    ),
                  ),
                  _SettingItem(
                    settingName: l10n.includeUserPreferences,
                    settingDesc: settings.aiAllowUserPreferences
                        ? l10n.includeUserPreferencesEnabledDesc
                        : l10n.includeUserPreferencesDisabledDesc,
                    icon: Icons.person_pin_outlined,
                    isChecked: settings.aiAllowUserPreferences,
                    onClick: () => notifier.setAiAllowUserPreferences(
                      !settings.aiAllowUserPreferences,
                    ),
                  ),
                  _SettingItem(
                    settingName: l10n.includeMeasurements,
                    settingDesc: settings.aiAllowMeasurements
                        ? l10n.includeMeasurementsEnabledDesc
                        : l10n.includeMeasurementsDisabledDesc,
                    icon: Icons.straighten_outlined,
                    isChecked: settings.aiAllowMeasurements,
                    onClick: () => notifier.setAiAllowMeasurements(
                      !settings.aiAllowMeasurements,
                    ),
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
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiApiConfiguration,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: settings.aiProvider,
                      decoration: InputDecoration(
                        labelText: l10n.apiProvider,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'gemini',
                          child: Text(l10n.geminiApi),
                        ),
                        DropdownMenuItem(
                          value: 'openrouter',
                          child: Text(l10n.openRouter),
                        ),
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
                      decoration: InputDecoration(
                        labelText: l10n.apiTokenKey,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) => notifier.setAiToken(val),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: settings.aiModel,
                      decoration: InputDecoration(
                        labelText: l10n.modelName,
                        hintText: settings.aiProvider == 'gemini'
                            ? 'gemini-1.5-flash'
                            : 'google/gemini-2.5-flash',
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: enabled ? 0.3 : 0.1,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: enabled ? onClick : null,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(icon, color: theme.colorScheme.onSurfaceVariant),
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
                      icon: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
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
