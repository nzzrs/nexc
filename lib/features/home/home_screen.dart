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

import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/workout_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';

/// Workout tab: active session hero plus the routine library.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Routine ids in the order last dropped by the user.
  ///
  /// The database stream stays the source of truth for routine contents; this
  /// only keeps the visual order stable between the drop and the database
  /// emitting the persisted positions, which avoids a flicker.
  List<int> _localOrderIds = const [];

  List<WorkoutWithExercisesAndSets> _applyLocalOrder(
    List<WorkoutWithExercisesAndSets> routines,
  ) {
    if (_localOrderIds.isEmpty) return routines;

    final Map<int, WorkoutWithExercisesAndSets> byId = {
      for (final WorkoutWithExercisesAndSets item in routines)
        item.workout.id: item,
    };
    final List<WorkoutWithExercisesAndSets> ordered =
        <WorkoutWithExercisesAndSets>[];
    for (final int id in _localOrderIds) {
      final WorkoutWithExercisesAndSets? item = byId.remove(id);
      if (item != null) ordered.add(item);
    }
    ordered.addAll(byId.values);
    return ordered;
  }

  Future<void> _reorderRoutines(
    List<WorkoutWithExercisesAndSets> routines,
    int oldIndex,
    int newIndex,
  ) async {
    if (routines.length < 2) return;

    int targetIndex = newIndex;
    if (targetIndex > oldIndex) targetIndex -= 1;
    if (targetIndex == oldIndex) return;

    final List<WorkoutWithExercisesAndSets> reordered =
        List<WorkoutWithExercisesAndSets>.of(routines);
    final WorkoutWithExercisesAndSets moved = reordered.removeAt(oldIndex);
    reordered.insert(targetIndex, moved);

    setState(() {
      _localOrderIds = reordered
          .map((WorkoutWithExercisesAndSets item) => item.workout.id)
          .toList();
    });

    await ref
        .read(workoutRepositoryProvider)
        .updateRoutinePositions(
          reordered
              .map((WorkoutWithExercisesAndSets item) => item.workout)
              .toList(),
        );
  }

  void _createRoutine() {
    Navigator.pushNamed(context, '/edit-workout', arguments: 0);
  }

  Future<bool> _confirmDiscard({required String message}) async {
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: context.l10n.discardRunningWorkoutTitle,
      message: message,
      confirmLabel: context.l10n.discard,
      cancelLabel: context.l10n.cancel,
      destructive: true,
    );
    return confirmed ?? false;
  }

  Future<void> _discardWorkout(Workout workout) async {
    final bool confirmed = await _confirmDiscard(
      message: context.l10n.discardWorkoutMessage,
    );
    if (!confirmed || !mounted) return;
    await ref.read(workoutRepositoryProvider).deleteWorkout(workout);
  }

  Future<void> _startRoutine(Workout routine, Workout? running) async {
    if (running != null) {
      final bool confirmed = await _confirmDiscard(
        message: context.l10n.discardWorkoutAndStartRoutineMessage,
      );
      if (!confirmed || !mounted) return;
      await ref.read(workoutRepositoryProvider).deleteWorkout(running);
      if (!mounted) return;
    }
    if (!mounted) return;
    Navigator.pushNamed(context, '/workout', arguments: routine.id);
  }

  Future<void> _deleteRoutine(Workout routine) async {
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: context.l10n.deleteRoutineTitle,
      message: context.l10n.deleteRoutineMessage,
      confirmLabel: context.l10n.delete,
      cancelLabel: context.l10n.cancel,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(workoutRepositoryProvider).deleteWorkout(routine);
  }

  void _openRoutine(Workout routine) {
    Navigator.pushNamed(context, '/info-workout', arguments: routine.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final AsyncValue<WorkoutWithExercisesAndSets?> runningAsync = ref.watch(
      runningWorkoutProvider,
    );
    final AsyncValue<List<WorkoutWithExercisesAndSets>> routinesAsync = ref
        .watch(routinesProvider);
    final bool aiEnabled = ref
        .watch(settingsProvider)
        .aiWorkoutGenerationEnabled;
    final Workout? running = runningAsync.value?.workout;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        NexcSpacing.lg,
        NexcSpacing.md,
        NexcSpacing.lg,
        NexcSpacing.section * 2,
      ),
      children: [
        runningAsync.when(
          data: (WorkoutWithExercisesAndSets? workout) {
            if (workout == null) {
              return FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/workout', arguments: 0);
                },
                icon: const Icon(NexcIcons.play),
                label: Text(l10n.startEmptyWorkout),
              );
            }
            return _ActiveWorkoutCard(
              workout: workout,
              onResume: () {
                Navigator.pushNamed(
                  context,
                  '/workout',
                  arguments: workout.workout.id,
                );
              },
              onDiscard: () => _discardWorkout(workout.workout),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(NexcSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (Object error, StackTrace stack) => Text(
            l10n.errorLoadingActiveWorkout('$error'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        const SizedBox(height: NexcSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.yourRoutines,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Tooltip(
              message: aiEnabled
                  ? l10n.aiWorkoutCreator
                  : l10n.aiWorkoutCreatorDisabled,
              child: IconButton.filledTonal(
                icon: const Icon(NexcIcons.ai),
                onPressed: aiEnabled
                    ? () => Navigator.pushNamed(context, '/workout/ai-chat')
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: NexcSpacing.md),
        routinesAsync.when(
          data: (List<WorkoutWithExercisesAndSets> routines) {
            if (routines.isEmpty) {
              return NexcEmptyState(
                icon: NexcIcons.workoutIdle,
                title: l10n.emptyRoutinesTitle,
                message: l10n.emptyRoutinesMessage,
                actionLabel: l10n.createRoutine,
                onAction: _createRoutine,
              );
            }

            final List<WorkoutWithExercisesAndSets> orderedRoutines =
                _applyLocalOrder(routines);

            return ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: orderedRoutines.length,
              onReorder: (int oldIndex, int newIndex) =>
                  _reorderRoutines(orderedRoutines, oldIndex, newIndex),
              itemBuilder: (BuildContext context, int index) {
                final WorkoutWithExercisesAndSets item = orderedRoutines[index];
                return Padding(
                  key: ValueKey<int>(item.workout.id),
                  padding: const EdgeInsets.only(bottom: NexcSpacing.sm),
                  child: _RoutineCard(
                    routine: item,
                    index: index,
                    onOpen: () => _openRoutine(item.workout),
                    onStart: () => _startRoutine(item.workout, running),
                    onDelete: () => _deleteRoutine(item.workout),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(NexcSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (Object error, StackTrace stack) => Text(
            l10n.errorLoadingRoutines('$error'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact hero shown while a session is running.
class _ActiveWorkoutCard extends StatelessWidget {
  final WorkoutWithExercisesAndSets workout;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  const _ActiveWorkoutCard({
    required this.workout,
    required this.onResume,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;

    return Material(
      color: theme.colorScheme.secondaryContainer,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.lgRadius),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        workout.workout.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: NexcSpacing.xs),
                      Text(
                        l10n.elapsedTime(
                          formatClock(workout.workout.timeElapsed),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  icon: Icon(
                    NexcIcons.more,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  onSelected: (String value) {
                    if (value == 'discard') onDiscard();
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'discard',
                      child: Row(
                        children: [
                          Icon(
                            NexcIcons.delete,
                            size: 20,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: NexcSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.discard,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: NexcSpacing.md),
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(NexcIcons.play),
              label: Text(l10n.resumeWorkout),
            ),
          ],
        ),
      ),
    );
  }
}

enum _RoutineMenuAction { open, delete }

/// Routine row with reorder handle, tonal play action and overflow menu.
class _RoutineCard extends StatelessWidget {
  final WorkoutWithExercisesAndSets routine;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onStart;
  final VoidCallback onDelete;

  const _RoutineCard({
    required this.routine,
    required this.index,
    required this.onOpen,
    required this.onStart,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final int exerciseCount = routine.exercisesWithSets.length;
    final String exerciseLabel = exerciseCount == 1
        ? l10n.exerciseNoun
        : l10n.exercisesNoun;

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.lgRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            NexcSpacing.sm,
            NexcSpacing.md,
            NexcSpacing.xs,
            NexcSpacing.md,
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Tooltip(
                  message: l10n.dragToReorder,
                  child: Padding(
                    padding: const EdgeInsets.all(NexcSpacing.sm),
                    child: Icon(
                      NexcIcons.drag,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      routine.workout.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: NexcSpacing.xs),
                    Text(
                      '$exerciseCount $exerciseLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: l10n.startRoutine,
                onPressed: onStart,
                icon: const Icon(NexcIcons.play),
              ),
              PopupMenuButton<_RoutineMenuAction>(
                tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                icon: Icon(
                  NexcIcons.more,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onSelected: (_RoutineMenuAction action) {
                  switch (action) {
                    case _RoutineMenuAction.open:
                      onOpen();
                    case _RoutineMenuAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<_RoutineMenuAction>(
                    value: _RoutineMenuAction.open,
                    child: Text(l10n.openThisRoutine),
                  ),
                  PopupMenuItem<_RoutineMenuAction>(
                    value: _RoutineMenuAction.delete,
                    child: Row(
                      children: [
                        Icon(
                          NexcIcons.delete,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: NexcSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.delete,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
