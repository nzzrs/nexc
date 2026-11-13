/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';

class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    if (kIsWeb) return;
    try {
      final PermissionStatus status = await Permission.notification.status;
      if (!status.isDenied && !status.isPermanentlyDenied) return;
      if (!context.mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) =>
            const NotificationPermissionDialog(),
      );
    } catch (error) {
      // Platforms without a permission plugin simply skip the prompt.
      debugPrint('Notification permission unavailable: $error');
    }
  }

  Future<void> _requestPermission(BuildContext context) async {
    try {
      final PermissionStatus status = await Permission.notification.request();
      if (status.isPermanentlyDenied) await openAppSettings();
    } catch (error) {
      debugPrint('Notification permission request failed: $error');
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.xlRadius),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              NexcSpacing.xl,
              NexcSpacing.xl,
              NexcSpacing.xl,
              NexcSpacing.lg,
            ),
            child: Semantics(
              container: true,
              namesRoute: true,
              label: l10n.notificationPermissionTitle,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        NexcIcons.restAlerts,
                        size: 36,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.xl),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.notificationPermissionTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.md),
                  Text(
                    l10n.notificationPermissionMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.xl),
                  FilledButton(
                    onPressed: () => _requestPermission(context),
                    child: Text(l10n.allow),
                  ),
                  const SizedBox(height: NexcSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.notNow),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
