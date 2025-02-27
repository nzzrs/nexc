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

package org.librefit.db

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import kotlinx.coroutines.flow.Flow
import org.librefit.data.ExerciseWithSets
import java.time.LocalDateTime

@Dao
interface WorkoutDao {
    @Query("SELECT * FROM workouts WHERE 1 = routine ORDER BY title")
    fun getRoutines(): Flow<List<Workout>>

    @Query("SELECT * FROM workouts WHERE 0 = routine ORDER BY completed DESC")
    fun getCompletedWorkouts(): Flow<List<Workout>>

    @Query("SELECT * FROM workouts WHERE id = :id")
    fun getWorkout(id: Int): Workout

    @Insert
    suspend fun addWorkout(workout: Workout): Long

    @Update
    suspend fun updateWorkout(workout: Workout)

    @Delete
    suspend fun deleteWorkout(workout: Workout)

    @Insert
    suspend fun addExercise(exercise: Exercise): Long

    @Update
    suspend fun updateExercise(exercise: Exercise)

    @Delete
    suspend fun deleteExercise(exercise: Exercise)

    @Insert
    suspend fun addSet(set: Set)

    @Update
    suspend fun updateSet(set: Set)

    @Delete
    suspend fun deleteSet(set: Set)

    @Query("SELECT * FROM exercises WHERE workoutId = :workoutId")
    suspend fun getExercisesFromWorkout(workoutId: Int): List<Exercise>

    @Query("SELECT * FROM sets WHERE exerciseId = :exerciseId")
    suspend fun getSetsFromExercise(exerciseId: Int): List<Set>

    @Query("SELECT * FROM workouts WHERE routineId = :routineId AND routine = 0 ORDER BY completed DESC")
    suspend fun getAllPastWorkouts(routineId: Long): List<Workout>

    /**
     * Adds a workout along with its associated exercises and sets to the database.
     *
     * A [workout] is considered "new" if its [Workout.id] is 0. In this case, it will be saved as a new entry.
     * If the workout is not new, it will be updated instead.
     *
     * The function performs the following steps:
     * 1. If the workout is new, it saves the workout with the current timestamp.
     * 2. If the workout is not new, it updates the existing workout.
     * 3. It retrieves all exercises associated with the workout from the database.
     * 4. It deletes any exercises that are in the database but not in the provided [exercisesWithSets].
     * 5. For each exercise in [exercisesWithSets]:
     *    - If the exercise is new (not found in the old exercises), it adds the exercise to the database.
     *    - If the exercise already exists, it updates the existing exercise.
     * 6. It retrieves all sets associated with each exercise.
     * 7. It deletes any sets that are in the database but not in the provided sets.
     * 8. For each set in the provided sets ([ExerciseWithSets.sets]):
     *    - If the set already exists, it updates the set.
     *    - If the set is new, it adds the set to the database.
     *
     * @param workout The workout to be added or updated.
     * @param exercisesWithSets A list of [ExerciseWithSets] with their associated [Set]s to be added or updated.
     */

    @Transaction
    suspend fun addWorkoutWithExercises(
        workout: Workout,
        exercisesWithSets: List<ExerciseWithSets>
    ) {
        val isNewWorkout = workout.id == 0

        val workoutId = if (isNewWorkout) {
            if (workout.routine) {
                addWorkout(workout.copy(completed = LocalDateTime.now())).toInt()
            } else {
                addWorkout(workout.copy(created = LocalDateTime.now())).toInt()
            }
        } else {
            workout.id
        }

        if (!isNewWorkout) {
            updateWorkout(workout)
        }

        val oldExercises = getExercisesFromWorkout(workoutId)

        // Deletes from db the exercises not found in the passed exercises
        oldExercises
            .filter { e -> !exercisesWithSets.any { it.exerciseId == e.id } }
            .forEach { exercise ->
                deleteExercise(exercise)
            }

        exercisesWithSets.forEach { exerciseWithSets ->
            val isNewExercise = !oldExercises.any { it.id == exerciseWithSets.exerciseId }

            val exerciseId = if (isNewExercise) {
                addExercise(
                    Exercise(
                        exerciseId = exerciseWithSets.exerciseDC.id,
                        notes = exerciseWithSets.note,
                        workoutId = workoutId,
                        setMode = exerciseWithSets.setMode,
                        restTime = exerciseWithSets.restTime
                    )
                ).toInt()
            } else {
                exerciseWithSets.exerciseId
            }


            if (!isNewExercise) {
                updateExercise(
                    Exercise(
                        id = exerciseWithSets.exerciseId,
                        exerciseId = exerciseWithSets.exerciseDC.id,
                        notes = exerciseWithSets.note,
                        workoutId = workoutId,
                        setMode = exerciseWithSets.setMode,
                        restTime = exerciseWithSets.restTime
                    )
                )
            }

            val oldSets = getSetsFromExercise(exerciseId)

            // Deletes from db the sets not found in the passed sets
            oldSets.filter { s -> !exerciseWithSets.sets.any { it.id == s.id } }.forEach { set ->
                deleteSet(set)
            }

            exerciseWithSets.sets.forEach { set ->
                if (oldSets.any { it.id == set.id }) {
                    updateSet(set)
                } else {
                    addSet(
                        set.copy(
                            id = 0,
                            exerciseId = exerciseId.toInt()
                        )
                    )
                }
            }
        }
    }
}