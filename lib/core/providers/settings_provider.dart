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
  final OneRepMaxFormula oneRepMaxFormula;
  final bool sleepModeEnabled;
  final bool showRpe;
  final IntensityScale intensityScale;
  final bool restTimerVibrationOn;
  final Language language;

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
    required this.oneRepMaxFormula,
    required this.sleepModeEnabled,
    required this.showRpe,
    required this.intensityScale,
    required this.restTimerVibrationOn,
    required this.language,
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
    OneRepMaxFormula? oneRepMaxFormula,
    bool? sleepModeEnabled,
    bool? showRpe,
    IntensityScale? intensityScale,
    bool? restTimerVibrationOn,
    Language? language,
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
      oneRepMaxFormula: oneRepMaxFormula ?? this.oneRepMaxFormula,
      sleepModeEnabled: sleepModeEnabled ?? this.sleepModeEnabled,
      showRpe: showRpe ?? this.showRpe,
      intensityScale: intensityScale ?? this.intensityScale,
      restTimerVibrationOn: restTimerVibrationOn ?? this.restTimerVibrationOn,
      language: language ?? this.language,
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

    final formulaVal = prefs.getInt('one_rep_max_formula') ?? 0;
    final oneRepMaxFormula = OneRepMaxFormula.values[formulaVal.clamp(0, OneRepMaxFormula.values.length - 1)];

    final sleepModeEnabled = prefs.getBool('sleep_mode') ?? false;
    final showRpe = prefs.getBool('show_rpe') ?? false;

    final intensityScaleVal = prefs.getInt('intensity_scale') ?? 0;
    final intensityScale = IntensityScale.values[intensityScaleVal.clamp(0, IntensityScale.values.length - 1)];

    final restTimerVibrationOn = prefs.getBool('rest_timer_vibration') ?? true;

    final langCode = prefs.getString('language') ?? '';
    final language = Language.values.firstWhere((l) => l.code == langCode, orElse: () => Language.system);

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
      oneRepMaxFormula: oneRepMaxFormula,
      sleepModeEnabled: sleepModeEnabled,
      showRpe: showRpe,
      intensityScale: intensityScale,
      restTimerVibrationOn: restTimerVibrationOn,
      language: language,
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

  Future<void> setOneRepMaxFormula(OneRepMaxFormula formula) async {
    await _prefs.setInt('one_rep_max_formula', formula.index);
    state = state.copyWith(oneRepMaxFormula: formula);
  }

  Future<void> setSleepModeEnabled(bool val) async {
    await _prefs.setBool('sleep_mode', val);
    state = state.copyWith(sleepModeEnabled: val);
  }

  Future<void> setShowRpe(bool val) async {
    await _prefs.setBool('show_rpe', val);
    state = state.copyWith(showRpe: val);
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
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
