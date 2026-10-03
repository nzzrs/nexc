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
import '../../core/integrations/ai_service.dart';
import '../../core/providers/settings_provider.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;
  final void Function(Product)? onConfirm;

  const EditProductScreen({
    super.key,
    required this.product,
    this.onConfirm,
  });

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ediblePercentController;
  late TextEditingController _proteinsController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  late TextEditingController _kcalController;
  late TextEditingController _dietaryFiberController;
  late TextEditingController _carbsByDifferenceController;
  late TextEditingController _mlToGFactorController;
  late TextEditingController _unitWeightController;

  late String _selectedDefaultUnit;
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

  void _submit() {
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
      if (widget.onConfirm != null) {
        widget.onConfirm!(newProduct);
      }
      Navigator.pop(context, newProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.id == 0 ? "Add Product" : "Edit Product"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    initialValue: _selectedDefaultUnit,
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
            const Text(
              "Macros & Energy (per 100g)",
              style: TextStyle(fontWeight: FontWeight.bold),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: Text(widget.product.id == 0 ? "Add Product" : "Save Changes"),
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
