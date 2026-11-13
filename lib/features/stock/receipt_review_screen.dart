/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/nexc_badge.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/db/app_database.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/stock_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/product_factory.dart';
import '../meals/edit_product_screen.dart';
import '../meals/product_selector_screen.dart';
import 'stock_dialogs.dart';

/// How a receipt line was resolved against the product database.
enum ReceiptMatchState { perfect, fuzzy, missing }

/// One editable receipt line in the review screen.
class ReceiptReviewItem {
  final String receiptName;
  double inputQuantity;
  String parsedUnit;
  Product? matchedProduct;
  ReceiptMatchState matchState;
  bool isSelected;

  ReceiptReviewItem({
    required this.receiptName,
    required this.inputQuantity,
    required this.parsedUnit,
    this.matchedProduct,
    required this.matchState,
    required this.isSelected,
  });
}

/// Units offered for a receipt line, limited by the matched product.
List<String> receiptAvailableUnits(Product? product) {
  if (product == null) {
    return <String>['g', 'kg', 'ml', 'l', 'units'];
  }
  return product.availableStringUnits;
}

/// Unit that will actually be used for a receipt line.
String receiptEffectiveUnit(ReceiptReviewItem item) {
  final List<String> units = receiptAvailableUnits(item.matchedProduct);
  final String lower = item.parsedUnit.trim().toLowerCase();
  return units.contains(lower) ? lower : units.first;
}

/// Editable row for one parsed receipt line.
///
/// Quantity, unit and actions live in a [Wrap] so they can stack instead of
/// overflowing on narrow screens.
class ReceiptReviewRow extends StatefulWidget {
  final ReceiptReviewItem item;
  final VoidCallback onToggle;
  final ValueChanged<double> onQuantityChanged;
  final ValueChanged<String> onUnitChanged;
  final VoidCallback onEdit;
  final VoidCallback onReplace;
  final VoidCallback onCreate;

  const ReceiptReviewRow({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onQuantityChanged,
    required this.onUnitChanged,
    required this.onEdit,
    required this.onReplace,
    required this.onCreate,
  });

  @override
  State<ReceiptReviewRow> createState() => _ReceiptReviewRowState();
}

