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

import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_segmented.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/db/app_database.dart';
import '../../core/integrations/ai_service.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';

/// Unit a product is normally measured in.
///
/// `unit` and `units` are the same concept; the editor always stores the
/// canonical `units` spelling.
enum ProductUnit {
  grams('g'),
  milliliters('ml'),
  units('units');

  const ProductUnit(this.storageValue);

  final String storageValue;

  static ProductUnit fromStorage(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'ml':
        return ProductUnit.milliliters;
      case 'unit':
      case 'units':
        return ProductUnit.units;
      default:
        return ProductUnit.grams;
    }
  }
}

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;
  final FutureOr<void> Function(Product)? onConfirm;

  const EditProductScreen({super.key, required this.product, this.onConfirm});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _ediblePercentController;
  late final TextEditingController _proteinsController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatsController;
  late final TextEditingController _kcalController;
  late final TextEditingController _dietaryFiberController;
  late final TextEditingController _carbsByDifferenceController;
  late final TextEditingController _mlToGFactorController;
  late final TextEditingController _unitWeightController;

  late ProductUnit _unit;
  late bool _isSupplement;
  late bool _isPortable;
  late bool _isStockRaw;
  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _unit = ProductUnit.fromStorage(widget.product.defaultUnits);
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
      text: widget.product.carbsAvailable?.toString() ?? "",
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

  int? get _mlToGFactor => int.tryParse(_mlToGFactorController.text.trim());
  int? get _unitWeight => int.tryParse(_unitWeightController.text.trim());

  String? _validateMlFactor(String? value) {
    if (_unit != ProductUnit.milliliters) return null;
    final int? parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return context.l10n.validationMlFactor;
    }
    return null;
  }

  String? _validateUnitWeight(String? value) {
    if (_unit != ProductUnit.units) return null;
    final int? parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return context.l10n.validationUnitWeight;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final double ediblePct =
        double.tryParse(_ediblePercentController.text) ?? 100.0;
    final Product newProduct = Product(
      id: widget.product.id,
      name: _nameController.text.trim(),
      defaultUnits: _unit.storageValue,
      edibleQtyPerUnit: ediblePct / 100.0,
      kcal: double.tryParse(_kcalController.text),
      proteins: double.tryParse(_proteinsController.text) ?? 0.0,
      carbsAvailable: double.tryParse(_carbsController.text),
      carbsByDifference: double.tryParse(_carbsByDifferenceController.text),
      dietaryFiber: double.tryParse(_dietaryFiberController.text),
      fats: double.tryParse(_fatsController.text) ?? 0.0,
      mlToGFactor: _mlToGFactor,
      unitWeight: _unitWeight,
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

  Widget _fieldGrid(BuildContext context, List<Widget> fields) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool twoColumns = constraints.maxWidth >= 420;
        final double width = twoColumns
            ? (constraints.maxWidth - NexcSpacing.md) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: NexcSpacing.md,
          runSpacing: NexcSpacing.md,
          children: <Widget>[
            for (final Widget field in fields)
              SizedBox(width: width, child: field),
          ],
        );
      },
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    String? helper,
    String? Function(String?)? validator,
    bool decimal = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      validator: validator,
      decoration: InputDecoration(labelText: label, helperText: helper),
    );
  }

  Future<void> _autofill() async {
    final l10n = context.l10n;
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      NexcSnack.show(context, l10n.enterProductNameFirst);
      return;
    }
    setState(() => _isAiLoading = true);
    try {
      final SettingsState settings = ref.read(settingsProvider);
      final AIProductDetails details = await AIService.autofillProduct(
        provider: settings.aiProvider,
        apiKey: settings.aiToken,
        model: settings.aiModel,
        productName: name,
      );
      final bool isEdit = widget.product.id != 0;
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
        _carbsByDifferenceController.text = details.carbsByDifference
            .toStringAsFixed(1);
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
      if (!isEdit ||
          _ediblePercentController.text.trim().isEmpty ||
          _ediblePercentController.text == "100") {
        if (details.edibleQtyPerUnit != null) {
          _ediblePercentController.text = (details.edibleQtyPerUnit! * 100.0)
              .toStringAsFixed(0);
        }
      }
      setState(() {
        _unit = ProductUnit.fromStorage(details.defaultUnits);
        _isSupplement = details.isSupplement;
        _isPortable = details.isPortable;
        _isStockRaw = details.isStockRaw;
      });
      if (mounted) {
        NexcSnack.show(context, l10n.autofilledProductDetails);
      }
    } catch (error) {
      if (mounted) NexcSnack.show(context, l10n.aiError('$error'));
    } finally {
      if (mounted) setState(() => _isAiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool aiEnabled = ref.watch(settingsProvider).enableAiProductCreation;

    return NexcPage(
      title: widget.product.id == 0 ? l10n.addProduct : l10n.editProduct,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: NexcSpacing.sm,
            bottom: NexcSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              NexcSection(
                title: l10n.detailsTab,
                padded: true,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: (String? value) => (value ?? '').trim().isEmpty
                        ? l10n.enterProductNameFirst
                        : null,
                    decoration: InputDecoration(
                      labelText: l10n.nameLabel,
                      suffixIcon: aiEnabled
                          ? Padding(
                              padding: const EdgeInsets.only(
                                right: NexcSpacing.xs,
                              ),
                              child: _isAiLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(NexcIcons.ai),
                                      tooltip: l10n.autofillWithAi,
                                      onPressed: _autofill,
                                    ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.isSupplementLabel),
                    value: _isSupplement,
                    onChanged: (bool value) =>
                        setState(() => _isSupplement = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.isPortableLabel),
                    value: _isPortable,
                    onChanged: (bool value) =>
                        setState(() => _isPortable = value),
                  ),
                ],
              ),
              NexcSection(
                title: l10n.defaultUnitsLabel,
                padded: true,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: NexcSegmented<ProductUnit>(
                      selected: _unit,
                      segments:
                          <({ProductUnit value, String label, IconData? icon})>[
                            (
                              value: ProductUnit.grams,
                              label: l10n.unitG,
                              icon: null,
                            ),
                            (
                              value: ProductUnit.milliliters,
                              label: l10n.unitMl,
                              icon: null,
                            ),
                            (
                              value: ProductUnit.units,
                              label: l10n.unitsLabel,
                              icon: null,
                            ),
                          ],
                      onChanged: (ProductUnit value) =>
                          setState(() => _unit = value),
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.lg),
                  _fieldGrid(context, <Widget>[
                    _numberField(
                      _ediblePercentController,
                      l10n.ediblePercentLabel,
                    ),
                    _numberField(
                      _mlToGFactorController,
                      _unit == ProductUnit.milliliters
                          ? l10n.mlToGFactorRequired
                          : l10n.mlToGFactorLabel,
                      helper: _unit == ProductUnit.milliliters
                          ? l10n.requiredForMlProducts
                          : null,
                      validator: _validateMlFactor,
                      decimal: false,
                    ),
                    _numberField(
                      _unitWeightController,
                      _unit == ProductUnit.units
                          ? l10n.unitWeightGRequired
                          : l10n.unitWeightGLabel,
                      helper: _unit == ProductUnit.units
                          ? l10n.requiredForUnitsProducts
                          : null,
                      validator: _validateUnitWeight,
                      decimal: false,
                    ),
                  ]),
                ],
              ),
              NexcSection(
                title: l10n.macrosEnergyPer100g,
                padded: true,
                children: <Widget>[
                  _fieldGrid(context, <Widget>[
                    _numberField(_kcalController, l10n.caloriesKcal),
                    _numberField(_proteinsController, l10n.proteinsG),
                    _numberField(_carbsController, l10n.carbsAvailableG),
                    _numberField(
                      _carbsByDifferenceController,
                      l10n.carbsByDiffG,
                    ),
                    _numberField(_fatsController, l10n.fatsG),
                    _numberField(_dietaryFiberController, l10n.dietaryFiberG),
                  ]),
                ],
              ),
              NexcSection(
                title: l10n.stockTitle,
                padded: true,
                children: <Widget>[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.isStockRawLabel),
                    value: _isStockRaw,
                    onChanged: (bool value) =>
                        setState(() => _isStockRaw = value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomBar: FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(NexcIcons.check),
        label: Text(
          widget.product.id == 0 ? l10n.addProduct : l10n.saveChanges,
        ),
      ),
    );
  }
}
