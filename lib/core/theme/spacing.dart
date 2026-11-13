/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

/// Spacing tokens on the 8dp grid.
///
/// Feature code must use these values instead of ad-hoc literals so the
/// vertical rhythm stays consistent across screens.
abstract final class NexcSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double section = 48;

  /// Horizontal page padding on compact widths.
  static const double pageCompact = 16;

  /// Horizontal page padding from 600dp up.
  static const double pageMedium = 24;

  /// Minimum height of an interactive row.
  static const double touchTarget = 48;

  /// Width of the leading icon container used by list tiles.
  static const double iconContainer = 40;

  /// Largest readable content width for forms and settings.
  static const double readableWidth = 720;

  /// Largest content width for dashboards.
  static const double pageMaxWidth = 1200;
}
