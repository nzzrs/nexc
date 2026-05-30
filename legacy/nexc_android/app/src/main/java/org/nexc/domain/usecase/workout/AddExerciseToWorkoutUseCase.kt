/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

package org.nexc.domain.usecase.workout

import org.nexc.core.db.entity.ExerciseDC
import org.nexc.core.enums.SetMode
import org.nexc.core.enums.exercise.Category
import org.nexc.core.enums.exercise.Equipment
import org.nexc.core.models.UiExercise
import org.nexc.core.models.UiExerciseWithSets
import org.nexc.core.models.mappers.toUi
import javax.inject.Inject

/**
 * Use case to initialize a new exercise with sets for a workout based on its definition (ExerciseDC).
 * It automatically determines the appropriate SetMode based on equipment and category.
 */
class AddExerciseToWorkoutUseCase @Inject constructor() {
    operator fun invoke(exerciseDC: ExerciseDC): UiExerciseWithSets {
        return UiExerciseWithSets(
            exercise = UiExercise(
                idExerciseDC = exerciseDC.id,
                setMode = when (exerciseDC.category) {
                    Category.STRETCHING, Category.CARDIO -> SetMode.DURATION
                    else -> when (exerciseDC.equipment) {
                        Equipment.BODY_ONLY, Equipment.FOAM_ROLL, Equipment.EXERCISE_BALL,
                        Equipment.MEDICINE_BALL, Equipment.BANDS -> SetMode.BODYWEIGHT

                        else -> if (exerciseDC.name.contains("Weighted", true))
                            SetMode.BODYWEIGHT_WITH_LOAD else SetMode.LOAD
                    }
                }
            ),
            exerciseDC = exerciseDC.toUi()
        )
    }
}
