/*
 * Copyright (c) 2024. LibreFit
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

package org.librefit.util

import org.librefit.enums.Category
import org.librefit.enums.Equipment
import org.librefit.enums.Force
import org.librefit.enums.Level
import org.librefit.enums.Mechanic
import org.librefit.enums.Muscle

data class ExerciseDC(
    val id: String,
    val name: String,
    val force: Force? = null,
    val level: Level,
    val mechanic: Mechanic? = null,
    val equipment: Equipment? = null,
    val primaryMuscles: List<Muscle>,
    val secondaryMuscles: List<Muscle>,
    val instructions: List<String>,
    val category: Category,
    val images: List<String>
)

