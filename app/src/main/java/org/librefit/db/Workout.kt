/*
 * Copyright (c) 2024. LibreFit
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

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.LocalDateTime

/**
 * Represents a workout.
 *
 * @property id The unique identifier for the workout. This is the primary key and is auto-incremented.
 * @property workoutId An identifier used for statistics to if the it has a parent routine. So every
 * workout from a single routine will share the same [workoutId]. It is used for statistics.
 * @property title The title of the workout visible to the user.
 * @property notes A user note about the routine or workout.
 * @property routine A boolean flag indicating whether the workout is a routine.
 * If `true`, the workout will be displayed as a playable routine in the [org.librefit.ui.screens.home.HomeScreen].
 * @property timeElapsed The total time elapsed during the workout, measured in seconds by
 * [org.librefit.services.WorkoutService] chronometer during a workout session.
 * @property created The timestamp indicating when a routine was created.
 * This is set to the current date and time by default.
 * @property completed The timestamp indicating when the workout was completed.
 * This is set to the current date and time by default, but it is updated when the workout is
 * finished in the [org.librefit.ui.screens.workout.WorkoutScreen].
 */
@Entity(tableName = "workouts")
data class Workout(
    @PrimaryKey(true) val id: Int = 0,
    val workoutId: Long = System.currentTimeMillis(),
    val notes: String = "",
    val title: String = "",
    val routine: Boolean = false,
    val timeElapsed: Int = 0,
    val created: LocalDateTime = LocalDateTime.now(),
    val completed: LocalDateTime = LocalDateTime.now()
)
