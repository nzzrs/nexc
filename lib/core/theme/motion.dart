/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

/// Motion tokens aligned with the Material 3 transition spec.
///
/// Expressive spring APIs are not exposed by the Flutter stable channel yet,
/// so components use these emphasized curves and durations, and every loop
/// animation must be disabled when [respectsReducedMotion] reports true.
abstract final class NexcMotion {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 400);

  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);

  static const Curve enterCurve = emphasizedDecelerate;
  static const Curve exitCurve = emphasizedAccelerate;

  /// Whether the platform asks for reduced motion.
  static bool respectsReducedMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }
}
