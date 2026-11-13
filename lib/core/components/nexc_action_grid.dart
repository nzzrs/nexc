/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

import '../theme/shapes.dart';
import '../theme/spacing.dart';

/// One entry in a [NexcActionGrid].
class NexcActionItem {
  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback onTap;
  final bool enabled;

  const NexcActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.description,
    this.enabled = true,
  });
}

/// Responsive grid of large tappable cards used by the profile hub.
///
/// Cards never shrink below a readable width: two columns on phones, three on
/// large phones and four on tablets.
class NexcActionGrid extends StatelessWidget {
  final List<NexcActionItem> items;
  final double spacing;

  const NexcActionGrid({
    super.key,
    required this.items,
    this.spacing = NexcSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = width >= 720
            ? 4
            : width >= 420
            ? 3
            : 2;
        final double itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (NexcActionItem item) => SizedBox(
                  width: itemWidth,
                  child: NexcActionCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Individual action card.
class NexcActionCard extends StatelessWidget {
  final NexcActionItem item;

  const NexcActionCard({super.key, required this.item});

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
      child: InkWell(
        onTap: item.enabled ? item.onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(NexcSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: NexcSpacing.iconContainer,
                height: NexcSpacing.iconContainer,
                decoration: BoxDecoration(
                  color: item.enabled
                      ? theme.colorScheme.secondaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(NexcSpacing.md),
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: item.enabled
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                ),
              ),
              const SizedBox(height: NexcSpacing.sm),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: item.enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
              if (item.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  item.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
