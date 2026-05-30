/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.relations

import androidx.room.Embedded
import androidx.room.Relation
import kotlinx.serialization.Serializable
import org.nexc.core.db.entity.Exercise
import org.nexc.core.db.entity.Workout

/**
 * A data class representing a [Workout] and its associated [ExerciseWithSets].
 *
 * This class is used by Room to retrieve all the data associated with an workout and
 * the exercisesWithSets associated with it.
 *
 * @property workout It contains the data associated with this [Workout] some of which is user generated.
 * @property exercisesWithSets A list of [ExerciseWithSets] entities where each entry consists of an [Exercise]
 * and its related [Set]s.
 */
@Serializable
data class WorkoutWithExercisesAndSets(
    @Embedded val workout: Workout,
    @Relation(
        entity = Exercise::class,
        parentColumn = "id",
        entityColumn = "workoutId"
    )
    val exercisesWithSets: List<ExerciseWithSets>
)