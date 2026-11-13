/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/util/unit_system.dart';
import '../../core/util/workout_stats_helper.dart';

String _formatSummaryDuration(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String formatWorkoutSummaryText(
  WorkoutWithExercisesAndSets workoutData, {
  IntensityScale intensityScale = IntensityScale.both,
  UnitSystem unitSystem = UnitSystem.metric,
}) {
  final title = workoutData.workout.title;
  final duration = _formatSummaryDuration(workoutData.workout.timeElapsed);
  final volume = workoutData.exercisesWithSets.fold(0.0, (sum, item) {
    return sum +
        item.sets.fold(
          0.0,
          (sSum, s) => sSum + (s.completed ? s.load * s.reps : 0.0),
        );
  });
  final completedSets = workoutData.exercisesWithSets.fold(0, (sum, item) {
    return sum + item.sets.where((s) => s.completed).length;
  });
  final totalSets = workoutData.exercisesWithSets.fold(
    0,
    (sum, item) => sum + item.sets.length,
  );

  final buffer = StringBuffer();
  buffer.writeln('Workout Summary: $title');
  buffer.writeln('Duration: $duration');
  buffer.writeln(
    'Total Volume: '
    '${fromKilograms(volume, unitSystem).toStringAsFixed(1)} '
    '${unitSystem.suffix}',
  );
  buffer.writeln('Completed Sets: $completedSets/$totalSets');
  buffer.writeln();
  buffer.writeln('Exercises:');

  final showRpe =
      intensityScale == IntensityScale.rpe ||
      intensityScale == IntensityScale.both;
  final showRir =
      intensityScale == IntensityScale.rir ||
      intensityScale == IntensityScale.both;

  for (final ex in workoutData.exercisesWithSets) {
    final restMin = ex.exercise.restTime ~/ 60;
    final restSec = ex.exercise.restTime % 60;
    final restStr = restMin > 0 ? '${restMin}m ${restSec}s' : '${restSec}s';
    buffer.writeln('- ${ex.exerciseDC.name} (Rest: $restStr):');
    for (int i = 0; i < ex.sets.length; i++) {
      final s = ex.sets[i];
      final status = s.completed ? 'Done' : 'Incomplete';
      final rpeStr = (showRpe && s.rpe != null)
          ? ', RPE ${s.rpe.toString().replaceAll(RegExp(r'\.0$'), '')}'
          : '';
      final rirStr = (showRir && s.rir != null) ? ', RIR ${s.rir}' : '';
      buffer.writeln(
        '  Set ${i + 1}: '
        '${fromKilograms(s.load, unitSystem).toStringAsFixed(1)} '
        '${unitSystem.suffix} x ${s.reps} reps ($status$rpeStr$rirStr)',
      );
    }
  }
  return buffer.toString();
}

class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  final WorkoutWithExercisesAndSets workoutData;

  const WorkoutSummaryScreen({super.key, required this.workoutData});

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen>
    with SingleTickerProviderStateMixin {
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
        _particles.add(
          _ConfettiParticle(
            x: _random.nextDouble() * size.width,
            y: -_random.nextDouble() * size.height * 0.5,
            color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
            size: _random.nextDouble() * 8 + 6,
            speedY: _random.nextDouble() * 150 + 100,
            speedX: _random.nextDouble() * 60 - 30,
            rotationSpeed: _random.nextDouble() * 4 + 1,
          ),
        );
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
    return WorkoutStatsHelper.calculateWorkoutTonnage(widget.workoutData);
  }

  int _totalCompletedSets() {
    return widget.workoutData.exercisesWithSets.fold(
      0,
      (sum, item) => sum + item.sets.where((s) => s.completed).length,
    );
  }

  int _totalSets() {
    return widget.workoutData.exercisesWithSets.fold(
      0,
      (sum, item) => sum + item.sets.length,
    );
  }

  /// Reads the preferred unit system and keeps the screen reactive to it.
  ///
  /// Widget tests may pump this screen without a `SharedPreferences`
  /// override; in that case the settings provider cannot be built, so the
  /// canonical metric display is used.
  UnitSystem _preferredUnitSystem() {
    try {
      return ref.watch(settingsProvider.select((s) => s.unitSystem));
    } on UnimplementedError {
      return UnitSystem.metric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.workoutData.workout.title;
    final duration = _formatDuration(widget.workoutData.workout.timeElapsed);
    final volume = _calculateTotalVolume();
    final unitSystem = _preferredUnitSystem();
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
                painter: _ConfettiPainter(
                  _particles,
                  _animationController.value,
                ),
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
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${fromKilograms(volume, unitSystem).toStringAsFixed(0)} '
                                    '${unitSystem.suffix}',
                                    maxLines: 1,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
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
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    duration,
                                    maxLines: 1,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
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
                        children: [
                          Expanded(
                            child: _SummaryStat(
                              label: 'Sets Completed',
                              value: '$completedSets / $totalSets',
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SummaryStat(
                              label: 'Hard Sets',
                              value:
                                  '${WorkoutStatsHelper.countHardSets(widget.workoutData)}',
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SummaryStat(
                              label: 'Exercises',
                              value:
                                  '${widget.workoutData.exercisesWithSets.length}',
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 24,
                        runSpacing: 8,
                        children: [
                          _SummaryBadge(
                            icon: Icons.speed,
                            iconColor: theme.colorScheme.primary,
                            text:
                                'Density: '
                                '${fromKilograms(WorkoutStatsHelper.calculateWorkoutDensity(widget.workoutData), unitSystem).toStringAsFixed(1)} '
                                '${unitSystem.suffix}/s',
                          ),
                          if (WorkoutStatsHelper.getPrimaryMuscleImpacted(
                                widget.workoutData,
                              ) !=
                              null)
                            _SummaryBadge(
                              icon: Icons.fitness_center,
                              iconColor: theme.colorScheme.secondary,
                              text:
                                  'Focus: ${WorkoutStatsHelper.getPrimaryMuscleImpacted(widget.workoutData)!.name}',
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    ex.exerciseDC.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (WorkoutStatsHelper.calculateExerciseEstimatedOneRepMax(
                                      ex,
                                    ) >
                                    0) ...[
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'e1RM: '
                                          '${fromKilograms(WorkoutStatsHelper.calculateExerciseEstimatedOneRepMax(ex), unitSystem).toStringAsFixed(1)} '
                                          '${unitSystem.suffix}',
                                          maxLines: 1,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSecondaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Volume: '
                              '${fromKilograms(WorkoutStatsHelper.calculateExerciseTonnage(ex), unitSystem).toStringAsFixed(0)} '
                              '${unitSystem.suffix}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...ex.sets.map((s) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          if (s.setType != SetType.NORMAL) ...[
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 1,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    s.setType == SetType.WARMUP
                                                    ? Colors.amber.withValues(
                                                        alpha: 0.2,
                                                      )
                                                    : s.setType == SetType.DROP
                                                    ? Colors.purple.withValues(
                                                        alpha: 0.2,
                                                      )
                                                    : s.setType == SetType.MYO
                                                    ? Colors.teal.withValues(
                                                        alpha: 0.2,
                                                      )
                                                    : Colors.red.withValues(
                                                        alpha: 0.2,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                s.setType == SetType.WARMUP
                                                    ? 'W'
                                                    : s.setType == SetType.DROP
                                                    ? 'D'
                                                    : s.setType == SetType.MYO
                                                    ? 'M'
                                                    : 'F',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      s.setType ==
                                                          SetType.WARMUP
                                                      ? Colors.amber.shade800
                                                      : s.setType ==
                                                            SetType.DROP
                                                      ? Colors.purple.shade700
                                                      : s.setType == SetType.MYO
                                                      ? Colors.teal.shade700
                                                      : Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                          Flexible(
                                            child: Text(
                                              '${fromKilograms(s.load, unitSystem).toStringAsFixed(1)} '
                                              '${unitSystem.suffix} x ${s.reps}',
                                              style: TextStyle(
                                                color: s.completed
                                                    ? theme
                                                          .colorScheme
                                                          .onSurface
                                                    : theme
                                                          .colorScheme
                                                          .onSurfaceVariant
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                fontWeight: s.completed
                                                    ? FontWeight.normal
                                                    : FontWeight.w300,
                                                decoration: s.completed
                                                    ? null
                                                    : TextDecoration
                                                          .lineThrough,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (s.completed)
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      )
                                    else
                                      const Icon(
                                        Icons.cancel_outlined,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
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
                      final settings = ref.read(settingsProvider);
                      Clipboard.setData(
                        ClipboardData(
                          text: formatWorkoutSummaryText(
                            widget.workoutData,
                            intensityScale: settings.intensityScale,
                            unitSystem: settings.unitSystem,
                          ),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Detailed summary copied to clipboard'),
                        ),
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

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _SummaryBadge({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
