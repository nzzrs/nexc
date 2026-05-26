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
                        kotlinx.coroutines.delay(1000) // Simple polling for updates or let Room handle if Flow was returned
                    }
                }
                flow.collect { plan ->
                    _mealPlanState.value = plan
                }
            }
        }
    }

    fun toggleMealItemConsumed(mealItem: MealItem) {
        viewModelScope.launch {
            val updatedItem = mealItem.copy(consumed = !mealItem.consumed)
            mealRepository.updateMealItem(updatedItem)
            // Reload manually to reflect state immediately
            val plan = mealRepository.getMealPlanWithMealsAndItems(mealPlanId)
            _mealPlanState.value = plan
        }
    }
}
