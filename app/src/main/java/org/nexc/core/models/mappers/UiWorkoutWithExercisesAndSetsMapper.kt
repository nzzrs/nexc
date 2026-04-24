/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.models.mappers

import kotlinx.collections.immutable.toImmutableList
import org.nexc.core.db.relations.WorkoutWithExercisesAndSets
import org.nexc.core.models.UiWorkoutWithExercisesAndSets

fun WorkoutWithExercisesAndSets.toUi(): UiWorkoutWithExercisesAndSets {
    return UiWorkoutWithExercisesAndSets(
        workout = workout.toUi(),
        exercisesWithSets = exercisesWithSets
            .sortedBy { it.exercise.position }
            .map { it.toUi() }
            .toImmutableList()
    )
}

fun UiWorkoutWithExercisesAndSets.toEntity(): WorkoutWithExercisesAndSets {
    return WorkoutWithExercisesAndSets(
        workout = workout.toEntity(),
        exercisesWithSets = exercisesWithSets.map { it.toEntity() }
    )
}
