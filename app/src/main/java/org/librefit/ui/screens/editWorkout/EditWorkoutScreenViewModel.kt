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

package org.librefit.ui.screens.editWorkout

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.librefit.db.entity.Exercise
import org.librefit.db.entity.ExerciseDC
import org.librefit.db.entity.Set
import org.librefit.db.entity.Workout
import org.librefit.db.relations.ExerciseWithSets
import org.librefit.db.relations.WorkoutWithExercisesAndSets
import org.librefit.db.repository.WorkoutRepository
import org.librefit.enums.SetMode
import org.librefit.enums.exercise.Category
import org.librefit.enums.exercise.Equipment
import javax.inject.Inject
import kotlin.random.Random

@HiltViewModel
class EditWorkoutScreenViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val workoutRepository: WorkoutRepository
) : ViewModel() {

    companion object {
        private const val WORKOUT_ID_KEY = "workoutId"
    }

    private val workoutId = savedStateHandle.get<Long>(WORKOUT_ID_KEY)
        ?: throw IllegalArgumentException("Invalid WORKOUT_ID_KEY")


    private val _isRoutine = MutableStateFlow(false)
    private val isRoutine = _isRoutine.asStateFlow()

    private val _workout = MutableStateFlow(Workout())
    val workout = _workout.asStateFlow()

    private val _routine = MutableStateFlow(Workout())
    val routine = _routine.asStateFlow()

    private val _exercises = MutableStateFlow<List<ExerciseWithSets>>(emptyList())
    val exercises = _exercises.asStateFlow()

    init {
        viewModelScope.launch(Dispatchers.IO) {
            if (workoutId != 0L) {
                val workoutWithExercisesAndSets =
                    workoutRepository.getWorkoutWithExercisesAndSets(workoutId)

                val workoutInDb = workoutWithExercisesAndSets.workout

                _isRoutine.value = workoutInDb.routine

                _workout.value = workoutInDb.copy(routine = false)

                _exercises.value = workoutWithExercisesAndSets.exercisesWithSets
            } else {
                _isRoutine.value = true
            }


            if (isRoutine.value) {
                _routine.value = workout.value
            } else {
                _routine.value = workoutRepository.getRoutineFromRoutineID(workout.value.routineId)
            }
        }
    }

    fun addExerciseWithSets(exerciseDC: ExerciseDC) {
        val newExercise = ExerciseWithSets(
            exercise = Exercise(
                idExerciseDC = exerciseDC.id,
                setMode = when (exerciseDC.category) {
                    Category.STRETCHING -> SetMode.DURATION
                    Category.CARDIO -> SetMode.DURATION
                    else -> when (exerciseDC.equipment) {
                        Equipment.BODY_ONLY -> SetMode.BODYWEIGHT
                        Equipment.FOAM_ROLL -> SetMode.BODYWEIGHT
                        Equipment.EXERCISE_BALL -> SetMode.BODYWEIGHT
                        else -> SetMode.LOAD
                    }
                }
            ),
            exerciseDC = exerciseDC
        )

        _exercises.value = exercises.value + newExercise
    }

    fun addSetToExercise(exerciseWithSets: ExerciseWithSets) {
        val newSet = exerciseWithSets.sets
            .lastOrNull()?.copy(id = Random.Default.nextLong())
            ?: Set()

        _exercises.value = exercises.value.map { exercise ->
            if (exercise == exerciseWithSets) {
                exercise.copy(sets = exercise.sets + newSet)
            } else {
                exercise
            }
        }
    }

    /**
     * Updates a specific [Set] within a [ExerciseWithSets.sets].
     *
     * @param exerciseWithSets The [ExerciseWithSets] in the [exercises] list that contains the
     * set to be updated.
     * @param set The updated [Set] to assign.
     */
    fun updateSet(set: Set, exerciseWithSets: ExerciseWithSets) {
        _exercises.value = exercises.value.map { exercise ->
            if (exercise == exerciseWithSets) {
                exercise.copy(
                    sets = exerciseWithSets.sets.map {
                        if (it.id == set.id) set else it
                    }
                )
            } else {
                exercise
            }
        }
    }

    /**
     * Removes a specific set from the sets associated with an exercise in the [exercises] list.
     *
     * This function updates the exercise at the given [index] by filtering out the specified [set]
     * based on its unique identifier. The modified exercise is then saved back to the [exercises] list.
     *
     * @param index The index of the exercise in the [exercises] list from which the set will be deleted.
     * @param set The set to be removed, identified by its unique ID.
     */
    fun deleteSet(index: Int, set: Set) {
        val exerciseWithSets = exercises.value[index]

        _exercises.value = exercises.value.mapIndexed { i, exercise ->
            if (index == i) {
                exercise.copy(
                    sets = exerciseWithSets.sets.filter { it.id != set.id }
                )
            } else {
                exercise
            }
        }
    }

    /**
     * Updates an instance of [ExerciseWithSets] by assigning a [value] to a specified attribute based on the provided [mode].
     *
     * @param index The index of the [ExerciseWithSets] instance in the [exercises] list that needs to be updated.
     * @param value The new value to be assigned to the specified attribute of the [ExerciseWithSets].
     * @param mode An integer that determines which attribute will be updated with the [value].
     * The following modes correspond to specific attributes:
     *  - 0: [org.librefit.db.entity.Exercise.notes]
     *  - 1: [org.librefit.db.entity.Exercise.setMode]
     *  - 2: [org.librefit.db.entity.Exercise.restTime]
     *
     * Note: When updating [org.librefit.db.entity.Exercise.setMode], the [value] should be one of the following string representations:
     *  - [SetMode.LOAD].name
     *  - [SetMode.DURATION].name
     *  - [SetMode.BODYWEIGHT].name;
     * If an invalid string is provided, the default value [SetMode.LOAD] will be assigned.
     */
    fun updateExercise(index: Int, value: String, mode: Int) {
        val exerciseWithSets = exercises.value[index]
        val newExerciseWithSets = when (mode) {
            0 -> exerciseWithSets.copy(exercise = exerciseWithSets.exercise.copy(notes = value))
            1 -> exerciseWithSets.copy(
                exercise = exerciseWithSets.exercise.copy(
                    setMode = when (value) {
                        SetMode.LOAD.name -> SetMode.LOAD
                        SetMode.BODYWEIGHT_WITH_LOAD.name -> SetMode.BODYWEIGHT_WITH_LOAD
                        SetMode.DURATION.name -> SetMode.DURATION
                        SetMode.BODYWEIGHT.name -> SetMode.BODYWEIGHT
                        else -> SetMode.LOAD
                    }
                )
            )

            2 -> exerciseWithSets.copy(
                exercise = exerciseWithSets.exercise.copy(
                    restTime = Integer.parseInt(
                        value
                    )
                )
            )

            else -> exerciseWithSets
        }

        _exercises.value = exercises.value.mapIndexed { i, e ->
            if (i == index) newExerciseWithSets else e
        }
    }

    fun deleteExercise(index: Int) {
        _exercises.value = exercises.value.filterIndexed { i, e -> i != index }
    }


    fun updateTitle(string: String) {
        _workout.value = workout.value.copy(title = string)
    }

    fun updateNotes(string: String) {
        _workout.value = workout.value.copy(notes = string)
    }

    fun isTitleEmpty(): Boolean {
        return workout.value.title.isEmpty()
    }

    fun isTitleTooLong(): Boolean {
        return workout.value.title.length >= 30
    }


    fun saveWorkoutWithExercisesInDB() {
        viewModelScope.launch(Dispatchers.IO) {
            workoutRepository.addWorkoutWithExercisesAndSets(
                WorkoutWithExercisesAndSets(
                    workout = workout.value.copy(routine = isRoutine.value),
                    exercisesWithSets = exercises.value
                )
            )
        }
    }


    /**
     * Returns `null` when a new routine is created, `true` when a routine is edited and `false` when
     * a past workout is edited
     */
    fun getTypeOfEdit(): Boolean? {
        return if (workout.value.id == 0L) null else isRoutine.value
    }
}

