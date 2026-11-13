/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/components/nexc_choice_sheet.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/db/app_database.dart';
import '../../core/db/stock_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';

/// Actions offered for a stock item row.
enum StockItemAction { replace, delete }

/// Asks for a house name (create and rename share the same sheet).
Future<String?> showHouseNameSheet(
  BuildContext context, {
  required String title,
  String initialValue = '',
}) {
  final l10n = context.l10n;
  return NexcInputSheet.show(
    context: context,
    title: title,
    label: l10n.houseName,
    initialValue: initialValue,
    confirmLabel: l10n.save,
    validator: (String value) =>
        value.trim().isEmpty ? l10n.titleCannotBeEmpty : null,
  );
}

/// Destructive confirmation before a house is removed.
Future<bool> confirmDeleteHouse(BuildContext context, House house) async {
  final l10n = context.l10n;
  final bool? confirmed = await NexcConfirmSheet.show(
    context: context,
    title: l10n.deleteHouse,
    message: l10n.deleteHouseConfirm(house.name),
    confirmLabel: l10n.delete,
    cancelLabel: l10n.cancel,
    destructive: true,
  );
  return confirmed ?? false;
}

/// Result of the trigger threshold sheet.
///
/// `saved` is false only when the sheet was dismissed; a saved record with a
/// null [value] means the trigger should be disabled.
typedef TriggerThresholdResult = ({bool saved, double? value});

/// Edits the low-stock trigger for one item.
Future<TriggerThresholdResult?> showTriggerThresholdSheet(
  BuildContext context, {
  required StockWithProduct item,
}) async {
  final l10n = context.l10n;
  final String? raw = await NexcInputSheet.show(
    context: context,
    title: l10n.setTriggerFor(item.product.name),
    label: l10n.minimumThresholdWithUnit(item.product.units),
    helper: l10n.leaveEmptyToDisableTrigger,
    initialValue: item.stock.minTriggerQuantity == null
        ? ''
        : formatDecimal(item.stock.minTriggerQuantity!),
    confirmLabel: l10n.save,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
  if (raw == null) return null;
  final String trimmed = raw.trim().replaceAll(',', '.');
  if (trimmed.isEmpty) return (saved: true, value: null);
  final double? parsed = double.tryParse(trimmed);
  if (parsed == null || parsed < 0) return null;
  return (saved: true, value: parsed);
}

/// Replace-or-delete chooser for a stock row.
Future<StockItemAction?> showStockItemOptionsSheet(
  BuildContext context,
  StockWithProduct item,
) {
  final l10n = context.l10n;
  return NexcChoiceSheet.show<StockItemAction>(
    context: context,
    title: l10n.optionsForItem(item.product.name),
    options: <NexcChoiceOption<StockItemAction>>[
      NexcChoiceOption(
        value: StockItemAction.replace,
        label: l10n.replaceAction,
        description: l10n.whatToDoWithItem,
        icon: NexcIcons.products,
      ),
      NexcChoiceOption(
        value: StockItemAction.delete,
        label: l10n.delete,
        icon: NexcIcons.delete,
      ),
    ],
  );
}

/// Destructive confirmation before a stock row is removed.
Future<bool> confirmDeleteStock(
  BuildContext context,
  StockWithProduct item,
) async {
  final l10n = context.l10n;
  final bool? confirmed = await NexcConfirmSheet.show(
    context: context,
    title: l10n.optionsForItem(item.product.name),
    message: l10n.whatToDoWithItem,
    confirmLabel: l10n.delete,
    cancelLabel: l10n.cancel,
    destructive: true,
  );
  return confirmed ?? false;
}

/// Shows an error with a copy action so bug reports keep the full trace.
Future<void> showCopyableErrorDialog(
  BuildContext context,
  String title,
  String error,
) {
  final ThemeData theme = Theme.of(context);
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Row(
        children: <Widget>[
          Icon(NexcIcons.warning, color: theme.colorScheme.error),
          const SizedBox(width: NexcSpacing.sm),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.operationError),
          const SizedBox(height: NexcSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(NexcSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.all(
                  Radius.circular(NexcSpacing.sm),
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  error,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton.icon(
          icon: const Icon(NexcIcons.notes),
          label: Text(l10n.copyError),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: error));
            NexcSnack.show(dialogContext, l10n.errorCopied);
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}
