/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart' show DateTimeRange;
import '../db/app_database.dart' show LocalTime;

class DayWindowHelper {
  /// Returns the 24-hour [DateTimeRange] corresponding to the active day window for [now],
  /// where each day resets at [startHour]:[startMinute].
  ///
  /// If [now] is before the reset time on that calendar day, the window began yesterday
  /// at [startHour]:[startMinute] and ends today at [startHour]:[startMinute].
  /// Otherwise, it began today at [startHour]:[startMinute] and ends tomorrow at [startHour]:[startMinute].
  static DateTimeRange getDayWindow(DateTime now, int startHour, int startMinute) {
    final resetToday = DateTime(now.year, now.month, now.day, startHour, startMinute);
    DateTime start;
    if (now.isBefore(resetToday)) {
      start = resetToday.subtract(const Duration(days: 1));
    } else {
      start = resetToday;
    }
    final end = start.add(const Duration(days: 1));
    return DateTimeRange(start: start, end: end);
  }

  /// Checks if [timestamp] falls within the day window defined for [now].
  ///
  /// The interval is half-open: `[window.start, window.end)`.
  static bool isWithinDayWindow(DateTime timestamp, DateTime now, int startHour, int startMinute) {
    final window = getDayWindow(now, startHour, startMinute);
    return (timestamp.isAtSameMomentAs(window.start) || timestamp.isAfter(window.start)) &&
        timestamp.isBefore(window.end);
  }

  /// Calculates elapsed minutes from the day reset ([startHour]:[startMinute]) to [time].
  ///
  /// Wraps around midnight such that times between midnight and the reset time
  /// are treated as occurring later in the same day window (e.g. at 5 AM reset,
  /// 2 AM is 21 hours = 1260 minutes from day start, while 8 AM is 3 hours = 180 minutes).
  static int getMinutesFromDayStart(LocalTime time, int startHour, int startMinute) {
    final totalMinutes = time.hour * 60 + time.minute;
    final resetMinutes = startHour * 60 + startMinute;
    int diff = totalMinutes - resetMinutes;
    if (diff < 0) {
      diff += 24 * 60;
    }
    return diff;
  }
}

// Top-level contract aliases
DateTimeRange getDayWindow(DateTime now, int startHour, int startMinute) =>
    DayWindowHelper.getDayWindow(now, startHour, startMinute);

bool isWithinDayWindow(DateTime timestamp, DateTime now, int startHour, int startMinute) =>
    DayWindowHelper.isWithinDayWindow(timestamp, now, startHour, startMinute);

int getMinutesFromDayStart(LocalTime time, int startHour, int startMinute) =>
    DayWindowHelper.getMinutesFromDayStart(time, startHour, startMinute);
