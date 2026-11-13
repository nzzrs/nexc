/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/theme/theme.dart';
import 'package:nexc_flutter/features/settings/backup_screen.dart';
import 'package:nexc_flutter/features/settings/settings_screen.dart';
import 'package:nexc_flutter/l10n/app_localizations_en.dart';

final AppLocalizationsEn _en = AppLocalizationsEn();

Future<SharedPreferences> _prefs([
  Map<String, Object> values = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Widget _app(Widget home, SharedPreferences prefs) {
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      theme: createNexcTheme(lightColorScheme),
      home: home,
      routes: {'/about': (_) => const SizedBox.shrink()},
    ),
  );
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('settings tree', () {
    testWidgets('shows every section title', (tester) async {
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_app(const SettingsScreen(), prefs));
      await tester.pump();

      for (final String title in <String>[
        _en.appearance,
        _en.generalSettings,
        _en.settingsWorkout,
        _en.settingsNutrition,
        _en.settingsHealth,
        _en.settingsAi,
        _en.settingsData,
        _en.settingsAbout,
      ]) {
        expect(
          find.text(title),
          findsWidgets,
          reason: 'missing section title "$title"',
        );
      }
    });

    testWidgets('keeps the frozen settings rows tappable in the first '
        'viewport', (tester) async {
      final SharedPreferences prefs = await _prefs({'unit_system': 'metric'});
      await tester.pumpWidget(_app(const SettingsScreen(), prefs));
      await tester.pump();

      expect(find.text('Show exercise images'), findsOneWidget);
      expect(find.text('Images hidden'), findsOneWidget);
      expect(find.text('Unit system'), findsOneWidget);
      expect(find.text('Metric'), findsOneWidget);
      expect(find.text('Scroll wheel input'), findsOneWidget);
      expect(find.text('Dismiss scroll wheel automatically'), findsOneWidget);

      for (final String label in <String>[
        'Show exercise images',
        'Unit system',
        'Scroll wheel input',
        'Dismiss scroll wheel automatically',
      ]) {
        final double dy = tester.getCenter(find.text(label)).dy;
        expect(dy, lessThan(600), reason: '"$label" is below the viewport');
      }

      await tester.tap(find.text('Show exercise images'));
      await tester.pump();
      expect(find.text('Images shown'), findsOneWidget);
      expect(prefs.getBool('show_exercise_images'), isTrue);

      await tester.tap(find.text('Unit system'));
      await tester.pumpAndSettle();
      expect(find.text('Select unit system'), findsOneWidget);
      await tester.tap(find.text('Imperial'));
      await tester.pumpAndSettle();
      expect(prefs.getString('unit_system'), 'imperial');

      await tester.tap(find.text('Scroll wheel input'));
      await tester.pump();
      expect(prefs.getBool('use_scroll_wheel_for_input'), isFalse);
      expect(find.text('Dismiss scroll wheel automatically'), findsNothing);
    });

    testWidgets('theme choice sheet updates the stored mode', (tester) async {
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_app(const SettingsScreen(), prefs));
      await tester.pump();

      await tester.tap(find.text(_en.theme));
      await tester.pumpAndSettle();
      expect(find.text(_en.selectTheme), findsOneWidget);

      await tester.tap(find.text(_en.themeModeDark));
      await tester.pumpAndSettle();

      expect(prefs.getInt('theme_mode'), ThemeMode.dark.index);
      expect(find.text(_en.themeModeDark), findsOneWidget);
    });

    testWidgets('language choice sheet is searchable and applies', (
      tester,
    ) async {
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_app(const SettingsScreen(), prefs));
      await tester.pump();

      await tester.tap(find.text(_en.language));
      await tester.pumpAndSettle();
      expect(find.text(_en.selectLanguage), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.text(_en.languageGerman));
      await tester.pumpAndSettle();

      expect(prefs.getString('language'), 'de');
      expect(find.text(_en.languageGerman), findsOneWidget);
    });

    testWidgets('stock tracking stays disabled while meals are off', (
      tester,
    ) async {
      final SharedPreferences prefs = await _prefs({
        'enable_meal_tracking': false,
      });
      await tester.pumpWidget(_app(const SettingsScreen(), prefs));
      await tester.pump();

      expect(find.text(_en.requiresMealTracking), findsOneWidget);

      final Finder stock = find.text(_en.stockTracking);
      await tester.ensureVisible(stock);
      await tester.pump();
      await tester.tap(stock);
      await tester.pump();

      expect(prefs.getBool('enable_stock_tracking'), isNull);
    });

    testWidgets('API configuration expander reveals token and model', (
      tester,
    ) async {
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_app(const SettingsScreen(), prefs));
      await tester.pump();

      final Finder expander = find.text(_en.aiApiConfiguration);
      await tester.ensureVisible(expander);
      await tester.pumpAndSettle();
      expect(find.text(_en.apiTokenKey), findsNothing);

      await tester.tap(expander);
      await tester.pumpAndSettle();

      expect(find.text(_en.apiTokenKey), findsOneWidget);
      expect(find.text(_en.modelName), findsOneWidget);
      expect(find.text(_en.testConnection), findsOneWidget);
    });

    testWidgets('renders at 360dp without overflow', (tester) async {
      _setViewport(tester, const Size(360, 640));
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_app(const SettingsScreen(), prefs));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('backup screen', () {
    testWidgets('lists export actions before import actions', (tester) async {
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_app(const BackupScreen(), prefs));
      await tester.pump();

      expect(find.text(_en.exportAction), findsWidgets);
      expect(find.text(_en.importAction), findsWidgets);

      final double exportX = tester
          .getTopLeft(find.text(_en.exportAction).first)
          .dx;
      final double importX = tester
          .getTopLeft(find.text(_en.importAction).first)
          .dx;
      expect(exportX, lessThan(importX));
    });

    testWidgets('groups documentation and renders at 360dp', (tester) async {
      _setViewport(tester, const Size(360, 640));
      final SharedPreferences prefs = await _prefs();
      await tester.pumpWidget(_app(const BackupScreen(), prefs));
      await tester.pump();

      expect(find.text(_en.importFormatDocumentation), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
