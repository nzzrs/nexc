/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.serialization.Serializable
import kotlin.random.Random

@Entity(tableName = "products")
@Serializable
data class Product(
    @PrimaryKey(true) val id: Long = Random.nextLong(),
    val name: String = "",
    val weight: Double = 0.0,
    val cost: Double = 0.0,
    val quantity: Int = 0,
    val units: String = "g",
    val ediblePercent: Double = 1.0,
    val edibleQtyPerUnit: Double = 0.0,
    val proteins: Double = 0.0, // per 100g
    val carbs: Double = 0.0,    // per 100g
    val fats: Double = 0.0,     // per 100g
    val isSupplement: Boolean = false,
    @ColumnInfo(defaultValue = "1") val isPortable: Boolean = true
)
