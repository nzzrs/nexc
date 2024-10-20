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

package org.librefit

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.launch
import org.librefit.data.DataStoreManager
import org.librefit.data.ExerciseDC
import org.librefit.data.ExerciseDeserializer
import org.librefit.nav.NavigationHost
import org.librefit.ui.theme.LibreFitTheme
import java.io.BufferedReader
import java.io.InputStream

class MainActivity : AppCompatActivity() {
    private lateinit var userPreferences: DataStoreManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        userPreferences = DataStoreManager(this)

        var list = emptyList<ExerciseDC>()

        lifecycleScope.launch {
            list = loadExercises(resources.openRawResource(R.raw.exercises))
        }

        setContent {
            LibreFitTheme(userPreferences){
                NavigationHost(
                    list = list,
                    userPreferences = userPreferences
                )
            }
        }
    }
}

private fun loadExercises(inputStream: InputStream) : List<ExerciseDC> {
    val gson = GsonBuilder()
        .registerTypeAdapter(ExerciseDC::class.java, ExerciseDeserializer())
        .create()
    val jsonString = inputStream.bufferedReader().use(BufferedReader::readText)
    val listType = object : TypeToken<List<ExerciseDC>>() {}.type

    return gson.fromJson(jsonString, listType)
}

