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
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProductsLibraryScreen(
    navigateBack: () -> Unit
) {
    val viewModel: ProductsLibraryViewModel = hiltViewModel()
    val products by viewModel.products.collectAsStateWithLifecycle()

    var showAddEditDialog by remember { mutableStateOf<Product?>(null) }

    NexcScaffold(
        title = AnnotatedString(stringResource(R.string.products)),
        navigateBack = navigateBack,
        fabAction = { showAddEditDialog = Product(id = 0L) },
        fabText = stringResource(R.string.add_product),
        fabIcon = painterResource(R.drawable.ic_add)
    ) { innerPadding ->
        if (products.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = stringResource(R.string.no_products),
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        } else {
            NexcLazyColumn(innerPadding = innerPadding) {
                items(products, key = { it.id }) { product ->
                    ProductCard(
                        product = product,
                        onClick = { showAddEditDialog = product },
                        onDelete = { viewModel.deleteProduct(product) }
                    )
                }
            }
        }

        showAddEditDialog?.let { product ->
            AddEditProductDialog(
                product = product,
                onDismiss = { showAddEditDialog = null },
                onConfirm = { editedProduct ->
                    viewModel.saveProduct(editedProduct)
                    showAddEditDialog = null
                }
            )
        }
    }
}

@Composable
fun ProductCard(
    product: Product,
    onClick: () -> Unit,
    onDelete: () -> Unit
) {
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
                        text = product.name,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    if (product.isSupplement) {
                        Spacer(modifier = Modifier.width(8.dp))
                        SuggestionChip(
                            onClick = {},
                            label = { Text(stringResource(R.string.supplement)) },
                            colors = SuggestionChipDefaults.suggestionChipColors(
                                containerColor = MaterialTheme.colorScheme.tertiaryContainer,
                                labelColor = MaterialTheme.colorScheme.onTertiaryContainer
                            )
                        )
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

            Spacer(modifier = Modifier.height(8.dp))

            // Nutritional details
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Text(
                        text = "Prot: ${product.proteins}g",
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Text(
                        text = "Carb: ${product.carbs}g",
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Text(
                        text = "Fat: ${product.fats}g",
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "Weight: ${product.weight}${product.units}",
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Text(
                        text = "Cost: $${String.format(Locale.getDefault(), "%.2f", product.cost)}",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.secondary
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddEditProductDialog(
    product: Product,
    onDismiss: () -> Unit,
    onConfirm: (Product) -> Unit
) {
    var name by remember { mutableStateOf(product.name) }
    var weight by remember { mutableStateOf(if (product.weight == 0.0) "" else product.weight.toString()) }
    var cost by remember { mutableStateOf(if (product.cost == 0.0) "" else product.cost.toString()) }
    var quantity by remember { mutableStateOf(if (product.quantity == 0) "" else product.quantity.toString()) }
    var units by remember { mutableStateOf(product.units) }
    var ediblePercent by remember { mutableStateOf(product.ediblePercent.toString()) }
    var edibleQtyPerUnit by remember { mutableStateOf(product.edibleQtyPerUnit.toString()) }
    var proteins by remember { mutableStateOf(product.proteins.toString()) }
    var carbs by remember { mutableStateOf(product.carbs.toString()) }
    var fats by remember { mutableStateOf(product.fats.toString()) }
    var isSupplement by remember { mutableStateOf(product.isSupplement) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(
                text = if (product.id == 0L) stringResource(R.string.add_product) else stringResource(R.string.edit)
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

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = weight,
                        onValueChange = { weight = it },
                        label = { Text("Weight") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = units,
                        onValueChange = { units = it },
                        label = { Text("Units") },
                        modifier = Modifier.weight(1f)
                    )
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = cost,
                        onValueChange = { cost = it },
                        label = { Text("Cost ($)") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = quantity,
                        onValueChange = { quantity = it },
                        label = { Text("Stock Qty") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = ediblePercent,
                        onValueChange = { ediblePercent = it },
                        label = { Text("Edible %") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = edibleQtyPerUnit,
                        onValueChange = { edibleQtyPerUnit = it },
                        label = { Text("Edible Qty") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                }

                Text(
                    text = "Macros per 100g",
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 8.dp)
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = proteins,
                        onValueChange = { proteins = it },
                        label = { Text("Prot") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = carbs,
                        onValueChange = { carbs = it },
                        label = { Text("Carb") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = fats,
                        onValueChange = { fats = it },
                        label = { Text("Fat") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.weight(1f)
                    )
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = isSupplement,
                        onCheckedChange = { isSupplement = it }
                    )
                    Text(text = stringResource(R.string.is_supplement))
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    if (name.isNotBlank()) {
                        val finalProduct = Product(
                            id = if (product.id == 0L) kotlin.random.Random.nextLong() else product.id,
                            name = name,
                            weight = weight.toDoubleOrNull() ?: 0.0,
                            cost = cost.toDoubleOrNull() ?: 0.0,
                            quantity = quantity.toIntOrNull() ?: 0,
                            units = units,
                            ediblePercent = ediblePercent.toDoubleOrNull() ?: 1.0,
                            edibleQtyPerUnit = edibleQtyPerUnit.toDoubleOrNull() ?: 0.0,
                            proteins = proteins.toDoubleOrNull() ?: 0.0,
                            carbs = carbs.toDoubleOrNull() ?: 0.0,
                            fats = fats.toDoubleOrNull() ?: 0.0,
                            isSupplement = isSupplement
                        )
                        onConfirm(finalProduct)
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
