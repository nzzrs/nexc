/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/db/relations.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final WorkoutWithExercisesAndSets workoutData;

  const WorkoutSummaryScreen({
    super.key,
    required this.workoutData,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Generate confetti particles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 120; i++) {
        _particles.add(_ConfettiParticle(
          x: _random.nextDouble() * size.width,
          y: -_random.nextDouble() * size.height * 0.5,
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
          size: _random.nextDouble() * 8 + 6,
          speedY: _random.nextDouble() * 150 + 100,
          speedX: _random.nextDouble() * 60 - 30,
          rotationSpeed: _random.nextDouble() * 4 + 1,
        ));
      }
      _animationController.repeat();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '${m}m ${s}s';
    }
    return '${s}s';
  }

  double _calculateTotalVolume() {
    double total = 0;
    for (final ex in widget.workoutData.exercisesWithSets) {
      for (final s in ex.sets) {
        if (s.completed) {
          total += s.load * s.reps;
        }
      }
    }
    return total;
  }

  int _totalCompletedSets() {
    return widget.workoutData.exercisesWithSets.fold(0, (sum, item) => sum + item.sets.where((s) => s.completed).length);
  }

  int _totalSets() {
    return widget.workoutData.exercisesWithSets.fold(0, (sum, item) => sum + item.sets.length);
  }

  String _getDetailedSummaryText() {
    final title = widget.workoutData.workout.title;
    final duration = _formatDuration(widget.workoutData.workout.timeElapsed);
    final volume = _calculateTotalVolume();
    final completedSets = _totalCompletedSets();
    final totalSets = _totalSets();

    final buffer = StringBuffer();
    buffer.writeln('Workout Summary: $title');
    buffer.writeln('Duration: $duration');
    buffer.writeln('Total Volume: ${volume.toStringAsFixed(1)} kg');
    buffer.writeln('Completed Sets: $completedSets/$totalSets');
    buffer.writeln();
    buffer.writeln('Exercises:');

    for (final ex in widget.workoutData.exercisesWithSets) {
      buffer.writeln('- ${ex.exerciseDC.name}:');
      for (int i = 0; i < ex.sets.length; i++) {
        final s = ex.sets[i];
        final status = s.completed ? 'Done' : 'Incomplete';
        buffer.writeln('  Set ${i + 1}: ${s.load.toStringAsFixed(1)} kg x ${s.reps} reps ($status${s.rpe != null ? ', RPE ${s.rpe}' : ''})');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.workoutData.workout.title;
    final duration = _formatDuration(widget.workoutData.workout.timeElapsed);
    final volume = _calculateTotalVolume();
    final completedSets = _totalCompletedSets();
    final totalSets = _totalSets();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Confetti painter
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(_particles, _animationController.value),
                child: Container(),
              );
            },
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title / Congrats
                  const SizedBox(height: 16),
                  Center(
                    child: Icon(
                      Icons.emoji_events,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Workout Completed!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // M3 Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: theme.colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Volume',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${volume.toStringAsFixed(0)} kg',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          color: theme.colorScheme.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Duration',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  duration,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: theme.colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Sets Completed',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$completedSets / $totalSets',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Exercises done',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.workoutData.exercisesWithSets.length}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Header
                  Text(
                    'Exercise Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Exercise list summary details
                  ...widget.workoutData.exercisesWithSets.map((ex) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.exerciseDC.name,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...ex.sets.map((s) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${s.load.toStringAsFixed(1)} kg x ${s.reps}',
                                      style: TextStyle(
                                        color: s.completed ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                        fontWeight: s.completed ? FontWeight.normal : FontWeight.w300,
                                        decoration: s.completed ? null : TextDecoration.lineThrough,
                                      ),
                                    ),
                                    if (s.completed)
                                      Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary)
                                    else
                                      const Icon(Icons.cancel_outlined, size: 16, color: Colors.grey),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Copy & Close Actions
                  FilledButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _getDetailedSummaryText()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Detailed summary copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy to Clipboard'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double speedY;
  final double speedX;
  final double rotationSpeed;
  double rotation = 0.0;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.rotationSpeed,
  });

  void update(double dt, double width, double height) {
    y += speedY * dt;
    x += speedX * dt;
    rotation += rotationSpeed * dt;
    if (y > height) {
      y = -size;
      x = Random().nextDouble() * width;
    }
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double animationVal;
  DateTime _lastTime = DateTime.now();

  _ConfettiPainter(this.particles, this.animationVal);

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final dt = now.difference(_lastTime).inMicroseconds / 1000000.0;
    _lastTime = now;

    // Use dt but clamp it to avoid huge jumps
    final delta = dt > 0.1 ? 0.016 : dt;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      p.update(delta, size.width, size.height);
      paint.color = p.color;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
