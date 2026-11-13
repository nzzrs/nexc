/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/clearable_search_field.dart';
import '../../core/components/nexc_badge.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_food_tile.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_segmented.dart';
import '../../core/components/nexc_stepper_field.dart';
import '../../core/db/enums.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/product_factory.dart';
import '../../l10n/app_localizations.dart';
import 'edit_product_screen.dart';
import 'edit_recipe_screen.dart';

/// One confirmed food pick returned by [AddMealItemScreen].
class MealItemPick {
  final MealItemType type;
  final int targetId;
  final double amount;
  final AmountUnit unit;

  const MealItemPick({
    required this.type,
    required this.targetId,
    required this.amount,
    required this.unit,
  });
}

/// Unit label for a logged meal item, localized through the shared keys.
String mealItemUnitLabel(
  BuildContext context,
  MealItem item,
  Product? product,
) {
  if (item.amountUnit == AmountUnit.UNITS) return context.l10n.unitsLabel;
  if (item.amountUnit == AmountUnit.ML) return context.l10n.unitMl;
  if (product != null && product.units.isNotEmpty) return product.units;
  return context.l10n.unitG;
}

/// Unit choices available for a meal item.
List<({AmountUnit value, String label})> mealItemUnitChoices(
  BuildContext context, {
  Product? product,
  bool isRecipe = false,
  AmountUnit current = AmountUnit.GRAMS,
}) {
  final AppLocalizations l10n = context.l10n;
  final List<({AmountUnit value, String label})> choices = [
    (
      value: AmountUnit.GRAMS,
      label: product != null && product.units.isNotEmpty
          ? product.units
          : l10n.unitG,
    ),
  ];
  if (product != null && product.canMeasureInMl) {
    choices.add((value: AmountUnit.ML, label: l10n.unitMl));
  }
  if (isRecipe || (product?.canMeasureInUnits ?? false)) {
    choices.add((value: AmountUnit.UNITS, label: l10n.unitsLabel));
  }
  if (!choices.any(
    (({AmountUnit value, String label}) choice) => choice.value == current,
  )) {
    choices.add((
      value: current,
      label: switch (current) {
        AmountUnit.UNITS => l10n.unitsLabel,
        AmountUnit.ML => l10n.unitMl,
        AmountUnit.GRAMS => l10n.unitG,
      },
    ));
  }
  return choices;
}

/// Shared amount/unit editor sheet for an item in a meal.
Future<({double amount, AmountUnit unit})?> showMealItemQuantitySheet({
  required BuildContext context,
  required double initialAmount,
  required AmountUnit initialUnit,
  Product? product,
  bool isRecipe = false,
  String? title,
}) {
  return showModalBottomSheet<({double amount, AmountUnit unit})>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) => _MealItemQuantitySheet(
      initialAmount: initialAmount,
      initialUnit: initialUnit,
      product: product,
      isRecipe: isRecipe,
      title: title,
    ),
  );
}

class _MealItemQuantitySheet extends StatefulWidget {
  final double initialAmount;
  final AmountUnit initialUnit;
  final Product? product;
  final bool isRecipe;
  final String? title;

  const _MealItemQuantitySheet({
    required this.initialAmount,
    required this.initialUnit,
    this.product,
    this.isRecipe = false,
    this.title,
  });

  @override
  State<_MealItemQuantitySheet> createState() => _MealItemQuantitySheetState();
}

