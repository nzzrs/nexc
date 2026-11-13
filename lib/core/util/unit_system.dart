/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark
 * usage; see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the
 * project root.
 */

import 'dart:ui' show Locale, PlatformDispatcher;

/// Unit system used for weight display and input.
///
/// Nexc stores every weight in kilograms. This enum only describes how values
/// are presented to and parsed from the user; it never changes the storage
/// format.
enum UnitSystem {
  metric('kg'),
  imperial('lb');

  const UnitSystem(this.suffix);

  /// Short unit symbol shown next to a weight.
  final String suffix;
}

/// Kilograms in one pound (international avoirdupois pound).
const double kilogramsPerPound = 0.45359237;

/// Converts a weight expressed in [system] to kilograms.
double toKilograms(double value, UnitSystem system) {
  switch (system) {
    case UnitSystem.metric:
      return value;
    case UnitSystem.imperial:
      return value * kilogramsPerPound;
  }
}

/// Converts a weight in kilograms to [system].
double fromKilograms(double kilograms, UnitSystem system) {
  switch (system) {
    case UnitSystem.metric:
      return kilograms;
    case UnitSystem.imperial:
      return kilograms / kilogramsPerPound;
  }
}

/// Formats a weight stored in kilograms for display in [system].
///
/// Trailing zeros are trimmed, at most [maxDecimals] decimals are kept, and
/// values rounding to zero are rendered as `0` instead of `-0`. When [suffix]
/// is non-empty it is appended after a single space; pass [UnitSystem.suffix]
/// to show the unit.
String formatWeight(
  double kilograms,
  UnitSystem system, {
  int maxDecimals = 2,
  String? suffix,
}) {
  final decimals = maxDecimals < 0 ? 0 : maxDecimals;
  var text = fromKilograms(kilograms, system).toStringAsFixed(decimals);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }
  if (text == '-0') {
    text = '0';
  }
  if (suffix != null && suffix.isNotEmpty) {
    return '$text $suffix';
  }
  return text;
}

/// Parses user input expressed in [system] and returns kilograms.
///
/// Surrounding whitespace is ignored, a comma is accepted as the decimal
/// separator, and empty, non-numeric, non-finite or negative input yields null.
double? parseWeight(String input, UnitSystem system) {
  final normalized = input.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  if (value == null || !value.isFinite || value < 0) return null;
  return toKilograms(value, system);
}

const Set<String> _imperialCountryCodes = {'US', 'LR', 'MM'};

/// Picks the default unit system for [locale].
///
/// Only the United States, Liberia and Myanmar default to imperial; every
/// other country uses metric.
UnitSystem resolveDefaultUnitSystem(Locale locale) {
  final countryCode = locale.countryCode?.toUpperCase();
  if (countryCode != null && _imperialCountryCodes.contains(countryCode)) {
    return UnitSystem.imperial;
  }
  return UnitSystem.metric;
}

/// Resolves the default unit system from the platform locale.
///
/// Uses `dart:ui`, so it works on every Flutter target including the web.
UnitSystem resolveDefaultUnitSystemFromPlatform() {
  return resolveDefaultUnitSystem(PlatformDispatcher.instance.locale);
}
