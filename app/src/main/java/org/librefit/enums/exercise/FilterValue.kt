/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.enums.exercise

data class FilterValue(
    val force: Force? = null,
    val level: Level? = null,
    val mechanic: Mechanic? = null,
    val equipment: Equipment? = null,
    val muscles: Muscle? = null,
    val category: Category? = null,
    val showOnlyCustomExercises: Boolean = false
)
