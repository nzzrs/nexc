/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.models.dto

import kotlinx.serialization.Serializable
import org.nexc.core.db.entity.LocalDateTimeSerializer
import org.nexc.core.db.entity.LocalTimeSerializer
import org.nexc.core.db.entity.Product
import org.nexc.core.db.entity.Recipe
import org.nexc.core.db.entity.RecipeIngredient
import org.nexc.core.db.entity.MealPlan
import org.nexc.core.db.entity.Meal
import org.nexc.core.db.entity.MealItem
import org.nexc.core.db.relations.MealPlanWithMealsAndItems
import org.nexc.core.db.relations.MealWithItems
import org.nexc.core.db.relations.MealItemWithDetails
import org.nexc.core.db.relations.RecipeWithIngredients
import org.nexc.core.db.relations.RecipeIngredientWithProduct
import org.nexc.core.enums.MealPlanState
import org.nexc.core.enums.MealItemType
import java.time.LocalDateTime
import java.time.LocalTime

@Serializable
data class ProductExportDTO(
    val name: String,
    val weight: Double,
    val cost: Double,
    val quantity: Int,
    val units: String,
    val ediblePercent: Double,
    val edibleQtyPerUnit: Double,
    val proteins: Double,
    val carbs: Double,
    val fats: Double,
    val isSupplement: Boolean,
    val isPortable: Boolean = true
)

fun Product.toExportDTO() = ProductExportDTO(
    name = name,
    weight = weight,
    cost = cost,
    quantity = quantity,
    units = units,
    ediblePercent = ediblePercent,
    edibleQtyPerUnit = edibleQtyPerUnit,
    proteins = proteins,
    carbs = carbs,
    fats = fats,
    isSupplement = isSupplement,
    isPortable = isPortable
)

@Serializable
data class RecipeIngredientExportDTO(
    val amount: Double,
    val product: ProductExportDTO
)

@Serializable
data class RecipeExportDTO(
    val name: String,
    val instructions: String,
    val isPortable: Boolean,
    val ingredients: List<RecipeIngredientExportDTO>
)

fun RecipeWithIngredients.toExportDTO() = RecipeExportDTO(
    name = recipe.name,
    instructions = recipe.instructions,
    isPortable = recipe.isPortable,
    ingredients = ingredients.map {
        RecipeIngredientExportDTO(
            amount = it.ingredient.amount,
            product = it.product.toExportDTO()
        )
    }
)

@Serializable
data class MealItemExportDTO(
    val type: String, // "PRODUCT" or "RECIPE"
    val amount: Double,
    val consumed: Boolean,
    val position: Int,
    val product: ProductExportDTO? = null,
    val recipe: RecipeExportDTO? = null
)

fun MealItemWithDetails.toExportDTO() = MealItemExportDTO(
    type = mealItem.type.name,
    amount = mealItem.amount,
    consumed = mealItem.consumed,
    position = mealItem.position,
    product = product?.toExportDTO(),
    recipe = recipe?.toExportDTO()
)

@Serializable
data class MealExportDTO(
    val name: String,
    @Serializable(with = LocalTimeSerializer::class)
    val time: LocalTime,
    val notes: String = "",
    val position: Int = 0,
    val items: List<MealItemExportDTO> = emptyList()
)

fun MealWithItems.toExportDTO() = MealExportDTO(
    name = meal.name,
    time = meal.time,
    notes = meal.notes,
    position = meal.position,
    items = items.map { it.toExportDTO() }
)

@Serializable
data class MealPlanExportDTO(
    val title: String,
    val notes: String = "",
    val state: String = "TEMPLATE",
    @Serializable(with = LocalDateTimeSerializer::class)
    val created: LocalDateTime = LocalDateTime.now(),
    @Serializable(with = LocalDateTimeSerializer::class)
    val completed: LocalDateTime = LocalDateTime.now(),
    val meals: List<MealExportDTO> = emptyList()
)

fun MealPlanWithMealsAndItems.toExportDTO() = MealPlanExportDTO(
    title = mealPlan.title,
    notes = mealPlan.notes,
    state = mealPlan.state.name,
    created = mealPlan.created,
    completed = mealPlan.completed,
    meals = meals.map { it.toExportDTO() }
)
