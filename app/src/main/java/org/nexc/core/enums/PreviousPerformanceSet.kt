/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.enums

/**
 * It is used to display the previous previous of a set in a [org.nexc.core.components.ExerciseCard]
 */
data class PreviousPerformanceSet(
    val reps: Int = 0,
    val load: Double = 0.0,
    val time: Int = 0
)
