/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/spacing.dart';
import 'nexc_empty_state.dart';

/// Shared loading / error / empty handling for async providers.
class NexcAsyncView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Widget? loading;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final String Function(Object error)? errorTitle;
  final VoidCallback? onRetry;

  const NexcAsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.loading,
    this.isEmpty,
    this.empty,
    this.errorTitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (T data) {
        if (isEmpty?.call(data) ?? false) {
          return empty ?? const SizedBox.shrink();
        }
        return builder(data);
      },
      loading: () =>
          loading ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(NexcSpacing.xxl),
              child: CircularProgressIndicator(),
            ),
          ),
      error: (Object error, StackTrace stack) => _ErrorView(
        message: errorTitle?.call(error) ?? '$error',
        onRetry: onRetry,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 32, color: theme.colorScheme.error),
            const SizedBox(height: NexcSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: NexcSpacing.lg),
              FilledButton.tonal(
                onPressed: onRetry,
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-page error with a copy action.
class NexcErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const NexcErrorView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return NexcEmptyState(
      icon: Icons.error_outline,
      title: title,
      message: message,
      actionLabel: onRetry == null
          ? null
          : MaterialLocalizations.of(context).okButtonLabel,
      onAction: onRetry,
    );
  }
}
