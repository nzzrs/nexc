/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.meals

import androidx.compose.foundation.clickable
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
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
import org.nexc.core.db.entity.Product
import org.nexc.core.db.entity.Recipe
import org.nexc.core.db.entity.RecipeIngredient
import org.nexc.core.db.relations.RecipeIngredientWithProduct
import org.nexc.core.db.relations.RecipeWithIngredients
import java.util.Locale

@Composable
fun RecipesLibraryScreen(
    navigateBack: () -> Unit
) {
    val viewModel: RecipesLibraryViewModel = hiltViewModel()
    val recipes by viewModel.recipes.collectAsStateWithLifecycle()
    val products by viewModel.products.collectAsStateWithLifecycle()

    var showAddEditDialog by remember { mutableStateOf<RecipeWithIngredients?>(null) }

    NexcScaffold(
        title = AnnotatedString(stringResource(R.string.recipes)),
        navigateBack = navigateBack,
        fabAction = { showAddEditDialog = RecipeWithIngredients(Recipe(id = 0L), emptyList()) },
        fabText = stringResource(R.string.add_recipe),
        fabIcon = painterResource(R.drawable.ic_add)
    ) { innerPadding ->
        if (recipes.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = stringResource(R.string.no_recipes),
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        } else {
            NexcLazyColumn(innerPadding = innerPadding) {
                items(recipes, key = { it.recipe.id }) { recipe ->
                    RecipeCard(
                        recipeWithIngredients = recipe,
                        onClick = { showAddEditDialog = recipe },
                        onDelete = { viewModel.deleteRecipe(recipe.recipe) }
                    )
                }
            }
        }

        showAddEditDialog?.let { recipeWithIngredients ->
            AddEditRecipeDialog(
                recipeWithIngredients = recipeWithIngredients,
                products = products,
                onDismiss = { showAddEditDialog = null },
                onConfirm = { editedRecipe ->
                    viewModel.saveRecipe(editedRecipe)
                    showAddEditDialog = null
                }
            )
        }
    }
}

