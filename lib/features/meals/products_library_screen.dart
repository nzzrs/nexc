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
import '../../core/db/app_database.dart';
import '../../core/db/meal_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/components/nexc_scaffold.dart';
import '../../core/components/clearable_search_field.dart';

import 'edit_product_screen.dart';

class ProductsLibraryScreen extends ConsumerStatefulWidget {
  const ProductsLibraryScreen({super.key});

  @override
  ConsumerState<ProductsLibraryScreen> createState() =>
      _ProductsLibraryScreenState();
}

class _ProductsLibraryScreenState extends ConsumerState<ProductsLibraryScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          product: product,
          onConfirm: (editedProduct) {
            ref.read(mealRepositoryProvider).saveProduct(editedProduct);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);
    final l10n = context.l10n;

    return NexcScaffold(
      title: Text(l10n.productsTab),
      navigateBack: () => Navigator.pop(context),
      fabAction: () {
        _showAddEditProduct(
          context,
          Product(
            id: 0,
            name: _searchQuery.trim(),
            defaultUnits: "g",
            edibleQtyPerUnit: 1.0,
            proteins: 0.0,
            carbsAvailable: null,
            fats: 0.0,
            isSupplement: false,
            isPortable: true,
            isStockRaw: false,
          ),
        );
      },
      fabIcon: const Icon(Icons.add),
      fabText: l10n.addProduct,
      content: (context, padding) {
        final usageCounts = ref.watch(productUsageCountsProvider).value;
        final inStockProductIds = ref.watch(inStockProductIdsProvider).value;
        return productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text(l10n.errorWithMessage('$err'))),
          data: (products) {
            final filteredProducts = products.searchAndSort(
              _searchQuery,
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
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(child: Text(l10n.noProductsFound))
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 80.0,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Padding(
                              key: ValueKey(product.id),
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ProductCard(
                                product: product,
                                onClick: () {
                                  _showAddEditProduct(context, product);
                                },
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(l10n.deleteProduct),
                                      content: Text(
                                        l10n.deleteProductConfirm(product.name),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(l10n.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(
                                            l10n.delete,
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    ref
                                        .read(mealRepositoryProvider)
                                        .deleteProduct(product);
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

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onClick;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onClick,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

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
                          product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: product.isPortable
                                    ? theme.colorScheme.primaryContainer
                                          .withValues(alpha: 0.5)
                                    : theme.colorScheme.errorContainer
                                          .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.isPortable
                                    ? l10n.portable
                                    : l10n.homeOnly,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: product.isPortable
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (product.isSupplement) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.supplement,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.protGrams('${product.proteins}')),
                      Text(l10n.carbGrams('${product.carbs}')),
                      Text(l10n.fatGrams('${product.fats}')),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.defaultWithValue(
                          '${product.units}${product.unitWeight != null ? ' (${product.unitWeight}g)' : ''}',
                        ),
                      ),
                    ],
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
