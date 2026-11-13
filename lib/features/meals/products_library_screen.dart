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
import '../../core/components/nexc_choice_sheet.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_food_tile.dart';
import '../../core/components/nexc_macro.dart';
import '../../core/components/nexc_page.dart';
import '../../core/db/app_database.dart';
import '../../core/db/meal_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/product_factory.dart';

import 'edit_product_screen.dart';

/// Ordering offered by the product libraries and the product picker.
enum ProductSortOption { name, mostUsed, stock }

/// Sorts products with the same rules everywhere they are listed.
List<Product> sortProducts(
  Iterable<Product> products,
  ProductSortOption option, {
  Map<int, int>? usageCounts,
  Set<int>? inStockProductIds,
}) {
  final List<Product> list = products.toList();
  int byName(Product a, Product b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  int byUsage(Product a, Product b) {
    final int aUse = usageCounts?[a.id] ?? 0;
    final int bUse = usageCounts?[b.id] ?? 0;
    return bUse.compareTo(aUse);
  }

  switch (option) {
    case ProductSortOption.name:
      list.sort(byName);
    case ProductSortOption.mostUsed:
      list.sort((Product a, Product b) {
        final int usage = byUsage(a, b);
        return usage != 0 ? usage : byName(a, b);
      });
    case ProductSortOption.stock:
      list.sort((Product a, Product b) {
        final bool aInStock = inStockProductIds?.contains(a.id) ?? false;
        final bool bInStock = inStockProductIds?.contains(b.id) ?? false;
        if (aInStock != bInStock) return aInStock ? -1 : 1;
        final int usage = byUsage(a, b);
        return usage != 0 ? usage : byName(a, b);
      });
  }
  return list;
}

/// Filters by search query, then applies [option] ordering.
List<Product> filterAndSortProducts(
  Iterable<Product> products,
  String query,
  ProductSortOption option, {
  Map<int, int>? usageCounts,
  Set<int>? inStockProductIds,
}) {
  final String trimmed = query.trim();
  if (trimmed.isEmpty) {
    return sortProducts(
      products,
      option,
      usageCounts: usageCounts,
      inStockProductIds: inStockProductIds,
    );
  }
  return products.searchAndSort(
    trimmed,
    usageCounts: usageCounts,
    inStockProductIds: inStockProductIds,
  );
}

/// Status pills shared by the library and the product picker.
List<NexcBadge> productBadges(
  BuildContext context,
  Product product, {
  required bool inStock,
}) {
  final l10n = context.l10n;
  return <NexcBadge>[
    if (inStock)
      NexcBadge(
        l10n.inStockBadge,
        tone: NexcBadgeTone.success,
        icon: NexcIcons.check,
      ),
    NexcBadge(
      product.isPortable ? l10n.portable : l10n.homeOnly,
      tone: product.isPortable ? NexcBadgeTone.neutral : NexcBadgeTone.warning,
    ),
    if (product.isSupplement) NexcBadge(l10n.supplement),
  ];
}

/// Product row with stock badge, macro chips and a per-row overflow action.
class ProductFoodTile extends StatelessWidget {
  final Product product;
  final bool inStock;
  final int usageCount;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProductFoodTile({
    super.key,
    required this.product,
    this.inStock = false,
    this.usageCount = 0,
    this.onTap,
    this.trailing,
  });

  String _subtitle(BuildContext context) {
    final l10n = context.l10n;
    final List<String> parts = <String>[];
    if (usageCount > 0) parts.add(l10n.usedCount(usageCount));
    final String units = product.unitWeight != null && product.unitWeight! > 0
        ? '${product.units} (${product.unitWeight}g)'
        : product.units;
    parts.add(l10n.unitWithValue(units));
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.mdRadius),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NexcFoodTile(
            name: product.name,
            icon: NexcIcons.products,
            subtitle: _subtitle(context),
            badges: productBadges(context, product, inStock: inStock),
            trailing: trailing,
            onTap: onTap,
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
                protein: product.proteins,
                carbs: product.carbs,
                fats: product.fats,
                showCalories: product.kcal != null,
                calories: product.kcal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductsLibraryScreen extends ConsumerStatefulWidget {
  const ProductsLibraryScreen({super.key});

  @override
  ConsumerState<ProductsLibraryScreen> createState() =>
      _ProductsLibraryScreenState();
}

class _ProductsLibraryScreenState extends ConsumerState<ProductsLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ProductSortOption _sort = ProductSortOption.stock;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor(Product product) async {
    await Navigator.push<Product>(
      context,
      NexcPage.route(
        title: product.id == 0
            ? context.l10n.addProduct
            : context.l10n.editProduct,
        builder: (BuildContext context) => EditProductScreen(
          product: product,
          onConfirm: (Product edited) async {
            await ref.read(mealRepositoryProvider).saveProduct(edited);
          },
        ),
      ),
    );
  }

  void _createProduct() {
    _openEditor(emptyProduct(name: _searchQuery.trim()));
  }

  Future<void> _deleteProduct(Product product) async {
    final l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: l10n.deleteProduct,
      message: l10n.deleteProductConfirm(product.name),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed == true) {
      await ref.read(mealRepositoryProvider).deleteProduct(product);
    }
  }

  Future<void> _pickSort() async {
    final l10n = context.l10n;
    final ProductSortOption? picked =
        await NexcChoiceSheet.show<ProductSortOption>(
          context: context,
          title: l10n.sortBy,
          selected: _sort,
          options: <NexcChoiceOption<ProductSortOption>>[
            NexcChoiceOption(
              value: ProductSortOption.name,
              label: l10n.sortName,
              icon: NexcIcons.sort,
            ),
            NexcChoiceOption(
              value: ProductSortOption.mostUsed,
              label: l10n.sortMostUsed,
              icon: NexcIcons.streak,
            ),
            NexcChoiceOption(
              value: ProductSortOption.stock,
              label: l10n.sortStock,
              icon: NexcIcons.check,
            ),
          ],
        );
    if (picked != null && picked != _sort) {
      setState(() => _sort = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final AsyncValue<List<Product>> productsAsync = ref.watch(
      allProductsProvider,
    );
    final Map<int, int>? usageCounts = ref
        .watch(productUsageCountsProvider)
        .value;
    final Set<int>? inStockProductIds = ref
        .watch(inStockProductIdsProvider)
        .value;

    return NexcPage(
      title: l10n.productsTab,
      actions: <Widget>[
        IconButton(
          icon: const Icon(NexcIcons.sort),
          tooltip: l10n.sortBy,
          onPressed: _pickSort,
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProduct,
        icon: const Icon(NexcIcons.add),
        label: Text(l10n.addProduct),
      ),
      body: NexcAsyncView<List<Product>>(
        value: productsAsync,
        errorTitle: (Object error) => l10n.errorWithMessage('$error'),
        onRetry: () => ref.invalidate(allProductsProvider),
        builder: (List<Product> products) {
          final List<Product> filtered = filterAndSortProducts(
            products,
            _searchQuery,
            _sort,
            usageCounts: usageCounts,
            inStockProductIds: inStockProductIds,
          );
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(NexcSpacing.lg),
                child: ClearableSearchField(
                  controller: _searchController,
                  labelText: l10n.searchProducts,
                  onChanged: (String value) =>
                      setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? NexcEmptyState(
                        icon: NexcIcons.products,
                        title: l10n.noProductsFound,
                        actionLabel: l10n.addProduct,
                        onAction: _createProduct,
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
                          final Product product = filtered[index];
                          return ProductFoodTile(
                            key: ValueKey<int>(product.id),
                            product: product,
                            inStock:
                                inStockProductIds?.contains(product.id) ??
                                false,
                            usageCount: usageCounts?[product.id] ?? 0,
                            onTap: () => _openEditor(product),
                            trailing: PopupMenuButton<String>(
                              tooltip: l10n.moreOptions,
                              icon: const Icon(NexcIcons.more),
                              onSelected: (String value) {
                                if (value == 'delete') _deleteProduct(product);
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            NexcIcons.delete,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                          const SizedBox(width: NexcSpacing.md),
                                          Text(
                                            l10n.delete,
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
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
