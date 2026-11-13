/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Behaviour ported from LibreFit's PlateCalculator.kt (commit 8db76211).
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/util/plate_calculator.dart';
import 'package:nexc_flutter/core/util/unit_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final metricPlates = standardPlatesFor(UnitSystem.metric);
  final imperialPlates = standardPlatesFor(UnitSystem.imperial);

  group('standard equipment', () {
    test('metric plates and bars match the upstream catalogue', () {
      expect(metricPlates, [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25, 0.5, 0.25]);
      expect(standardBarsFor(UnitSystem.metric), [20.0, 15.0, 10.0, 5.0]);
    });

    test('imperial plates and bars are converted to kilograms', () {
      expect(imperialPlates, hasLength(6));
      expect(
        imperialPlates.first,
        closeTo(toKilograms(45.0, UnitSystem.imperial), 1e-12),
      );
      expect(standardBarsFor(UnitSystem.imperial), hasLength(3));
      expect(
        standardBarsFor(UnitSystem.imperial).first,
        closeTo(toKilograms(45.0, UnitSystem.imperial), 1e-12),
      );
    });
  });

  group('calculatePlates', () {
    test('uses a greedy largest-first strategy (100 kg, 20 kg bar)', () {
      final breakdown = calculatePlates(
        targetKg: 100.0,
        barKg: 20.0,
        availablePlatesKg: metricPlates,
      );

      // 40 kg per side: 25 + 15.
      expect(breakdown.platesPerSideKg.keys.toList(), [25.0, 15.0]);
      expect(breakdown.platesPerSideKg[25.0], 1);
      expect(breakdown.platesPerSideKg[15.0], 1);
      expect(breakdown.remainderKg, closeTo(0.0, 1e-9));
      expect(breakdown.closestAchievableKg, closeTo(100.0, 1e-9));
    });

    test('repeats plates when needed (120 kg, 20 kg bar)', () {
      final breakdown = calculatePlates(
        targetKg: 120.0,
        barKg: 20.0,
        availablePlatesKg: metricPlates,
      );

      // 50 kg per side: 2 x 25.
      expect(breakdown.platesPerSideKg, {25.0: 2});
      expect(breakdown.remainderKg, closeTo(0.0, 1e-9));
    });

    test('achieves an exact fractional fit (102.5 kg, 20 kg bar)', () {
      final breakdown = calculatePlates(
        targetKg: 102.5,
        barKg: 20.0,
        availablePlatesKg: metricPlates,
      );

      // 41.25 kg per side: 25 + 15 + 1.25.
      expect(breakdown.platesPerSideKg.keys.toList(), [25.0, 15.0, 1.25]);
      expect(breakdown.platesPerSideKg[25.0], 1);
      expect(breakdown.platesPerSideKg[15.0], 1);
      expect(breakdown.platesPerSideKg[1.25], 1);
      expect(breakdown.remainderKg, closeTo(0.0, 1e-9));
      expect(breakdown.closestAchievableKg, closeTo(102.5, 1e-9));
    });

    test('rounds the remainder to two decimal digits (60.02 kg)', () {
      final breakdown = calculatePlates(
        targetKg: 60.02,
        barKg: 20.0,
        availablePlatesKg: metricPlates,
      );

      // 20.005 kg per side: 20 fits, 0.005 rounds to 0.01.
      expect(breakdown.platesPerSideKg, {20.0: 1});
      expect(breakdown.remainderKg, closeTo(0.01, 1e-9));
    });

    test(
      'returns empty plates when the target is below or equal to the bar',
      () {
        final belowBar = calculatePlates(
          targetKg: 10.0,
          barKg: 20.0,
          availablePlatesKg: metricPlates,
        );
        final equalToBar = calculatePlates(
          targetKg: 20.0,
          barKg: 20.0,
          availablePlatesKg: metricPlates,
        );

        expect(belowBar.platesPerSideKg, isEmpty);
        expect(belowBar.remainderKg, closeTo(0.0, 1e-9));
        expect(belowBar.closestAchievableKg, closeTo(10.0, 1e-9));

        expect(equalToBar.platesPerSideKg, isEmpty);
        expect(equalToBar.remainderKg, closeTo(0.0, 1e-9));
        expect(equalToBar.closestAchievableKg, closeTo(20.0, 1e-9));
      },
    );

    test('ignores small plates when they are excluded (52.5 kg)', () {
      final available = filterSmallPlates(
        metricPlates,
        includeSmallPlates: false,
        system: UnitSystem.metric,
      );
      final breakdown = calculatePlates(
        targetKg: 52.5,
        barKg: 20.0,
        availablePlatesKg: available,
      );

      // 16.25 kg per side: 15 fits, 1.25 kg of small plate would be needed.
      expect(breakdown.platesPerSideKg, {15.0: 1});
      expect(breakdown.remainderKg, closeTo(1.25, 1e-9));
      expect(breakdown.closestAchievableKg, closeTo(50.0, 1e-9));
    });

    test('works with imperial plates (225 lb, 45 lb bar)', () {
      final breakdown = calculatePlates(
        targetKg: toKilograms(225.0, UnitSystem.imperial),
        barKg: toKilograms(45.0, UnitSystem.imperial),
        availablePlatesKg: imperialPlates,
      );

      // 90 lb per side: 2 x 45 lb.
      expect(breakdown.platesPerSideKg.values.toList(), [2]);
      expect(
        breakdown.platesPerSideKg.keys.single,
        closeTo(toKilograms(45.0, UnitSystem.imperial), 1e-12),
      );
      expect(breakdown.remainderKg, closeTo(0.0, 1e-9));
      expect(
        fromKilograms(breakdown.closestAchievableKg, UnitSystem.imperial),
        closeTo(225.0, 1e-9),
      );
    });

    test(
      'closest achievable derives from the unrounded leftover (103.76 kg)',
      () {
        final breakdown = calculatePlates(
          targetKg: 103.76,
          barKg: 20.0,
          availablePlatesKg: metricPlates,
        );

        // 41.88 kg per side: 25 + 15 + 1.25 + 0.5 = 41.75 loaded.
        expect(breakdown.platesPerSideKg.keys.toList(), [
          25.0,
          15.0,
          1.25,
          0.5,
        ]);
        expect(breakdown.remainderKg, closeTo(0.13, 1e-9));
        expect(breakdown.closestAchievableKg, closeTo(103.5, 1e-9));

        final loadedPerSideKg = breakdown.platesPerSideKg.entries.fold<double>(
          0.0,
          (sum, entry) => sum + entry.key * entry.value,
        );
        expect(
          breakdown.closestAchievableKg,
          closeTo(2 * loadedPerSideKg + 20.0, 1e-9),
        );
      },
    );

    test('is unit-system equivalent between kg and lb inputs', () {
      final metric = calculatePlates(
        targetKg: 100.0,
        barKg: 20.0,
        availablePlatesKg: metricPlates,
      );
      final imperialInput = calculatePlates(
        targetKg: toKilograms(220.46, UnitSystem.imperial),
        barKg: 20.0,
        availablePlatesKg: metricPlates,
      );

      expect(imperialInput.platesPerSideKg, metric.platesPerSideKg);
      expect(imperialInput.remainderKg, closeTo(metric.remainderKg, 1e-9));
    });
  });

  group('isSmallPlate', () {
    test('classifies fractional plates per unit system', () {
      expect(isSmallPlate(1.25, UnitSystem.metric), isTrue);
      expect(isSmallPlate(0.5, UnitSystem.metric), isTrue);
      expect(isSmallPlate(0.25, UnitSystem.metric), isTrue);
      expect(isSmallPlate(2.5, UnitSystem.metric), isFalse);

      expect(
        isSmallPlate(
          toKilograms(1.25, UnitSystem.imperial),
          UnitSystem.imperial,
        ),
        isTrue,
      );
      expect(
        isSmallPlate(
          toKilograms(2.5, UnitSystem.imperial),
          UnitSystem.imperial,
        ),
        isFalse,
      );
      expect(isSmallPlate(45.0, UnitSystem.metric), isFalse);
    });
  });

  group('filterSmallPlates', () {
    test('excludes fractional plates when disabled', () {
      final withoutSmall = filterSmallPlates(
        metricPlates,
        includeSmallPlates: false,
        system: UnitSystem.metric,
      );

      expect(withoutSmall, [25.0, 20.0, 15.0, 10.0, 5.0, 2.5]);
    });

    test('keeps every plate when enabled', () {
      final withSmall = filterSmallPlates(
        metricPlates,
        includeSmallPlates: true,
        system: UnitSystem.metric,
      );

      expect(withSmall, hasLength(metricPlates.length));
    });
  });

  group('defaultBarWeightKg setting', () {
    test('defaults to null', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      expect(notifier.state.defaultBarWeightKg, isNull);
      expect(prefs.getDouble('default_bar_weight_kg'), isNull);
    });

    test('persists the last chosen bar under default_bar_weight_kg', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier(prefs);
      addTearDown(notifier.dispose);

      await notifier.setDefaultBarWeightKg(15.0);

      expect(notifier.state.defaultBarWeightKg, 15.0);
      expect(prefs.getDouble('default_bar_weight_kg'), 15.0);

      final reloaded = SettingsNotifier(prefs);
      addTearDown(reloaded.dispose);
      expect(reloaded.state.defaultBarWeightKg, 15.0);
    });
  });
}
