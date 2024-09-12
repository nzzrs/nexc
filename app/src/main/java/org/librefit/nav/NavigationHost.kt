package org.librefit.nav

import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import org.librefit.data.ExerciseDC
import org.librefit.data.SharedViewModel
import org.librefit.ui.screens.AboutScreen
import org.librefit.ui.screens.AddExerciseScreen
import org.librefit.ui.screens.CreateRoutineScreen
import org.librefit.ui.screens.MainScreen
import org.librefit.ui.screens.SettingsScreen
import org.librefit.ui.screens.WorkoutScreen
import org.librefit.util.DataStoreManager

@Composable
fun NavigationHost(list: List<ExerciseDC>, userPreferences: DataStoreManager, sharedViewModel : SharedViewModel) {

    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = Destination.MainScreen,
        enterTransition = { scaleIn(tween(450), 0.8f) + fadeIn(tween(400)) },
        exitTransition = { scaleOut(tween(450), 1.2f)  },
        popEnterTransition = { scaleIn(tween(450),1.2f)  },
        popExitTransition = { scaleOut(tween(450), 0.8f) + fadeOut(tween(400)) }
    ){
        composable<Destination.MainScreen> {
            MainScreen(navController = navController, sharedViewModel = sharedViewModel)
        }
        composable<Destination.CreateRoutineScreen> {
            CreateRoutineScreen(
                viewModel = sharedViewModel,
                navigateBack = { navController.popBackStack() },
                navigateAddExercise = { navController.navigate(Destination.AddExerciseScreen )}
            )
        }
        composable<Destination.AddExerciseScreen> {
            AddExerciseScreen(
                list = list,
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
            AboutScreen(navigateBack = { navController.popBackStack() })
        }
        composable<Destination.WorkoutScreen> {
            WorkoutScreen(
                userPreferences = userPreferences,
                sharedViewModel = sharedViewModel,
                workoutId = it.toRoute<Destination.WorkoutScreen>().workoutId,
                navController = navController,
                list = list
            )
        }
    }
}