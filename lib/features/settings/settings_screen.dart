/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/components/nexc_choice_sheet.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_segmented.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/db/enums.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/unit_system.dart';
import '../../l10n/app_localizations.dart';
import 'rest_alerts_screen.dart';

/// Whether the current device exposes OS-level dynamic colors.
///
/// Android 12+ answers with a palette; every other platform (and the test
/// environment) resolves to false, which hides the Material You row instead of
/// offering a switch that cannot do anything.
final FutureProvider<bool> dynamicColorAvailabilityProvider =
    FutureProvider<bool>((ref) async {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
        return false;
      }
      try {
        return await DynamicColorPlugin.getCorePalette() != null;
      } catch (_) {
        return false;
      }
    });

String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => l10n.themeModeSystem,
    ThemeMode.light => l10n.themeModeLight,
    ThemeMode.dark => l10n.themeModeDark,
  };
}

String _languageLabel(AppLocalizations l10n, Language language) {
  return switch (language) {
    Language.system => l10n.languageSystem,
    Language.arabic => l10n.languageArabic,
    Language.catalan => l10n.languageCatalan,
    Language.czech => l10n.languageCzech,
    Language.german => l10n.languageGerman,
    Language.english => l10n.languageEnglish,
    Language.spanish => l10n.languageSpanish,
    Language.french => l10n.languageFrench,
    Language.galician => l10n.languageGalician,
    Language.hindi => l10n.languageHindi,
    Language.indonesian => l10n.languageIndonesian,
    Language.italian => l10n.languageItalian,
    Language.korean => l10n.languageKorean,
    Language.dutch => l10n.languageDutch,
    Language.polish => l10n.languagePolish,
    Language.portuguese => l10n.languagePortuguese,
    Language.portugueseBrazil => l10n.languagePortugueseBrazil,
    Language.russian => l10n.languageRussian,
    Language.swedish => l10n.languageSwedish,
    Language.ukrainian => l10n.languageUkrainian,
    Language.urdu => l10n.languageUrdu,
    Language.simplifiedChinese => l10n.languageSimplifiedChinese,
  };
}

String _intensityScaleLabel(AppLocalizations l10n, IntensityScale scale) {
  return switch (scale) {
    IntensityScale.none => l10n.intensityScaleNone,
    IntensityScale.rpe => l10n.intensityScaleRpe,
    IntensityScale.rir => l10n.intensityScaleRir,
    IntensityScale.both => l10n.intensityScaleBoth,
  };
}

String _unitSystemLabel(AppLocalizations l10n, UnitSystem system) {
  return switch (system) {
    UnitSystem.metric => l10n.unitSystemMetric,
    UnitSystem.imperial => l10n.unitSystemImperial,
  };
}

