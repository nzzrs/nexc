/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Behaviour ported from LibreFit's InputModalBottomSheetStateTest.kt
 * (commit 03a4cb6f).
 */

import 'package:flutter_test/flutter_test.dart';

import 'package:nexc_flutter/core/util/input_sheet_state.dart';
import 'package:nexc_flutter/core/util/unit_system.dart';

void main() {
  group('time sheet state', () {
    test('stepping carries over from seconds to minutes', () {
      final InputSheetState state = InputSheetState.time(seconds: 50);

      final InputSheetState stepped = state.steppedBy(30);

      expect(stepped.minutes, 1);
      expect(stepped.seconds, 20);
      expect(stepped.totalSeconds, 80);
    });

    test('stepping backwards borrows from minutes', () {
      final InputSheetState state = InputSheetState.time(seconds: 65);

      final InputSheetState stepped = state.steppedBy(-30);

      expect(stepped.minutes, 0);
      expect(stepped.seconds, 35);
      expect(stepped.totalSeconds, 35);
    });

    test('clamps at zero', () {
      final InputSheetState state = InputSheetState.time(seconds: 10);

      expect(state.steppedBy(-30).totalSeconds, 0);
    });

    test('clamps at the maximum of 59:59', () {
      final InputSheetState state = InputSheetState.time(seconds: 3599);

      expect(state.steppedBy(30).totalSeconds, 3599);
    });

    test('zero delta returns an equal state', () {
      final InputSheetState state = InputSheetState.time(seconds: 205);

      expect(state.steppedBy(0), equals(state));
    });

    test('formats as minutes and seconds', () {
      expect(InputSheetState.time(seconds: 65).formattedValue, '01:05');
      expect(InputSheetState.time(seconds: 5).formattedValue, '00:05');
      expect(InputSheetState.time(seconds: 3599).formattedValue, '59:59');
    });

    test('converts to and from storage seconds', () {
      final InputSheetState state = InputSheetState.time(seconds: 95);

      expect(state.storageValue, 95);
      expect(state.totalSeconds, 95);
    });

    test('quick buttons step by 5 and 30 seconds', () {
      final InputSheetState state = InputSheetState.time(seconds: 65);

      expect(state.quickIncrement().totalSeconds, 70);
      expect(state.quickDecrement().totalSeconds, 60);
      expect(state.majorIncrement().totalSeconds, 95);
      expect(state.majorDecrement().totalSeconds, 35);
    });
  });

  group('reps sheet state', () {
    test('increments and decrements', () {
      final InputSheetState state = InputSheetState.reps(reps: 8);

      expect(state.increment().reps, 9);
      expect(state.decrement().reps, 7);
      expect(state.quickIncrement().reps, 9);
      expect(state.majorIncrement().reps, 13);
      expect(state.majorDecrement().reps, 3);
    });

    test('quick buttons step by one and five reps', () {
      final InputSheetState state = InputSheetState.reps(reps: 8);

      expect(state.quickDecrement().reps, 7);
      expect(state.majorIncrement().reps, 13);
    });

    test('clamps at both bounds', () {
      expect(InputSheetState.reps(reps: 2).steppedBy(-5).reps, 0);
      expect(InputSheetState.reps(reps: 997).steppedBy(5).reps, 999);
    });

    test('formats and converts to storage reps', () {
      final InputSheetState state = InputSheetState.reps(reps: 12);

      expect(state.formattedValue, '12');
      expect(state.storageValue, 12);
      expect(state.suffix, isEmpty);
    });
  });

  group('load sheet state', () {
    test('converts a stored kilogram load into the display unit', () {
      final InputSheetState state = InputSheetState.load(
        kilograms: 100,
        unitSystem: UnitSystem.imperial,
      );

      // The imperial wheel is one pound, so 220.46 lb snaps to 220 lb.
      expect(state.value, 220);
      expect(state.formattedValue, '220');
      expect(state.suffix, 'lb');
      expect(
        (state.storageValue as double),
        closeTo(toKilograms(220, UnitSystem.imperial), 1e-9),
      );
    });

    test('converts a display value back to kilograms', () {
      final InputSheetState state = InputSheetState.load(
        kilograms: toKilograms(100, UnitSystem.imperial),
        unitSystem: UnitSystem.imperial,
      );

      expect(state.value, closeTo(100, 1e-9));
      expect(state.formattedValue, '100');
      expect(
        (state.storageValue as double),
        closeTo(toKilograms(100, UnitSystem.imperial), 1e-9),
      );
    });

    test('metric steps by 2.5 kg and 0.5 kg', () {
      final InputSheetState state = InputSheetState.load(
        kilograms: 100,
        unitSystem: UnitSystem.metric,
      );

      expect(state.increment().value, 100.5);
      expect(state.decrement().value, 99.5);
      expect(state.quickIncrement().value, 100.5);
      expect(state.majorIncrement().value, 102.5);
      expect(state.majorDecrement().value, 97.5);
    });

    test('imperial steps by 5 lb and 1 lb', () {
      final InputSheetState state = InputSheetState.load(
        kilograms: toKilograms(100, UnitSystem.imperial),
        unitSystem: UnitSystem.imperial,
      );

      expect(state.increment().value, closeTo(101, 1e-9));
      expect(state.decrement().value, closeTo(99, 1e-9));
      expect(state.majorIncrement().value, closeTo(105, 1e-9));
      expect(state.majorDecrement().value, closeTo(95, 1e-9));
    });

    test('steps the integer part and preserves the snapped value', () {
      final InputSheetState state = InputSheetState.load(
        kilograms: 62,
        unitSystem: UnitSystem.metric,
      );

      final InputSheetState stepped = state.steppedBy(10);

      expect(stepped.value, 72);
      expect(stepped.formattedValue, '72');
    });

    test('snaps a value outside the step grid', () {
      final InputSheetState state = InputSheetState.load(
        kilograms: 62.3,
        unitSystem: UnitSystem.metric,
      );

      expect(state.value, 62.5);
    });

    test('clamps at range bounds while keeping the step', () {
      expect(
        InputSheetState.load(
          kilograms: 2,
          unitSystem: UnitSystem.metric,
        ).steppedBy(-10).value,
        0,
      );
      expect(
        InputSheetState.load(
          kilograms: 999,
          unitSystem: UnitSystem.metric,
        ).steppedBy(10).value,
        999,
      );
    });

    test('trims trailing zeros when formatting', () {
      expect(
        InputSheetState.load(
          kilograms: 62,
          unitSystem: UnitSystem.metric,
        ).formattedValue,
        '62',
      );
      expect(
        InputSheetState.load(
          kilograms: 62.5,
          unitSystem: UnitSystem.metric,
        ).formattedValue,
        '62.5',
      );
    });
  });
}
