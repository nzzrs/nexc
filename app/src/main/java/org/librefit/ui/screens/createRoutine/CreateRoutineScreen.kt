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

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AddCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Done
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
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
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import org.librefit.R
import org.librefit.data.ExerciseDC
import org.librefit.data.SharedViewModel
import org.librefit.db.Set
import org.librefit.db.Workout
import org.librefit.ui.components.ConfirmExitDialog
import org.librefit.ui.components.ExerciseDetailModalBottomSheet

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateRoutineScreen(
    sharedViewModel: SharedViewModel,
    navigateBack: () -> Unit,
    navigateAddExercise: () -> Unit
) {
    val viewModel : CreateRoutineScreenViewModel = viewModel()

    LaunchedEffect(sharedViewModel.getSelectedExercisesList()) {
        sharedViewModel.getSelectedExercisesList().forEach { exerciseDC ->
            viewModel.addExerciseWithSets(
                ExerciseWithSets(
                    exercise = exerciseDC,
                    sets = emptyList()
                )
            )
        }
    }

    var showExitDialog by remember { mutableStateOf(false) }

    BackHandler (enabled = !showExitDialog && !viewModel.isEmpty() ){
        showExitDialog = true
    }

    if(showExitDialog){
        ConfirmExitDialog(
            text = stringResource(id = R.string.label_exit_create_routine),
            onExit = {
                navigateBack()
                showExitDialog = false
                sharedViewModel.resetSelectedExercisesList()
            },
            onDismiss = { showExitDialog = false }
        )
    }

    Scaffold (
        topBar = {
            TopAppBar(
                title = {
                    Text(text = stringResource(id = R.string.label_routine))
                },
                navigationIcon = {
                    IconButton(
                        onClick = {
                            if (viewModel.isEmpty()) {
                                navigateBack()
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
                                Workout(title = viewModel.getTitle()), viewModel.exercisesWithSets.value
                            )
                            sharedViewModel.resetSelectedExercisesList()
                            navigateBack()
                        },
                        enabled = !viewModel.isTitleEmpty() && !viewModel.isEmpty()
                    ) {
                        Icon(
                            imageVector = Icons.Default.Done,
                            contentDescription = Icons.Default.Done.name
                        )
                    }
                }
            )
        }
    ){ innerPadding ->
        RoutineScreen(
            innerPadding,
            navigateAddExercise,
            viewModel
        )
    }
}

