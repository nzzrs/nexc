/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db

import androidx.room.AutoMigration
import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import org.nexc.core.db.converters.ExerciseDCConverter
import org.nexc.core.db.converters.LocalDateTimeConverter
import org.nexc.core.db.dao.DatasetDao
import org.nexc.core.db.dao.MeasurementDao
import org.nexc.core.db.dao.WorkoutDao
import org.nexc.core.db.entity.Exercise
import org.nexc.core.db.entity.ExerciseDC
import org.nexc.core.db.entity.Measurement
import org.nexc.core.db.entity.Set
import org.nexc.core.db.entity.Workout

@Database(
    entities = [Workout::class, Exercise::class, Set::class, Measurement::class, ExerciseDC::class],
    version = 8,
    exportSchema = true,
    autoMigrations = [
        AutoMigration(from = 1, to = 2),
        AutoMigration(from = 2, to = 3),
        AutoMigration(from = 3, to = 5),
        AutoMigration(from = 5, to = 6),
        AutoMigration(from = 6, to = 8)
    ]
)
@TypeConverters(LocalDateTimeConverter::class, ExerciseDCConverter::class)
abstract class AppDatabase : RoomDatabase() {
    companion object {
        const val NAME = "nexc_database"
    }

    abstract fun getWorkoutDao(): WorkoutDao

    abstract fun getMeasurementDao(): MeasurementDao

    abstract fun getDatasetDao(): DatasetDao
}