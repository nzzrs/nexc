/*
 * Copyright (c) 2024 LibreFit
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

package org.librefit.ui.screens.createRoutine

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.librefit.MainApplication
import org.librefit.data.ExerciseWithSets
import org.librefit.db.Set
import org.librefit.db.Workout

class CreateRoutineScreenViewModel : ViewModel() {
    private val _exercisesWithSets = MutableStateFlow<List<ExerciseWithSets>>(emptyList())
    val exercisesWithSets = _exercisesWithSets.asStateFlow()

    private var currentId: Int = 0

    fun getExercisesWithSets(): List<ExerciseWithSets> {
        return exercisesWithSets.value
    }

    fun addExerciseWithSets(exerciseWithSets: ExerciseWithSets) {
        val newExerciseWithSets = exerciseWithSets.copy(
            id = currentId++,
            sets = listOf(Set(exerciseId = currentId++))
        )
        _exercisesWithSets.value += newExerciseWithSets
    }

    fun addSetToExercise(index: Int) {
        _exercisesWithSets.value = _exercisesWithSets.value.map { exerciseWithSets ->
            if (exerciseWithSets.id == index) {
                exerciseWithSets.copy(sets = exerciseWithSets.sets + Set(exerciseId = currentId++))
            } else {
                exerciseWithSets
            }
        }
    }

    fun deleteExercise(index: Int) {
        _exercisesWithSets.value = _exercisesWithSets.value.filter { it.id != index }
    }

    fun isListEmpty(): Boolean {
        return exercisesWithSets.value.isEmpty()
    }

    fun updateSet(exerciseId: Int, set: Set, weight: Int? = null, reps: Int? = null, time : Int? = null) {
        val exerciseWithSets = _exercisesWithSets.value.find { it.id == exerciseId }

        if (exerciseWithSets != null) {
            val setToUpdateIndex =
                exerciseWithSets.sets.indexOfFirst { it.exerciseId == set.exerciseId }

            if (setToUpdateIndex != -1) {
                val updatedSets = exerciseWithSets.sets.toMutableList().apply {
                    this[setToUpdateIndex] = this[setToUpdateIndex].copy(
                        weight = weight ?: this[setToUpdateIndex].weight,
                        reps = reps ?: this[setToUpdateIndex].reps,
                        elapsedTime = time?: this[setToUpdateIndex].elapsedTime
                    )
                }

                _exercisesWithSets.value = _exercisesWithSets.value.map {
                    if (it == exerciseWithSets) it.copy(sets = updatedSets) else it
                }
            }
        }
    }


    private var titleRoutine by mutableStateOf("")

    fun updateTitle(string: String) {
        titleRoutine = string
    }

    fun getTitle(): String {
        return titleRoutine
    }

    fun isTitleEmpty(): Boolean {
        return titleRoutine.isEmpty()
    }

    fun isTitleTooLong(): Boolean {
        return titleRoutine.length >= 30
    }


    private val workoutDao = MainApplication.workoutDatabase.getWorkoutDao()

    fun saveExercisesWithWorkout(workout: Workout, exercises: List<ExerciseWithSets>) {
        val list = exercises.toList()
        viewModelScope.launch(Dispatchers.IO) {
            workoutDao.addWorkoutWithExercises(workout, list)
        }
    }
}

