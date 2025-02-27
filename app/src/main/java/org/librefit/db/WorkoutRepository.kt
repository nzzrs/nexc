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

    suspend fun getExercisesFromWorkout(workoutId: Int): List<Exercise> {
        return workoutDao.getExercisesFromWorkout(workoutId)
    }

    suspend fun getSetsFromExercise(exerciseId: Int): List<Set> {
        return workoutDao.getSetsFromExercise(exerciseId)
    }

    suspend fun getAllPastWorkouts(routineId: Long): List<Workout> {
        return workoutDao.getAllPastWorkouts(routineId)
    }

    suspend fun addWorkoutWithExercises(
        workout: Workout,
        exercisesWithSets: List<ExerciseWithSets>
    ) {
        workoutDao.addWorkoutWithExercises(workout, exercisesWithSets)
    }
}