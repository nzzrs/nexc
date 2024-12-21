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

package org.librefit

import android.app.Application
import androidx.room.Room
import org.librefit.db.WorkoutDatabase
import org.librefit.helpers.NotificationHelper

class MainApplication : Application() {
    companion object{
        lateinit var workoutDatabase: WorkoutDatabase
        lateinit var notificationHelper: NotificationHelper
    }

    override fun onCreate() {
        super.onCreate()
        workoutDatabase = Room.databaseBuilder(
            applicationContext,
            WorkoutDatabase::class.java,
            WorkoutDatabase.NAME
        ).build()

        notificationHelper = NotificationHelper(this)
    }
}