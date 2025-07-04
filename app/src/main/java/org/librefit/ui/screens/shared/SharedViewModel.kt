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

package org.librefit.ui.screens.shared

import androidx.compose.runtime.mutableStateListOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import org.librefit.data.ExerciseDC
import org.librefit.db.entity.Workout
import org.librefit.db.relations.ExerciseWithSets
import org.librefit.db.repository.WorkoutRepository
import javax.inject.Inject

@HiltViewModel
class SharedViewModel @Inject constructor(
    private val workoutRepository: WorkoutRepository,
    private val exercisesList: List<ExerciseDC>
) : ViewModel() {


    private val selectedExercisesList = mutableStateListOf<ExerciseDC>()

    fun getSelectedExercisesList(): List<ExerciseDC> {
        val list = selectedExercisesList.toList()
        resetSelectedExercisesList()
        return list
    }

    fun addSelectedExerciseToList(exerciseList: List<ExerciseDC>) {
        resetSelectedExercisesList()
        selectedExercisesList += exerciseList
    }

    fun resetSelectedExercisesList() {
        selectedExercisesList.clear()
    }


    private var passedWorkout = Workout()
    private var passedExercises = listOf<ExerciseWithSets>()
    private var passedRoutine = Workout()
    private var workoutId = 0L


    fun updateWorkoutId(workoutId: Long) {
        this.workoutId = workoutId
        getDataFromDB()
    }

    fun setPassedData(
        workout: Workout? = null,
        exercises: List<ExerciseWithSets>,
        routine: Workout? = null
    ) {
        if (workout != null) {
            passedWorkout = workout
        }
        passedExercises = exercises.map {
            it.apply {
                val exDC = exercisesList.find { e -> e.id == it.exercise.exerciseId }!!
                it.exercise = it.exercise.copy(exerciseId = exDC.id)
                it.exerciseDC = exDC
            }
        }
        if (routine != null) {
            passedRoutine = routine
        }
    }

    fun getPassedWorkout(): Workout {
        return passedWorkout
    }

    fun getPassedExercises(): List<ExerciseWithSets> {
        return passedExercises
    }

    fun getPassedRoutine(): Workout {
        return passedRoutine
    }


    private fun getDataFromDB() {
        if (workoutId != 0L) {
            viewModelScope.launch(Dispatchers.IO) {
                passedExercises = workoutRepository.getExercisesFromWorkout(workoutId).map {
                    it.apply {
                        val exDC = exercisesList.find { e -> e.id == it.exercise.exerciseId }!!
                        it.exercise = it.exercise.copy(exerciseId = exDC.id)
                        it.exerciseDC = exDC
                    }
                }
            }
            viewModelScope.launch(Dispatchers.IO) {
                passedWorkout = workoutRepository.getWorkout(workoutId)

                passedRoutine = if (passedWorkout.routine) {
                    passedWorkout
                } else {
                    runCatching { workoutRepository.routines.first() }
                        .getOrDefault(emptyList())
                        .find { it.routineId == passedWorkout.routineId }
                        .takeIf { it?.id != passedWorkout.id } ?: Workout()
                }

            }
        } else {
            passedWorkout = Workout()
            passedRoutine = Workout()
            passedExercises = emptyList()
        }
    }
}