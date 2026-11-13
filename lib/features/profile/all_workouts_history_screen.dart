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

import '../../core/components/nexc_async_view.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_page.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/util/format.dart';
import 'profile_screen.dart';

class AllWorkoutsHistoryScreen extends ConsumerWidget {
  const AllWorkoutsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final AsyncValue<List<WorkoutWithExercisesAndSets>> workoutsAsync = ref
        .watch(completedWorkoutsProvider);

    return NexcPage(
      title: l10n.allWorkoutsTitle,
      body: NexcAsyncView<List<WorkoutWithExercisesAndSets>>(
        value: workoutsAsync,
        isEmpty: (List<WorkoutWithExercisesAndSets> workouts) =>
            workouts.isEmpty,
        empty: NexcEmptyState(
          icon: NexcIcons.workoutHistory,
          title: l10n.emptyHistoryTitle,
          message: l10n.emptyHistoryMessage,
        ),
        errorTitle: (Object error) => l10n.errorWithMessage('$error'),
        builder: (List<WorkoutWithExercisesAndSets> workouts) {
          return NexcGroupedHistoryList(
            entries: [
              for (final WorkoutWithExercisesAndSets item in workouts)
                NexcHistoryEntry(
                  date: item.workout.completed,
                  icon: NexcIcons.workout,
                  title: item.workout.title,
                  meta: [
                    l10n.finishedOnDuration(
                      context.formatShortDate(item.workout.completed),
                      formatDurationShort(item.workout.timeElapsed),
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
            ],
          );
        },
      ),
    );
  }
}
