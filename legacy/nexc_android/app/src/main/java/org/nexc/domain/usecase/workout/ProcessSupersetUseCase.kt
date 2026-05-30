/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

package org.nexc.domain.usecase.workout

import org.nexc.core.models.UiExerciseWithSets
import javax.inject.Inject
import kotlin.random.Random

/**
 * Use case to handle superset transformations on a list of exercises.
 * It links an exercise with its predecessor using a shared supersetId or unlinks it.
 */
class ProcessSupersetUseCase @Inject constructor() {
    operator fun invoke(exercises: List<UiExerciseWithSets>, targetExerciseId: Long): List<UiExerciseWithSets> {
        val index = exercises.indexOfFirst { it.exercise.id == targetExerciseId }
        if (index == -1) return exercises

        val exercise = exercises[index].exercise
        return if (exercise.supersetId != null) {
            // Unlink target exercise
            exercises.map { if (it.exercise.id == targetExerciseId) it.copy(exercise = it.exercise.copy(supersetId = null)) else it }
        } else {
            // Link with previous exercise if possible
            if (index > 0) {
                val prevExercise = exercises[index - 1].exercise
                val newSupersetId = prevExercise.supersetId ?: Random.nextLong()
                
                exercises.mapIndexed { i, eWs ->
                    when (i) {
                        index -> eWs.copy(exercise = eWs.exercise.copy(supersetId = newSupersetId))
                        index - 1 -> if (prevExercise.supersetId == null) {
                            eWs.copy(exercise = eWs.exercise.copy(supersetId = newSupersetId))
                        } else eWs
                        else -> eWs
                    }
                }
            } else {
                exercises
            }
        }
    }
}
