/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.models

import androidx.compose.runtime.Immutable
import org.nexc.core.enums.WorkoutState
import java.time.LocalDateTime
import kotlin.random.Random

/**
 * The [org.nexc.core.db.entity.Workout] model used only by the ui. The difference is the use
 * of [Immutable] annotation
 *
 * @see [org.nexc.core.db.entity.Workout]
 */
@Immutable
data class UiWorkout(
    val id: Long = 0,
    val routineId: Long = Random.nextLong(),
    val notes: String = "",
    val title: String = "",
    val state: WorkoutState = WorkoutState.COMPLETED,
    val timeElapsed: Int = 0,
    val created: LocalDateTime = LocalDateTime.now(),
    val completed: LocalDateTime = LocalDateTime.now()
)