String _routineUpdateLabel(AppLocalizations l10n, RoutineUpdateMode mode) {
  return switch (mode) {
    RoutineUpdateMode.never => l10n.routineUpdateNever,
    RoutineUpdateMode.always => l10n.routineUpdateAlways,
    RoutineUpdateMode.ask => l10n.routineUpdateAsk,
  };
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final SettingsState settings = ref.watch(settingsProvider);
    final SettingsNotifier notifier = ref.read(settingsProvider.notifier);
    final bool dynamicColorAvailable =
        ref.watch(dynamicColorAvailabilityProvider).value == true;

    return NexcPage(
      title: l10n.settingsTitle,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NexcSection(
              title: l10n.appearance,
              children: [
                NexcTile.value(
                  title: l10n.theme,
                  value: _themeModeLabel(l10n, settings.themeMode),
                  icon: NexcIcons.theme,
                  onTap: () => _pickThemeMode(context, settings, notifier),
                ),
                if (dynamicColorAvailable)
                  NexcTile.toggle(
                    title: l10n.materialYou,
                    subtitle: settings.materialMode
                        ? l10n.dynamicColorEnabled
                        : l10n.dynamicColorDisabled,
                    icon: NexcIcons.dynamicColor,
                    value: settings.materialMode,
                    onChanged: notifier.setMaterialMode,
                  ),
                NexcTile.toggle(
                  title: l10n.showExerciseImages,
                  subtitle: settings.showExerciseImages
                      ? l10n.imagesShown
                      : l10n.imagesHidden,
                  icon: NexcIcons.images,
                  value: settings.showExerciseImages,
                  onChanged: notifier.setShowExerciseImages,
                ),
              ],
            ),
            NexcSection(
              title: l10n.generalSettings,
              children: [
                NexcTile.value(
                  title: l10n.language,
                  value: _languageLabel(l10n, settings.language),
                  icon: NexcIcons.language,
                  onTap: () => _pickLanguage(context, settings, notifier),
                ),
                NexcTile.value(
                  title: l10n.unitSystem,
                  value: _unitSystemLabel(l10n, settings.unitSystem),
                  icon: NexcIcons.units,
                  onTap: () => _pickUnitSystem(context, settings, notifier),
                ),
                NexcTile.toggle(
                  title: l10n.scrollWheelInput,
                  icon: NexcIcons.scrollInput,
                  value: settings.useScrollWheelForInput,
                  onChanged: notifier.setUseScrollWheelForInput,
                ),
                if (settings.useScrollWheelForInput)
                  NexcTile.toggle(
                    title: l10n.dismissScrollWheelAutomatically,
                    subtitle: settings.dismissScrollWheelInputAutomatically
                        ? l10n.closesAfterShortPause
                        : l10n.confirmWithDone,
                    value: settings.dismissScrollWheelInputAutomatically,
                    indent: true,
                    onChanged: notifier.setDismissScrollWheelInputAutomatically,
                  ),
              ],
            ),
            NexcSection(
              title: l10n.settingsWorkout,
              children: [
                NexcTile.toggle(
                  title: l10n.keepScreenOn,
                  subtitle: settings.workoutScreenOn
                      ? l10n.screenWillStayOn
                      : l10n.screenWillTurnOffNormally,
                  icon: NexcIcons.keepScreenOn,
                  value: settings.workoutScreenOn,
                  onChanged: notifier.setWorkoutScreenOn,
                ),
                NexcTile(
                  title: l10n.restAlerts,
                  subtitle: l10n.restAlertsDesc,
                  icon: NexcIcons.restAlerts,
                  showChevron: true,
                  onTap: () => Navigator.of(context).push(
                    NexcPage.route<void>(
                      title: l10n.restAlerts,
                      builder: (_) => const RestAlertsScreen(),
                    ),
                  ),
                ),
                NexcTile(
                  title: l10n.intensityScale,
                  subtitle: _intensityScaleLabel(l10n, settings.intensityScale),
                  icon: NexcIcons.intensity,
                  onTap: () => _pickIntensityScale(context, settings, notifier),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n.intensityScalesTitle,
                        icon: const Icon(NexcIcons.about, size: 20),
                        onPressed: () => _showIntensityInfo(context),
                      ),
                      const Icon(NexcIcons.chevron, size: 20),
                    ],
                  ),
                ),
                NexcTile.value(
                  title: l10n.updateRoutineAfterWorkout,
                  value: _routineUpdateLabel(l10n, settings.routineUpdateMode),
                  icon: NexcIcons.routineUpdate,
                  onTap: () =>
                      _pickRoutineUpdateMode(context, settings, notifier),
                ),
                NexcTile.toggle(
                  title: l10n.stickyWorkoutStatusBar,
                  subtitle: settings.isWorkoutHeaderSticky
                      ? l10n.statusBarIsSticky
                      : l10n.statusBarIsNotSticky,
                  icon: NexcIcons.stickyHeader,
                  value: settings.isWorkoutHeaderSticky,
                  onChanged: notifier.setIsWorkoutHeaderSticky,
                ),
              ],
            ),
            NexcSection(
              title: l10n.settingsNutrition,
              children: [
                NexcTile.toggle(
                  title: l10n.mealTracking,
                  subtitle: l10n.mealTrackingDesc,
                  icon: NexcIcons.mealTracking,
                  value: settings.enableMealTracking,
                  onChanged: notifier.setEnableMealTracking,
                ),
                if (settings.enableMealTracking) ...[
                  NexcTile.value(
                    title: l10n.dayStartHour,
                    value: context.formatTimeOfDay(
                      TimeOfDay(hour: settings.dayStartHour, minute: 0),
                    ),
                    subtitle: l10n.newDayStartsAt(
                      settings.dayStartHour.toString().padLeft(2, '0'),
                    ),
                    icon: NexcIcons.dayStart,
                    onTap: () => _pickDayStartHour(context, settings, notifier),
                  ),
                  NexcTile.toggle(
                    title: l10n.defaultMacrosOverridePlans,
                    subtitle: settings.defaultMacrosOverrideMealPlan
                        ? l10n.defaultMacrosOverrideEnabledDesc
                        : l10n.defaultMacrosOverrideDisabledDesc,
                    icon: NexcIcons.macros,
                    value: settings.defaultMacrosOverrideMealPlan,
                    onChanged: notifier.setDefaultMacrosOverrideMealPlan,
                  ),
                ],
                NexcTile.toggle(
                  title: l10n.stockTracking,
                  subtitle: settings.enableMealTracking
                      ? l10n.stockTrackingDesc
                      : l10n.requiresMealTracking,
                  icon: NexcIcons.stock,
                  enabled: settings.enableMealTracking,
                  value: settings.enableStockTracking,
                  onChanged: settings.enableMealTracking
                      ? notifier.setEnableStockTracking
                      : null,
                ),
              ],
            ),
            NexcSection(
              title: l10n.settingsHealth,
              children: [
                NexcTile(
                  title: l10n.measurementsSettings,
                  subtitle: l10n.configureMeasurementsDesc,
                  icon: NexcIcons.measurements,
                  showChevron: true,
                  onTap: () =>
                      Navigator.pushNamed(context, '/settings/measurements'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NexcSpacing.lg + NexcSpacing.xs,
                    0,
                    NexcSpacing.lg,
                    NexcSpacing.lg,
                  ),
                  child: Text(
                    _healthSummary(l10n, settings),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            NexcSection(
              title: l10n.settingsAi,
              children: [
                NexcTile.toggle(
                  title: l10n.aiWorkoutCreator,
                  subtitle: settings.enableAiWorkoutAssistant
                      ? l10n.aiWorkoutGenerationEnabledDesc
                      : l10n.aiWorkoutGenerationDisabledDesc,
                  icon: NexcIcons.ai,
                  value: settings.enableAiWorkoutAssistant,
                  onChanged: notifier.setEnableAiWorkoutAssistant,
                ),
                if (settings.enableAiWorkoutAssistant)
                  _AiPermissionsCard(settings: settings, notifier: notifier),
                NexcTile.toggle(
                  title: l10n.aiStockLogging,
                  subtitle: l10n.aiStockLoggingDesc,
                  icon: NexcIcons.aiReceipt,
                  value: settings.enableAiStockLogging,
                  onChanged: notifier.setEnableAiStockLogging,
                ),
                NexcTile.toggle(
                  title: l10n.aiProductCreation,
                  subtitle: l10n.aiProductCreationDesc,
                  icon: NexcIcons.aiProduct,
                  value: settings.enableAiProductCreation,
                  onChanged: notifier.setEnableAiProductCreation,
                ),
                const _ApiConfigurationSection(),
              ],
            ),
            NexcSection(
              title: l10n.settingsData,
              children: [
                NexcTile(
                  title: l10n.backupAndRestore,
                  subtitle: l10n.backupAndRestoreDesc,
                  icon: NexcIcons.backup,
                  showChevron: true,
                  onTap: () => Navigator.pushNamed(context, '/backup'),
                ),
              ],
            ),
            NexcSection(
              title: l10n.settingsAbout,
              children: [
                NexcTile(
                  title: l10n.aboutTitle,
                  subtitle: l10n.settingsAboutDesc,
                  icon: NexcIcons.about,
                  showChevron: true,
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),
              ],
            ),
            const _VersionText(),
            const SizedBox(height: NexcSpacing.xl),
          ],
        ),
      ),
    );
  }

  String _healthSummary(AppLocalizations l10n, SettingsState settings) {
    final List<String> tracked = <String>[
      if (settings.enableSleep) l10n.sleepMeasurements,
      if (settings.enableActivity) l10n.activityMeasurements,
      if (settings.enableAdvancedBody) l10n.advancedBodyMeasurements,
    ];
    return tracked.isEmpty
        ? l10n.measurementsSettingsDesc
        : tracked.join(' · ');
  }

  Future<void> _pickThemeMode(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final AppLocalizations l10n = context.l10n;
    final ThemeMode? picked = await NexcChoiceSheet.show<ThemeMode>(
      context: context,
      title: l10n.selectTheme,
      selected: settings.themeMode,
      options: ThemeMode.values
          .map(
            (ThemeMode mode) => NexcChoiceOption<ThemeMode>(
              value: mode,
              label: _themeModeLabel(l10n, mode),
            ),
          )
          .toList(),
    );
    if (picked != null) await notifier.setThemeMode(picked);
  }

  Future<void> _pickLanguage(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final AppLocalizations l10n = context.l10n;
    final Language? picked = await NexcChoiceSheet.show<Language>(
      context: context,
      title: l10n.selectLanguage,
      searchable: true,
      searchHint: l10n.language,
      selected: settings.language,
      options: Language.values
          .map(
            (Language language) => NexcChoiceOption<Language>(
              value: language,
              label: _languageLabel(l10n, language),
            ),
          )
          .toList(),
    );
    if (picked != null) await notifier.setLanguage(picked);
  }

  Future<void> _pickUnitSystem(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final AppLocalizations l10n = context.l10n;
    final UnitSystem? picked = await NexcChoiceSheet.show<UnitSystem>(
      context: context,
      title: l10n.selectUnitSystem,
      selected: settings.unitSystem,
      options: UnitSystem.values
          .map(
            (UnitSystem system) => NexcChoiceOption<UnitSystem>(
              value: system,
              label: _unitSystemLabel(l10n, system),
            ),
          )
          .toList(),
    );
    if (picked != null) await notifier.setUnitSystem(picked);
  }

  Future<void> _pickIntensityScale(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final AppLocalizations l10n = context.l10n;
    final IntensityScale? picked = await NexcChoiceSheet.show<IntensityScale>(
      context: context,
      title: l10n.selectIntensityScale,
      selected: settings.intensityScale,
      options: IntensityScale.values
          .map(
            (IntensityScale scale) => NexcChoiceOption<IntensityScale>(
              value: scale,
              label: _intensityScaleLabel(l10n, scale),
            ),
          )
          .toList(),
    );
    if (picked != null) await notifier.setIntensityScale(picked);
  }

  Future<void> _pickRoutineUpdateMode(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final AppLocalizations l10n = context.l10n;
    final RoutineUpdateMode? picked =
        await NexcChoiceSheet.show<RoutineUpdateMode>(
          context: context,
          title: l10n.updateRoutineAfterWorkout,
          selected: settings.routineUpdateMode,
          options: RoutineUpdateMode.values
              .map(
                (RoutineUpdateMode mode) => NexcChoiceOption<RoutineUpdateMode>(
                  value: mode,
                  label: _routineUpdateLabel(l10n, mode),
                ),
              )
              .toList(),
        );
    if (picked != null) await notifier.setRoutineUpdateMode(picked);
  }

  Future<void> _pickDayStartHour(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.dayStartHour, minute: 0),
      helpText: context.l10n.dayStartHour,
    );
    // Only the hour is stored; the label always renders the hour on the hour.
    if (picked != null) await notifier.setDayStartHour(picked.hour);
  }

  void _showIntensityInfo(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.intensityScalesTitle),
        content: SingleChildScrollView(
          child: Text(l10n.intensityScalesDescription),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

/// Indented permission switches shown while the AI workout creator is on.
class _AiPermissionsCard extends StatelessWidget {
  final SettingsState settings;
  final SettingsNotifier notifier;

  const _AiPermissionsCard({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NexcSpacing.lg,
        0,
        NexcSpacing.lg,
        NexcSpacing.lg,
      ),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: const RoundedRectangleBorder(borderRadius: NexcShapes.smRadius),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NexcSpacing.lg,
                NexcSpacing.md,
                NexcSpacing.lg,
                NexcSpacing.xs,
              ),
              child: Text(
                l10n.aiPermissions,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            NexcTile.toggle(
              title: l10n.includeUserStatistics,
              icon: NexcIcons.statistics,
              dense: true,
              indent: true,
              value: settings.aiAllowStatistics,
              onChanged: notifier.setAiAllowStatistics,
            ),
            NexcTile.toggle(
              title: l10n.includeMealHistory,
              icon: NexcIcons.mealHistory,
              dense: true,
              indent: true,
              value: settings.aiAllowMealHistory,
              onChanged: notifier.setAiAllowMealHistory,
            ),
            NexcTile.toggle(
              title: l10n.includeWorkoutHistory,
              icon: NexcIcons.workoutHistory,
              dense: true,
              indent: true,
              value: settings.aiAllowWorkoutHistory,
              onChanged: notifier.setAiAllowWorkoutHistory,
            ),
            NexcTile.toggle(
              title: l10n.includeUserPreferences,
              icon: NexcIcons.personalInfo,
              dense: true,
              indent: true,
              value: settings.enableUserPreferences,
              onChanged: notifier.setEnableUserPreferences,
            ),
            NexcTile.toggle(
              title: l10n.includeMeasurements,
              icon: NexcIcons.measurements,
              dense: true,
              indent: true,
              value: settings.aiAllowMeasurements,
              onChanged: notifier.setAiAllowMeasurements,
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider, key and model fields for the remote AI API.
///
/// Fields commit on submit or blur only, so typing a key never writes to
/// preferences on every keystroke.
class _ApiConfigurationSection extends ConsumerStatefulWidget {
  const _ApiConfigurationSection();

  @override
  ConsumerState<_ApiConfigurationSection> createState() =>
      _ApiConfigurationSectionState();
}

class _ApiConfigurationSectionState
    extends ConsumerState<_ApiConfigurationSection> {
  late final TextEditingController _tokenController;
  late final TextEditingController _modelController;
  late final FocusNode _tokenFocus;
  late final FocusNode _modelFocus;
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    final SettingsState settings = ref.read(settingsProvider);
    _tokenController = TextEditingController(text: settings.aiToken);
    _modelController = TextEditingController(text: settings.aiModel);
    _tokenFocus = FocusNode()..addListener(_commitToken);
    _modelFocus = FocusNode()..addListener(_commitModel);
  }

  @override
  void dispose() {
    _tokenFocus
      ..removeListener(_commitToken)
      ..dispose();
    _modelFocus
      ..removeListener(_commitModel)
      ..dispose();
    _tokenController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _commitToken() {
    if (_tokenFocus.hasFocus) return;
    final String value = _tokenController.text.trim();
    if (value == ref.read(settingsProvider).aiToken) return;
    ref.read(settingsProvider.notifier).setAiToken(value);
  }

  void _commitModel() {
    if (_modelFocus.hasFocus) return;
    final String value = _modelController.text.trim();
    if (value == ref.read(settingsProvider).aiModel) return;
    ref.read(settingsProvider.notifier).setAiModel(value);
  }

  void _testConnection() {
    final String token = _tokenController.text.trim();
    NexcSnack.show(
      context,
      token.isEmpty
          ? context.l10n.aiTokenNotConfigured
          : context.l10n.testConnection,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final SettingsState settings = ref.watch(settingsProvider);
    final bool isOpenRouter = settings.aiProvider == 'openrouter';

    return ExpansionTile(
      leading: const Icon(NexcIcons.apiKey),
      title: Text(l10n.aiApiConfiguration),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NexcSegmented<String>(
              segments: const [
                (value: 'gemini', label: 'Gemini', icon: null),
                (value: 'openrouter', label: 'OpenRouter', icon: null),
              ],
              selected: isOpenRouter ? 'openrouter' : 'gemini',
              onChanged: (String provider) =>
                  ref.read(settingsProvider.notifier).setAiProvider(provider),
            ),
            const SizedBox(height: NexcSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _tokenController,
                    focusNode: _tokenFocus,
                    obscureText: _obscureToken,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(labelText: l10n.apiTokenKey),
                    onSubmitted: (_) => _commitToken(),
                  ),
                ),
                const SizedBox(width: NexcSpacing.sm),
                TextButton(
                  onPressed: () =>
                      setState(() => _obscureToken = !_obscureToken),
                  child: Text(_obscureToken ? l10n.showToken : l10n.hideToken),
                ),
              ],
            ),
            const SizedBox(height: NexcSpacing.md),
            TextField(
              controller: _modelController,
              focusNode: _modelFocus,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.modelName,
                hintText: isOpenRouter
                    ? 'google/gemini-2.5-flash'
                    : 'gemini-1.5-flash',
              ),
              onSubmitted: (_) => _commitModel(),
            ),
            const SizedBox(height: NexcSpacing.md),
            Text(
              l10n.apiPrivacyNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: NexcSpacing.lg),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                onPressed: _testConnection,
                icon: const Icon(NexcIcons.check, size: 18),
                label: Text(l10n.testConnection),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Version and build number under the About row.
class _VersionText extends StatefulWidget {
  const _VersionText();

  @override
  State<_VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<_VersionText> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _info = info);
    } catch (_) {
      // Version metadata is optional; keep the loading label on failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final PackageInfo? info = _info;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NexcSpacing.xl,
        0,
        NexcSpacing.xl,
        NexcSpacing.lg,
      ),
      child: Text(
        info == null
            ? l10n.loadingVersion
            : l10n.versionWithBuild(info.version, info.buildNumber),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
