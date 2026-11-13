/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/spacing.dart';

/// Shared page scaffold.
///
/// Gives every screen the same app bar, content width, safe-area handling and
/// optional bottom action bar, replacing the older [NexcScaffold] widget and
/// the ad-hoc `Scaffold`/`AppBar` pairs.
class NexcPage extends StatelessWidget {
  /// Page title, shown in the app bar.
  final String title;

  /// Optional secondary line under the title (counts, current value, …).
  final String? subtitle;

  /// Secondary actions; keep to one or two.
  final List<Widget> actions;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Optional bar pinned above the navigation bar (primary page action).
  final Widget? bottomBar;

  /// Vertical scrolling body.
  final Widget body;

  /// Whether the body should be constrained for readability.
  final bool constrainContent;

  /// Maximum content width when [constrainContent] is true.
  final double maxWidth;

  /// Optional background decoration behind the body.
  final Widget? background;

  /// Padding applied around the body before the safe area.
  final EdgeInsetsGeometry padding;

  /// Renders without an app bar for screens hosted inside the tab shell.
  final bool embedded;

  const NexcPage({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.floatingActionButton,
    this.bottomBar,
    this.constrainContent = true,
    this.maxWidth = NexcSpacing.readableWidth,
    this.background,
    this.padding = EdgeInsets.zero,
    this.embedded = false,
  });

  /// Route with the shared enter/exit transition.
  static Route<T> route<T>({
    required String title,
    required WidgetBuilder builder,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: '/$title'),
      transitionDuration: NexcMotion.medium,
      reverseTransitionDuration: NexcMotion.short,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (NexcMotion.respectsReducedMotion(context)) return child;
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: NexcMotion.enterCurve,
          reverseCurve: NexcMotion.exitCurve,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: constrainContent ? maxWidth : double.infinity,
        ),
        child: Padding(padding: padding, child: body),
      ),
    );

    return Scaffold(
      appBar: embedded
          ? null
          : AppBar(
              titleSpacing: 0,
              title: subtitle == null
                  ? Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.appBarTheme.titleTextStyle,
                        ),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
              actions: actions.isEmpty
                  ? null
                  : [...actions, const SizedBox(width: NexcSpacing.sm)],
            ),
      body: SafeArea(
        top: false,
        child: background == null
            ? content
            : Stack(
                children: [
                  Positioned.fill(child: background!),
                  content,
                ],
              ),
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              top: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NexcSpacing.lg,
                    NexcSpacing.md,
                    NexcSpacing.lg,
                    NexcSpacing.md,
                  ),
                  child: bottomBar,
                ),
              ),
            ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Removes the default app-bar back button spacing when no leading is wanted.
class NexcPageBodyPadding extends StatelessWidget {
  final Widget child;
  final bool bottomInset;

  const NexcPageBodyPadding({
    super.key,
    required this.child,
    this.bottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NexcSpacing.lg,
        NexcSpacing.sm,
        NexcSpacing.lg,
        bottomInset ? NexcSpacing.xl : NexcSpacing.sm,
      ),
      child: child,
    );
  }
}
