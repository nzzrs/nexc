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

package org.librefit.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Done
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import org.librefit.R
import org.librefit.data.Category
import org.librefit.data.ExerciseDC
import org.librefit.data.ExerciseWithSets
import org.librefit.data.Level
import org.librefit.data.SetMode
import org.librefit.db.Set
import java.util.Locale
import kotlin.text.ifEmpty
import kotlin.text.toInt

@Composable
fun ExerciseCard(
    exerciseWithSets: ExerciseWithSets,
    completedSet: (Boolean) -> Unit,
    addSet: () -> Unit,
    onDetail: () -> Unit,
    onDelete: () -> Unit,
    updateSet: (Set, Int, SetMode) -> Unit,
    workout: Boolean = false
) {
    var note by remember { mutableStateOf(exerciseWithSets.note) }

    var setMode by remember { mutableStateOf(exerciseWithSets.setMode) }

    ElevatedCard {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(15.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = exerciseWithSets.exercise.name,
                    style = MaterialTheme.typography.headlineSmall,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f)
                )
                IconButton(onClick = onDetail) {
                    Icon(
                        imageVector = Icons.Default.Info,
                        contentDescription = stringResource(R.string.label_info)
                    )
                }
                IconButton(onClick = onDelete) {
                    Icon(
                        imageVector = Icons.Default.Delete,
                        contentDescription = stringResource(R.string.label_delete)
                    )
                }
            }

            OutlinedTextField(
                modifier = Modifier.fillMaxWidth(),
                label = { Text(text = stringResource(id = R.string.label_notes)) },
                value = note,
                onValueChange = {
                    note = it
                    exerciseWithSets.note = it
                }
            )

            Spacer(modifier = Modifier.height(10.dp))

            //Rest timer
