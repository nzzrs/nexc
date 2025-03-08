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

import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.librefit.db.WorkoutRepository
import org.librefit.db.entity.Workout
import org.librefit.db.relations.ExerciseWithSets
import org.librefit.db.relations.WorkoutWithExercisesAndSets
import org.librefit.enums.ChartMode
import org.librefit.enums.SetMode
import org.librefit.util.Formatter.formatTime
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Locale
import javax.inject.Inject

@HiltViewModel
class InfoWorkoutScreenViewModel @Inject constructor(
    private val workoutRepository: WorkoutRepository
) : ViewModel() {
    private var initialized = false
    private val workout = mutableStateOf(Workout())

    fun initialize(
        workout: Workout,
        passedRoutine: Workout,
        passedExercises: List<ExerciseWithSets>
    ) {
        if (!initialized) {
            initialized = true
            this.workout.value = workout
            if (isRoutine()) {
                getCompletedWorkoutsFromDB()
            }

            this.routine.value = passedRoutine

            exercises.addAll(passedExercises)
        }
    }

    fun getWorkoutTitle(): String {
        return workout.value.title
    }

    fun getDate(): String {
        val date = if (isRoutine()) workout.value.created else workout.value.completed
        return date.format(
            DateTimeFormatter.ofLocalizedDate(FormatStyle.LONG).withLocale(
                Locale.getDefault()
            )
        )
    }

    fun getElapsedTime(): String {
        return formatTime(workout.value.timeElapsed)
    }

    fun getNotes(): String {
        return workout.value.notes
    }

    fun isRoutine(): Boolean {
        return workout.value.routine
    }


    private var routine = mutableStateOf(Workout())


    fun getRoutineTitle(): String {
        return routine.value.title
    }

    fun getRoutineDate(): String {
        return routine.value.created.format(
            DateTimeFormatter.ofLocalizedDate(FormatStyle.LONG).withLocale(
                Locale.getDefault()
            )
        )
    }


    val exercises = mutableStateListOf<ExerciseWithSets>()

    fun getVolumeExercises(): String {
        val value = exercises.sumOf {
            it.sets.sumOf { set ->
                if (it.exercise.setMode == SetMode.WEIGHT) {
                    if (isRoutine()) {
                        (set.weight * set.reps).toDouble()
                    } else {
                        if (set.completed) {
                            (set.weight * set.reps).toDouble()
                        } else 0.0
                    }
                } else 0.0
            }
        }

        return String.format(Locale.getDefault(), "%.2f", value)
    }

    fun getTotalExercises(): String {
        return exercises.size.toString()
    }

    fun getTotalSets(): String {
        return exercises.sumOf { it.sets.size }.toString()
    }

    fun getCompletedSets(): String {
        return exercises.sumOf { it.sets.filter { it.completed == true }.size }.toString()
    }


    val shortFormatter = DateTimeFormatter.ofLocalizedDate(FormatStyle.SHORT).withLocale(
        Locale.getDefault()
    )
    private var chartMode = mutableStateOf(ChartMode.DURATION)

    fun getYAxisDataChart(): List<Float> {
        return completedWorkoutsWithExercises.mapIndexed { index, it ->
            when (chartMode.value) {
                ChartMode.DURATION -> it.workout.timeElapsed / 60f
                ChartMode.VOLUME -> it.exercisesWithSets.sumOf {
                    it.sets.filter { it.completed }.sumOf { it.weight.toDouble() * it.reps }
                }

                ChartMode.REPS -> it.exercisesWithSets.sumOf {
                    it.sets.filter { it.completed }.sumOf { it.reps }
                }
            }.toFloat()
        }
    }

    fun getXAxisDataChart(): List<String> {
        return completedWorkoutsWithExercises.map { it ->
            it.workout.completed.format(shortFormatter).toString()
        }
    }

    fun updateChartMode(value: ChartMode) {
        chartMode.value = value
    }

    fun getChartMode(): ChartMode {
        return chartMode.value
    }

    /**
     * All the completed [WorkoutWithExercisesAndSets] linked to [routine] by [Workout.routineId]
     */
    private var completedWorkoutsWithExercises = mutableStateListOf<WorkoutWithExercisesAndSets>()

    fun getCompletedWorkoutsFromDB() {
        viewModelScope.launch(Dispatchers.IO) {
            completedWorkoutsWithExercises.addAll(
                workoutRepository.getCompletedWorkoutsWithExercisesAndSetsFromRoutine(workout.value.routineId)
            )
        }
    }

    fun deleteWorkout() {
        viewModelScope.launch(Dispatchers.IO) {
            workoutRepository.deleteWorkout(workout.value)
        }
    }

    fun detachWorkoutFromRoutine() {
        workout.value = workout.value.copy(
            routineId = System.currentTimeMillis()
        )

        routine.value = Workout()

        viewModelScope.launch(Dispatchers.IO) {
            workoutRepository.updateWorkout(workout.value)
        }
    }
}