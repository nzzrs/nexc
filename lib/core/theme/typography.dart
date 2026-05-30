/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';

const fontVariationsRegular = [
  FontVariation('wght', 200),
  FontVariation('wdth', 125),
  FontVariation('GRAD', 200),
];

const fontVariationsEmphasized = [
  FontVariation('wght', 400),
  FontVariation('wdth', 125),
  FontVariation('GRAD', 200),
  FontVariation('XOPQ', 96),
  FontVariation('XTRA', 500),
  FontVariation('YOPQ', 79),
  FontVariation('YTAS', 750),
  FontVariation('YTDE', -203),
  FontVariation('YTFI', 738),
  FontVariation('YTLC', 514),
  FontVariation('YTUC', 712),
];

const fontVariationsDisplay = [
  FontVariation('wght', 600),
  FontVariation('wdth', 125),
  FontVariation('GRAD', 200),
];

const fontVariationsDisplayEmphasized = [
  FontVariation('wght', 800),
  FontVariation('wdth', 125),
  FontVariation('GRAD', 400),
  FontVariation('XOPQ', 100),
  FontVariation('XTRA', 550),
  FontVariation('YOPQ', 80),
  FontVariation('YTAS', 750),
  FontVariation('YTDE', -200),
  FontVariation('YTFI', 700),
  FontVariation('YTLC', 550),
  FontVariation('YTUC', 712),
];

// Helper to create TextStyle
TextStyle _createStyle({
  required double fontSize,
  required double lineHeight,
  required List<FontVariation> variations,
  double letterSpacing = 0.0,
}) {
  return TextStyle(
    fontFamily: 'RobotoFlex',
    fontSize: fontSize,
    height: lineHeight,
    letterSpacing: letterSpacing,
    fontVariations: variations,
  );
}

// TextTheme matching Compose Baseline M3 sizes
final nexcTextTheme = TextTheme(
  displayLarge: _createStyle(fontSize: 57, lineHeight: 1.12, variations: fontVariationsDisplay),
  displayMedium: _createStyle(fontSize: 45, lineHeight: 1.16, variations: fontVariationsDisplay),
  displaySmall: _createStyle(fontSize: 36, lineHeight: 1.22, variations: fontVariationsDisplay),
  headlineLarge: _createStyle(fontSize: 32, lineHeight: 1.25, variations: fontVariationsDisplay),
  headlineMedium: _createStyle(fontSize: 28, lineHeight: 1.29, variations: fontVariationsDisplay),
  headlineSmall: _createStyle(fontSize: 24, lineHeight: 1.33, variations: fontVariationsDisplay),
  titleLarge: _createStyle(fontSize: 22, lineHeight: 1.27, variations: fontVariationsDisplay),
  titleMedium: _createStyle(fontSize: 16, lineHeight: 1.5, variations: fontVariationsDisplay, letterSpacing: 0.15),
  titleSmall: _createStyle(fontSize: 14, lineHeight: 1.43, variations: fontVariationsDisplay, letterSpacing: 0.1),
  bodyLarge: _createStyle(fontSize: 16, lineHeight: 1.5, variations: fontVariationsRegular, letterSpacing: 0.5),
  bodyMedium: _createStyle(fontSize: 14, lineHeight: 1.43, variations: fontVariationsRegular, letterSpacing: 0.25),
  bodySmall: _createStyle(fontSize: 12, lineHeight: 1.33, variations: fontVariationsRegular, letterSpacing: 0.4),
  labelLarge: _createStyle(fontSize: 14, lineHeight: 1.43, variations: fontVariationsRegular, letterSpacing: 0.1),
  labelMedium: _createStyle(fontSize: 12, lineHeight: 1.33, variations: fontVariationsRegular, letterSpacing: 0.5),
  labelSmall: _createStyle(fontSize: 11, lineHeight: 1.45, variations: fontVariationsRegular, letterSpacing: 0.5),
);

// Extensions for Emphasized styles
extension EmphasizedTextTheme on TextTheme {
  TextStyle get displayLargeEmphasized => _createStyle(fontSize: 57, lineHeight: 1.12, variations: fontVariationsDisplayEmphasized);
  TextStyle get displayMediumEmphasized => _createStyle(fontSize: 45, lineHeight: 1.16, variations: fontVariationsDisplayEmphasized);
  TextStyle get displaySmallEmphasized => _createStyle(fontSize: 36, lineHeight: 1.22, variations: fontVariationsDisplayEmphasized);
  TextStyle get headlineLargeEmphasized => _createStyle(fontSize: 32, lineHeight: 1.25, variations: fontVariationsDisplayEmphasized);
  TextStyle get headlineMediumEmphasized => _createStyle(fontSize: 28, lineHeight: 1.29, variations: fontVariationsDisplayEmphasized);
  TextStyle get headlineSmallEmphasized => _createStyle(fontSize: 24, lineHeight: 1.33, variations: fontVariationsDisplayEmphasized);
  TextStyle get titleLargeEmphasized => _createStyle(fontSize: 22, lineHeight: 1.27, variations: fontVariationsDisplayEmphasized);
  TextStyle get titleMediumEmphasized => _createStyle(fontSize: 16, lineHeight: 1.5, variations: fontVariationsDisplayEmphasized, letterSpacing: 0.15);
  TextStyle get titleSmallEmphasized => _createStyle(fontSize: 14, lineHeight: 1.43, variations: fontVariationsDisplayEmphasized, letterSpacing: 0.1);
  TextStyle get bodyLargeEmphasized => _createStyle(fontSize: 16, lineHeight: 1.5, variations: fontVariationsEmphasized, letterSpacing: 0.5);
  TextStyle get bodyMediumEmphasized => _createStyle(fontSize: 14, lineHeight: 1.43, variations: fontVariationsEmphasized, letterSpacing: 0.25);
  TextStyle get bodySmallEmphasized => _createStyle(fontSize: 12, lineHeight: 1.33, variations: fontVariationsEmphasized, letterSpacing: 0.4);
  TextStyle get labelLargeEmphasized => _createStyle(fontSize: 14, lineHeight: 1.43, variations: fontVariationsEmphasized, letterSpacing: 0.1);
  TextStyle get labelMediumEmphasized => _createStyle(fontSize: 12, lineHeight: 1.33, variations: fontVariationsEmphasized, letterSpacing: 0.5);
  TextStyle get labelSmallEmphasized => _createStyle(fontSize: 11, lineHeight: 1.45, variations: fontVariationsEmphasized, letterSpacing: 0.5);
}
