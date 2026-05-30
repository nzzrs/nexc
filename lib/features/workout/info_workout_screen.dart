/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/db/measurement_repository.dart';
import '../../core/components/nexc_scaffold.dart';
import '../../core/providers/profile_providers.dart';
import '../profile/profile_screen.dart';

class InfoWorkoutScreen extends ConsumerStatefulWidget {
  final int workoutId;

  const InfoWorkoutScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<InfoWorkoutScreen> createState() => _InfoWorkoutScreenState();
}

class _InfoWorkoutScreenState extends ConsumerState<InfoWorkoutScreen> {
  bool _isLoading = true;
  WorkoutWithExercisesAndSets? _workoutData;
  WorkoutWithExercisesAndSets? _linkedRoutineData;
  List<WorkoutWithExercisesAndSets> _completedWorkoutsForChart = [];
  double _volume = 0.0;
  WorkoutChart _chartMode = WorkoutChart.DURATION;
  List<Point> _chartPoints = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final workoutRepo = ref.read(workoutRepositoryProvider);
    final measurementRepo = ref.read(measurementRepositoryProvider);

    final data = await workoutRepo.getWorkoutWithExercisesAndSets(widget.workoutId);
    if (data == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    _workoutData = data;

    // Determine if it is a routine
    final isRoutine = data.workout.state == WorkoutState.ROUTINE;

    // Fetch bodyweight for volume calculation
    final measurementDate = isRoutine ? data.workout.created : data.workout.completed;
    final measurement = await measurementRepo.getLastMeasurementByCutoff(measurementDate);
    final bodyWeight = measurement?.bodyWeight ?? 0.0;

    // Calculate volume
    double totalVol = 0.0;
    for (final exe in data.exercisesWithSets) {
      final includeBodyweight = exe.exercise.setMode == SetMode.BODYWEIGHT ||
          exe.exercise.setMode == SetMode.BODYWEIGHT_WITH_LOAD;
      for (final set in exe.sets) {
        if (isRoutine || set.completed) {
          totalVol += (set.load + (includeBodyweight ? bodyWeight : 0.0)) * set.reps;
        }
      }
    }
    _volume = totalVol;

    if (isRoutine) {
      // Fetch past completed workouts of this routine for the performance chart
      final past = await workoutRepo.getCompletedWorkoutsWithExercisesAndSetsFromRoutine(data.workout.id);
      _completedWorkoutsForChart = past;
      await _updateChartPoints();
    } else if (data.workout.routineId != 0) {
      // Fetch linked routine details
      final routine = await workoutRepo.getWorkoutWithExercisesAndSets(data.workout.routineId);
      _linkedRoutineData = routine;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateChartPoints() async {
    final measurementRepo = ref.read(measurementRepositoryProvider);
    final List<Point> pts = [];

    for (final w in _completedWorkoutsForChart) {
      final measurement = await measurementRepo.getLastMeasurementByCutoff(w.workout.completed);
      final bodyWeight = measurement?.bodyWeight ?? 0.0;

      double yVal = 0.0;
      switch (_chartMode) {
        case WorkoutChart.DURATION:
          yVal = w.workout.timeElapsed / 60.0;
          break;
        case WorkoutChart.VOLUME:
          double totalVol = 0.0;
          for (final exe in w.exercisesWithSets) {
            final includeBodyweight = exe.exercise.setMode == SetMode.BODYWEIGHT ||
                exe.exercise.setMode == SetMode.BODYWEIGHT_WITH_LOAD;
            for (final set in exe.sets) {
              if (set.completed) {
                totalVol += (set.load + (includeBodyweight ? bodyWeight : 0.0)) * set.reps;
              }
            }
          }
          yVal = totalVol;
          break;
        case WorkoutChart.REPS:
          int totalReps = 0;
          for (final exe in w.exercisesWithSets) {
            for (final set in exe.sets) {
              if (set.completed) {
                totalReps += set.reps;
              }
            }
          }
          yVal = totalReps.toDouble();
          break;
      }

      final dateStr = "${w.workout.completed.month}/${w.workout.completed.day}/${w.workout.completed.year.toString().substring(max(0, w.workout.completed.year.toString().length - 2))}";
      pts.add(Point(
        yValues: [yVal],
        xValue: dateStr,
        workoutId: w.workout.id,
      ));
    }

    _chartPoints = pts.reversed.toList();
  }

  Future<void> _deleteWorkout() async {
    if (_workoutData == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_workoutData!.workout.state == WorkoutState.ROUTINE ? 'Delete Routine?' : 'Delete Workout?'),
        content: Text(_workoutData!.workout.state == WorkoutState.ROUTINE
            ? 'Are you sure you want to delete this routine? This action cannot be undone.'
            : 'Are you sure you want to delete this workout? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.deleteWorkout(_workoutData!.workout);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _unlinkRoutine() async {
    if (_workoutData == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Routine?'),
        content: const Text('Are you sure you want to unlink this workout from its routine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(workoutRepositoryProvider);
      final updated = _workoutData!.workout.copyWith(
        routineId: 0,
      );
      await repo.updateWorkout(updated);
      _linkedRoutineData = null;
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _workoutData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final workout = _workoutData!.workout;
    final isRoutine = workout.state == WorkoutState.ROUTINE;
    final dateStr = isRoutine
        ? "${workout.created.month}/${workout.created.day}/${workout.created.year}"
        : "${workout.completed.month}/${workout.completed.day}/${workout.completed.year}";

    final totalSets = _workoutData!.exercisesWithSets.fold<int>(0, (sum, e) => sum + e.sets.length);
    final completedSets = _workoutData!.exercisesWithSets.fold<int>(0, (sum, e) => sum + e.sets.where((s) => s.completed).length);

    return NexcScaffold(
      title: Text(isRoutine ? 'Routine' : 'Workout'),
      navigateBack: () => Navigator.pop(context),
      actions: [
        () {
          Navigator.pushNamed(context, '/edit-workout', arguments: workout.id).then((_) => _loadData());
        },
        () => _deleteWorkout(),
      ],
      actionsIcons: const [
        Icon(Icons.edit_outlined),
        Icon(Icons.delete_outline),
      ],
      actionsElevated: const [false, false],
      content: (context, padding) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    if (!isRoutine) ...[
                      Text('Duration: ${(workout.timeElapsed ~/ 60)} min'),
                      const SizedBox(height: 8),
                    ],
                    Text(isRoutine ? 'Created: $dateStr' : 'Completed: $dateStr'),
                    const Divider(height: 24),
                    Text('Exercises: ${_workoutData!.exercisesWithSets.length}'),
                    const SizedBox(height: 8),
                    Text('Total sets: $totalSets'),
                    if (!isRoutine) ...[
                      const SizedBox(height: 8),
                      Text('Completed sets: $completedSets'),
                    ],
                    const SizedBox(height: 8),
                    Text('Volume: ${_volume.toStringAsFixed(2)} kg'),
                  ],
                ),
              ),
            ),
            if (workout.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline),
                          const SizedBox(width: 8),
                          Text(
                            'Notes',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(workout.notes),
                    ],
                  ),
                ),
              ),
            ],
            if (isRoutine && _completedWorkoutsForChart.isNotEmpty) ...[
              const SizedBox(height: 16),
              NexcCartesianChart(
                points: _chartPoints,
                decimalCount: _chartMode == WorkoutChart.DURATION ? 0 : 2,
                suffix: _chartMode == WorkoutChart.DURATION
                    ? "m"
                    : _chartMode == WorkoutChart.VOLUME
                        ? "kg"
                        : "",
                chartMode: _chartMode,
                updateChartMode: (mode) async {
                  setState(() {
                    _chartMode = mode;
                  });
                  await _updateChartPoints();
                  setState(() {});
                },
                onEntrySelection: (id) {
                  Navigator.pushNamed(context, '/info-workout', arguments: id).then((_) => _loadData());
                },
              ),
            ],
            if (!isRoutine && _linkedRoutineData != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Linked routine',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _linkedRoutineData!.workout.title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Created: ${_linkedRoutineData!.workout.created.month}/${_linkedRoutineData!.workout.created.day}/${_linkedRoutineData!.workout.created.year}'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.link_off),
                            onPressed: () => _unlinkRoutine(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            foregroundColor: theme.colorScheme.onSecondaryContainer,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/info-workout', arguments: _linkedRoutineData!.workout.id).then((_) => _loadData());
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open this routine'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Exercises',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ..._workoutData!.exercisesWithSets.map((e) {
              return _ReadOnlyExerciseCard(
                exe: e,
                isRoutine: isRoutine,
              );
            }),
          ],
        );
      },
    );
  }
}

class _ReadOnlyExerciseCard extends StatelessWidget {
  final ExerciseWithSets exe;
  final bool isRoutine;

  const _ReadOnlyExerciseCard({
    required this.exe,
    required this.isRoutine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dc = exe.exerciseDC;
    final sets = exe.sets;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dc.name,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(sets.length, (idx) {
              final set = sets[idx];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text('Set ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    if (exe.exercise.setMode == SetMode.DURATION)
                      Text('${set.elapsedTime ~/ 60}:${(set.elapsedTime % 60).toString().padLeft(2, '0')}')
                    else ...[
                      if (exe.exercise.setMode == SetMode.LOAD || exe.exercise.setMode == SetMode.BODYWEIGHT_WITH_LOAD)
                        Text('${set.load} kg  x  '),
                      Text('${set.reps} reps'),
                    ],
                    if (set.rpe != null) Text('  (RPE ${set.rpe})'),
                    if (set.rir != null) Text('  (RIR ${set.rir})'),
                    if (!isRoutine) ...[
                      const SizedBox(width: 12),
                      Icon(
                        set.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: set.completed ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
