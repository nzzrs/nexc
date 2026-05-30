/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.repository

import kotlinx.coroutines.flow.Flow
import org.nexc.core.db.dao.MealDao
import org.nexc.core.db.entity.*
import org.nexc.core.db.relations.*
import org.nexc.core.enums.MealPlanState
import org.nexc.core.enums.MealItemType
import java.time.LocalDateTime
import java.time.LocalTime
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MealRepository @Inject constructor(
    private val mealDao: MealDao
) {
    fun getAllProducts(): Flow<List<Product>> = mealDao.getAllProducts()

    suspend fun getProduct(id: Long): Product? = mealDao.getProduct(id)

    suspend fun saveProduct(product: Product): Long {
        return if (product.id == 0L) {
            mealDao.insertProduct(product)
        } else {
            mealDao.updateProduct(product)
            product.id
        }
    }

    suspend fun deleteProduct(product: Product) {
        mealDao.deleteProduct(product)
    }

    fun getAllRecipes(): Flow<List<RecipeWithIngredients>> = mealDao.getAllRecipes()

    suspend fun getRecipe(id: Long): RecipeWithIngredients? = mealDao.getRecipe(id)

    suspend fun saveRecipe(recipeWithIngredients: RecipeWithIngredients): Long {
        return mealDao.saveRecipeWithIngredients(recipeWithIngredients)
    }

    suspend fun deleteRecipe(recipe: Recipe) {
        mealDao.deleteRecipe(recipe)
    }

    fun getMealPlansByState(state: MealPlanState): Flow<List<MealPlan>> =
        mealDao.getMealPlansByState(state)

    fun getMealPlansWithMealsAndItemsByState(state: MealPlanState): Flow<List<MealPlanWithMealsAndItems>> =
        mealDao.getMealPlansWithMealsAndItemsByState(state)

    suspend fun getMealPlanWithMealsAndItems(id: Long): MealPlanWithMealsAndItems? =
        mealDao.getMealPlanWithMealsAndItems(id)

    suspend fun getMealPlan(id: Long): MealPlan? = mealDao.getMealPlan(id)

    suspend fun saveMealPlan(mealPlanWithMealsAndItems: MealPlanWithMealsAndItems): Long {
        return mealDao.saveMealPlanWithMealsAndItems(mealPlanWithMealsAndItems)
    }

    suspend fun deleteMealPlan(mealPlan: MealPlan) {
        mealDao.deleteMealPlan(mealPlan)
    }

    suspend fun updateMealItem(mealItem: MealItem) {
        mealDao.updateMealItem(mealItem)
    }

    suspend fun deleteMealItem(mealItem: MealItem) {
        mealDao.deleteMealItem(mealItem)
    }

    suspend fun insertMealItem(mealItem: MealItem): Long {
        return mealDao.insertMealItem(mealItem)
    }

    suspend fun updateMeal(meal: Meal) {
        mealDao.updateMeal(meal)
    }

    suspend fun prepopulateDefaultMealPlans() {
        if (mealDao.getMealPlansCount() > 0) return

        // 1. Insert Products
        val leche = Product(id = 10001L, name = "Whole Milk", weight = 1000.0, cost = 1.20, quantity = 2, units = "ml", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 3.3, carbs = 4.7, fats = 3.6, isSupplement = false)
        val galletas = Product(id = 10002L, name = "Oatmeal Cookies", weight = 200.0, cost = 1.50, quantity = 5, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 6.5, carbs = 65.0, fats = 15.0, isSupplement = false)
        val creatina = Product(id = 10003L, name = "Creatine Monohydrate", weight = 300.0, cost = 18.00, quantity = 1, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 0.0, carbs = 0.0, fats = 0.0, isSupplement = true)
        val pollo = Product(id = 10004L, name = "Chicken Breast", weight = 1000.0, cost = 7.50, quantity = 1, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 31.0, carbs = 0.0, fats = 3.6, isSupplement = false)
        val arroz = Product(id = 10005L, name = "Cooked Rice", weight = 1000.0, cost = 1.50, quantity = 3, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 2.7, carbs = 28.0, fats = 0.3, isSupplement = false)
        val platano = Product(id = 10006L, name = "Banana", weight = 150.0, cost = 0.30, quantity = 6, units = "g", ediblePercent = 0.65, edibleQtyPerUnit = 97.5, proteins = 1.1, carbs = 22.8, fats = 0.3, isSupplement = false)
        val huevo = Product(id = 10007L, name = "Whole Eggs", weight = 60.0, cost = 0.15, quantity = 30, units = "unit", ediblePercent = 0.88, edibleQtyPerUnit = 52.8, proteins = 13.0, carbs = 1.1, fats = 11.0, isSupplement = false)
        val espinaca = Product(id = 10008L, name = "Fresh Spinach", weight = 250.0, cost = 1.20, quantity = 1, units = "g", ediblePercent = 0.95, edibleQtyPerUnit = 0.0, proteins = 2.9, carbs = 3.6, fats = 0.4, isSupplement = false, isPortable = false)
        val salmon = Product(id = 10009L, name = "Grilled Salmon", weight = 200.0, cost = 6.00, quantity = 2, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 25.0, carbs = 0.0, fats = 13.0, isSupplement = false, isPortable = false)

        mealDao.insertProduct(leche)
        mealDao.insertProduct(galletas)
        mealDao.insertProduct(creatina)
        mealDao.insertProduct(pollo)
        mealDao.insertProduct(arroz)
        mealDao.insertProduct(platano)
        mealDao.insertProduct(huevo)
        mealDao.insertProduct(espinaca)
        mealDao.insertProduct(salmon)

        // 2. Insert Recipes
        val scrambledEggs = Recipe(id = 20001L, name = "Scrambled Eggs with Spinach", instructions = "Heat a pan with a drop of oil. Pour in 2 beaten eggs and clean spinach. Cook for 3 minutes.", isPortable = true)
        val recipeIngredients = listOf(
            RecipeIngredientWithProduct(
                ingredient = RecipeIngredient(id = 0L, recipeId = scrambledEggs.id, productId = huevo.id, amount = 120.0),
                product = huevo
            ),
            RecipeIngredientWithProduct(
                ingredient = RecipeIngredient(id = 0L, recipeId = scrambledEggs.id, productId = espinaca.id, amount = 50.0),
                product = espinaca
            )
        )
        mealDao.saveRecipeWithIngredients(RecipeWithIngredients(scrambledEggs, recipeIngredients))

        val salmonSalad = Recipe(id = 20002L, name = "Salmon Salad", instructions = "Mix grilled salmon with clean spinach and a splash of olive oil.", isPortable = true)
        val saladIngredients = listOf(
            RecipeIngredientWithProduct(
                ingredient = RecipeIngredient(id = 0L, recipeId = salmonSalad.id, productId = salmon.id, amount = 150.0),
                product = salmon
            ),
            RecipeIngredientWithProduct(
                ingredient = RecipeIngredient(id = 0L, recipeId = salmonSalad.id, productId = espinaca.id, amount = 50.0),
                product = espinaca
            )
        )
        mealDao.saveRecipeWithIngredients(RecipeWithIngredients(salmonSalad, saladIngredients))

        // 3. Insert Meal Plan
        val mealPlan = MealPlan(
            id = 30001L,
            parentPlanId = 0L,
            title = "Daily High-Protein & Supplement Plan",
            notes = "Focused day including natural food and pre/post training supplements.",
            state = MealPlanState.TEMPLATE,
            created = LocalDateTime.now(),
            completed = LocalDateTime.now()
        )

        val m1 = Meal(id = 40001L, mealPlanId = mealPlan.id, name = "Breakfast & Supplementation", time = LocalTime.of(8, 0), notes = "Take immediately upon waking up with plenty of water.", position = 0)
        val m1Items = listOf(
            MealItemWithDetails(MealItem(id = 0L, mealId = m1.id, type = MealItemType.PRODUCT, targetId = leche.id, amount = 250.0, consumed = false, position = 0), leche, null),
            MealItemWithDetails(MealItem(id = 0L, mealId = m1.id, type = MealItemType.PRODUCT, targetId = galletas.id, amount = 50.0, consumed = false, position = 1), galletas, null),
            MealItemWithDetails(MealItem(id = 0L, mealId = m1.id, type = MealItemType.PRODUCT, targetId = creatina.id, amount = 5.0, consumed = false, position = 2), creatina, null)
        )

        val m2 = Meal(id = 40002L, mealPlanId = mealPlan.id, name = "Lunch", time = LocalTime.of(13, 30), notes = "Main meal of the day.", position = 1)
        val m2Items = listOf(
            MealItemWithDetails(MealItem(id = 0L, mealId = m2.id, type = MealItemType.PRODUCT, targetId = pollo.id, amount = 100.0, consumed = false, position = 0), pollo, null),
            MealItemWithDetails(MealItem(id = 0L, mealId = m2.id, type = MealItemType.PRODUCT, targetId = arroz.id, amount = 100.0, consumed = false, position = 1), arroz, null)
        )

        val m3 = Meal(id = 40003L, mealPlanId = mealPlan.id, name = "Pre-Workout Snack", time = LocalTime.of(17, 0), notes = "1 hour before training.", position = 2)
        val m3Items = listOf(
            MealItemWithDetails(MealItem(id = 0L, mealId = m3.id, type = MealItemType.PRODUCT, targetId = platano.id, amount = 100.0, consumed = false, position = 0), platano, null)
        )

        val m4 = Meal(id = 40004L, mealPlanId = mealPlan.id, name = "Dinner", time = LocalTime.of(21, 0), notes = "Light meal before sleeping.", position = 3)
        val m4Items = listOf(
            MealItemWithDetails(MealItem(id = 0L, mealId = m4.id, type = MealItemType.RECIPE, targetId = scrambledEggs.id, amount = 1.0, consumed = false, position = 0), null, RecipeWithIngredients(scrambledEggs, recipeIngredients))
        )

        val mealsList = listOf(
            MealWithItems(m1, m1Items),
            MealWithItems(m2, m2Items),
            MealWithItems(m3, m3Items),
            MealWithItems(m4, m4Items)
        )

        mealDao.saveMealPlanWithMealsAndItems(MealPlanWithMealsAndItems(mealPlan, mealsList))
    }
}
