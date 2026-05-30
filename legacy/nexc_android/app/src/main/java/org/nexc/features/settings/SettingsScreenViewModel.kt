/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.settings

import androidx.datastore.preferences.core.Preferences
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.nexc.core.db.repository.UserPreferencesRepository
import org.nexc.core.enums.userPreferences.OneRepMaxFormula
import org.nexc.core.enums.userPreferences.DialogPreference
import org.nexc.core.enums.userPreferences.Language
import org.nexc.core.enums.userPreferences.ThemeMode
import javax.inject.Inject

@HiltViewModel
class SettingsScreenViewModel @Inject constructor(
    private val userPreferences: UserPreferencesRepository
) : ViewModel() {
    val themeMode = userPreferences.themeMode
    val materialMode = userPreferences.materialMode
    val keepScreenOn = userPreferences.workoutScreenOn
    val language = userPreferences.language
    val restTimerSoundOn = userPreferences.restTimerSoundOn
    val isWorkoutHeaderSticky = userPreferences.isWorkoutHeaderSticky
    val oneRepMaxFormula = userPreferences.oneRepMaxFormula
    val sleepModeEnabled = userPreferences.sleepModeEnabled
    val showRpe = userPreferences.showRpe
    val intensityScale = userPreferences.intensityScale
    val restTimerVibrationOn = userPreferences.restTimerVibrationOn


    fun <T> savePreference(key: Preferences.Key<T>, value: T) {
        viewModelScope.launch {
            userPreferences.savePreference(
                key = key,
                value = value
            )
        }
    }


    private val _preferences = MutableStateFlow<List<DialogPreference>?>(null)
    val preferences = _preferences.asStateFlow()

    fun updatePreferences(preferences: List<DialogPreference>?) {
        _preferences.update { current ->
            preferences?.ifEmpty { current }
        }
    }

    val currentPreference: StateFlow<DialogPreference?> = combine(
        preferences,
        language,
        themeMode,
        oneRepMaxFormula,
        intensityScale
    ) { p, l, t, f, i ->
        p?.let {
            when (p.first()) {
                is Language -> l
                is ThemeMode -> t
                is OneRepMaxFormula -> f
                is org.nexc.core.enums.userPreferences.IntensityScale -> i
                else -> null
            }
        }
    }
        .distinctUntilChanged()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = null
        )

    fun updateDialogPreference(newPreference: DialogPreference) {
        when (newPreference) {
            is Language -> savePreference(
                UserPreferencesRepository.languageKey,
                newPreference.code
            )
            is ThemeMode -> savePreference(
                UserPreferencesRepository.themeModeKey,
                newPreference.value
            )
            is OneRepMaxFormula -> savePreference(
                UserPreferencesRepository.oneRepMaxFormulaKey,
                newPreference.value
            )
            is org.nexc.core.enums.userPreferences.IntensityScale -> savePreference(
                UserPreferencesRepository.intensityScaleKey,
                newPreference.value
            )
        }
    }
}