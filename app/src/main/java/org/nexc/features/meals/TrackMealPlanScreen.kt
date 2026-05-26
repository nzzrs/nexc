/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.meals

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.nexc.R
import org.nexc.core.components.NexcLazyColumn
import org.nexc.core.components.NexcScaffold
import org.nexc.core.db.relations.*
import org.nexc.core.enums.MealItemType
import java.time.format.DateTimeFormatter
import java.util.Locale

@Composable
fun TrackMealPlanScreen(
    navigateBack: () -> Unit
) {
    val viewModel: TrackMealPlanViewModel = hiltViewModel()
    val planState by viewModel.mealPlanState.collectAsStateWithLifecycle()

    val plan = planState ?: return

    val meals = plan.meals

    // Live consumed & target totals calculations
    var totalProtTarget = 0.0
    var totalCarbTarget = 0.0
    var totalFatTarget = 0.0
    var totalCostTarget = 0.0

    var totalProtConsumed = 0.0
    var totalCarbConsumed = 0.0
    var totalFatConsumed = 0.0
    var totalCostConsumed = 0.0

    meals.forEach { m ->
        m.items.forEach { detail ->
            val scale = detail.mealItem.amount / 100.0
            var itemProt = 0.0
            var itemCarb = 0.0
            var itemFat = 0.0
            var itemCost = 0.0

            if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
                itemProt = detail.product.proteins * scale
                itemCarb = detail.product.carbs * scale
                itemFat = detail.product.fats * scale
                val costFactor = if (detail.product.weight > 0) detail.mealItem.amount / detail.product.weight else 0.0
                itemCost = detail.product.cost * costFactor
            } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
                detail.recipe.ingredients.forEach { ing ->
                    val ingScale = (ing.ingredient.amount / 100.0) * scale
                    itemProt += ing.product.proteins * ingScale
                    itemCarb += ing.product.carbs * ingScale
                    itemFat += ing.product.fats * ingScale
                    val costFactor = if (ing.product.weight > 0) (ing.ingredient.amount * scale) / ing.product.weight else 0.0
                    itemCost += ing.product.cost * costFactor
                }
            }

            totalProtTarget += itemProt
            totalCarbTarget += itemCarb
            totalFatTarget += itemFat
            totalCostTarget += itemCost

            if (detail.mealItem.consumed) {
                totalProtConsumed += itemProt
                totalCarbConsumed += itemCarb
                totalFatConsumed += itemFat
                totalCostConsumed += itemCost
            }
        }
    }

    NexcScaffold(
        title = AnnotatedString(plan.mealPlan.title),
        navigateBack = navigateBack
    ) { innerPadding ->
        NexcLazyColumn(innerPadding = innerPadding) {
            item {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 12.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.secondaryContainer)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "Today's Consumption Progress",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSecondaryContainer
                        )
                        Spacer(modifier = Modifier.height(8.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Column {
                                Text(
                                    text = "Proteins: ${String.format(Locale.getDefault(), "%.1f", totalProtConsumed)}g / ${String.format(Locale.getDefault(), "%.1f", totalProtTarget)}g",
                                    style = MaterialTheme.typography.bodyMedium
                                )
                                Text(
                                    text = "Carbs: ${String.format(Locale.getDefault(), "%.1f", totalCarbConsumed)}g / ${String.format(Locale.getDefault(), "%.1f", totalCarbTarget)}g",
                                    style = MaterialTheme.typography.bodyMedium
                                )
                                Text(
                                    text = "Fats: ${String.format(Locale.getDefault(), "%.1f", totalFatConsumed)}g / ${String.format(Locale.getDefault(), "%.1f", totalFatTarget)}g",
                                    style = MaterialTheme.typography.bodyMedium
                                )
                            }
                            Column(horizontalAlignment = Alignment.End) {
                                Text(
                                    text = "Cost: $${String.format(Locale.getDefault(), "%.2f", totalCostConsumed)} / $${String.format(Locale.getDefault(), "%.2f", totalCostTarget)}",
                                    style = MaterialTheme.typography.bodyMedium,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                }
            }

            items(meals, key = { it.meal.id }) { mealWithItems ->
                MealTrackCard(
                    mealWithItems = mealWithItems,
                    onItemToggle = { item -> viewModel.toggleMealItemConsumed(item) }
                )
            }
        }
    }
}

@Composable
fun MealTrackCard(
    mealWithItems: MealWithItems,
    onItemToggle: (org.nexc.core.db.entity.MealItem) -> Unit
) {
    val meal = mealWithItems.meal
    val timeFormatter = remember { DateTimeFormatter.ofPattern("HH:mm") }

    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp),
        shape = MaterialTheme.shapes.medium
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = meal.time.format(timeFormatter),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.primary
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = meal.name,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                }

                val isMealPortable = mealWithItems.isMealPortable
                Text(
                    text = if (isMealPortable) "🎒 Portable" else "🏠 Home only",
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.Medium,
                    color = if (isMealPortable) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error
                )
            }

            if (meal.notes.isNotBlank()) {
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = meal.notes,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(8.dp))
            HorizontalDivider()
            Spacer(modifier = Modifier.height(8.dp))

            mealWithItems.items.forEach { detail ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = detail.mealItem.consumed,
                        onCheckedChange = { onItemToggle(detail.mealItem) }
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Column {
                        val name = if (detail.mealItem.type == MealItemType.PRODUCT) {
                            detail.product?.name ?: "Unknown Product"
                        } else {
                            detail.recipe?.recipe?.name ?: "Unknown Recipe"
                        }

                        val isItemPortable = detail.isItemPortable
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = "$name (${detail.mealItem.amount}g/units)",
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.SemiBold
                            )
                            if (!isItemPortable) {
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(
                                    text = "🏠 Home only",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = MaterialTheme.colorScheme.error
                                )
                            }
                        }

                        // Calculate detail macros
                        val scale = detail.mealItem.amount / 100.0
                        var detailProt = 0.0
                        var detailCarb = 0.0
                        var detailFat = 0.0
                        var detailCost = 0.0

                        if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
                            detailProt = detail.product.proteins * scale
                            detailCarb = detail.product.carbs * scale
                            detailFat = detail.product.fats * scale
                            val costFactor = if (detail.product.weight > 0) detail.mealItem.amount / detail.product.weight else 0.0
                            detailCost = detail.product.cost * costFactor
                        } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
                            detail.recipe.ingredients.forEach { ing ->
                                val ingScale = (ing.ingredient.amount / 100.0) * scale
                                detailProt += ing.product.proteins * ingScale
                                detailCarb += ing.product.carbs * ingScale
                                detailFat += ing.product.fats * ingScale
                                val costFactor = if (ing.product.weight > 0) (ing.ingredient.amount * scale) / ing.product.weight else 0.0
                                detailCost += ing.product.cost * costFactor
                            }
                        }

                        Text(
                            text = "P: ${String.format(Locale.getDefault(), "%.1f", detailProt)}g | C: ${String.format(Locale.getDefault(), "%.1f", detailCarb)}g | F: ${String.format(Locale.getDefault(), "%.1f", detailFat)}g • $${String.format(Locale.getDefault(), "%.2f", detailCost)}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}
