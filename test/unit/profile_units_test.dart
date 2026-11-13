/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:nexc_flutter/core/providers/db_provider.dart';
import 'package:nexc_flutter/core/providers/profile_providers.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/util/unit_system.dart';
import 'package:nexc_flutter/features/profile/log_measurement_screen.dart';
import 'package:nexc_flutter/features/profile/measurements_screen.dart';
import 'package:nexc_flutter/features/profile/profile_screen.dart';
import 'package:nexc_flutter/features/workout/workout_ai_chat_screen.dart';

const double _kgFor180Lb = 180 * kilogramsPerPound;

Future<SharedPreferences> _prefs(UnitSystem system) async {
  SharedPreferences.setMockInitialValues({'unit_system': system.name});
  return SharedPreferences.getInstance();
}

/// Builds a widget test scope backed by an in-memory database.
///
/// The database is intentionally left open: closing it while the widget test
/// fake clock owns pending drift operations deadlocks the test teardown. Each
/// test creates its own in-memory database, so nothing leaks across tests.
Widget _app({
  required SharedPreferences prefs,
  required AppDatabase db,
  required Widget home,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(db),
    ],
    child: MaterialApp(home: home),
  );
}

BodyMeasurement _measurement(int id, double kilograms, DateTime date) {
  return BodyMeasurement(id: id, bodyWeight: kilograms, date: date);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Log measurement weight input', () {
    testWidgets('label follows the selected unit system', (tester) async {
      final prefs = await _prefs(UnitSystem.imperial);
      final db = AppDatabase.executor(NativeDatabase.memory());

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const LogMeasurementScreen()),
      );
      await tester.pump();

      expect(find.text('Body Weight (lb)'), findsOneWidget);
      expect(find.text('Body Weight (kg)'), findsNothing);
    });

    testWidgets('180 lb is stored as 81.65 kg', (tester) async {
      final prefs = await _prefs(UnitSystem.imperial);
      final db = AppDatabase.executor(NativeDatabase.memory());

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const LogMeasurementScreen()),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, '180');
      await tester.tap(find.byIcon(Icons.check).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final rows = await db.select(db.bodyMeasurements).get();
      expect(rows, hasLength(1));
      expect(rows.single.bodyWeight, closeTo(81.65, 0.01));
    });

    testWidgets('metric input stays unchanged in kilograms', (tester) async {
      final prefs = await _prefs(UnitSystem.metric);
      final db = AppDatabase.executor(NativeDatabase.memory());

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const LogMeasurementScreen()),
      );
      await tester.pump();

      expect(find.text('Body Weight (kg)'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '81.65');
      await tester.tap(find.byIcon(Icons.check).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final rows = await db.select(db.bodyMeasurements).get();
      expect(rows.single.bodyWeight, closeTo(81.65, 0.0001));
    });
  });

  group('Weight chart conversion', () {
    test('converts chart spots from kilograms to the selected unit', () {
      final spots = [FlSpot(0, _kgFor180Lb), FlSpot(1, 90.0)];

      final imperial = convertWeightSpots(spots, UnitSystem.imperial);
      expect(imperial[0].y, closeTo(180, 0.01));
      expect(imperial[1].y, closeTo(90 / kilogramsPerPound, 0.01));

      final metric = convertWeightSpots(spots, UnitSystem.metric);
      expect(metric[0].y, closeTo(_kgFor180Lb, 0.0001));
      expect(metric[1].y, closeTo(90.0, 0.0001));
    });

    test('keeps metric chart values untouched', () {
      final spots = [FlSpot(0, 81.65), FlSpot(1, 90.0)];
      final converted = convertWeightSpots(spots, UnitSystem.metric);

      expect(converted.map((spot) => spot.y), orderedEquals([81.65, 90.0]));
    });
  });

  group('Measurements history and chart display', () {
    testWidgets('81.65 kg is shown as 180 lb in imperial', (tester) async {
      final prefs = await _prefs(UnitSystem.imperial);
      final db = AppDatabase.executor(NativeDatabase.memory());
      await db
          .into(db.bodyMeasurements)
          .insert(_measurement(1, _kgFor180Lb, DateTime(2026, 11, 1)));

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const MeasurementsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Weight: 180 lb'), findsOneWidget);
      expect(find.textContaining('kg'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('weight chart labels use the selected unit', (tester) async {
      final prefs = await _prefs(UnitSystem.imperial);
      final db = AppDatabase.executor(NativeDatabase.memory());
      await db
          .into(db.bodyMeasurements)
          .insert(_measurement(1, _kgFor180Lb, DateTime(2026, 11, 1)));
      await db
          .into(db.bodyMeasurements)
          .insert(_measurement(2, 90.718474, DateTime(2026, 11, 2)));

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const MeasurementsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weight Progress'), findsOneWidget);
      expect(find.textContaining('Latest'), findsOneWidget);
      expect(find.textContaining('180 lb'), findsWidgets);
      expect(find.textContaining('kg'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('metric history stays in kilograms', (tester) async {
      final prefs = await _prefs(UnitSystem.metric);
      final db = AppDatabase.executor(NativeDatabase.memory());
      await db
          .into(db.bodyMeasurements)
          .insert(_measurement(1, 81.65, DateTime(2026, 11, 1)));

      await tester.pumpWidget(
        _app(prefs: prefs, db: db, home: const MeasurementsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Weight: 81.65 kg'), findsOneWidget);
      expect(find.textContaining('lb'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Profile overview volume chart', () {
    test('converts volume chart points for the selected unit', () {
      final metric = Point(yValues: [100.0], xValue: '1/11', workoutId: 1);

      final imperial = convertChartPointToUnit(
        metric,
        WorkoutChart.volume,
        UnitSystem.imperial,
      );
      expect(imperial.yValues.single, closeTo(220.46, 0.01));

      final unchanged = convertChartPointToUnit(
        metric,
        WorkoutChart.volume,
        UnitSystem.metric,
      );
      expect(unchanged.yValues.single, 100.0);
    });

    test('leaves non-weight chart points untouched', () {
      final metric = Point(yValues: [60.0], xValue: '1/11', workoutId: 1);

      final converted = convertChartPointToUnit(
        metric,
        WorkoutChart.duration,
        UnitSystem.imperial,
      );
      expect(converted.yValues.single, 60.0);
    });
  });

  group('Workout AI chat latest weight', () {
    test('shows imperial measurements in pounds', () {
      final measurement = _measurement(1, _kgFor180Lb, DateTime(2026, 11, 2));

      final summary = formatLatestWeightSummary(
        measurement,
        UnitSystem.imperial,
      );

      expect(summary, 'Latest weight: 180 lb recorded on 11/2/2026.');
    });

    test('keeps canonical kilograms for metric users', () {
      final measurement = _measurement(1, 81.65, DateTime(2026, 11, 2));

      final summary = formatLatestWeightSummary(measurement, UnitSystem.metric);

      expect(summary, 'Latest weight: 81.65 kg recorded on 11/2/2026.');
    });
  });
}
