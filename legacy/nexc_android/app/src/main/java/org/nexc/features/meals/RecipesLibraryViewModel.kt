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
import kotlinx.coroutines.launch
import org.nexc.core.db.entity.Product
import org.nexc.core.db.entity.Recipe
import org.nexc.core.db.relations.RecipeWithIngredients
import org.nexc.core.db.repository.MealRepository
import javax.inject.Inject

@HiltViewModel
class RecipesLibraryViewModel @Inject constructor(
    private val mealRepository: MealRepository
) : ViewModel() {

    val recipes: StateFlow<List<RecipeWithIngredients>> = mealRepository.getAllRecipes()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    val products: StateFlow<List<Product>> = mealRepository.getAllProducts()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    fun saveRecipe(recipeWithIngredients: RecipeWithIngredients) {
        viewModelScope.launch {
            mealRepository.saveRecipe(recipeWithIngredients)
        }
    }

    fun deleteRecipe(recipe: Recipe) {
        viewModelScope.launch {
            mealRepository.deleteRecipe(recipe)
        }
    }
}
