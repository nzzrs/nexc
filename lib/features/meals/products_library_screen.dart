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
import '../../core/providers/settings_provider.dart';
import '../../core/integrations/ai_service.dart';

class ProductsLibraryScreen extends ConsumerStatefulWidget {
  const ProductsLibraryScreen({super.key});

  @override
  ConsumerState<ProductsLibraryScreen> createState() => _ProductsLibraryScreenState();
}

class _ProductsLibraryScreenState extends ConsumerState<ProductsLibraryScreen> {
  String _searchQuery = "";

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
      fabText: "Add Product",
      content: (context, padding) {
        return productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (products) {
            final filteredProducts = _searchQuery.isEmpty ? products : products.searchAndSort(_searchQuery);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Search products...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text("No products found"))
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 80.0),
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
                      Text("Default: ${product.units}${product.unitWeight != null ? ' (${product.unitWeight}g)' : ''}"),
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

class AddEditProductDialog extends ConsumerStatefulWidget {
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
  ConsumerState<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends ConsumerState<AddEditProductDialog> {
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
  late TextEditingController _unitWeightController;
  late bool _isSupplement;
  late bool _isPortable;
  late bool _isStockRaw;
  bool _isAiLoading = false;

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
    _unitWeightController = TextEditingController(text: widget.product.unitWeight?.toString() ?? "");
    _isSupplement = widget.product.isSupplement;
    _isPortable = widget.product.isPortable;
    _isStockRaw = widget.product.isStockRaw;
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
    _unitWeightController.dispose();
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (ref.watch(settingsProvider).enableAiProductCreation) ...[
                    const SizedBox(width: 8),
                    _isAiLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton.filledTonal(
                            icon: const Icon(Icons.auto_awesome),
                            tooltip: "Autofill with AI",
                            onPressed: () async {
                              final name = _nameController.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Enter a product name first")),
                                );
                                return;
                              }
                              setState(() {
                                _isAiLoading = true;
                              });
                              try {
                                final settings = ref.read(settingsProvider);
                                final details = await AIService.autofillProduct(
                                  provider: settings.aiProvider,
                                  apiKey: settings.aiToken,
                                  model: settings.aiModel,
                                  productName: name,
                                );
                                  final isEdit = widget.product.id != 0;
                                  if (!isEdit || _nameController.text.trim().isEmpty) {
                                    _nameController.text = details.name;
                                  }
                                  if (!isEdit || _kcalController.text.trim().isEmpty) {
                                    _kcalController.text = details.kcal.toStringAsFixed(0);
                                  }
                                  if (!isEdit || _proteinsController.text.trim().isEmpty) {
                                    _proteinsController.text = details.proteins.toStringAsFixed(1);
                                  }
                                  if (!isEdit || _carbsController.text.trim().isEmpty) {
                                    _carbsController.text = details.carbsAvailable.toStringAsFixed(1);
                                  }
                                  if (!isEdit || _carbsByDifferenceController.text.trim().isEmpty) {
                                    _carbsByDifferenceController.text = details.carbsByDifference.toStringAsFixed(1);
                                  }
                                  if (!isEdit || _dietaryFiberController.text.trim().isEmpty) {
                                    _dietaryFiberController.text = details.dietaryFiber.toStringAsFixed(1);
                                  }
                                  if (!isEdit || _fatsController.text.trim().isEmpty) {
                                    _fatsController.text = details.fats.toStringAsFixed(1);
                                  }
                                  if (!isEdit || _unitWeightController.text.trim().isEmpty) {
                                    _unitWeightController.text = details.unitWeight?.toString() ?? "";
                                  }
                                  if (!isEdit || _mlToGFactorController.text.trim().isEmpty) {
                                    _mlToGFactorController.text = details.mlToGFactor?.toString() ?? "";
                                  }
                                  if (!isEdit || _ediblePercentController.text.trim().isEmpty || _ediblePercentController.text == "100") {
                                    if (details.edibleQtyPerUnit != null) {
                                      _ediblePercentController.text = (details.edibleQtyPerUnit! * 100.0).toStringAsFixed(0);
                                    }
                                  }
                                  setState(() {
                                    _selectedDefaultUnit = ['g', 'ml', 'unit'].contains(details.defaultUnits)
                                        ? details.defaultUnits
                                        : 'g';
                                    _isSupplement = details.isSupplement;
                                    _isPortable = details.isPortable;
                                    _isStockRaw = details.isStockRaw;
                                  });
                                 if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     const SnackBar(content: Text("Autofilled product details!")),
                                   );
                                 }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("AI Error: $e")),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isAiLoading = false;
                                  });
                                }
                              }
                            },
                          ),
                  ],
                ],
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _unitWeightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Unit weight (g)",
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
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text("Is Stock Raw", style: TextStyle(fontSize: 12)),
                      value: _isStockRaw,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _isStockRaw = val);
                        }
                      },
                    ),
                  ),
                  const Expanded(child: SizedBox()),
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
                unitWeight: int.tryParse(_unitWeightController.text),
                isSupplement: _isSupplement,
                isPortable: _isPortable,
                isStockRaw: _isStockRaw,
              );
              widget.onConfirm(newProduct);
            }
          },
        ),
      ],
    );
  }
}
