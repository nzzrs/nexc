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
import '../../core/db/app_database.dart';
import '../../core/db/workout_repository.dart';
import '../../core/providers/workout_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<Color?> _borderColorAnimation;

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
      end: theme.colorScheme.secondary.withOpacity(0.8),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard running workout?'),
          content: const Text(
            'Are you sure you want to discard this unsaved, ongoing workout? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final repo = ref.read(workoutRepositoryProvider);
                await repo.deleteWorkout(workout);
                if (mounted) Navigator.pop(context);
              },
              child: const Text(
                'Discard',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDiscardAndStartRoutineDialog(Workout running, int routineId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard running workout?'),
          content: const Text(
            'Are you sure you want to discard this unsaved, ongoing workout and start this routine instead? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final repo = ref.read(workoutRepositoryProvider);
                await repo.deleteWorkout(running);
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/workout', arguments: routineId);
                }
              },
              child: const Text(
                'Discard & Start',
                style: TextStyle(color: Colors.red),
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
    final routinesAsync = ref.watch(routinesProvider);
    final runningWorkoutAsync = ref.watch(runningWorkoutProvider);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1. Running Workout Card
        runningWorkoutAsync.when(
          data: (runningWorkout) {
            final hasRunning = runningWorkout != null;
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasRunning ? (_borderColorAnimation.value ?? Colors.transparent) : Colors.transparent,
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
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/workout',
                                arguments: hasRunning ? runningWorkout.workout.id : 0,
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              hasRunning ? 'Resume workout' : 'Start empty workout',
                            ),
                          ),
                          if (hasRunning) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Elapsed time: ${_formatTime(runningWorkout.workout.timeElapsed)}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _showDiscardDialog(runningWorkout.workout),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading active workout: $err'),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. Your Routines Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your routines',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                Navigator.pushNamed(context, '/tutorial');
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Routines List
        routinesAsync.when(
          data: (routines) {
            if (routines.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'Start by creating a new routine',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: routines.map((item) {
                final routine = item.workout;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
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
                                  routine.title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/info-workout',
                                    arguments: routine.id,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondaryContainer,
                              foregroundColor: theme.colorScheme.onSecondaryContainer,
                            ),
                            onPressed: () {
                              final running = runningWorkoutAsync.value;
                              if (running != null) {
                                _showDiscardAndStartRoutineDialog(running.workout, routine.id);
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  '/workout',
                                  arguments: routine.id,
                                );
                              }
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start routine'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading routines: $err'),
          ),
        ),
      ],
    );
  }
}
