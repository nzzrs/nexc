/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.repository

import android.content.Context
import android.os.Build
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import org.nexc.R
import org.nexc.core.db.dao.DatasetDao
import org.nexc.core.db.entity.ExerciseDC
import org.nexc.core.di.qualifiers.ApplicationScope
import org.nexc.core.models.UiExerciseDC
import org.nexc.core.models.mappers.toUi
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Repository class to provide `res/raw/exercises.json` as a [List] of [ExerciseDC].
 *
 * This class serves as a mediator between [DatasetDao] and the
 * application, providing a clean API for data access.
 *
 *
 * @param datasetDao The [DatasetDao] instance used to access the dataset from the database.
 * @param applicationScope A long-lived coroutine on the application scope in order to update the dataset.
 * @property dataset It provides the latest dataset saved in Room
 */
@Singleton
class DatasetRepository @Inject constructor(
    private val datasetDao: DatasetDao,
    @param:ApplicationScope private val applicationScope: CoroutineScope,
    private val userPreferencesRepository: UserPreferencesRepository,
    @param:ApplicationContext private val context: Context
) {
    val dataset: StateFlow<List<UiExerciseDC>> = datasetDao.getDataset()
        .map { dataset -> dataset.map { it.toUi() } }
        .stateIn(
            scope = applicationScope,
            started = SharingStarted.Eagerly,
            initialValue = emptyList()
        )

    fun updateDatasetOnAppUpdate() {
        applicationScope.launch(Dispatchers.IO) {
            val pInfo = context.packageManager.getPackageInfo(context.packageName, 0)
            val currentVersion =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) pInfo.longVersionCode else pInfo.versionCode.toLong()
            val pastVersion = userPreferencesRepository.pastVersionCode.value

            // Update dataset only on app update
            if (pastVersion != currentVersion) {
                val jsonFile =
                    context.resources.openRawResource(R.raw.exercises).bufferedReader().use {
                        it.readText()
                    }

                val json = Json

                // All entries of all enums must be annotated with @SerialName with its corresponding value in json file
                val exercises = json.decodeFromString<List<ExerciseDC>>(jsonFile)

                // Set the dataset into the database using the DAO
                datasetDao.setDataset(exercises)

                // Save version
                userPreferencesRepository.savePreference(
                    key = UserPreferencesRepository.pastVersionCodeKey,
                    value = currentVersion
                )
            }
        }
    }

    val customExercises = datasetDao.getCustomExercises()

    suspend fun upsertExercise(exerciseDC: ExerciseDC) {
        datasetDao.upsertExercise(exerciseDC)
    }

    suspend fun deleteExercise(exerciseDC: ExerciseDC) {
        datasetDao.deleteExercise(exerciseDC)
    }

    suspend fun getExerciseFromId(id: String): UiExerciseDC? {
        return datasetDao.getExerciseFromId(id)?.toUi()
    }

    fun getExerciseFlowFromId(id: String): Flow<UiExerciseDC?> {
        return datasetDao.getExerciseFlowFromId(id).map { it?.toUi() }
    }
}