/*
 * Copyright (c) 2025. LibreFit
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

package org.librefit.db.repository

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.librefit.data.ExerciseDC
import org.librefit.db.dao.DatasetDao

/**
 * Repository class to provide `res/raw/exercises.json` as a [List] of [ExerciseDC].
 *
 * This class serves as a mediator between [DatasetDao] and the
 * application, providing a clean API for data access.
 *
 * This class is provided by [org.librefit.di.RepositoryModule].
 *
 * @param datasetDao The [DatasetDao] instance used to access the dataset from the database.
 * @param applicationScope A long-lived coroutine on the application scope in order to update the dataset.
 *
 */
class DatasetRepository(
    datasetDao: DatasetDao,
    applicationScope: CoroutineScope
) {
    // Private MutableStateFlow to hold the dataset internally.
    private val _dataset = MutableStateFlow<List<ExerciseDC>>(emptyList())

    // Public, read-only StateFlow for consumers to collect.
    val dataset: StateFlow<List<ExerciseDC>> = _dataset

    init {
        // Launch a long-lived coroutine on the application scope.
        applicationScope.launch {
            // Collect the data from the database Flow and update the state.
            datasetDao.getDataset().collect { newList ->
                _dataset.value = newList
            }
        }
    }
}