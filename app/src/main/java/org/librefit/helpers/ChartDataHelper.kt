/*
 * Copyright (c) 2025. LibreFit
 *
 * This file is part of LibreFit
 *
 * LibreFit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * LibreFit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with LibreFit.  If not, see <https://www.gnu.org/licenses/>.
 */

package org.librefit.helpers

import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import org.librefit.data.ChartData
import org.librefit.db.relations.WorkoutWithExercisesAndSets
import org.librefit.db.repository.MeasurementRepository
import org.librefit.enums.SetMode
import org.librefit.enums.chart.WorkoutChart
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Locale
import javax.inject.Inject

class ChartDataHelper @Inject constructor(
    private val measurementRepository: MeasurementRepository
) {
    val shortFormatter: DateTimeFormatter? =
        DateTimeFormatter.ofLocalizedDate(FormatStyle.SHORT).withLocale(
            Locale.getDefault()
        )

    suspend fun fetchListChartData(
        workoutChart: WorkoutChart,
        workoutsWithExercises: List<WorkoutWithExercisesAndSets>
    ): List<ChartData> = coroutineScope {
        val bodyWeights = workoutsWithExercises
            .map {
                async {
                    measurementRepository.getBodyWeightByCutoff(it.workout.completed)?.bodyWeight
                        ?: 0f
                }
            }
            .awaitAll()

        workoutsWithExercises
            .mapIndexed { index, it ->
                async {
                    ChartData(
                        yValue = when (workoutChart) {
                            WorkoutChart.DURATION -> it.workout.timeElapsed / 60f
                            WorkoutChart.VOLUME -> it.exercisesWithSets.sumOf { exe ->
                                exe.sets.filter { it.completed }.sumOf {
                                    (it.weight + if (exe.exercise.setMode == SetMode.REPS) bodyWeights[index]
                                    else 0f) * it.reps.toDouble()
                                }
                            }

                            WorkoutChart.REPS -> it.exercisesWithSets.sumOf {
                                it.sets.filter { it.completed }.sumOf { it.reps }
                            }
                        }.toFloat(),
                        xValue = it.workout.completed.format(shortFormatter)
                    )
                }
            }
            .awaitAll()

    }
}