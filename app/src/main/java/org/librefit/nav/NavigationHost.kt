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

package org.librefit.nav

import android.content.Context
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import org.librefit.R
import org.librefit.data.DataStoreManager
import org.librefit.data.ExerciseDC
import org.librefit.data.ExerciseDeserializer
import org.librefit.data.SharedViewModel
import org.librefit.ui.screens.AddExerciseScreen
import org.librefit.ui.screens.MainScreen
import org.librefit.ui.screens.SettingsScreen
import org.librefit.ui.screens.about.AboutScreen
import org.librefit.ui.screens.about.LicenseScreen
import org.librefit.ui.screens.createRoutine.CreateRoutineScreen
import org.librefit.ui.screens.workout.WorkoutScreen

@Composable
fun NavigationHost(userPreferences: DataStoreManager) {

    val navController = rememberNavController()

    val sharedViewModel: SharedViewModel = viewModel()

    val exerciseList = remember { mutableStateOf(emptyList<ExerciseDC>()) }

    val context = LocalContext.current

    LaunchedEffect(Unit) {
        exerciseList.value = loadExercises(context)
    }

    NavHost(
        navController = navController,
        startDestination = Destination.MainScreen,
        enterTransition = { scaleIn(tween(400), 0.8f) + fadeIn(tween(350)) },
        exitTransition = { scaleOut(tween(400), 1.2f) },
        popEnterTransition = { scaleIn(tween(400), 1.2f) },
        popExitTransition = { scaleOut(tween(400), 0.8f) + fadeOut(tween(350)) }
    ) {
        composable<Destination.MainScreen> {
            MainScreen(navController = navController)
        }
        composable<Destination.CreateRoutineScreen> {
            CreateRoutineScreen(
                sharedViewModel = sharedViewModel,
                navController = navController
            )
        }
        composable<Destination.AddExerciseScreen> {
            AddExerciseScreen(
                exerciseList = exerciseList.value,
                navigateBack = { navController.popBackStack() },
                viewModel = sharedViewModel
            )
        }
        composable<Destination.SettingsScreen> {
            SettingsScreen(
                userPreferences = userPreferences,
                navigateBack = { navController.popBackStack() }
            )
        }
        composable<Destination.AboutScreen> {
            AboutScreen(navController = navController)
        }
        composable<Destination.LicenseScreen> {
            LicenseScreen(navigateBack = { navController.popBackStack() })
        }
        composable<Destination.WorkoutScreen> {
            WorkoutScreen(
                userPreferences = userPreferences,
                workoutId = it.toRoute<Destination.WorkoutScreen>().workoutId,
                navController = navController,
                list = exerciseList.value,
                sharedViewModel = sharedViewModel
            )
        }
    }
}

private fun loadExercises(context: Context): List<ExerciseDC> {
    val inputStream = context.resources.openRawResource(R.raw.exercises)

    return inputStream.bufferedReader().use { reader ->
        val gson = GsonBuilder()
            .registerTypeAdapter(ExerciseDC::class.java, ExerciseDeserializer())
            .create()
        val listType = object : TypeToken<List<ExerciseDC>>() {}.type

        gson.fromJson(reader, listType)
    }
}
