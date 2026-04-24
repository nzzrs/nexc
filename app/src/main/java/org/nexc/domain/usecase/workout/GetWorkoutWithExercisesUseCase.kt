/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

package org.nexc.domain.usecase.workout

import org.nexc.core.db.repository.WorkoutRepository
import org.nexc.core.models.UiWorkoutWithExercisesAndSets
import javax.inject.Inject

class GetWorkoutWithExercisesUseCase @Inject constructor(
    private val workoutRepository: WorkoutRepository
) {
    suspend operator fun invoke(workoutId: Long): UiWorkoutWithExercisesAndSets {
        return workoutRepository.getWorkoutWithExercisesAndSets(workoutId)
    }
}
