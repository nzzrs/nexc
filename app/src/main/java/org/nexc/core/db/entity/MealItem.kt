/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.entity

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import kotlinx.serialization.Serializable
import org.nexc.core.enums.MealItemType
import kotlin.random.Random

@Entity(
    tableName = "meal_items",
    foreignKeys = [
        ForeignKey(
            entity = Meal::class,
            parentColumns = ["id"],
            childColumns = ["mealId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [
        Index(value = ["mealId"]),
        Index(value = ["mealId", "position"])
    ]
)
@Serializable
data class MealItem(
    @PrimaryKey(true) val id: Long = Random.nextLong(),
    val mealId: Long = 0,
    val type: MealItemType = MealItemType.PRODUCT,
    val targetId: Long = 0, // References Product.id or Recipe.id
    val amount: Double = 0.0,
    val consumed: Boolean = false,
    val position: Int = 0
)