@Composable
fun RecipeCard(
    recipeWithIngredients: RecipeWithIngredients,
    onClick: () -> Unit,
    onDelete: () -> Unit
) {
    val recipe = recipeWithIngredients.recipe
    val ingredients = recipeWithIngredients.ingredients

    // Totals calculations
    var totalProt = 0.0
    var totalCarb = 0.0
    var totalFat = 0.0
    var totalCost = 0.0
    ingredients.forEach { item ->
        val scale = item.ingredient.amount / 100.0
        totalProt += item.product.proteins * scale
        totalCarb += item.product.carbs * scale
        totalFat += item.product.fats * scale
        // cost proportion: product.cost is for product.weight
        val costFactor = if (item.product.weight > 0) item.ingredient.amount / item.product.weight else 0.0
        totalCost += item.product.cost * costFactor
    }

    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
            .clickable { onClick() },
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
                        text = recipe.name,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    SuggestionChip(
                        onClick = {},
                        label = {
                            Text(
                                if (recipe.isPortable) stringResource(R.string.portable)
                                else stringResource(R.string.not_portable)
                            )
                        },
                        colors = SuggestionChipDefaults.suggestionChipColors(
                            containerColor = if (recipe.isPortable) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.errorContainer,
                            labelColor = if (recipe.isPortable) MaterialTheme.colorScheme.onPrimaryContainer else MaterialTheme.colorScheme.onErrorContainer
                        )
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

            if (ingredients.isNotEmpty()) {
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = ingredients.joinToString(", ") { "${it.product.name} (${it.ingredient.amount}g)" },
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            if (recipe.instructions.isNotBlank()) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = recipe.instructions,
                    style = MaterialTheme.typography.bodyMedium,
                    maxLines = 2
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "Macros: P ${String.format(Locale.getDefault(), "%.1f", totalProt)}g | C ${String.format(Locale.getDefault(), "%.1f", totalCarb)}g | F ${String.format(Locale.getDefault(), "%.1f", totalFat)}g",
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = "Cost: $${String.format(Locale.getDefault(), "%.2f", totalCost)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.secondary,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddEditRecipeDialog(
    recipeWithIngredients: RecipeWithIngredients,
    products: List<Product>,
    onDismiss: () -> Unit,
    onConfirm: (RecipeWithIngredients) -> Unit
) {
    var name by remember { mutableStateOf(recipeWithIngredients.recipe.name) }
    var instructions by remember { mutableStateOf(recipeWithIngredients.recipe.instructions) }
    var isPortable by remember { mutableStateOf(recipeWithIngredients.recipe.isPortable) }

    val ingredientsList = remember {
        mutableStateListOf<RecipeIngredientWithProduct>().apply {
            addAll(recipeWithIngredients.ingredients)
        }
    }

    var selectedProduct by remember { mutableStateOf<Product?>(null) }
    var amountString by remember { mutableStateOf("") }
    var showProductDropdown by remember { mutableStateOf(false) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(
                text = if (recipeWithIngredients.recipe.id == 0L) stringResource(R.string.add_recipe) else stringResource(R.string.edit)
            )
        },
        text = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text(stringResource(R.string.name)) },
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = instructions,
                    onValueChange = { instructions = it },
                    label = { Text(stringResource(R.string.process)) },
                    minLines = 2,
                    modifier = Modifier.fillMaxWidth()
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = isPortable,
                        onCheckedChange = { isPortable = it }
                    )
                    Text(text = stringResource(R.string.is_portable))
                }

                HorizontalDivider()

                Text(
                    text = stringResource(R.string.composition),
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold
                )

                // Add Ingredient sub-form
                Box(modifier = Modifier.fillMaxWidth()) {
                    OutlinedButton(
                        onClick = { showProductDropdown = true },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(selectedProduct?.name ?: "Select Product/Ingredient")
                    }
                    DropdownMenu(
                        expanded = showProductDropdown,
                        onDismissRequest = { showProductDropdown = false }
                    ) {
                        products.forEach { product ->
                            DropdownMenuItem(
                                text = { Text(product.name) },
                                onClick = {
                                    selectedProduct = product
                                    showProductDropdown = false
                                }
                            )
                        }
                    }
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedTextField(
                        value = amountString,
                        onValueChange = { amountString = it },
                        label = { Text("Amount (g/units)") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                    Button(
                        onClick = {
                            val prod = selectedProduct
                            val amt = amountString.toDoubleOrNull()
                            if (prod != null && amt != null && amt > 0.0) {
                                ingredientsList.add(
                                    RecipeIngredientWithProduct(
                                        ingredient = RecipeIngredient(
                                            productId = prod.id,
                                            amount = amt
                                        ),
                                        product = prod
                                    )
                                )
                                amountString = ""
                                selectedProduct = null
                            }
                        },
                        enabled = selectedProduct != null && amountString.isNotBlank()
                    ) {
                        Text(stringResource(R.string.add))
                    }
                }

                // List added ingredients
                ingredientsList.forEach { ing ->
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "${ing.product.name}: ${ing.ingredient.amount}g",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        IconButton(onClick = { ingredientsList.remove(ing) }) {
                            Icon(
                                painter = painterResource(R.drawable.ic_delete),
                                contentDescription = stringResource(R.string.delete),
                                tint = MaterialTheme.colorScheme.error
                            )
                        }
                    }
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    if (name.isNotBlank()) {
                        val finalRecipe = Recipe(
                            id = if (recipeWithIngredients.recipe.id == 0L) kotlin.random.Random.nextLong() else recipeWithIngredients.recipe.id,
                            name = name,
                            instructions = instructions,
                            isPortable = isPortable
                        )
                        onConfirm(
                            RecipeWithIngredients(
                                recipe = finalRecipe,
                                ingredients = ingredientsList.toList()
                            )
                        )
                    }
                }
            ) {
                Text(stringResource(R.string.save))
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(stringResource(R.string.cancel_dialog))
            }
        }
    )
}
