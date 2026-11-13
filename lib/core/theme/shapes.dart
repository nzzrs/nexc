/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

/// Shape tokens shared by every surface.
///
/// [childOf] keeps nested corners concentric: a child inside a padded parent
/// uses the parent radius minus the padding.
abstract final class NexcShapes {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;

  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(999));

  static const StadiumBorder stadium = StadiumBorder();

  /// Concentric radius for a child inside a [parent] radius with [padding].
  static BorderRadius childOf(double parent, double padding) {
    final double value = (parent - padding).clamp(0, parent);
    return BorderRadius.all(Radius.circular(value));
  }
}
