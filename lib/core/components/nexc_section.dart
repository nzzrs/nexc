/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

import '../theme/shapes.dart';
import '../theme/spacing.dart';

/// Titled group of rows.
///
/// A section is one tonal container with internal dividers instead of one card
/// per row, which keeps long screens calm and scannable.
class NexcSection extends StatelessWidget {
  final String? title;
  final Widget? action;
  final List<Widget> children;

  /// Extra description under the title.
  final String? description;

  /// Whether children carry their own horizontal padding.
  final bool padded;

  /// Optional top margin.
  final bool spaced;

  /// Drops the tonal container and border, for children that bring their own
  /// cards (for example an action grid).
  final bool flat;

  const NexcSection({
    super.key,
    required this.children,
    this.title,
    this.action,
    this.description,
    this.padded = false,
    this.spaced = true,
    this.flat = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          const Divider(height: 1, indent: NexcSpacing.lg, endIndent: 0),
        );
      }
      rows.add(children[i]);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: spaced ? NexcSpacing.xl : 0,
        left: NexcSpacing.lg,
        right: NexcSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(
                left: NexcSpacing.xs,
                bottom: NexcSpacing.sm,
                top: NexcSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(
                left: NexcSpacing.xs,
                bottom: NexcSpacing.sm,
              ),
              child: Text(
                description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (flat)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            )
          else
            Material(
              color: theme.colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: NexcShapes.lgRadius,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: padded
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(NexcSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: children,
                          ),
                        ),
                      ]
                    : rows,
              ),
            ),
        ],
      ),
    );
  }
}
