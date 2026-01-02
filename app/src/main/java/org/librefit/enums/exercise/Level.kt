/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.enums.exercise

import com.squareup.moshi.Json

enum class Level : ExerciseProperty {
    @Json(name = "beginner")
    BEGINNER,
    @Json(name = "intermediate")
    INTERMEDIATE,
    @Json(name = "expert")
    EXPERT
}