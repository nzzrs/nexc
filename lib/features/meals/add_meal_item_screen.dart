/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:collection/collection.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/db/meal_repository.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/components/clearable_search_field.dart';
import 'edit_product_screen.dart';
import 'edit_recipe_screen.dart';

class _SelectedItemConfig {
  final MealItemType type;
  final int targetId;
  final String name;
  double amount;
  AmountUnit unit;

  _SelectedItemConfig({
    required this.type,
    required this.targetId,
    required this.name,
    this.amount = 100.0,
    this.unit = AmountUnit.GRAMS,
  });
}

class AddMealItemScreen extends ConsumerStatefulWidget {
  final int mealId;
  final bool isReplace;
  final int? replaceItemId;
  final List<Product> products;
  final List<RecipeWithIngredients> recipes;
  final void Function(
    MealItemType type,
    int targetId,
    double amount,
    AmountUnit amountUnit,
  )?
  onConfirm;

  const AddMealItemScreen({
    super.key,
    required this.mealId,
    this.isReplace = false,
    this.replaceItemId,
    required this.products,
    required this.recipes,
    this.onConfirm,
  });

  @override
  ConsumerState<AddMealItemScreen> createState() => _AddMealItemScreenState();
}

class _AddMealItemScreenState extends ConsumerState<AddMealItemScreen> {
  MealItemType _type = MealItemType.PRODUCT;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final Map<String, _SelectedItemConfig> _selectedItems = {};
  final TextEditingController _amountController = TextEditingController(
    text: "100",
  );
  AmountUnit _amountUnit = AmountUnit.GRAMS;

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _showAddEditProduct(Product product) async {
    final savedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditProductScreen(
          product: product,
          onConfirm: (updated) async {
            await ref.read(mealRepositoryProvider).saveProduct(updated);
          },
        ),
      ),
    );

    if (savedProduct != null && mounted) {
      final key = 'product_${savedProduct.id}';
      setState(() {
        _selectedItems[key] = _SelectedItemConfig(
          type: MealItemType.PRODUCT,
          targetId: savedProduct.id,
          name: savedProduct.name,
        );
      });
    }
  }

  Future<void> _showAddEditRecipe(RecipeWithIngredients recipe) async {
    await Navigator.push<RecipeWithIngredients>(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditRecipeScreen(
          recipeWithIngredients: recipe,
          products: widget.products,
          onConfirm: (updated) async {
            final id = await ref
                .read(mealRepositoryProvider)
                .saveRecipeWithIngredients(updated);
            if (!mounted) return;
            final key = 'recipe_$id';
            setState(() {
              _selectedItems[key] = _SelectedItemConfig(
                type: MealItemType.RECIPE,
                targetId: id,
                name: updated.recipe.name,
              );
            });
          },
        ),
      ),
    );
  }

  void _toggleProduct(Product p) {
    final key = 'product_${p.id}';
    setState(() {
      if (widget.isReplace) {
        _selectedItems.clear();
        _selectedItems[key] = _SelectedItemConfig(
          type: MealItemType.PRODUCT,
          targetId: p.id,
          name: p.name,
          amount: double.tryParse(_amountController.text) ?? 100.0,
          unit: _amountUnit,
        );
      } else {
        if (_selectedItems.containsKey(key)) {
          _selectedItems.remove(key);
        } else {
          _selectedItems[key] = _SelectedItemConfig(
            type: MealItemType.PRODUCT,
            targetId: p.id,
            name: p.name,
            amount: double.tryParse(_amountController.text) ?? 100.0,
            unit: _amountUnit,
          );
        }
      }
    });
  }

  void _toggleRecipe(RecipeWithIngredients r) {
    final key = 'recipe_${r.recipe.id}';
    setState(() {
      if (widget.isReplace) {
        _selectedItems.clear();
        _selectedItems[key] = _SelectedItemConfig(
          type: MealItemType.RECIPE,
          targetId: r.recipe.id,
          name: r.recipe.name,
          amount: double.tryParse(_amountController.text) ?? 100.0,
          unit: _amountUnit,
        );
      } else {
        if (_selectedItems.containsKey(key)) {
          _selectedItems.remove(key);
        } else {
          _selectedItems[key] = _SelectedItemConfig(
            type: MealItemType.RECIPE,
            targetId: r.recipe.id,
            name: r.recipe.name,
            amount: double.tryParse(_amountController.text) ?? 100.0,
            unit: _amountUnit,
          );
        }
      }
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

    final filteredRecipes = _searchQuery.isEmpty
        ? widget.recipes
        : widget.recipes
              .where(
                (r) => r.recipe.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    final isAnySelected = _selectedItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isReplace
              ? "Replace Meal Item"
              : _selectedItems.isEmpty
              ? "Add Item to Meal"
              : "Add Items (${_selectedItems.length} selected)",
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text("Products"),
                    selected: _type == MealItemType.PRODUCT,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _type = MealItemType.PRODUCT;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Recipes"),
                    selected: _type == MealItemType.RECIPE,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _type = MealItemType.RECIPE;
                        });
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    tooltip: _type == MealItemType.PRODUCT
                        ? "Create Product"
                        : "Create Recipe",
                    onPressed: () {
                      if (_type == MealItemType.PRODUCT) {
                        _showAddEditProduct(
                          Product(
                            id: 0,
                            name: _searchQuery,
                            defaultUnits: "g",
                            edibleQtyPerUnit: 1.0,
                            kcal: 0.0,
                            proteins: 0.0,
                            carbsAvailable: null,
                            fats: 0.0,
                            isSupplement: false,
                            isPortable: true,
                            isStockRaw: false,
                          ),
                        );
                      } else {
                        _showAddEditRecipe(
                          RecipeWithIngredients(
                            recipe: Recipe(
                              id: 0,
                              name: _searchQuery,
                              instructions: "",
                              isPortable: false,
                            ),
                            ingredients: [],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: ClearableSearchField(
                controller: _searchController,
                labelText: _type == MealItemType.PRODUCT
                    ? "Search food or product..."
                    : "Search recipes...",
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            if (isAnySelected)
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _selectedItems.values.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InputChip(
                        label: Text(item.name),
                        selected: true,
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          final key = item.type == MealItemType.PRODUCT
                              ? 'product_${item.targetId}'
                              : 'recipe_${item.targetId}';
                          setState(() {
                            _selectedItems.remove(key);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            Expanded(
              child: _type == MealItemType.PRODUCT
                  ? filteredProducts.isEmpty
                        ? const Center(child: Text("No products found"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, idx) {
                              final p = filteredProducts[idx];
                              final key = 'product_${p.id}';
                              final isSelected = _selectedItems.containsKey(
                                key,
                              );
                              final inStock =
                                  inStockProductIds?.contains(p.id) ?? false;

                              return Card(
                                elevation: isSelected ? 2 : 0,
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                          .withValues(alpha: 0.5)
                                    : theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.3),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: ListTile(
                                  leading: inStock
                                      ? const Tooltip(
                                          message: "In Stock",
                                          child: Icon(
                                            Icons.inventory_2,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                        )
                                      : null,
                                  title: Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${p.proteins}g P | ${p.carbs}g C | ${p.fats}g F",
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                        ),
                                        tooltip: "Edit Product",
                                        onPressed: () => _showAddEditProduct(p),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      else
                                        const Icon(
                                          Icons.circle_outlined,
                                          color: Colors.grey,
                                        ),
                                    ],
                                  ),
                                  onTap: () => _toggleProduct(p),
                                ),
                              );
                            },
                          )
                  : filteredRecipes.isEmpty
                  ? const Center(child: Text("No recipes found"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, idx) {
                        final r = filteredRecipes[idx];
                        final key = 'recipe_${r.recipe.id}';
                        final isSelected = _selectedItems.containsKey(key);

                        return Card(
                          elevation: isSelected ? 2 : 0,
                          color: isSelected
                              ? theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.5,
                                )
                              : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text(
                              r.recipe.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "${r.ingredients.length} ingredients",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  tooltip: "Edit Recipe",
                                  onPressed: () => _showAddEditRecipe(r),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                else
                                  const Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey,
                                  ),
                              ],
                            ),
                            onTap: () => _toggleRecipe(r),
                          ),
                        );
                      },
                    ),
            ),
            if (isAnySelected) ...[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Builder(
                      builder: (context) {
                        bool showMl = false;
                        bool showUnits = false;

                        if (_selectedItems.isNotEmpty) {
                          bool allSupportMl = true;
                          bool allSupportUnits = true;

                          for (final item in _selectedItems.values) {
                            if (item.type == MealItemType.PRODUCT) {
                              final p = widget.products.firstWhereOrNull(
                                (prod) => prod.id == item.targetId,
                              );
                              if (p == null || !p.canMeasureInMl) {
                                allSupportMl = false;
                              }
                              if (p == null || !p.canMeasureInUnits) {
                                allSupportUnits = false;
                              }
                            } else {
                              allSupportMl = false;
                            }
                          }

                          showMl = allSupportMl;
                          showUnits = allSupportUnits;
                        }

                        if (_amountUnit == AmountUnit.ML && !showMl) {
                          Future.microtask(
                            () =>
                                setState(() => _amountUnit = AmountUnit.GRAMS),
                          );
                        }
                        if (_amountUnit == AmountUnit.UNITS && !showUnits) {
                          Future.microtask(
                            () =>
                                setState(() => _amountUnit = AmountUnit.GRAMS),
                          );
                        }

                        return Row(
                          children: [
                            ChoiceChip(
                              label: const Text("Grams"),
                              selected: _amountUnit == AmountUnit.GRAMS,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(
                                    () => _amountUnit = AmountUnit.GRAMS,
                                  );
                                }
                              },
                            ),
                            if (showMl) ...[
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text("ml"),
                                selected: _amountUnit == AmountUnit.ML,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _amountUnit = AmountUnit.ML);
                                  }
                                },
                              ),
                            ],
                            if (showUnits) ...[
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text("Units"),
                                selected: _amountUnit == AmountUnit.UNITS,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(
                                      () => _amountUnit = AmountUnit.UNITS,
                                    );
                                  }
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: "Portion Amount",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                          ),
                          onPressed: () async {
                            final amount =
                                double.tryParse(_amountController.text) ??
                                100.0;
                            final repo = ref.read(mealRepositoryProvider);

                            for (final item in _selectedItems.values) {
                              if (widget.onConfirm != null) {
                                widget.onConfirm!(
                                  item.type,
                                  item.targetId,
                                  amount,
                                  _amountUnit,
                                );
                              } else if (widget.isReplace &&
                                  widget.replaceItemId != null) {
                                await repo.replaceMealItemInMeal(
                                  oldItemId: widget.replaceItemId!,
                                  newType: item.type,
                                  newTargetId: item.targetId,
                                  newAmount: amount,
                                  newAmountUnit: _amountUnit,
                                );
                              } else {
                                await repo.addMealItemToMeal(
                                  mealId: widget.mealId,
                                  type: item.type,
                                  targetId: item.targetId,
                                  amount: amount,
                                  amountUnit: _amountUnit,
                                );
                              }
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: Text(
                            widget.isReplace
                                ? "Replace"
                                : _selectedItems.length > 1
                                ? "Add All (${_selectedItems.length})"
                                : "Add to Meal",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