class _ReceiptReviewRowState extends State<ReceiptReviewRow> {
  late final TextEditingController _quantityController = TextEditingController(
    text: formatDecimal(widget.item.inputQuantity),
  );

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  ({String label, NexcBadgeTone tone, IconData icon}) _matchBadge(
    BuildContext context,
  ) {
    final l10n = context.l10n;
    switch (widget.item.matchState) {
      case ReceiptMatchState.perfect:
        return (
          label: l10n.perfectMatch,
          tone: NexcBadgeTone.success,
          icon: NexcIcons.check,
        );
      case ReceiptMatchState.fuzzy:
        return (
          label: l10n.fuzzyMatch,
          tone: NexcBadgeTone.warning,
          icon: NexcIcons.warning,
        );
      case ReceiptMatchState.missing:
        return (
          label: l10n.notFound,
          tone: NexcBadgeTone.error,
          icon: NexcIcons.close,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final ReceiptReviewItem item = widget.item;
    final String unit = receiptEffectiveUnit(item);
    final ({String label, NexcBadgeTone tone, IconData icon}) badge =
        _matchBadge(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: const BorderRadius.all(Radius.circular(NexcSpacing.md)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: item.isSelected,
                  onChanged: (_) => widget.onToggle(),
                ),
                const SizedBox(width: NexcSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.receiptName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: NexcSpacing.xs),
                      Wrap(
                        spacing: NexcSpacing.xs,
                        runSpacing: NexcSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          NexcBadge(
                            badge.label,
                            tone: badge.tone,
                            icon: badge.icon,
                          ),
                          if (item.matchedProduct != null)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 220),
                              child: Text(
                                '→ ${item.matchedProduct!.name}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: NexcSpacing.md),
            Wrap(
              spacing: NexcSpacing.sm,
              runSpacing: NexcSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.quantityLabel,
                      isDense: true,
                    ),
                    onChanged: (String value) {
                      final double? parsed = double.tryParse(
                        value.trim().replaceAll(',', '.'),
                      );
                      widget.onQuantityChanged(parsed ?? 0.0);
                    },
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey<String>('${item.receiptName}-$unit'),
                    initialValue: unit,
                    isDense: true,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.unitLabel,
                      isDense: true,
                    ),
                    items: receiptAvailableUnits(item.matchedProduct)
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      if (value != null) widget.onUnitChanged(value);
                    },
                  ),
                ),
                if (item.matchedProduct != null)
                  IconButton(
                    icon: const Icon(NexcIcons.edit),
                    tooltip: l10n.editProduct,
                    onPressed: widget.onEdit,
                  ),
                TextButton(
                  onPressed: widget.onReplace,
                  child: Text(l10n.replaceAction),
                ),
                if (item.matchedProduct == null)
                  FilledButton.tonal(
                    onPressed: widget.onCreate,
                    child: Text(l10n.createAction),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen review of an AI-parsed receipt before quantities hit stock.
class ReceiptReviewScreen extends ConsumerStatefulWidget {
  final int houseId;
  final List<ReceiptReviewItem> items;

  const ReceiptReviewScreen({
    super.key,
    required this.houseId,
    required this.items,
  });

  @override
  ConsumerState<ReceiptReviewScreen> createState() =>
      _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  late final List<ReceiptReviewItem> _items = List<ReceiptReviewItem>.of(
    widget.items,
  );
  bool _saving = false;

  void _refresh(VoidCallback change) => setState(change);

  Future<void> _editItem(ReceiptReviewItem item) async {
    final l10n = context.l10n;
    final Product? product = item.matchedProduct;
    if (product == null) return;
    try {
      final Product? updated = await Navigator.push<Product>(
        context,
        NexcPage.route(
          title: l10n.editProduct,
          builder: (BuildContext context) => EditProductScreen(
            product: product,
            onConfirm: (Product edited) async {
              await ref.read(mealRepositoryProvider).saveProduct(edited);
            },
          ),
        ),
      );
      if (updated != null && mounted) {
        setState(() {
          item.matchedProduct = updated;
          item.matchState = ReceiptMatchState.perfect;
        });
      }
    } catch (error, stackTrace) {
      if (mounted) {
        await showCopyableErrorDialog(
          context,
          l10n.productEditError,
          '$error\n\n$stackTrace',
        );
      }
    }
  }

  Future<void> _replaceItem(ReceiptReviewItem item) async {
    final l10n = context.l10n;
    try {
      final Product? selected = await Navigator.push<Product>(
        context,
        NexcPage.route(
          title: l10n.mapToTitle(item.receiptName),
          builder: (BuildContext context) => ProductSelectorScreen(
            title: l10n.mapToTitle(item.receiptName),
            initialQuery: item.receiptName,
          ),
        ),
      );
      if (selected == null || !mounted) return;
      await ref
          .read(stockRepositoryProvider)
          .saveReceiptMapping(
            receiptName: item.receiptName,
            productId: selected.id,
          );
      if (mounted) {
        setState(() {
          item.matchedProduct = selected;
          item.matchState = ReceiptMatchState.perfect;
        });
      }
    } catch (error, stackTrace) {
      if (mounted) {
        await showCopyableErrorDialog(
          context,
          l10n.productEditError,
          '$error\n\n$stackTrace',
        );
      }
    }
  }

  Future<void> _createItem(ReceiptReviewItem item) async {
    final l10n = context.l10n;
    Product? created;
    try {
      final Product? result = await Navigator.push<Product>(
        context,
        NexcPage.route(
          title: l10n.createProduct,
          builder: (BuildContext context) => EditProductScreen(
            product: emptyProduct(
              name: item.receiptName,
              defaultUnits: defaultUnitsForReceiptUnit(item.parsedUnit),
            ),
            onConfirm: (Product product) async {
              final int newId = await ref
                  .read(mealRepositoryProvider)
                  .saveProduct(product);
              created = product.copyWith(id: newId);
              await ref
                  .read(stockRepositoryProvider)
                  .saveReceiptMapping(
                    receiptName: item.receiptName,
                    productId: newId,
                  );
            },
          ),
        ),
      );
      final Product? product = created ?? result;
      if (product != null && mounted) {
        setState(() {
          item.matchedProduct = product;
          item.matchState = ReceiptMatchState.perfect;
        });
      }
    } catch (error, stackTrace) {
      if (mounted) {
        await showCopyableErrorDialog(
          context,
          l10n.productCreationError,
          '$error\n\n$stackTrace',
        );
      }
    }
  }

  Future<void> _confirm() async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      final StockRepository repo = ref.read(stockRepositoryProvider);
      final List<StockWithProduct> currentStocks = await repo
          .getStocksWithProductForHouse(widget.houseId);

      for (final ReceiptReviewItem item in _items) {
        if (!item.isSelected ||
            item.matchedProduct == null ||
            item.inputQuantity <= 0.0) {
          continue;
        }
        double quantity = item.inputQuantity;
        final String unit = receiptEffectiveUnit(item);
        if (unit == 'kg' || unit == 'l') quantity *= 1000;
        final StockWithProduct? existing = currentStocks.firstWhereOrNull(
          (StockWithProduct stock) =>
              stock.product.id == item.matchedProduct!.id,
        );
        await repo.saveStock(
          productId: item.matchedProduct!.id,
          houseId: widget.houseId,
          quantity: (existing?.stock.quantity ?? 0.0) + quantity,
          minTriggerQuantity: existing?.stock.minTriggerQuantity,
        );
      }
      if (!mounted) return;
      NexcSnack.show(context, l10n.loggedReceiptItems);
      Navigator.pop(context);
    } catch (error, stackTrace) {
      if (mounted) {
        await showCopyableErrorDialog(
          context,
          l10n.stockLoggingError,
          '$error\n\n$stackTrace',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return NexcPage(
      title: l10n.aiLogConfirmation,
      subtitle: l10n.ingredientsCount(_items.length),
      body: _items.isEmpty
          ? NexcEmptyState(icon: NexcIcons.empty, title: l10n.noItemsParsed)
          : ListView.separated(
              padding: const EdgeInsets.all(NexcSpacing.lg),
              itemCount: _items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: NexcSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final ReceiptReviewItem item = _items[index];
                return ReceiptReviewRow(
                  key: ValueKey<String>(item.receiptName),
                  item: item,
                  onToggle: () =>
                      _refresh(() => item.isSelected = !item.isSelected),
                  onQuantityChanged: (double value) =>
                      _refresh(() => item.inputQuantity = value),
                  onUnitChanged: (String value) =>
                      _refresh(() => item.parsedUnit = value),
                  onEdit: () => _editItem(item),
                  onReplace: () => _replaceItem(item),
                  onCreate: () => _createItem(item),
                );
              },
            ),
      bottomBar: FilledButton(
        onPressed: _saving ? null : _confirm,
        child: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.confirmAction),
      ),
    );
  }
}
