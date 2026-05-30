/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 */

package org.nexc.core.enums.userPreferences

import org.nexc.R

enum class OneRepMaxFormula(val value: Int) : DialogPreference {
    BALANCED(0),
    EPLEY(1),
    BRZYCKI(2),
    MCGLOTHIN(3),
    LOMBARDI(4),
    MAYHEW(5),
    O_CONNER(6),
    WATHEN(7);
}
