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
import 'package:table_calendar/table_calendar.dart';
import '../../core/db/relations.dart';
import '../../core/db/enums.dart';
import '../../core/db/workout_repository.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<WorkoutWithExercisesAndSets> _allWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final repo = ref.read(workoutRepositoryProvider);
    // Watch completed workouts stream
    repo.watchWorkoutsWithExercisesAndSetsByState(WorkoutState.COMPLETED).listen((workouts) {
      if (mounted) {
        setState(() {
          _allWorkouts = workouts;
          _isLoading = false;
        });
      }
    });
  }

  List<WorkoutWithExercisesAndSets> _getWorkoutsForDay(DateTime day) {
    return _allWorkouts.where((w) {
      final d = w.workout.completed;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedWorkouts = _selectedDay != null ? _getWorkoutsForDay(_selectedDay!) : [];
    final todayWorkouts = _getWorkoutsForDay(DateTime.now());

    // Build a set of days that have workouts
    final workoutDays = <DateTime>{};
    for (final w in _allWorkouts) {
      final d = w.workout.completed;
      workoutDays.add(DateTime(d.year, d.month, d.day));
    }

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TableCalendar<WorkoutWithExercisesAndSets>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getWorkoutsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      formatButtonTextStyle: theme.textTheme.labelSmall!,
                    ),
                  ),
                ),
              ),

              // Divider
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        _selectedDay != null
                            ? _formatDate(_selectedDay!)
                            : 'Select a day to view workouts',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedDay != null) ...[
                        const Spacer(),
                        Text(
                          '${selectedWorkouts.length} workout${selectedWorkouts.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Workout list for selected day
              if (_selectedDay != null && selectedWorkouts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Rest day — no workouts logged',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final w = (selectedWorkouts.isNotEmpty
                          ? selectedWorkouts
                          : todayWorkouts)[index];
                      return _WorkoutSummaryCard(workout: w);
                    },
                    childCount: selectedWorkouts.isNotEmpty
                        ? selectedWorkouts.length
                        : todayWorkouts.length,
                  ),
                ),
            ],
          );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final wd = d.weekday - 1; // 0=Mon
    return '${days[wd]}, ${months[d.month - 1]} ${d.day}';
  }
}

class _WorkoutSummaryCard extends StatelessWidget {
  final WorkoutWithExercisesAndSets workout;

  const _WorkoutSummaryCard({required this.workout});

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = workout.workout;
    final exercises = workout.exercisesWithSets;
    final totalSets = exercises.fold(0, (sum, e) => sum + e.sets.length);
    final completedSets = exercises.fold(
        0, (sum, e) => sum + e.sets.where((s) => s.completed).length);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    w.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(_formatDuration(w.timeElapsed)),
                  avatar: const Icon(Icons.timer_outlined, size: 14),
                  labelStyle: theme.textTheme.labelSmall,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$completedSets/$totalSets sets completed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.fitness_center_outlined,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${exercises.length} exercise${exercises.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (exercises.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: exercises.take(5).map((e) {
                  return Chip(
                    label: Text(
                      e.exerciseDC.name,
                      style: theme.textTheme.labelSmall,
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  );
                }).toList()
                  ..addAll(
                    exercises.length > 5
                        ? [
                            Chip(
                              label: Text(
                                '+${exercises.length - 5} more',
                                style: theme.textTheme.labelSmall,
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: theme.colorScheme.surfaceVariant,
                            )
                          ]
                        : [],
                  ),
              ),
            ],
            if (w.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                w.notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
