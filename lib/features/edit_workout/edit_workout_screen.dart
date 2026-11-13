/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/exercise_card.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_page.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/exercise_set_mode_helper.dart';
import '../../l10n/app_localizations.dart';
import '../exercises/exercises_screen.dart';

/// Toggles the superset group of [index] in [exercises].
///
/// Linking joins the previous exercise's group when it has one. Otherwise it
/// starts a brand-new group after the highest id currently in use, so a
/// routine with existing supersets never collapses everything into group 1.
List<ExerciseWithSets> toggleSupersetGroup(
  List<ExerciseWithSets> exercises,
  int index,
) {
  if (index < 0 || index >= exercises.length) return exercises;
  final List<ExerciseWithSets> updated = List<ExerciseWithSets>.of(exercises);
  final ExerciseWithSets current = updated[index];
  final int? currentGroup = current.exercise.supersetId;

  if (currentGroup != null) {
    updated[index] = current.copyWith(
      exercise: current.exercise.copyWith(supersetId: const Value<int?>(null)),
    );
    return updated;
  }

  if (index == 0) return updated;

  final ExerciseWithSets previous = updated[index - 1];
  final int? previousGroup = previous.exercise.supersetId;
  final int groupId;
  if (previousGroup != null) {
    groupId = previousGroup;
  } else {
    final int maxId = updated
        .map((ExerciseWithSets exercise) => exercise.exercise.supersetId)
        .whereType<int>()
        .fold<int>(0, (int max, int value) => value > max ? value : max);
    groupId = maxId + 1;
    updated[index - 1] = previous.copyWith(
      exercise: previous.exercise.copyWith(supersetId: Value<int?>(groupId)),
    );
  }
  updated[index] = current.copyWith(
    exercise: current.exercise.copyWith(supersetId: Value<int?>(groupId)),
  );
  return updated;
}

class EditWorkoutScreen extends ConsumerStatefulWidget {
  final int workoutId; // 0 if new routine

  const EditWorkoutScreen({super.key, required this.workoutId});

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isReordering = false;
  late Workout _workout;
  List<ExerciseWithSets> _exercises = <ExerciseWithSets>[];

