/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.enums.pages

import androidx.annotation.Keep

/**
 * IMPORTANT: Keep in sync with [org.librefit.ui.screens.about.TutorialScreen]
 */
@Keep
enum class TutorialContent(
    val lazyColumnIndex: Int,
    val pageIndex: Int = 0
) {
    CREATE_ROUTINE(0),
    COMPLETE_WORKOUT(3)
}