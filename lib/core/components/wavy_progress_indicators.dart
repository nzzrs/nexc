/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/spacing.dart';

/// Number of drawn segments for a wavy arc.
///
/// Always at least one segment for a positive value so the painter never
/// divides by zero, which used to produce `NaN` coordinates for values below
/// `1/120` (including the rest timer's first tick).
@visibleForTesting
int wavyActiveSegments(double value, {int segments = 120}) {
  final double clamped = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
  if (clamped <= 0) return 0;
  return (segments * clamped).round().clamp(1, segments);
}

/// Start and end angles for every drawn wavy arc segment.
///
/// Kept free of rendering code so a unit test can assert every angle stays
/// finite even for tiny progress values.
@visibleForTesting
List<double> wavyProgressAngles(double value, {int segments = 120}) {
  final double clamped = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
  final int active = wavyActiveSegments(clamped, segments: segments);
  if (active == 0) return const <double>[];
  const double startAngle = -math.pi / 2;
  final double progressAngle = 2 * math.pi * clamped;
  return <double>[
    for (int i = 0; i <= active; i++) startAngle + progressAngle * (i / active),
  ];
}

/// Animated wavy progress line.
///
/// The wave is decorative, so it only loops when motion is allowed. With
/// reduced motion the line renders a static phase, and it pauses whenever the
/// surrounding [TickerMode] is disabled (offstage tabs, covered routes).
class LinearWavyProgressIndicator extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final double waveHeight;
  final double waveLength;

  const LinearWavyProgressIndicator({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 4.0,
    this.waveHeight = 4.0,
    this.waveLength = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final double safeValue = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final Widget child = _LinearWavyProgressIndicatorInternal(
      value: safeValue,
      color: color,
      backgroundColor: backgroundColor,
      strokeWidth: strokeWidth,
      waveHeight: waveHeight,
      waveLength: waveLength,
      reduceMotion: reduceMotion,
    );
    if (reduceMotion) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: safeValue),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (BuildContext context, double animatedValue, Widget? _) {
        return _LinearWavyProgressIndicatorInternal(
          value: animatedValue,
          color: color,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
          waveHeight: waveHeight,
          waveLength: waveLength,
          reduceMotion: false,
        );
      },
    );
  }
}

class _LinearWavyProgressIndicatorInternal extends StatefulWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final double waveHeight;
  final double waveLength;
  final bool reduceMotion;

  const _LinearWavyProgressIndicatorInternal({
    required this.value,
    this.color,
    this.backgroundColor,
    required this.strokeWidth,
    required this.waveHeight,
    required this.waveLength,
    required this.reduceMotion,
  });

  @override
  State<_LinearWavyProgressIndicatorInternal> createState() =>
      _LinearWavyProgressIndicatorInternalState();
}

class _LinearWavyProgressIndicatorInternalState
    extends State<_LinearWavyProgressIndicatorInternal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant _LinearWavyProgressIndicatorInternal old) {
    super.didUpdateWidget(old);
    _syncTicker();
  }

  void _syncTicker() {
    final bool canAnimate =
        !widget.reduceMotion && TickerMode.of(context) && mounted;
    if (canAnimate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color activeColor = widget.color ?? theme.colorScheme.primary;
    final Color inactiveColor =
        widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final double height = math.max(12, widget.strokeWidth + widget.waveHeight);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _LinearWavyProgressPainter(
              value: widget.value,
              color: activeColor,
              backgroundColor: inactiveColor,
              strokeWidth: widget.strokeWidth,
              waveHeight: widget.waveHeight,
              waveLength: widget.waveLength,
              animationValue: widget.reduceMotion ? 0.0 : _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _LinearWavyProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double waveHeight;
  final double waveLength;
  final double animationValue;

  _LinearWavyProgressPainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.waveHeight,
    required this.waveLength,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final double length = waveLength <= 0 ? 1 : waveLength;
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double midY = size.height / 2;
    final double width = size.width;
    final double phase = animationValue * 2 * math.pi;
    final double startX = strokeWidth / 2;
    final double endX = math.max(startX, width - strokeWidth / 2);

    double waveY(double x) =>
        midY + math.sin(x / length * 2 * math.pi - phase) * waveHeight;

    final Path backgroundPath = Path()..moveTo(startX, waveY(startX));
    for (double x = startX; x <= endX; x += 1.5) {
      backgroundPath.lineTo(x, waveY(x));
    }
    canvas.drawPath(backgroundPath, backgroundPaint);

    if (value <= 0) return;

    final Path progressPath = Path()..moveTo(startX, waveY(startX));
    final double progressWidth = (startX + (endX - startX) * value).clamp(
      startX,
      endX,
    );
    for (double x = startX; x <= progressWidth; x += 1.5) {
      progressPath.lineTo(x, waveY(x));
    }
    progressPath.lineTo(progressWidth, waveY(progressWidth));
    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _LinearWavyProgressPainter old) {
    return old.value != value ||
        old.color != color ||
        old.backgroundColor != backgroundColor ||
        old.strokeWidth != strokeWidth ||
        old.waveHeight != waveHeight ||
        old.waveLength != waveLength ||
        old.animationValue != animationValue;
  }
}

/// Animated wavy progress ring.
class CircularWavyProgressIndicator extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final double waveHeight;
  final int waveCount;

  const CircularWavyProgressIndicator({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 4.0,
    this.waveHeight = 3.0,
    this.waveCount = 16,
  });

  @override
  Widget build(BuildContext context) {
    final double safeValue = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final Widget child = _CircularWavyProgressIndicatorInternal(
      value: safeValue,
      color: color,
      backgroundColor: backgroundColor,
      strokeWidth: strokeWidth,
      waveHeight: waveHeight,
      waveCount: waveCount,
      reduceMotion: reduceMotion,
    );
    if (reduceMotion) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: safeValue),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.linear,
      builder: (BuildContext context, double animatedValue, Widget? _) {
        return _CircularWavyProgressIndicatorInternal(
          value: animatedValue,
          color: color,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
          waveHeight: waveHeight,
          waveCount: waveCount,
          reduceMotion: false,
        );
      },
    );
  }
}

