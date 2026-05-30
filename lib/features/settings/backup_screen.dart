/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onExport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database export not implemented yet')),
              );
            },
            onImport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database import not implemented yet')),
              );
            },
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: 'Workout plans',
            description: 'Import or export your workout plan templates as portable JSON files.',
            onExport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workout plans export not implemented yet')),
              );
            },
            onImport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workout plans import not implemented yet')),
              );
            },
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: 'Exercises',
            description: 'Import or export your exercises database as portable JSON files.',
            onExport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exercises export not implemented yet')),
              );
            },
            onImport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exercises import not implemented yet')),
              );
            },
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: 'Meal plans',
            description: 'Import or export your meal plan templates as portable JSON files.',
            onExport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meal plans export not implemented yet')),
              );
            },
            onImport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meal plans import not implemented yet')),
              );
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
