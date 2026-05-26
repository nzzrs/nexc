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
import org.nexc.core.enums.MealPlanState
import java.time.LocalDateTime
import kotlin.random.Random

@Entity(tableName = "meal_plans")
@Serializable
data class MealPlan(
    @PrimaryKey(true) val id: Long = 0,
    val parentPlanId: Long = Random.nextLong(),
    val title: String = "",
    val notes: String = "",
    val state: MealPlanState = MealPlanState.LOGGED,
    @Serializable(with = LocalDateTimeSerializer::class)
    val created: LocalDateTime = LocalDateTime.now(),
    @Serializable(with = LocalDateTimeSerializer::class)
    val completed: LocalDateTime = LocalDateTime.now()
)
