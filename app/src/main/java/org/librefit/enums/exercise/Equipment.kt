/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.enums.exercise

import com.squareup.moshi.Json

enum class Equipment : ExerciseProperty {
    @Json(name = "medicine ball")
    MEDICINE_BALL,
    @Json(name = "dumbbell")
    DUMBBELL,
    @Json(name = "body only")
    BODY_ONLY,
    @Json(name = "bands")
    BANDS,
    @Json(name = "kettlebells")
    KETTLEBELLS,
    @Json(name = "foam roll")
    FOAM_ROLL,
    @Json(name = "cable")
    CABLE,
    @Json(name = "machine")
    MACHINE,
    @Json(name = "barbell")
    BARBELL,
    @Json(name = "exercise ball")
    EXERCISE_BALL,
    @Json(name = "e-z curl bar")
    E_Z_CURL_BAR,
    @Json(name = "other")
    OTHER
}