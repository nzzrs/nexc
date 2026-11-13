/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/util/unit_system.dart';

void main() {
  group('UnitSystem', () {
    test('exposes a display suffix', () {
      expect(UnitSystem.metric.suffix, 'kg');
      expect(UnitSystem.imperial.suffix, 'lb');
    });

    test('converts pounds to kilograms', () {
      expect(toKilograms(45, UnitSystem.imperial), closeTo(20.41165665, 1e-9));
      expect(toKilograms(1, UnitSystem.imperial), kilogramsPerPound);
    });

    test('keeps metric values unchanged', () {
      expect(toKilograms(45, UnitSystem.metric), 45);
      expect(UnitSystem.metric.suffix, 'kg');
    });

    test('converts kilograms to pounds', () {
      expect(
        fromKilograms(kilogramsPerPound, UnitSystem.imperial),
        closeTo(1, 1e-9),
      );
      expect(
        fromKilograms(100, UnitSystem.imperial),
        closeTo(220.46226218, 1e-8),
      );
      expect(fromKilograms(100, UnitSystem.metric), 100);
    });

    test('round-trips through kilograms', () {
      for (final system in UnitSystem.values) {
        final kilograms = toKilograms(135, system);
        expect(fromKilograms(kilograms, system), closeTo(135, 1e-9));
      }
    });
  });

  group('formatWeight', () {
    test('formats metric values without trailing zeros', () {
      expect(formatWeight(100, UnitSystem.metric), '100');
      expect(formatWeight(100.5, UnitSystem.metric), '100.5');
      expect(formatWeight(100.50, UnitSystem.metric), '100.5');
      expect(formatWeight(100.456, UnitSystem.metric), '100.46');
    });

    test('formats imperial values in pounds', () {
      expect(formatWeight(100, UnitSystem.imperial), '220.46');
      expect(formatWeight(45.359237, UnitSystem.imperial), '100');
    });

    test('honours maxDecimals', () {
      expect(formatWeight(100.456, UnitSystem.metric, maxDecimals: 1), '100.5');
      expect(
        formatWeight(100.456, UnitSystem.metric, maxDecimals: 3),
        '100.456',
      );
      expect(formatWeight(100, UnitSystem.metric, maxDecimals: 0), '100');
    });

    test('appends only the given suffix', () {
      expect(formatWeight(100, UnitSystem.metric, suffix: 'kg'), '100 kg');
      expect(formatWeight(100, UnitSystem.metric), '100');
      expect(formatWeight(100, UnitSystem.metric, suffix: ''), '100');
    });

    test('never returns a negative zero', () {
      expect(formatWeight(-0.0, UnitSystem.metric), '0');
      expect(formatWeight(-0.001, UnitSystem.metric), '0');
      expect(formatWeight(-0.0001, UnitSystem.imperial), '0');
    });
  });

  group('parseWeight', () {
    test('parses metric input', () {
      expect(parseWeight('45', UnitSystem.metric), 45);
      expect(parseWeight(' 45.5 ', UnitSystem.metric), 45.5);
      expect(parseWeight('45,5', UnitSystem.metric), 45.5);
    });

    test('parses imperial input as kilograms', () {
      expect(
        parseWeight('45', UnitSystem.imperial),
        closeTo(20.41165665, 1e-9),
      );
      expect(
        parseWeight('100 lb', UnitSystem.imperial),
        isNull,
        reason: 'only numeric values are accepted',
      );
    });

    test('rejects empty, non-numeric, non-finite and negative input', () {
      expect(parseWeight('', UnitSystem.metric), isNull);
      expect(parseWeight('   ', UnitSystem.metric), isNull);
      expect(parseWeight('abc', UnitSystem.metric), isNull);
      expect(parseWeight('12abc', UnitSystem.metric), isNull);
      expect(parseWeight('NaN', UnitSystem.metric), isNull);
      expect(parseWeight('Infinity', UnitSystem.metric), isNull);
      expect(parseWeight('-5', UnitSystem.metric), isNull);
      expect(parseWeight('-0.5', UnitSystem.imperial), isNull);
    });

    test('round-trips through formatWeight', () {
      final kilograms = parseWeight('225', UnitSystem.imperial)!;
      expect(formatWeight(kilograms, UnitSystem.imperial), '225');
    });
  });

  group('resolveDefaultUnitSystem', () {
    test('is imperial for the United States, Liberia and Myanmar', () {
      expect(
        resolveDefaultUnitSystem(const Locale('en', 'US')),
        UnitSystem.imperial,
      );
      expect(
        resolveDefaultUnitSystem(const Locale('en', 'LR')),
        UnitSystem.imperial,
      );
      expect(
        resolveDefaultUnitSystem(const Locale('my', 'MM')),
        UnitSystem.imperial,
      );
      expect(
        resolveDefaultUnitSystem(const Locale('en', 'us')),
        UnitSystem.imperial,
      );
    });

    test('is metric everywhere else', () {
      expect(
        resolveDefaultUnitSystem(const Locale('it', 'IT')),
        UnitSystem.metric,
      );
      expect(
        resolveDefaultUnitSystem(const Locale('de', 'DE')),
        UnitSystem.metric,
      );
      expect(
        resolveDefaultUnitSystem(const Locale('en', 'GB')),
        UnitSystem.metric,
      );
      expect(resolveDefaultUnitSystem(const Locale('en')), UnitSystem.metric);
    });

    test('platform convenience matches the platform locale', () {
      expect(
        resolveDefaultUnitSystemFromPlatform(),
        resolveDefaultUnitSystem(PlatformDispatcher.instance.locale),
      );
    });
  });
}
