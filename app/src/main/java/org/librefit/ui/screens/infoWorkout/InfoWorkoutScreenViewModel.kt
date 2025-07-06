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

package org.librefit.ui.screens.infoWorkout

import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.librefit.data.ChartData
import org.librefit.data.ExerciseDC
import org.librefit.db.entity.Workout
import org.librefit.db.relations.ExerciseWithSets
import org.librefit.db.relations.WorkoutWithExercisesAndSets
import org.librefit.db.repository.WorkoutRepository
import org.librefit.enums.chart.WorkoutChart
import org.librefit.helpers.DataHelper
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Locale
import javax.inject.Inject
import kotlin.random.Random

@HiltViewModel
class InfoWorkoutScreenViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val exercisesList: List<ExerciseDC>,
    private val workoutRepository: WorkoutRepository,
    private val dataHelper: DataHelper
) : ViewModel() {
    companion object {
        private const val WORKOUT_ID_KEY = "workoutId"
    }

    private val workoutId = savedStateHandle.get<Long>(WORKOUT_ID_KEY) ?: 0L

    init {
        require(workoutId != 0L) { "workoutId must be not equal to 0" }

        viewModelScope.launch(Dispatchers.IO) {
            val workoutWithExercisesAndSets =
                workoutRepository.getWorkoutWithExercisesAndSets(workoutId)

            _workout.value = workoutWithExercisesAndSets.workout

            _exercises.value = workoutWithExercisesAndSets.exercisesWithSets.map {
                it.apply {
                    val exDC = exercisesList.find { e -> e.id == it.exercise.exerciseId }!!
                    it.exercise = it.exercise.copy(exerciseId = exDC.id)
                    it.exerciseDC = exDC
                }
            }

            if (isRoutine()) {
                _routine.value = workout.value

                //If the workout is a routine, then retrieve all past completed workout associated with it
                _completedWorkoutsWithExercises.value = workoutRepository
                    .getCompletedWorkoutsWithExercisesAndSetsFromRoutine(routineId = workout.value.routineId)
            } else {
                _routine.value = workoutRepository.getRoutineFromRoutineID(workout.value.routineId)
            }
        }
    }


    private var _workout = MutableStateFlow(Workout())
    val workout = _workout.asStateFlow()

    fun getDate(): String {
        val date = if (isRoutine()) workout.value.created else workout.value.completed
        return date.format(
            DateTimeFormatter.ofLocalizedDate(FormatStyle.LONG).withLocale(
                Locale.getDefault()
            )
        )
    }

    fun isRoutine(): Boolean {
        return workout.value.routine
    }

    fun deleteWorkout() {
        viewModelScope.launch(Dispatchers.IO) {
            workoutRepository.deleteWorkout(workout.value)
        }
    }

    fun detachWorkoutFromRoutine() {
        _workout.value = workout.value.copy(
            routineId = Random.Default.nextLong() + System.currentTimeMillis()
        )

        _routine.value = Workout()

        viewModelScope.launch(Dispatchers.IO) {
            workoutRepository.updateWorkout(workout.value)
        }
    }




    private var _routine = MutableStateFlow(Workout())
    val routine = _routine.asStateFlow()


    private var _exercises = MutableStateFlow<List<ExerciseWithSets>>(emptyList())
    val exercises = _exercises.asStateFlow()


    suspend fun getVolumeExercises(): String {
        val volume = dataHelper.fetchVolumeFromWorkout(
            WorkoutWithExercisesAndSets(workout.value, exercises.value)
        )

        return String.format(Locale.getDefault(), "%.2f", volume)
    }


    private val _completedWorkoutsWithExercises =
        MutableStateFlow<List<WorkoutWithExercisesAndSets>>(emptyList())
    private val completedWorkoutsWithExercises = _completedWorkoutsWithExercises.asStateFlow()

    private var workoutChart = mutableStateOf(WorkoutChart.DURATION)

    private val _listChartData = MutableStateFlow<List<ChartData>>(emptyList())
    val listChartData = _listChartData.asStateFlow()


    suspend fun fetchListChartData() {
        _listChartData.value = dataHelper.fetchListChartData(
            workoutChart = workoutChart.value,
            workoutsWithExercises = completedWorkoutsWithExercises.value
        )
    }

    fun updateChartMode(value: WorkoutChart) {
        workoutChart.value = value
    }

    fun getChartMode(): WorkoutChart {
        return workoutChart.value
    }

}