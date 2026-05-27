/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.dao

import androidx.room.*
import kotlinx.coroutines.flow.Flow
import org.nexc.core.db.entity.Product
import org.nexc.core.db.entity.Recipe
import org.nexc.core.db.entity.RecipeIngredient
import org.nexc.core.db.entity.MealPlan
import org.nexc.core.db.entity.Meal
import org.nexc.core.db.entity.MealItem
import org.nexc.core.db.relations.RecipeWithIngredients
import org.nexc.core.db.relations.MealPlanWithMealsAndItems
import org.nexc.core.db.relations.MealWithItems
import org.nexc.core.enums.MealPlanState
import java.time.LocalDateTime

@Dao
interface MealDao {

    // --- Products ---
    @Query("SELECT * FROM products ORDER BY name ASC")
    fun getAllProducts(): Flow<List<Product>>

    @Query("SELECT * FROM products WHERE id = :id")
    suspend fun getProduct(id: Long): Product?

    @Query("SELECT COUNT(*) FROM products")
    suspend fun getProductsCount(): Int

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProduct(product: Product): Long

    @Update
    suspend fun updateProduct(product: Product)

    @Delete
    suspend fun deleteProduct(product: Product)

    // --- Recipes ---
    @Transaction
    @Query("SELECT * FROM recipes ORDER BY name ASC")
    fun getAllRecipes(): Flow<List<RecipeWithIngredients>>

    @Transaction
    @Query("SELECT * FROM recipes WHERE id = :id")
    suspend fun getRecipe(id: Long): RecipeWithIngredients?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertRecipe(recipe: Recipe): Long

    @Update
    suspend fun updateRecipe(recipe: Recipe)

    @Delete
    suspend fun deleteRecipe(recipe: Recipe)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertRecipeIngredient(ingredient: RecipeIngredient): Long

    @Query("DELETE FROM recipe_ingredients WHERE recipeId = :recipeId")
    suspend fun deleteIngredientsForRecipe(recipeId: Long)

    @Transaction
    suspend fun saveRecipeWithIngredients(recipeWithIngredients: RecipeWithIngredients): Long {
        val recipe = recipeWithIngredients.recipe
        val recipeId = if (recipe.id == 0L) {
            insertRecipe(recipe.copy(id = 0))
        } else {
            insertRecipe(recipe)
        }

        deleteIngredientsForRecipe(recipeId)

        recipeWithIngredients.ingredients.forEach {
            insertRecipeIngredient(it.ingredient.copy(id = 0, recipeId = recipeId))
        }

        return recipeId
    }

    // --- Meal Plans ---
    @Query("SELECT * FROM meal_plans WHERE state = :state ORDER BY created DESC")
    fun getMealPlansByState(state: MealPlanState): Flow<List<MealPlan>>

    @Transaction
    @Query("SELECT * FROM meal_plans WHERE state = :state ORDER BY created DESC")
    fun getMealPlansWithMealsAndItemsByState(state: MealPlanState): Flow<List<MealPlanWithMealsAndItems>>

    @Transaction
    @Query("SELECT * FROM meal_plans WHERE id = :id")
    suspend fun getMealPlanWithMealsAndItems(id: Long): MealPlanWithMealsAndItems?

    @Query("SELECT * FROM meal_plans WHERE id = :id")
    suspend fun getMealPlan(id: Long): MealPlan?

    @Query("SELECT COUNT(*) FROM meal_plans")
    suspend fun getMealPlansCount(): Int

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMealPlan(mealPlan: MealPlan): Long

    @Update
    suspend fun updateMealPlan(mealPlan: MealPlan)

    @Delete
    suspend fun deleteMealPlan(mealPlan: MealPlan)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMeal(meal: Meal): Long

    @Update
    suspend fun updateMeal(meal: Meal)

    @Delete
    suspend fun deleteMeal(meal: Meal)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMealItem(mealItem: MealItem): Long

    @Update
    suspend fun updateMealItem(mealItem: MealItem)

    @Delete
    suspend fun deleteMealItem(mealItem: MealItem)

    @Transaction
    @Query("SELECT * FROM meals WHERE mealPlanId = :mealPlanId ORDER BY position")
    suspend fun getMealsForPlan(mealPlanId: Long): List<MealWithItems>

    @Query("SELECT * FROM meal_items WHERE mealId = :mealId ORDER BY position")
    suspend fun getItemsForMeal(mealId: Long): List<MealItem>

    @Transaction
    suspend fun saveMealPlanWithMealsAndItems(
        mealPlanWithMealsAndItems: MealPlanWithMealsAndItems
    ): Long {
        val mealPlan = mealPlanWithMealsAndItems.mealPlan
        val mealPlanId = if (mealPlan.id == 0L) {
            insertMealPlan(
                mealPlan.copy(
                    id = 0,
                    created = LocalDateTime.now()
                )
            )
        } else {
            insertMealPlan(mealPlan)
        }

        val newMeals = mealPlanWithMealsAndItems.meals
        val oldMeals = getMealsForPlan(mealPlanId)

        val oldMealsMap = oldMeals.associateBy { it.meal.id }
        val newMealsMap = newMeals.associateBy { it.meal.id }

        val mealIdsToDelete = oldMealsMap.keys - newMealsMap.keys
        mealIdsToDelete.forEach { id ->
            deleteMeal(oldMealsMap.getValue(id).meal)
        }

        newMeals.forEach { newMealWithItems ->
            val mealId = if (newMealWithItems.meal.id in oldMealsMap) {
                updateMeal(newMealWithItems.meal)
                newMealWithItems.meal.id
            } else {
                insertMeal(newMealWithItems.meal.copy(id = 0, mealPlanId = mealPlanId))
            }

            val newItems = newMealWithItems.items
            val oldItems = getItemsForMeal(mealId)

            val oldItemsMap = oldItems.associateBy { it.id }
            val newItemsMap = newItems.associateBy { it.mealItem.id }

            val itemIdsToDelete = oldItemsMap.keys - newItemsMap.keys
            itemIdsToDelete.forEach { id ->
                deleteMealItem(oldItemsMap.getValue(id))
            }

            newItems.forEach { itemDetails ->
                if (itemDetails.mealItem.id in oldItemsMap) {
                    updateMealItem(itemDetails.mealItem)
                } else {
                    insertMealItem(itemDetails.mealItem.copy(id = 0, mealId = mealId))
                }
            }
        }

        return mealPlanId
    }
}
