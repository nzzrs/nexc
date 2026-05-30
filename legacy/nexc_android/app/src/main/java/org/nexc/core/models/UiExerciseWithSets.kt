/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.models

import androidx.compose.runtime.Immutable
import kotlinx.collections.immutable.ImmutableList
import kotlinx.collections.immutable.persistentListOf

/**
 * The [org.nexc.core.db.relations.ExerciseWithSets] model used only by the ui. The difference is the use
 * of [ImmutableList] instead of [List] in order to ensure the [Immutable] annotation and improve
 * composition performance.
 *
 * @see [org.nexc.core.db.relations.ExerciseWithSets]
 */
@Immutable
data class UiExerciseWithSets(
    val exercise: UiExercise = UiExercise(),
    val sets: ImmutableList<UiSet> = persistentListOf(UiSet()),
    val exerciseDC: UiExerciseDC = UiExerciseDC()
)
