/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_database.dart';
import '../../core/db/meal_repository.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/components/nexc_scaffold.dart';

class ProductsLibraryScreen extends ConsumerStatefulWidget {
  const ProductsLibraryScreen({super.key});

  @override
  ConsumerState<ProductsLibraryScreen> createState() => _ProductsLibraryScreenState();
}

class _ProductsLibraryScreenState extends ConsumerState<ProductsLibraryScreen> {
  void _showAddEditProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditProductDialog(
        product: product,
        onDismiss: () => Navigator.pop(context),
        onConfirm: (editedProduct) {
          ref.read(mealRepositoryProvider).saveProduct(editedProduct);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return NexcScaffold(
      title: const Text("Products"),
      navigateBack: () => Navigator.pop(context),
      fabAction: () {
        _showAddEditProduct(
          context,
          const Product(
            id: 0,
            name: "",
            weight: 0.0,
            cost: 0.0,
            quantity: 0,
            units: "g",
            ediblePercent: 1.0,
            edibleQtyPerUnit: 0.0,
            proteins: 0.0,
            carbs: 0.0,
            fats: 0.0,
            isSupplement: false,
            isPortable: true,
          ),
        );
      },
      fabIcon: const Icon(Icons.add),
      fabText: "Add Product",
      content: (context, padding) {
        return productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (products) {
            if (products.isEmpty) {
              return const Center(child: Text("No products"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  key: ValueKey(product.id),
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ProductCard(
                    product: product,
                    onClick: () {
                      _showAddEditProduct(context, product);
                    },
                    onDelete: () {
                      ref.read(mealRepositoryProvider).deleteProduct(product);
                    },
                  ),
                );
              },
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
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.isSupplement) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Supplement",
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
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
                      Text("Prot: ${product.proteins}g"),
                      Text("Carb: ${product.carbs}g"),
                      Text("Fat: ${product.fats}g"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Weight: ${product.weight}${product.units}"),
                      Text(
                        "Cost: \$${product.cost.toStringAsFixed(2)}",
                        style: TextStyle(color: theme.colorScheme.secondary),
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

class AddEditProductDialog extends StatefulWidget {
  final Product product;
  final VoidCallback onDismiss;
  final void Function(Product) onConfirm;

  const AddEditProductDialog({
    super.key,
    required this.product,
    required this.onDismiss,
    required this.onConfirm,
  });

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;
  late TextEditingController _unitsController;
  late TextEditingController _ediblePercentController;
  late TextEditingController _edibleQtyController;
  late TextEditingController _proteinsController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  late bool _isSupplement;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _weightController = TextEditingController(
        text: widget.product.weight == 0.0 ? "" : widget.product.weight.toString());
    _costController =
        TextEditingController(text: widget.product.cost == 0.0 ? "" : widget.product.cost.toString());
    _quantityController = TextEditingController(
        text: widget.product.quantity == 0 ? "" : widget.product.quantity.toString());
    _unitsController = TextEditingController(text: widget.product.units);
    _ediblePercentController = TextEditingController(text: widget.product.ediblePercent.toString());
    _edibleQtyController = TextEditingController(text: widget.product.edibleQtyPerUnit.toString());
    _proteinsController = TextEditingController(text: widget.product.proteins.toString());
    _carbsController = TextEditingController(text: widget.product.carbs.toString());
    _fatsController = TextEditingController(text: widget.product.fats.toString());
    _isSupplement = widget.product.isSupplement;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _unitsController.dispose();
    _ediblePercentController.dispose();
    _edibleQtyController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product.id == 0 ? "Add Product" : "Edit Product"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Weight"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _unitsController,
                    decoration: const InputDecoration(labelText: "Units"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Cost (\$)"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Stock Qty"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ediblePercentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Edible %"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _edibleQtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Edible Qty"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Macros per 100g",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Prot"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Carb"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fatsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Fat"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _isSupplement,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _isSupplement = val);
                    }
                  },
                ),
                const Text("Is Supplement"),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onDismiss, child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              final newProduct = Product(
                id: widget.product.id == 0 ? Random().nextInt(10000000) : widget.product.id,
                name: name,
                weight: double.tryParse(_weightController.text) ?? 0.0,
                cost: double.tryParse(_costController.text) ?? 0.0,
                quantity: int.tryParse(_quantityController.text) ?? 0,
                units: _unitsController.text.trim(),
                ediblePercent: double.tryParse(_ediblePercentController.text) ?? 1.0,
                edibleQtyPerUnit: double.tryParse(_edibleQtyController.text) ?? 0.0,
                proteins: double.tryParse(_proteinsController.text) ?? 0.0,
                carbs: double.tryParse(_carbsController.text) ?? 0.0,
                fats: double.tryParse(_fatsController.text) ?? 0.0,
                isSupplement: _isSupplement,
                isPortable: true,
              );
              widget.onConfirm(newProduct);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
