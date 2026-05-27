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
import org.nexc.core.db.entity.MealItem
import org.nexc.core.db.entity.Meal
import org.nexc.core.enums.MealItemType
import java.time.LocalTime
import org.nexc.core.db.relations.MealPlanWithMealsAndItems
import org.nexc.core.db.repository.MealRepository
import javax.inject.Inject

@HiltViewModel
class TrackMealPlanViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val mealRepository: MealRepository
) : ViewModel() {

    val mealPlanId: Long = savedStateHandle.get<Long>("mealPlanId") ?: 0L

    private val _mealPlanState = MutableStateFlow<MealPlanWithMealsAndItems?>(null)
    val mealPlanState: StateFlow<MealPlanWithMealsAndItems?> = _mealPlanState.asStateFlow()

    val products = mealRepository.getAllProducts().stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )

    val recipes = mealRepository.getAllRecipes().stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )

    init {
        loadMealPlan()
    }

    private fun loadMealPlan() {
        viewModelScope.launch {
            if (mealPlanId != 0L) {
                val flow = flow {
                    while (true) {
                        val plan = mealRepository.getMealPlanWithMealsAndItems(mealPlanId)
                        emit(plan)
                        kotlinx.coroutines.delay(1000) // Simple polling for updates
                    }
                }
                flow.collect { plan ->
                    _mealPlanState.value = plan
                }
            }
        }
    }

    private fun reloadMealPlan() {
        viewModelScope.launch {
            val plan = mealRepository.getMealPlanWithMealsAndItems(mealPlanId)
            _mealPlanState.value = plan
        }
    }

    fun toggleMealItemConsumed(mealItem: MealItem) {
        viewModelScope.launch {
            val updatedItem = mealItem.copy(consumed = !mealItem.consumed)
            mealRepository.updateMealItem(updatedItem)
            reloadMealPlan()
        }
    }

    fun updateMealTime(mealId: Long, newTime: LocalTime) {
        viewModelScope.launch {
            _mealPlanState.value?.meals?.find { it.meal.id == mealId }?.meal?.let { meal ->
                mealRepository.updateMeal(meal.copy(time = newTime))
                reloadMealPlan()
            }
        }
    }

    fun updateMealItemAmount(itemId: Long, newAmount: Double) {
        viewModelScope.launch {
            var foundItem: MealItem? = null
            _mealPlanState.value?.meals?.forEach { m ->
                m.items.forEach { detail ->
                    if (detail.mealItem.id == itemId) {
                        foundItem = detail.mealItem
                    }
                }
            }
            foundItem?.let { item ->
                mealRepository.updateMealItem(item.copy(amount = newAmount))
                reloadMealPlan()
            }
        }
    }

    fun deleteMealItem(itemId: Long) {
        viewModelScope.launch {
            var foundItem: MealItem? = null
            _mealPlanState.value?.meals?.forEach { m ->
                m.items.forEach { detail ->
                    if (detail.mealItem.id == itemId) {
                        foundItem = detail.mealItem
                    }
                }
            }
            foundItem?.let { item ->
                mealRepository.deleteMealItem(item)
                reloadMealPlan()
            }
        }
    }

    fun addMealItem(mealId: Long, type: MealItemType, targetId: Long, amount: Double) {
        viewModelScope.launch {
            val meal = _mealPlanState.value?.meals?.find { it.meal.id == mealId }
            val maxPos = meal?.items?.maxOfOrNull { it.mealItem.position } ?: -1
            val newItem = MealItem(
                id = 0L,
                mealId = mealId,
                type = type,
                targetId = targetId,
                amount = amount,
                consumed = false,
                position = maxPos + 1
            )
            mealRepository.insertMealItem(newItem)
            reloadMealPlan()
        }
    }

    fun replaceMealItem(oldItemId: Long, newType: MealItemType, newTargetId: Long, newAmount: Double) {
        viewModelScope.launch {
            var oldItem: MealItem? = null
            _mealPlanState.value?.meals?.forEach { m ->
                m.items.forEach { detail ->
                    if (detail.mealItem.id == oldItemId) {
                        oldItem = detail.mealItem
                    }
                }
            }
            oldItem?.let { item ->
                mealRepository.deleteMealItem(item)
                val newItem = MealItem(
                    id = 0L,
                    mealId = item.mealId,
                    type = newType,
                    targetId = newTargetId,
                    amount = newAmount,
                    consumed = false,
                    position = item.position
                )
                mealRepository.insertMealItem(newItem)
                reloadMealPlan()
            }
        }
    }
}
