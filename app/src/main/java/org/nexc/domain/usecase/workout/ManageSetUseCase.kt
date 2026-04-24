/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

package org.nexc.domain.usecase.workout

import kotlinx.collections.immutable.toImmutableList
import org.nexc.core.models.UiExerciseWithSets
import org.nexc.core.models.UiSet
import javax.inject.Inject
import kotlin.random.Random

/**
 * Use case to manage sets within a workout session.
 * Handles adding, updating, and deleting sets within the provided exercise list.
 */
class ManageSetUseCase @Inject constructor() {
    
    fun addSet(exercises: List<UiExerciseWithSets>, exerciseId: Long): List<UiExerciseWithSets> {
        return exercises.map { exercise ->
            if (exercise.exercise.id == exerciseId) {
                val newSet = exercise.sets
                    .lastOrNull()?.copy(id = Random.nextLong(), completed = false)
                    ?: UiSet(id = Random.nextLong())

                val newSets = exercise.sets.toMutableList() + newSet
                exercise.copy(sets = newSets.toImmutableList())
            } else exercise
        }
    }

    fun updateSet(
        exercises: List<UiExerciseWithSets>,
        setId: Long,
        update: (UiSet) -> UiSet
    ): List<UiExerciseWithSets> {
        return exercises.map { exercise ->
            if (exercise.sets.any { it.id == setId }) {
                exercise.copy(
                    sets = exercise.sets.map {
                        if (it.id == setId) update(it) else it
                    }.toImmutableList()
                )
            } else exercise
        }
    }

    fun deleteSet(exercises: List<UiExerciseWithSets>, setId: Long): List<UiExerciseWithSets> {
        return exercises.map { exercise ->
            if (exercise.sets.any { it.id == setId }) {
                exercise.copy(
                    sets = exercise.sets.filter { it.id != setId }.toImmutableList()
                )
            } else exercise
        }
    }
}
