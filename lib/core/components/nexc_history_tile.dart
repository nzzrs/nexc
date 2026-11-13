/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

import '../theme/iconography.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';

/// Shared summary tile for workout and meal history lists.
class NexcHistoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> meta;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? deleteLabel;
  final Widget? trailing;

  const NexcHistoryTile({
    super.key,
    required this.icon,
    required this.title,
    this.meta = const [],
    this.onTap,
    this.onDelete,
    this.deleteLabel,
    this.trailing,
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
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(NexcSpacing.md),
          child: Row(
            children: [
              Container(
                width: NexcSpacing.iconContainer,
                height: NexcSpacing.iconContainer,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(NexcSpacing.md),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: NexcSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    for (final String line in meta) ...[
                      const SizedBox(height: 2),
                      Text(
                        line,
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
              if (trailing != null) ...[
                const SizedBox(width: NexcSpacing.sm),
                trailing!,
              ],
              if (onDelete != null)
                PopupMenuButton<String>(
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  icon: Icon(
                    NexcIcons.more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (_) => onDelete!(),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(
                        deleteLabel ??
                            MaterialLocalizations.of(
                              context,
                            ).deleteButtonTooltip,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                )
              else
                Icon(
                  NexcIcons.chevron,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
