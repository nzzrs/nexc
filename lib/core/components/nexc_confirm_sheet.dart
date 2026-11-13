/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

import '../theme/spacing.dart';

/// Confirmation sheet for one-off and destructive actions.
///
/// Use [show] for a boolean answer and inspect the returned value. The
/// destructive action is always visually separated from cancel.
class NexcConfirmSheet extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final String? secondaryLabel;
  final bool destructive;

  const NexcConfirmSheet({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    this.message,
    this.secondaryLabel,
    this.destructive = false,
  });

  /// Returns true for the primary action, false for the secondary action and
  /// null when dismissed or cancelled.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? message,
    required String confirmLabel,
    required String cancelLabel,
    String? secondaryLabel,
    bool destructive = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) => NexcConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        secondaryLabel: secondaryLabel,
        destructive: destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NexcSpacing.xl,
        NexcSpacing.sm,
        NexcSpacing.xl,
        NexcSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          if (message != null) ...[
            const SizedBox(height: NexcSpacing.md),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: NexcSpacing.xl),
          if (secondaryLabel != null) ...[
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(secondaryLabel!),
            ),
            const SizedBox(height: NexcSpacing.sm),
          ],
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
          const SizedBox(height: NexcSpacing.sm),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelLabel),
          ),
        ],
      ),
    );
  }
}
