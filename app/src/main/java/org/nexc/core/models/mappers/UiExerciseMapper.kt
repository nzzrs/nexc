/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.models.mappers

import org.nexc.core.db.entity.Exercise
import org.nexc.core.models.UiExercise

fun Exercise.toUi(): UiExercise {
    return UiExercise(
        id = this.id,
        idExerciseDC = this.idExerciseDC,
        notes = this.notes,
        setMode = this.setMode,
        restTime = this.restTime,
<<<<<<< HEAD:app/src/main/java/org/nexc/core/models/mappers/UiExerciseMapper.kt
        supersetId = this.supersetId,
        workoutId = this.workoutId,
        position = this.position
=======
        position = this.position,
        workoutId = this.workoutId
>>>>>>> fork/main:app/src/main/java/org/librefit/ui/models/mappers/UiExerciseMapper.kt
    )
}

fun UiExercise.toEntity(): Exercise {
    return Exercise(
        id = this.id,
        idExerciseDC = this.idExerciseDC,
        notes = this.notes,
        setMode = this.setMode,
        restTime = this.restTime,
<<<<<<< HEAD:app/src/main/java/org/nexc/core/models/mappers/UiExerciseMapper.kt
        supersetId = this.supersetId,
        workoutId = this.workoutId,
        position = this.position
=======
        position = this.position,
        workoutId = this.workoutId
>>>>>>> fork/main:app/src/main/java/org/librefit/ui/models/mappers/UiExerciseMapper.kt
    )
}
