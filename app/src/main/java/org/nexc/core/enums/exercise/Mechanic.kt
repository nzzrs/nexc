/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.enums.exercise

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class Mechanic : ExerciseProperty {
    @SerialName(value = "isolation")
    ISOLATION,

    @SerialName(value = "compound")
    COMPOUND
}