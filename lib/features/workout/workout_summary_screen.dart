/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/nexc_snack.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/unit_system.dart';
import '../../core/util/workout_stats_helper.dart';
import '../../l10n/app_localizations.dart';

String _formatSummaryDuration(int seconds) {
  final String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final String remainder = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$remainder';
}

String formatWorkoutSummaryText(
  WorkoutWithExercisesAndSets workoutData, {
  IntensityScale intensityScale = IntensityScale.both,
  UnitSystem unitSystem = UnitSystem.metric,
  AppLocalizations? l10n,
}) {
  final String title = workoutData.workout.title;
  final String duration = _formatSummaryDuration(
    workoutData.workout.timeElapsed,
  );
  final double volume = workoutData.exercisesWithSets.fold<double>(
    0,
    (double sum, ExerciseWithSets item) =>
        sum +
        item.sets.fold<double>(
          0,
          (double sSum, WorkoutSet s) =>
              sSum + (s.completed ? s.load * s.reps : 0.0),
        ),
  );
  final int completedSets = workoutData.exercisesWithSets.fold<int>(
    0,
    (int sum, ExerciseWithSets item) =>
        sum + item.sets.where((WorkoutSet s) => s.completed).length,
  );
  final int totalSets = workoutData.exercisesWithSets.fold<int>(
    0,
    (int sum, ExerciseWithSets item) => sum + item.sets.length,
  );

  final String summaryLabel = l10n?.workoutSummaryTitle ?? 'Workout Summary';
  final String durationLabel = l10n?.durationLabel ?? 'Duration';
  final String exercisesLabel = l10n?.exercisesLabel ?? 'Exercises';
  final String doneLabel = l10n?.done ?? 'Done';

  final StringBuffer buffer = StringBuffer();
  buffer.writeln('$summaryLabel: $title');
  buffer.writeln('$durationLabel: $duration');
  buffer.writeln(
    'Total Volume: '
    '${fromKilograms(volume, unitSystem).toStringAsFixed(1)} '
    '${unitSystem.suffix}',
  );
  buffer.writeln('Completed Sets: $completedSets/$totalSets');
  buffer.writeln();
  buffer.writeln('$exercisesLabel:');

  final bool showRpe =
      intensityScale == IntensityScale.rpe ||
      intensityScale == IntensityScale.both;
  final bool showRir =
      intensityScale == IntensityScale.rir ||
      intensityScale == IntensityScale.both;

  for (final ExerciseWithSets ex in workoutData.exercisesWithSets) {
    final int restMin = ex.exercise.restTime ~/ 60;
    final int restSec = ex.exercise.restTime % 60;
    final String restStr = restMin > 0
        ? '${restMin}m ${restSec}s'
        : '${restSec}s';
    buffer.writeln('- ${ex.exerciseDC.name} (Rest: $restStr):');
    for (int i = 0; i < ex.sets.length; i++) {
      final WorkoutSet s = ex.sets[i];
      final String status = s.completed ? doneLabel : 'Incomplete';
      final String rpeStr = (showRpe && s.rpe != null)
          ? ', RPE ${s.rpe.toString().replaceAll(RegExp(r'\.0$'), '')}'
          : '';
      final String rirStr = (showRir && s.rir != null) ? ', RIR ${s.rir}' : '';
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
  late final AnimationController _animationController;
  final List<_ConfettiParticle> _particles = <_ConfettiParticle>[];
  final Random _random = Random();
  bool _confettiStarted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_confettiStarted) return;
    _confettiStarted = true;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final Size size = MediaQuery.sizeOf(context);
      final ColorScheme scheme = Theme.of(context).colorScheme;
      final List<Color> colors = <Color>[
        scheme.primary,
        scheme.secondary,
        scheme.tertiary,
        scheme.primaryContainer,
        scheme.tertiaryContainer,
      ];
      for (int i = 0; i < 90; i++) {
        _particles.add(
          _ConfettiParticle(
            x: _random.nextDouble() * size.width,
            y: -_random.nextDouble() * size.height * 0.5,
            color: colors[_random.nextInt(colors.length)],
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

  double _calculateTotalVolume() {
    return WorkoutStatsHelper.calculateWorkoutTonnage(widget.workoutData);
  }

  int _totalCompletedSets() {
    return widget.workoutData.exercisesWithSets.fold(
      0,
      (int sum, ExerciseWithSets item) =>
          sum + item.sets.where((WorkoutSet s) => s.completed).length,
    );
  }

  int _totalSets() {
    return widget.workoutData.exercisesWithSets.fold(
      0,
      (int sum, ExerciseWithSets item) => sum + item.sets.length,
    );
  }

  /// Reads the preferred unit system and keeps the screen reactive to it.
  ///
  /// Widget tests may pump this screen without a `SharedPreferences`
  /// override; in that case the settings provider cannot be built, so the
  /// canonical metric display is used.
  UnitSystem _preferredUnitSystem() {
    try {
      return ref.watch(
        settingsProvider.select((SettingsState s) => s.unitSystem),
      );
    } on UnimplementedError {
      return UnitSystem.metric;
    }
  }

  void _copySummary(UnitSystem unitSystem) {
    final l10n = context.l10n;
    IntensityScale intensityScale;
    try {
      intensityScale = ref.read(settingsProvider).intensityScale;
    } on UnimplementedError {
      intensityScale = IntensityScale.both;
    }
    Clipboard.setData(
      ClipboardData(
        text: formatWorkoutSummaryText(
          widget.workoutData,
          intensityScale: intensityScale,
          unitSystem: unitSystem,
          l10n: l10n,
        ),
      ),
    );
    NexcSnack.show(context, l10n.detailedSummaryCopied);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final String title = widget.workoutData.workout.title;
    final String duration = formatDurationShort(
      widget.workoutData.workout.timeElapsed,
    );
    final double volume = _calculateTotalVolume();
    final UnitSystem unitSystem = _preferredUnitSystem();
    final int completedSets = _totalCompletedSets();
    final int totalSets = _totalSets();
    final String volumeText =
        '${fromKilograms(volume, unitSystem).toStringAsFixed(0)} '
        '${unitSystem.suffix}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutSummaryTitle),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonLabel,
            icon: const Icon(NexcIcons.close),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: NexcSpacing.sm),
        ],
      ),
      body: Stack(
        children: <Widget>[
          if (_particles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (BuildContext context, Widget? child) {
                    return CustomPaint(
                      painter: _ConfettiPainter(
                        _particles,
                        _animationController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                NexcSpacing.lg,
                NexcSpacing.sm,
                NexcSpacing.lg,
                NexcSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  Text(
                    l10n.workoutCompleted,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.sm),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.xl),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final bool sideBySide = constraints.maxWidth >= 300;
                          final double cardWidth = sideBySide
                              ? (constraints.maxWidth - NexcSpacing.md) / 2
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: NexcSpacing.md,
                            runSpacing: NexcSpacing.md,
                            children: <Widget>[
                              SizedBox(
                                width: cardWidth,
                                child: _StatCard(
                                  label: l10n.volumeLabel,
                                  value: volumeText,
                                  background:
                                      theme.colorScheme.primaryContainer,
                                  foreground:
                                      theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _StatCard(
                                  label: l10n.durationLabel,
                                  value: duration,
                                  background:
                                      theme.colorScheme.secondaryContainer,
                                  foreground:
                                      theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          );
                        },
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  _StatStrip(
                    stats: <_StatData>[
                      _StatData(
                        label: l10n.setsCompletedLabel,
                        value: '$completedSets / $totalSets',
                      ),
                      _StatData(
                        label: l10n.hardSetsSummaryLabel,
                        value:
                            '${WorkoutStatsHelper.countHardSets(widget.workoutData)}',
                      ),
                      _StatData(
                        label: l10n.exercisesLabel,
                        value: '${widget.workoutData.exercisesWithSets.length}',
                      ),
                    ],
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: NexcSpacing.lg,
                      vertical: NexcSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: NexcShapes.lgRadius,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: NexcSpacing.lg,
                      runSpacing: NexcSpacing.sm,
                      children: <Widget>[
                        _SummaryBadge(
                          icon: Icons.speed,
                          iconColor: theme.colorScheme.primary,
                          text: l10n.densityWithValue(
                            '${fromKilograms(WorkoutStatsHelper.calculateWorkoutDensity(widget.workoutData), unitSystem).toStringAsFixed(1)} '
                            '${unitSystem.suffix}/s',
                          ),
                        ),
                        if (WorkoutStatsHelper.getPrimaryMuscleImpacted(
                              widget.workoutData,
                            ) !=
                            null)
                          _SummaryBadge(
                            icon: NexcIcons.workout,
                            iconColor: theme.colorScheme.secondary,
                            text: l10n.focusWithValue(
                              WorkoutStatsHelper.getPrimaryMuscleImpacted(
                                widget.workoutData,
                              )!.name,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.xl),
                  Text(
                    l10n.exerciseBreakdown,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.sm),
                  ...widget.workoutData.exercisesWithSets.map(
                    (ExerciseWithSets ex) => _ExerciseBreakdown(
                      exercise: ex,
                      unitSystem: unitSystem,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              NexcSpacing.lg,
              NexcSpacing.md,
              NexcSpacing.lg,
              NexcSpacing.md,
            ),
            child: FilledButton(
              onPressed: () => _copySummary(unitSystem),
              child: Text(
                l10n.copyToClipboard,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;

  const _StatData({required this.label, required this.value});
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color background;
  final Color foreground;

  const _StatCard({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(NexcSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: NexcShapes.lgRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            style: theme.textTheme.labelMedium?.copyWith(color: foreground),
          ),
          const SizedBox(height: NexcSpacing.sm),
          Text(
            value,
            textAlign: TextAlign.center,
            softWrap: true,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatStrip extends StatelessWidget {
  final List<_StatData> stats;

  const _StatStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(NexcSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: NexcShapes.lgRadius,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int columns = constraints.maxWidth >= 340 ? stats.length : 1;
          final double spacing = NexcSpacing.sm;
          final double width =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: NexcSpacing.md,
            children: <Widget>[
              for (final _StatData stat in stats)
                SizedBox(
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        stat.label,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      const SizedBox(height: NexcSpacing.xs),
                      Text(
                        stat.value,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
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
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: NexcSpacing.sm),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseBreakdown extends StatelessWidget {
  final ExerciseWithSets exercise;
  final UnitSystem unitSystem;

  const _ExerciseBreakdown({required this.exercise, required this.unitSystem});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final double oneRepMax =
        WorkoutStatsHelper.calculateExerciseEstimatedOneRepMax(exercise);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: NexcSpacing.xs),
      padding: const EdgeInsets.all(NexcSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: NexcShapes.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: NexcSpacing.sm,
            runSpacing: NexcSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                exercise.exerciseDC.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (oneRepMax > 0)
                _Tag(
                  label: l10n.e1rmWithValue(
                    '${fromKilograms(oneRepMax, unitSystem).toStringAsFixed(1)} '
                    '${unitSystem.suffix}',
                  ),
                  background: theme.colorScheme.primaryContainer,
                  foreground: theme.colorScheme.onPrimaryContainer,
                ),
            ],
          ),
          const SizedBox(height: NexcSpacing.xs),
          Text(
            l10n.volumeWithValue(
              '${fromKilograms(WorkoutStatsHelper.calculateExerciseTonnage(exercise), unitSystem).toStringAsFixed(0)} '
              '${unitSystem.suffix}',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: NexcSpacing.sm),
          ...List<Widget>.generate(exercise.sets.length, (int index) {
            final WorkoutSet set = exercise.sets[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: <Widget>[
                  if (set.setType != SetType.NORMAL) ...<Widget>[
                    _Tag(
                      label: set.setType.displayName,
                      background: _setTypeBackground(set.setType, theme),
                      foreground: _setTypeForeground(set.setType, theme),
                    ),
                    const SizedBox(width: NexcSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      '${fromKilograms(set.load, unitSystem).toStringAsFixed(1)} '
                      '${unitSystem.suffix} × ${set.reps}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: set.completed
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        decoration: set.completed
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  Icon(
                    set.completed ? NexcIcons.check : NexcIcons.close,
                    size: 16,
                    color: set.completed
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _setTypeBackground(SetType type, ThemeData theme) {
    switch (type) {
      case SetType.WARMUP:
        return theme.colorScheme.secondaryContainer;
      case SetType.DROP:
        return theme.colorScheme.tertiaryContainer;
      case SetType.MYO:
        return theme.colorScheme.primaryContainer;
      case SetType.FAILURE:
        return theme.colorScheme.errorContainer;
      case SetType.NORMAL:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _setTypeForeground(SetType type, ThemeData theme) {
    switch (type) {
      case SetType.WARMUP:
        return theme.colorScheme.onSecondaryContainer;
      case SetType.DROP:
        return theme.colorScheme.onTertiaryContainer;
      case SetType.MYO:
        return theme.colorScheme.onPrimaryContainer;
      case SetType.FAILURE:
        return theme.colorScheme.onErrorContainer;
      case SetType.NORMAL:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}

/// Small tonal label whose text can wrap instead of overflowing its row.
class _Tag extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NexcSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: NexcShapes.xsRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
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
      x = width > 0 ? x % width : 0;
    }
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double animationValue;
  DateTime _lastTime = DateTime.now();

  _ConfettiPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final DateTime now = DateTime.now();
    final double dt = now.difference(_lastTime).inMicroseconds / 1000000.0;
    _lastTime = now;

    // Clamp long frames so a resumed app does not teleport the confetti.
    final double delta = dt.isFinite ? dt.clamp(0.0, 0.1) : 0.016;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final _ConfettiParticle particle in particles) {
      particle.update(delta, size.width, size.height);
      paint.color = particle.color;
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.particles != particles;
  }
}
