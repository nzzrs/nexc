/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:nexc_flutter/core/util/day_window_helper.dart';

void main() {
  group('DayWindowHelper Tests', () {
    const defaultResetHour = 5;
    const defaultResetMinute = 0;

    group('Default 5:00 AM Reset Window Calculations', () {
      test('5:00 AM starts a new day window ending next day at 5:00 AM', () {
        final now = DateTime(2026, 10, 2, 5, 0, 0);
        final window = DayWindowHelper.getDayWindow(now, defaultResetHour, defaultResetMinute);

        expect(window.start, equals(DateTime(2026, 10, 2, 5, 0, 0)));
        expect(window.end, equals(DateTime(2026, 10, 3, 5, 0, 0)));
        expect(DayWindowHelper.isWithinDayWindow(now, now, defaultResetHour, defaultResetMinute), isTrue);
      });

      test('4:59 AM belongs to yesterday window (started yesterday at 5:00 AM)', () {
        final now = DateTime(2026, 10, 2, 4, 59, 59);
        final window = DayWindowHelper.getDayWindow(now, defaultResetHour, defaultResetMinute);

        expect(window.start, equals(DateTime(2026, 10, 1, 5, 0, 0)));
        expect(window.end, equals(DateTime(2026, 10, 2, 5, 0, 0)));
        expect(DayWindowHelper.isWithinDayWindow(now, now, defaultResetHour, defaultResetMinute), isTrue);
      });

      test('11:59 PM and 2:00 AM across midnight belong to the exact same day window', () {
        final lateNight = DateTime(2026, 10, 2, 23, 59, 0);
        final earlyMorning = DateTime(2026, 10, 3, 2, 0, 0);

        final windowLate = DayWindowHelper.getDayWindow(lateNight, defaultResetHour, defaultResetMinute);
        final windowEarly = DayWindowHelper.getDayWindow(earlyMorning, defaultResetHour, defaultResetMinute);

        expect(windowLate.start, equals(windowEarly.start));
        expect(windowLate.end, equals(windowEarly.end));
        expect(windowLate.start, equals(DateTime(2026, 10, 2, 5, 0, 0)));
        expect(windowLate.end, equals(DateTime(2026, 10, 3, 5, 0, 0)));

        expect(DayWindowHelper.isWithinDayWindow(earlyMorning, lateNight, defaultResetHour, defaultResetMinute), isTrue);
        expect(DayWindowHelper.isWithinDayWindow(lateNight, earlyMorning, defaultResetHour, defaultResetMinute), isTrue);
      });

      test('Boundary test: exactly at 5:00:00 AM vs 4:59:59.999 AM', () {
        final preBoundary = DateTime(2026, 10, 2, 4, 59, 59, 999);
        final postBoundary = DateTime(2026, 10, 2, 5, 0, 0, 0);

        final windowPre = DayWindowHelper.getDayWindow(preBoundary, defaultResetHour, defaultResetMinute);
        final windowPost = DayWindowHelper.getDayWindow(postBoundary, defaultResetHour, defaultResetMinute);

        expect(windowPre.start, equals(DateTime(2026, 10, 1, 5, 0, 0)));
        expect(windowPre.end, equals(DateTime(2026, 10, 2, 5, 0, 0)));

        expect(windowPost.start, equals(DateTime(2026, 10, 2, 5, 0, 0)));
        expect(windowPost.end, equals(DateTime(2026, 10, 3, 5, 0, 0)));

        // Window inclusion checks: preBoundary is not in postBoundary window
        expect(DayWindowHelper.isWithinDayWindow(preBoundary, postBoundary, defaultResetHour, defaultResetMinute), isFalse);
        expect(DayWindowHelper.isWithinDayWindow(postBoundary, preBoundary, defaultResetHour, defaultResetMinute), isFalse);
      });
    });

    group('Configurable Reset Times', () {
      test('Midnight reset (00:00)', () {
        final now = DateTime(2026, 10, 2, 14, 30);
        final window = DayWindowHelper.getDayWindow(now, 0, 0);

        expect(window.start, equals(DateTime(2026, 10, 2, 0, 0)));
        expect(window.end, equals(DateTime(2026, 10, 3, 0, 0)));

        final early1201 = DateTime(2026, 10, 2, 0, 1);
        final late2359 = DateTime(2026, 10, 2, 23, 59);

        expect(DayWindowHelper.isWithinDayWindow(early1201, now, 0, 0), isTrue);
        expect(DayWindowHelper.isWithinDayWindow(late2359, now, 0, 0), isTrue);

        final nextDayEarly = DateTime(2026, 10, 3, 0, 1);
        expect(DayWindowHelper.isWithinDayWindow(nextDayEarly, now, 0, 0), isFalse);
      });

      test('Morning fractional reset (06:30 AM)', () {
        final at0629 = DateTime(2026, 10, 2, 6, 29, 59);
        final at0630 = DateTime(2026, 10, 2, 6, 30, 0);

        final windowBefore = DayWindowHelper.getDayWindow(at0629, 6, 30);
        final windowAfter = DayWindowHelper.getDayWindow(at0630, 6, 30);

        expect(windowBefore.start, equals(DateTime(2026, 10, 1, 6, 30)));
        expect(windowBefore.end, equals(DateTime(2026, 10, 2, 6, 30)));

        expect(windowAfter.start, equals(DateTime(2026, 10, 2, 6, 30)));
        expect(windowAfter.end, equals(DateTime(2026, 10, 3, 6, 30)));
      });

      test('Late night reset (23:00)', () {
        final at2259 = DateTime(2026, 10, 2, 22, 59);
        final at2301 = DateTime(2026, 10, 2, 23, 1);

        final windowBefore = DayWindowHelper.getDayWindow(at2259, 23, 0);
        final windowAfter = DayWindowHelper.getDayWindow(at2301, 23, 0);

        expect(windowBefore.start, equals(DateTime(2026, 10, 1, 23, 0)));
        expect(windowBefore.end, equals(DateTime(2026, 10, 2, 23, 0)));

        expect(windowAfter.start, equals(DateTime(2026, 10, 2, 23, 0)));
        expect(windowAfter.end, equals(DateTime(2026, 10, 3, 23, 0)));
      });
    });

    group('Minutes From Day Start Calculation & Meal Ordering', () {
      test('Minutes calculation at 5:00 AM reset accurately sorts meals chronologically across midnight', () {
        // Meals at various times:
        // Breakfast at 08:00
        // Lunch at 13:00
        // Dinner at 20:30
        // Late Snack at 02:15 AM
        // Pre-reset Snack at 04:45 AM
        // Reset itself at 05:00 AM
        final resetTime = const LocalTime(5, 0);
        final breakfast = const LocalTime(8, 0);
        final lunch = const LocalTime(13, 0);
        final dinner = const LocalTime(20, 30);
        final lateSnack = const LocalTime(2, 15);
        final preReset = const LocalTime(4, 45);

        final minReset = DayWindowHelper.getMinutesFromDayStart(resetTime, 5, 0);
        final minBreakfast = DayWindowHelper.getMinutesFromDayStart(breakfast, 5, 0);
        final minLunch = DayWindowHelper.getMinutesFromDayStart(lunch, 5, 0);
        final minDinner = DayWindowHelper.getMinutesFromDayStart(dinner, 5, 0);
        final minLateSnack = DayWindowHelper.getMinutesFromDayStart(lateSnack, 5, 0);
        final minPreReset = DayWindowHelper.getMinutesFromDayStart(preReset, 5, 0);

        expect(minReset, equals(0));
        expect(minBreakfast, equals(180)); // 3 hours * 60
        expect(minLunch, equals(480)); // 8 hours * 60
        expect(minDinner, equals(930)); // 15.5 hours * 60
        expect(minLateSnack, equals(1275)); // (19 + 2.25) * 60 = (24 + 2 - 5)*60 + 15 = 1275
        expect(minPreReset, equals(1425)); // (23 + 45/60)*60 = 1425

        // Assert strictly monotonic chronological ordering throughout the day window
        final mealList = [dinner, preReset, breakfast, lateSnack, lunch, resetTime];
        mealList.sort((a, b) => DayWindowHelper.getMinutesFromDayStart(a, 5, 0)
            .compareTo(DayWindowHelper.getMinutesFromDayStart(b, 5, 0)));

        expect(mealList, equals([resetTime, breakfast, lunch, dinner, lateSnack, preReset]));
      });

      test('Top-level helper aliases match class static methods', () {
        final now = DateTime(2026, 10, 2, 12, 0);
        expect(getDayWindow(now, 5, 0), equals(DayWindowHelper.getDayWindow(now, 5, 0)));
        expect(isWithinDayWindow(now, now, 5, 0), equals(DayWindowHelper.isWithinDayWindow(now, now, 5, 0)));
        expect(getMinutesFromDayStart(const LocalTime(12, 0), 5, 0),
            equals(DayWindowHelper.getMinutesFromDayStart(const LocalTime(12, 0), 5, 0)));
      });

      test('Year boundary crossover: New Year Eve at 23:59 to New Year Day at 02:00 AM', () {
        final nyeLate = DateTime(2026, 12, 31, 23, 59);
        final newYearEarly = DateTime(2027, 1, 1, 2, 0);

        final windowNYE = DayWindowHelper.getDayWindow(nyeLate, 5, 0);
        final windowNY = DayWindowHelper.getDayWindow(newYearEarly, 5, 0);

        expect(windowNYE.start, equals(DateTime(2026, 12, 31, 5, 0)));
        expect(windowNYE.end, equals(DateTime(2027, 1, 1, 5, 0)));

        expect(windowNY.start, equals(windowNYE.start));
        expect(windowNY.end, equals(windowNYE.end));
        expect(DayWindowHelper.isWithinDayWindow(newYearEarly, nyeLate, 5, 0), isTrue);
      });
    });
  });
}
