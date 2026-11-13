/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

import '../theme/spacing.dart';
import 'nexc_badge.dart';

/// Label/value tile used for metrics and stats.
class NexcStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final NexcBadgeTone tone;

  const NexcStatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.tone = NexcBadgeTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = switch (tone) {
      NexcBadgeTone.neutral => theme.colorScheme.onSurfaceVariant,
      NexcBadgeTone.info => theme.colorScheme.primary,
      NexcBadgeTone.success => theme.colorScheme.tertiary,
      NexcBadgeTone.warning => theme.colorScheme.secondary,
      NexcBadgeTone.error => theme.colorScheme.error,
    };

    return Semantics(
      label: unit == null ? '$label: $value' : '$label: $value $unit',
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: NexcSpacing.sm),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: NexcSpacing.sm),
          Text.rich(
            TextSpan(
              text: value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              children: [
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
