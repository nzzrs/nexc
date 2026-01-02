/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.enums.exercise

import com.squareup.moshi.Json

enum class Muscle : ExerciseProperty {
    @Json(name = "abdominals")
    ABDOMINALS(),
    @Json(name = "abductors")
    ABDUCTORS(),
    @Json(name = "adductors")
    ADDUCTORS(),
    @Json(name = "biceps")
    BICEPS(),
    @Json(name = "calves")
    CALVES(),
    @Json(name = "chest")
    CHEST(),
    @Json(name = "forearms")
    FOREARMS(),
    @Json(name = "glutes")
    GLUTES(),
    @Json(name = "hamstrings")
    HAMSTRINGS(),
    @Json(name = "lats")
    LATS(),
    @Json(name = "lower back")
    LOWER_BACK(),
    @Json(name = "middle back")
    MIDDLE_BACK(),
    @Json(name = "neck")
    NECK(),
    @Json(name = "quadriceps")
    QUADRICEPS(),
    @Json(name = "shoulders")
    SHOULDERS(),
    @Json(name = "traps")
    TRAPS(),
    @Json(name = "triceps")
    TRICEPS();
}