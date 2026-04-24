/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.editWorkout

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.toRoute
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.collections.immutable.toImmutableList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.nexc.core.db.entity.ExerciseDC
import org.nexc.core.db.relations.WorkoutWithExercisesAndSets
import org.nexc.core.db.repository.UserPreferencesRepository
import org.nexc.core.db.repository.WorkoutRepository
import org.nexc.core.enums.SetMode
import org.nexc.core.enums.WorkoutState
import org.nexc.core.enums.exercise.Category
import org.nexc.core.enums.exercise.Equipment
import org.nexc.core.nav.Route
import org.nexc.core.models.UiExercise
import org.nexc.core.models.UiExerciseWithSets
import org.nexc.core.models.UiSet
import org.nexc.core.models.UiWorkout
import org.nexc.core.models.mappers.toEntity
import org.nexc.core.models.mappers.toUi
import org.nexc.domain.usecase.workout.AddExerciseToWorkoutUseCase
import org.nexc.domain.usecase.workout.ManageSetUseCase
import org.nexc.domain.usecase.workout.ProcessSupersetUseCase
import org.nexc.domain.usecase.workout.SaveWorkoutUseCase
import javax.inject.Inject
import kotlin.random.Random

@HiltViewModel
class EditWorkoutScreenViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val workoutRepository: WorkoutRepository,
    private val userPreferences: UserPreferencesRepository,
    private val addExerciseToWorkoutUseCase: AddExerciseToWorkoutUseCase,
    private val manageSetUseCase: ManageSetUseCase,
    private val processSupersetUseCase: ProcessSupersetUseCase,
    private val saveWorkoutUseCase: SaveWorkoutUseCase
) : ViewModel() {

    private val workoutId = savedStateHandle.toRoute<Route.EditWorkoutScreen>().workoutId


    private val _isRoutine = MutableStateFlow(false)
    private val isRoutine = _isRoutine.asStateFlow()

    private val _workout = MutableStateFlow(UiWorkout())
    val workout = _workout.asStateFlow()

    private val _routine = MutableStateFlow(UiWorkout())
    val routine = _routine.asStateFlow()

    private val _exercises = MutableStateFlow<List<UiExerciseWithSets>>(emptyList())
    val exercises = _exercises.asStateFlow()

    init {
        viewModelScope.launch(Dispatchers.IO) {
            if (workoutId != 0L) {
                val workoutWithExercisesAndSets =
                    workoutRepository.getWorkoutWithExercisesAndSets(workoutId)

                val workoutInDb = workoutWithExercisesAndSets.workout

                _isRoutine.update {
                    workoutInDb.state == WorkoutState.ROUTINE
                }

                _workout.update {
                    workoutInDb.copy(state = WorkoutState.COMPLETED)
                }

                _exercises.update {
                    workoutWithExercisesAndSets.exercisesWithSets
                }
            } else {
                _isRoutine.update {
                    true
                }
            }

            _routine.update {
                if (isRoutine.value) {
                    workout.value
                } else {
                    workoutRepository.getRoutineFromRoutineID(workout.value.routineId).toUi()
                }
            }
        }
    }

    fun addExerciseWithSets(exerciseDC: ExerciseDC) {
        val newExercise = addExerciseToWorkoutUseCase(exerciseDC)

        _exercises.update { exercises ->
            exercises + newExercise
        }
    }

    fun addSetToExercise(exerciseId: Long) {
        _exercises.update { exercises ->
            manageSetUseCase.addSet(exercises, exerciseId)
        }
    }

    fun updateSetTime(time: Int, id: Long) {
        _exercises.update { currentExercises ->
            manageSetUseCase.updateSet(currentExercises, id) { it.copy(elapsedTime = time) }
        }
    }

    fun updateSetReps(reps: Int, id: Long) {
        _exercises.update { currentExercises ->
            manageSetUseCase.updateSet(currentExercises, id) { it.copy(reps = reps) }
        }
    }

    fun updateSetLoad(load: Double, id: Long) {
        _exercises.update { currentExercises ->
            manageSetUseCase.updateSet(currentExercises, id) { it.copy(load = load) }
        }
    }

    fun updateSetRpe(rpe: String, id: Long) {
        val currentScale = intensityScale.value
        _exercises.update { currentExercises ->
            manageSetUseCase.updateSet(currentExercises, id) { it.copy(rpe = rpe, intensityScale = currentScale) }
        }
    }

    fun updateSetRir(rir: String, id: Long) {
        val currentScale = intensityScale.value
        _exercises.update { currentExercises ->
            manageSetUseCase.updateSet(currentExercises, id) { it.copy(rir = rir, intensityScale = currentScale) }
        }
    }

    fun updateSetCompleted(completed: Boolean, id: Long) {
        _exercises.update { currentExercises ->
            manageSetUseCase.updateSet(currentExercises, id) { it.copy(completed = completed) }
        }
    }

    fun deleteSet(id: Long) {
        _exercises.update { currentExercises ->
            manageSetUseCase.deleteSet(currentExercises, id)
        }
    }

    fun updateExerciseNotes(notes: String, id: Long) {
        _exercises.update { currentExercises ->
            currentExercises.map { eWs ->
                if (eWs.exercise.id == id) eWs.copy(exercise = eWs.exercise.copy(notes = notes)) else eWs
            }
        }
    }

    fun updateExerciseRestTime(restTime: Int, id: Long) {
        _exercises.update { currentExercises ->
            currentExercises.map { eWs ->
                if (eWs.exercise.id == id) eWs.copy(exercise = eWs.exercise.copy(restTime = restTime)) else eWs
            }
        }
    }

    fun updateExerciseSetMode(setMode: SetMode, id: Long) {
        _exercises.update { currentExercises ->
            currentExercises.map { eWs ->
                if (eWs.exercise.id == id) eWs.copy(exercise = eWs.exercise.copy(setMode = setMode)) else eWs
            }
        }
    }
    fun toggleSuperset(id: Long) {
        _exercises.update { currentExercises ->
            processSupersetUseCase(currentExercises, id)
        }
    }

    fun deleteExercise(exerciseId: Long) {
        _exercises.update { currentExercises ->
            currentExercises.filter { it.exercise.id != exerciseId }
        }
    }


    fun updateTitle(string: String) {
        _workout.update { it.copy(title = string) }
    }

    fun updateNotes(string: String) {
        _workout.update { it.copy(notes = string) }
    }

    fun isTitleEmpty(): Boolean {
        return workout.value.title.isEmpty()
    }

    fun isTitleTooLong(): Boolean {
        return workout.value.title.length >= 30
    }


    fun saveWorkoutWithExercisesInDB() {
        viewModelScope.launch(Dispatchers.IO) {
            val state = if (isRoutine.value) WorkoutState.ROUTINE else WorkoutState.COMPLETED

            saveWorkoutUseCase(
                WorkoutWithExercisesAndSets(
                    workout = workout.value.copy(state = state).toEntity(),
                    exercisesWithSets = exercises.value.map { it.toEntity() }
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

    val showRpe = userPreferences.showRpe
    val intensityScale = userPreferences.intensityScale
}

