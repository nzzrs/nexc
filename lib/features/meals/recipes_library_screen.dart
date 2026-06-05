/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../core/db/relations.dart';
import '../../core/db/meal_repository.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/components/nexc_scaffold.dart';

class RecipesLibraryScreen extends ConsumerStatefulWidget {
  const RecipesLibraryScreen({super.key});

  @override
  ConsumerState<RecipesLibraryScreen> createState() => _RecipesLibraryScreenState();
}

class _RecipesLibraryScreenState extends ConsumerState<RecipesLibraryScreen> {
  String _searchQuery = "";

  void _showAddEditRecipe(BuildContext context, RecipeWithIngredients recipe, List<Product> products) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditRecipeDialog(
        recipeWithIngredients: recipe,
        products: products,
        onDismiss: () => Navigator.pop(context),
        onConfirm: (editedRecipe) {
          ref.read(mealRepositoryProvider).saveRecipeWithIngredients(editedRecipe);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(allRecipesProvider);
    final products = ref.watch(allProductsProvider).value ?? [];
    final theme = Theme.of(context);

    return NexcScaffold(
      title: const Text("Recipes"),
      navigateBack: () => Navigator.pop(context),
      fabAction: () {
        _showAddEditRecipe(
          context,
          RecipeWithIngredients(
            recipe: Recipe(
              id: 0,
              name: _searchQuery.trim(),
              instructions: "",
              isPortable: true,
            ),
            ingredients: [],
          ),
          products,
        );
      },
      fabIcon: const Icon(Icons.add),
      fabText: "Add Recipe",
      content: (context, padding) {
        return recipesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (recipes) {
            final filteredRecipes = _searchQuery.isEmpty
                ? recipes
                : recipes.where((r) {
                    final nameMatch = r.recipe.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    final ingredientMatch = r.ingredients.any(
                        (ing) => ing.product.name.toLowerCase().contains(_searchQuery.toLowerCase()));
                    return nameMatch || ingredientMatch;
                  }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Search recipes...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filteredRecipes.isEmpty
                      ? const Center(child: Text("No recipes found"))
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 80.0),
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = filteredRecipes[index];
                            return Padding(
                              key: ValueKey(recipe.recipe.id),
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: RecipeCard(
                                recipeWithIngredients: recipe,
                                onClick: () {
                                  _showAddEditRecipe(context, recipe, products);
                                },
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Delete Recipe"),
                                      content: Text("Are you sure you want to delete '${recipe.recipe.name}'?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text("Delete", style: TextStyle(color: theme.colorScheme.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    ref.read(mealRepositoryProvider).deleteRecipe(recipe.recipe);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  final RecipeWithIngredients recipeWithIngredients;
  final VoidCallback onClick;
  final VoidCallback onDelete;

  const RecipeCard({
    super.key,
    required this.recipeWithIngredients,
    required this.onClick,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = recipeWithIngredients.recipe;
    final ingredients = recipeWithIngredients.ingredients;

    // Totals calculations
    double totalProt = 0.0;
    double totalCarb = 0.0;
    double totalFat = 0.0;
    for (final item in ingredients) {
      final scale = item.ingredient.amount / 100.0;
      totalProt += item.product.proteins * scale;
      totalCarb += item.product.carbs * scale;
      totalFat += item.product.fats * scale;
    }

    return Card(
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: recipe.isPortable
                                ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                                : theme.colorScheme.errorContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            recipe.isPortable ? "Portable" : "Home only",
                            style: TextStyle(
                              fontSize: 10,
                              color: recipe.isPortable
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (ingredients.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  ingredients.map((i) => "${i.product.name} (${i.ingredient.amount.toStringAsFixed(0)}${i.ingredient.amountUnits ?? 'g'})").join(", "),
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              if (recipe.instructions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  recipe.instructions,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Macros: P ${totalProt.toStringAsFixed(1)}g | C ${totalCarb.toStringAsFixed(1)}g | F ${totalFat.toStringAsFixed(1)}g",
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddEditRecipeDialog extends StatefulWidget {
  final RecipeWithIngredients recipeWithIngredients;
  final List<Product> products;
  final VoidCallback onDismiss;
  final void Function(RecipeWithIngredients) onConfirm;

  const AddEditRecipeDialog({
    super.key,
    required this.recipeWithIngredients,
    required this.products,
    required this.onDismiss,
    required this.onConfirm,
  });

  @override
  State<AddEditRecipeDialog> createState() => _AddEditRecipeDialogState();
}

class _AddEditRecipeDialogState extends State<AddEditRecipeDialog> {
  late TextEditingController _nameController;
  late TextEditingController _instructionsController;
  late bool _isPortable;
  late List<RecipeIngredientWithProduct> _ingredients;

  int? _selectedProductId;
  final TextEditingController _amountController = TextEditingController();
  String _selectedIngredientUnit = "g";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedIngredientUnit = "g";
    _nameController = TextEditingController(text: widget.recipeWithIngredients.recipe.name);
    _instructionsController =
        TextEditingController(text: widget.recipeWithIngredients.recipe.instructions);
    _isPortable = widget.recipeWithIngredients.recipe.isPortable;
    _ingredients = List.from(widget.recipeWithIngredients.ingredients);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProducts = _searchQuery.isEmpty
        ? widget.products
        : widget.products.searchAndSort(_searchQuery);

    return AlertDialog(
      title: Text(widget.recipeWithIngredients.recipe.id == 0 ? "Add Recipe" : "Edit Recipe"),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: "Instructions/Process"),
                minLines: 2,
                maxLines: 5,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _ingredients.any((ing) => !ing.product.isPortable) ? false : _isPortable,
                    onChanged: _ingredients.any((ing) => !ing.product.isPortable)
                        ? null
                        : (val) {
                            if (val != null) setState(() => _isPortable = val);
                          },
                  ),
                  Expanded(
                    child: Text(
                      _ingredients.any((ing) => !ing.product.isPortable)
                          ? "Is Portable (Contains non-portable ingredients)"
                          : "Is Portable",
                      style: TextStyle(
                        color: _ingredients.any((ing) => !ing.product.isPortable) ? theme.disabledColor : null,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const Text("Composition", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_selectedProductId != null) ...[
                Builder(builder: (context) {
                  final prod = widget.products.firstWhereOrNull((p) => p.id == _selectedProductId);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(prod?.name ?? ""),
                      subtitle: Text("${prod?.proteins}g P | ${prod?.carbs}g C | ${prod?.fats}g F"),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _selectedProductId = null),
                      ),
                    ),
                  );
                }),
              ] else ...[
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Search Ingredient...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, idx) {
                        final p = filteredProducts[idx];
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text("${p.proteins}g P | ${p.carbs}g C | ${p.fats}g F"),
                          onTap: () => setState(() {
                            _selectedProductId = p.id;
                            _searchQuery = "";
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Amount"),
                    ),
                  ),
                   const SizedBox(width: 8),
                  Builder(
                    builder: (context) {
                      final prod = widget.products.firstWhereOrNull((p) => p.id == _selectedProductId);
                      final showMl = prod == null || (prod.mlToGFactor != null && prod.mlToGFactor! > 0);
                      final showUnits = prod == null || (prod.unitWeight != null && prod.unitWeight! > 0);
                      if (_selectedIngredientUnit == "ml" && !showMl) {
                        _selectedIngredientUnit = "g";
                      }
                      if (_selectedIngredientUnit == "units" && !showUnits) {
                        _selectedIngredientUnit = "g";
                      }
                      return DropdownButton<String>(
                        value: _selectedIngredientUnit,
                        items: [
                          const DropdownMenuItem(value: "g", child: Text("g")),
                          if (showMl)
                            const DropdownMenuItem(value: "ml", child: Text("ml")),
                          if (showUnits)
                            const DropdownMenuItem(value: "units", child: Text("units")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedIngredientUnit = val;
                            });
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final prod = widget.products.firstWhereOrNull((p) => p.id == _selectedProductId);
                      final amt = double.tryParse(_amountController.text) ?? 0.0;
                      if (prod != null && amt > 0.0) {
                        setState(() {
                          _ingredients.add(
                            RecipeIngredientWithProduct(
                              ingredient: RecipeIngredient(
                                id: 0,
                                recipeId: widget.recipeWithIngredients.recipe.id,
                                productId: prod.id,
                                amount: amt,
                                amountUnits: _selectedIngredientUnit,
                              ),
                              product: prod,
                            ),
                          );
                          _amountController.clear();
                          _selectedProductId = null;
                        });
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._ingredients.map((ing) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${ing.product.name}: ${ing.ingredient.amount.toStringAsFixed(0)}${ing.ingredient.amountUnits ?? 'g'}"),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      onPressed: () {
                        setState(() {
                          _ingredients.remove(ing);
                        });
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onDismiss,
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              final newRecipe = Recipe(
                id: widget.recipeWithIngredients.recipe.id,
                name: name,
                instructions: _instructionsController.text.trim(),
                isPortable: _isPortable,
              );
              widget.onConfirm(
                RecipeWithIngredients(recipe: newRecipe, ingredients: _ingredients),
              );
            }
          },
        ),
      ],
    );
  }
}
