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
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.nexc.R
import org.nexc.core.components.NexcLazyColumn
import org.nexc.core.components.NexcScaffold
import org.nexc.core.db.entity.MealItem
import org.nexc.core.db.relations.*
import org.nexc.core.enums.MealItemType
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import java.util.Locale

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun TrackMealPlanScreen(
    navigateBack: () -> Unit
) {
    val viewModel: TrackMealPlanViewModel = hiltViewModel()
    val planState by viewModel.mealPlanState.collectAsStateWithLifecycle()
    val products by viewModel.products.collectAsStateWithLifecycle()
    val recipes by viewModel.recipes.collectAsStateWithLifecycle()

    val plan = planState ?: return
    val meals = plan.meals

    // State for Dialogs
    var editTimeMealId by remember { mutableStateOf<Long?>(null) }
    var editAmountItemId by remember { mutableStateOf<Long?>(null) }
    var editAmountInitial by remember { mutableDoubleStateOf(0.0) }
    var addMealId by remember { mutableStateOf<Long?>(null) }
    var optionsItemId by remember { mutableStateOf<Long?>(null) }
    var replaceItemId by remember { mutableStateOf<Long?>(null) }

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
                TrackingMacrosCard(
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
    }

    // Edit Meal Time Dialog
    editTimeMealId?.let { mealId ->
        val initialTime = meals.find { it.meal.id == mealId }?.meal?.time ?: LocalTime.now()
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
fun TrackingMacrosCard(
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

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun CircularMacroIndicator(
    label: String,
    consumed: Double,
    target: Double,
    color: Color,
    modifier: Modifier = Modifier
) {
    val progress = if (target > 0) (consumed / target).toFloat() else 0f
    val isExceeded = consumed > target
    val displayProgress = progress.coerceIn(0f, 1f)

    val indicatorColor = if (isExceeded) MaterialTheme.colorScheme.error else color

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = modifier.padding(4.dp)
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.size(76.dp)
        ) {
            CircularProgressIndicator(
                progress = { displayProgress },
                color = indicatorColor,
                strokeWidth = 6.dp,
                trackColor = indicatorColor.copy(alpha = 0.15f),
                modifier = Modifier.fillMaxSize()
            )
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = String.format(Locale.getDefault(), "%.0f", consumed) + "g",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = if (isExceeded) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSecondaryContainer
                )
                if (isExceeded) {
                    val exceededAmount = consumed - target
                    Text(
                        text = "+${String.format(Locale.getDefault(), "%.0f", exceededAmount)}g",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.error,
                        fontWeight = FontWeight.Bold
                    )
                } else {
                    Text(
                        text = "/${String.format(Locale.getDefault(), "%.0f", target)}g",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.7f)
                    )
                }
            }
        }
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = label,
            style = MaterialTheme.typography.labelMedium,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onSecondaryContainer
        )
    }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun MealTrackCard(
    mealWithItems: MealWithItems,
    onItemToggle: (MealItem) -> Unit,
    onTimeClick: ((Long) -> Unit)? = null,
    onAmountClick: ((Long, Double) -> Unit)? = null,
    onNameClick: ((Long) -> Unit)? = null,
    onAddClick: ((Long) -> Unit)? = null
) {
    val meal = mealWithItems.meal
    val timeFormatter = remember { DateTimeFormatter.ofPattern("HH:mm") }

    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp),
        shape = MaterialTheme.shapes.extraLarge
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
                        color = MaterialTheme.colorScheme.primary,
                        modifier = if (onTimeClick != null) {
                            Modifier.clickable { onTimeClick(meal.id) }.padding(vertical = 4.dp)
                        } else {
                            Modifier.padding(vertical = 4.dp)
                        }
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = meal.name,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    if (onAddClick != null) {
                        Spacer(modifier = Modifier.width(6.dp))
                        IconButton(
                            onClick = { onAddClick(meal.id) },
                            modifier = Modifier.size(24.dp)
                        ) {
                            Icon(
                                painter = painterResource(R.drawable.ic_add),
                                contentDescription = "Add Item",
                                modifier = Modifier.size(16.dp),
                                tint = MaterialTheme.colorScheme.primary
                            )
                        }
                    }
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
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        val name = if (detail.mealItem.type == MealItemType.PRODUCT) {
                            detail.product?.name ?: "Unknown Product"
                        } else {
                            detail.recipe?.recipe?.name ?: "Unknown Recipe"
                        }

                        val isItemPortable = detail.isItemPortable

                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.weight(1f)
                        ) {
                            Text(
                                text = name,
                                style = MaterialTheme.typography.bodyLarge,
                                fontWeight = FontWeight.Bold,
                                modifier = if (onNameClick != null) {
                                    Modifier.clickable { onNameClick(detail.mealItem.id) }
                                } else {
                                    Modifier
                                }
                            )
                            if (!isItemPortable) {
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "🏠",
                                    style = MaterialTheme.typography.labelSmall
                                )
                            }
                        }

                        SuggestionChip(
                            onClick = { onAmountClick?.invoke(detail.mealItem.id, detail.mealItem.amount) },
                            enabled = onAmountClick != null,
                            label = {
                                Text(
                                    text = "${String.format(Locale.getDefault(), "%.0f", detail.mealItem.amount)}g",
                                    style = MaterialTheme.typography.labelMedium,
                                    fontWeight = FontWeight.Bold
                                )
                            },
                            colors = SuggestionChipDefaults.suggestionChipColors(
                                containerColor = MaterialTheme.colorScheme.surfaceVariant
                            )
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun EditTimeDialog(
    initialTime: LocalTime,
    onDismiss: () -> Unit,
    onConfirm: (LocalTime) -> Unit
) {
    var hour by remember { mutableStateOf(initialTime.hour.toString().padStart(2, '0')) }
    var minute by remember { mutableStateOf(initialTime.minute.toString().padStart(2, '0')) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit Meal Time") },
        text = {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)
            ) {
                OutlinedTextField(
                    value = hour,
                    onValueChange = { hour = it.take(2).filter { c -> c.isDigit() } },
                    label = { Text("Hour") },
                    modifier = Modifier.weight(1f),
                    singleLine = true
                )
                Text(":", style = MaterialTheme.typography.titleLarge)
                OutlinedTextField(
                    value = minute,
                    onValueChange = { minute = it.take(2).filter { c -> c.isDigit() } },
                    label = { Text("Min") },
                    modifier = Modifier.weight(1f),
                    singleLine = true
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    val h = hour.toIntOrNull()?.coerceIn(0, 23) ?: 0
                    val m = minute.toIntOrNull()?.coerceIn(0, 59) ?: 0
                    onConfirm(LocalTime.of(h, m))
                }
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
fun EditAmountDialog(
    initialAmount: Double,
    onDismiss: () -> Unit,
    onConfirm: (Double) -> Unit
) {
    var amount by remember { mutableStateOf(initialAmount.toString()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit Quantity") },
        text = {
            OutlinedTextField(
                value = amount,
                onValueChange = { amount = it.filter { c -> c.isDigit() || c == '.' } },
                label = { Text("Amount (grams / units)") },
                modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp),
                singleLine = true
            )
        },
        confirmButton = {
            TextButton(
                onClick = {
                    val a = amount.toDoubleOrNull() ?: initialAmount
                    onConfirm(a)
                }
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
fun AddMealItemDialog(
    products: List<org.nexc.core.db.entity.Product>,
    recipes: List<RecipeWithIngredients>,
    onDismiss: () -> Unit,
    onConfirm: (MealItemType, Long, Double) -> Unit
) {
    var type by remember { mutableStateOf(MealItemType.PRODUCT) }
    var searchQuery by remember { mutableStateOf("") }
    var dropdownExpanded by remember { mutableStateOf(false) }

    var selectedProductId by remember { mutableStateOf<Long?>(null) }
    var selectedRecipeId by remember { mutableStateOf<Long?>(null) }
    var amountString by remember { mutableStateOf("") }

    val filteredProducts = if (searchQuery.isBlank()) products else products.filter { it.name.contains(searchQuery, ignoreCase = true) }
    val filteredRecipes = if (searchQuery.isBlank()) recipes else recipes.filter { it.recipe.name.contains(searchQuery, ignoreCase = true) }

    val nameToShow = if (type == MealItemType.PRODUCT) {
        products.find { it.id == selectedProductId }?.name ?: "Select Product"
    } else {
        recipes.find { it.recipe.id == selectedRecipeId }?.recipe?.name ?: "Select Recipe"
    }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Item to Meal") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    FilterChip(
                        selected = type == MealItemType.PRODUCT,
                        onClick = { type = MealItemType.PRODUCT },
                        label = { Text("Product") }
                    )
                    FilterChip(
                        selected = type == MealItemType.RECIPE,
                        onClick = { type = MealItemType.RECIPE },
                        label = { Text("Recipe") }
                    )
                }

                OutlinedTextField(
                    value = searchQuery,
                    onValueChange = {
                        searchQuery = it
                        dropdownExpanded = true
                    },
                    label = { Text("Search") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    trailingIcon = {
                        if (searchQuery.isNotEmpty()) {
                            IconButton(onClick = { searchQuery = "" }) {
                                Icon(painter = painterResource(R.drawable.ic_close), contentDescription = "Clear")
                            }
                        }
                    }
                )

                Box(modifier = Modifier.fillMaxWidth()) {
                    OutlinedButton(
                        onClick = { dropdownExpanded = true },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(nameToShow)
                    }

                    DropdownMenu(
                        expanded = dropdownExpanded,
                        onDismissRequest = { dropdownExpanded = false }
                    ) {
                        if (type == MealItemType.PRODUCT) {
                            filteredProducts.forEach { prod ->
                                DropdownMenuItem(
                                    text = { Text(prod.name) },
                                    onClick = {
                                        selectedProductId = prod.id
                                        searchQuery = prod.name
                                        dropdownExpanded = false
                                    }
                                )
                            }
                            if (filteredProducts.isEmpty()) {
                                DropdownMenuItem(
                                    text = { Text("No results", color = MaterialTheme.colorScheme.onSurfaceVariant) },
                                    onClick = {},
                                    enabled = false
                                )
                            }
                        } else {
                            filteredRecipes.forEach { rec ->
                                DropdownMenuItem(
                                    text = { Text(rec.recipe.name) },
                                    onClick = {
                                        selectedRecipeId = rec.recipe.id
                                        searchQuery = rec.recipe.name
                                        dropdownExpanded = false
                                    }
                                )
                            }
                            if (filteredRecipes.isEmpty()) {
                                DropdownMenuItem(
                                    text = { Text("No results", color = MaterialTheme.colorScheme.onSurfaceVariant) },
                                    onClick = {},
                                    enabled = false
                                )
                            }
                        }
                    }
                }

                OutlinedTextField(
                    value = amountString,
                    onValueChange = { amountString = it.filter { c -> c.isDigit() || c == '.' } },
                    label = { Text("Amount (grams / units)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    val targetId = if (type == MealItemType.PRODUCT) selectedProductId else selectedRecipeId
                    val amt = amountString.toDoubleOrNull() ?: 0.0
                    if (targetId != null && amt > 0.0) {
                        onConfirm(type, targetId, amt)
                    }
                },
                enabled = (if (type == MealItemType.PRODUCT) selectedProductId != null else selectedRecipeId != null) && amountString.isNotBlank()
            ) {
                Text("Add")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
