/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/enums.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class SettingsState {
  final ThemeMode themeMode;
  final bool materialMode;
  final bool workoutScreenOn;
  final bool requestPermissionsNextTime;
  final bool restTimerSoundOn;
  final bool showWelcomeScreen;
  final int pastVersionCode;
  final bool isWorkoutHeaderSticky;
  final bool showKeepAndroidOpen;
  final IntensityScale intensityScale;
  final bool restTimerVibrationOn;
  final Language language;
  
  // New Global Targets
  final double targetProtein;
  final double targetCarbs;
  final double targetFats;

  // Measurement toggles
  final bool enableSleep;
  final bool enableAdvancedSleep;
  final bool enableActivity;
  final bool enableAdvancedBody;

  // New toggles
  final bool enableMealTracking;
  final bool enableStockTracking;
  final bool enableAiStockLogging;
  final bool enableAiProductCreation;
  final String aiProvider;
  final String aiToken;
  final String aiModel;

  const SettingsState({
    required this.themeMode,
    required this.materialMode,
    required this.workoutScreenOn,
    required this.requestPermissionsNextTime,
    required this.restTimerSoundOn,
    required this.showWelcomeScreen,
    required this.pastVersionCode,
    required this.isWorkoutHeaderSticky,
    required this.showKeepAndroidOpen,
    required this.intensityScale,
    required this.restTimerVibrationOn,
    required this.language,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFats,
    required this.enableSleep,
    required this.enableAdvancedSleep,
    required this.enableActivity,
    required this.enableAdvancedBody,
    required this.enableMealTracking,
    required this.enableStockTracking,
    required this.enableAiStockLogging,
    required this.enableAiProductCreation,
    required this.aiProvider,
    required this.aiToken,
    required this.aiModel,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? materialMode,
    bool? workoutScreenOn,
    bool? requestPermissionsNextTime,
    bool? restTimerSoundOn,
    bool? showWelcomeScreen,
    int? pastVersionCode,
    bool? isWorkoutHeaderSticky,
    bool? showKeepAndroidOpen,
    IntensityScale? intensityScale,
    bool? restTimerVibrationOn,
    Language? language,
    double? targetProtein,
    double? targetCarbs,
    double? targetFats,
    bool? enableSleep,
    bool? enableAdvancedSleep,
    bool? enableActivity,
    bool? enableAdvancedBody,
    bool? enableMealTracking,
    bool? enableStockTracking,
    bool? enableAiStockLogging,
    bool? enableAiProductCreation,
    String? aiProvider,
    String? aiToken,
    String? aiModel,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      materialMode: materialMode ?? this.materialMode,
      workoutScreenOn: workoutScreenOn ?? this.workoutScreenOn,
      requestPermissionsNextTime: requestPermissionsNextTime ?? this.requestPermissionsNextTime,
      restTimerSoundOn: restTimerSoundOn ?? this.restTimerSoundOn,
      showWelcomeScreen: showWelcomeScreen ?? this.showWelcomeScreen,
      pastVersionCode: pastVersionCode ?? this.pastVersionCode,
      isWorkoutHeaderSticky: isWorkoutHeaderSticky ?? this.isWorkoutHeaderSticky,
      showKeepAndroidOpen: showKeepAndroidOpen ?? this.showKeepAndroidOpen,
      intensityScale: intensityScale ?? this.intensityScale,
      restTimerVibrationOn: restTimerVibrationOn ?? this.restTimerVibrationOn,
      language: language ?? this.language,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFats: targetFats ?? this.targetFats,
      enableSleep: enableSleep ?? this.enableSleep,
      enableAdvancedSleep: enableAdvancedSleep ?? this.enableAdvancedSleep,
      enableActivity: enableActivity ?? this.enableActivity,
      enableAdvancedBody: enableAdvancedBody ?? this.enableAdvancedBody,
      enableMealTracking: enableMealTracking ?? this.enableMealTracking,
      enableStockTracking: enableStockTracking ?? this.enableStockTracking,
      enableAiStockLogging: enableAiStockLogging ?? this.enableAiStockLogging,
      enableAiProductCreation: enableAiProductCreation ?? this.enableAiProductCreation,
      aiProvider: aiProvider ?? this.aiProvider,
      aiToken: aiToken ?? this.aiToken,
      aiModel: aiModel ?? this.aiModel,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(_loadInitialSettings(_prefs));

  static SettingsState _loadInitialSettings(SharedPreferences prefs) {
    final themeModeVal = prefs.getInt('theme_mode') ?? 0;
    final themeMode = ThemeMode.values[themeModeVal.clamp(0, ThemeMode.values.length - 1)];

    final materialMode = prefs.getBool('material_mode') ?? true;
    final workoutScreenOn = prefs.getBool('workout_screen_on') ?? false;
    final requestPermissionsNextTime = prefs.getBool('ask_permission_again') ?? false;
    final restTimerSoundOn = prefs.getBool('alert_sound') ?? true;
    final showWelcomeScreen = prefs.getBool('show_welcome_screen') ?? false;
    final pastVersionCode = prefs.getInt('pastVersionCode') ?? -1;
    final isWorkoutHeaderSticky = prefs.getBool('is_workout_header_sticky') ?? true;
    final showKeepAndroidOpen = prefs.getBool('showKeepAndroidOpenKey') ?? true;

    final intensityScaleVal = prefs.getInt('intensity_scale') ?? 0;
    final intensityScale = IntensityScale.values[intensityScaleVal.clamp(0, IntensityScale.values.length - 1)];

    final restTimerVibrationOn = prefs.getBool('rest_timer_vibration') ?? true;

    final langCode = prefs.getString('language') ?? '';
    final language = Language.values.firstWhere((l) => l.code == langCode, orElse: () => Language.system);

    final targetProtein = prefs.getDouble('target_protein') ?? 150.0;
    final targetCarbs = prefs.getDouble('target_carbs') ?? 200.0;
    final targetFats = prefs.getDouble('target_fats') ?? 70.0;

    final enableSleep = prefs.getBool('enable_sleep') ?? false;
    final enableAdvancedSleep = prefs.getBool('enable_advanced_sleep') ?? false;
    final enableActivity = prefs.getBool('enable_activity') ?? false;
    final enableAdvancedBody = prefs.getBool('enable_advanced_body') ?? false;

    final enableMealTracking = prefs.getBool('enable_meal_tracking') ?? true;
    final enableStockTracking = prefs.getBool('enable_stock_tracking') ?? true;
    final enableAiStockLogging = prefs.getBool('enable_ai_stock_logging') ?? false;
    final enableAiProductCreation = prefs.getBool('enable_ai_product_creation') ?? false;
    final aiProvider = prefs.getString('ai_provider') ?? 'gemini';
    final aiToken = prefs.getString('ai_token') ?? '';
    final aiModel = prefs.getString('ai_model') ?? '';

    return SettingsState(
      themeMode: themeMode,
      materialMode: materialMode,
      workoutScreenOn: workoutScreenOn,
      requestPermissionsNextTime: requestPermissionsNextTime,
      restTimerSoundOn: restTimerSoundOn,
      showWelcomeScreen: showWelcomeScreen,
      pastVersionCode: pastVersionCode,
      isWorkoutHeaderSticky: isWorkoutHeaderSticky,
      showKeepAndroidOpen: showKeepAndroidOpen,
      intensityScale: intensityScale,
      restTimerVibrationOn: restTimerVibrationOn,
      language: language,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFats: targetFats,
      enableSleep: enableSleep,
      enableAdvancedSleep: enableAdvancedSleep,
      enableActivity: enableActivity,
      enableAdvancedBody: enableAdvancedBody,
      enableMealTracking: enableMealTracking,
      enableStockTracking: enableStockTracking,
      enableAiStockLogging: enableAiStockLogging,
      enableAiProductCreation: enableAiProductCreation,
      aiProvider: aiProvider,
      aiToken: aiToken,
      aiModel: aiModel,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt('theme_mode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setMaterialMode(bool val) async {
    await _prefs.setBool('material_mode', val);
    state = state.copyWith(materialMode: val);
  }

  Future<void> setWorkoutScreenOn(bool val) async {
    await _prefs.setBool('workout_screen_on', val);
    state = state.copyWith(workoutScreenOn: val);
  }

  Future<void> setRequestPermissionsNextTime(bool val) async {
    await _prefs.setBool('ask_permission_again', val);
    state = state.copyWith(requestPermissionsNextTime: val);
  }

  Future<void> setRestTimerSoundOn(bool val) async {
    await _prefs.setBool('alert_sound', val);
    state = state.copyWith(restTimerSoundOn: val);
  }

  Future<void> setShowWelcomeScreen(bool val) async {
    await _prefs.setBool('show_welcome_screen', val);
    state = state.copyWith(showWelcomeScreen: val);
  }

  Future<void> setPastVersionCode(int val) async {
    await _prefs.setInt('pastVersionCode', val);
    state = state.copyWith(pastVersionCode: val);
  }

  Future<void> setIsWorkoutHeaderSticky(bool val) async {
    await _prefs.setBool('is_workout_header_sticky', val);
    state = state.copyWith(isWorkoutHeaderSticky: val);
  }

  Future<void> setShowKeepAndroidOpen(bool val) async {
    await _prefs.setBool('showKeepAndroidOpenKey', val);
    state = state.copyWith(showKeepAndroidOpen: val);
  }

  Future<void> setIntensityScale(IntensityScale scale) async {
    await _prefs.setInt('intensity_scale', scale.index);
    state = state.copyWith(intensityScale: scale);
  }

  Future<void> setRestTimerVibrationOn(bool val) async {
    await _prefs.setBool('rest_timer_vibration', val);
    state = state.copyWith(restTimerVibrationOn: val);
  }

  Future<void> setLanguage(Language lang) async {
    await _prefs.setString('language', lang.code);
    state = state.copyWith(language: lang);
  }

  Future<void> setTargetMacros(double p, double c, double f) async {
    await _prefs.setDouble('target_protein', p);
    await _prefs.setDouble('target_carbs', c);
    await _prefs.setDouble('target_fats', f);
    state = state.copyWith(targetProtein: p, targetCarbs: c, targetFats: f);
  }

  Future<void> overwriteTargetMacrosWithPlan(double p, double c, double f) async {
    final hasSaved = _prefs.getBool('has_saved_pre_meal_plan_macros') ?? false;
    if (!hasSaved) {
      await _prefs.setDouble('pre_meal_plan_target_protein', state.targetProtein);
      await _prefs.setDouble('pre_meal_plan_target_carbs', state.targetCarbs);
      await _prefs.setDouble('pre_meal_plan_target_fats', state.targetFats);
      await _prefs.setBool('has_saved_pre_meal_plan_macros', true);
    }
    await setTargetMacros(p, c, f);
  }

  Future<void> restorePrePlanTargetMacros() async {
    final hasSaved = _prefs.getBool('has_saved_pre_meal_plan_macros') ?? false;
    if (hasSaved) {
      final p = _prefs.getDouble('pre_meal_plan_target_protein') ?? 150.0;
      final c = _prefs.getDouble('pre_meal_plan_target_carbs') ?? 200.0;
      final f = _prefs.getDouble('pre_meal_plan_target_fats') ?? 70.0;
      await setTargetMacros(p, c, f);
      await _prefs.setBool('has_saved_pre_meal_plan_macros', false);
    }
  }

  Future<void> setEnableSleep(bool val) async {
    await _prefs.setBool('enable_sleep', val);
    state = state.copyWith(enableSleep: val);
  }

  Future<void> setEnableAdvancedSleep(bool val) async {
    await _prefs.setBool('enable_advanced_sleep', val);
    state = state.copyWith(enableAdvancedSleep: val);
  }

  Future<void> setEnableActivity(bool val) async {
    await _prefs.setBool('enable_activity', val);
    state = state.copyWith(enableActivity: val);
  }

  Future<void> setEnableAdvancedBody(bool val) async {
    await _prefs.setBool('enable_advanced_body', val);
    state = state.copyWith(enableAdvancedBody: val);
  }

  Future<void> setEnableMealTracking(bool val) async {
    await _prefs.setBool('enable_meal_tracking', val);
    if (!val) {
      await _prefs.setBool('enable_stock_tracking', false);
      state = state.copyWith(
        enableMealTracking: false,
        enableStockTracking: false,
      );
    } else {
      state = state.copyWith(enableMealTracking: true);
    }
  }

  Future<void> setEnableStockTracking(bool val) async {
    await _prefs.setBool('enable_stock_tracking', val);
    state = state.copyWith(enableStockTracking: val);
  }

  Future<void> setEnableAiStockLogging(bool val) async {
    await _prefs.setBool('enable_ai_stock_logging', val);
    state = state.copyWith(enableAiStockLogging: val);
  }

  Future<void> setEnableAiProductCreation(bool val) async {
    await _prefs.setBool('enable_ai_product_creation', val);
    state = state.copyWith(enableAiProductCreation: val);
  }

  Future<void> setAiProvider(String val) async {
    await _prefs.setString('ai_provider', val);
    state = state.copyWith(aiProvider: val);
  }

  Future<void> setAiToken(String val) async {
    await _prefs.setString('ai_token', val);
    state = state.copyWith(aiToken: val);
  }

  Future<void> setAiModel(String val) async {
    await _prefs.setString('ai_model', val);
    state = state.copyWith(aiModel: val);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
