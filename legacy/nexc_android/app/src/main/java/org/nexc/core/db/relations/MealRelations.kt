/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.relations

import androidx.room.Embedded
import androidx.room.Relation
import org.nexc.core.db.entity.Product
import org.nexc.core.db.entity.Recipe
import org.nexc.core.db.entity.RecipeIngredient
import org.nexc.core.db.entity.Meal
import org.nexc.core.db.entity.MealItem
import org.nexc.core.db.entity.MealPlan


data class RecipeIngredientWithProduct(
    @Embedded val ingredient: RecipeIngredient,
    @Relation(
        parentColumn = "productId",
        entityColumn = "id"
    )
    val product: Product
)

data class RecipeWithIngredients(
    @Embedded val recipe: Recipe,
    @Relation(
        entity = RecipeIngredient::class,
        parentColumn = "id",
        entityColumn = "recipeId"
    )
    val ingredients: List<RecipeIngredientWithProduct>
)

data class MealItemWithDetails(
    @Embedded val mealItem: MealItem,
    @Relation(
        parentColumn = "targetId",
        entityColumn = "id"
    )
    val product: Product?,
    @Relation(
        entity = Recipe::class,
        parentColumn = "targetId",
        entityColumn = "id"
    )
    val recipe: RecipeWithIngredients?
)

data class MealWithItems(
    @Embedded val meal: Meal,
    @Relation(
        entity = MealItem::class,
        parentColumn = "id",
        entityColumn = "mealId"
    )
    val items: List<MealItemWithDetails>
)

data class MealPlanWithMealsAndItems(
    @Embedded val mealPlan: MealPlan,
    @Relation(
        entity = Meal::class,
        parentColumn = "id",
        entityColumn = "mealPlanId"
    )
    val meals: List<MealWithItems>
)

val RecipeWithIngredients.isRecipePortable: Boolean
    get() = recipe.isPortable && ingredients.all { it.product.isPortable }

val MealItemWithDetails.isItemPortable: Boolean
    get() = when (mealItem.type) {
        org.nexc.core.enums.MealItemType.PRODUCT -> product?.isPortable ?: true
        org.nexc.core.enums.MealItemType.RECIPE -> recipe?.isRecipePortable ?: true
    }

val MealWithItems.isMealPortable: Boolean
    get() = items.all { it.isItemPortable }