class _MealItemQuantitySheetState extends State<_MealItemQuantitySheet> {
  late double _amount = widget.initialAmount;
  late AmountUnit _unit = widget.initialUnit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final List<({AmountUnit value, String label})> choices =
        mealItemUnitChoices(
          context,
          product: widget.product,
          isRecipe: widget.isRecipe,
          current: _unit,
        );
    final String currentLabel = choices
        .firstWhere((({AmountUnit value, String label}) c) => c.value == _unit)
        .label;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        NexcSpacing.xl,
        NexcSpacing.sm,
        NexcSpacing.xl,
        NexcSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title ?? l10n.portionAmount,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: NexcSpacing.lg),
          Center(
            child: NexcQuantityField(
              value: _amount,
              unit: currentLabel,
              units: choices
                  .map((({AmountUnit value, String label}) c) => c.label)
                  .toList(),
              onUnitChanged: (String label) {
                final ({AmountUnit value, String label})? choice = choices
                    .firstWhereOrNull(
                      (({AmountUnit value, String label}) c) =>
                          c.label == label,
                    );
                if (choice == null) return;
                setState(() => _unit = choice.value);
              },
              min: 1,
              onChanged: (double value) => setState(() => _amount = value),
            ),
          ),
          const SizedBox(height: NexcSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: NexcSpacing.sm),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, (amount: _amount, unit: _unit)),
                child: Text(l10n.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Selection {
  final MealItemType type;
  final int targetId;
  final String name;
  final Product? product;
  double amount = 100;
  AmountUnit unit = AmountUnit.GRAMS;

  _Selection({
    required this.type,
    required this.targetId,
    required this.name,
    this.product,
  });
}

enum _RowAction { edit }

class AddMealItemScreen extends ConsumerStatefulWidget {
  final List<Product> products;
  final List<RecipeWithIngredients> recipes;
  final bool isReplace;
  final int? replaceItemId;

  const AddMealItemScreen({
    super.key,
    required this.products,
    required this.recipes,
    this.isReplace = false,
    this.replaceItemId,
  });

  @override
  ConsumerState<AddMealItemScreen> createState() => _AddMealItemScreenState();
}

class _AddMealItemScreenState extends ConsumerState<AddMealItemScreen> {
  MealItemType _type = MealItemType.PRODUCT;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Map<String, _Selection> _selected = <String, _Selection>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _keyFor(MealItemType type, int id) => '${type.name}_$id';

  void _addSelection(_Selection selection) {
    setState(() {
      if (widget.isReplace) _selected.clear();
      _selected[_keyFor(selection.type, selection.targetId)] = selection;
    });
  }

  void _toggleSelection(_Selection selection) {
    final String key = _keyFor(selection.type, selection.targetId);
    setState(() {
      if (widget.isReplace) {
        _selected
          ..clear()
          ..[key] = selection;
        return;
      }
      if (_selected.containsKey(key)) {
        _selected.remove(key);
      } else {
        _selected[key] = selection;
      }
    });
  }

  Future<void> _editSelection(String key) async {
    final _Selection? selection = _selected[key];
    if (selection == null) return;
    final ({double amount, AmountUnit unit})? result =
        await showMealItemQuantitySheet(
          context: context,
          initialAmount: selection.amount,
          initialUnit: selection.unit,
          product: selection.product,
          isRecipe: selection.type == MealItemType.RECIPE,
          title: selection.name,
        );
    if (result == null || !mounted) return;
    setState(() {
      selection
        ..amount = result.amount
        ..unit = result.unit;
    });
  }

  Future<void> _openEditor({
    required bool product,
    Product? existingProduct,
    RecipeWithIngredients? existingRecipe,
  }) async {
    if (product) {
      int? savedId;
      final Product? saved = await Navigator.push<Product>(
        context,
        MaterialPageRoute<Product>(
          builder: (BuildContext context) => EditProductScreen(
            product: existingProduct ?? emptyProduct(name: _searchQuery),
            onConfirm: (Product updated) async {
              savedId = await ref
                  .read(mealRepositoryProvider)
                  .saveProduct(updated);
            },
          ),
        ),
      );
      if (saved == null || !mounted) return;
      final Product stored = saved.copyWith(id: savedId ?? saved.id);
      _addSelection(
        _Selection(
          type: MealItemType.PRODUCT,
          targetId: stored.id,
          name: stored.name,
          product: stored,
        ),
      );
      return;
    }

    final RecipeWithIngredients? saved =
        await Navigator.push<RecipeWithIngredients>(
          context,
          MaterialPageRoute<RecipeWithIngredients>(
            builder: (BuildContext context) => EditRecipeScreen(
              recipeWithIngredients:
                  existingRecipe ??
                  RecipeWithIngredients(
                    recipe: Recipe(
                      id: 0,
                      name: _searchQuery,
                      instructions: '',
                      isPortable: false,
                    ),
                    ingredients: const <RecipeIngredientWithProduct>[],
                  ),
              products: widget.products,
              onConfirm: (RecipeWithIngredients updated) async {
                await ref
                    .read(mealRepositoryProvider)
                    .saveRecipeWithIngredients(updated);
              },
            ),
          ),
        );
    if (saved == null || !mounted) return;
    _addSelection(
      _Selection(
        type: MealItemType.RECIPE,
        targetId: saved.recipe.id,
        name: saved.recipe.name,
      ),
    );
  }

  void _submit() {
    if (_selected.isEmpty) return;
    Navigator.pop(context, [
      for (final _Selection selection in _selected.values)
        MealItemPick(
          type: selection.type,
          targetId: selection.targetId,
          amount: selection.amount,
          unit: selection.unit,
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Map<int, int>? usageCounts = ref
        .watch(productUsageCountsProvider)
        .value;
    final Set<int>? inStock = ref.watch(inStockProductIdsProvider).value;
    final List<Product> products = widget.products.searchAndSort(
      _searchQuery,
      usageCounts: usageCounts,
      inStockProductIds: inStock,
    );
    final String query = _searchQuery.toLowerCase();
    final List<RecipeWithIngredients> recipes = query.isEmpty
        ? widget.recipes
        : widget.recipes
              .where(
                (RecipeWithIngredients recipe) =>
                    recipe.recipe.name.toLowerCase().contains(query),
              )
              .toList();

    return NexcPage(
      title: widget.isReplace ? l10n.replaceMealItem : l10n.addItemToMeal,
      subtitle: _selected.isEmpty
          ? null
          : l10n.addItemsSelected(_selected.length),
      actions: [
        IconButton.filledTonal(
          tooltip: _type == MealItemType.PRODUCT
              ? l10n.createProduct
              : l10n.createRecipe,
          onPressed: () => _openEditor(product: _type == MealItemType.PRODUCT),
          icon: const Icon(NexcIcons.add),
        ),
      ],
      bottomBar: FilledButton.icon(
        onPressed: _selected.isEmpty ? null : _submit,
        icon: const Icon(NexcIcons.check, size: 18),
        label: Text(
          widget.isReplace
              ? l10n.replaceAction
              : _selected.length > 1
              ? l10n.addAllCount(_selected.length)
              : l10n.addToMeal,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NexcSpacing.lg,
              NexcSpacing.md,
              NexcSpacing.lg,
              NexcSpacing.sm,
            ),
            child: NexcSegmented<MealItemType>(
              selected: _type,
              onChanged: (MealItemType value) => setState(() => _type = value),
              segments: [
                (
                  value: MealItemType.PRODUCT,
                  label: l10n.productsTab,
                  icon: NexcIcons.products,
                ),
                (
                  value: MealItemType.RECIPE,
                  label: l10n.recipesTab,
                  icon: NexcIcons.recipes,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
            child: ClearableSearchField(
              controller: _searchController,
              labelText: _type == MealItemType.PRODUCT
                  ? l10n.searchFoodOrProduct
                  : l10n.searchRecipes,
              onChanged: (String value) => setState(() => _searchQuery = value),
            ),
          ),
          if (_selected.isNotEmpty)
            SizedBox(
              height: NexcSpacing.section + NexcSpacing.sm,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: NexcSpacing.lg,
                  vertical: NexcSpacing.sm,
                ),
                children: [
                  for (final MapEntry<String, _Selection> entry
                      in _selected.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: NexcSpacing.sm),
                      child: InputChip(
                        avatar: const Icon(NexcIcons.check, size: 16),
                        label: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            '${entry.value.name} · '
                            '${formatDecimal(entry.value.amount)} '
                            '${_unitLabel(entry.value)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onPressed: () => _editSelection(entry.key),
                        onDeleted: () =>
                            setState(() => _selected.remove(entry.key)),
                        deleteIcon: const Icon(NexcIcons.close, size: 16),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: _type == MealItemType.PRODUCT
                ? _buildProducts(context, products, inStock)
                : _buildRecipes(context, recipes),
          ),
        ],
      ),
    );
  }

  String _unitLabel(_Selection selection) {
    if (selection.unit == AmountUnit.UNITS) return context.l10n.unitsLabel;
    if (selection.unit == AmountUnit.ML) return context.l10n.unitMl;
    final Product? product = selection.product;
    if (product != null && product.units.isNotEmpty) return product.units;
    return context.l10n.unitG;
  }

  Widget _buildProducts(
    BuildContext context,
    List<Product> products,
    Set<int>? inStock,
  ) {
    final AppLocalizations l10n = context.l10n;
    if (products.isEmpty) {
      return NexcEmptyState(
        icon: NexcIcons.products,
        title: l10n.noProductsFound,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        NexcSpacing.lg,
        NexcSpacing.sm,
        NexcSpacing.lg,
        NexcSpacing.lg,
      ),
      itemCount: products.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: NexcSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final Product product = products[index];
        final String key = _keyFor(MealItemType.PRODUCT, product.id);
        final bool selected = _selected.containsKey(key);
        return NexcFoodTile(
          name: product.name,
          icon: NexcIcons.products,
          subtitle: l10n.macrosCompact(
            formatDecimal(product.proteins),
            formatDecimal(product.carbs),
            formatDecimal(product.fats),
          ),
          selected: selected,
          badges: [
            if (inStock?.contains(product.id) ?? false)
              NexcBadge(l10n.inStock, tone: NexcBadgeTone.info),
          ],
          trailing: PopupMenuButton<_RowAction>(
            tooltip: l10n.moreOptions,
            icon: const Icon(NexcIcons.more, size: 20),
            onSelected: (_RowAction action) =>
                _openEditor(product: true, existingProduct: product),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<_RowAction>(
                value: _RowAction.edit,
                child: Row(
                  children: [
                    const Icon(NexcIcons.edit, size: 20),
                    const SizedBox(width: NexcSpacing.md),
                    Text(l10n.editProduct),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _toggleSelection(
            _Selection(
              type: MealItemType.PRODUCT,
              targetId: product.id,
              name: product.name,
              product: product,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipes(
    BuildContext context,
    List<RecipeWithIngredients> recipes,
  ) {
    final AppLocalizations l10n = context.l10n;
    if (recipes.isEmpty) {
      return NexcEmptyState(
        icon: NexcIcons.recipes,
        title: l10n.noRecipesFound,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        NexcSpacing.lg,
        NexcSpacing.sm,
        NexcSpacing.lg,
        NexcSpacing.lg,
      ),
      itemCount: recipes.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: NexcSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final RecipeWithIngredients recipe = recipes[index];
        final String key = _keyFor(MealItemType.RECIPE, recipe.recipe.id);
        final bool selected = _selected.containsKey(key);
        return NexcFoodTile(
          name: recipe.recipe.name,
          icon: NexcIcons.recipes,
          subtitle: l10n.ingredientsCount(recipe.ingredients.length),
          selected: selected,
          trailing: PopupMenuButton<_RowAction>(
            tooltip: l10n.moreOptions,
            icon: const Icon(NexcIcons.more, size: 20),
            onSelected: (_RowAction action) =>
                _openEditor(product: false, existingRecipe: recipe),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<_RowAction>(
                value: _RowAction.edit,
                child: Row(
                  children: [
                    const Icon(NexcIcons.edit, size: 20),
                    const SizedBox(width: NexcSpacing.md),
                    Text(l10n.editRecipe),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _toggleSelection(
            _Selection(
              type: MealItemType.RECIPE,
              targetId: recipe.recipe.id,
              name: recipe.recipe.name,
            ),
          ),
        );
      },
    );
  }
}
