/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.meals

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import org.nexc.core.db.entity.MealPlan
import org.nexc.core.db.entity.Meal
import org.nexc.core.db.entity.MealItem
import org.nexc.core.db.relations.MealPlanWithMealsAndItems
import org.nexc.core.db.relations.MealWithItems
import org.nexc.core.db.relations.MealItemWithDetails
import org.nexc.core.enums.MealPlanState
import org.nexc.core.db.repository.MealRepository
import java.time.LocalDateTime
import java.time.LocalDate
import javax.inject.Inject
import kotlin.random.Random

@HiltViewModel
class MealsDashboardViewModel @Inject constructor(
    private val mealRepository: MealRepository
) : ViewModel() {

    val templates: StateFlow<List<MealPlanWithMealsAndItems>> =
        mealRepository.getMealPlansWithMealsAndItemsByState(MealPlanState.TEMPLATE)
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = emptyList()
            )

    val todayPlan: StateFlow<MealPlanWithMealsAndItems?> =
        mealRepository.getMealPlansWithMealsAndItemsByState(MealPlanState.LOGGED)
            .map { logs ->
                logs.find { it.mealPlan.created.toLocalDate() == LocalDate.now() }
            }
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = null
            )

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

    fun deleteMealPlan(mealPlan: MealPlan) {
        viewModelScope.launch {
            mealRepository.deleteMealPlan(mealPlan)
        }
    }

    fun updateMealTime(mealId: Long, newTime: java.time.LocalTime) {
        viewModelScope.launch {
            todayPlan.value?.meals?.find { it.meal.id == mealId }?.meal?.let { meal ->
                mealRepository.updateMeal(meal.copy(time = newTime))
            }
        }
    }

    fun updateMealItemAmount(itemId: Long, newAmount: Double) {
        viewModelScope.launch {
            var foundItem: MealItem? = null
            todayPlan.value?.meals?.forEach { m ->
                m.items.forEach { detail ->
                    if (detail.mealItem.id == itemId) {
                        foundItem = detail.mealItem
                    }
                }
            }
            foundItem?.let { item ->
                mealRepository.updateMealItem(item.copy(amount = newAmount))
            }
        }
    }

    fun deleteMealItem(itemId: Long) {
        viewModelScope.launch {
            var foundItem: MealItem? = null
            todayPlan.value?.meals?.forEach { m ->
                m.items.forEach { detail ->
                    if (detail.mealItem.id == itemId) {
                        foundItem = detail.mealItem
                    }
                }
            }
            foundItem?.let { item ->
                mealRepository.deleteMealItem(item)
            }
        }
    }

    fun addMealItem(mealId: Long, type: org.nexc.core.enums.MealItemType, targetId: Long, amount: Double) {
        viewModelScope.launch {
            val meal = todayPlan.value?.meals?.find { it.meal.id == mealId }
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
        }
    }

    fun replaceMealItem(oldItemId: Long, newType: org.nexc.core.enums.MealItemType, newTargetId: Long, newAmount: Double) {
        viewModelScope.launch {
            var oldItem: MealItem? = null
            todayPlan.value?.meals?.forEach { m ->
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
            }
        }
    }

    fun selectMealPlanForToday(template: MealPlanWithMealsAndItems) {
        viewModelScope.launch {
            // First, delete any existing logged plan of today to replace it.
            val logsList = mealRepository.getMealPlansWithMealsAndItemsByState(MealPlanState.LOGGED).first()
            val existingTodayPlan = logsList.find { it.mealPlan.created.toLocalDate() == LocalDate.now() }
            if (existingTodayPlan != null) {
                mealRepository.deleteMealPlan(existingTodayPlan.mealPlan)
            }

            // Now, instantiate the new one
            startTrackingFromTemplate(template) { }
        }
    }

    fun toggleMealItemConsumed(mealItem: MealItem) {
        viewModelScope.launch {
            val updatedItem = mealItem.copy(consumed = !mealItem.consumed)
            mealRepository.updateMealItem(updatedItem)
        }
    }

    fun startTrackingFromTemplate(template: MealPlanWithMealsAndItems, onComplete: (Long) -> Unit) {
        viewModelScope.launch {
            val newPlanId = Random.nextLong()
            val newPlan = MealPlan(
                id = newPlanId,
                parentPlanId = template.mealPlan.id,
                title = template.mealPlan.title,
                notes = template.mealPlan.notes,
                state = MealPlanState.LOGGED,
                created = LocalDateTime.now(),
                completed = LocalDateTime.now()
            )

            val newMeals = template.meals.map { m ->
                val newMealId = Random.nextLong()
                val newItems = m.items.map { item ->
                    MealItemWithDetails(
                        mealItem = MealItem(
                            id = Random.nextLong(),
                            mealId = newMealId,
                            type = item.mealItem.type,
                            targetId = item.mealItem.targetId,
                            amount = item.mealItem.amount,
                            consumed = false,
                            position = item.mealItem.position
                        ),
                        product = item.product,
                        recipe = item.recipe
                    )
                }

                MealWithItems(
                    meal = Meal(
                        id = newMealId,
                        mealPlanId = newPlanId,
                        name = m.meal.name,
                        time = m.meal.time,
                        notes = m.meal.notes,
                        position = m.meal.position
                    ),
                    items = newItems
                )
            }

            val newPlanWithMeals = MealPlanWithMealsAndItems(
                mealPlan = newPlan,
                meals = newMeals
            )

            mealRepository.saveMealPlan(newPlanWithMeals)
            onComplete(newPlanId)
        }
    }

    fun startEmptyTracking(onComplete: (Long) -> Unit) {
        viewModelScope.launch {
            val newPlanId = Random.nextLong()
            val newPlan = MealPlan(
                id = newPlanId,
                parentPlanId = 0L,
                title = "Today's Meal Log",
                notes = "",
                state = MealPlanState.LOGGED,
                created = LocalDateTime.now(),
                completed = LocalDateTime.now()
            )
            mealRepository.saveMealPlan(MealPlanWithMealsAndItems(newPlan, emptyList()))
            onComplete(newPlanId)
        }
    }
}
