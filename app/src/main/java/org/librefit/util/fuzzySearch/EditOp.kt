/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.util.fuzzySearch

class EditOp {
    var type: EditType? = null
    var spos = 0 // source block pos
    var dpos = 0 // destination block pos
    override fun toString(): String {
        return type!!.name + "(" + spos + "," + dpos + ")"
    }
}