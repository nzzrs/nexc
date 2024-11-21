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

package org.librefit.ui.screens.createRoutine

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AddCircle
import androidx.compose.material.icons.filled.Done
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.rememberNavController
import org.librefit.R
import org.librefit.data.ExerciseDC
import org.librefit.data.ExerciseWithSets
import org.librefit.data.SetMode
import org.librefit.data.SharedViewModel
import org.librefit.db.Workout
import org.librefit.nav.Destination
import org.librefit.ui.components.ConfirmExitDialog
import org.librefit.ui.components.ExerciseCard
import org.librefit.ui.components.ExerciseDetailModalBottomSheet

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateRoutineScreen(
    sharedViewModel: SharedViewModel,
    navController: NavHostController
) {
    val viewModel: CreateRoutineScreenViewModel = viewModel()

    LaunchedEffect(Unit) {
        sharedViewModel.getSelectedExercisesList().forEach { exerciseDC ->
            viewModel.addExerciseWithSets(
                ExerciseWithSets(
                    exercise = exerciseDC
                )
            )
        }
    }

    var showExitDialog by remember { mutableStateOf(false) }

    BackHandler(enabled = !showExitDialog && !viewModel.isListEmpty()) {
        showExitDialog = true
    }

    if (showExitDialog) {
        ConfirmExitDialog(
            text = stringResource(id = R.string.label_exit_create_routine),
            onExit = {
                navController.popBackStack()
                showExitDialog = false
            },
            onDismiss = { showExitDialog = false }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(text = stringResource(id = R.string.label_routine))
                },
                navigationIcon = {
                    IconButton(
                        onClick = {
                            if (viewModel.isListEmpty()) {
                                navController.popBackStack()
                            } else {
                                showExitDialog = true
                            }
                        }
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
                            viewModel.saveExercisesWithWorkout(
                                workout = Workout(title = viewModel.getTitle()),
                                exercises = viewModel.exercisesWithSets.value
                            )
                            navController.popBackStack()
                        },
                        enabled = !viewModel.isTitleEmpty() && !viewModel.isListEmpty()
                    ) {
                        Icon(
                            imageVector = Icons.Default.Done,
                            contentDescription = Icons.Default.Done.name
                        )
                    }
                }
            )
        }
    ) { innerPadding ->
        CreateRoutineScreen(
            innerPadding,
            { navController.navigate(Destination.AddExerciseScreen) },
            viewModel
        )
    }
}

@Composable
private fun CreateRoutineScreen(
    innerPadding: PaddingValues,
    navigateAddExercise: () -> Unit,
    viewModel: CreateRoutineScreenViewModel
) {

    /**
     * Used to display information about the selected exercise in [ExerciseDetailModalBottomSheet]
     */
    var selectedExercise by remember { mutableStateOf<ExerciseDC?>(null) }
    var isModalSheetOpen by remember { mutableStateOf(false) }

    val exercisesWithSets by viewModel.exercisesWithSets.collectAsState()

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(paddingValues = innerPadding)
            .padding(start = 15.dp, end = 15.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        item {
            OutlinedTextField(
                value = viewModel.getTitle(),
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                onValueChange = { newTitle ->
                    viewModel.updateTitle(newTitle)
                },
                trailingIcon = {
                    if (viewModel.isTitleEmpty() || viewModel.isTitleTooLong()) {
                        Icon(
                            imageVector = Icons.Default.Warning,
                            contentDescription = Icons.Default.Warning.name
                        )
                    }
                },
                isError = viewModel.isTitleEmpty() || viewModel.isTitleTooLong(),
                label = { Text(text = stringResource(id = R.string.label_text_field_title)) },
                colors = OutlinedTextFieldDefaults.colors(),
                supportingText = {
                    when {
                        viewModel.isTitleTooLong() -> {
                            Text(stringResource(R.string.error_title_length_exceeded))
                        }

                        viewModel.isTitleEmpty() -> {
                            Text(stringResource(R.string.error_title_empty))
                        }
                    }
                }
            )
        }
        if (viewModel.isListEmpty()) {
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
                        text = stringResource(id = R.string.label_start_creating_routine),
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
                    addSet = {
                        viewModel.addSetToExercise(exerciseWithSets.id)
                    },
                    updateSet = { set, value, mode ->
                        if (SetMode.WEIGHT == mode) {
                            viewModel.updateSet(
                                exerciseId = exerciseWithSets.id,
                                set = set,
                                weight = value,
                            )
                        } else if (SetMode.REPS == mode) {
                            viewModel.updateSet(
                                exerciseId = exerciseWithSets.id,
                                set = set,
                                reps = value,
                            )
                        } else if (SetMode.TIME == mode) {
                            viewModel.updateSet(
                                exerciseId = exerciseWithSets.id,
                                set = set,
                                time = value,
                            )
                        }
                    },
                    completedSet = {}
                )
            }
        }

        item {
            TextButton(
                onClick = navigateAddExercise ,
                colors = ButtonDefaults.buttonColors(),
            ) {
                Row (
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ){
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

    /**
     * Opened by info icon (in the [ExerciseCard]), it shows the details of an exercise
     */

    if (isModalSheetOpen) {
        ExerciseDetailModalBottomSheet(exercise = selectedExercise!!) { isModalSheetOpen = false }
    }
}

@Preview
@Composable
private fun CreateRoutineScreenPreview() {
    CreateRoutineScreen(viewModel(), rememberNavController())
}