  String _initialTitle = '';
  String _initialNotes = '';
  List<ExerciseWithSets> _initialExercises = <ExerciseWithSets>[];
  String? _titleError;
  String? _saveError;

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
        _exercises = List<ExerciseWithSets>.from(data.exercisesWithSets);
        _titleController.text = _workout.title;
        _notesController.text = _workout.notes;
        _initialTitle = _workout.title;
        _initialNotes = _workout.notes;
        _initialExercises = _exercises
            .map((ExerciseWithSets e) => e.copyWith())
            .toList();
      } else {
        _initNewWorkout();
      }
    } else {
      _initNewWorkout();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initNewWorkout() {
    _workout = Workout(
      id: 0,
      routineId: 0,
      notes: '',
      title: '',
      state: WorkoutState.ROUTINE,
      timeElapsed: 0,
      position: 0,
      created: DateTime.now(),
      completed: DateTime.now(),
      isTemporal: false,
    );
    _exercises = <ExerciseWithSets>[];
    _initialTitle = '';
    _initialNotes = '';
    _initialExercises = <ExerciseWithSets>[];
  }

  bool _hasChanges() {
    if (widget.workoutId == 0) {
      final bool hasTitle = _titleController.text.trim().isNotEmpty;
      final bool hasNotes = _notesController.text.trim().isNotEmpty;
      final bool hasExercises = _exercises.isNotEmpty;
      return hasTitle || hasNotes || hasExercises;
    }
    if (_titleController.text != _initialTitle) return true;
    if (_notesController.text != _initialNotes) return true;
    if (_exercises.length != _initialExercises.length) return true;
    for (int i = 0; i < _exercises.length; i++) {
      final ExerciseWithSets current = _exercises[i];
      final ExerciseWithSets initial = _initialExercises[i];
      if (current.exercise.exerciseDataId != initial.exercise.exerciseDataId) {
        return true;
      }
      if (current.exercise.notes != initial.exercise.notes) return true;
      if (current.exercise.restTime != initial.exercise.restTime) return true;
      if (current.exercise.setMode != initial.exercise.setMode) return true;
      if (current.exercise.supersetId != initial.exercise.supersetId) {
        return true;
      }
      if (current.sets.length != initial.sets.length) return true;
      for (int j = 0; j < current.sets.length; j++) {
        final WorkoutSet currentSet = current.sets[j];
        final WorkoutSet initialSet = initial.sets[j];
        if (currentSet.load != initialSet.load ||
            currentSet.reps != initialSet.reps ||
            currentSet.elapsedTime != initialSet.elapsedTime ||
            currentSet.completed != initialSet.completed) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _handlePop() async {
    if (!_hasChanges()) {
      Navigator.pop(context);
      return;
    }

    final AppLocalizations l10n = context.l10n;
    final bool? result = await NexcConfirmSheet.show(
      context: context,
      title: l10n.discardChangesTitle,
      message: l10n.discardChangesMessage,
      confirmLabel: l10n.discardAction,
      secondaryLabel: l10n.saveAction,
      cancelLabel: l10n.cancel,
    );

    if (result == true) {
      if (mounted) Navigator.pop(context);
    } else if (result == false) {
      await _save();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final AppLocalizations l10n = context.l10n;
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = l10n.titleCannotBeEmpty;
        _saveError = null;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _titleError = null;
      _saveError = null;
    });

    try {
      final Workout updatedWorkout = _workout.copyWith(
        title: title,
        notes: _notesController.text.trim(),
        state: WorkoutState.ROUTINE,
      );
      await ref
          .read(workoutRepositoryProvider)
          .addWorkoutWithExercisesAndSets(
            WorkoutWithExercisesAndSets(
              workout: updatedWorkout,
              exercisesWithSets: _exercises,
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saveError = l10n.failedToSaveRoutine('$error');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _addExercise(ExerciseDataDC dc) async {
    final repo = ref.read(workoutRepositoryProvider);
    final SetMode? storedMode = await repo.getLastSetModeForExercise(dc.id);
    final SetMode initialSetMode = storedMode ?? _defaultSetMode(dc);
    if (!mounted) return;
    setState(() {
      final Exercise newEx = Exercise(
        id: DateTime.now().millisecondsSinceEpoch + _exercises.length,
        exerciseDataId: dc.id,
        notes: '',
        setMode: initialSetMode,
        restTime: 90,
        position: _exercises.length,
        workoutId: _workout.id,
      );
      final WorkoutSet newSet = WorkoutSet(
        id: DateTime.now().millisecondsSinceEpoch + _exercises.length + 1000,
        load: 0.0,
        weightUnit: WeightUnit.kg,
        reps: 0,
        elapsedTime: 0,
        completed: false,
        setType: SetType.NORMAL,
        exerciseId: newEx.id,
      );
      _exercises.add(
        ExerciseWithSets(
          exercise: newEx,
          exerciseDC: dc,
          sets: <WorkoutSet>[newSet],
        ),
      );
    });
  }

  Future<void> _pickExercises() async {
    final dynamic result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) =>
            const ExercisesScreen(addExercises: true),
      ),
    );
    if (!mounted) return;
    if (result is List<ExerciseDataDC>) {
      for (final ExerciseDataDC dc in result) {
        await _addExercise(dc);
      }
    }
  }

  SetMode _defaultSetMode(ExerciseDataDC dc) => defaultSetModeForExercise(dc);

  void _onReorder(int oldIndex, int newIndex) {
    int to = newIndex;
    if (to > oldIndex) to -= 1;
    if (oldIndex < 0 || oldIndex >= _exercises.length) return;
    to = to.clamp(0, _exercises.length - 1);
    setState(() {
      final ExerciseWithSets item = _exercises.removeAt(oldIndex);
      _exercises.insert(to, item);
      for (int i = 0; i < _exercises.length; i++) {
        _exercises[i] = _exercises[i].copyWith(
          exercise: _exercises[i].exercise.copyWith(position: i),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        await _handlePop();
      },
      child: NexcPage(
        title: widget.workoutId == 0
            ? l10n.createRoutineTitle
            : l10n.editRoutineTitle,
        actions: <Widget>[
          if (_exercises.isNotEmpty)
            IconButton(
              tooltip: _isReordering
                  ? l10n.doneReordering
                  : l10n.reorderExercises,
              icon: Icon(_isReordering ? NexcIcons.check : NexcIcons.sort),
              onPressed: () {
                setState(() {
                  _isReordering = !_isReordering;
                });
              },
            ),
        ],
        bottomBar: FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.saveAction),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                NexcSpacing.lg,
                NexcSpacing.sm,
                NexcSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _DetailsCard(
                  titleController: _titleController,
                  notesController: _notesController,
                  titleError: _titleError,
                  onTitleChanged: () {
                    if (_titleError != null) {
                      setState(() => _titleError = null);
                    }
                  },
                ),
              ),
            ),
            if (_saveError != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  NexcSpacing.lg,
                  NexcSpacing.md,
                  NexcSpacing.lg,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(NexcSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: NexcShapes.mdRadius,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          NexcIcons.warning,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: NexcSpacing.sm),
                        Expanded(
                          child: Text(
                            _saveError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                NexcSpacing.lg,
                NexcSpacing.xl,
                NexcSpacing.lg,
                NexcSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.exercisesLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (_exercises.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: NexcSpacing.xxl,
                    ),
                    child: Text(
                      l10n.noExercisesAdded,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
                sliver: SliverReorderableList(
                  itemCount: _exercises.length,
                  onReorder: _onReorder,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildExerciseCard(context, index, l10n);
                  },
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                NexcSpacing.lg,
                NexcSpacing.sm,
                NexcSpacing.lg,
                NexcSpacing.xxl,
              ),
              sliver: SliverToBoxAdapter(
                child: OutlinedButton.icon(
                  onPressed: _pickExercises,
                  icon: const Icon(NexcIcons.add),
                  label: Text(l10n.addExerciseTitle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    int index,
    AppLocalizations l10n,
  ) {
    final ExerciseWithSets eWs = _exercises[index];
    return ExerciseCard(
      key: ValueKey<String>('routine_ex_${eWs.exercise.id}'),
      index: index,
      exerciseWithSets: eWs,
      workout: false,
      isReordering: _isReordering,
      addSet: (int exId) {
        setState(() {
          final List<WorkoutSet> setList = List<WorkoutSet>.from(eWs.sets);
          final WorkoutSet? lastSet = setList.lastOrNull;
          setList.add(
            WorkoutSet(
              id: DateTime.now().millisecondsSinceEpoch,
              load: lastSet?.load ?? 0.0,
              weightUnit: WeightUnit.kg,
              reps: lastSet?.reps ?? 0,
              elapsedTime: lastSet?.elapsedTime ?? 0,
              completed: false,
              setType: lastSet?.setType ?? SetType.NORMAL,
              exerciseId: exId,
            ),
          );
          _exercises[index] = eWs.copyWith(sets: setList);
        });
      },
      onDetail: (int exId, String dcId) {
        Navigator.pushNamed(context, '/exercises/info', arguments: dcId);
      },
      onDelete: (int exId) {
        setState(() {
          _exercises.removeAt(index);
        });
      },
      deleteSet: (int setId) {
        setState(() {
          final List<WorkoutSet> setList = eWs.sets
              .where((WorkoutSet s) => s.id != setId)
              .toList();
          _exercises[index] = eWs.copyWith(sets: setList);
        });
      },
      updateExerciseNotes: (String text, int exId) {
        setState(() {
          _exercises[index] = eWs.copyWith(
            exercise: eWs.exercise.copyWith(notes: text),
          );
        });
      },
      updateExerciseRestTime: (int restTime, int exId) {
        setState(() {
          _exercises[index] = eWs.copyWith(
            exercise: eWs.exercise.copyWith(restTime: restTime),
          );
        });
      },
      updateExerciseSetMode: (SetMode setMode, int exId) {
        setState(() {
          _exercises[index] = eWs.copyWith(
            exercise: eWs.exercise.copyWith(setMode: setMode),
          );
        });
      },
      updateSetTime: (int time, int setId) {
        setState(() {
          _exercises[index] = eWs.copyWith(
            sets: eWs.sets
                .map(
                  (WorkoutSet s) =>
                      s.id == setId ? s.copyWith(elapsedTime: time) : s,
                )
                .toList(),
          );
        });
      },
      updateSetReps: (int reps, int setId) {
        setState(() {
          _exercises[index] = eWs.copyWith(
            sets: eWs.sets
                .map(
                  (WorkoutSet s) => s.id == setId ? s.copyWith(reps: reps) : s,
                )
                .toList(),
          );
        });
      },
      updateSetLoad: (double load, int setId) {
        setState(() {
          _exercises[index] = eWs.copyWith(
            sets: eWs.sets
                .map(
                  (WorkoutSet s) => s.id == setId ? s.copyWith(load: load) : s,
                )
                .toList(),
          );
        });
      },
      updateSetCompleted: (bool completed, int setId) {},
      onReplace: (int exId) async {
        final dynamic result = await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => ExercisesScreen(
              addExercises: false,
              targetExerciseToReplace: _exercises[index].exerciseDC,
            ),
          ),
        );
        if (result is List<ExerciseDataDC> && result.isNotEmpty) {
          final ExerciseDataDC newDC = result.first;
          final SetMode? storedMode = await ref
              .read(workoutRepositoryProvider)
              .getLastSetModeForExercise(newDC.id);
          final SetMode initialSetMode = storedMode ?? _defaultSetMode(newDC);
          if (!mounted) return;
          setState(() {
            _exercises[index] = _exercises[index].copyWith(
              exerciseDC: newDC,
              exercise: _exercises[index].exercise.copyWith(
                exerciseDataId: newDC.id,
                setMode: initialSetMode,
              ),
            );
          });
        }
      },
      onSupersetToggle: (int exId) {
        setState(() {
          _exercises = toggleSupersetGroup(_exercises, index);
        });
      },
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController notesController;
  final String? titleError;
  final VoidCallback onTitleChanged;

  const _DetailsCard({
    required this.titleController,
    required this.notesController,
    required this.titleError,
    required this.onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(NexcSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: NexcShapes.lgRadius,
      ),
      child: Column(
        children: <Widget>[
          TextField(
            controller: titleController,
            onChanged: (_) => onTitleChanged(),
            decoration: InputDecoration(
              labelText: l10n.routineTitleField,
              errorText: titleError,
            ),
          ),
          const SizedBox(height: NexcSpacing.md),
          TextField(
            controller: notesController,
            decoration: InputDecoration(labelText: l10n.routineNotesField),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
