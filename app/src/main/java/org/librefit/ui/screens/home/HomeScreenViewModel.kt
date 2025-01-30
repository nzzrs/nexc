/*
 * Copyright (c) 2024-2025. LibreFit
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

package org.librefit.ui.screens.home

import androidx.compose.runtime.MutableState
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.launch
import org.librefit.data.DataStoreManager
import org.librefit.db.Workout
import org.librefit.db.WorkoutDao
import javax.inject.Inject

@HiltViewModel
class HomeScreenViewModel @Inject constructor(
    userPreferences: DataStoreManager,
    private val workoutDao: WorkoutDao
) : ViewModel() {
    val requestPermissionAgain = userPreferences.requestPermissionsAgain

    var routineList: MutableState<List<Workout>> = mutableStateOf(emptyList())

    init {
        getRoutinesList()
    }

    private fun getRoutinesList() {
        viewModelScope.launch {
            workoutDao.getRoutines()
                .distinctUntilChanged()
                .collect { workouts ->
                    routineList.value = workouts
                }
        }
    }

}