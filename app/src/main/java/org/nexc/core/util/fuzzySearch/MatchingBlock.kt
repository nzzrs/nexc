/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.util.fuzzySearch

class MatchingBlock {
    var spos = 0
    var dpos = 0
    var length = 0
    override fun toString(): String {
        return "($spos,$dpos,$length)"
    }
}