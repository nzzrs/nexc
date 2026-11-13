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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_history_tile.dart';
import '../../core/components/nexc_page.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';

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
  StreamSubscription<List<WorkoutWithExercisesAndSets>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() {
    _subscription = ref
        .read(workoutRepositoryProvider)
        .watchWorkoutsWithExercisesAndSetsByState(WorkoutState.COMPLETED)
        .listen((List<WorkoutWithExercisesAndSets> workouts) {
          if (!mounted) return;
          setState(() {
            _allWorkouts = workouts;
            _isLoading = false;
          });
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<WorkoutWithExercisesAndSets> _getWorkoutsForDay(DateTime day) {
    return _allWorkouts.where((WorkoutWithExercisesAndSets item) {
      final DateTime date = item.workout.completed;
      return date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final List<WorkoutWithExercisesAndSets> selectedWorkouts =
        _selectedDay == null ? const [] : _getWorkoutsForDay(_selectedDay!);

    return NexcPage(
      title: l10n.calendarTitle,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: NexcSpacing.xl),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NexcSpacing.lg,
                    NexcSpacing.sm,
                    NexcSpacing.lg,
                    0,
                  ),
                  child: Material(
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: const RoundedRectangleBorder(
                      borderRadius: NexcShapes.lgRadius,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(NexcSpacing.sm),
                      child: TableCalendar<WorkoutWithExercisesAndSets>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (DateTime day) =>
                            isSameDay(_selectedDay, day),
                        eventLoader: _getWorkoutsForDay,
                        onDaySelected:
                            (DateTime selectedDay, DateTime focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                        onFormatChanged: (CalendarFormat format) {
                          setState(() => _calendarFormat = format);
                        },
                        onPageChanged: (DateTime focusedDay) {
                          setState(() => _focusedDay = focusedDay);
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
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                            borderRadius: NexcShapes.smRadius,
                          ),
                          formatButtonTextStyle: theme.textTheme.labelSmall!,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_allWorkouts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      NexcSpacing.lg,
                      NexcSpacing.md,
                      NexcSpacing.lg,
                      0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: NexcSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.workoutNoun,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedDay == null)
                  NexcEmptyState(
                    icon: NexcIcons.calendar,
                    title: l10n.selectDayHint,
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      NexcSpacing.lg,
                      NexcSpacing.lg,
                      NexcSpacing.lg,
                      NexcSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.formatMediumDate(_selectedDay!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: NexcSpacing.sm),
                        Text(
                          selectedWorkouts.length == 1
                              ? '1 ${l10n.workoutNoun}'
                              : '${selectedWorkouts.length} '
                                    '${l10n.workoutsNoun}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedWorkouts.isEmpty)
                    NexcEmptyState(
                      icon: NexcIcons.workoutIdle,
                      title: l10n.restDayNoWorkouts,
                    )
                  else
                    for (final WorkoutWithExercisesAndSets item
                        in selectedWorkouts)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          NexcSpacing.lg,
                          0,
                          NexcSpacing.lg,
                          NexcSpacing.sm,
                        ),
                        child: NexcHistoryTile(
                          icon: NexcIcons.workout,
                          title: item.workout.title,
                          meta: [
                            formatDurationShort(item.workout.timeElapsed),
                            l10n.setsCompletedRatio(
                              _completedSets(item),
                              _totalSets(item),
                            ),
                          ],
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/info-workout',
                              arguments: item.workout.id,
                            );
                          },
                        ),
                      ),
                ],
              ],
            ),
    );
  }

  int _totalSets(WorkoutWithExercisesAndSets item) {
    return item.exercisesWithSets.fold(
      0,
      (int sum, ExerciseWithSets exercise) => sum + exercise.sets.length,
    );
  }

  int _completedSets(WorkoutWithExercisesAndSets item) {
    return item.exercisesWithSets.fold(
      0,
      (int sum, ExerciseWithSets exercise) =>
          sum + exercise.sets.where((WorkoutSet set) => set.completed).length,
    );
  }
}
