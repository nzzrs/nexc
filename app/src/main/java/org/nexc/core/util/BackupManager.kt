/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.util

import android.content.Context
import android.net.Uri
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString
import org.nexc.core.db.AppDatabase
import org.nexc.core.db.repository.WorkoutRepository
import org.nexc.core.models.dto.WorkoutExportDTO
import org.nexc.core.models.dto.toExportDTO
import org.nexc.core.models.mappers.*
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.io.FileOutputStream
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.first
import org.nexc.core.db.repository.DatasetRepository

@Singleton
class BackupManager @Inject constructor(
    @ApplicationContext private val context: Context,
    private val workoutRepository: WorkoutRepository,
    private val datasetRepository: DatasetRepository
) {
    private val databaseName = AppDatabase.NAME

    suspend fun exportDatabase(uri: Uri) = withContext(Dispatchers.IO) {
        val dbFile = context.getDatabasePath(databaseName)
        context.contentResolver.openOutputStream(uri)?.use { output ->
            dbFile.inputStream().use { input ->
                input.copyTo(output)
            }
        }
    }

    suspend fun importDatabase(uri: Uri) = withContext(Dispatchers.IO) {
        val dbFile = context.getDatabasePath(databaseName)
        val shmFile = File(dbFile.path + "-shm")
        val walFile = File(dbFile.path + "-wal")

        // In a real app, we should probably close the DB connection first
        // But for a simple implementation, we might need a restart
        context.contentResolver.openInputStream(uri)?.use { input ->
            FileOutputStream(dbFile).use { output ->
                input.copyTo(output)
            }
        }
        // Clean up journal files to ensure consistency
        if (shmFile.exists()) shmFile.delete()
        if (walFile.exists()) walFile.delete()
    }

    suspend fun exportPlans(uri: Uri) = withContext(Dispatchers.IO) {
        val routines = workoutRepository.routines.first()
        val routinesWithExercises = routines.map { 
            workoutRepository.getWorkoutWithExercisesAndSets(it.id)
        }
        
        val dtos = routinesWithExercises.map { routine ->
            routine.workout.toExportDTO(routine.exercisesWithSets)
        }
        val json = Json.encodeToString(dtos)
        
        context.contentResolver.openOutputStream(uri)?.use<java.io.OutputStream, Unit> { output ->
            output.write(json.toByteArray())
        }
    }

    suspend fun importPlans(uri: Uri): Boolean = withContext(Dispatchers.IO) {
        try {
            context.contentResolver.openInputStream(uri)?.use { input ->
                val json = input.bufferedReader().readText()
                val dtos = Json.decodeFromString<List<WorkoutExportDTO>>(json)

                dtos.forEach { dto ->
                    val supersetMapping = mutableMapOf<String, Long>()

                    val workout = org.nexc.core.db.entity.Workout(
                        notes = dto.notes,
                        title = dto.title,
                        state = org.nexc.core.enums.WorkoutState.valueOf(dto.state),
                        timeElapsed = dto.timeElapsed,
                        created = dto.created,
                        completed = dto.completed ?: java.time.LocalDateTime.now()
                    )

                    val exercisesWithSets = dto.exercises.map { exerciseDto ->
                        val uiExerciseDc = datasetRepository.getExerciseFromId(exerciseDto.exerciseId)
                            ?: org.nexc.core.db.entity.ExerciseDC(id = exerciseDto.exerciseId, name = exerciseDto.name).toUi()
                        
                        val supersetId = exerciseDto.supersetGroupId?.let { groupId ->
                            supersetMapping.getOrPut(groupId) { java.util.UUID.randomUUID().mostSignificantBits }
                        }
                        
                        org.nexc.core.db.relations.ExerciseWithSets(
                            exercise = org.nexc.core.db.entity.Exercise(
                                notes = exerciseDto.notes,
                                setMode = org.nexc.core.enums.SetMode.valueOf(exerciseDto.setMode),
                                restTime = exerciseDto.restTime,
                                supersetId = supersetId,
                                idExerciseDC = uiExerciseDc.id
                            ),
                            sets = exerciseDto.sets.map { setDto ->
                                org.nexc.core.db.entity.Set(
                                    load = setDto.load,
                                    reps = setDto.reps,
                                    elapsedTime = setDto.elapsedTime,
                                    rpe = setDto.rpe.toDoubleOrNull(),
                                    intensityScale = setDto.intensityScale,
                                    completed = setDto.completed
                                )
                            },
                            exerciseDC = uiExerciseDc.toEntity()
                        )
                    }

                    workoutRepository.addWorkoutWithExercisesAndSets(
                        org.nexc.core.db.relations.WorkoutWithExercisesAndSets(
                            workout = workout,
                            exercisesWithSets = exercisesWithSets
                        )
                    )
                }
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    suspend fun exportExercises(uri: Uri) = withContext(Dispatchers.IO) {
        val customExercises = datasetRepository.customExercises.first()
        val json = Json.encodeToString(customExercises)
        context.contentResolver.openOutputStream(uri)?.use { output ->
            output.write(json.toByteArray())
        }
    }

    suspend fun importExercises(uri: Uri): Boolean = withContext(Dispatchers.IO) {
        try {
            context.contentResolver.openInputStream(uri)?.use { input ->
                val json = input.bufferedReader().readText()
                val exercises = Json.decodeFromString<List<org.nexc.core.db.entity.ExerciseDC>>(json)
                exercises.forEach {
                    datasetRepository.upsertExercise(it.copy(isCustomExercise = true))
                }
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
