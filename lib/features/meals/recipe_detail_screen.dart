/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/nexc_badge.dart';
import '../../core/components/nexc_macro.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/macro_totals.dart';

import 'edit_recipe_screen.dart';

/// Macro totals for one whole recipe (all ingredients at their amount).
MacroTotals recipeTotals(RecipeWithIngredients recipe) {
  double protein = 0;
  double carbs = 0;
  double fats = 0;
  double calories = 0;
  for (final RecipeIngredientWithProduct ingredient in recipe.ingredients) {
    final double scale = ingredient.ingredient.amount / 100.0;
    protein += ingredient.product.proteins * scale;
    carbs += ingredient.product.carbs * scale;
    fats += ingredient.product.fats * scale;
    calories += (ingredient.product.kcal ?? 0) * scale;
  }
  return MacroTotals(
    protein: protein,
    carbs: carbs,
    fats: fats,
    calories: calories,
  );
}

/// Read-only recipe view with a single edit action.
class RecipeDetailScreen extends ConsumerStatefulWidget {
  final RecipeWithIngredients recipeWithIngredients;

  const RecipeDetailScreen({super.key, required this.recipeWithIngredients});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late RecipeWithIngredients _recipe = widget.recipeWithIngredients;

  Future<void> _edit() async {
    final List<Product> products = ref.read(allProductsProvider).value ?? [];
    final RecipeWithIngredients? updated =
        await Navigator.push<RecipeWithIngredients>(
          context,
          NexcPage.route(
            title: context.l10n.editRecipe,
            builder: (BuildContext context) => EditRecipeScreen(
              recipeWithIngredients: _recipe,
              products: products,
              onConfirm: (RecipeWithIngredients edited) async {
                await ref
                    .read(mealRepositoryProvider)
                    .saveRecipeWithIngredients(edited);
              },
            ),
          ),
        );
    if (updated != null && mounted) {
      setState(() => _recipe = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Recipe recipe = _recipe.recipe;
    final MacroTotals totals = recipeTotals(_recipe);

    return NexcPage(
      title: recipe.name,
      actions: <Widget>[
        IconButton(
          icon: const Icon(NexcIcons.edit),
          tooltip: l10n.edit,
          onPressed: _edit,
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.only(top: NexcSpacing.sm),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NexcSpacing.lg,
              0,
              NexcSpacing.lg,
              NexcSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: NexcSpacing.xs,
                  runSpacing: NexcSpacing.xs,
                  children: <Widget>[
                    NexcBadge(
                      recipe.isPortable ? l10n.portable : l10n.homeOnly,
                      tone: recipe.isPortable
                          ? NexcBadgeTone.neutral
                          : NexcBadgeTone.warning,
                    ),
                    NexcBadge(
                      l10n.ingredientsCount(_recipe.ingredients.length),
                    ),
                  ],
                ),
                const SizedBox(height: NexcSpacing.md),
                NexcMacroChips(
                  protein: totals.protein,
                  carbs: totals.carbs,
                  fats: totals.fats,
                  showCalories: true,
                  calories: totals.calories,
                ),
              ],
            ),
          ),
          NexcSection(
            title: l10n.ingredients,
            children: <Widget>[
              for (final RecipeIngredientWithProduct ingredient
                  in _recipe.ingredients)
                NexcTile(
                  icon: NexcIcons.products,
                  title: ingredient.product.name,
                  subtitle: l10n.ingredientWithAmount(
                    ingredient.product.name,
                    '${formatDecimal(ingredient.ingredient.amount)}'
                    '${ingredient.ingredient.amountUnits ?? l10n.unitG}',
                  ),
                  trailing: Text(
                    l10n.macrosShort(
                      formatDecimal(ingredient.product.proteins),
                      formatDecimal(ingredient.product.carbs),
                      formatDecimal(ingredient.product.fats),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          NexcSection(
            title: l10n.instructions,
            padded: true,
            children: <Widget>[
              Text(
                recipe.instructions.trim().isEmpty
                    ? l10n.noDataYet
                    : recipe.instructions,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
