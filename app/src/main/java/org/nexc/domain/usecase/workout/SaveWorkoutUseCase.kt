/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

package org.nexc.domain.usecase.workout

import org.nexc.core.db.repository.WorkoutRepository
import org.nexc.core.db.relations.WorkoutWithExercisesAndSets
import javax.inject.Inject

class SaveWorkoutUseCase @Inject constructor(
    private val workoutRepository: WorkoutRepository
) {
    suspend operator fun invoke(workoutWithExercisesAndSets: WorkoutWithExercisesAndSets): Long {
        return workoutRepository.addWorkoutWithExercisesAndSets(workoutWithExercisesAndSets)
    }
}
