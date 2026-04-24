/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.nav

import androidx.compose.animation.ExperimentalSharedTransitionApi
import androidx.compose.animation.SharedTransitionLayout
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import org.nexc.features.MainScreen
import org.nexc.features.about.AboutScreen
import org.nexc.features.about.DependenciesScreen
import org.nexc.features.about.LicenseScreen
import org.nexc.features.about.PrivacyScreen
import org.nexc.features.about.TutorialScreen
import org.nexc.features.about.WelcomeScreen
import org.nexc.features.beforeSaving.BeforeSavingScreen
import org.nexc.features.calendar.CalendarScreen
import org.nexc.features.editExercise.EditExerciseScreen
import org.nexc.features.editWorkout.EditWorkoutScreen
import org.nexc.features.exercises.ExercisesScreen
import org.nexc.features.infoExercise.InfoExerciseScreen
import org.nexc.features.infoWorkout.InfoWorkoutScreen
import org.nexc.features.measurements.MeasurementScreen
import org.nexc.features.settings.BackupScreen
import org.nexc.features.settings.SettingsScreen
import org.nexc.features.shared.RequestPermissionScreen
import org.nexc.features.shared.SharedViewModel
import org.nexc.features.shared.SuccessScreen
import org.nexc.features.statistics.StatisticsScreen
import org.nexc.features.workout.WorkoutScreen

@OptIn(ExperimentalSharedTransitionApi::class)
@Composable
fun NavigationHost() {

    val navController = rememberNavController()

    val sharedViewModel: SharedViewModel = hiltViewModel()

    val showWelcomeScreen by sharedViewModel.showWelcomeScreen.collectAsStateWithLifecycle()

    val requestPermissionNextTime by sharedViewModel.requestPermissionNextTime.collectAsStateWithLifecycle()

    val startDestination = remember {
        if (showWelcomeScreen) Route.WelcomeScreen else Route.MainScreen
    }

    SharedTransitionLayout {
        NavHost(
            navController = navController,
            startDestination = startDestination,
            enterTransition = { scaleIn(tween(300), 0.9f) + fadeIn(tween(200)) },
            exitTransition = { scaleOut(tween(300), 1.1f) },
            popEnterTransition = { scaleIn(tween(300), 1.1f) },
            popExitTransition = { scaleOut(tween(300), 0.9f) + fadeOut(tween(200)) }
        ) {
            composable<Route.BackupScreen> {
                BackupScreen(navigateBack = navController::navigateUp)
            }
            composable<Route.AboutScreen> {
                AboutScreen(navController = navController)
            }
            composable<Route.BeforeSavingScreen> {
                BeforeSavingScreen(
                    navController = navController,
                    animatedVisibilityScope = this
                )
            }
            composable<Route.CalendarScreen> {
                CalendarScreen(
                    navController = navController,
                    animatedVisibilityScope = this
                )
            }
            composable<Route.EditExerciseScreen> {
                EditExerciseScreen(
                    navController = navController,
                    id = it.toRoute<Route.EditExerciseScreen>().id,
                    exerciseDCid = it.toRoute<Route.EditExerciseScreen>().exerciseDCid,
                    animatedVisibilityScope = this
                )
            }
            composable<Route.EditWorkoutScreen> {
                EditWorkoutScreen(
                    sharedViewModel = sharedViewModel,
                    navController = navController,
                    animatedVisibilityScope = this
                )
            }
            composable<Route.ExercisesScreen> {
                ExercisesScreen(
                    addExercises = it.toRoute<Route.ExercisesScreen>().addExercises,
                    navController = navController,
                    sharedViewModel = sharedViewModel,
                    animatedVisibilityScope = this
                )
            }
            composable<Route.InfoExerciseScreen> {
                InfoExerciseScreen(
                    id = it.toRoute<Route.InfoExerciseScreen>().id,
                    animatedVisibilityScope = this,
                    navController = navController
                )
            }
            composable<Route.InfoWorkoutScreen> {
                InfoWorkoutScreen(
                    animatedVisibilityScope = this,
                    navController = navController,
                    workoutId = it.toRoute<Route.InfoWorkoutScreen>().workoutId,
                )
            }
            composable<Route.MainScreen> {
                MainScreen(
                    navController = navController,
                    animatedVisibilityScope = this
                )
            }
            composable<Route.MeasurementScreen> {
                MeasurementScreen(navigateBack = navController::navigateUp)
            }
            composable<Route.PrivacyScreen> {
                PrivacyScreen(navigateBack = navController::navigateUp)
            }
            composable<Route.LibrariesScreen> {
                DependenciesScreen(navigateBack = navController::navigateUp)
            }
            composable<Route.LicenseScreen> {
                LicenseScreen(navigateBack = navController::navigateUp)
            }
            composable<Route.RequestPermissionScreen> {
                RequestPermissionScreen(
                    navController = navController,
                    workoutId = it.toRoute<Route.RequestPermissionScreen>().workoutId,
                    requestPermissionNextTime = requestPermissionNextTime,
                    saveRequestPermissionAgainPreference = sharedViewModel::saveRequestPermissionAgainPreference
                )
            }
            composable<Route.SettingsScreen> {
                SettingsScreen(navController = navController)
            }
            composable<Route.SuccessScreen> {
                SuccessScreen(
                    route = it.toRoute(),
                    navController = navController
                )
            }
            composable<Route.StatisticsScreen> {
                StatisticsScreen(navController = navController)
            }
            composable<Route.TutorialScreen> {
                TutorialScreen(
                    tutorialContent = it.toRoute<Route.TutorialScreen>().tutorialContent,
                    fromWelcomeScreen = it.toRoute<Route.TutorialScreen>().fromWelcomeScreen,
                    navController = navController
                )
            }
            composable<Route.WelcomeScreen> {
                WelcomeScreen(
                    navController = navController,
                    doNotShowWelcomeScreenAgain = sharedViewModel::doNotShowWelcomeScreenAgain
                )
            }
            composable<Route.WorkoutScreen> {
                WorkoutScreen(
                    navController = navController,
                    sharedViewModel = sharedViewModel,
                    animatedVisibilityScope = this
                )
            }
        }
    }

}