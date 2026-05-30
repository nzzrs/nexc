/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.models.mappers

import kotlinx.collections.immutable.toImmutableList
import org.nexc.core.db.relations.ExerciseWithSets
import org.nexc.core.models.UiExerciseWithSets

fun ExerciseWithSets.toUi(): UiExerciseWithSets {
    return UiExerciseWithSets(
        exercise = this.exercise.toUi(),
        sets = this.sets.map { it.toUi() }.toImmutableList(),
        exerciseDC = this.exerciseDC.toUi()
    )
}

fun UiExerciseWithSets.toEntity(): ExerciseWithSets {
    return ExerciseWithSets(
        exercise = this.exercise.toEntity(),
        sets = sets.map { it.toEntity() },
        exerciseDC = exerciseDC.toEntity()
    )
}