/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.serialization.Serializable
import kotlin.random.Random

@Entity(tableName = "recipes")
@Serializable
data class Recipe(
    @PrimaryKey(true) val id: Long = Random.nextLong(),
    val name: String = "",
    val instructions: String = "",
    val isPortable: Boolean = true
)
