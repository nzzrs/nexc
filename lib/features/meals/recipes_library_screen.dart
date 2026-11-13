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

import '../../core/components/clearable_search_field.dart';
import '../../core/components/nexc_async_view.dart';
import '../../core/components/nexc_badge.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_food_tile.dart';
import '../../core/components/nexc_macro.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/macro_totals.dart';

import 'edit_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class RecipesLibraryScreen extends ConsumerStatefulWidget {
  const RecipesLibraryScreen({super.key});

  @override
  ConsumerState<RecipesLibraryScreen> createState() =>
      _RecipesLibraryScreenState();
}

class _RecipesLibraryScreenState extends ConsumerState<RecipesLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor(
    RecipeWithIngredients recipe,
    List<Product> products,
  ) async {
    final bool isNew = recipe.recipe.id == 0;
    final RecipeWithIngredients? saved =
        await Navigator.push<RecipeWithIngredients>(
          context,
          NexcPage.route(
            title: isNew ? context.l10n.addRecipe : context.l10n.editRecipe,
            builder: (BuildContext context) => EditRecipeScreen(
              recipeWithIngredients: recipe,
              products: products,
              onConfirm: (RecipeWithIngredients edited) async {
                await ref
                    .read(mealRepositoryProvider)
                    .saveRecipeWithIngredients(edited);
              },
            ),
          ),
        );

    // New recipes refresh through the provider; clearing the filter keeps the
    // saved recipe visible without leaving the library.
    if (saved != null && isNew && mounted) {
      setState(() {
        _searchQuery = '';
        _searchController.clear();
      });
    }
  }

  void _createRecipe(List<Product> products) {
    _openEditor(
      RecipeWithIngredients(
        recipe: Recipe(
          id: 0,
          name: _searchQuery.trim(),
          instructions: "",
          isPortable: true,
        ),
        ingredients: <RecipeIngredientWithProduct>[],
      ),
      products,
    );
  }

  void _openDetail(RecipeWithIngredients recipe) {
    Navigator.push<void>(
      context,
      NexcPage.route(
        title: recipe.recipe.name,
        builder: (BuildContext context) =>
            RecipeDetailScreen(recipeWithIngredients: recipe),
      ),
    );
  }

  Future<void> _deleteRecipe(RecipeWithIngredients recipe) async {
    final l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: l10n.deleteRecipe,
      message: l10n.deleteRecipeConfirm(recipe.recipe.name),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed == true) {
      await ref.read(mealRepositoryProvider).deleteRecipe(recipe.recipe);
    }
  }

  List<RecipeWithIngredients> _filter(List<RecipeWithIngredients> recipes) {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return recipes;
    return recipes.where((RecipeWithIngredients recipe) {
      final bool nameMatch = recipe.recipe.name.toLowerCase().contains(query);
      final bool ingredientMatch = recipe.ingredients.any(
        (RecipeIngredientWithProduct ingredient) =>
            ingredient.product.name.toLowerCase().contains(query),
      );
      return nameMatch || ingredientMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final AsyncValue<List<RecipeWithIngredients>> recipesAsync = ref.watch(
      allRecipesProvider,
    );
    final List<Product> products = ref.watch(allProductsProvider).value ?? [];

    return NexcPage(
      title: l10n.recipesTab,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createRecipe(products),
        icon: const Icon(NexcIcons.add),
        label: Text(l10n.addRecipe),
      ),
      body: NexcAsyncView<List<RecipeWithIngredients>>(
        value: recipesAsync,
        errorTitle: (Object error) => l10n.errorWithMessage('$error'),
        onRetry: () => ref.invalidate(allRecipesProvider),
        builder: (List<RecipeWithIngredients> recipes) {
          final List<RecipeWithIngredients> filtered = _filter(recipes);
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(NexcSpacing.lg),
                child: ClearableSearchField(
                  controller: _searchController,
                  labelText: l10n.searchRecipes,
                  onChanged: (String value) =>
                      setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? NexcEmptyState(
                        icon: NexcIcons.recipes,
                        title: l10n.noRecipesFound,
                        actionLabel: l10n.addRecipe,
                        onAction: () => _createRecipe(products),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          NexcSpacing.lg,
                          0,
                          NexcSpacing.lg,
                          NexcSpacing.section,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: NexcSpacing.sm),
                        itemBuilder: (BuildContext context, int index) {
                          final RecipeWithIngredients recipe = filtered[index];
                          return _RecipeFoodTile(
                            key: ValueKey<int>(recipe.recipe.id),
                            recipe: recipe,
                            onTap: () => _openDetail(recipe),
                            onDelete: () => _deleteRecipe(recipe),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeFoodTile extends StatelessWidget {
  final RecipeWithIngredients recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecipeFoodTile({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onDelete,
  });

  String _preview(BuildContext context) {
    final l10n = context.l10n;
    return recipe.ingredients
        .map(
          (RecipeIngredientWithProduct ingredient) => l10n.ingredientWithAmount(
            ingredient.product.name,
            '${formatDecimal(ingredient.ingredient.amount)}'
            '${ingredient.ingredient.amountUnits ?? l10n.unitG}',
          ),
        )
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final MacroTotals totals = recipeTotals(recipe);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.mdRadius),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          NexcFoodTile(
            name: recipe.recipe.name,
            icon: NexcIcons.recipes,
            subtitle: _preview(context),
            badges: <NexcBadge>[
              NexcBadge(
                recipe.recipe.isPortable ? l10n.portable : l10n.homeOnly,
                tone: recipe.recipe.isPortable
                    ? NexcBadgeTone.neutral
                    : NexcBadgeTone.warning,
              ),
            ],
            onTap: onTap,
            trailing: PopupMenuButton<String>(
              tooltip: l10n.moreOptions,
              icon: const Icon(NexcIcons.more),
              onSelected: (String value) {
                if (value == 'delete') onDelete();
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: <Widget>[
                      Icon(NexcIcons.delete, color: theme.colorScheme.error),
                      const SizedBox(width: NexcSpacing.md),
                      Text(
                        l10n.delete,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                NexcSpacing.iconContainer + NexcSpacing.lg,
                0,
                NexcSpacing.md,
                NexcSpacing.md,
              ),
              child: NexcMacroChips(
                protein: totals.protein,
                carbs: totals.carbs,
                fats: totals.fats,
                showCalories: true,
                calories: totals.calories,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
