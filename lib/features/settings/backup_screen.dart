/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
          const Divider(height: 32),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Import Format Documentation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get a detailed Markdown template detailing format fields, types, and values for importing workout plans, meals, and exercises.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        final tempDir = await getTemporaryDirectory();
                        final file = File(p.join(tempDir.path, 'nexc_import_format.md'));
                        await file.writeAsString(r'''# Nexc Import Formats Specification

This document details the JSON schema specifications used for importing data into Nexc.

---

## 1. Workout Plans (Routines)

Workout plans are imported as a JSON array of workout objects.

### Fields Description

| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | `String` | Title of the workout plan/routine. |
| `notes` | `String` | Description or instructions for the routine. |
| `timeElapsed` | `Int` | Default elapsed time in seconds. |
| `created` | `String` | ISO 8601 Date string. |
| `completed` | `String` | ISO 8601 Date string. |
| `exercises` | `Array` | List of exercise items in the plan. |

### Exercise Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `exerciseId` | `String` | Unique ID of the exercise. |
| `name` | `String` | Name of the exercise (used if it doesn't exist in local database). |
| `notes` | `String` | Exercise-specific notes. |
| `setMode` | `String` | Set mode. Options: `LOAD`, `BODYWEIGHT`, `BODYWEIGHT_WITH_LOAD`, `TIME`, `TIME_WITH_LOAD`. |
| `restTime` | `Int` | Rest time in seconds between sets. |
| `supersetGroupId` | `String?` | Optional identifier to group supersets. |
| `sets` | `Array` | Sets logs list. |

### Set Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `load` | `Double` | Weight load (kg/lbs). |
| `reps` | `Int` | Target repetitions count. |
| `elapsedTime` | `Int` | Set duration (if applicable). |
| `rpe` | `String` | Rated Perceived Exertion (1 to 10). |
| `rir` | `Int` | Reps in Reserve. |
| `completed` | `Bool` | Whether target was achieved. |

### Example

```json
[
  {
    "title": "Hypertrophy Push A",
    "notes": "Focus on controlled eccentrics",
    "timeElapsed": 0,
    "created": "2026-06-03T12:00:00Z",
    "completed": "2026-06-03T13:00:00Z",
    "exercises": [
      {
        "exerciseId": "db_bench_press",
        "name": "Dumbbell Bench Press",
        "notes": "Keep shoulder blades retracted",
        "setMode": "LOAD",
        "restTime": 90,
        "sets": [
          {
            "load": 32.5,
            "reps": 10,
            "elapsedTime": 0,
            "rpe": "9",
            "completed": true
          }
        ]
      }
    ]
  }
]
```

---

## 2. Exercises

Exercises database is imported as a JSON array of custom exercises.

### Fields Description

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique identifier (e.g. `my_custom_exercise`). |
| `name` | `String` | Name of the exercise. |
| `level` | `String` | `BEGINNER`, `INTERMEDIATE`, `ADVANCED`. |
| `category` | `String` | `STRENGTH`, `STRETCHING`, `PLYOMETRICS`, `STRONGMAN`, `POWERLIFTING`, `CARDIO`, `OLYMPIC_WEIGHTLIFTING`. |
| `primaryMuscles` | `Array` | Muscle names (e.g. `chest`, `triceps`). |
| `secondaryMuscles` | `Array` | Muscle names. |
| `instructions` | `Array` | List of instruction text paragraphs. |
| `images` | `Array` | List of image asset URLs/filenames. |

---

## 3. Meal Plans

Meal plans are imported as a JSON array of templates.

### Fields Description

| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | `String` | Title of the meal plan. |
| `notes` | `String` | Overall plan description. |
| `targetProtein` | `Double` | Target daily protein in grams. |
| `targetCarbs` | `Double` | Target daily carbs in grams. |
| `targetFats` | `Double` | Target daily fats in grams. |
| `meals` | `Array` | List of meals within the plan. |

### Meal Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | `String` | Meal name (e.g. Breakfast). |
| `time` | `String` | Time format (e.g. `08:00`). |
| `notes` | `String` | Meal description. |
| `position` | `Int` | Ordering index of the meal. |
| `items` | `Array` | List of meal items. |

### Meal Item Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `String` | `PRODUCT` or `RECIPE`. |
| `targetId` | `Int` | Database ID of the product or recipe. |
| `amount` | `Double` | Portion quantity. |
| `amountUnit` | `String` | `GRAMS` or `UNITS`. |
| `consumed` | `Bool` | Whether it is marked consumed. |
| `position` | `Int` | Ordering index of the item. |
''');
                        await Share.shareXFiles([XFile(file.path)], subject: 'Nexc Import Format Specifications');
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to download format file: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Download Import Format (.md)'),
                  ),
                ],
              ),
            ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
              ),
              onPressed: onImport,
              icon: const Icon(Icons.download),
              label: const Text('Import'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.upload),
              label: const Text('Export'),
            ),
          ],
        ),
      ],
    );
  }
}
