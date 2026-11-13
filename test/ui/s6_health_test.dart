/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/components/nexc_tile.dart';
import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:nexc_flutter/core/providers/db_provider.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/theme/theme.dart';
import 'package:nexc_flutter/core/util/unit_system.dart';
import 'package:nexc_flutter/features/profile/log_measurement_screen.dart';
import 'package:nexc_flutter/features/profile/measurements_screen.dart';
import 'package:nexc_flutter/features/profile/personal_info_screen.dart';
import 'package:nexc_flutter/features/settings/measurements_settings_screen.dart';
import 'package:nexc_flutter/l10n/app_localizations.dart';

const double _kgFor180Lb = 180 * kilogramsPerPound;

Future<SharedPreferences> _prefs({
  UnitSystem system = UnitSystem.metric,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'unit_system': system.name,
  });
  return SharedPreferences.getInstance();
}

Future<SharedPreferences> _prefsWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Widget _app({
  required SharedPreferences prefs,
  required AppDatabase db,
  required Widget home,
  double textScale = 1.0,
}) {
  return ProviderScope(
    overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(db),
    ],
    child: MaterialApp(
      theme: createNexcTheme(lightColorScheme),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: home,
    ),
  );
}

void _phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

BodyMeasurement _measurement(int id, double kilograms, DateTime date) {
  return BodyMeasurement(id: id, bodyWeight: kilograms, date: date);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Measurements tabs', () {
    testWidgets('render localized history labels', (tester) async {
      final prefs = await _prefsWith(<String, Object>{
        'unit_system': UnitSystem.metric.name,
        'enable_sleep': true,
        'enable_activity': true,
      });
      final db = AppDatabase.executor(NativeDatabase.memory());

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const MeasurementsScreen()),
      );
      await tester.pumpAndSettle();

      final Finder tabBar = find.byType(TabBar);
      expect(
        find.descendant(of: tabBar, matching: find.text('Body History')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: tabBar, matching: find.text('Sleep History')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: tabBar, matching: find.text('Activity History')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Measurements history units', () {
    testWidgets('weight row follows the imperial unit system', (tester) async {
      final prefs = await _prefs(system: UnitSystem.imperial);
      final db = AppDatabase.executor(NativeDatabase.memory());
      await db
          .into(db.bodyMeasurements)
          .insert(_measurement(1, _kgFor180Lb, DateTime(2026, 11, 1)));

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const MeasurementsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weight: 180 lb'), findsOneWidget);
      expect(find.textContaining('kg'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('weight row stays in kilograms for metric users', (
      tester,
    ) async {
      final prefs = await _prefs();
      final db = AppDatabase.executor(NativeDatabase.memory());
      await db
          .into(db.bodyMeasurements)
          .insert(_measurement(1, 81.65, DateTime(2026, 11, 1)));

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const MeasurementsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weight: 81.65 kg'), findsOneWidget);
      expect(find.textContaining('lb'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Log measurement', () {
    testWidgets('has one save action and validates zero weight', (
      tester,
    ) async {
      final prefs = await _prefs();
      final db = AppDatabase.executor(NativeDatabase.memory());

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const LogMeasurementScreen()),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '0');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(find.text('Error: Body Weight (kg)'), findsOneWidget);
      expect(await db.select(db.bodyMeasurements).get(), isEmpty);

      await tester.enterText(find.byType(TextField).first, '81.65');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final List<BodyMeasurement> rows = await db
          .select(db.bodyMeasurements)
          .get();
      expect(rows, hasLength(1));
      expect(rows.single.bodyWeight, closeTo(81.65, 0.0001));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Personal info height', () {
    testWidgets('uses inches for imperial users and stores centimetres', (
      tester,
    ) async {
      final prefs = await _prefs(system: UnitSystem.imperial);
      final db = AppDatabase.executor(NativeDatabase.memory());

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const PersonalInfoScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Height (cm)'), findsNothing);
      expect(find.textContaining('(in)'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '70');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      final user = await db.select(db.users).getSingle();
      expect(user.height, closeTo(177.8, 0.1));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('keeps the centimetre label for metric users', (tester) async {
      final prefs = await _prefs();
      final db = AppDatabase.executor(NativeDatabase.memory());

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const PersonalInfoScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Height (cm)'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Measurements settings', () {
    testWidgets('advanced sleep is disabled while sleep is off', (
      tester,
    ) async {
      final prefs = await _prefsWith(<String, Object>{
        'unit_system': UnitSystem.metric.name,
        'enable_sleep': false,
        'enable_advanced_sleep': true,
      });
      final db = AppDatabase.executor(NativeDatabase.memory());

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const MeasurementsSettingsScreen()),
      );
      await tester.pump();

      Finder tile(String title) => find.widgetWithText(NexcTile, title);
      Switch toggle(String title) => tester.widget<Switch>(
        find.descendant(of: tile(title), matching: find.byType(Switch)),
      );

      expect(toggle('Sleep Measurements').onChanged, isNotNull);
      expect(toggle('Advanced Sleep Measurements').onChanged, isNull);

      await tester.tap(tile('Sleep Measurements'));
      await tester.pumpAndSettle();

      expect(toggle('Advanced Sleep Measurements').onChanged, isNotNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Compact layout', () {
    testWidgets('screens do not overflow at 360x640 with large text', (
      tester,
    ) async {
      _phoneSize(tester);
      final prefs = await _prefsWith(<String, Object>{
        'unit_system': UnitSystem.imperial.name,
        'enable_sleep': true,
        'enable_advanced_sleep': true,
        'enable_activity': true,
        'enable_advanced_body': true,
      });
      final db = AppDatabase.executor(NativeDatabase.memory());
      await db
          .into(db.bodyMeasurements)
          .insert(_measurement(1, _kgFor180Lb, DateTime(2026, 11, 1)));
      await db
          .into(db.bodyMeasurements)
          .insert(_measurement(2, 81.0, DateTime(2026, 11, 2)));

      await tester.pumpWidget(
        _app(
          prefs: prefs,
          db: db,
          home: const MeasurementsScreen(),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _app(
          prefs: prefs,
          db: db,
          home: const LogMeasurementScreen(),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _app(
          prefs: prefs,
          db: db,
          home: const PersonalInfoScreen(),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _app(
          prefs: prefs,
          db: db,
          home: const MeasurementsSettingsScreen(),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
