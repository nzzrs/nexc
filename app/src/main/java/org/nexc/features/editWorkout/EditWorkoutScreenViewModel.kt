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
<<<<<<< HEAD:app/src/main/java/org/nexc/features/editWorkout/EditWorkoutScreenViewModel.kt
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
=======
import org.librefit.db.entity.ExerciseDC
import org.librefit.db.relations.WorkoutWithExercisesAndSets
import org.librefit.db.repository.WorkoutRepository
import org.librefit.enums.SetMode
import org.librefit.enums.WorkoutState
import org.librefit.enums.exercise.Category
import org.librefit.enums.exercise.Equipment
import org.librefit.nav.Route
import org.librefit.ui.models.UiExercise
import org.librefit.ui.models.UiExerciseWithSets
import org.librefit.ui.models.UiSet
import org.librefit.ui.models.UiWorkout
import org.librefit.ui.models.moveExercise
import org.librefit.ui.models.withNormalizedExercisePositions
import org.librefit.ui.models.mappers.toEntity
import org.librefit.ui.models.mappers.toUi
>>>>>>> fork/main:app/src/main/java/org/librefit/ui/screens/editWorkout/EditWorkoutScreenViewModel.kt
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
            (exercises + newExercise).withNormalizedExercisePositions()
        }
    }

    fun replaceExercise(index: Int, exerciseDC: ExerciseDC) {
        val newExercise = addExerciseToWorkoutUseCase(exerciseDC)
        _exercises.update { currentExercises ->
            val mutableList = currentExercises.toMutableList()
            if (index in mutableList.indices) {
                mutableList[index] = newExercise
            }
            mutableList
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
            currentExercises
                .filter { it.exercise.id != exerciseId }
                .withNormalizedExercisePositions()
        }
    }

    fun moveExercise(fromIndex: Int, toIndex: Int) {
        _exercises.update { currentExercises ->
            currentExercises.moveExercise(fromIndex = fromIndex, toIndex = toIndex)
        }
    }

    fun moveExercise(fromIndex: Int, toIndex: Int) {
        _exercises.update { currentExercises ->
            val mutableList = currentExercises.toMutableList()
            if (fromIndex in mutableList.indices && toIndex in mutableList.indices) {
                val item = mutableList.removeAt(fromIndex)
                mutableList.add(toIndex, item)
            }
            mutableList
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
<<<<<<< HEAD:app/src/main/java/org/nexc/features/editWorkout/EditWorkoutScreenViewModel.kt
                    exercisesWithSets = exercises.value.mapIndexed { index, it ->
                        it.copy(exercise = it.exercise.copy(position = index)).toEntity()
                    }
=======
                    exercisesWithSets = exercises.value
                        .withNormalizedExercisePositions()
                        .map { it.toEntity() }
>>>>>>> fork/main:app/src/main/java/org/librefit/ui/screens/editWorkout/EditWorkoutScreenViewModel.kt
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
