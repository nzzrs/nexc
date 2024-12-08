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

package org.librefit.db

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction
import kotlinx.coroutines.flow.Flow
import org.librefit.util.ExerciseWithSets

@Dao
interface WorkoutDao {
    @Query("SELECT * FROM workouts WHERE 1 = routine ORDER BY title" )
    fun getRoutines() : Flow<List<Workout>>

    @Query("SELECT * FROM workouts WHERE 0 = routine ORDER BY title" )
    fun getWorkouts() : Flow<List<Workout>>

    @Insert
    fun addWorkout(workout: Workout) : Long

    @Delete
    fun deleteWorkout(workout: Workout)

    @Insert
    fun addExercise(exercise: Exercise) : Long

    @Delete
    suspend fun deleteExercise(exercise: Exercise)

    @Insert
    suspend fun addSet(set: Set)

    @Delete
    suspend fun deleteSet(set: Set)

    @Query("SELECT * FROM exercises WHERE workoutId = :workoutId")
    suspend fun getExercisesFromWorkout(workoutId: Int): List<Exercise>

    @Query("SELECT * FROM sets WHERE exerciseId = :exerciseId")
    suspend fun getSetsFromExercise(exerciseId : Int): List<Set>

    @Transaction
    suspend fun addWorkoutWithExercises(workout: Workout, exercises: List<ExerciseWithSets>) {
        val workoutId = addWorkout(workout).toInt()
        exercises.forEach {
            val exerciseId = addExercise(
                Exercise(
                    exerciseId = it.exerciseDC.id,
                    notes = it.note,
                    workoutId = workoutId,
                    setMode = it.setMode
                )
            )
            it.sets.forEach { set ->
                addSet(set.copy(exerciseId = exerciseId.toInt()))
            }
        }
    }
}