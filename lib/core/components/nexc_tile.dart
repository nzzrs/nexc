/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

import '../theme/iconography.dart';
import '../theme/spacing.dart';

/// A settings/navigation list row with an optional tonal icon container.
///
/// One widget covers switches, value pickers, navigation rows and plain
/// actions, so every list in the app keeps the same padding, hierarchy and
/// trailing affordances.
class NexcTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? infoContent;
  final bool enabled;
  final bool dense;
  final bool indent;
  final bool showChevron;
  final bool selected;

  const NexcTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.infoContent,
    this.enabled = true,
    this.dense = false,
    this.indent = false,
    this.showChevron = false,
    this.selected = false,
  });

  /// Row with a switch; the whole row toggles it.
  factory NexcTile.toggle({
    Key? key,
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    IconData? icon,
    String? subtitle,
    bool enabled = true,
    bool dense = false,
    bool indent = false,
  }) {
    return NexcTile(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: icon,
      enabled: enabled,
      dense: dense,
      indent: indent,
      onTap: enabled && onChanged != null ? () => onChanged(!value) : null,
      trailing: ExcludeSemantics(
        child: Switch(value: value, onChanged: enabled ? onChanged : null),
      ),
    );
  }

  /// Row that opens a picker and shows the current value.
  factory NexcTile.value({
    Key? key,
    required String title,
    required String value,
    required VoidCallback? onTap,
    IconData? icon,
    String? subtitle,
    bool enabled = true,
    bool dense = false,
    bool indent = false,
  }) {
    return NexcTile(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: icon,
      enabled: enabled,
      dense: dense,
      indent: indent,
      onTap: onTap,
      showChevron: true,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          value,
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color foreground = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);
    final Color supportColor = enabled
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return Semantics(
      enabled: enabled,
      button: onTap != null,
      selected: selected,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            indent ? NexcSpacing.xxl : NexcSpacing.lg,
            dense ? NexcSpacing.sm : NexcSpacing.md,
            NexcSpacing.md,
            dense ? NexcSpacing.sm : NexcSpacing.md,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: NexcSpacing.iconContainer,
                  height: NexcSpacing.iconContainer,
                  decoration: BoxDecoration(
                    color: enabled
                        ? theme.colorScheme.secondaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(NexcSpacing.md),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: enabled
                        ? theme.colorScheme.onSecondaryContainer
                        : supportColor,
                  ),
                ),
                const SizedBox(width: NexcSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foreground,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: supportColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (infoContent != null)
                IconButton(
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  icon: Icon(NexcIcons.about, size: 20, color: supportColor),
                  onPressed: enabled
                      ? () => _showInfo(context, supportColor)
                      : null,
                ),
              if (trailing != null) ...[
                const SizedBox(width: NexcSpacing.sm),
                DefaultTextStyle.merge(
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: supportColor,
                  ),
                  child: trailing!,
                ),
              ],
              if (showChevron)
                Padding(
                  padding: const EdgeInsets.only(left: NexcSpacing.xs),
                  child: Icon(NexcIcons.chevron, size: 20, color: supportColor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, Color iconColor) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: infoContent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}
