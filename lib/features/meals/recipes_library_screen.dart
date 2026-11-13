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
import '../../core/db/relations.dart';
import '../../core/db/meal_repository.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/components/nexc_scaffold.dart';
import '../../core/components/clearable_search_field.dart';
import 'edit_recipe_screen.dart';

class RecipesLibraryScreen extends ConsumerStatefulWidget {
  const RecipesLibraryScreen({super.key});

  @override
  ConsumerState<RecipesLibraryScreen> createState() =>
      _RecipesLibraryScreenState();
}

class _RecipesLibraryScreenState extends ConsumerState<RecipesLibraryScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddEditRecipe(
    BuildContext context,
    RecipeWithIngredients recipe,
    List<Product> products,
  ) async {
    final isNewRecipe = recipe.recipe.id == 0;
    final savedRecipe = await Navigator.push<RecipeWithIngredients>(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipeScreen(
          recipeWithIngredients: recipe,
          products: products,
          onConfirm: (editedRecipe) async {
            await ref
                .read(mealRepositoryProvider)
                .saveRecipeWithIngredients(editedRecipe);
          },
        ),
      ),
    );

    // New recipes refresh through the provider; clearing the filter keeps the
    // saved recipe visible without leaving the library.
    if (savedRecipe != null && isNewRecipe && mounted) {
      setState(() {
        _searchQuery = "";
        _searchController.clear();
      });
    }
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
                    final nameMatch = r.recipe.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                    final ingredientMatch = r.ingredients.any(
                      (ing) => ing.product.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    );
                    return nameMatch || ingredientMatch;
                  }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClearableSearchField(
                    controller: _searchController,
                    labelText: "Search recipes...",
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
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 80.0,
                          ),
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
                                      content: Text(
                                        "Are you sure you want to delete '${recipe.recipe.name}'?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    ref
                                        .read(mealRepositoryProvider)
                                        .deleteRecipe(recipe.recipe);
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: recipe.isPortable
                                ? theme.colorScheme.primaryContainer.withValues(
                                    alpha: 0.5,
                                  )
                                : theme.colorScheme.errorContainer.withValues(
                                    alpha: 0.5,
                                  ),
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
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (ingredients.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  ingredients
                      .map(
                        (i) =>
                            "${i.product.name} (${i.ingredient.amount.toStringAsFixed(0)}${i.ingredient.amountUnits ?? 'g'})",
                      )
                      .join(", "),
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
