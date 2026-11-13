/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/nexc_badge.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/db/enums.dart';
import '../../core/db/measurement_repository.dart';
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/unit_system.dart';
import '../../core/util/workout_stats_helper.dart';
import '../../l10n/app_localizations.dart';
import '../profile/profile_screen.dart';

class InfoWorkoutScreen extends ConsumerStatefulWidget {
  final int workoutId;

  const InfoWorkoutScreen({super.key, required this.workoutId});

  @override
  ConsumerState<InfoWorkoutScreen> createState() => _InfoWorkoutScreenState();
}

class _InfoWorkoutScreenState extends ConsumerState<InfoWorkoutScreen> {
  bool _isLoading = true;
  WorkoutWithExercisesAndSets? _workoutData;
  WorkoutWithExercisesAndSets? _linkedRoutineData;
  List<WorkoutWithExercisesAndSets> _completedWorkoutsForChart =
      <WorkoutWithExercisesAndSets>[];
  double _volume = 0.0;
  WorkoutChart _chartMode = WorkoutChart.duration;
  List<Point> _chartPoints = <Point>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final WorkoutRepository workoutRepo = ref.read(workoutRepositoryProvider);
    final MeasurementRepository measurementRepo = ref.read(
      measurementRepositoryProvider,
    );

    final WorkoutWithExercisesAndSets? data = await workoutRepo
        .getWorkoutWithExercisesAndSets(widget.workoutId);
    if (data == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    _workoutData = data;
    final bool isRoutine = data.workout.state == WorkoutState.ROUTINE;
    final DateTime measurementDate = isRoutine
        ? data.workout.created
        : data.workout.completed;
    final BodyMeasurement? measurement = await measurementRepo
        .getLastMeasurementByCutoff(measurementDate);
    final double bodyWeight = measurement?.bodyWeight ?? 0.0;
    _volume = _volumeOf(
      data,
      bodyWeight: bodyWeight,
      onlyCompleted: !isRoutine,
    );

    if (isRoutine) {
      _completedWorkoutsForChart = await workoutRepo
          .getCompletedWorkoutsWithExercisesAndSetsFromRoutine(data.workout.id);
      await _updateChartPoints();
    } else if (data.workout.routineId != 0) {
      _linkedRoutineData = await workoutRepo.getWorkoutWithExercisesAndSets(
        data.workout.routineId,
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Total tonnage, including body-weight contribution for body-weight modes.
  double _volumeOf(
    WorkoutWithExercisesAndSets data, {
    required double bodyWeight,
    required bool onlyCompleted,
  }) {
    double total = 0;
    for (final ExerciseWithSets exercise in data.exercisesWithSets) {
      final bool includeBodyweight =
          exercise.exercise.setMode == SetMode.BODYWEIGHT ||
          exercise.exercise.setMode == SetMode.BODYWEIGHT_WITH_LOAD;
      for (final WorkoutSet set in exercise.sets) {
        if (onlyCompleted && !set.completed) continue;
        total += (set.load + (includeBodyweight ? bodyWeight : 0.0)) * set.reps;
      }
    }
    return total;
  }

  Future<void> _updateChartPoints() async {
    final MeasurementRepository measurementRepo = ref.read(
      measurementRepositoryProvider,
    );
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final List<Point> points = <Point>[];

    for (final WorkoutWithExercisesAndSets workout
        in _completedWorkoutsForChart) {
      final BodyMeasurement? measurement = await measurementRepo
          .getLastMeasurementByCutoff(workout.workout.completed);
      final double bodyWeight = measurement?.bodyWeight ?? 0.0;

      double value = 0;
      switch (_chartMode) {
        case WorkoutChart.duration:
          value = workout.workout.timeElapsed / 60.0;
          break;
        case WorkoutChart.volume:
          value = _volumeOf(
            workout,
            bodyWeight: bodyWeight,
            onlyCompleted: true,
          );
          break;
        case WorkoutChart.reps:
          int totalReps = 0;
          for (final ExerciseWithSets exercise in workout.exercisesWithSets) {
            for (final WorkoutSet set in exercise.sets) {
              if (set.completed) totalReps += set.reps;
            }
          }
          value = totalReps.toDouble();
          break;
      }

      final String date = localizations.formatShortDate(
        workout.workout.completed,
      );
      points.add(
        Point(
          yValues: <double>[value],
          xValue: date,
          workoutId: workout.workout.id,
        ),
      );
    }

    _chartPoints = points.reversed.toList();
  }

  Future<void> _deleteWorkout() async {
    if (_workoutData == null) return;
    final AppLocalizations l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: _workoutData!.workout.state == WorkoutState.ROUTINE
          ? l10n.deleteRoutineTitle
          : l10n.deleteWorkoutTitle,
      message: _workoutData!.workout.state == WorkoutState.ROUTINE
          ? l10n.deleteRoutineMessage
          : l10n.deleteWorkoutMessage,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed == true && mounted) {
      await ref
          .read(workoutRepositoryProvider)
          .deleteWorkout(_workoutData!.workout);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _unlinkRoutine() async {
    if (_workoutData == null) return;
    final AppLocalizations l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: l10n.unlinkRoutineTitle,
      message: l10n.unlinkRoutineMessage,
      confirmLabel: l10n.unlink,
      cancelLabel: l10n.cancel,
    );
    if (confirmed == true && mounted) {
      final Workout updated = _workoutData!.workout.copyWith(routineId: 0);
      await ref.read(workoutRepositoryProvider).updateWorkout(updated);
      _linkedRoutineData = null;
      _loadData();
    }
  }

  void _openEditor() {
    Navigator.pushNamed(
      context,
      '/edit-workout',
      arguments: _workoutData!.workout.id,
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _workoutData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final UnitSystem unitSystem = ref.watch(
      settingsProvider.select((SettingsState s) => s.unitSystem),
    );
    final Workout workout = _workoutData!.workout;
    final bool isRoutine = workout.state == WorkoutState.ROUTINE;
    final DateTime displayDate = isRoutine
        ? workout.created
        : workout.completed;
    final String dateStr = context.formatMediumDate(displayDate);

    final int totalSets = _workoutData!.exercisesWithSets.fold<int>(
      0,
      (int sum, ExerciseWithSets e) => sum + e.sets.length,
    );
    final int completedSets = _workoutData!.exercisesWithSets.fold<int>(
      0,
      (int sum, ExerciseWithSets e) =>
          sum + e.sets.where((WorkoutSet s) => s.completed).length,
    );

    return NexcPage(
      title: isRoutine ? l10n.routineLabel : l10n.tabWorkout,
      subtitle: workout.title,
      actions: <Widget>[
        IconButton(
          tooltip: l10n.edit,
          icon: const Icon(NexcIcons.edit),
          onPressed: _openEditor,
        ),
        PopupMenuButton<String>(
          tooltip: l10n.moreOptions,
          icon: const Icon(NexcIcons.more),
          onSelected: (String value) {
            if (value == 'delete') _deleteWorkout();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(NexcIcons.delete, color: theme.colorScheme.error),
                title: Text(
                  l10n.delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(NexcSpacing.lg),
        children: <Widget>[
          _HeaderCard(
            workout: workout,
            dateStr: dateStr,
            isRoutine: isRoutine,
            l10n: l10n,
          ),
          const SizedBox(height: NexcSpacing.xl),
          _MetricsSection(
            workoutData: _workoutData!,
            unitSystem: unitSystem,
            volumeKg: _volume,
            totalSets: totalSets,
            completedSets: completedSets,
            isRoutine: isRoutine,
          ),
          if (workout.notes.isNotEmpty) ...<Widget>[
            const SizedBox(height: NexcSpacing.xl),
            _NotesSection(notes: workout.notes),
          ],
          if (isRoutine && _completedWorkoutsForChart.isNotEmpty) ...<Widget>[
            const SizedBox(height: NexcSpacing.lg),
            NexcCartesianChart(
              points: _chartMode == WorkoutChart.volume
                  ? _chartPoints
                        .map(
                          (Point point) => Point(
                            yValues: point.yValues
                                .map(
                                  (double value) =>
                                      fromKilograms(value, unitSystem),
                                )
                                .toList(),
                            xValue: point.xValue,
                            workoutId: point.workoutId,
                          ),
                        )
                        .toList()
                  : _chartPoints,
              decimalCount: _chartMode == WorkoutChart.duration ? 0 : 2,
              suffix: _chartMode == WorkoutChart.duration
                  ? 'm'
                  : _chartMode == WorkoutChart.volume
                  ? unitSystem.suffix
                  : '',
              chartMode: _chartMode,
              updateChartMode: (WorkoutChart mode) async {
                setState(() => _chartMode = mode);
                await _updateChartPoints();
                if (mounted) setState(() {});
              },
              onEntrySelection: (int id) {
                Navigator.pushNamed(
                  context,
                  '/info-workout',
                  arguments: id,
                ).then((_) => _loadData());
              },
            ),
          ],
          if (!isRoutine && _linkedRoutineData != null) ...<Widget>[
            const SizedBox(height: NexcSpacing.xl),
            _LinkedRoutineSection(
              routine: _linkedRoutineData!,
              onOpen: () {
                Navigator.pushNamed(
                  context,
                  '/info-workout',
                  arguments: _linkedRoutineData!.workout.id,
                ).then((_) => _loadData());
              },
              onUnlink: _unlinkRoutine,
            ),
          ],
          const SizedBox(height: NexcSpacing.xl),
          NexcSection(
            title: l10n.exercisesLabel,
            children: _workoutData!.exercisesWithSets
                .map(
                  (ExerciseWithSets exercise) => _ReadOnlyExercise(
                    exercise: exercise,
                    isRoutine: isRoutine,
                    unitSystem: unitSystem,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Workout workout;
  final String dateStr;
  final bool isRoutine;
  final AppLocalizations l10n;

  const _HeaderCard({
    required this.workout,
    required this.dateStr,
    required this.isRoutine,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(NexcSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: NexcShapes.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            workout.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: NexcSpacing.sm),
          Text(
            isRoutine
                ? l10n.createdWithDate(dateStr)
                : l10n.completedWithDate(dateStr),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          if (!isRoutine) ...<Widget>[
            const SizedBox(height: NexcSpacing.xs),
            Text(
              l10n.durationWithTime(formatDurationShort(workout.timeElapsed)),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  final WorkoutWithExercisesAndSets workoutData;
  final UnitSystem unitSystem;
  final double volumeKg;
  final int totalSets;
  final int completedSets;
  final bool isRoutine;

  const _MetricsSection({
    required this.workoutData,
    required this.unitSystem,
    required this.volumeKg,
    required this.totalSets,
    required this.completedSets,
    required this.isRoutine,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final double density = WorkoutStatsHelper.calculateWorkoutDensity(
      workoutData,
    );
    final int hardSets = WorkoutStatsHelper.countHardSets(workoutData);
    final BestEstimatedOneRepMax? bestOneRm =
        WorkoutStatsHelper.getBestEstimatedOneRepMax(workoutData);
    final Muscle? primaryMuscle = WorkoutStatsHelper.getPrimaryMuscleImpacted(
      workoutData,
    );

    final List<_MetricData> metrics = <_MetricData>[
      if (!isRoutine)
        _MetricData(
          icon: NexcIcons.timer,
          label: l10n.durationLabel,
          value: formatDurationShort(workoutData.workout.timeElapsed),
        ),
      _MetricData(
        icon: Icons.scale_outlined,
        label: l10n.tonnageLabel,
        value:
            '${fromKilograms(volumeKg, unitSystem).toStringAsFixed(0)} '
            '${unitSystem.suffix}',
      ),
      _MetricData(
        icon: Icons.speed_outlined,
        label: l10n.densityLabel,
        value: density > 0
            ? '${fromKilograms(density, unitSystem).toStringAsFixed(2)} '
                  '${unitSystem.suffix}/s'
            : '—',
      ),
      _MetricData(
        icon: NexcIcons.check,
        label: l10n.setsCompletedLabel,
        value: isRoutine ? '$totalSets' : '$completedSets / $totalSets',
      ),
      _MetricData(
        icon: Icons.local_fire_department_outlined,
        label: l10n.hardSetsMetricLabel,
        value: '$hardSets',
      ),
      if (primaryMuscle != null)
        _MetricData(
          icon: NexcIcons.workout,
          label: l10n.primaryMuscleLabel,
          value: l10n.muscleWithValue(_humanize(primaryMuscle.name)),
        ),
      if (bestOneRm != null)
        _MetricData(
          icon: Icons.trending_up_outlined,
          label: l10n.bestE1rmLabel,
          value:
              '${bestOneRm.exerciseName} · '
              '${fromKilograms(bestOneRm.estimatedOneRepMax, unitSystem).toStringAsFixed(1)} '
              '${unitSystem.suffix}',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: NexcSpacing.xs,
            bottom: NexcSpacing.sm,
          ),
          child: Text(
            l10n.performance,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int columns = constraints.maxWidth >= 340 ? 2 : 1;
            const double spacing = NexcSpacing.sm;
            final double width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: <Widget>[
                for (final _MetricData metric in metrics)
                  SizedBox(
                    width: width,
                    child: _MetricTile(data: metric),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  static String _humanize(String value) {
    return value
        .split('_')
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;

  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _MetricTile extends StatelessWidget {
  final _MetricData data;

  const _MetricTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(NexcSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: NexcShapes.mdRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(data.icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: NexcSpacing.xs),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NexcSpacing.xs),
          Text(
            data.value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final String notes;

  const _NotesSection({required this.notes});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(NexcSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: NexcShapes.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(NexcIcons.notes, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: NexcSpacing.sm),
              Text(
                l10n.notes,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: NexcSpacing.sm),
          Text(notes, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _LinkedRoutineSection extends StatelessWidget {
  final WorkoutWithExercisesAndSets routine;
  final VoidCallback onOpen;
  final VoidCallback onUnlink;

  const _LinkedRoutineSection({
    required this.routine,
    required this.onOpen,
    required this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(NexcSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: NexcShapes.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.linkedRoutine,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.unlink,
                icon: const Icon(Icons.link_off),
                onPressed: onUnlink,
              ),
            ],
          ),
          const SizedBox(height: NexcSpacing.xs),
          Text(
            routine.workout.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: NexcSpacing.xs),
          Text(
            l10n.createdWithDate(
              context.formatMediumDate(routine.workout.created),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: NexcSpacing.md),
          FilledButton.tonalIcon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.openThisRoutine),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyExercise extends StatelessWidget {
  final ExerciseWithSets exercise;
  final bool isRoutine;
  final UnitSystem unitSystem;

  const _ReadOnlyExercise({
    required this.exercise,
    required this.isRoutine,
    required this.unitSystem,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final ExerciseDataDC dc = exercise.exerciseDC;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NexcSpacing.lg,
        vertical: NexcSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            dc.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: NexcSpacing.sm),
          ...List<Widget>.generate(exercise.sets.length, (int index) {
            final WorkoutSet set = exercise.sets[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: NexcSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _setValue(context, set),
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (set.setType != SetType.NORMAL) ...<Widget>[
                          const SizedBox(height: NexcSpacing.xs),
                          Wrap(
                            spacing: NexcSpacing.xs,
                            runSpacing: NexcSpacing.xs,
                            children: <Widget>[
                              NexcBadge(
                                set.setType.displayName,
                                tone: NexcBadgeTone.warning,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (set.rpe != null)
                    NexcBadge(l10n.rpeWithValue('${set.rpe}')),
                  if (set.rir != null) ...<Widget>[
                    const SizedBox(width: NexcSpacing.xs),
                    NexcBadge(l10n.rirWithValue('${set.rir}')),
                  ],
                  if (!isRoutine) ...<Widget>[
                    const SizedBox(width: NexcSpacing.sm),
                    Icon(
                      set.completed ? NexcIcons.check : NexcIcons.close,
                      size: 18,
                      color: set.completed
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _setValue(BuildContext context, WorkoutSet set) {
    final String reps = context.l10n.repsCount(set.reps);
    switch (exercise.exercise.setMode) {
      case SetMode.DURATION:
        return formatClock(set.elapsedTime);
      case SetMode.DURATION_WITH_LOAD:
        return '${formatWeight(set.load, unitSystem, suffix: unitSystem.suffix)}'
            ' × ${formatClock(set.elapsedTime)}';
      case SetMode.BODYWEIGHT:
        return reps;
      case SetMode.BODYWEIGHT_WITH_LOAD:
      case SetMode.LOAD:
        return '${formatWeight(set.load, unitSystem, suffix: unitSystem.suffix)}'
            ' × $reps';
    }
  }
}
