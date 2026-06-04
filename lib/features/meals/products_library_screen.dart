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
            defaultUnits: "g",
            edibleQtyPerUnit: 1.0,
            proteins: 0.0,
            carbsAvailable: 0.0,
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
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Product"),
                          content: Text("Are you sure you want to delete '${product.name}'?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(mealRepositoryProvider).deleteProduct(product);
                      }
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
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: product.isPortable
                                    ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                                    : theme.colorScheme.errorContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.isPortable ? "Portable" : "Home only",
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
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
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
                            ],
                          ],
                        ),
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
                      Text("Default: ${product.units}"),
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
  late String _selectedDefaultUnit;
  late TextEditingController _ediblePercentController;
  late TextEditingController _proteinsController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  late TextEditingController _kcalController;
  late TextEditingController _dietaryFiberController;
  late TextEditingController _carbsByDifferenceController;
  late TextEditingController _mlToGFactorController;
  late bool _isSupplement;
  late bool _isPortable;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _selectedDefaultUnit = widget.product.defaultUnits ?? "g";
    _ediblePercentController = TextEditingController(
        text: widget.product.edibleQtyPerUnit != null ? (widget.product.edibleQtyPerUnit! * 100.0).toStringAsFixed(0) : "100");
    _proteinsController = TextEditingController(text: widget.product.proteins == 0.0 ? "" : widget.product.proteins.toString());
    _carbsController = TextEditingController(text: widget.product.carbsAvailable == null ? "" : widget.product.carbsAvailable.toString());
    _fatsController = TextEditingController(text: widget.product.fats == 0.0 ? "" : widget.product.fats.toString());
    
    _kcalController = TextEditingController(text: widget.product.kcal?.toString() ?? "");
    _dietaryFiberController = TextEditingController(text: widget.product.dietaryFiber?.toString() ?? "");
    _carbsByDifferenceController = TextEditingController(text: widget.product.carbsByDifference?.toString() ?? "");
    _mlToGFactorController = TextEditingController(text: widget.product.mlToGFactor?.toString() ?? "");
    _isSupplement = widget.product.isSupplement;
    _isPortable = widget.product.isPortable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ediblePercentController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _kcalController.dispose();
    _dietaryFiberController.dispose();
    _carbsByDifferenceController.dispose();
    _mlToGFactorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product.id == 0 ? "Add Product" : "Edit Product"),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDefaultUnit,
                      decoration: const InputDecoration(
                        labelText: "Default Units",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'g', child: Text('g')),
                        DropdownMenuItem(value: 'unit', child: Text('unit')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedDefaultUnit = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _mlToGFactorController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "ml to g factor",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ediblePercentController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Edible %",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Macros & Energy (per 100g)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _kcalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Calories (kcal)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _proteinsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Proteins (g)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Carbs Available (g)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _carbsByDifferenceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Carbs By Diff (g)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fatsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Fats (g)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _dietaryFiberController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Dietary Fiber (g)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text("Is Supplement", style: TextStyle(fontSize: 12)),
                      value: _isSupplement,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _isSupplement = val);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text("Is Portable", style: TextStyle(fontSize: 12)),
                      value: _isPortable,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _isPortable = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onDismiss,
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              final ediblePct = double.tryParse(_ediblePercentController.text) ?? 100.0;
              final newProduct = Product(
                id: widget.product.id,
                name: name,
                defaultUnits: _selectedDefaultUnit,
                edibleQtyPerUnit: ediblePct / 100.0,
                kcal: double.tryParse(_kcalController.text),
                proteins: double.tryParse(_proteinsController.text) ?? 0.0,
                carbsAvailable: double.tryParse(_carbsController.text),
                carbsByDifference: double.tryParse(_carbsByDifferenceController.text),
                dietaryFiber: double.tryParse(_dietaryFiberController.text),
                fats: double.tryParse(_fatsController.text) ?? 0.0,
                mlToGFactor: int.tryParse(_mlToGFactorController.text),
                isSupplement: _isSupplement,
                isPortable: _isPortable,
              );
              widget.onConfirm(newProduct);
            }
          },
        ),
      ],
    );
  }
}

