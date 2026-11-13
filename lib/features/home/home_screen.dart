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
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/workout_providers.dart';
import '../../core/providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<Color?> _borderColorAnimation;

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

    final byId = {for (final item in routines) item.workout.id: item};
    final ordered = <WorkoutWithExercisesAndSets>[];
    for (final id in _localOrderIds) {
      final item = byId.remove(id);
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

    var targetIndex = newIndex;
    if (targetIndex > oldIndex) targetIndex -= 1;
    if (targetIndex == oldIndex) return;

    final reordered = List<WorkoutWithExercisesAndSets>.of(routines);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(targetIndex, moved);

    setState(() {
      _localOrderIds = reordered.map((item) => item.workout.id).toList();
    });

    await ref
        .read(workoutRepositoryProvider)
        .updateRoutinePositions(reordered.map((item) => item.workout).toList());
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    _borderColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: theme.colorScheme.secondary.withValues(alpha: 0.8),
    ).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showDiscardDialog(Workout workout) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.discardRunningWorkoutTitle),
          content: Text(l10n.discardWorkoutMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final nav = Navigator.of(dialogCtx);
                final repo = ref.read(workoutRepositoryProvider);
                await repo.deleteWorkout(workout);
                if (mounted) nav.pop();
              },
              child: Text(
                l10n.discard,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDiscardAndStartRoutineDialog(Workout running, int routineId) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.discardRunningWorkoutTitle),
          content: Text(l10n.discardWorkoutAndStartRoutineMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final nav = Navigator.of(dialogCtx);
                final repo = ref.read(workoutRepositoryProvider);
                await repo.deleteWorkout(running);
                if (mounted) {
                  nav.pop();
                  nav.pushNamed('/workout', arguments: routineId);
                }
              },
              child: Text(
                l10n.discardAndStart,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final routinesAsync = ref.watch(routinesProvider);
    final runningWorkoutAsync = ref.watch(runningWorkoutProvider);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1. Running Workout Card
        runningWorkoutAsync.when(
          data: (runningWorkout) {
            final hasRunning = runningWorkout != null;
            if (!hasRunning) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 24,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/workout', arguments: 0);
                  },
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: Text(l10n.startEmptyWorkout),
                ),
              );
            }
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _borderColorAnimation.value ?? Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/workout',
                                arguments: runningWorkout.workout.id,
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l10n.resumeWorkout),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.elapsedTime(
                                  _formatTime(
                                    runningWorkout.workout.timeElapsed,
                                  ),
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _showDiscardDialog(runningWorkout.workout),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(l10n.errorLoadingActiveWorkout('$err')),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.yourRoutines,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton.filledTonal(
              icon: Icon(
                Icons.auto_awesome,
                color: ref.watch(settingsProvider).aiWorkoutGenerationEnabled
                    ? null
                    : theme.disabledColor,
              ),
              tooltip: ref.watch(settingsProvider).aiWorkoutGenerationEnabled
                  ? l10n.aiWorkoutCreator
                  : l10n.aiWorkoutCreatorDisabled,
              onPressed: () {
                if (ref.read(settingsProvider).aiWorkoutGenerationEnabled) {
                  Navigator.pushNamed(context, '/workout/ai-chat');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.aiWorkoutGenerationDisabled),
                      action: SnackBarAction(
                        label: l10n.settingsTitle,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Routines List
        routinesAsync.when(
          data: (routines) {
            if (routines.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  l10n.startByCreatingRoutine,
                  textAlign: TextAlign.center,
                ),
              );
            }

            final orderedRoutines = _applyLocalOrder(routines);

            return ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: orderedRoutines.length,
              onReorder: (oldIndex, newIndex) =>
                  _reorderRoutines(orderedRoutines, oldIndex, newIndex),
              itemBuilder: (context, index) {
                final routine = orderedRoutines[index].workout;
                return Padding(
                  key: ValueKey(routine.id),
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/info-workout',
                          arguments: routine.id,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    routine.title,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (routine.isTemporal) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ],
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Tooltip(
                                    message: l10n.dragToReorder,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.drag_handle,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onSecondaryContainer,
                              ),
                              onPressed: () {
                                final running = runningWorkoutAsync.value;
                                if (running != null) {
                                  _showDiscardAndStartRoutineDialog(
                                    running.workout,
                                    routine.id,
                                  );
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    '/workout',
                                    arguments: routine.id,
                                  );
                                }
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: Text(l10n.startRoutine),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(l10n.errorLoadingRoutines('$err')),
          ),
        ),
      ],
    );
  }
}
