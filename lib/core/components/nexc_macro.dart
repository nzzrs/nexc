/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../util/format.dart';

/// Macro palette derived from the active color scheme.
abstract final class NexcMacroColors {
  static Color protein(ColorScheme scheme) => scheme.primary;
  static Color carbs(ColorScheme scheme) => scheme.tertiary;
  static Color fats(ColorScheme scheme) => scheme.secondary;
}

/// Three concentric rings showing protein, carbs and fat progress.
///
/// Values are clamped visually while the numeric centre keeps the real value.
class NexcMacroRing extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fats;
  final double? targetProtein;
  final double? targetCarbs;
  final double? targetFats;
  final double size;
  final Widget? center;

  const NexcMacroRing({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.targetProtein,
    this.targetCarbs,
    this.targetFats,
    this.size = 132,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<double> progress = <double>[
      _ratio(protein, targetProtein),
      _ratio(carbs, targetCarbs),
      _ratio(fats, targetFats),
    ];
    final List<Color> colors = <Color>[
      NexcMacroColors.protein(scheme),
      NexcMacroColors.carbs(scheme),
      NexcMacroColors.fats(scheme),
    ];

    return Semantics(
      label:
          'Protein ${formatDecimal(protein)}g, '
          'carbs ${formatDecimal(carbs)}g, '
          'fats ${formatDecimal(fats)}g',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: progress,
            colors: colors,
            trackColor: scheme.surfaceContainerHighest,
            stroke: size * 0.075,
            gap: size * 0.035,
          ),
          child: Center(child: center),
        ),
      ),
    );
  }

  static double _ratio(double value, double? target) {
    if (target == null || target <= 0) return 0;
    return (value / target).clamp(0.0, 1.0);
  }
}

class _RingPainter extends CustomPainter {
  final List<double> progress;
  final List<Color> colors;
  final Color trackColor;
  final double stroke;
  final double gap;

  _RingPainter({
    required this.progress,
    required this.colors,
    required this.trackColor,
    required this.stroke,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double maxRadius = math.min(size.width, size.height) / 2 - stroke / 2;
    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < progress.length; i++) {
      final double radius = maxRadius - i * (stroke + gap);
      if (radius <= 0) break;
      canvas.drawCircle(center, radius, track);
      if (progress[i] <= 0) continue;
      final Paint arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors[i]
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress[i],
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.progress != progress ||
        old.colors != colors ||
        old.trackColor != trackColor ||
        old.stroke != stroke ||
        old.gap != gap;
  }
}

/// Horizontal macro progress row with label, amount and target.
class NexcMacroBar extends StatelessWidget {
  final String label;
  final double value;
  final double? target;
  final Color color;
  final String? unit;

  const NexcMacroBar({
    super.key,
    required this.label,
    required this.value,
    this.target,
    required this.color,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double ratio = (target != null && target! > 0)
        ? (value / target!).clamp(0.0, 1.0)
        : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NexcSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: NexcSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                target == null
                    ? '${formatDecimal(value)}$unit'
                    : '${formatDecimal(value)} / ${formatDecimal(target!)}$unit',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: NexcSpacing.xs),
          ClipRRect(
            borderRadius: NexcShapes.fullRadius,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact `P 12g · C 30g · F 8g` chips row.
class NexcMacroChips extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fats;
  final bool showCalories;
  final double? calories;

  const NexcMacroChips({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.showCalories = false,
    this.calories,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<({String label, double value, Color color})> macros = [
      (label: 'P', value: protein, color: NexcMacroColors.protein(scheme)),
      (label: 'C', value: carbs, color: NexcMacroColors.carbs(scheme)),
      (label: 'F', value: fats, color: NexcMacroColors.fats(scheme)),
    ];

    return Wrap(
      spacing: NexcSpacing.sm,
      runSpacing: NexcSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final ({String label, double value, Color color}) macro in macros)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: macro.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: NexcSpacing.xs),
              Text(
                '${macro.label} ${formatDecimal(macro.value)}g',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        if (showCalories && calories != null)
          Text(
            '${formatDecimal(calories!)} kcal',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
      ],
    );
  }
}
