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
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_page.dart';
import '../../core/db/app_database.dart';
import '../../core/db/meal_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/product_factory.dart';

import 'edit_product_screen.dart';
import 'products_library_screen.dart';

/// Reusable product-selection view.
///
/// Returns the selected [Product] through `Navigator.pop` and lets the caller
/// create or edit products without leaving the flow. Rows keep the library
/// ordering and stock badges so both surfaces behave the same.
class ProductSelectorScreen extends ConsumerStatefulWidget {
  final String? title;
  final String? initialQuery;

  const ProductSelectorScreen({super.key, this.title, this.initialQuery});

  @override
  ConsumerState<ProductSelectorScreen> createState() =>
      _ProductSelectorScreenState();
}

class _ProductSelectorScreenState extends ConsumerState<ProductSelectorScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? "");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createProduct() async {
    Product? createdProduct;
    final Product? result = await Navigator.push<Product>(
      context,
      NexcPage.route(
        title: context.l10n.createProduct,
        builder: (BuildContext context) => EditProductScreen(
          product: emptyProduct(name: _searchController.text.trim()),
          onConfirm: (Product product) async {
            final int newId = await ref
                .read(mealRepositoryProvider)
                .saveProduct(product);
            createdProduct = product.copyWith(id: newId);
          },
        ),
      ),
    );

    final Product? product = createdProduct ?? result;
    if (product != null && mounted) {
      Navigator.pop(context, product);
    }
  }

  Future<void> _editProduct(Product product) async {
    await Navigator.push<Product>(
      context,
      NexcPage.route(
        title: context.l10n.editProduct,
        builder: (BuildContext context) => EditProductScreen(
          product: product,
          onConfirm: (Product edited) async {
            await ref.read(mealRepositoryProvider).saveProduct(edited);
          },
        ),
      ),
    );
    if (mounted) setState(() {});
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
      title: widget.title ?? l10n.selectProduct,
      actions: <Widget>[
        IconButton(
          icon: const Icon(NexcIcons.add),
          tooltip: l10n.createProduct,
          onPressed: _createProduct,
        ),
      ],
      body: NexcAsyncView<List<Product>>(
        value: productsAsync,
        errorTitle: (Object error) => l10n.errorWithMessage('$error'),
        onRetry: () => ref.invalidate(allProductsProvider),
        builder: (List<Product> products) {
          final List<Product> filtered = filterAndSortProducts(
            products,
            _searchController.text,
            ProductSortOption.stock,
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
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? NexcEmptyState(
                        icon: NexcIcons.products,
                        title: l10n.noProductsFound,
                        actionLabel: l10n.createProduct,
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
                            onTap: () => Navigator.pop(context, product),
                            trailing: IconButton(
                              icon: const Icon(NexcIcons.edit),
                              tooltip: l10n.editProduct,
                              onPressed: () => _editProduct(product),
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