@Composable
private fun RoutineScreen(
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
        item{
            OutlinedTextField(
                value = viewModel.getTitle(),
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                onValueChange = { newTitle ->
                    viewModel.updateTitle(newTitle)
                },
                trailingIcon = {
                    if(viewModel.isTitleEmpty() || viewModel.isTitleTooLong()) {
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
                    when{
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
        if(viewModel.isEmpty()){
            item {
                Icon(
                    imageVector = ImageVector.vectorResource(id = R.drawable.ic_launcher_monochrome),
                    contentDescription = ""
                )
            }
            item{
                Row (modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center){
                    Text(
                        text = stringResource(id = R.string.label_start_creating_routine),
                        color = MaterialTheme.colorScheme.onBackground,
                        textAlign = TextAlign.Center
                    )
                }
            }
        } else {
            items(exercisesWithSets, key = {it.id}){ exerciseWithSets ->
                ExerciseCard(
                    exerciseWithSets = exerciseWithSets,
                    onDetail = {
                        selectedExercise = exerciseWithSets.exercise
                        isModalSheetOpen = true
                    },
                    onDelete = { viewModel.deleteExercise(exerciseWithSets.id) },
                    addSet = {
                        viewModel.addSetToExercise(exerciseWithSets.id)
                    },
                    updateSet = { set, value, mode ->
                        if(SetMode.WEIGHT == mode) {
                            viewModel.updateSet(
                                exerciseId = exerciseWithSets.id,
                                set = set,
                                weight = value,
                            )
                        } else if (SetMode.REPS == mode) {
                            viewModel.updateSet(
                                exerciseId = exerciseWithSets.id,
                                set = set,
                                reps = value ,
                            )
                        } else if(SetMode.TIME == mode){
                            /* TODO */
                        }
                    },
                    updateNote = {
                        //exerciseWithSets.note = it
                    }
                )
            }
        }

        item{
            TextButton(
                onClick = { navigateAddExercise() },
                colors = ButtonDefaults.buttonColors()
            ) {
                Icon(
                    imageVector = Icons.Default.AddCircle,
                    contentDescription = Icons.Default.AddCircle.name
                )
                Spacer( modifier = Modifier.weight(1f) )
                Text( text = stringResource(id = R.string.label_add_exercise) )
                Spacer( modifier = Modifier.weight(1.3f) )
            }
        }
    }

    /**
     * Opened by info icon (in the [ExerciseCard]), it shows the details of an exercise
      */

    if(isModalSheetOpen){
        ExerciseDetailModalBottomSheet(exercise = selectedExercise!!) { isModalSheetOpen = false }
    }
}


@Composable
private fun ExerciseCard(
    exerciseWithSets: ExerciseWithSets,
    onDetail : () -> Unit,
    onDelete : () -> Unit,
    addSet : () -> Unit,
    updateSet : (Set, Int, SetMode) -> Unit,
    updateNote : (String) -> Unit
) {
    Log.d("ExerciseItem", "Recomposing for exercise ID: ${exerciseWithSets.id}")
    var note by remember { mutableStateOf("") }

    ElevatedCard  (
        modifier = Modifier.fillMaxWidth()
    ){
        Column (
            modifier = Modifier
                .fillMaxSize()
                .padding(15.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ){
            Row (
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ){
                Text(
                    text = exerciseWithSets.exercise.name,
                    style = MaterialTheme.typography.headlineSmall,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f)
                )
                IconButton(onClick = { onDetail() }) {
                    Icon(imageVector = Icons.Default.Info, contentDescription = Icons.Default.Info.name)
                }
                IconButton(onClick = { onDelete() }) {
                    Icon(imageVector = Icons.Default.Delete, contentDescription = Icons.Default.Delete.name)
                }
            }

            //Notes
            OutlinedTextField(
                modifier = Modifier.fillMaxWidth(),
                label = { Text(text = stringResource(id = R.string.label_notes))},
                value = note,
                onValueChange = {
                    note = it
                    updateNote(it)
                }
            )

            Spacer(modifier = Modifier.height(10.dp))

            HorizontalDivider()

            //Headline set
            Row(
                modifier = Modifier
                    .height(40.dp)
                    .fillMaxWidth()
                    .padding(start = 10.dp, end = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(text = stringResource(id = R.string.label_exercise_card_set), color = MaterialTheme.colorScheme.secondary)
                Text(text = stringResource(id = R.string.label_exercise_card_reps), color = MaterialTheme.colorScheme.secondary)
                Text(text = stringResource(id = R.string.label_exercise_card_weight), color = MaterialTheme.colorScheme.secondary)
            }
            //Sets
            exerciseWithSets.sets.forEachIndexed { index, set ->

                var repValue by rememberSaveable { mutableStateOf("0") }
                var weightValue by rememberSaveable { mutableStateOf("0") }
                var repError by rememberSaveable { mutableStateOf(false) }
                var weightError by rememberSaveable { mutableStateOf(false) }

                val i = index + 1
                Row(
                    modifier = Modifier
                        .height(80.dp)
                        .fillMaxWidth()
                        .padding(start = 20.dp, end = 10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ){
                    Text("$i", color = MaterialTheme.colorScheme.onSurface)

                    Spacer(modifier = Modifier.weight(2.5f))

                    //Reps
                    OutlinedTextField(
                        modifier = Modifier.width(80.dp),
                        value = repValue,
                        onValueChange = { string ->
                            if(string.all { it.isDigit() } ) {
                                if( string.length > 4 ){
                                    repError = true
                                } else {
                                    repError = false
                                    repValue = string
                                    updateSet(set, repValue.ifEmpty{"0"}.toInt(), SetMode.REPS)
                                }
                            }
                        },
                        singleLine = true,
                        isError = repError,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    )

                    Spacer(modifier = Modifier.weight(1f))

                    //Weight
                    OutlinedTextField(
                        modifier = Modifier.width(100.dp),
                        value = weightValue,
                        suffix = { Text("kg")},
                        onValueChange = { string ->
                            if(string.all { it.isDigit() } ) {
                                if( string.length > 4){
                                    weightError = true
                                } else {
                                    weightValue = string
                                    weightError = false
                                    updateSet(set, weightValue.ifEmpty{"0"}.toInt(), SetMode.WEIGHT)
                                }
                            }
                        },
                        singleLine = true,
                        isError = weightError,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                    )

                }
            }

            Spacer(Modifier.height(10.dp))

            HorizontalDivider()

            TextButton(
                onClick = addSet,
                colors = ButtonDefaults.textButtonColors(
                    containerColor = MaterialTheme.colorScheme.secondaryContainer,
                    contentColor = MaterialTheme.colorScheme.onSecondaryContainer
                )
            ) {
                Icon(
                    imageVector = Icons.Default.AddCircle,
                    contentDescription = Icons.Default.AddCircle.name
                )
                Spacer( modifier = Modifier.weight(1f) )
                Text( text = stringResource(id = R.string.label_exercise_card_add) )
                Spacer( modifier = Modifier.weight(1.3f) )
            }
        }
    }
}

@Preview
@Composable
private fun CreateRoutineScreenPreview(){
    CreateRoutineScreen( viewModel(), {  }, {  } )
}