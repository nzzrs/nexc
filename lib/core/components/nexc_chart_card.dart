/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

import '../theme/shapes.dart';
import '../theme/spacing.dart';

/// Legend entry matching the series colors used by charts.
class NexcChartLegend {
  final String label;
  final Color color;

  const NexcChartLegend({required this.label, required this.color});
}

/// Card wrapper for every chart in the app.
class NexcChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final List<NexcChartLegend> legend;
  final String? emptyMessage;

  const NexcChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.legend = const [],
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: NexcShapes.lgRadius,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: NexcSpacing.sm),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: NexcSpacing.lg),
            if (emptyMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: NexcSpacing.xxl),
                child: Text(
                  emptyMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              child,
            if (legend.isNotEmpty) ...[
              const SizedBox(height: NexcSpacing.md),
              Wrap(
                spacing: NexcSpacing.md,
                runSpacing: NexcSpacing.xs,
                children: [
                  for (final NexcChartLegend entry in legend)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: entry.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: NexcSpacing.xs),
                        Text(
                          entry.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