//            Row(
//                modifier = Modifier.fillMaxWidth(),
//                horizontalArrangement = Arrangement.Center
//            ) {
//                TextButton(
//                    onClick = {
//
//                    },
//                    colors = ButtonDefaults.textButtonColors(
//                        containerColor = MaterialTheme.colorScheme.secondaryContainer,
//                        contentColor = MaterialTheme.colorScheme.onSecondaryContainer
//                    )
//                ) {
//                    Icon(
//                        imageVector = ImageVector.vectorResource(R.drawable.ic_timer),
//                        contentDescription = stringResource(R.string.label_rest_time)
//                    )
//                    Text("Rest: 1 minute and 30 seconds")
//                }
//            }

            Spacer(modifier = Modifier.height(10.dp))

            // Set mode selection
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceAround,
                verticalAlignment = Alignment.CenterVertically
            ) {
                SingleChoiceSegmentedButtonRow {
                    SetMode.entries.forEachIndexed { index, mode ->
                        SegmentedButton(
                            selected = setMode == mode,
                            onClick = {
                                setMode = mode
                                exerciseWithSets.setMode = mode
                            },
                            shape = SegmentedButtonDefaults.itemShape(
                                index = index,
                                count = SetMode.entries.size
                            )
                        ) {
                            Text(
                                text = mode.name.lowercase().replaceFirstChar { it.uppercase() },
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                    }

                }
            }

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
                Text(
                    text = stringResource(id = R.string.label_exercise_card_set),
                    color = MaterialTheme.colorScheme.secondary
                )
                if (setMode == SetMode.TIME) {
                    Text(
                        text = "Time",
                        color = MaterialTheme.colorScheme.secondary
                    )
                } else {
                    Text(
                        text = stringResource(id = R.string.label_exercise_card_reps),
                        color = MaterialTheme.colorScheme.secondary
                    )
                    if (setMode == SetMode.WEIGHT) {
                        Text(
                            text = stringResource(id = R.string.label_exercise_card_weight),
                            color = MaterialTheme.colorScheme.secondary
                        )
                    }
                }
                if (workout) {
                    Icon(
                        imageVector = Icons.Default.Done,
                        contentDescription = null
                    )
                }
            }

            //Sets
            exerciseWithSets.sets.forEachIndexed { i, set ->
                var checked by rememberSaveable { mutableStateOf(false) }

                var time = if (set.elapsedTime != null) {
                    set.elapsedTime.toString()
                } else {
                    "0"
                }

                var timeValue by remember { mutableStateOf(time) }
                var repValue by remember { mutableStateOf(if (set.reps != null) set.reps.toString() else "0") }
                var weightValue by remember { mutableStateOf(if (set.weight != null) set.weight.toString() else "0") }
                var timeError by remember { mutableStateOf(false) }
                var repError by remember { mutableStateOf(false) }
                var weightError by remember { mutableStateOf(false) }

                Row(
                    modifier = Modifier
                        .clip(
                            RoundedCornerShape(
                                topEndPercent = if (i == 0) 20 else 0,
                                topStartPercent = if (i == 0) 20 else 0,
                                bottomEndPercent = if (i == exerciseWithSets.sets.size - 1) 20 else 0,
                                bottomStartPercent = if (i == exerciseWithSets.sets.size - 1) 20 else 0
                            )
                        )
                        .background(if (checked) MaterialTheme.colorScheme.inversePrimary.copy(0.3f) else Color.Transparent)
                        .height(80.dp)
                        .fillMaxWidth()
                        .padding(start = 15.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = "${i + 1}",
                        color = MaterialTheme.colorScheme.onSurface,
                        modifier = Modifier.padding(end = 20.dp)
                    )

                    if (setMode == SetMode.TIME) {
                        //Time
                        OutlinedTextField(
                            modifier = Modifier.width(80.dp),
                            value = String.format(Locale.getDefault(),"%s:%s", timeValue.padStart(4,'0').substring(0,2), timeValue.padStart(4,'0').substring(2,4)),
                            onValueChange = { string ->
                                if (string.all { it.isDigit() }) {
                                    if (string.length > 4) {
                                        timeError = true
                                    } else {
                                        timeError = false
                                        timeValue = string.ifEmpty { "0" }
                                        updateSet(set, timeValue.toInt(), SetMode.TIME)
                                    }
                                }
                            },
                            singleLine = true,
                            isError = timeError,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        )
                    } else {
                        //Reps
                        OutlinedTextField(
                            modifier = Modifier.width(80.dp),
                            value = repValue,
                            onValueChange = { string ->
                                if (string.all { it.isDigit() }) {
                                    if (string.length > 4) {
                                        repError = true
                                    } else {
                                        repError = false
                                        repValue = string.ifEmpty { "0" }
                                        updateSet(set, repValue.toInt(), SetMode.WEIGHT)
                                    }
                                }
                            },
                            singleLine = true,
                            isError = repError,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        )
                        if (setMode == SetMode.WEIGHT) {
                            //Weight
                            OutlinedTextField(
                                modifier = Modifier.width(100.dp),
                                value = weightValue,
                                suffix = { Text("kg") },
                                onValueChange = { string ->
                                    if (string.all { it.isDigit() }) {
                                        if (string.length > 4) {
                                            weightError = true
                                        } else {
                                            weightValue = string
                                            weightError = false
                                            updateSet(
                                                set,
                                                weightValue.ifEmpty { "0" }.toInt(),
                                                SetMode.WEIGHT
                                            )
                                        }
                                    }
                                },
                                singleLine = true,
                                isError = weightError,
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                            )
                        }
                    }





                    if (workout) {
                        Checkbox(
                            checked = checked,
                            onCheckedChange = {
                                checked = it
                                completedSet(it)
                            }
                        )
                    }

                }
            }

            Spacer(modifier = Modifier.height(10.dp))

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
                    contentDescription = null
                )
                Spacer(modifier = Modifier.weight(1f))
                Text(text = stringResource(id = R.string.label_exercise_card_add))
                Spacer(modifier = Modifier.weight(1.3f))
            }
        }
    }
}

@Preview
@Composable
private fun ExerciseCardPreview() {
    ExerciseCard(
        ExerciseWithSets(
            exercise = ExerciseDC(
                id = "",
                name = "Exercise",
                level = Level.INTERMEDIATE,
                primaryMuscles = emptyList(),
                secondaryMuscles = emptyList(),
                instructions = listOf(""),
                category = Category.POWERLIFTING,
                images = listOf("")
            ),
            sets = listOf(Set(exerciseId = 0)),
            setMode = SetMode.REPS
        ),
        {},
        {},
        {},
        {},
        { i, s, j -> },
        false
    )
}