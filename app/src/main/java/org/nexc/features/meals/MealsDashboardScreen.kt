/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.meals

import androidx.compose.foundation.clickable
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
import org.nexc.core.components.NexcButton
import org.nexc.core.db.entity.MealPlan
import org.nexc.core.db.entity.MealItem
import org.nexc.core.db.relations.MealPlanWithMealsAndItems
import org.nexc.core.db.relations.MealWithItems
import org.nexc.core.db.relations.isMealPortable
import org.nexc.core.db.relations.isItemPortable
import org.nexc.core.enums.MealItemType
import java.time.format.DateTimeFormatter
import java.util.Locale

@Composable
fun MealsDashboardScreen(
    onNavigateToProducts: () -> Unit,
    onNavigateToRecipes: () -> Unit,
    onNavigateToEditPlan: (Long) -> Unit,
    onNavigateToTrackPlan: (Long) -> Unit
) {
    val viewModel: MealsDashboardViewModel = hiltViewModel()
    val templates by viewModel.templates.collectAsStateWithLifecycle()
    val todayPlan by viewModel.todayPlan.collectAsStateWithLifecycle()

    var selectedTab by remember { mutableIntStateOf(0) }
    var showMenu by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize()) {
        NexcScaffold(
            title = AnnotatedString(stringResource(R.string.meals)),
            actions = listOf { showMenu = true },
            actionsIcons = listOf(painterResource(R.drawable.ic_library)),
            actionsDescription = listOf("Library"),
            fabAction = {
                if (selectedTab == 0) {
                    todayPlan?.let {
                        onNavigateToEditPlan(it.mealPlan.id)
                    }
                } else {
                    val newTemplateId = kotlin.random.Random.nextLong()
                    onNavigateToEditPlan(newTemplateId)
                }
            },
            fabText = if (selectedTab == 0) {
                if (todayPlan != null) "Edit Today's Plan" else null
            } else {
                "Create Meal Plan"
            },
            fabIcon = if (selectedTab == 0) {
                if (todayPlan != null) painterResource(R.drawable.ic_edit) else null
            } else {
                painterResource(R.drawable.ic_add)
            }
        ) { innerPadding ->
            NexcLazyColumn(innerPadding = innerPadding) {
                item {
                    TabRow(selectedTabIndex = selectedTab) {
                        Tab(
                            selected = selectedTab == 0,
                            onClick = { selectedTab = 0 },
                            text = { Text("Today's plan") }
                        )
                        Tab(
                            selected = selectedTab == 1,
                            onClick = { selectedTab = 1 },
                            text = { Text("Meal plans") }
                        )
                    }
                }

                if (selectedTab == 0) {
                    // Today's plan content
                    val plan = todayPlan
                    if (plan == null) {
                        item {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(top = 64.dp),
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Text(
                                    text = "Select a meal plan for today",
                                    style = MaterialTheme.typography.titleMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                                Spacer(modifier = Modifier.height(16.dp))
                                NexcButton(
                                    text = "Go to Meal Plans",
                                    icon = painterResource(R.drawable.ic_arrow_forward),
                                    onClick = { selectedTab = 1 }
                                )
                            }
                        }
                    } else {
                        // Display tracking details
                        val meals = plan.meals

                        // Totals calculations
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

                        item {
                            Card(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 12.dp),
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
                } else {
                    // Meal plans templates content
                    if (templates.isEmpty()) {
                        item {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(200.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "No meal plans yet",
                                    style = MaterialTheme.typography.bodyLarge,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                    } else {
                        items(templates, key = { it.mealPlan.id }) { plan ->
                            val isSelected = todayPlan?.mealPlan?.parentPlanId == plan.mealPlan.id
                            MealPlanCard(
                                planWithMeals = plan,
                                isSelected = isSelected,
                                onClick = {
                                    onNavigateToEditPlan(plan.mealPlan.id)
                                },
                                onDelete = { viewModel.deleteMealPlan(plan.mealPlan) },
                                onSelect = {
                                    viewModel.selectMealPlanForToday(plan)
                                }
                            )
                        }
                    }
                }
            }
        }

        Box(
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(end = 16.dp, top = 56.dp)
        ) {
            DropdownMenu(
                expanded = showMenu,
                onDismissRequest = { showMenu = false }
            ) {
                DropdownMenuItem(
                    text = { Text("Products Library") },
                    onClick = {
                        showMenu = false
                        onNavigateToProducts()
                    },
                    leadingIcon = {
                        Icon(
                            painter = painterResource(R.drawable.ic_library),
                            contentDescription = null
                        )
                    }
                )
                DropdownMenuItem(
                    text = { Text("Recipes Library") },
                    onClick = {
                        showMenu = false
                        onNavigateToRecipes()
                    },
                    leadingIcon = {
                        Icon(
                            painter = painterResource(R.drawable.ic_reorder),
                            contentDescription = null
                        )
                    }
                )
            }
        }
    }
}

@Composable
fun MealPlanCard(
    planWithMeals: MealPlanWithMealsAndItems,
    isSelected: Boolean,
    onClick: () -> Unit,
    onDelete: () -> Unit,
    onSelect: () -> Unit
) {
    val plan = planWithMeals.mealPlan
    val meals = planWithMeals.meals

    // Totals calculations
    var totalProt = 0.0
    var totalCarb = 0.0
    var totalFat = 0.0
    var totalCost = 0.0

    meals.forEach { m ->
        m.items.forEach { detail ->
            val scale = detail.mealItem.amount / 100.0
            if (detail.mealItem.type == MealItemType.PRODUCT && detail.product != null) {
                totalProt += detail.product.proteins * scale
                totalCarb += detail.product.carbs * scale
                totalFat += detail.product.fats * scale
                val costFactor = if (detail.product.weight > 0) detail.mealItem.amount / detail.product.weight else 0.0
                totalCost += detail.product.cost * costFactor
            } else if (detail.mealItem.type == MealItemType.RECIPE && detail.recipe != null) {
                detail.recipe.ingredients.forEach { ing ->
                    val ingScale = (ing.ingredient.amount / 100.0) * scale
                    totalProt += ing.product.proteins * ingScale
                    totalCarb += ing.product.carbs * ingScale
                    totalFat += ing.product.fats * ingScale
                    val costFactor = if (ing.product.weight > 0) (ing.ingredient.amount * scale) / ing.product.weight else 0.0
                    totalCost += ing.product.cost * costFactor
                }
            }
        }
    }

    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp)
            .clickable { onClick() },
        shape = MaterialTheme.shapes.large
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = plan.title,
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                        if (isSelected) {
                            Spacer(modifier = Modifier.width(8.dp))
                            SuggestionChip(
                                onClick = {},
                                label = { Text("Selected") },
                                colors = SuggestionChipDefaults.suggestionChipColors(
                                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                                    labelColor = MaterialTheme.colorScheme.onPrimaryContainer
                                )
                            )
                        }
                    }
                }
                IconButton(onClick = onDelete) {
                    Icon(
                        painter = painterResource(R.drawable.ic_delete),
                        contentDescription = stringResource(R.string.delete),
                        tint = MaterialTheme.colorScheme.error
                    )
                }
            }

            if (plan.notes.isNotBlank()) {
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = plan.notes,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Show Meals breakdown
            if (meals.isNotEmpty()) {
                Text(
                    text = "${meals.size} scheduled meals (${meals.joinToString { it.meal.name }})",
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.Medium
                )
                Spacer(modifier = Modifier.height(8.dp))
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "P: ${String.format(Locale.getDefault(), "%.1f", totalProt)}g | C: ${String.format(Locale.getDefault(), "%.1f", totalCarb)}g | F: ${String.format(Locale.getDefault(), "%.1f", totalFat)}g",
                        style = MaterialTheme.typography.bodySmall,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        text = "Est. Cost: $${String.format(Locale.getDefault(), "%.2f", totalCost)}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.secondary
                    )
                }

                if (isSelected) {
                    NexcButton(
                        text = "Selected",
                        icon = painterResource(R.drawable.ic_check),
                        elevated = false,
                        enabled = false,
                        onClick = {}
                    )
                } else {
                    NexcButton(
                        text = "Select",
                        icon = painterResource(R.drawable.ic_play_arrow),
                        elevated = false,
                        onClick = onSelect
                    )
                }
            }
        }
    }
}
