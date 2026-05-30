/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.meals

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import org.nexc.core.db.entity.MealPlan
import org.nexc.core.db.entity.Meal
import org.nexc.core.db.entity.MealItem
import org.nexc.core.db.entity.Product
import org.nexc.core.db.relations.MealPlanWithMealsAndItems
import org.nexc.core.db.relations.MealWithItems
import org.nexc.core.db.relations.RecipeWithIngredients
import org.nexc.core.enums.MealPlanState
import org.nexc.core.db.repository.MealRepository
import java.time.LocalDateTime
import javax.inject.Inject

@HiltViewModel
class EditMealPlanViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val mealRepository: MealRepository
) : ViewModel() {

    val mealPlanId: Long = savedStateHandle.get<Long>("mealPlanId") ?: 0L

    private val _mealPlanState = MutableStateFlow<MealPlanWithMealsAndItems?>(null)
    val mealPlanState: StateFlow<MealPlanWithMealsAndItems?> = _mealPlanState.asStateFlow()

    val products: StateFlow<List<Product>> = mealRepository.getAllProducts()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val recipes: StateFlow<List<RecipeWithIngredients>> = mealRepository.getAllRecipes()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    init {
        loadOrCreateMealPlan()
    }

    private fun loadOrCreateMealPlan() {
        viewModelScope.launch {
            if (mealPlanId != 0L) {
                val plan = mealRepository.getMealPlanWithMealsAndItems(mealPlanId)
                if (plan != null) {
                    _mealPlanState.value = plan
                    return@launch
                }
            }

            // Create default blank template
            _mealPlanState.value = MealPlanWithMealsAndItems(
                mealPlan = MealPlan(
                    id = mealPlanId,
                    title = "New Meal Plan",
                    notes = "",
                    state = MealPlanState.TEMPLATE,
                    created = LocalDateTime.now(),
                    completed = LocalDateTime.now()
                ),
                meals = emptyList()
            )
        }
    }

    fun updateMealPlanInfo(title: String, notes: String) {
        _mealPlanState.update { current ->
            current?.copy(
                mealPlan = current.mealPlan.copy(title = title, notes = notes)
            )
        }
    }

    fun saveMealPlan(onSuccess: () -> Unit) {
        viewModelScope.launch {
            mealPlanState.value?.let { plan ->
                mealRepository.saveMealPlan(plan)
                onSuccess()
            }
        }
    }

    fun addMeal(meal: Meal) {
        _mealPlanState.update { current ->
            current?.let {
                val updatedMeals = current.meals + MealWithItems(
                    meal = meal.copy(mealPlanId = current.mealPlan.id, position = current.meals.size),
                    items = emptyList()
                )
                current.copy(meals = updatedMeals.sortedBy { it.meal.time })
            }
        }
    }

    fun deleteMeal(mealId: Long) {
        _mealPlanState.update { current ->
            current?.let {
                val updatedMeals = current.meals.filter { it.meal.id != mealId }
                current.copy(meals = updatedMeals)
            }
        }
    }

    fun addMealItem(mealId: Long, item: MealItem) {
        _mealPlanState.update { current ->
            current?.let {
                val updatedMeals = current.meals.map { m ->
                    if (m.meal.id == mealId) {
                        // Resolve details locally from cache/repos if possible, but DAO handles fetching relation
                        val detail = org.nexc.core.db.relations.MealItemWithDetails(
                            mealItem = item.copy(mealId = mealId, position = m.items.size),
                            product = products.value.find { it.id == item.targetId },
                            recipe = recipes.value.find { it.recipe.id == item.targetId }
                        )
                        m.copy(items = m.items + detail)
                    } else m
                }
                current.copy(meals = updatedMeals)
            }
        }
    }

    fun deleteMealItem(mealId: Long, itemId: Long) {
        _mealPlanState.update { current ->
            current?.let {
                val updatedMeals = current.meals.map { m ->
                    if (m.meal.id == mealId) {
                        m.copy(items = m.items.filter { it.mealItem.id != itemId })
                    } else m
                }
                current.copy(meals = updatedMeals)
            }
        }
    }
}
