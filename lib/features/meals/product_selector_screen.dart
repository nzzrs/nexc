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
import '../../core/db/app_database.dart';
import '../../core/db/meal_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import 'edit_product_screen.dart';

/// Reusable product-selection view.
///
/// Returns the selected [Product] through `Navigator.pop` and lets the caller
/// create or edit products without leaving the flow.
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
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditProductScreen(
          product: Product(
            id: 0,
            name: _searchController.text.trim(),
            defaultUnits: "g",
            edibleQtyPerUnit: 1.0,
            proteins: 0.0,
            carbsAvailable: null,
            fats: 0.0,
            isSupplement: false,
            isPortable: true,
            isStockRaw: false,
          ),
          onConfirm: (prod) async {
            final newId = await ref
                .read(mealRepositoryProvider)
                .saveProduct(prod);
            createdProduct = prod.copyWith(id: newId);
          },
        ),
      ),
    );

    final product = createdProduct ?? result;
    if (product != null && mounted) {
      Navigator.pop(context, product);
    }
  }

  Future<void> _editProduct(Product product) async {
    await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditProductScreen(
          product: product,
          onConfirm: (prod) async {
            await ref.read(mealRepositoryProvider).saveProduct(prod);
          },
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  String _subtitleFor(
    BuildContext context,
    Product product,
    Map<int, int>? usageCounts,
    Set<int>? inStockProductIds,
  ) {
    final l10n = context.l10n;
    final parts = <String>[];
    if (inStockProductIds?.contains(product.id) ?? false) {
      parts.add(l10n.inStockBadge);
    }
    final usage = usageCounts?[product.id] ?? 0;
    if (usage > 0) {
      parts.add(l10n.usedCount(usage));
    }
    parts.add(
      l10n.unitWithValue(
        '${product.units}'
        '${product.unitWeight != null && product.unitWeight! > 0 ? ' (${product.unitWeight}g)' : ''}',
      ),
    );
    parts.add(
      l10n.macrosShort(
        '${product.proteins}',
        '${product.carbs}',
        '${product.fats}',
      ),
    );
    return parts.join(" • ");
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);
    final usageCounts = ref.watch(productUsageCountsProvider).value;
    final inStockProductIds = ref.watch(inStockProductIdsProvider).value;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? l10n.selectProduct),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.createProduct,
            onPressed: _createProduct,
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text(l10n.errorWithMessage('$err'))),
        data: (products) {
          final filtered = products.searchAndSort(
            _searchController.text,
            usageCounts: usageCounts,
            inStockProductIds: inStockProductIds,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClearableSearchField(
                  controller: _searchController,
                  labelText: l10n.searchProducts,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.noProductsFound),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: Text(l10n.createProduct),
                              onPressed: _createProduct,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return ListTile(
                            title: Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              _subtitleFor(
                                context,
                                p,
                                usageCounts,
                                inStockProductIds,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: l10n.editProduct,
                              onPressed: () => _editProduct(p),
                            ),
                            onTap: () {
                              Navigator.pop(context, p);
                            },
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
