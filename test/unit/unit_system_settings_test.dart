/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/util/unit_system.dart';
import 'package:nexc_flutter/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  UnitSystem platformDefault() =>
      resolveDefaultUnitSystem(PlatformDispatcher.instance.locale);

  group('Unit system settings', () {
    test('defaults from the platform locale when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.unitSystem, platformDefault());
    });

    test('persists the selected system under unit_system', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      await notifier.setUnitSystem(UnitSystem.imperial);

      expect(notifier.state.unitSystem, UnitSystem.imperial);
      expect(prefs.getString('unit_system'), UnitSystem.imperial.name);

      await notifier.setUnitSystem(UnitSystem.metric);

      expect(notifier.state.unitSystem, UnitSystem.metric);
      expect(prefs.getString('unit_system'), UnitSystem.metric.name);
    });

    test('restores the stored system', () async {
      SharedPreferences.setMockInitialValues({'unit_system': 'imperial'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.unitSystem, UnitSystem.imperial);
    });

    test('falls back to the platform default for an unknown value', () async {
      SharedPreferences.setMockInitialValues({'unit_system': 'not-a-system'});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.unitSystem, platformDefault());
    });
  });

  group('SettingsScreen unit system entry', () {
    testWidgets('shows the current system and changes it', (tester) async {
      SharedPreferences.setMockInitialValues({'unit_system': 'metric'});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Unit system'), findsOneWidget);
      expect(find.text('Metric'), findsOneWidget);

      await tester.tap(find.text('Unit system'));
      await tester.pumpAndSettle();

      expect(find.text('Select unit system'), findsOneWidget);
      expect(find.text('Imperial'), findsOneWidget);

      await tester.tap(find.text('Imperial'));
      await tester.pumpAndSettle();

      expect(prefs.getString('unit_system'), 'imperial');
      expect(find.text('Imperial'), findsOneWidget);
    });
  });
}
