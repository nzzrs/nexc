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
import org.nexc.core.enums.userPreferences.IntensityScale
import kotlin.random.Random

/**
 * The [org.nexc.core.db.entity.Set] model used only by the ui. The difference is the use
 * of [ImmutableList] instead of [List] in order to ensure the [Immutable] annotation and improve
 * composition performance.
 *
 * @see [org.nexc.core.db.entity.Set]
 */
@Immutable
data class UiSet(
    val id: Long = Random.nextLong(),
    val load: Double = 0.0,
    val reps: Int = 0,
    val elapsedTime: Int = 0,
    val completed: Boolean = false,
    val rpe: String = "",
    val rir: String = "",
    val intensityScale: IntensityScale = IntensityScale.RPE,
    val exerciseId: Long = 0
)
