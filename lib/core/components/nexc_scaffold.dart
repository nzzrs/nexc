/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NexcScaffold extends StatelessWidget {
  final Widget? title;
  final VoidCallback? navigateBack;
  final List<VoidCallback> actions;
  final List<bool> actionsEnabled;
  final List<String?> actionsDescription;
  final List<Widget> actionsIcons;
  final List<bool> actionsElevated;
  final VoidCallback? fabAction;
  final Widget? fabIcon;
  final String? fabDescription;
  final String? fabText;
  final Widget? snackbarHost;
  final Widget? bottomBar;
  final Widget Function(BuildContext context, EdgeInsets padding) content;

  const NexcScaffold({
    super.key,
    this.title,
    this.navigateBack,
    this.actions = const [],
    this.actionsEnabled = const [],
    this.actionsDescription = const [],
    this.actionsIcons = const [],
    this.actionsElevated = const [],
    this.fabAction,
    this.fabIcon,
    this.fabDescription,
    this.fabText,
    this.snackbarHost,
    this.bottomBar,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: (title != null || navigateBack != null || actions.isNotEmpty)
          ? AppBar(
              title: title,
              leading: navigateBack != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: navigateBack,
                    )
                  : null,
              actions: [
                if (actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(actions.length, (index) {
                        final action = actions[index];
                        final enabled = index < actionsEnabled.length ? actionsEnabled[index] : true;
                        final elevated = index < actionsElevated.length ? actionsElevated[index] : true;
                        final description = index < actionsDescription.length ? actionsDescription[index] : null;
                        final icon = index < actionsIcons.length ? actionsIcons[index] : null;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: icon != null
                              ? IconButton(
                                  style: elevated
                                      ? IconButton.styleFrom(
                                          backgroundColor: theme.colorScheme.secondaryContainer,
                                          foregroundColor: theme.colorScheme.onSecondaryContainer,
                                        )
                                      : null,
                                  icon: icon,
                                  onPressed: enabled
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          action();
                                        }
                                      : null,
                                )
                              : description != null
                                  ? FilledButton(
                                      style: elevated
                                          ? null
                                          : FilledButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              foregroundColor: theme.colorScheme.primary,
                                              elevation: 0,
                                            ),
                                      onPressed: enabled
                                          ? () {
                                              HapticFeedback.lightImpact();
                                              action();
                                            }
                                          : null,
                                      child: Text(description),
                                    )
                                  : const SizedBox.shrink(),
                        );
                      }),
                    ),
                  )
              ],
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return content(context, EdgeInsets.zero);
          },
        ),
      ),
      floatingActionButton: fabAction != null && fabIcon != null
          ? (fabText == null
              ? FloatingActionButton(
                  onPressed: fabAction,
                  tooltip: fabDescription,
                  child: fabIcon,
                )
              : FloatingActionButton.extended(
                  onPressed: fabAction,
                  icon: fabIcon,
                  label: Text(fabText!),
                  tooltip: fabDescription,
                ))
          : null,
      bottomNavigationBar: bottomBar,
    );
  }
}
