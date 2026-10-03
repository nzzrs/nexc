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
import '../../core/providers/meals_providers.dart';
import 'edit_product_screen.dart';

class ProductSelectorScreen extends ConsumerStatefulWidget {
  final String title;
  final String? initialQuery;

  const ProductSelectorScreen({
    super.key,
    this.title = "Select Product",
    this.initialQuery,
  });

  @override
  ConsumerState<ProductSelectorScreen> createState() => _ProductSelectorScreenState();
}

class _ProductSelectorScreenState extends ConsumerState<ProductSelectorScreen> {
  late TextEditingController _searchController;

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
    final newProduct = await Navigator.push<Product>(
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
            await ref.read(mealRepositoryProvider).saveProduct(prod);
          },
        ),
      ),
    );

    if (newProduct != null && mounted) {
      Navigator.pop(context, newProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);
    final usageCounts = ref.watch(productUsageCountsProvider).value;
    final inStockProductIds = ref.watch(inStockProductIdsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Create Product",
            onPressed: _createProduct,
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Search products...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("No products found"),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text("Create this Product"),
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
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Unit: ${p.units}${p.unitWeight != null && p.unitWeight! > 0 ? ' (${p.unitWeight}g)' : ''} • P ${p.proteins}g | C ${p.carbs}g | F ${p.fats}g"),
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
