/*
 * Copyright (c) 2024-2025. LibreFit Team
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
 *
 * LibreFit is subject to additional terms covering author attribution and
 * trademark usage, as found in the accompanying ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md.
 */

package org.librefit.nav

import kotlinx.serialization.Serializable
import org.librefit.db.entity.ExerciseDC
import org.librefit.enums.SuccessMessage
import org.librefit.enums.pages.TutorialContent


sealed interface Route {
    @Serializable
    data object AboutScreen : Route

    @Serializable
    data class BeforeSavingScreen(
        val runningWorkoutId: Long
    ) : Route

    @Serializable
    data object CalendarScreen : Route

    @Serializable
    data class EditExerciseScreen(
        val id: Long = 0,
        val exerciseDCid: String = ""
    ) : Route

    @Serializable
    data class EditWorkoutScreen(
        val workoutId: Long
    ) : Route

    @Serializable
    data class ExercisesScreen(
        val addExercises: Boolean
    ) : Route

    @Serializable
    data class InfoExerciseScreen(
        val id: Long,
        val exerciseDC: ExerciseDC
    ) : Route

    @Serializable
    data class InfoWorkoutScreen(
        val workoutId: Long
    ) : Route

    @Serializable
    data object MainScreen : Route

    @Serializable
    data object MeasurementScreen : Route

    @Serializable
    data object PrivacyScreen : Route

    @Serializable
    data class RequestPermissionScreen(
        val workoutId: Long
    ) : Route

    @Serializable
    data object LibrariesScreen : Route

    @Serializable
    data object LicenseScreen : Route

    @Serializable
    data object SettingsScreen : Route

    @Serializable
    data object StatisticsScreen : Route

    @Serializable
    data class SuccessScreen(
        val message: SuccessMessage,
    ) : Route

    @Serializable
    data class SupportScreen(
        val supporterInfo: Boolean = false
    ) : Route

    @Serializable
    data class TutorialScreen(
        val tutorialContent: TutorialContent = TutorialContent.CREATE_ROUTINE,
        val fromWelcomeScreen: Boolean = false
    ) : Route

    @Serializable
    data object WelcomeScreen : Route

    @Serializable
    data class WorkoutScreen(
        val workoutId: Long
    ) : Route
}