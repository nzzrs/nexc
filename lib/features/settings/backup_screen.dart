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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/util/backup_manager.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  void _showImportError(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 40),
        title: const Text('Import Failed'),
        content: SingleChildScrollView(
          child: SelectableText(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: error));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy Error'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImport(
    BuildContext context,
    Future<ImportResult> Function() importFn,
    String entityName,
  ) async {
    try {
      final result = await importFn();
      if (!context.mounted) return;
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$entityName imported successfully')),
        );
      } else {
        _showImportError(context, result.error ?? 'Unknown error');
      }
    } catch (e) {
      if (!context.mounted) return;
      _showImportError(context, e.toString());
    }
  }

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
                    'Download Markdown import specifications (fields, types, JSON templates) or the active exercise ID list.',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
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
| `isTemporal` | `Bool?` | Optional. If set to `true`, this routine template will auto-delete upon completion. Useful for one-off/AI routines. |
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
| `elapsedTime` | `Int` | Target set duration in seconds (optional). |
| `rpe` | `String?` | Optional. Rated Perceived Exertion (1 to 10). If omitted, defaults to empty/none. |
| `rir` | `Int?` | Optional. Reps in Reserve. If omitted, defaults to empty/none. |
| `completed` | `Bool` | Whether target was achieved. It is highly recommended to set this to `false` for imported templates (indicating sets are not yet performed/done). |

### Example

```json
[
  {
    "title": "Hypertrophy Push A",
    "notes": "Focus on controlled eccentrics",
    "timeElapsed": 0,
    "created": "2026-06-03T12:00:00Z",
    "completed": "2026-06-03T13:00:00Z",
    "isTemporal": true,
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
            "rpe": null,
            "rir": null,
            "completed": false
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
| `equipment` | `String?` | Equipment. Options: `BARBELL`, `DUMBBELL`, `CABLE`, `MACHINE`, `KETTLEBELLS`, `BANDS`, `MEDICINE_BALL`, `BODY_ONLY`, `FOAM_ROLL`, `EXERCISE_BALL`, `E_Z_CURL_BAR`, `OTHER`. |
| `force` | `String?` | Force type. Options: `PUSH`, `PULL`, `STATIC`. |
| `mechanic` | `String?` | Mechanic type. Options: `COMPOUND`, `ISOLATION`. |
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
| `isTemporal` | `Bool?` | Optional. If set to `true`, this meal plan auto-deletes when finished/done. |
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

Each meal item can reference a product or recipe in two ways:

**Option A — Direct DB reference** (requires entities already imported):

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `String` | `PRODUCT` or `RECIPE`. |
| `targetId` | `Int` | Database ID of the existing product or recipe. |
| `amount` | `Double` | Portion quantity. |
| `amountUnit` | `String` | `GRAMS` or `UNITS`. |
| `consumed` | `Bool` | Whether it is marked consumed. |
| `position` | `Int` | Ordering index of the item. |

**Option B — Embedded object** (auto-creates if not found by name):

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `String` | `PRODUCT` or `RECIPE`. |
| `product` | `Object` | Embedded product JSON (for type=PRODUCT). |
| `recipe` | `Object` | Embedded recipe JSON (for type=RECIPE). |
| `amount` | `Double` | Portion quantity. |
| `amountUnit` | `String` | `GRAMS` or `UNITS`. |
| `consumed` | `Bool` | Whether it is marked consumed. |
| `position` | `Int` | Ordering index of the item. |

> Each PRODUCT/RECIPE item **must** have either a `targetId` or an embedded `product`/`recipe` object. If `targetId` is used, the referenced product/recipe must already exist in the database.

---

## 4. Products

Products are imported as a JSON array.

### Fields Description

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | `String` | **Yes** | Product name. |
| `proteins` | `Double` | No (default 0) | Protein per reference weight. |
| `carbsAvailable` | `Double` | No | Available carbs per reference weight. |
| `fats` | `Double` | No (default 0) | Fat per reference weight. |
| `kcal` | `Double` | No | Calories per reference weight. |
| `dietaryFiber` | `Double` | No | Dietary fiber per reference weight. |
| `carbsByDifference` | `Double` | No | Carbs by difference. |
| `defaultUnits` | `String` | No | Default unit (`g`, `ml`, `units`). |
| `ediblePercent` | `Double` | No (default 100) | Edible percentage of the product (0 to 100). |
| `mlToGFactor` | `Int` | No | Conversion factor ml to g. |
| `isSupplement` | `Bool` | No (default false) | Whether product is a supplement. |
| `isPortable` | `Bool` | No (default true) | Whether product is portable. |

---

## 5. Recipes

Recipes are imported as a JSON array.

### Fields Description

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | `String` | **Yes** | Recipe name. |
| `instructions` | `String` | No | Preparation instructions. |
| `isPortable` | `Bool` | No (default true) | Whether recipe is portable. |
| `ingredients` | `Array` | No | Ingredient list. |

### Ingredient Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `productName` | `String` | Must match an existing product name (case-insensitive). |
| `amount` | `Double` | Quantity. |
| `amountUnits` | `String?` | Optional unit label. |

> **Important**: All ingredient `productName` values must match existing products. Import products before recipes.
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
                          label: const Text('Format (.md)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            try {
                              await backupManager.exportAvailableExercisesDocumentation();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Exercise list generated')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to export exercises list: $e')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.format_list_bulleted),
                          label: const Text('Exercises (.md)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 32),
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
                _showImportError(context, e.toString());
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
            onImport: () => _handleImport(context, backupManager.importWorkoutPlans, 'Workout plans'),
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
            onImport: () => _handleImport(context, backupManager.importExercises, 'Exercises'),
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
            onImport: () => _handleImport(context, backupManager.importMealPlans, 'Meal plans'),
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: 'Products',
            description: 'Import or export your products/foods database.',
            onExport: () async {
              try {
                await backupManager.exportProducts();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Products exported')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Products export failed: $e')),
                );
              }
            },
            onImport: () => _handleImport(context, backupManager.importProducts, 'Products'),
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: 'Recipes',
            description: 'Import or export your custom recipes database.',
            onExport: () async {
              try {
                await backupManager.exportRecipes();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipes exported')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recipes export failed: $e')),
                );
              }
            },
            onImport: () => _handleImport(context, backupManager.importRecipes, 'Recipes'),
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
