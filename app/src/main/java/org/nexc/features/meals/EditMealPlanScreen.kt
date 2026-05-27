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
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.nexc.R
import org.nexc.core.components.NexcLazyColumn
import org.nexc.core.components.NexcScaffold
import org.nexc.core.components.NexcButton
import org.nexc.core.db.entity.Meal
import org.nexc.core.db.entity.MealItem
import org.nexc.core.db.entity.Product
import org.nexc.core.db.relations.RecipeWithIngredients
import org.nexc.core.db.relations.MealWithItems
import org.nexc.core.enums.MealItemType
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditMealPlanScreen(
    navigateBack: () -> Unit
) {
    val viewModel: EditMealPlanViewModel = hiltViewModel()
    val planState by viewModel.mealPlanState.collectAsStateWithLifecycle()
    val products by viewModel.products.collectAsStateWithLifecycle()
    val recipes by viewModel.recipes.collectAsStateWithLifecycle()

    var showAddMealDialog by remember { mutableStateOf(false) }
    var showAddItemForMealId by remember { mutableStateOf<Long?>(null) }

    val plan = planState ?: return

    NexcScaffold(
        title = AnnotatedString(stringResource(R.string.create_meal_plan)),
        navigateBack = navigateBack,
        actions = listOf {
            viewModel.saveMealPlan {
                navigateBack()
            }
        },
        actionsDescription = listOf(stringResource(R.string.save)),
        actionsEnabled = listOf(plan.mealPlan.title.isNotBlank())
    ) { innerPadding ->
        NexcLazyColumn(innerPadding = innerPadding) {
            item {
                OutlinedTextField(
                    value = plan.mealPlan.title,
                    onValueChange = { viewModel.updateMealPlanInfo(it, plan.mealPlan.notes) },
                    label = { Text("Plan Title") },
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                OutlinedTextField(
                    value = plan.mealPlan.notes,
                    onValueChange = { viewModel.updateMealPlanInfo(plan.mealPlan.title, it) },
                    label = { Text("Notes/Goal") },
                    modifier = Modifier.fillMaxWidth()
                )
            }

            item {
                Spacer(modifier = Modifier.height(24.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Meals",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(16.dp))
                    OutlinedButton(
                        onClick = { showAddMealDialog = true },
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp)
                    ) {
                        Icon(painter = painterResource(R.drawable.ic_add), contentDescription = null, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(stringResource(R.string.add_meal), style = MaterialTheme.typography.labelMedium)
                    }
                }
            }

            items(plan.meals, key = { it.meal.id }) { mealWithItems ->
                MealEditCard(
                    mealWithItems = mealWithItems,
                    onDeleteMeal = { viewModel.deleteMeal(mealWithItems.meal.id) },
                    onAddItemClick = { showAddItemForMealId = mealWithItems.meal.id },
                    onDeleteItem = { itemId -> viewModel.deleteMealItem(mealWithItems.meal.id, itemId) },
                    onReplaceItem = { oldItemId -> showAddItemForMealId = mealWithItems.meal.id; viewModel.deleteMealItem(mealWithItems.meal.id, oldItemId) }
                )
            }
        }

        if (showAddMealDialog) {
            AddMealDialog(
                onDismiss = { showAddMealDialog = false },
                onConfirm = { meal ->
                    viewModel.addMeal(meal)
                    showAddMealDialog = false
                }
            )
        }

        showAddItemForMealId?.let { mealId ->
            AddMealItemDialog(
                products = products,
                recipes = recipes,
                onDismiss = { showAddItemForMealId = null },
                onConfirm = { item ->
                    viewModel.addMealItem(mealId, item)
                    showAddItemForMealId = null
                }
            )
        }
    }
}

@Composable
fun MealEditCard(
    mealWithItems: MealWithItems,
    onDeleteMeal: () -> Unit,
    onAddItemClick: () -> Unit,
    onDeleteItem: (Long) -> Unit,
    onReplaceItem: (Long) -> Unit = {}
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
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
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
                IconButton(onClick = onDeleteMeal) {
                    Icon(
                        painter = painterResource(R.drawable.ic_delete),
                        contentDescription = "Delete Meal",
                        tint = MaterialTheme.colorScheme.error
                    )
                }
            }

            if (meal.notes.isNotBlank()) {
                Text(
                    text = meal.notes,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(8.dp))
            }

            HorizontalDivider(modifier = Modifier.padding(vertical = 4.dp))

            // Meal Items List
            mealWithItems.items.forEach { detail ->
                var showItemMenu by remember { mutableStateOf(false) }

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 2.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    val name = if (detail.mealItem.type == MealItemType.PRODUCT) {
                        detail.product?.name ?: "Unknown Product"
                    } else {
                        detail.recipe?.recipe?.name ?: "Unknown Recipe"
                    }

                    Text(
                        text = "$name: ${detail.mealItem.amount}g/units",
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.weight(1f)
                    )

                    Box {
                        IconButton(onClick = { showItemMenu = true }) {
                            Icon(
                                painter = painterResource(R.drawable.ic_more_vert),
                                contentDescription = "Options",
                                modifier = Modifier.size(20.dp)
                            )
                        }
                        DropdownMenu(
                            expanded = showItemMenu,
                            onDismissRequest = { showItemMenu = false }
                        ) {
                            DropdownMenuItem(
                                text = { Text("Replace") },
                                onClick = {
                                    showItemMenu = false
                                    onReplaceItem(detail.mealItem.id)
                                },
                                leadingIcon = {
                                    Icon(
                                        painter = painterResource(R.drawable.ic_reorder),
                                        contentDescription = null
                                    )
                                }
                            )
                            DropdownMenuItem(
                                text = { Text("Delete") },
                                onClick = {
                                    showItemMenu = false
                                    onDeleteItem(detail.mealItem.id)
                                },
                                leadingIcon = {
                                    Icon(
                                        painter = painterResource(R.drawable.ic_delete),
                                        contentDescription = null,
                                        tint = MaterialTheme.colorScheme.error
                                    )
                                }
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedButton(
                onClick = onAddItemClick,
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(painter = painterResource(R.drawable.ic_add), contentDescription = null)
                Spacer(modifier = Modifier.width(4.dp))
                Text("Add Food / Recipe")
            }
        }
    }
}

@Composable
fun AddMealDialog(
    onDismiss: () -> Unit,
    onConfirm: (Meal) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var hour by remember { mutableStateOf("") }
    var minute by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Meal Slot") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text(stringResource(R.string.meal_name)) },
                    modifier = Modifier.fillMaxWidth()
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = hour,
                        onValueChange = { hour = it },
                        label = { Text("Hour (0-23)") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = minute,
                        onValueChange = { minute = it },
                        label = { Text("Minute (0-59)") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                }

                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("How to eat/Notes") },
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    val h = hour.toIntOrNull() ?: 12
                    val m = minute.toIntOrNull() ?: 0
                    if (name.isNotBlank()) {
                        val time = LocalTime.of(h.coerceIn(0, 23), m.coerceIn(0, 59))
                        onConfirm(
                            Meal(
                                id = kotlin.random.Random.nextLong(),
                                name = name,
                                time = time,
                                notes = notes
                            )
                        )
                    }
                }
            ) {
                Text(stringResource(R.string.add))
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(stringResource(R.string.cancel_dialog))
            }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddMealItemDialog(
    products: List<Product>,
    recipes: List<RecipeWithIngredients>,
    onDismiss: () -> Unit,
    onConfirm: (MealItem) -> Unit
) {
    var type by remember { mutableStateOf(MealItemType.PRODUCT) }
    var selectedProductId by remember { mutableStateOf<Long?>(null) }
    var selectedRecipeId by remember { mutableStateOf<Long?>(null) }
    var amountString by remember { mutableStateOf("") }
    var searchQuery by remember { mutableStateOf("") }

    var dropdownExpanded by remember { mutableStateOf(false) }

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
                // Selector type
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

                // Search + Dropdown selector
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
                    onValueChange = { amountString = it },
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
                        onConfirm(
                            MealItem(
                                id = kotlin.random.Random.nextLong(),
                                type = type,
                                targetId = targetId,
                                amount = amt
                            )
                        )
                    }
                },
                enabled = (if (type == MealItemType.PRODUCT) selectedProductId != null else selectedRecipeId != null) && amountString.isNotBlank()
            ) {
                Text(stringResource(R.string.add))
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(stringResource(R.string.cancel_dialog))
            }
        }
    )
}
