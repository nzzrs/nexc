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

package org.librefit.services

import android.content.Context
import android.content.Intent
import dagger.hilt.android.qualifiers.ApplicationContext
import org.librefit.enums.WorkoutServiceActions
import org.librefit.services.WorkoutService.Companion.EXTRA_ADD_TEN_SECONDS
import org.librefit.services.WorkoutService.Companion.EXTRA_INITIAL_REST_TIME
import org.librefit.services.WorkoutService.Companion.EXTRA_IS_FOCUSED
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WorkoutServiceManager @Inject constructor(
    @ApplicationContext context: Context
) {
    private val context = context.applicationContext

    private val workoutServiceIntent by lazy {
        Intent(context, WorkoutService::class.java)
    }

    fun startChronometer() {
        val service = workoutServiceIntent.apply {
            action = WorkoutServiceActions.START_CHRONOMETER.string
        }
        context.startForegroundService(service)
    }

    fun pauseChronometer() {
        val service = workoutServiceIntent.apply {
            action = WorkoutServiceActions.PAUSE_CHRONOMETER.string
        }
        context.startForegroundService(service)
    }

    fun updateFocus(isFocused: Boolean) {
        val serviceIntent = workoutServiceIntent.apply {
            action = WorkoutServiceActions.WORKOUT_FOCUS.string
            putExtra(EXTRA_IS_FOCUSED, isFocused)
        }
        context.startForegroundService(serviceIntent)
    }

    fun startRestTimer(initialValue: Int) {
        val serviceIntent = workoutServiceIntent.apply {
            action = WorkoutServiceActions.START_REST_TIMER.string
            putExtra(EXTRA_INITIAL_REST_TIME, initialValue)
        }
        context.startForegroundService(serviceIntent)
    }

    fun modifyRestTime(addTenSeconds: Boolean) {
        val serviceIntent = workoutServiceIntent.apply {
            action = WorkoutServiceActions.MODIFY_REST_TIMER.string
            putExtra(EXTRA_ADD_TEN_SECONDS, addTenSeconds)
        }
        context.startForegroundService(serviceIntent)
    }

    fun stopService() {
        val service = workoutServiceIntent.apply {
            action = WorkoutServiceActions.STOP_SERVICE.string
        }
        context.startService(service)
    }

}