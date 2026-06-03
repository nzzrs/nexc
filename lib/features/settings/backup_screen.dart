/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/util/backup_manager.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupManager = ref.read(backupManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBackupSection(
            context,
            title: 'Database',
            description: 'Export or import the full SQLite database containing all workouts, routines, measurements, and foods.',
            onExport: () async {
              try {
                await backupManager.exportDatabase();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database exported successfully')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Database export failed: $e')),
                );
              }
            },
            onImport: () async {
              try {
                final success = await backupManager.importDatabase();
                if (!context.mounted) return;
                if (success) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: const Text('Import Successful'),
                      content: const Text('The database was imported. Please restart Nexc to load the new data.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database import cancelled')),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Database import failed: $e')),
                );
              }
            },
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: 'Workout plans',
            description: 'Import or export your workout plan templates as portable JSON files.',
            onExport: () async {
              try {
                await backupManager.exportWorkoutPlans();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workout plans exported')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Workout plans export failed: $e')),
                );
              }
            },
            onImport: () async {
              try {
                final success = await backupManager.importWorkoutPlans();
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Workout plans imported successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Workout plans import failed or cancelled')),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Workout plans import failed: $e')),
                );
              }
            },
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: 'Exercises',
            description: 'Import or export your exercises database as portable JSON files.',
            onExport: () async {
              try {
                await backupManager.exportExercises();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exercises exported')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exercises export failed: $e')),
                );
              }
            },
            onImport: () async {
              try {
                final success = await backupManager.importExercises();
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exercises imported successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exercises import failed or cancelled')),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exercises import failed: $e')),
                );
              }
            },
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: 'Meal plans',
            description: 'Import or export your meal plan templates as portable JSON files.',
            onExport: () async {
              try {
                await backupManager.exportMealPlans();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meal plans exported')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Meal plans export failed: $e')),
                );
              }
            },
            onImport: () async {
              try {
                final success = await backupManager.importMealPlans();
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meal plans imported successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meal plans import failed or cancelled')),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Meal plans import failed: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSection(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onExport,
    required VoidCallback onImport,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.exit_to_app),
          label: const Text('Export'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
          ),
          onPressed: onImport,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Import'),
        ),
      ],
    );
  }
}
