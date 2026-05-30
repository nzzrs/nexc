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
import java.time.LocalTime
import kotlin.random.Random

@Entity(
    tableName = "meals",
    foreignKeys = [
        ForeignKey(
            entity = MealPlan::class,
            parentColumns = ["id"],
            childColumns = ["mealPlanId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [
        Index(value = ["mealPlanId"]),
        Index(value = ["mealPlanId", "position"])
    ]
)
@Serializable
data class Meal(
    @PrimaryKey(true) val id: Long = Random.nextLong(),
    val mealPlanId: Long = 0,
    val name: String = "",
    @Serializable(with = LocalTimeSerializer::class)
    val time: LocalTime = LocalTime.NOON,
    val notes: String = "",
    val position: Int = 0
)
