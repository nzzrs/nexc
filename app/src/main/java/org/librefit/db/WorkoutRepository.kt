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

package org.librefit.db

import org.librefit.data.ExerciseWithSets

/**
 * Repository class for managing workout data.
 *
 * This class serves as a mediator between the workout database and the
 * application, providing a clean API for data access.
 *
 * This class is provided by [org.librefit.di.DatabaseModule].
 *
 * @param workoutDao The [WorkoutDao] instance used to access workout data from the database.
 * @property completedWorkouts Refer to [WorkoutDao.getCompletedWorkouts]
 * @property routines Refer to [WorkoutDao.getRoutines]
 *
 */
class WorkoutRepository(private val workoutDao: WorkoutDao) {
    val completedWorkouts = workoutDao.getCompletedWorkouts()

    val routines = workoutDao.getRoutines()


    fun getWorkout(id: Int): Workout {
        return workoutDao.getWorkout(id)
    }

    suspend fun updateWorkout(workout: Workout) {
        workoutDao.updateWorkout(workout)
    }

    suspend fun deleteWorkout(workout: Workout) {
        workoutDao.deleteWorkout(workout)
    }

    /**
     * Refer to [WorkoutDao.getExercisesFromWorkout]
     */
    suspend fun getExercisesFromWorkout(workoutId: Int): List<Exercise> {
        return workoutDao.getExercisesFromWorkout(workoutId)
    }

    /**
     * Refer to [WorkoutDao.getSetsFromExercise]
     */
    suspend fun getSetsFromExercise(exerciseId: Int): List<Set> {
        return workoutDao.getSetsFromExercise(exerciseId)
    }

    /**
     * Refer to [WorkoutDao.getCompletedWorkoutsFromRoutine]
     */
    suspend fun getAllPastWorkouts(routineId: Long): List<Workout> {
        return workoutDao.getCompletedWorkoutsFromRoutine(routineId)
    }

    /**
     * Refer to [WorkoutDao.addWorkoutWithExercises]
     */
    suspend fun addWorkoutWithExercises(
        workout: Workout,
        exercisesWithSets: List<ExerciseWithSets>
    ) {
        workoutDao.addWorkoutWithExercises(workout, exercisesWithSets)
    }

    suspend fun getVolumeAndRepsFromWorkouts(workouts: List<Workout>): Pair<List<Float>, List<Int>> {
        val volume = mutableListOf<Float>()
        val reps = mutableListOf<Int>()

        workouts.forEach { workout ->
            val allSets = getExercisesFromWorkout(workout.id)
                .flatMap { getSetsFromExercise(it.id) }
                .filter { it.completed }

            val (workoutVolume, workoutReps) = allSets.fold(0f to 0) { (volumeAcc, repsAcc), set ->
                (volumeAcc + set.weight * set.reps) to (repsAcc + set.reps)
            }

            volume.add(workoutVolume)
            reps.add(workoutReps)
        }

        return Pair(volume, reps)
    }
}