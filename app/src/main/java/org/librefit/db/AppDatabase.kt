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
 *
 * LibreFit is subject to additional terms covering author attribution and
 * trademark usage, as found in the accompanying ADDITIONAL_TERMS.md file.
 */

package org.librefit.db

import android.content.Context
import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.sqlite.db.SupportSQLiteDatabase
import com.squareup.moshi.JsonDataException
import com.squareup.moshi.Moshi
import com.squareup.moshi.Types
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.librefit.R
import org.librefit.db.converters.ExerciseDCConverter
import org.librefit.db.converters.LocalDateTimeConverter
import org.librefit.db.dao.DatasetDao
import org.librefit.db.dao.MeasurementDao
import org.librefit.db.dao.WorkoutDao
import org.librefit.db.entity.Exercise
import org.librefit.db.entity.ExerciseDC
import org.librefit.db.entity.Measurement
import org.librefit.db.entity.Set
import org.librefit.db.entity.Workout
import javax.inject.Provider

@Database(
    entities = [Workout::class, Exercise::class, Set::class, Measurement::class, ExerciseDC::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(LocalDateTimeConverter::class, ExerciseDCConverter::class)
abstract class AppDatabase : RoomDatabase() {
    companion object {
        const val NAME = "librefit_database"

        class PrepopulateCallback(
            private val context: Context,
            private val daoProvider: Provider<DatasetDao>,
            private val scope: CoroutineScope
        ) : Callback() {

            override fun onCreate(db: SupportSQLiteDatabase) {
                super.onCreate(db)
                // The dataset is parsed only once, when the database is first created.
                scope.launch(Dispatchers.IO) {
                    prepopulateDatabase()
                }
            }

            private suspend fun prepopulateDatabase() {
                try {
                    val jsonFile =
                        context.resources.openRawResource(R.raw.exercises).bufferedReader().use {
                            it.readText()
                        }

                    val moshi = Moshi.Builder().build()
                    val listType =
                        Types.newParameterizedType(List::class.java, ExerciseDC::class.java)
                    val adapter = moshi.adapter<List<ExerciseDC>>(listType)

                    // ExerciseDC adapter is auto generated. All entries of all
                    // enums must be annotated with @Json with its corresponding value in json file
                    val exercises = adapter.fromJson(jsonFile)
                        ?: throw JsonDataException("Failed to parse `exercises.json` file. Resource ID: ${R.raw.exercises}")

                    // Set the dataset into the database using the DAO
                    daoProvider.get().setDataset(exercises)

                } catch (e: Exception) {
                    error(e.message.toString())
                }
            }
        }
    }

    abstract fun getWorkoutDao(): WorkoutDao

    abstract fun getMeasurementDao(): MeasurementDao

    abstract fun getDatasetDao(): DatasetDao
}