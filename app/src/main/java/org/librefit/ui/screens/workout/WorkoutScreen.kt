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

package org.librefit.ui.screens.workout

import android.app.Activity
import android.view.WindowManager
import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.animateIntAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AddCircle
import androidx.compose.material.icons.filled.Done
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.BottomAppBar
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ProgressIndicatorDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.text.intl.Locale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import org.librefit.R
import org.librefit.data.DataStoreManager
import org.librefit.data.ExerciseDC
import org.librefit.data.ExerciseWithSets
import org.librefit.data.SetMode
import org.librefit.data.SharedViewModel
import org.librefit.nav.Destination
import org.librefit.ui.components.ConfirmExitDialog
import org.librefit.ui.components.ExerciseCard
import org.librefit.ui.components.ExerciseDetailModalBottomSheet

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WorkoutScreen(
    userPreferences: DataStoreManager,
    workoutId: Int = 0,
    navController: NavHostController,
    list: List<ExerciseDC>,
    sharedViewModel: SharedViewModel
) {
    val viewModel: WorkoutScreenViewModel = viewModel()

    val keepWorkoutScreenOn = userPreferences.workoutScreenOn.collectAsState(initial = true).value

    val context = LocalContext.current

    if (keepWorkoutScreenOn) {
        DisposableEffect(key1 = Unit) {
            val window = (context as Activity).window

            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

            onDispose {
                window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            }
        }
    }


    var showExitDialog by remember { mutableStateOf(false) }

    if (showExitDialog) {
        ConfirmExitDialog(
            text = stringResource(id = R.string.label_exit_workout),
            onExit = {
                navController.popBackStack()
                showExitDialog = false
            },
            onDismiss = { showExitDialog = false }
        )
    }


    viewModel.getExercisesFromWorkout(workoutId)


    LaunchedEffect(workoutId) {
        viewModel.exercises.value.forEach { exercise ->
            val item = list.associateBy { it.id }[exercise.exerciseId]
            if (item != null) {
                viewModel.getSetsFromExercise(exercise.id)

                viewModel.addExerciseWithSets(
                    ExerciseWithSets(
                        exercise = item,
                        exerciseId = exercise.id,
                        note = exercise.notes!!
                    )
                )
            }
        }
    }

    LaunchedEffect(Unit) {
        sharedViewModel.getSelectedExercisesList().forEach { exerciseDC ->
            viewModel.addExerciseWithSets(
                ExerciseWithSets(
                    exercise = exerciseDC
                )
            )
        }
    }

    val exercisesWithSets by viewModel.exercisesWithSets.collectAsState()

    BackHandler(enabled = !showExitDialog && exercisesWithSets.isNotEmpty()) {
        showExitDialog = true
    }

    var isModalSheetOpen by remember { mutableStateOf(false) }

    /**
     * Used to display information about the selected exercise in [ExerciseDetailModalBottomSheet]
     */
    var selectedExercise by remember { mutableStateOf<ExerciseDC?>(null) }

    val animatedProgress = animateFloatAsState(
        targetValue = viewModel.progress,
        animationSpec = ProgressIndicatorDefaults.ProgressAnimationSpec,
        label = ""
    ).value

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.label_workout)) },
                navigationIcon = {
                    IconButton(
                        onClick = { navController.popBackStack() }
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Default.ArrowBack,
                            contentDescription = stringResource(id = R.string.label_navigate_back)
                        )
                    }
                },
                actions = {
                    IconButton(
                        onClick = {
//                            viewModel.saveExercisesWithWorkout(
//                                workout = Workout(title = viewModel.getTitle()),
//                                exercises = viewModel.exercisesWithSets.value
//                            )
                            navController.popBackStack()
                        },
                        enabled = exercisesWithSets.isNotEmpty()
                    ) {
                        Icon(
                            imageVector = Icons.Default.Done,
                            contentDescription = Icons.Default.Done.name
                        )
                    }
                }
            )
        },
        bottomBar = {
            BottomAppBar(
                modifier = Modifier.height(120.dp)
            ) {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    LinearProgressIndicator(
                        progress = { animatedProgress },
                        modifier = Modifier.fillMaxWidth(),
                    )
                    Stopwatch(viewModel)
                }
            }
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .padding(paddingValues)
                .padding(start = 15.dp, end = 15.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (exercisesWithSets.isEmpty()) {
                item {
                    Icon(
                        imageVector = ImageVector.vectorResource(id = R.drawable.ic_launcher_monochrome),
                        contentDescription = ""
                    )
                }
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Text(
                            text = stringResource(id = R.string.label_add_to_empty_workout),
                            color = MaterialTheme.colorScheme.onBackground,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            } else {
                items(exercisesWithSets, key = { it.id }) { exerciseWithSets ->
                    ExerciseCard(
                        exerciseWithSets = exerciseWithSets,
                        onDetail = {
                            selectedExercise = exerciseWithSets.exercise
                            isModalSheetOpen = true
                        },
                        onDelete = {
                            viewModel.deleteExercise(exerciseWithSets.id)
                        },
                        completedSet = { completed ->
                            viewModel.addCompletedSet(completed)
                        },
                        addSet = {
                            viewModel.addSetToExercise(exerciseWithSets.id)
                        },
                        updateSet = { set, value, mode ->
                            if (SetMode.WEIGHT == mode) {
                                viewModel.updateSet(
                                    exerciseId = exerciseWithSets.id,
                                    set = set,
                                    weight = value
                                )
                            } else if (SetMode.REPS == mode) {
                                viewModel.updateSet(
                                    exerciseId = exerciseWithSets.id,
                                    set = set,
                                    reps = value,
                                )
                            } else if (SetMode.TIME == mode) {
                                /* TODO */
                            }
                        },
                        workout = true
                    )
                }
            }

            item { Spacer(modifier = Modifier.height(5.dp)) }

            item {
                TextButton(
                    onClick = { navController.navigate(Destination.AddExerciseScreen) },
                    colors = ButtonDefaults.buttonColors(),
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.Center,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.AddCircle,
                            contentDescription = Icons.Default.AddCircle.name
                        )
                        Spacer(Modifier.width(10.dp))
                        Text(text = stringResource(id = R.string.label_add_exercise))
                    }
                }
            }
        }
    }

    if (isModalSheetOpen) {
        ExerciseDetailModalBottomSheet(exercise = selectedExercise!!) { isModalSheetOpen = false }
    }
}

