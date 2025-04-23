/*
 * Copyright (c) 2024-2025. LibreFit
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

package org.librefit.ui.screens.profile

import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.librefit.data.ChartData
import org.librefit.db.relations.WorkoutWithExercisesAndSets
import org.librefit.db.repository.WorkoutRepository
import org.librefit.enums.WorkoutChart
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.time.temporal.ChronoUnit
import java.util.Locale
import javax.inject.Inject

@HiltViewModel
class ProfileScreenViewModel @Inject constructor(
    private val workoutRepository: WorkoutRepository
) : ViewModel() {
    val workoutsWithExercises = mutableStateListOf<WorkoutWithExercisesAndSets>()


    val shortFormatter: DateTimeFormatter? =
        DateTimeFormatter.ofLocalizedDate(FormatStyle.SHORT).withLocale(
        Locale.getDefault()
    )

    private var workoutChart = mutableStateOf(WorkoutChart.DURATION)

    fun getListChartData(): List<ChartData> {
        return workoutsWithExercises.mapIndexed { index, it ->
            ChartData(
                yValue = when (workoutChart.value) {
                    WorkoutChart.DURATION -> it.workout.timeElapsed / 60f
                    WorkoutChart.VOLUME -> it.exercisesWithSets.sumOf {
                        it.sets.filter { it.completed }.sumOf { it.weight.toDouble() * it.reps }
                    }

                    WorkoutChart.REPS -> it.exercisesWithSets.sumOf {
                        it.sets.filter { it.completed }.sumOf { it.reps }
                    }
                }.toFloat(),
                xValue = it.workout.completed.format(shortFormatter)
            )
        }
    }

    fun updateChartMode(value: WorkoutChart) {
        workoutChart.value = value
    }

    fun getChartMode(): WorkoutChart {
        return workoutChart.value
    }


    fun getWorkoutListFromDB() {
        viewModelScope.launch(Dispatchers.IO) {
            val workoutsFromDb = workoutRepository.getCompletedWorkoutsWithExercisesAndSets()
            if (workoutsWithExercises != workoutsFromDb) {
                workoutsWithExercises.clear()
                workoutsWithExercises.addAll(workoutsFromDb)
            }
        }
    }


    fun getWeekStreak(): Int {
        if (workoutsWithExercises.size < 2 || ChronoUnit.DAYS.between(
                workoutsWithExercises.first().workout.completed,
                LocalDateTime.now()
            ) > 7
        ) {
            return 0
        }

        var index = workoutsWithExercises.lastIndex

        for (i in 0 until workoutsWithExercises.size - 1) {
            if (ChronoUnit.DAYS.between(
                    workoutsWithExercises[i + 1].workout.completed,
                    workoutsWithExercises[i].workout.completed
                ) > 7
            ) {
                index = i
                break
            }
        }

        return ChronoUnit.WEEKS.between(
            workoutsWithExercises[index].workout.completed,
            LocalDateTime.now()
        ).toInt()
    }

}