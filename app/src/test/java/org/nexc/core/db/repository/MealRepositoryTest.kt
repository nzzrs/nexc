/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.repository

import com.google.common.truth.Truth.assertThat
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import org.nexc.core.db.dao.MealDao
import org.nexc.core.db.entity.*
import org.nexc.core.db.relations.RecipeWithIngredients
import org.nexc.core.db.relations.MealPlanWithMealsAndItems
import org.nexc.core.enums.MealPlanState
import java.time.LocalDateTime

class MealRepositoryTest {

    private lateinit var mealDao: MealDao
    private lateinit var repository: MealRepository

    @Before
    fun setUp() {
        mealDao = mockk(relaxed = true)
        repository = MealRepository(mealDao)
    }

    @Test
    fun `getAllProducts returns products from DAO`() = runTest {
        val products = listOf(
            Product(id = 1L, name = "Pollo", weight = 1000.0, cost = 7.5, quantity = 1, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 31.0, carbs = 0.0, fats = 3.6, isSupplement = false),
            Product(id = 2L, name = "Creatina", weight = 300.0, cost = 18.0, quantity = 1, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 0.0, carbs = 0.0, fats = 0.0, isSupplement = true)
        )
        every { mealDao.getAllProducts() } returns flowOf(products)

        val result = repository.getAllProducts().first()

        assertThat(result).isEqualTo(products)
        coVerify { mealDao.getAllProducts() }
    }

    @Test
    fun `getProduct returns product from DAO`() = runTest {
        val product = Product(id = 1L, name = "Pollo", weight = 1000.0, cost = 7.5, quantity = 1, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 31.0, carbs = 0.0, fats = 3.6, isSupplement = false)
        coEvery { mealDao.getProduct(1L) } returns product

        val result = repository.getProduct(1L)

        assertThat(result).isEqualTo(product)
        coVerify { mealDao.getProduct(1L) }
    }

    @Test
    fun `saveProduct inserts new product when id is 0`() = runTest {
        val product = Product(id = 0L, name = "Pollo", weight = 1000.0, cost = 7.5, quantity = 1, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 31.0, carbs = 0.0, fats = 3.6, isSupplement = false)
        coEvery { mealDao.insertProduct(product) } returns 10L

        val result = repository.saveProduct(product)

        assertThat(result).isEqualTo(10L)
        coVerify { mealDao.insertProduct(product) }
    }

    @Test
    fun `saveProduct updates existing product when id is not 0`() = runTest {
        val product = Product(id = 5L, name = "Pollo", weight = 1000.0, cost = 7.5, quantity = 1, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 31.0, carbs = 0.0, fats = 3.6, isSupplement = false)
        coEvery { mealDao.updateProduct(product) } returns Unit

        val result = repository.saveProduct(product)

        assertThat(result).isEqualTo(5L)
        coVerify { mealDao.updateProduct(product) }
    }

    @Test
    fun `deleteProduct deletes product from DAO`() = runTest {
        val product = Product(id = 5L, name = "Pollo", weight = 1000.0, cost = 7.5, quantity = 1, units = "g", ediblePercent = 1.0, edibleQtyPerUnit = 0.0, proteins = 31.0, carbs = 0.0, fats = 3.6, isSupplement = false)
        coEvery { mealDao.deleteProduct(product) } returns Unit

        repository.deleteProduct(product)

        coVerify { mealDao.deleteProduct(product) }
    }

    @Test
    fun `getAllRecipes returns recipes from DAO`() = runTest {
        val recipes = listOf(
            RecipeWithIngredients(
                recipe = Recipe(id = 1L, name = "Test Recipe", instructions = "Test Instructions", isPortable = true),
                ingredients = emptyList()
            )
        )
        every { mealDao.getAllRecipes() } returns flowOf(recipes)

        val result = repository.getAllRecipes().first()

        assertThat(result).isEqualTo(recipes)
        coVerify { mealDao.getAllRecipes() }
    }

    @Test
    fun `saveRecipe calls saveRecipeWithIngredients on DAO`() = runTest {
        val recipe = RecipeWithIngredients(
            recipe = Recipe(id = 1L, name = "Test Recipe", instructions = "Test Instructions", isPortable = true),
            ingredients = emptyList()
        )
        coEvery { mealDao.saveRecipeWithIngredients(recipe) } returns 1L

        val result = repository.saveRecipe(recipe)

        assertThat(result).isEqualTo(1L)
        coVerify { mealDao.saveRecipeWithIngredients(recipe) }
    }

    @Test
    fun `deleteRecipe calls deleteRecipe on DAO`() = runTest {
        val recipe = Recipe(id = 1L, name = "Test Recipe", instructions = "Test Instructions", isPortable = true)
        coEvery { mealDao.deleteRecipe(recipe) } returns Unit

        repository.deleteRecipe(recipe)

        coVerify { mealDao.deleteRecipe(recipe) }
    }

    @Test
    fun `getMealPlansByState returns meal plans from DAO`() = runTest {
        val plans = listOf(
            MealPlan(id = 1L, parentPlanId = 0L, title = "Plan", notes = "", state = MealPlanState.TEMPLATE, created = LocalDateTime.now(), completed = LocalDateTime.now())
        )
        every { mealDao.getMealPlansByState(MealPlanState.TEMPLATE) } returns flowOf(plans)

        val result = repository.getMealPlansByState(MealPlanState.TEMPLATE).first()

        assertThat(result).isEqualTo(plans)
        coVerify { mealDao.getMealPlansByState(MealPlanState.TEMPLATE) }
    }

    @Test
    fun `saveMealPlan calls saveMealPlanWithMealsAndItems on DAO`() = runTest {
        val plan = MealPlanWithMealsAndItems(
            mealPlan = MealPlan(id = 1L, parentPlanId = 0L, title = "Plan", notes = "", state = MealPlanState.TEMPLATE, created = LocalDateTime.now(), completed = LocalDateTime.now()),
            meals = emptyList()
        )
        coEvery { mealDao.saveMealPlanWithMealsAndItems(plan) } returns 1L

        val result = repository.saveMealPlan(plan)

        assertThat(result).isEqualTo(1L)
        coVerify { mealDao.saveMealPlanWithMealsAndItems(plan) }
    }
}
