/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

/// Locale-aware date/time and number formatting shared by every screen.
///
/// Dates go through [MaterialLocalizations] so no locale data needs to be
/// initialized manually and every language keeps its own ordering.
extension NexcFormatting on BuildContext {
  MaterialLocalizations get _localizations => MaterialLocalizations.of(this);

  /// Numeric date such as `10/1/2026`.
  String formatShortDate(DateTime date) => _localizations.formatShortDate(date);

  /// Medium date such as `Thu, Oct 1`.
  String formatMediumDate(DateTime date) =>
      _localizations.formatMediumDate(date);

  /// Month and year such as `October 2026`.
  String formatMonthYear(DateTime date) => _localizations.formatMonthYear(date);

  /// Time of day in the locale's clock convention.
  String formatTimeOfDay(TimeOfDay time) =>
      _localizations.formatTimeOfDay(time);

  /// Range of days such as `Oct 1 – Oct 7`.
  String formatDateRange(DateTime start, DateTime end) =>
      '${_localizations.formatShortMonthDay(start)} – '
      '${_localizations.formatShortMonthDay(end)}';
}

/// Trims trailing zeros so whole numbers stay short.
String formatDecimal(double value, {int maxDecimals = 2}) {
  final String text = value.toStringAsFixed(maxDecimals);
  if (!text.contains('.')) return text;
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

/// `01:35` — used by stopwatches and rest timers.
String formatClock(int totalSeconds) {
  final int safe = totalSeconds < 0 ? 0 : totalSeconds;
  final String minutes = (safe ~/ 60).toString().padLeft(2, '0');
  final String seconds = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// Human duration such as `1h 05m`, `12m` or `45s`.
String formatDurationShort(int totalSeconds) {
  if (totalSeconds <= 0) return '0m';
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  if (hours > 0) {
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
  if (minutes > 0) return '${minutes}m';
  return '${totalSeconds}s';
}

/// Turns `BODY_ONLY` into `Body Only` for labels without a translation key.
String humanizeEnumName(String raw) {
  return raw
      .split('_')
      .where((String part) => part.isNotEmpty)
      .map(
        (String part) =>
            part[0].toUpperCase() + part.substring(1).toLowerCase(),
      )
      .join(' ');
}

/// Thousands separator without pulling a locale-specific formatter.
String formatCount(int value) {
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}
