/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.models.dto

import kotlinx.serialization.Serializable
import org.nexc.core.db.entity.LocalDateTimeSerializer
import org.nexc.core.enums.WorkoutState
import org.nexc.core.enums.SetMode
import java.time.LocalDateTime

import org.nexc.core.models.UiExerciseWithSets
import org.nexc.core.models.UiWorkout

@Serializable
data class WorkoutExportDTO(
    val title: String,
    val notes: String = "",
    val timeElapsed: Int = 0,
    @Serializable(with = LocalDateTimeSerializer::class)
    val created: LocalDateTime = LocalDateTime.now(),
    @Serializable(with = LocalDateTimeSerializer::class)
    val completed: LocalDateTime? = null,
    val state: String = "COMPLETED",
    val exercises: List<ExerciseExportDTO> = emptyList()
)

fun UiWorkout.toExportDTO(exercises: List<UiExerciseWithSets>) = WorkoutExportDTO(
    title = title,
    notes = notes,
    timeElapsed = timeElapsed,
    created = created,
    completed = completed,
    state = state.name,
    exercises = exercises.map { it.toExportDTO() }
)

@Serializable
data class ExerciseExportDTO(
    val exerciseId: String,
    val name: String,
    val notes: String = "",
    val setMode: String,
    val restTime: Int = 0,
    val supersetGroupId: String? = null,
    val sets: List<SetExportDTO> = emptyList()
)

fun UiExerciseWithSets.toExportDTO() = ExerciseExportDTO(
    exerciseId = exerciseDC.id,
    name = exerciseDC.name,
    notes = exercise.notes,
    setMode = exercise.setMode.name,
    restTime = exercise.restTime,
    supersetGroupId = exercise.supersetId?.toString(),
    sets = sets.map {
        SetExportDTO(
            load = it.load,
            reps = it.reps,
            elapsedTime = it.elapsedTime,
            rpe = it.rpe,
            intensityScale = it.intensityScale.value,
            completed = it.completed
        )
    }
)

@Serializable
data class SetExportDTO(
    val load: Double = 0.0,
    val reps: Int = 0,
    val elapsedTime: Int = 0,
    val rpe: String = "",
    val intensityScale: Int = 0, // 0 = RPE (default), 1 = RIR, 2 = BOTH
    val completed: Boolean = true
)
