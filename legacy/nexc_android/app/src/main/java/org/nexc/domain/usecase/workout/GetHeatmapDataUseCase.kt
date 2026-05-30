/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

package org.nexc.domain.usecase.workout

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import org.nexc.core.db.repository.WorkoutRepository
import org.nexc.core.enums.exercise.Muscle
import org.nexc.core.helpers.DataHelper
import javax.inject.Inject

/**
 * Use case to retrieve muscle heatmap data for a specific period.
 * Defaults to 30 days and aggregates total volume (weight * reps).
 */
class GetHeatmapDataUseCase @Inject constructor(
    private val workoutRepository: WorkoutRepository,
    private val dataHelper: DataHelper
) {
    operator fun invoke(days: Int = 30): Flow<Map<Muscle, Double>> {
        return workoutRepository.completedWorkoutsWithExercisesAndSets.map { workouts ->
            dataHelper.fetchMuscleVolumeHeatmap(workouts, days)
        }
    }
}
