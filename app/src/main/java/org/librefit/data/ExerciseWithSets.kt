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

package org.librefit.data

import org.librefit.db.Set
import org.librefit.enums.SetMode

data class ExerciseWithSets(
    val id: Int = 0,
    val exerciseId: Int = 0,
    val exerciseDC: ExerciseDC,
    val sets: List<Set> = emptyList<Set>(),
    val note: String = "",
    val restTime: Int = 0,
    val setMode: SetMode = SetMode.WEIGHT
)