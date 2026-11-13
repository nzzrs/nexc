/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/components/nexc_async_view.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/backup_manager.dart';
import '../../l10n/app_localizations.dart';

/// Bundled specification of every JSON import format.
const String backupFormatAsset = 'assets/docs/backup_format.md';

/// Actions for one exportable entity. [onExport] runs immediately; [onImport]
/// goes through the destructive confirmation before touching any data.
class _BackupSection extends StatelessWidget {
  final String? title;
  final String description;
  final IconData icon;
  final Future<void> Function() onExport;
  final Future<void> Function() onImport;

  const _BackupSection({
    required this.description,
    required this.icon,
    required this.onExport,
    required this.onImport,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(NexcSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: NexcSpacing.sm),
              if (title != null)
                Expanded(
                  child: Text(title!, style: theme.textTheme.titleMedium),
                ),
            ],
          ),
          const SizedBox(height: NexcSpacing.xs),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: NexcSpacing.md),
          _ResponsiveActions(
            children: [
              FilledButton.tonalIcon(
                onPressed: onExport,
                icon: const Icon(Icons.upload, size: 18),
                label: Text(l10n.exportAction),
              ),
              OutlinedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.download, size: 18),
                label: Text(l10n.importAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Two action buttons side by side, stacked on narrow phones.
class _ResponsiveActions extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveActions({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: NexcSpacing.sm),
                children[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: NexcSpacing.sm),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}

/// Read-only viewer for the bundled import format documentation.
class _FormatDocumentation extends StatelessWidget {
  const _FormatDocumentation();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    return ExpansionTile(
      leading: const Icon(NexcIcons.license),
      title: Text(l10n.importFormatDocumentation),
      subtitle: Text(l10n.importFormatDocumentationDesc),
      children: [
        FutureBuilder<String>(
          future: rootBundle.loadString(backupFormatAsset),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.only(bottom: NexcSpacing.lg),
                child: NexcErrorView(
                  title: l10n.importFormatDocumentation,
                  message: '${snapshot.error}',
                ),
              );
            }
            final String? markdown = snapshot.data;
            if (markdown == null) {
              return const Padding(
                padding: EdgeInsets.all(NexcSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: NexcSpacing.lg),
              padding: const EdgeInsets.all(NexcSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: NexcShapes.smRadius,
              ),
              child: SelectableText(
                markdown,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  Future<void> _confirmAndImport(
    BuildContext context, {
    required String entity,
    required Future<ImportResult> Function(BackupManager manager) run,
  }) async {
    final AppLocalizations l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: '${l10n.importAction} $entity',
      message: l10n.backupExportFirst,
      confirmLabel: l10n.importAction,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final ImportResult result = await run(
        ProviderScope.containerOf(
          context,
          listen: false,
        ).read(backupManagerProvider),
      );
      if (!context.mounted) return;
      if (result.success) {
        NexcSnack.show(context, l10n.importedSuccessfully(entity));
      } else {
        _showImportError(context, result.error ?? l10n.unknownError);
      }
    } catch (error) {
      if (!context.mounted) return;
      _showImportError(context, '$error');
    }
  }

  Future<void> _importDatabase(BuildContext context) async {
    final AppLocalizations l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: '${l10n.importAction} ${l10n.databaseTitle}',
      message: l10n.backupExportFirst,
      confirmLabel: l10n.importAction,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final BackupManager manager = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(backupManagerProvider);
      final bool success = await manager.importDatabase();
      if (!context.mounted) return;
      if (success) {
        NexcSnack.show(context, l10n.importSuccessBody);
      } else {
        NexcSnack.show(context, l10n.databaseImportCancelled);
      }
    } catch (error) {
      if (!context.mounted) return;
      _showImportError(context, '$error');
    }
  }

  void _showImportError(BuildContext context, String error) {
    final AppLocalizations l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: NexcErrorView(title: l10n.importFailed, message: error),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: error));
              NexcSnack.show(dialogContext, l10n.errorCopied);
            },
            icon: const Icon(Icons.copy, size: 18),
            label: Text(l10n.copyError),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _export(
    BuildContext context, {
    required Future<void> Function(BackupManager manager) run,
    required String successMessage,
    required String Function(String error) failureMessage,
  }) async {
    try {
      await run(
        ProviderScope.containerOf(
          context,
          listen: false,
        ).read(backupManagerProvider),
      );
      if (!context.mounted) return;
      NexcSnack.show(context, successMessage);
    } catch (error) {
      if (!context.mounted) return;
      NexcSnack.show(context, failureMessage('$error'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return NexcPage(
      title: l10n.backupRestoreTitle,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NexcSection(
              title: l10n.databaseTitle,
              children: [
                _BackupSection(
                  description: l10n.databaseDesc,
                  icon: NexcIcons.backup,
                  onExport: () => _export(
                    context,
                    run: (BackupManager manager) => manager.exportDatabase(),
                    successMessage: l10n.databaseExported,
                    failureMessage: l10n.databaseExportFailed,
                  ),
                  onImport: () => _importDatabase(context),
                ),
              ],
            ),
            NexcSection(
              title: 'Content',
              children: [
                _BackupSection(
                  title: l10n.workoutPlansTitle,
                  description: l10n.workoutPlansDesc,
                  icon: NexcIcons.workout,
                  onExport: () => _export(
                    context,
                    run: (BackupManager manager) =>
                        manager.exportWorkoutPlans(),
                    successMessage: l10n.workoutPlansExported,
                    failureMessage: l10n.workoutPlansExportFailed,
                  ),
                  onImport: () => _confirmAndImport(
                    context,
                    entity: l10n.workoutPlansTitle,
                    run: (BackupManager manager) =>
                        manager.importWorkoutPlans(),
                  ),
                ),
                _BackupSection(
                  title: l10n.workoutHistoryTitle,
                  description: l10n.workoutHistoryDesc,
                  icon: NexcIcons.workoutHistory,
                  onExport: () => _export(
                    context,
                    run: (BackupManager manager) =>
                        manager.exportWorkoutHistory(),
                    successMessage: l10n.workoutHistoryExported,
                    failureMessage: l10n.workoutHistoryExportFailed,
                  ),
                  onImport: () => _confirmAndImport(
                    context,
                    entity: l10n.workoutHistoryTitle,
                    run: (BackupManager manager) =>
                        manager.importWorkoutHistory(),
                  ),
                ),
                _BackupSection(
                  title: l10n.exercisesLabel,
                  description: l10n.exercisesBackupDesc,
                  icon: NexcIcons.exercises,
                  onExport: () => _export(
                    context,
                    run: (BackupManager manager) => manager.exportExercises(),
                    successMessage: l10n.exercisesExported,
                    failureMessage: l10n.exercisesExportFailed,
                  ),
                  onImport: () => _confirmAndImport(
                    context,
                    entity: l10n.exercisesLabel,
                    run: (BackupManager manager) => manager.importExercises(),
                  ),
                ),
                _BackupSection(
                  title: l10n.mealPlansTitle,
                  description: l10n.mealPlansDesc,
                  icon: NexcIcons.meals,
                  onExport: () => _export(
                    context,
                    run: (BackupManager manager) => manager.exportMealPlans(),
                    successMessage: l10n.mealPlansExported,
                    failureMessage: l10n.mealPlansExportFailed,
                  ),
                  onImport: () => _confirmAndImport(
                    context,
                    entity: l10n.mealPlansTitle,
                    run: (BackupManager manager) => manager.importMealPlans(),
                  ),
                ),
                _BackupSection(
                  title: l10n.mealHistoryTitle,
                  description: l10n.mealHistoryDesc,
                  icon: NexcIcons.mealHistory,
                  onExport: () => _export(
                    context,
                    run: (BackupManager manager) => manager.exportMealHistory(),
                    successMessage: l10n.mealHistoryExported,
                    failureMessage: l10n.mealHistoryExportFailed,
                  ),
                  onImport: () => _confirmAndImport(
                    context,
                    entity: l10n.mealHistoryTitle,
                    run: (BackupManager manager) => manager.importMealHistory(),
                  ),
                ),
                _BackupSection(
                  title: l10n.productsTab,
                  description: l10n.productsBackupDesc,
                  icon: NexcIcons.products,
                  onExport: () => _export(
                    context,
                    run: (BackupManager manager) => manager.exportProducts(),
                    successMessage: l10n.productsExported,
                    failureMessage: l10n.productsExportFailed,
                  ),
                  onImport: () => _confirmAndImport(
                    context,
                    entity: l10n.productsTab,
                    run: (BackupManager manager) => manager.importProducts(),
                  ),
                ),
                _BackupSection(
                  title: l10n.recipesTab,
                  description: l10n.recipesBackupDesc,
                  icon: NexcIcons.recipes,
                  onExport: () => _export(
                    context,
                    run: (BackupManager manager) => manager.exportRecipes(),
                    successMessage: l10n.recipesExported,
                    failureMessage: l10n.recipesExportFailed,
                  ),
                  onImport: () => _confirmAndImport(
                    context,
                    entity: l10n.recipesTab,
                    run: (BackupManager manager) => manager.importRecipes(),
                  ),
                ),
                _BackupSection(
                  title: l10n.stockTitle,
                  description: l10n.stockBackupDesc,
                  icon: NexcIcons.stock,
                  onExport: () => _export(
                    context,
                    run: (BackupManager manager) => manager.exportStock(),
                    successMessage: l10n.stockExported,
                    failureMessage: l10n.stockExportFailed,
                  ),
                  onImport: () => _confirmAndImport(
                    context,
                    entity: l10n.stockTitle,
                    run: (BackupManager manager) => manager.importStock(),
                  ),
                ),
              ],
            ),
            NexcSection(
              title: 'Documentation',
              children: [
                const _FormatDocumentation(),
                Padding(
                  padding: const EdgeInsets.all(NexcSpacing.lg),
                  child: _ResponsiveActions(
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => _shareFormatDocumentation(context),
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: Text(l10n.formatMarkdown),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _exportExercisesDocumentation(context),
                        icon: const Icon(Icons.format_list_bulleted, size: 18),
                        label: Text(l10n.exercisesMarkdown),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: NexcSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _shareFormatDocumentation(BuildContext context) async {
    final AppLocalizations l10n = context.l10n;
    try {
      final String markdown = await rootBundle.loadString(backupFormatAsset);
      await Share.shareXFiles([
        XFile.fromData(
          utf8.encode(markdown),
          name: 'nexc_import_format.md',
          mimeType: 'text/markdown',
        ),
      ], subject: l10n.formatShareSubject);
    } catch (error) {
      if (!context.mounted) return;
      NexcSnack.show(context, l10n.formatDownloadFailed('$error'));
    }
  }

  Future<void> _exportExercisesDocumentation(BuildContext context) async {
    final AppLocalizations l10n = context.l10n;
    try {
      await ProviderScope.containerOf(
        context,
        listen: false,
      ).read(backupManagerProvider).exportAvailableExercisesDocumentation();
      if (!context.mounted) return;
      NexcSnack.show(context, l10n.exerciseListGenerated);
    } catch (error) {
      if (!context.mounted) return;
      NexcSnack.show(context, l10n.exerciseListExportFailed('$error'));
    }
  }
}
