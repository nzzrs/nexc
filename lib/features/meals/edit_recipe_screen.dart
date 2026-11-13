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
import '../../core/components/nexc_badge.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_segmented.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/db/relations.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';

/// Full-screen recipe editor used for both creating and updating recipes.
///
/// On save the edited recipe is handed to [onConfirm] (when provided) and then
/// returned to the caller through `Navigator.pop`. There is exactly one save
/// action, pinned to the bottom bar.
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _instructionsController;
  late bool _isPortable;
  late List<RecipeIngredientWithProduct> _ingredients;

  int? _selectedProductId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _ingredientSearchController =
      TextEditingController();
  String _selectedIngredientUnit = 'g';
  String _searchQuery = '';

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
    _ingredients = List<RecipeIngredientWithProduct>.from(
      widget.recipeWithIngredients.ingredients,
    );
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
    (Product product) => product.id == _selectedProductId,
  );

  bool get _hasNonPortableIngredients => _ingredients.any(
    (RecipeIngredientWithProduct ingredient) => !ingredient.product.isPortable,
  );

  List<String> get _ingredientUnits {
    final Product? product = _selectedProduct;
    final List<String> units = <String>['g'];
    if (product == null || product.canMeasureInMl) units.add('ml');
    if (product == null || product.canMeasureInUnits) units.add('units');
    return units;
  }

  /// Unit currently offered by the picker, limited to what the selected
  /// product supports.
  String get _effectiveIngredientUnit {
    final List<String> units = _ingredientUnits;
    return units.contains(_selectedIngredientUnit)
        ? _selectedIngredientUnit
        : units.first;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final RecipeWithIngredients updated = RecipeWithIngredients(
      recipe: Recipe(
        id: widget.recipeWithIngredients.recipe.id,
        name: _nameController.text.trim(),
        instructions: _instructionsController.text.trim(),
        isPortable: _hasNonPortableIngredients ? false : _isPortable,
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
    final Product? product = _selectedProduct;
    final double? amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (product == null || amount == null || amount <= 0.0) return;

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
      _selectedIngredientUnit = 'g';
    });
  }

  String _unitLabel(String unit) {
    final l10n = context.l10n;
    switch (unit) {
      case 'ml':
        return l10n.unitMl;
      case 'units':
        return l10n.unitsLabel;
      default:
        return l10n.unitG;
    }
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProductId = product.id;
      _selectedIngredientUnit = 'g';
      _searchQuery = '';
      _ingredientSearchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final Map<int, int>? usageCounts = ref
        .watch(productUsageCountsProvider)
        .value;
    final Set<int>? inStockProductIds = ref
        .watch(inStockProductIdsProvider)
        .value;

    final List<Product> filteredProducts = widget.products.searchAndSort(
      _searchQuery,
      usageCounts: usageCounts,
      inStockProductIds: inStockProductIds,
    );
    final Product? selectedProduct = _selectedProduct;

    return NexcPage(
      title: widget.recipeWithIngredients.recipe.id == 0
          ? l10n.addRecipe
          : l10n.editRecipe,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: NexcSpacing.sm,
            bottom: NexcSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              NexcSection(
                title: l10n.detailsTab,
                padded: true,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (String? value) => (value ?? '').trim().isEmpty
                        ? l10n.enterRecipeName
                        : null,
                    decoration: InputDecoration(labelText: l10n.nameLabel),
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  TextFormField(
                    controller: _instructionsController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.instructionsProcess,
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _hasNonPortableIngredients
                          ? l10n.isPortableNonPortable
                          : l10n.isPortableLabel,
                    ),
                    value: _hasNonPortableIngredients ? false : _isPortable,
                    onChanged: _hasNonPortableIngredients
                        ? null
                        : (bool value) => setState(() => _isPortable = value),
                  ),
                ],
              ),
              NexcSection(
                title: l10n.composition,
                padded: true,
                children: <Widget>[
                  if (_ingredients.isNotEmpty) ...<Widget>[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _ingredients.length,
                        itemBuilder: (BuildContext context, int index) {
                          final RecipeIngredientWithProduct ingredient =
                              _ingredients[index];
                          return NexcTile(
                            icon: NexcIcons.products,
                            dense: true,
                            title: ingredient.product.name,
                            subtitle: l10n.ingredientWithAmount(
                              ingredient.product.name,
                              '${formatDecimal(ingredient.ingredient.amount)}'
                              '${ingredient.ingredient.amountUnits ?? l10n.unitG}',
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                NexcIcons.delete,
                                color: theme.colorScheme.error,
                              ),
                              tooltip: l10n.removeIngredient,
                              onPressed: () =>
                                  setState(() => _ingredients.removeAt(index)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: NexcSpacing.lg),
                  ],
                  if (selectedProduct != null)
                    NexcTile(
                      icon: NexcIcons.check,
                      title: selectedProduct.name,
                      subtitle: l10n.macrosCompact(
                        formatDecimal(selectedProduct.proteins),
                        formatDecimal(selectedProduct.carbs),
                        formatDecimal(selectedProduct.fats),
                      ),
                      trailing: IconButton(
                        icon: const Icon(NexcIcons.close),
                        tooltip: l10n.clearSelection,
                        onPressed: () =>
                            setState(() => _selectedProductId = null),
                      ),
                    )
                  else ...<Widget>[
                    ClearableSearchField(
                      controller: _ingredientSearchController,
                      labelText: l10n.searchIngredient,
                      onChanged: (String value) =>
                          setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: NexcSpacing.sm),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: filteredProducts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(NexcSpacing.lg),
                              child: Text(l10n.noProductsFound),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: filteredProducts.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Product product = filteredProducts[index];
                                final bool inStock =
                                    inStockProductIds?.contains(product.id) ??
                                    false;
                                return NexcTile(
                                  dense: true,
                                  title: product.name,
                                  subtitle: l10n.macrosCompact(
                                    formatDecimal(product.proteins),
                                    formatDecimal(product.carbs),
                                    formatDecimal(product.fats),
                                  ),
                                  trailing: inStock
                                      ? NexcBadge(
                                          l10n.inStockBadge,
                                          tone: NexcBadgeTone.success,
                                          icon: NexcIcons.check,
                                        )
                                      : null,
                                  onTap: () => _selectProduct(product),
                                );
                              },
                            ),
                    ),
                  ],
                  const SizedBox(height: NexcSpacing.lg),
                  Wrap(
                    spacing: NexcSpacing.sm,
                    runSpacing: NexcSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.amountLabel,
                          ),
                        ),
                      ),
                      NexcSegmented<String>(
                        selected: _effectiveIngredientUnit,
                        segments:
                            <({String value, String label, IconData? icon})>[
                              for (final String unit in _ingredientUnits)
                                (
                                  value: unit,
                                  label: _unitLabel(unit),
                                  icon: null,
                                ),
                            ],
                        onChanged: (String value) =>
                            setState(() => _selectedIngredientUnit = value),
                      ),
                      ListenableBuilder(
                        listenable: _amountController,
                        builder: (BuildContext context, Widget? child) {
                          final double? amount = double.tryParse(
                            _amountController.text.trim().replaceAll(',', '.'),
                          );
                          final bool canAdd =
                              selectedProduct != null &&
                              amount != null &&
                              amount > 0.0;
                          return FilledButton.tonalIcon(
                            onPressed: canAdd ? _addIngredient : null,
                            icon: const Icon(NexcIcons.add),
                            label: Text(l10n.addAction),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomBar: FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(NexcIcons.check),
        label: Text(
          widget.recipeWithIngredients.recipe.id == 0
              ? l10n.addRecipe
              : l10n.saveChanges,
        ),
      ),
    );
  }
}
