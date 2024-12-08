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

package org.librefit.ui.screens.workout

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.librefit.MainApplication
import org.librefit.db.Exercise
import org.librefit.db.Set
import org.librefit.db.Workout
import org.librefit.enums.SetMode
import org.librefit.util.ExerciseDC
import org.librefit.util.ExerciseWithSets
import kotlin.random.Random

class WorkoutScreenViewModel(
    workoutId: Int,
    private val list: List<ExerciseDC>
) : ViewModel() {

    private val _exercisesWithSets = MutableStateFlow<List<ExerciseWithSets>>(emptyList())
    val exercisesWithSets = _exercisesWithSets.asStateFlow()

    fun addExerciseWithSets(exerciseWithSets: ExerciseWithSets) {
        val newExerciseWithSets = exerciseWithSets.copy(
            id = Random.nextInt(),
            sets = if (exerciseWithSets.sets.isEmpty()) {
                listOf(Set(id = Random.nextInt()))
            } else exerciseWithSets.sets
        )
        _exercisesWithSets.value += newExerciseWithSets
    }

    fun addSetToExercise(id: Int) {
        _exercisesWithSets.value = _exercisesWithSets.value.map { exerciseWithSets ->
            if (exerciseWithSets.id == id) {
                exerciseWithSets.copy(
                    id = Random.nextInt(),
                    sets = exerciseWithSets.sets + Set(id = Random.nextInt())
                )
            } else {
                exerciseWithSets
            }
        }
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
     *  [Set.completed]     -> 3
     */
    fun updateSet(exerciseId: Int, set: Set, value: Int, mode: Int) {
        _exercisesWithSets.value = _exercisesWithSets.value.map { exerciseWithSets ->
            if (exerciseWithSets.id == exerciseId) {
                val updatedSets = exerciseWithSets.sets.map { currentSet ->
                    if (currentSet.id == set.id) {
                        when (mode) {
                            0 -> currentSet.copy(weight = value)
                            1 -> currentSet.copy(reps = value)
                            2 -> currentSet.copy(elapsedTime = value)
                            3 -> currentSet.copy(completed = value == 1)
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
     * @param exerciseId ID of the exercise with sets. It should be [ExerciseWithSets.exerciseId]
     * @param value The new value to assign to one attribute of [ExerciseWithSets]
     * @param mode Defines which attribute should the [value] be assigned.
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

    fun deleteExercise(index: Int) {
        _exercisesWithSets.value = _exercisesWithSets.value.filter { it.id != index }
    }


    fun getProgress(): Float {
        return exercisesWithSets.value.sumOf { it.sets.filter { it.completed == true }.size }
            .toFloat() / exercisesWithSets.value.sumOf { it.sets.size }
    }


    private val workoutDao = MainApplication.workoutDatabase.getWorkoutDao()

    init {
        getExercisesFromWorkout(workoutId)
    }

    fun getExercisesFromWorkout(workoutId: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            val exercises = workoutDao.getExercisesFromWorkout(workoutId)
            exercises.forEach { exercise ->
                val exerciseDC = list.associateBy { it.id }[exercise.exerciseId]
                if (exerciseDC != null) {
                    getSetsFromExercise(exercise.id)

                    addExerciseWithSets(
                        ExerciseWithSets(
                            exerciseDC = exerciseDC,
                            exerciseId = exercise.id,
                            note = exercise.notes,
                            setMode = exercise.setMode
                        )
                    )
                }
            }
        }
    }

    fun getSetsFromExercise(exerciseId: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            val sets = workoutDao.getSetsFromExercise(exerciseId)
            val updatedExercisesWithSets = _exercisesWithSets.value.map { exerciseWithSets ->
                if (exerciseWithSets.exerciseId == exerciseId) {
                    //A random id is assigned to avoid conflicts in updateSet method
                    exerciseWithSets.copy(sets = sets.map { it.copy(exerciseId = Random.nextInt()) })
                } else {
                    exerciseWithSets
                }
            }
            _exercisesWithSets.value = updatedExercisesWithSets
        }
    }

    fun saveExercisesWithWorkout(workout: Workout, exercises: List<ExerciseWithSets>) {
        val list = exercises.toList()
        viewModelScope.launch(Dispatchers.IO) {
            workoutDao.addWorkoutWithExercises(workout, list)
        }
    }

    var timeElapsed by mutableIntStateOf(0)
        private set
    var isTimerRunning by mutableStateOf(true)
        private set
    private var pulsingText by mutableIntStateOf(0)


    init {
        startTimer()
    }

    fun startTimer() {
        isTimerRunning = true
        val startTime = System.currentTimeMillis()
        val pastTimeElapsed = timeElapsed

        viewModelScope.launch(Dispatchers.IO) {
            while (isTimerRunning) {
                val currentTime = System.currentTimeMillis()

                timeElapsed = (currentTime - startTime).toInt() / 1000 + pastTimeElapsed
                delay(1000)
            }
        }
    }

    fun stopTimer() {
        isTimerRunning = false

        viewModelScope.launch(Dispatchers.IO) {
            while (!isTimerRunning) {
                pulsingText++
                delay(600)
            }
        }
    }

    fun pulsingTimer(): Boolean {
        return !isTimerRunning && pulsingText % 2 == 1
    }
}
