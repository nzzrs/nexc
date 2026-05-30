/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/db/app_database.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/components/exercise_card.dart';
import '../exercises/exercises_screen.dart';
import '../../core/components/wavy_progress_indicators.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  final int workoutId; // 0 if empty, routineId if starting routine, runningWorkoutId if resuming

  const WorkoutScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  bool _isLoading = true;
  late Workout _workout;
  List<ExerciseWithSets> _exercises = [];
  final Map<String, List<WorkoutSet>> _previousPerformances = {};

  // Timers
  Timer? _stopwatchTimer;
  int _elapsedSeconds = 0;

  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _initialRestTime = 0;

  int? _idSetWithRunningStopwatch;
  Timer? _setStopwatchTimer;

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    final repo = ref.read(workoutRepositoryProvider);

    if (widget.workoutId == 0) {
      // 1. Empty Workout
      _workout = Workout(
        id: 0,
        routineId: 0,
        notes: '',
        title: 'Empty Workout',
        state: WorkoutState.RUNNING,
        timeElapsed: 0,
        created: DateTime.now(),
        completed: DateTime.now(),
      );
      _exercises = [];
      _elapsedSeconds = 0;
      _startStopwatch();
    } else {
      final potential = await repo.getWorkoutWithExercisesAndSets(widget.workoutId);
      if (potential != null) {
        if (potential.workout.state == WorkoutState.RUNNING) {
          // 2. Resuming running workout
          _workout = potential.workout;
          _exercises = List.from(potential.exercisesWithSets);
          _elapsedSeconds = _workout.timeElapsed;
          _startStopwatch();
        } else if (potential.workout.state == WorkoutState.ROUTINE) {
          // 3. Starting new workout from routine
          final now = DateTime.now();
          _workout = Workout(
            id: 0,
            routineId: potential.workout.id,
            notes: potential.workout.notes,
            title: potential.workout.title,
            state: WorkoutState.RUNNING,
            timeElapsed: 0,
            created: now,
            completed: now,
          );
          // Clone exercises & sets
          _exercises = potential.exercisesWithSets.map((eWs) {
            final clonedEx = eWs.exercise.copyWith(
              id: 0, // database will auto-increment
              workoutId: 0,
            );
            final clonedSets = eWs.sets.map((s) => s.copyWith(
              id: 0,
              exerciseId: 0,
              completed: false,
            )).toList();
            return ExerciseWithSets(
              exercise: clonedEx,
              exerciseDC: eWs.exerciseDC,
              sets: clonedSets,
            );
          }).toList();
          _elapsedSeconds = 0;
          _startStopwatch();
        }
      } else {
        // Fallback
        _initNewEmpty();
      }
    }

    // Fetch previous performances
    for (final eWs in _exercises) {
      final lastSets = await repo.getLastPerformanceSets(eWs.exerciseDC.id);
      _previousPerformances[eWs.exerciseDC.id] = lastSets;
    }

    setState(() {
      _isLoading = false;
    });

    // Save initial running state to DB to get a valid workout ID
    _saveProgressToDb();
  }

  void _initNewEmpty() {
    _workout = Workout(
      id: 0,
      routineId: 0,
      notes: '',
      title: 'Empty Workout',
      state: WorkoutState.RUNNING,
      timeElapsed: 0,
      created: DateTime.now(),
      completed: DateTime.now(),
    );
    _exercises = [];
    _elapsedSeconds = 0;
    _startStopwatch();
  }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
      // Save periodically
      if (_elapsedSeconds % 10 == 0) {
        _saveProgressToDb();
      }
    });
  }

  void _startRestTimer(int seconds) {
    if (seconds <= 0) return;
    _restTimer?.cancel();
    setState(() {
      _initialRestTime = seconds;
      _restSecondsRemaining = seconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining <= 1) {
        _restTimer?.cancel();
        setState(() {
          _restSecondsRemaining = 0;
          _initialRestTime = 0;
        });
        HapticFeedback.vibrate();
      } else {
        setState(() {
          _restSecondsRemaining--;
        });
      }
    });
  }

  void _modifyRestTime(bool addTenSeconds) {
    if (_restSecondsRemaining <= 0) return;
    setState(() {
      if (addTenSeconds) {
        _restSecondsRemaining += 10;
        if (_restSecondsRemaining > _initialRestTime) {
          _initialRestTime = _restSecondsRemaining;
        }
      } else {
        if (_restSecondsRemaining > 10) {
          _restSecondsRemaining -= 10;
        } else {
          _restSecondsRemaining = 0;
          _initialRestTime = 0;
          _restTimer?.cancel();
        }
      }
    });
  }

  void _startSetStopwatch(int setId) {
    _setStopwatchTimer?.cancel();
    setState(() {
      _idSetWithRunningStopwatch = setId;
    });
    _setStopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Find set and increment elapsed time
      bool found = false;
      for (int i = 0; i < _exercises.length; i++) {
        final eWs = _exercises[i];
        final setsList = List<WorkoutSet>.from(eWs.sets);
        final idx = setsList.indexWhere((s) => s.id == setId);
        if (idx != -1) {
          setsList[idx] = setsList[idx].copyWith(
            elapsedTime: setsList[idx].elapsedTime + 1,
          );
          _exercises[i] = eWs.copyWith(sets: setsList);
          found = true;
          break;
        }
      }
      if (!found) {
        _setStopwatchTimer?.cancel();
        setState(() {
          _idSetWithRunningStopwatch = null;
        });
      } else {
        setState(() {});
      }
    });
  }

  void _stopSetStopwatch() {
    _setStopwatchTimer?.cancel();
    setState(() {
      _idSetWithRunningStopwatch = null;
    });
  }

  Future<void> _saveProgressToDb() async {
    final repo = ref.read(workoutRepositoryProvider);
    final currentWorkout = _workout.copyWith(
      timeElapsed: _elapsedSeconds,
      state: WorkoutState.RUNNING,
    );

    final id = await repo.addWorkoutWithExercisesAndSets(
      WorkoutWithExercisesAndSets(
        workout: currentWorkout,
        exercisesWithSets: _exercises,
      ),
    );

    if (_workout.id != id) {
      _workout = _workout.copyWith(id: id);
    }
  }

  Future<void> _finishWorkout() async {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    _setStopwatchTimer?.cancel();

    final repo = ref.read(workoutRepositoryProvider);
    final completedWorkout = _workout.copyWith(
      timeElapsed: _elapsedSeconds,
      state: WorkoutState.COMPLETED,
      completed: DateTime.now(),
    );

    await repo.addWorkoutWithExercisesAndSets(
      WorkoutWithExercisesAndSets(
        workout: completedWorkout,
        exercisesWithSets: _exercises,
      ),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    _setStopwatchTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _addExercise(ExerciseDC dc) async {
    final repo = ref.read(workoutRepositoryProvider);
    final lastSets = await repo.getLastPerformanceSets(dc.id);
    setState(() {
      _previousPerformances[dc.id] = lastSets;
      final newEx = Exercise(
        id: DateTime.now().millisecondsSinceEpoch + _exercises.length, // local temp
        idExerciseDC: dc.id,
        notes: '',
        setMode: _defaultSetMode(dc),
        restTime: 90,
        position: _exercises.length,
        workoutId: _workout.id,
      );
      final newSet = WorkoutSet(
        id: DateTime.now().millisecondsSinceEpoch + _exercises.length + 1000,
        load: 0.0,
        reps: 0,
        elapsedTime: 0,
        completed: false,
        exerciseId: newEx.id,
      );

      _exercises.add(
        ExerciseWithSets(
          exercise: newEx,
          exerciseDC: dc,
          sets: [newSet],
        ),
      );
    });
    _saveProgressToDb();
  }

  SetMode _defaultSetMode(ExerciseDC dc) {
    if (dc.category == Category.STRETCHING || dc.category == Category.CARDIO) {
      return SetMode.DURATION;
    }
    if (dc.equipment == Equipment.BODY_ONLY ||
        dc.equipment == Equipment.FOAM_ROLL ||
        dc.equipment == Equipment.EXERCISE_BALL ||
        dc.equipment == Equipment.BANDS) {
      return SetMode.BODYWEIGHT;
    }
    return SetMode.LOAD;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final int completedSets = _exercises.fold(0, (sum, item) => sum + item.sets.where((s) => s.completed).length);
    final int totalSets = _exercises.fold(0, (sum, item) => sum + item.sets.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          if (_exercises.isNotEmpty)
            TextButton(
              onPressed: _finishWorkout,
              child: const Text(
                'DONE',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
            children: [
              // Header Card
              Card(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Completed sets: $completedSets/$totalSets',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'Elapsed time: ${_formatTime(_elapsedSeconds)}',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearWavyProgressIndicator(
                        value: totalSets > 0 ? (completedSets / totalSets) : 0.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Exercises List
              if (_exercises.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60.0),
                  child: Text(
                    'Your workout is empty. Tap Add Exercise below.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...List.generate(_exercises.length, (index) {
                  final eWs = _exercises[index];
                  return ExerciseCard(
                    exerciseWithSets: eWs,
                    workout: true,
                    previousPerformances: _previousPerformances[eWs.exerciseDC.id],
                    idSetWithRunningStopwatch: _idSetWithRunningStopwatch,
                    addSet: (exId) {
                      setState(() {
                        final setList = List<WorkoutSet>.from(eWs.sets);
                        final lastSet = setList.lastOrNull;
                        setList.add(
                          WorkoutSet(
                            id: DateTime.now().millisecondsSinceEpoch,
                            load: lastSet?.load ?? 0.0,
                            reps: lastSet?.reps ?? 0,
                            elapsedTime: lastSet?.elapsedTime ?? 0,
                            completed: false,
                            exerciseId: exId,
                          ),
                        );
                        _exercises[index] = eWs.copyWith(sets: setList);
                      });
                      _saveProgressToDb();
                    },
                    onDetail: (exId, dcId) {},
                    onDelete: (exId) {
                      setState(() {
                        _exercises.removeAt(index);
                      });
                      _saveProgressToDb();
                    },
                    deleteSet: (setId) {
                      setState(() {
                        final setList = eWs.sets.where((s) => s.id != setId).toList();
                        _exercises[index] = eWs.copyWith(sets: setList);
                      });
                      _saveProgressToDb();
                    },
                    updateExerciseNotes: (text, exId) {
                      _exercises[index] = eWs.copyWith(
                        exercise: eWs.exercise.copyWith(notes: text),
                      );
                    },
                    updateExerciseRestTime: (restTime, exId) {
                      _exercises[index] = eWs.copyWith(
                        exercise: eWs.exercise.copyWith(restTime: restTime),
                      );
                    },
                    updateExerciseSetMode: (setMode, exId) {
                      _exercises[index] = eWs.copyWith(
                        exercise: eWs.exercise.copyWith(setMode: setMode),
                      );
                    },
                    updateSetTime: (time, setId) {
                      _exercises[index] = eWs.copyWith(
                        sets: eWs.sets.map((s) => s.id == setId ? s.copyWith(elapsedTime: time) : s).toList(),
                      );
                    },
                    updateSetReps: (reps, setId) {
                      _exercises[index] = eWs.copyWith(
                        sets: eWs.sets.map((s) => s.id == setId ? s.copyWith(reps: reps) : s).toList(),
                      );
                    },
                    updateSetLoad: (load, setId) {
                      _exercises[index] = eWs.copyWith(
                        sets: eWs.sets.map((s) => s.id == setId ? s.copyWith(load: load) : s).toList(),
                      );
                    },
                    updateSetCompleted: (completed, setId) {
                      setState(() {
                        _exercises[index] = eWs.copyWith(
                          sets: eWs.sets.map((s) => s.id == setId ? s.copyWith(completed: completed) : s).toList(),
                        );
                      });
                      if (completed && eWs.exercise.restTime > 0) {
                        _startRestTimer(eWs.exercise.restTime);
                      }
                      _saveProgressToDb();
                    },
                    showInfo: (info) {},
                    updateIdSetWithRunningStopwatch: (setId) {
                      if (setId == 0) {
                        _stopSetStopwatch();
                      } else {
                        _startSetStopwatch(setId);
                      }
                    },
                    isFirst: index == 0,
                    isLast: index == _exercises.length - 1,
                    onMoveUp: (exId) {
                      if (index > 0) {
                        setState(() {
                          final item = _exercises.removeAt(index);
                          _exercises.insert(index - 1, item);
                        });
                        _saveProgressToDb();
                      }
                    },
                    onMoveDown: (exId) {
                      if (index < _exercises.length - 1) {
                        setState(() {
                          final item = _exercises.removeAt(index);
                          _exercises.insert(index + 1, item);
                        });
                        _saveProgressToDb();
                      }
                    },
                    onReplace: (exId) async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExercisesScreen(addExercises: false),
                        ),
                      );
                      if (result != null && result is List<ExerciseDC> && result.isNotEmpty) {
                        setState(() {
                          final replaced = _exercises[index].copyWith(
                            exerciseDC: result.first,
                            exercise: _exercises[index].exercise.copyWith(
                              idExerciseDC: result.first.id,
                            ),
                          );
                          _exercises[index] = replaced;
                        });
                        _saveProgressToDb();
                      }
                    },
                    onSupersetToggle: (exId) {
                      setState(() {
                        final curr = eWs.exercise.supersetId;
                        _exercises[index] = eWs.copyWith(
                          exercise: eWs.exercise.copyWith(
                            supersetId: Value(curr == null ? 1 : null),
                          ),
                        );
                      });
                      _saveProgressToDb();
                    },
                  );
                }),
            ],
          ),

          // Floating Action Bar / Rest timer bar at bottom
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_restSecondsRemaining > 0) ...[
                  _RestTimerPanel(
                    restSecondsRemaining: _restSecondsRemaining,
                    initialRestTime: _initialRestTime,
                    onIncrement: () => _modifyRestTime(true),
                    onDecrement: () => _modifyRestTime(false),
                  ),
                ],

                // + button (big)
                FloatingActionButton.extended(
                  heroTag: 'btn_add_ex_workout',
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExercisesScreen(addExercises: true),
                      ),
                    );
                    if (result != null && result is List<ExerciseDC>) {
                      for (final dc in result) {
                        await _addExercise(dc);
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add exercise'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension CoerceInt on int {
  int coerceAtLeast(int minVal) => this < minVal ? minVal : this;
}

class _RestTimerPanel extends StatefulWidget {
  final int restSecondsRemaining;
  final int initialRestTime;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _RestTimerPanel({
    required this.restSecondsRemaining,
    required this.initialRestTime,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  State<_RestTimerPanel> createState() => _RestTimerPanelState();
}

class _RestTimerPanelState extends State<_RestTimerPanel> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Horizontal adjustment buttons row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'btn_dec_rest',
              shape: const CircleBorder(),
              elevation: 2,
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              onPressed: widget.onDecrement,
              child: const Icon(Icons.remove, size: 18),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: 'btn_inc_rest',
              shape: const CircleBorder(),
              elevation: 2,
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              onPressed: widget.onIncrement,
              child: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Rest timer container — Pentagon background + wavy ring
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            // NO StackFit.expand — children get loose constraints so SizedBox works
            alignment: Alignment.center,
            children: [
              // Pentagon fills the full 180×180 via Positioned.fill
              Positioned.fill(
                child: RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      shape: const StarBorder(
                        points: 5,
                        innerRadiusRatio: 0.85,
                        pointRounding: 0.25,
                      ),
                    ),
                  ),
                ),
              ),

              // Wavy ring — change 140 here to shrink/grow vs 180px pentagon
              SizedBox(
                width: 100,
                height: 100,
                child: CircularWavyProgressIndicator(
                  key: const ValueKey('rest_timer_indicator'),
                  value: widget.initialRestTime > 0
                      ? widget.restSecondsRemaining / widget.initialRestTime
                      : 0.0,
                  color: theme.colorScheme.onSecondaryContainer,
                  backgroundColor: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.12),
                  strokeWidth: 4.5,
                  waveHeight: 1.5,
                  waveCount: 9,
                ),
              ),

              // Centered text (non-rotating)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'REST',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${widget.restSecondsRemaining}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
