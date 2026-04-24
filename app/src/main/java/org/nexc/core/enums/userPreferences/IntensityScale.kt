/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.enums.userPreferences

import org.nexc.R

enum class IntensityScale(val value: Int, val stringId: Int) : DialogPreference {
    RPE(0, R.string.rpe),
    RIR(1, R.string.rir),
    BOTH(2, R.string.intensity_both);
}