class _CircularWavyProgressIndicatorInternal extends StatefulWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final double waveHeight;
  final int waveCount;
  final bool reduceMotion;

  const _CircularWavyProgressIndicatorInternal({
    required this.value,
    this.color,
    this.backgroundColor,
    required this.strokeWidth,
    required this.waveHeight,
    required this.waveCount,
    required this.reduceMotion,
  });

  @override
  State<_CircularWavyProgressIndicatorInternal> createState() =>
      _CircularWavyProgressIndicatorInternalState();
}

class _CircularWavyProgressIndicatorInternalState
    extends State<_CircularWavyProgressIndicatorInternal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant _CircularWavyProgressIndicatorInternal old) {
    super.didUpdateWidget(old);
    _syncTicker();
  }

  void _syncTicker() {
    final bool canAnimate =
        !widget.reduceMotion && TickerMode.of(context) && mounted;
    if (canAnimate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color activeColor = widget.color ?? theme.colorScheme.primary;
    final Color inactiveColor =
        widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : NexcSpacing.touchTarget;
        final double height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : NexcSpacing.touchTarget;
        final double side = math.max(
          0,
          math.min(width, height) - widget.strokeWidth,
        );
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              size: Size.square(side),
              painter: _CircularWavyProgressPainter(
                value: widget.value,
                color: activeColor,
                backgroundColor: inactiveColor,
                strokeWidth: widget.strokeWidth,
                waveHeight: widget.waveHeight,
                waveCount: widget.waveCount,
                animationValue: widget.reduceMotion ? 0.0 : _controller.value,
              ),
            );
          },
        );
      },
    );
  }
}

class _CircularWavyProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double waveHeight;
  final int waveCount;
  final double animationValue;

  _CircularWavyProgressPainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.waveHeight,
    required this.waveCount,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = math.max(
      0,
      math.min(size.width, size.height) / 2 - strokeWidth,
    );
    if (radius <= 0) return;
    final Offset center = size.center(Offset.zero);

    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final double phase = animationValue * 2 * math.pi;
    final int points = waveCount.abs().clamp(1, 64);

    final Path backgroundPath = Path();
    for (int i = 0; i <= 360; i += 2) {
      final double angle = (i * math.pi) / 180.0;
      final double currentRadius =
          radius + math.sin(angle * points + phase) * waveHeight;
      final double x = center.dx + math.cos(angle) * currentRadius;
      final double y = center.dy + math.sin(angle) * currentRadius;
      if (i == 0) {
        backgroundPath.moveTo(x, y);
      } else {
        backgroundPath.lineTo(x, y);
      }
    }
    backgroundPath.close();
    canvas.drawPath(backgroundPath, backgroundPaint);

    if (value <= 0) return;

    final List<double> angles = wavyProgressAngles(value);
    if (angles.isEmpty) return;
    final Path progressPath = Path();
    for (int i = 0; i < angles.length; i++) {
      final double angle = angles[i];
      final double currentRadius =
          radius + math.sin(angle * points + phase) * waveHeight;
      final double x = center.dx + math.cos(angle) * currentRadius;
      final double y = center.dy + math.sin(angle) * currentRadius;
      if (i == 0) {
        progressPath.moveTo(x, y);
      } else {
        progressPath.lineTo(x, y);
      }
    }
    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularWavyProgressPainter old) {
    return old.value != value ||
        old.color != color ||
        old.backgroundColor != backgroundColor ||
        old.strokeWidth != strokeWidth ||
        old.waveHeight != waveHeight ||
        old.waveCount != waveCount ||
        old.animationValue != animationValue;
  }
}
