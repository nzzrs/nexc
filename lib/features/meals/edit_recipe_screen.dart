/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/clearable_search_field.dart';
import '../../core/db/relations.dart';
import '../../core/providers/meals_providers.dart';

/// Full-screen recipe editor used for both creating and updating recipes.
///
/// On save the edited recipe is handed to [onConfirm] (when provided) and then
/// returned to the caller through `Navigator.pop`.
class EditRecipeScreen extends ConsumerStatefulWidget {
  final RecipeWithIngredients recipeWithIngredients;
  final List<Product> products;
  final FutureOr<void> Function(RecipeWithIngredients)? onConfirm;

  const EditRecipeScreen({
    super.key,
    required this.recipeWithIngredients,
    required this.products,
    this.onConfirm,
  });

  @override
  ConsumerState<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends ConsumerState<EditRecipeScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _instructionsController;
  late bool _isPortable;
  late List<RecipeIngredientWithProduct> _ingredients;

  int? _selectedProductId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _ingredientSearchController =
      TextEditingController();
  String _selectedIngredientUnit = "g";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.recipeWithIngredients.recipe.name,
    );
    _instructionsController = TextEditingController(
      text: widget.recipeWithIngredients.recipe.instructions,
    );
    _isPortable = widget.recipeWithIngredients.recipe.isPortable;
    _ingredients = List.from(widget.recipeWithIngredients.ingredients);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _amountController.dispose();
    _ingredientSearchController.dispose();
    super.dispose();
  }

  Product? get _selectedProduct => widget.products.firstWhereOrNull(
    (product) => product.id == _selectedProductId,
  );

  bool get _hasNonPortableIngredients =>
      _ingredients.any((ingredient) => !ingredient.product.isPortable);

  /// Unit currently offered by the dropdown, limited to what the selected
  /// product supports.
  String get _effectiveIngredientUnit {
    final product = _selectedProduct;
    final supportsMl = product == null || product.canMeasureInMl;
    final supportsUnits = product == null || product.canMeasureInUnits;
    if (_selectedIngredientUnit == "ml" && !supportsMl) return "g";
    if (_selectedIngredientUnit == "units" && !supportsUnits) return "g";
    return _selectedIngredientUnit;
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a recipe name")));
      return;
    }

    final updated = RecipeWithIngredients(
      recipe: Recipe(
        id: widget.recipeWithIngredients.recipe.id,
        name: name,
        instructions: _instructionsController.text.trim(),
        isPortable: _isPortable,
      ),
      ingredients: _ingredients,
    );

    if (widget.onConfirm != null) {
      await widget.onConfirm!(updated);
    }
    if (!mounted) return;
    Navigator.pop(context, updated);
  }

  void _addIngredient() {
    final product = _selectedProduct;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (product == null || amount <= 0.0) return;

    setState(() {
      _ingredients.add(
        RecipeIngredientWithProduct(
          ingredient: RecipeIngredient(
            id: 0,
            recipeId: widget.recipeWithIngredients.recipe.id,
            productId: product.id,
            amount: amount,
            amountUnits: _effectiveIngredientUnit,
          ),
          product: product,
        ),
      );
      _amountController.clear();
      _selectedProductId = null;
      _selectedIngredientUnit = "g";
    });
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProductId = product.id;
      _selectedIngredientUnit = "g";
      _searchQuery = "";
      _ingredientSearchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usageCounts = ref.watch(productUsageCountsProvider).value;
    final inStockProductIds = ref.watch(inStockProductIdsProvider).value;

    final filteredProducts = widget.products.searchAndSort(
      _searchQuery,
      usageCounts: usageCounts,
      inStockProductIds: inStockProductIds,
    );
    final selectedProduct = _selectedProduct;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipeWithIngredients.recipe.id == 0
              ? "Add Recipe"
              : "Edit Recipe",
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Cancel",
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Save",
            onPressed: _submit,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructionsController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: "Instructions/Process",
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: Text(
                _hasNonPortableIngredients
                    ? "Is Portable (Contains non-portable ingredients)"
                    : "Is Portable",
                style: TextStyle(
                  color: _hasNonPortableIngredients
                      ? theme.disabledColor
                      : null,
                ),
              ),
              value: _hasNonPortableIngredients ? false : _isPortable,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: _hasNonPortableIngredients
                  ? null
                  : (value) {
                      if (value != null) setState(() => _isPortable = value);
                    },
            ),
            const Divider(),
            Text(
              "Composition",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (selectedProduct != null) ...[
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(selectedProduct.name),
                  subtitle: Text(
                    "${selectedProduct.proteins}g P | ${selectedProduct.carbs}g C | ${selectedProduct.fats}g F",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: "Clear selection",
                    onPressed: () => setState(() => _selectedProductId = null),
                  ),
                ),
              ),
            ] else ...[
              ClearableSearchField(
                controller: _ingredientSearchController,
                labelText: "Search Ingredient...",
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text("No products found"),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ListTile(
                              title: Text(product.name),
                              subtitle: Text(
                                "${product.proteins}g P | ${product.carbs}g C | ${product.fats}g F",
                              ),
                              onTap: () => _selectProduct(product),
                            );
                          },
                        ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) {
                    final showMl =
                        selectedProduct == null ||
                        selectedProduct.canMeasureInMl;
                    final showUnits =
                        selectedProduct == null ||
                        selectedProduct.canMeasureInUnits;
                    return DropdownButton<String>(
                      value: _effectiveIngredientUnit,
                      items: [
                        const DropdownMenuItem(value: "g", child: Text("g")),
                        if (showMl)
                          const DropdownMenuItem(
                            value: "ml",
                            child: Text("ml"),
                          ),
                        if (showUnits)
                          const DropdownMenuItem(
                            value: "units",
                            child: Text("units"),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedIngredientUnit = value);
                        }
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addIngredient,
                  child: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._ingredients.map((ingredient) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${ingredient.product.name}: ${ingredient.ingredient.amount.toStringAsFixed(0)}${ingredient.ingredient.amountUnits ?? 'g'}",
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: "Remove ingredient",
                    onPressed: () {
                      setState(() {
                        _ingredients.remove(ingredient);
                      });
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: Text(
                  widget.recipeWithIngredients.recipe.id == 0
                      ? "Add Recipe"
                      : "Save Changes",
                ),
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
