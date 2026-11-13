/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_database.dart';
import '../../core/integrations/ai_service.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;
  final FutureOr<void> Function(Product)? onConfirm;

  const EditProductScreen({super.key, required this.product, this.onConfirm});

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
      text: widget.product.edibleQtyPerUnit != null
          ? (widget.product.edibleQtyPerUnit! * 100.0).toStringAsFixed(0)
          : "100",
    );
    _proteinsController = TextEditingController(
      text: widget.product.proteins == 0.0
          ? ""
          : widget.product.proteins.toString(),
    );
    _carbsController = TextEditingController(
      text: widget.product.carbsAvailable == null
          ? ""
          : widget.product.carbsAvailable.toString(),
    );
    _fatsController = TextEditingController(
      text: widget.product.fats == 0.0 ? "" : widget.product.fats.toString(),
    );

    _kcalController = TextEditingController(
      text: widget.product.kcal?.toString() ?? "",
    );
    _dietaryFiberController = TextEditingController(
      text: widget.product.dietaryFiber?.toString() ?? "",
    );
    _carbsByDifferenceController = TextEditingController(
      text: widget.product.carbsByDifference?.toString() ?? "",
    );
    _mlToGFactorController = TextEditingController(
      text: widget.product.mlToGFactor?.toString() ?? "",
    );
    _unitWeightController = TextEditingController(
      text: widget.product.unitWeight?.toString() ?? "",
    );
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

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final mlToGFactor = int.tryParse(_mlToGFactorController.text.trim());
    final unitWeight = int.tryParse(_unitWeightController.text.trim());

    // Units and millilitres are only usable when their equivalence is known.
    if (_selectedDefaultUnit == 'ml' &&
        (mlToGFactor == null || mlToGFactor <= 0)) {
      _showValidationMessage(context.l10n.validationMlFactor);
      return;
    }
    if (_selectedDefaultUnit == 'unit' &&
        (unitWeight == null || unitWeight <= 0)) {
      _showValidationMessage(context.l10n.validationUnitWeight);
      return;
    }

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
      mlToGFactor: mlToGFactor,
      unitWeight: unitWeight,
      isSupplement: _isSupplement,
      isPortable: _isPortable,
      isStockRaw: _isStockRaw,
    );
    if (widget.onConfirm != null) {
      await widget.onConfirm!(newProduct);
    }
    if (mounted) {
      Navigator.pop(context, newProduct);
    }
  }

  void _showValidationMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.id == 0 ? l10n.addProduct : l10n.editProduct,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _submit),
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
                    decoration: InputDecoration(
                      labelText: l10n.nameLabel,
                      border: const OutlineInputBorder(),
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
                          tooltip: l10n.autofillWithAi,
                          onPressed: () async {
                            final name = _nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.enterProductNameFirst),
                                ),
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
                              if (!isEdit ||
                                  _nameController.text.trim().isEmpty) {
                                _nameController.text = details.name;
                              }
                              if (!isEdit ||
                                  _kcalController.text.trim().isEmpty) {
                                _kcalController.text = details.kcal
                                    .toStringAsFixed(0);
                              }
                              if (!isEdit ||
                                  _proteinsController.text.trim().isEmpty) {
                                _proteinsController.text = details.proteins
                                    .toStringAsFixed(1);
                              }
                              if (!isEdit ||
                                  _carbsController.text.trim().isEmpty) {
                                _carbsController.text = details.carbsAvailable
                                    .toStringAsFixed(1);
                              }
                              if (!isEdit ||
                                  _carbsByDifferenceController.text
                                      .trim()
                                      .isEmpty) {
                                _carbsByDifferenceController.text = details
                                    .carbsByDifference
                                    .toStringAsFixed(1);
                              }
                              if (!isEdit ||
                                  _dietaryFiberController.text.trim().isEmpty) {
                                _dietaryFiberController.text = details
                                    .dietaryFiber
                                    .toStringAsFixed(1);
                              }
                              if (!isEdit ||
                                  _fatsController.text.trim().isEmpty) {
                                _fatsController.text = details.fats
                                    .toStringAsFixed(1);
                              }
                              if (!isEdit ||
                                  _unitWeightController.text.trim().isEmpty) {
                                _unitWeightController.text =
                                    details.unitWeight?.toString() ?? "";
                              }
                              if (!isEdit ||
                                  _mlToGFactorController.text.trim().isEmpty) {
                                _mlToGFactorController.text =
                                    details.mlToGFactor?.toString() ?? "";
                              }
                              if (!isEdit ||
                                  _ediblePercentController.text
                                      .trim()
                                      .isEmpty ||
                                  _ediblePercentController.text == "100") {
                                if (details.edibleQtyPerUnit != null) {
                                  _ediblePercentController.text =
                                      (details.edibleQtyPerUnit! * 100.0)
                                          .toStringAsFixed(0);
                                }
                              }
                              setState(() {
                                _selectedDefaultUnit =
                                    [
                                      'g',
                                      'ml',
                                      'unit',
                                    ].contains(details.defaultUnits)
                                    ? details.defaultUnits
                                    : 'g';
                                _isSupplement = details.isSupplement;
                                _isPortable = details.isPortable;
                                _isStockRaw = details.isStockRaw;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.autofilledProductDetails,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.aiError('$e'))),
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
                    decoration: InputDecoration(
                      labelText: l10n.defaultUnitsLabel,
                      border: const OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: _selectedDefaultUnit == 'ml'
                          ? l10n.mlToGFactorRequired
                          : l10n.mlToGFactorLabel,
                      helperText: _selectedDefaultUnit == 'ml'
                          ? l10n.requiredForMlProducts
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _unitWeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _selectedDefaultUnit == 'unit'
                          ? l10n.unitWeightGRequired
                          : l10n.unitWeightGLabel,
                      helperText: _selectedDefaultUnit == 'unit'
                          ? l10n.requiredForUnitsProducts
                          : null,
                      border: const OutlineInputBorder(),
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.ediblePercentLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.macrosEnergyPer100g,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kcalController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.caloriesKcal,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _proteinsController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.proteinsG,
                      border: const OutlineInputBorder(),
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.carbsAvailableG,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _carbsByDifferenceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.carbsByDiffG,
                      border: const OutlineInputBorder(),
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.fatsG,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _dietaryFiberController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.dietaryFiberG,
                      border: const OutlineInputBorder(),
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
                    title: Text(
                      l10n.isSupplementLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
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
                    title: Text(
                      l10n.isPortableLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
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
                    title: Text(
                      l10n.isStockRawLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
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
                label: Text(
                  widget.product.id == 0 ? l10n.addProduct : l10n.saveChanges,
                ),
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
