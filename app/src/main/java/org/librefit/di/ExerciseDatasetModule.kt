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

package org.librefit.di

import android.content.Context
import com.squareup.moshi.JsonDataException
import com.squareup.moshi.Moshi
import com.squareup.moshi.Types
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import org.librefit.R
import org.librefit.data.ExerciseDC
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object ExerciseDatasetModule {

    @Provides
    @Singleton
    fun provideExerciseDCList(@ApplicationContext context: Context): List<ExerciseDC> {
        val jsonFile = context.resources.openRawResource(R.raw.exercises).bufferedReader().use {
            it.readText()
        }

        val moshi = Moshi.Builder().build()
        val listType = Types.newParameterizedType(List::class.java, ExerciseDC::class.java)
        val adapter = moshi.adapter<List<ExerciseDC>>(listType)

        // ExerciseDC adapter is auto generated. All entries of all
        // enums must be annotated with @Json with its corresponding value in json file
        val exercises = adapter.fromJson(jsonFile)
            ?: throw JsonDataException("Failed to parse exercises.json file. Resource ID: ${R.raw.exercises}")

        return exercises
    }
}