@Composable
private fun Stopwatch(viewModel: WorkoutScreenViewModel) {

    val animatedExpansion = animateIntAsState(
        targetValue = if (viewModel.isTimerRunning) 80 else 55,
        label = ""
    )

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column(
            modifier = Modifier.weight(0.4f),
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = stringResource(R.string.label_elapsed_time),
                style = MaterialTheme.typography.bodySmall
            )
            Text(
                text = formatTime(viewModel.timeElapsed),
                color = if (viewModel.pulsingTimer()) Color.Transparent else Color.Unspecified
            )
        }
        Box(
            modifier = Modifier
                .height(70.dp)
                .weight(0.2f),
            contentAlignment = Alignment.Center
        ) {
            FilledIconButton(
                onClick = {
                    if (viewModel.isTimerRunning) viewModel.stopTimer() else viewModel.startTimer()
                },
                modifier = Modifier.size(animatedExpansion.value.dp)
            ) {
                Icon(
                    imageVector = if (viewModel.isTimerRunning) ImageVector.vectorResource(id = R.drawable.ic_pause)
                    else Icons.Default.PlayArrow,
                    contentDescription = stringResource(if (viewModel.isTimerRunning) R.string.label_pause else R.string.label_play),
                    modifier = Modifier.size(30.dp)
                )
            }
        }
        Spacer(modifier = Modifier.weight(0.4f))
    }
}

private fun formatTime(seconds: Int): String {
    val hours = seconds / 3600
    val minutes = (seconds % 3600) / 60
    val secs = seconds % 60
    return String.format(Locale.current.platformLocale, "%02d:%02d:%02d", hours, minutes, secs)
}