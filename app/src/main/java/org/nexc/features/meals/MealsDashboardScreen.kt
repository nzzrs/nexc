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

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun MealsDashboardScreen(
    onNavigateToEditPlan: (Long) -> Unit,
    onNavigateToTrackPlan: (Long) -> Unit
) {
    val viewModel: MealsDashboardViewModel = hiltViewModel()
    val templates by viewModel.templates.collectAsStateWithLifecycle()
    val todayPlan by viewModel.todayPlan.collectAsStateWithLifecycle()
    val products by viewModel.products.collectAsStateWithLifecycle()
    val recipes by viewModel.recipes.collectAsStateWithLifecycle()

    var selectedTab by remember { mutableIntStateOf(0) }

    // Dialog state variables
    var editTimeMealId by remember { mutableStateOf<Long?>(null) }
    var editAmountItemId by remember { mutableStateOf<Long?>(null) }
    var editAmountInitial by remember { mutableDoubleStateOf(0.0) }
    var addMealId by remember { mutableStateOf<Long?>(null) }
    var optionsItemId by remember { mutableStateOf<Long?>(null) }
    var replaceItemId by remember { mutableStateOf<Long?>(null) }

    NexcScaffold(
        fabAction = {
            if (selectedTab == 1) {
                val newTemplateId = kotlin.random.Random.nextLong()
                onNavigateToEditPlan(newTemplateId)
            }
        },
        fabText = if (selectedTab == 1) {
            "Create Meal Plan"
        } else {
            null
        },
        fabIcon = if (selectedTab == 1) {
            painterResource(R.drawable.ic_add)
        } else {
            null
        }
    ) { innerPadding ->
        NexcLazyColumn(innerPadding = innerPadding) {
            item {
                PrimaryTabRow(selectedTabIndex = selectedTab) {
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
                        TodayMacrosCard(
                            protConsumed = totalProtConsumed,
                            protTarget = totalProtTarget,
                            carbConsumed = totalCarbConsumed,
                            carbTarget = totalCarbTarget,
                            fatConsumed = totalFatConsumed,
                            fatTarget = totalFatTarget,
                            costConsumed = totalCostConsumed,
                            costTarget = totalCostTarget
                        )
                    }

                    items(meals, key = { it.meal.id }) { mealWithItems ->
                        MealTrackCard(
                            mealWithItems = mealWithItems,
                            onItemToggle = { item -> viewModel.toggleMealItemConsumed(item) },
                            onTimeClick = { mealId -> editTimeMealId = mealId },
                            onAmountClick = { itemId, initialAmt ->
                                editAmountItemId = itemId
                                editAmountInitial = initialAmt
                            },
                            onNameClick = { itemId -> optionsItemId = itemId },
                            onAddClick = { mealId -> addMealId = mealId }
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

    // Edit Meal Time Dialog
    editTimeMealId?.let { mealId ->
        val initialTime = todayPlan?.meals?.find { it.meal.id == mealId }?.meal?.time ?: java.time.LocalTime.now()
        EditTimeDialog(
            initialTime = initialTime,
            onDismiss = { editTimeMealId = null },
            onConfirm = { newTime ->
                viewModel.updateMealTime(mealId, newTime)
                editTimeMealId = null
            }
        )
    }

    // Edit Quantity Dialog
    editAmountItemId?.let { itemId ->
        EditAmountDialog(
            initialAmount = editAmountInitial,
            onDismiss = { editAmountItemId = null },
            onConfirm = { newAmount ->
                viewModel.updateMealItemAmount(itemId, newAmount)
                editAmountItemId = null
            }
        )
    }

    // Item Action Options Dialog
    optionsItemId?.let { itemId ->
        AlertDialog(
            onDismissRequest = { optionsItemId = null },
            title = { Text("Meal Item Options") },
            text = { Text("Select action for this item in today's session.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        replaceItemId = itemId
                        optionsItemId = null
                    }
                ) {
                    Text("Replace")
                }
            },
            dismissButton = {
                TextButton(
                    onClick = {
                        viewModel.deleteMealItem(itemId)
                        optionsItemId = null
                    },
                    colors = ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.error)
                ) {
                    Text("Delete")
                }
            }
        )
    }

    // Replace Item Dialog
    replaceItemId?.let { itemId ->
        AddMealItemDialog(
            products = products,
            recipes = recipes,
            onDismiss = { replaceItemId = null },
            onConfirm = { type, targetId, amount ->
                viewModel.replaceMealItem(itemId, type, targetId, amount)
                replaceItemId = null
            }
        )
    }

    // Add Item Dialog
    addMealId?.let { mealId ->
        AddMealItemDialog(
            products = products,
            recipes = recipes,
            onDismiss = { addMealId = null },
            onConfirm = { type, targetId, amount ->
                viewModel.addMealItem(mealId, type, targetId, amount)
                addMealId = null
            }
        )
    }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun TodayMacrosCard(
    protConsumed: Double,
    protTarget: Double,
    carbConsumed: Double,
    carbTarget: Double,
    fatConsumed: Double,
    fatTarget: Double,
    costConsumed: Double,
    costTarget: Double
) {
    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 12.dp),
        shape = MaterialTheme.shapes.extraLarge,
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.secondaryContainer)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = "Today's Macros",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSecondaryContainer
            )
            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceAround,
                verticalAlignment = Alignment.CenterVertically
            ) {
                CircularMacroIndicator(
                    label = "Protein",
                    consumed = protConsumed,
                    target = protTarget,
                    color = MaterialTheme.colorScheme.primary
                )
                CircularMacroIndicator(
                    label = "Carbs",
                    consumed = carbConsumed,
                    target = carbTarget,
                    color = MaterialTheme.colorScheme.tertiary
                )
                CircularMacroIndicator(
                    label = "Fats",
                    consumed = fatConsumed,
                    target = fatTarget,
                    color = MaterialTheme.colorScheme.error
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                val costExceeded = costConsumed > costTarget && costTarget > 0
                Text(
                    text = "Cost Progress",
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSecondaryContainer
                )
                SuggestionChip(
                    onClick = {},
                    label = {
                        Text(
                            text = "$${String.format(Locale.getDefault(), "%.2f", costConsumed)} / $${String.format(Locale.getDefault(), "%.2f", costTarget)}",
                            style = MaterialTheme.typography.labelSmall,
                            fontWeight = FontWeight.Bold
                        )
                    },
                    colors = SuggestionChipDefaults.suggestionChipColors(
                        containerColor = if (costExceeded) MaterialTheme.colorScheme.errorContainer else MaterialTheme.colorScheme.primaryContainer,
                        labelColor = if (costExceeded) MaterialTheme.colorScheme.onErrorContainer else MaterialTheme.colorScheme.onPrimaryContainer
                    )
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
        shape = MaterialTheme.shapes.extraLarge
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = plan.title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.weight(1f)
                )
                if (isSelected) {
                    Icon(
                        painter = painterResource(R.drawable.ic_check),
                        contentDescription = "Selected",
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier
                            .padding(start = 8.dp)
                            .size(20.dp)
                    )
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

            // Visual macro chips
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                SuggestionChip(
                    onClick = {},
                    label = { Text("P: ${String.format(Locale.getDefault(), "%.0f", totalProt)}g", style = MaterialTheme.typography.labelSmall) },
                    colors = SuggestionChipDefaults.suggestionChipColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.6f)
                    ),
                    modifier = Modifier.height(28.dp)
                )
                SuggestionChip(
                    onClick = {},
                    label = { Text("C: ${String.format(Locale.getDefault(), "%.0f", totalCarb)}g", style = MaterialTheme.typography.labelSmall) },
                    colors = SuggestionChipDefaults.suggestionChipColors(
                        containerColor = MaterialTheme.colorScheme.tertiaryContainer.copy(alpha = 0.6f)
                    ),
                    modifier = Modifier.height(28.dp)
                )
                SuggestionChip(
                    onClick = {},
                    label = { Text("F: ${String.format(Locale.getDefault(), "%.0f", totalFat)}g", style = MaterialTheme.typography.labelSmall) },
                    colors = SuggestionChipDefaults.suggestionChipColors(
                        containerColor = MaterialTheme.colorScheme.errorContainer.copy(alpha = 0.6f)
                    ),
                    modifier = Modifier.height(28.dp)
                )
                SuggestionChip(
                    onClick = {},
                    label = { Text("$${String.format(Locale.getDefault(), "%.2f", totalCost)}", style = MaterialTheme.typography.labelSmall) },
                    colors = SuggestionChipDefaults.suggestionChipColors(
                        containerColor = MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.6f)
                    ),
                    modifier = Modifier.height(28.dp)
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Select button - compact
            if (isSelected) {
                AssistChip(
                    onClick = {},
                    label = { Text("Active today") },
                    leadingIcon = {
                        Icon(
                            painter = painterResource(R.drawable.ic_check),
                            contentDescription = null,
                            modifier = Modifier.size(16.dp)
                        )
                    },
                    colors = AssistChipDefaults.assistChipColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer,
                        labelColor = MaterialTheme.colorScheme.onPrimaryContainer,
                        leadingIconContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                )
            } else {
                OutlinedButton(
                    onClick = onSelect,
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp)
                ) {
                    Icon(
                        painter = painterResource(R.drawable.ic_play_arrow),
                        contentDescription = null,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("Select", style = MaterialTheme.typography.labelMedium)
                }
            }
        }
    }
}
