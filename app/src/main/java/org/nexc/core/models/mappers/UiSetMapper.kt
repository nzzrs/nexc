/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 */

package org.nexc.core.models.mappers

import org.nexc.core.db.entity.Set
import org.nexc.core.enums.userPreferences.IntensityScale
import org.nexc.core.models.UiSet

fun Set.toUi(): UiSet {
    return UiSet(
        id = this.id,
        load = this.load,
        reps = this.reps,
        elapsedTime = this.elapsedTime,
        completed = this.completed,
        rpe = this.rpe?.let { if (it % 1.0 == 0.0) it.toInt().toString() else it.toString() } ?: "",
        rir = this.rir?.toString() ?: "",
        intensityScale = IntensityScale.entries
            .find { it.value == this.intensityScale }
            ?: IntensityScale.RPE,
        exerciseId = this.exerciseId
    )
}

fun UiSet.toEntity(): Set {
    return Set(
        id = this.id,
        load = this.load,
        reps = this.reps,
        elapsedTime = this.elapsedTime,
        completed = this.completed,
        rpe = this.rpe.toDoubleOrNull(),
        rir = this.rir.toIntOrNull(),
        intensityScale = this.intensityScale.value,
        exerciseId = this.exerciseId
    )
}