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

package org.librefit.ui.screens.settings

import android.os.PowerManager
import androidx.appcompat.app.AppCompatDelegate
import androidx.compose.runtime.mutableStateOf
import androidx.core.os.LocaleListCompat
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch
import org.librefit.data.DataStoreManager
import org.librefit.enums.Language
import javax.inject.Inject

@HiltViewModel
class SettingsScreenViewModel @Inject constructor(
    private val userPreferences: DataStoreManager
) : ViewModel() {
    val themeMode = userPreferences.themeMode
    val materialMode = userPreferences.materialMode
    val keepScreenOn = userPreferences.workoutScreenOn

    fun changeLanguage(language: Language) {
        val appLocale: LocaleListCompat = LocaleListCompat.forLanguageTags(language.code)
        AppCompatDelegate.setApplicationLocales(appLocale)
    }

    var isIgnoringBatteryOptimization = mutableStateOf(false)

    /**
     * A method that checks every second the state of [android.Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS].
     * using a flow. It uses the method [PowerManager.isIgnoringBatteryOptimizations].
     * Any approach better than this one are welcome.
     */
    fun checkBatteryOptimization(pm: PowerManager, packageName: String) {
        isIgnoringBatteryOptimization.value = pm.isIgnoringBatteryOptimizations(packageName)
        viewModelScope.launch {
            flow {
                while (true) {
                    emit(pm.isIgnoringBatteryOptimizations(packageName))
                    delay(1000)
                }
            }.collect { isIgnoring ->
                if (isIgnoringBatteryOptimization.value != isIgnoring) {
                    isIgnoringBatteryOptimization.value = isIgnoring
                }
            }
        }
    }

    /**
     * Pass the corresponding [key] value to save:
     *  - 0: theme mode
     *  - 1: material you
     *  - 2: keep screen on during workout
     */
    fun savePreference(key: Int, value: Int) {
        viewModelScope.launch {
            when (key) {
                0 -> userPreferences.savePreference(
                    key = userPreferences.themeModeKey,
                    value = value
                )

                1 -> userPreferences.savePreference(
                    key = userPreferences.materialModeKey,
                    value = value == 1
                )

                2 -> userPreferences.savePreference(
                    key = userPreferences.keepOnWorkoutScreenKey,
                    value = value == 1
                )
            }

        }
    }
}