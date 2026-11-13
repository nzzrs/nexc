/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoutineUpdateMode settings', () {
    test('defaults to never when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.routineUpdateMode, RoutineUpdateMode.never);
    });

    test('persists the selected mode under routine_update_mode', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      await notifier.setRoutineUpdateMode(RoutineUpdateMode.always);

      expect(notifier.state.routineUpdateMode, RoutineUpdateMode.always);
      expect(
        prefs.getString('routine_update_mode'),
        RoutineUpdateMode.always.name,
      );

      final reloaded = SettingsNotifier(prefs);
      addTearDown(reloaded.dispose);
      expect(reloaded.state.routineUpdateMode, RoutineUpdateMode.always);
    });

    test('restores ask mode from storage', () async {
      SharedPreferences.setMockInitialValues({
        'routine_update_mode': RoutineUpdateMode.ask.name,
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.routineUpdateMode, RoutineUpdateMode.ask);
    });

    test('falls back to never for an unknown stored value', () async {
      SharedPreferences.setMockInitialValues({
        'routine_update_mode': 'not-a-mode',
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.routineUpdateMode, RoutineUpdateMode.never);
    });
  });
}
