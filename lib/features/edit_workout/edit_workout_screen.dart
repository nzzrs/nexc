/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../exercises/exercises_screen.dart';
import '../../core/db/app_database.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/components/exercise_card.dart';

class EditWorkoutScreen extends ConsumerStatefulWidget {
  final int workoutId; // 0 if new routine

  const EditWorkoutScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  bool _isLoading = true;
  late Workout _workout;
  List<ExerciseWithSets> _exercises = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    final repo = ref.read(workoutRepositoryProvider);
    if (widget.workoutId != 0) {
      final data = await repo.getWorkoutWithExercisesAndSets(widget.workoutId);
      if (data != null) {
        _workout = data.workout;
        _exercises = List.from(data.exercisesWithSets);
        _titleController.text = _workout.title;
        _notesController.text = _workout.notes;
      } else {
        _initNewWorkout();
      }
    } else {
      _initNewWorkout();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _initNewWorkout() {
    _workout = Workout(
      id: 0,
      routineId: 0,
      notes: '',
      title: '',
      state: WorkoutState.ROUTINE,
      timeElapsed: 0,
      created: DateTime.now(),
      completed: DateTime.now(),
    );
    _exercises = [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a routine title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final repo = ref.read(workoutRepositoryProvider);
    final updatedWorkout = _workout.copyWith(
      title: _titleController.text.trim(),
      notes: _notesController.text.trim(),
      state: WorkoutState.ROUTINE,
    );

    // Save/update routine in database
    await repo.addWorkoutWithExercisesAndSets(
      WorkoutWithExercisesAndSets(
        workout: updatedWorkout,
        exercisesWithSets: _exercises,
      ),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _addExercise(ExerciseDC dc) {
    setState(() {
      final newEx = Exercise(
        id: DateTime.now().millisecondsSinceEpoch + _exercises.length, // local temp id
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutId == 0 ? 'Create Routine' : 'Edit Routine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Routine details Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Routine title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Routine notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Routine Exercises Header
          Text(
            'Exercises',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (_exercises.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'No exercises added yet. Tap Add Exercise below.',
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            ...List.generate(_exercises.length, (index) {
              final eWs = _exercises[index];
              return ExerciseCard(
                exerciseWithSets: eWs,
                workout: false,
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
                },
                onDetail: (exId, dcId) {},
                onDelete: (exId) {
                  setState(() {
                    _exercises.removeAt(index);
                  });
                },
                deleteSet: (setId) {
                  setState(() {
                    final setList = eWs.sets.where((s) => s.id != setId).toList();
                    _exercises[index] = eWs.copyWith(sets: setList);
                  });
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
                updateSetCompleted: (completed, setId) {},
                showInfo: (info) {},
                isFirst: index == 0,
                isLast: index == _exercises.length - 1,
                onMoveUp: (exId) {
                  if (index > 0) {
                    setState(() {
                      final item = _exercises.removeAt(index);
                      _exercises.insert(index - 1, item);
                    });
                  }
                },
                onMoveDown: (exId) {
                  if (index < _exercises.length - 1) {
                    setState(() {
                      final item = _exercises.removeAt(index);
                      _exercises.insert(index + 1, item);
                    });
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
                },
              );
            }),
          ],
          const SizedBox(height: 12),

          // Add Exercise Button
          OutlinedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExercisesScreen(addExercises: true),
                ),
              );
              if (result != null && result is List<ExerciseDC>) {
                for (final dc in result) {
                  _addExercise(dc);
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
          ),
        ],
      ),
    );
  }
}
