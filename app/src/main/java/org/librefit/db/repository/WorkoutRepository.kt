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

package org.librefit.db.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import org.librefit.db.dao.WorkoutDao
import org.librefit.db.entity.Workout
import org.librefit.db.relations.WorkoutWithExercisesAndSets
import org.librefit.enums.WorkoutState
import org.librefit.ui.models.UiWorkoutWithExercisesAndSets
import org.librefit.ui.models.mappers.toUi
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Repository class for managing workout data.
 *
 * This class serves as a mediator between [WorkoutDao] and the
 * application, providing a clean API for data access.
 *
 * @param workoutDao The [WorkoutDao] instance used to access workout data from the database.
 * @property completedWorkouts Refer to [WorkoutDao.getWorkoutsByStateAndOrderedByCompleted]
 * @property routines Refer to [WorkoutDao.getWorkoutsByState]
 * @property completedWorkoutsWithExercisesAndSets Refer to [WorkoutDao.getWorkoutsWithExercisesAndSetsByStateAndOrderedByCompleted]
 *
 */
@Singleton
class WorkoutRepository @Inject constructor(
    private val workoutDao: WorkoutDao
) {
    val completedWorkouts =
        workoutDao.getWorkoutsByStateAndOrderedByCompleted(WorkoutState.COMPLETED)

    val routines = workoutDao.getWorkoutsByState(WorkoutState.ROUTINE)

    val completedWorkoutsWithExercisesAndSets =
        workoutDao.getWorkoutsWithExercisesAndSetsByStateAndOrderedByCompleted(WorkoutState.COMPLETED)



    suspend fun getWorkoutWithExercisesAndSets(workoutID: Long): UiWorkoutWithExercisesAndSets {
        return workoutDao.getWorkoutWithExercisesAndSets(id = workoutID).toUi()
    }

    suspend fun getRoutineFromRoutineID(routineId: Long): Workout {
        return workoutDao.getWorkoutFromRoutineIDAndState(routineId, state = WorkoutState.ROUTINE)
            ?: Workout()
    }

    suspend fun updateWorkout(workout: Workout) {
        workoutDao.updateWorkout(workout)
    }

    suspend fun deleteWorkout(workout: Workout) {
        workoutDao.deleteWorkout(workout)
    }




    /**
     * Refer to [WorkoutDao.getWorkoutsWithExercisesAndSetsFromRoutineByState]
     */
    suspend fun getCompletedWorkoutsWithExercisesAndSetsFromRoutine(routineId: Long): List<WorkoutWithExercisesAndSets> {
        return workoutDao.getWorkoutsWithExercisesAndSetsFromRoutineByState(
            routineId,
            state = WorkoutState.COMPLETED
        )
    }

    /**
     * Refer to [WorkoutDao.addWorkoutWithExercisesAndSets]
     */
    suspend fun addWorkoutWithExercisesAndSets(
        workoutWithExercisesAndSets: WorkoutWithExercisesAndSets
    ) {
        workoutDao.addWorkoutWithExercisesAndSets(workoutWithExercisesAndSets)
    }


    fun getCompletedWorkoutsWithExercisesWithIdExerciseDC(idExerciseDC: String): Flow<List<WorkoutWithExercisesAndSets>> {
        return workoutDao
            .getWorkoutsFromIdExerciseDC(idExerciseDC, WorkoutState.COMPLETED)
            .map { list ->
                list.map { w ->
                    w.copy(
                        exercisesWithSets = w.exercisesWithSets.filter { it.exerciseDC.id == idExerciseDC }
                    )
                }
            }
    }
}