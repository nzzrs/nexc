import 'dart:math' as math;
import 'package:flutter/material.dart';

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
    // Smoothly animate value changes to prevent glitchy jumps
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        return _LinearWavyProgressIndicatorInternal(
          value: animatedValue,
          color: color,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
          waveHeight: waveHeight,
          waveLength: waveLength,
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

  const _LinearWavyProgressIndicatorInternal({
    required this.value,
    this.color,
    this.backgroundColor,
    required this.strokeWidth,
    required this.waveHeight,
    required this.waveLength,
  });

  @override
  State<_LinearWavyProgressIndicatorInternal> createState() =>
      _LinearWavyProgressIndicatorInternalState();
}

class _LinearWavyProgressIndicatorInternalState
    extends State<_LinearWavyProgressIndicatorInternal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.color ?? theme.colorScheme.primary;
    final inactiveColor = widget.backgroundColor ?? theme.colorScheme.surfaceVariant;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 12),
          painter: _LinearWavyProgressPainter(
            value: widget.value,
            color: activeColor,
            backgroundColor: inactiveColor,
            strokeWidth: widget.strokeWidth,
            waveHeight: widget.waveHeight,
            waveLength: widget.waveLength,
            animationValue: _controller.value,
          ),
        );
      },
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
    final paintBg = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintProgress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double midY = size.height / 2;
    final double width = size.width;
    final double phase = animationValue * 2 * math.pi;

    // Draw background as a wavy line
    final bgPath = Path();
    final double startX = strokeWidth / 2;
    final double endX = width - strokeWidth / 2;
    bgPath.moveTo(startX, midY + math.sin(startX / waveLength * 2 * math.pi - phase) * waveHeight);
    for (double x = startX; x <= endX; x += 1.5) {
      final double relativeX = x / waveLength;
      final double y = midY + math.sin(relativeX * 2 * math.pi - phase) * waveHeight;
      bgPath.lineTo(x, y);
    }
    canvas.drawPath(bgPath, paintBg);

    if (value <= 0.0) return;

    // Draw progress as a wave overlaying the background wave exactly
    final progressPath = Path();
    final double progressWidth = (width - strokeWidth) * value + (strokeWidth / 2);

    progressPath.moveTo(startX, midY + math.sin(startX / waveLength * 2 * math.pi - phase) * waveHeight);
    for (double x = startX; x <= progressWidth; x += 1.5) {
      final double relativeX = x / waveLength;
      final double y = midY + math.sin(relativeX * 2 * math.pi - phase) * waveHeight;
      progressPath.lineTo(x, y);
    }

    canvas.drawPath(progressPath, paintProgress);
  }

  @override
  bool shouldRepaint(covariant _LinearWavyProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.animationValue != animationValue;
  }
}

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
    this.waveCount = 16, // Star/flower shape with 16 points
  });

  @override
  Widget build(BuildContext context) {
    // Smoothly animate value changes to prevent glitchy jumps
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.linear,
      builder: (context, animatedValue, child) {
        return _CircularWavyProgressIndicatorInternal(
          value: animatedValue,
          color: color,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
          waveHeight: waveHeight,
          waveCount: waveCount,
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

  const _CircularWavyProgressIndicatorInternal({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    required this.strokeWidth,
    required this.waveHeight,
    required this.waveCount,
  });

  @override
  State<_CircularWavyProgressIndicatorInternal> createState() =>
      _CircularWavyProgressIndicatorInternalState();
}

class _CircularWavyProgressIndicatorInternalState
    extends State<_CircularWavyProgressIndicatorInternal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.color ?? theme.colorScheme.primary;
    final inactiveColor = widget.backgroundColor ?? theme.colorScheme.surfaceVariant;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;
            final double sizeVal = (width.isInfinite || height.isInfinite)
                ? 48.0
                : math.min(width, height);
            return CustomPaint(
              size: Size(sizeVal, sizeVal),
              painter: _CircularWavyProgressPainter(
                value: widget.value,
                color: activeColor,
                backgroundColor: inactiveColor,
                strokeWidth: widget.strokeWidth,
                waveHeight: widget.waveHeight,
                waveCount: widget.waveCount,
                animationValue: _controller.value,
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
    final double radius = math.min(size.width, size.height) / 2 - strokeWidth;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final paintBg = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintProgress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final double phase = animationValue * 2 * math.pi;

    // Draw background 12-pointed rounded star/flower shape
    final bgPath = Path();
    for (int i = 0; i <= 360; i += 2) {
      final double angle = (i * math.pi) / 180.0;
      // Oscillate radius with angle to form a star shape, moving with phase to align with progress
      final double currentRadius = radius + math.sin(angle * waveCount + phase) * waveHeight;
      final double x = center.dx + math.cos(angle) * currentRadius;
      final double y = center.dy + math.sin(angle) * currentRadius;
      if (i == 0) {
        bgPath.moveTo(x, y);
      } else {
        bgPath.lineTo(x, y);
      }
    }
    bgPath.close();
    canvas.drawPath(bgPath, paintBg);

    if (value <= 0.0) return;

    // Draw progress path following the same star shape
    final progressPath = Path();
    const double startAngle = -math.pi / 2;
    final double progressAngle = 2 * math.pi * value;

    final double firstX = center.dx + math.cos(startAngle) * (radius + math.sin(startAngle * waveCount + phase) * waveHeight);
    final double firstY = center.dy + math.sin(startAngle) * (radius + math.sin(startAngle * waveCount + phase) * waveHeight);
    progressPath.moveTo(firstX, firstY);

    const int segments = 120;
    final int activeSegments = (segments * value).round();

    for (int i = 0; i <= activeSegments; i++) {
      final double angle = startAngle + (progressAngle * (i / activeSegments));
      final double currentRadius = radius + math.sin(angle * waveCount + phase) * waveHeight;
      final double x = center.dx + math.cos(angle) * currentRadius;
      final double y = center.dy + math.sin(angle) * currentRadius;
      progressPath.lineTo(x, y);
    }

    canvas.drawPath(progressPath, paintProgress);
  }

  @override
  bool shouldRepaint(covariant _CircularWavyProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.animationValue != animationValue;
  }
}
