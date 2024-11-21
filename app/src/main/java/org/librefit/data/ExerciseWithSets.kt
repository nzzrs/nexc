package org.librefit.data

import org.librefit.db.Set

data class ExerciseWithSets(
    val id: Int = 0,
    val exerciseId: Int = 0,
    val exercise: ExerciseDC,
    var sets: List<Set> = emptyList(),
    var note: String = "",
    var setMode: SetMode = SetMode.WEIGHT
)