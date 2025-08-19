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

package org.librefit.ui.screens.infoExercise

import android.net.Uri
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.serialization.json.Json
import org.librefit.db.entity.ExerciseDC
import org.librefit.db.repository.WorkoutRepository
import org.librefit.enums.chart.BodyweightChart
import org.librefit.enums.chart.ExerciseChart
import org.librefit.enums.chart.LoadChart
import org.librefit.enums.chart.TimeChart
import org.librefit.enums.chart.WeightedBodyweightChart
import org.librefit.enums.exercise.Category
import org.librefit.enums.exercise.Equipment
import org.librefit.helpers.DataHelper
import org.librefit.ui.components.charts.Point
import org.librefit.ui.models.UiExerciseDC
import org.librefit.ui.models.UiWorkoutWithExercisesAndSets
import org.librefit.ui.models.mappers.toUi
import javax.inject.Inject

@HiltViewModel
class InfoExerciseScreenViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    workoutRepository: WorkoutRepository,
    dataHelper: DataHelper
) : ViewModel() {

    companion object {
        private const val EXERCISE_DC_KEY = "exerciseDC"
    }

    private val exerciseDCjson = savedStateHandle.get<String>(EXERCISE_DC_KEY)
        ?: error("EXERCISE_DC_KEY does not match `Route.InfoExerciseScreen` parameter")


    private val exerciseDC: UiExerciseDC = exerciseDCjson
        .let { it ->
            Json.decodeFromString<ExerciseDC>(Uri.decode(it)).toUi()
        }

    val workoutsWithExercises: StateFlow<List<UiWorkoutWithExercisesAndSets>> = workoutRepository
        .getCompletedWorkoutsWithExercisesWithIdExerciseDC(exerciseDC.id)
        .distinctUntilChanged()
        .map { list -> list.map { it.toUi() } }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )


    val defaultExerciseChart: ExerciseChart = when (exerciseDC.category) {
        Category.STRETCHING, Category.CARDIO -> TimeChart.BEST_TIME
        else -> when (exerciseDC.equipment) {
            Equipment.BODY_ONLY, Equipment.FOAM_ROLL, Equipment.EXERCISE_BALL,
            Equipment.MEDICINE_BALL, Equipment.BANDS -> if (exerciseDC.name.contains(
                    "Weighted",
                    true
                )
            )
                WeightedBodyweightChart.HEAVIEST_WEIGHT else BodyweightChart.MOST_REPS

            else -> LoadChart.HEAVIEST_WEIGHT
        }
    }
    private val _exerciseChart = MutableStateFlow(defaultExerciseChart)
    val exerciseChart = _exerciseChart.asStateFlow()

    fun updateExerciseChart(newValue: ExerciseChart) {
        _exerciseChart.update {
            newValue
        }
    }

    val points: StateFlow<List<Point>> = combine(
        exerciseChart,
        workoutRepository.getCompletedWorkoutsWithExercisesWithIdExerciseDC(exerciseDC.id)
    ) { c, workouts ->
        dataHelper.fetchPointsForExercisesChart(c, workouts)
    }
        .distinctUntilChanged()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )
}