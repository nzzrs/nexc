package org.librefit.db

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction
import org.librefit.data.ExerciseDC

@Dao
interface WorkoutDao {
    @Query("SELECT * FROM Workout ORDER BY title" )
    fun getWorkouts() : LiveData<List<Workout>>

    @Insert
    fun addWorkout(workout: Workout) : Long

    @Delete
    fun deleteWorkout(workout: Workout)

    @Insert
    suspend fun addExercise(exercise: Exercise)

    @Delete
    suspend fun deleteExercise(exercise: Exercise)

    @Transaction
    @Query("SELECT * FROM Workout WHERE id = :workoutId")
    fun getWorkoutWithExercises(workoutId: Int): WorkoutWithExercises

    @Transaction
    suspend fun addWorkoutWithExercises(workout: Workout, exercises: List<ExerciseDC>) {
        val workoutId = addWorkout(workout).toInt()
        exercises.forEach {
            addExercise(Exercise(exerciseId = it.id, notes = null, workoutId = workoutId))
        }
    }
}