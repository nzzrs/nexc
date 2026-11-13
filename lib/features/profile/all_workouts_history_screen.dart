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
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';

class AllWorkoutsHistoryScreen extends ConsumerWidget {
  const AllWorkoutsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(completedWorkoutsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allWorkoutsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: workoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text(l10n.errorWithMessage('$err'))),
        data: (workouts) {
          if (workouts.isEmpty) {
            return Center(child: Text(l10n.noWorkoutsCompleted));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final w = workouts[index];
              final durationStr = '${(w.workout.timeElapsed ~/ 60)} min';
              final dateStr =
                  "${w.workout.completed.month}/${w.workout.completed.day}/${w.workout.completed.year}";
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(
                    w.workout.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(l10n.finishedOnDuration(dateStr, durationStr)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/info-workout',
                      arguments: w.workout.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
