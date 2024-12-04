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
import org.librefit.db.Exercise
import org.librefit.db.Set
import org.librefit.db.Workout
import org.librefit.enums.SetMode
import org.librefit.util.ExerciseWithSets

class CreateRoutineScreenViewModel : ViewModel() {
    private val _exercisesWithSets = MutableStateFlow<List<ExerciseWithSets>>(emptyList())
    val exercisesWithSets = _exercisesWithSets.asStateFlow()

    private var currentId: Int = 0


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
                exerciseWithSets.copy(
                    sets = exerciseWithSets.sets + Set(exerciseId = currentId++)
                )
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

    /**
     * It updates [Set] by assigning a [value] to one attribute based on [mode].
     * @param exerciseId ID of the exercise [Exercise.exerciseId]
     * @param set [Set] to change
     * @param value The new value to assign to one attribute of [Set]
     * @param mode Defines which attribute should the value be assigned.
     * Based on which attribute you want to change, you have to pass the corresponding value:
     *  [Set.weight]        -> 0;
     *  [Set.reps]          -> 1;
     *  [Set.elapsedTime]   -> 2;
     */
    fun updateSet(exerciseId: Int, set: Set, value: Int, mode: Int) {
        _exercisesWithSets.value = _exercisesWithSets.value.map { exerciseWithSets ->
            if (exerciseWithSets.id == exerciseId) {
                val updatedSets = exerciseWithSets.sets.map { currentSet ->
                    /*
                    It compares "exerciseId" instead of "id" because in
                    AddSetToExercise method a unique ID is assigned at "exerciseId".
                    Furthermore it will be overwritten when saved in db.
                     */
                    if (currentSet.exerciseId == set.exerciseId) {
                        when (mode) {
                            0 -> currentSet.copy(weight = value)
                            1 -> currentSet.copy(reps = value)
                            2 -> currentSet.copy(elapsedTime = value)
                            else -> currentSet
                        }
                    } else {
                        currentSet
                    }
                }
                exerciseWithSets.copy(sets = updatedSets)
            } else {
                exerciseWithSets
            }
        }
    }

    /**
     * It updates [ExerciseWithSets] by assigning a [value] to one attribute based on [mode].
     * @param exerciseId ID of the exercise [Exercise.exerciseId]
     * @param value The new value to assign to one attribute of [ExerciseWithSets]
     * @param mode Defines which attribute should the value be assigned.
     * Based on which attribute you want to change, you have to pass the corresponding value:
     *  [ExerciseWithSets.note]    -> 0;
     *  [ExerciseWithSets.setMode] -> 1;
     */
    fun updateExercise(exerciseId: Int, value: String, mode: Int) {
        _exercisesWithSets.value = _exercisesWithSets.value.map { exerciseWithSets ->
            if (exerciseWithSets.id == exerciseId) {
                when (mode) {
                    0 -> exerciseWithSets.copy(note = value.toString())
                    1 -> exerciseWithSets.copy(
                        setMode = when (value) {
                            SetMode.WEIGHT.name -> SetMode.WEIGHT
                            SetMode.TIME.name -> SetMode.TIME
                            SetMode.REPS.name -> SetMode.REPS
                            else -> SetMode.WEIGHT
                        }
                    )

                    else -> exerciseWithSets
                }
            } else {
                exerciseWithSets
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

    fun saveExercisesWithRoutine(workout: Workout, exercises: List<ExerciseWithSets>) {
        val list = exercises.toList()
        viewModelScope.launch(Dispatchers.IO) {
            workoutDao.addWorkoutWithExercises(workout.copy(routine = true), list)
        }
    }
}

