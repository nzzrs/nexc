/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import '../db/enums.dart';

class BodyHeatmap extends StatelessWidget {
  final Map<Muscle, double> intensities; // values 0.0 to 1.0

  const BodyHeatmap({
    super.key,
    required this.intensities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = width * 0.7; // Aspect ratio

        return Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Front View",
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: CustomPaint(
                        painter: BodyOutlinePainter(
                          intensities: intensities,
                          isFront: true,
                          theme: theme,
                          isDark: isDark,
                        ),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
              VerticalDivider(
                width: 1,
                color: theme.colorScheme.outlineVariant,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Back View",
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: CustomPaint(
                        painter: BodyOutlinePainter(
                          intensities: intensities,
                          isFront: false,
                          theme: theme,
                          isDark: isDark,
                        ),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BodyOutlinePainter extends CustomPainter {
  final Map<Muscle, double> intensities;
  final bool isFront;
  final ThemeData theme;
  final bool isDark;

  BodyOutlinePainter({
    required this.intensities,
    required this.isFront,
    required this.theme,
    required this.isDark,
  });

  Color _getHeatColor(Muscle muscle) {
    final intensity = intensities[muscle] ?? 0.0;
    if (intensity == 0.0) {
      return isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);
    }
    // Color scale: Primary color at different opacities or HSL gradient
    return Color.lerp(
      theme.colorScheme.primary.withOpacity(0.2),
      theme.colorScheme.primary,
      intensity,
    )!;
  }

  Color _getOutlineColor() {
    return isDark ? Colors.white24 : Colors.black26;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final outlinePaint = Paint()
      ..color = _getOutlineColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    // Standard coordinate box of 100 x 200
    final double scaleX = size.width / 100;
    final double scaleY = size.height / 200;

    Path scalePath(Path path) {
      return path.transform(Matrix4.identity()
          .scaled(scaleX, scaleY)
          .storage);
    }

    if (isFront) {
      // Draw Head outline (aesthetic only)
      final head = scalePath(Path()
        ..addOval(const Rect.fromLTWH(42, 10, 16, 20)));
      canvas.drawPath(head, Paint()..color = _getOutlineColor().withOpacity(0.1));
      canvas.drawPath(head, outlinePaint);

      // Neck (Front)
      final neck = scalePath(Path()
        ..moveTo(45, 30)
        ..lineTo(55, 30)
        ..lineTo(54, 40)
        ..lineTo(46, 40)
        ..close());
      _drawMuscle(canvas, neck, Muscle.NECK, paint, outlinePaint);

      // Chest
      final leftChest = scalePath(Path()
        ..moveTo(30, 48)
        ..quadraticBezierTo(40, 45, 49, 48)
        ..lineTo(49, 65)
        ..quadraticBezierTo(38, 68, 30, 65)
        ..close());
      _drawMuscle(canvas, leftChest, Muscle.CHEST, paint, outlinePaint);

      final rightChest = scalePath(Path()
        ..moveTo(51, 48)
        ..quadraticBezierTo(60, 45, 70, 48)
        ..lineTo(70, 65)
        ..quadraticBezierTo(62, 68, 51, 65)
        ..close());
      _drawMuscle(canvas, rightChest, Muscle.CHEST, paint, outlinePaint);

      // Abdominals
      final abs = scalePath(Path()
        ..moveTo(35, 68)
        ..lineTo(65, 68)
        ..lineTo(61, 105)
        ..lineTo(39, 105)
        ..close());
      _drawMuscle(canvas, abs, Muscle.ABDOMINALS, paint, outlinePaint);

      // Shoulders (Front)
      final leftShoulder = scalePath(Path()
        ..moveTo(28, 48)
        ..quadraticBezierTo(22, 53, 25, 62)
        ..lineTo(30, 65)
        ..close());
      _drawMuscle(canvas, leftShoulder, Muscle.SHOULDERS, paint, outlinePaint);

      final rightShoulder = scalePath(Path()
        ..moveTo(72, 48)
        ..quadraticBezierTo(78, 53, 75, 62)
        ..lineTo(70, 65)
        ..close());
      _drawMuscle(canvas, rightShoulder, Muscle.SHOULDERS, paint, outlinePaint);

      // Biceps
      final leftBicep = scalePath(Path()
        ..moveTo(24, 64)
        ..lineTo(18, 90)
        ..lineTo(26, 92)
        ..lineTo(29, 66)
        ..close());
      _drawMuscle(canvas, leftBicep, Muscle.BICEPS, paint, outlinePaint);

      final rightBicep = scalePath(Path()
        ..moveTo(76, 64)
        ..lineTo(82, 90)
        ..lineTo(74, 92)
        ..lineTo(71, 66)
        ..close());
      _drawMuscle(canvas, rightBicep, Muscle.BICEPS, paint, outlinePaint);

      // Forearms (Front)
      final leftForearm = scalePath(Path()
        ..moveTo(18, 92)
        ..lineTo(12, 128)
        ..lineTo(19, 128)
        ..lineTo(26, 94)
        ..close());
      _drawMuscle(canvas, leftForearm, Muscle.FOREARMS, paint, outlinePaint);

      final rightForearm = scalePath(Path()
        ..moveTo(82, 92)
        ..lineTo(88, 128)
        ..lineTo(81, 128)
        ..lineTo(74, 94)
        ..close());
      _drawMuscle(canvas, rightForearm, Muscle.FOREARMS, paint, outlinePaint);

      // Quadriceps
      final leftQuad = scalePath(Path()
        ..moveTo(33, 112)
        ..lineTo(48, 112)
        ..lineTo(45, 155)
        ..lineTo(30, 155)
        ..close());
      _drawMuscle(canvas, leftQuad, Muscle.QUADRICEPS, paint, outlinePaint);

      final rightQuad = scalePath(Path()
        ..moveTo(52, 112)
        ..lineTo(67, 112)
        ..lineTo(70, 155)
        ..lineTo(55, 155)
        ..close());
      _drawMuscle(canvas, rightQuad, Muscle.QUADRICEPS, paint, outlinePaint);

      // Adductors
      final leftAdductor = scalePath(Path()
        ..moveTo(48, 113)
        ..lineTo(50, 113)
        ..lineTo(48, 140)
        ..lineTo(46, 140)
        ..close());
      _drawMuscle(canvas, leftAdductor, Muscle.ADDUCTORS, paint, outlinePaint);

      final rightAdductor = scalePath(Path()
        ..moveTo(52, 113)
        ..lineTo(50, 113)
        ..lineTo(52, 140)
        ..lineTo(54, 140)
        ..close());
      _drawMuscle(canvas, rightAdductor, Muscle.ADDUCTORS, paint, outlinePaint);

      // Abductors (Front view hip area representation)
      final leftAbductor = scalePath(Path()
        ..moveTo(30, 107)
        ..lineTo(33, 112)
        ..lineTo(30, 130)
        ..lineTo(28, 120)
        ..close());
      _drawMuscle(canvas, leftAbductor, Muscle.ABDUCTORS, paint, outlinePaint);

      final rightAbductor = scalePath(Path()
        ..moveTo(70, 107)
        ..lineTo(67, 112)
        ..lineTo(70, 130)
        ..lineTo(72, 120)
        ..close());
      _drawMuscle(canvas, rightAbductor, Muscle.ABDUCTORS, paint, outlinePaint);

    } else {
      // Draw Head outline (aesthetic only)
      final head = scalePath(Path()
        ..addOval(const Rect.fromLTWH(42, 10, 16, 20)));
      canvas.drawPath(head, Paint()..color = _getOutlineColor().withOpacity(0.1));
      canvas.drawPath(head, outlinePaint);

      // Neck (Back)
      final neck = scalePath(Path()
        ..moveTo(45, 30)
        ..lineTo(55, 30)
        ..lineTo(54, 40)
        ..lineTo(46, 40)
        ..close());
      _drawMuscle(canvas, neck, Muscle.NECK, paint, outlinePaint);

      // Traps
      final traps = scalePath(Path()
        ..moveTo(50, 36)
        ..lineTo(38, 48)
        ..lineTo(50, 68)
        ..lineTo(62, 48)
        ..close());
      _drawMuscle(canvas, traps, Muscle.TRAPS, paint, outlinePaint);

      // Shoulders (Rear)
      final leftShoulder = scalePath(Path()
        ..moveTo(37, 48)
        ..quadraticBezierTo(22, 53, 25, 62)
        ..lineTo(32, 65)
        ..close());
      _drawMuscle(canvas, leftShoulder, Muscle.SHOULDERS, paint, outlinePaint);

      final rightShoulder = scalePath(Path()
        ..moveTo(63, 48)
        ..quadraticBezierTo(78, 53, 75, 62)
        ..lineTo(68, 65)
        ..close());
      _drawMuscle(canvas, rightShoulder, Muscle.SHOULDERS, paint, outlinePaint);

      // Lats
      final leftLat = scalePath(Path()
        ..moveTo(32, 66)
        ..lineTo(48, 69)
        ..lineTo(46, 92)
        ..lineTo(36, 90)
        ..close());
      _drawMuscle(canvas, leftLat, Muscle.LATS, paint, outlinePaint);

      final rightLat = scalePath(Path()
        ..moveTo(68, 66)
        ..lineTo(52, 69)
        ..lineTo(54, 92)
        ..lineTo(64, 90)
        ..close());
      _drawMuscle(canvas, rightLat, Muscle.LATS, paint, outlinePaint);

      // Middle Back
      final middleBack = scalePath(Path()
        ..moveTo(48, 69)
        ..lineTo(52, 69)
        ..lineTo(52, 90)
        ..lineTo(48, 90)
        ..close());
      _drawMuscle(canvas, middleBack, Muscle.MIDDLE_BACK, paint, outlinePaint);

      // Lower Back
      final lowerBack = scalePath(Path()
        ..moveTo(38, 92)
        ..lineTo(62, 92)
        ..lineTo(59, 105)
        ..lineTo(41, 105)
        ..close());
      _drawMuscle(canvas, lowerBack, Muscle.LOWER_BACK, paint, outlinePaint);

      // Triceps
      final leftTricep = scalePath(Path()
        ..moveTo(24, 64)
        ..lineTo(18, 90)
        ..lineTo(26, 92)
        ..lineTo(29, 66)
        ..close());
      _drawMuscle(canvas, leftTricep, Muscle.TRICEPS, paint, outlinePaint);

      final rightTricep = scalePath(Path()
        ..moveTo(76, 64)
        ..lineTo(82, 90)
        ..lineTo(74, 92)
        ..lineTo(71, 66)
        ..close());
      _drawMuscle(canvas, rightTricep, Muscle.TRICEPS, paint, outlinePaint);

      // Forearms (Back)
      final leftForearm = scalePath(Path()
        ..moveTo(18, 92)
        ..lineTo(12, 128)
        ..lineTo(19, 128)
        ..lineTo(26, 94)
        ..close());
      _drawMuscle(canvas, leftForearm, Muscle.FOREARMS, paint, outlinePaint);

      final rightForearm = scalePath(Path()
        ..moveTo(82, 92)
        ..lineTo(88, 128)
        ..lineTo(81, 128)
        ..lineTo(74, 94)
        ..close());
      _drawMuscle(canvas, rightForearm, Muscle.FOREARMS, paint, outlinePaint);

      // Glutes
      final leftGlute = scalePath(Path()
        ..moveTo(33, 107)
        ..quadraticBezierTo(40, 105, 50, 107)
        ..lineTo(47, 128)
        ..quadraticBezierTo(38, 128, 30, 124)
        ..close());
      _drawMuscle(canvas, leftGlute, Muscle.GLUTES, paint, outlinePaint);

      final rightGlute = scalePath(Path()
        ..moveTo(67, 107)
        ..quadraticBezierTo(60, 105, 50, 107)
        ..lineTo(53, 128)
        ..quadraticBezierTo(62, 128, 70, 124)
        ..close());
      _drawMuscle(canvas, rightGlute, Muscle.GLUTES, paint, outlinePaint);

      // Hamstrings
      final leftHamstring = scalePath(Path()
        ..moveTo(31, 130)
        ..lineTo(48, 130)
        ..lineTo(45, 168)
        ..lineTo(30, 168)
        ..close());
      _drawMuscle(canvas, leftHamstring, Muscle.HAMSTRINGS, paint, outlinePaint);

      final rightHamstring = scalePath(Path()
        ..moveTo(69, 130)
        ..lineTo(52, 130)
        ..lineTo(55, 168)
        ..lineTo(70, 168)
        ..close());
      _drawMuscle(canvas, rightHamstring, Muscle.HAMSTRINGS, paint, outlinePaint);

      // Calves
      final leftCalf = scalePath(Path()
        ..moveTo(29, 172)
        ..lineTo(44, 172)
        ..lineTo(41, 198)
        ..lineTo(32, 198)
        ..close());
      _drawMuscle(canvas, leftCalf, Muscle.CALVES, paint, outlinePaint);

      final rightCalf = scalePath(Path()
        ..moveTo(71, 172)
        ..lineTo(56, 172)
        ..lineTo(59, 198)
        ..lineTo(68, 198)
        ..close());
      _drawMuscle(canvas, rightCalf, Muscle.CALVES, paint, outlinePaint);
    }
  }

  void _drawMuscle(Canvas canvas, Path path, Muscle muscle, Paint fillPaint, Paint strokePaint) {
    fillPaint.color = _getHeatColor(muscle);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant BodyOutlinePainter oldDelegate) {
    return oldDelegate.intensities != intensities ||
        oldDelegate.isFront != isFront ||
        oldDelegate.isDark != isDark;
  }
}
