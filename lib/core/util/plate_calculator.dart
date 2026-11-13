/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Behaviour ported from LibreFit's PlateCalculator.kt (commit 8db76211).
 */

import 'unit_system.dart';

/// The result of a barbell plate calculation.
///
/// [platesPerSideKg] maps a plate weight in kilograms to the number of plates
/// required per side, ordered from heaviest to lightest. [remainderKg] is the
/// leftover weight per side that no available plate could match, rounded to two
/// decimal digits; it is never negative. [closestAchievableKg] is the exact
/// total weight reachable with the calculated plates, derived from the
/// unrounded leftover so no compounding rounding error appears.
class PlateBreakdown {
  const PlateBreakdown({
    required this.platesPerSideKg,
    required this.remainderKg,
    required this.closestAchievableKg,
  });

  final Map<double, int> platesPerSideKg;
  final double remainderKg;
  final double closestAchievableKg;
}

/// Difference (in kilograms) considered a matched plate.
const double plateMatchToleranceKg = 0.01;

/// Tolerance used when counting how many plates fit in the remaining weight.
/// It absorbs floating point error from unit conversions without making a
/// plate fit when it genuinely does not.
const double plateCountEpsilon = 1e-4;

/// Standard competition-style metric plates, including fractional plates.
const List<double> _standardPlatesMetricKg = [
  25.0,
  20.0,
  15.0,
  10.0,
  5.0,
  2.5,
  1.25,
  0.5,
  0.25,
];

/// Standard imperial plates in pounds, including fractional plates.
const List<double> _standardPlatesImperialLb = [
  45.0,
  25.0,
  10.0,
  5.0,
  2.5,
  1.25,
];

/// Standard barbell weights in kilograms.
const List<double> _standardBarsMetricKg = [20.0, 15.0, 10.0, 5.0];

/// Standard barbell weights in pounds.
const List<double> _standardBarsImperialLb = [45.0, 35.0, 25.0];

/// Fractional "small" plate values in kilograms.
const List<double> _smallPlateValuesKg = [0.25, 0.5, 1.25];

/// Fractional "small" plate values in pounds.
const List<double> _smallPlateValuesLb = [1.25];

/// Standard plates for [system], always expressed in kilograms.
List<double> standardPlatesFor(UnitSystem system) {
  switch (system) {
    case UnitSystem.metric:
      return List<double>.unmodifiable(_standardPlatesMetricKg);
    case UnitSystem.imperial:
      return List<double>.unmodifiable(
        _standardPlatesImperialLb.map(
          (pounds) => toKilograms(pounds, UnitSystem.imperial),
        ),
      );
  }
}

/// Standard barbell weights for [system], always expressed in kilograms.
List<double> standardBarsFor(UnitSystem system) {
  switch (system) {
    case UnitSystem.metric:
      return List<double>.unmodifiable(_standardBarsMetricKg);
    case UnitSystem.imperial:
      return List<double>.unmodifiable(
        _standardBarsImperialLb.map(
          (pounds) => toKilograms(pounds, UnitSystem.imperial),
        ),
      );
  }
}

/// Calculates the plates required per side to reach [targetKg] with a bar of
/// weight [barKg], using a greedy largest-first strategy.
///
/// The per-side requirement is intentionally not rounded: pound values
/// converted to kilograms carry long decimal fractions, and rounding here
/// would make plates no longer fit. Only the outputs are rounded.
PlateBreakdown calculatePlates({
  required double targetKg,
  required double barKg,
  required List<double> availablePlatesKg,
}) {
  final double perSideRequired = (targetKg - barKg) / 2.0;

  if (perSideRequired <= 0.0) {
    return PlateBreakdown(
      platesPerSideKg: const <double, int>{},
      remainderKg: 0.0,
      closestAchievableKg: targetKg,
    );
  }

  double remaining = perSideRequired;
  final Map<double, int> platesPerSide = <double, int>{};
  final List<double> sortedPlates = List<double>.of(availablePlatesKg)
    ..sort((a, b) => b.compareTo(a));

  for (final double plateKg in sortedPlates) {
    if (!plateKg.isFinite || plateKg <= 0.0) continue;

    // Tolerant floor so floating point noise from unit conversion cannot drop
    // a plate that genuinely fits (e.g. floor(1.9999999 + 1e-4) == 2).
    final int count = (remaining / plateKg + plateCountEpsilon).floor();
    if (count > 0) {
      platesPerSide[plateKg] = count;
      remaining -= plateKg * count;
      if (remaining <= plateMatchToleranceKg / 10) break;
    }
  }

  // Clamp before rounding so the remainder can never surface as negative.
  final double remainder = _roundToTwoDecimals(
    remaining < 0.0 ? 0.0 : remaining,
  );

  // The achievable total derives from the unrounded leftover, keeping it
  // accurate when displayed in a different unit system than the calculation.
  final double closestAchievable = (perSideRequired - remaining) * 2.0 + barKg;

  return PlateBreakdown(
    platesPerSideKg: Map<double, int>.unmodifiable(platesPerSide),
    remainderKg: remainder + 0.0,
    closestAchievableKg: closestAchievable < 0.0 ? 0.0 : closestAchievable,
  );
}

/// Determines whether [plateKg] counts as a "small" (fractional) plate in
/// [system]: metric 0.25, 0.5 and 1.25 kg, imperial 1.25 lb.
bool isSmallPlate(double plateKg, UnitSystem system) {
  final double value = fromKilograms(plateKg, system);
  final List<double> smallValues = switch (system) {
    UnitSystem.metric => _smallPlateValuesKg,
    UnitSystem.imperial => _smallPlateValuesLb,
  };
  return smallValues.any((small) => (small - value).abs() < 1e-6);
}

/// Filters [platesKg], optionally excluding small (fractional) plates.
List<double> filterSmallPlates(
  List<double> platesKg, {
  required bool includeSmallPlates,
  required UnitSystem system,
}) {
  if (includeSmallPlates) return List<double>.unmodifiable(platesKg);
  return List<double>.unmodifiable(
    platesKg.where((plateKg) => !isSmallPlate(plateKg, system)),
  );
}

double _roundToTwoDecimals(double value) {
  const double multiplier = 100.0;
  return (value * multiplier).roundToDouble() / multiplier;
}
