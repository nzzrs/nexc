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
| `isTemporal` | `Bool?` | Optional. If `true`, auto-deletes upon completion. |
| `exercises` | `Array` | List of exercise items in the plan. |

### Exercise Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `exerciseId` | `String` | Unique ID of the exercise. |
| `name` | `String` | Name of the exercise (used if not found in local database). |
| `notes` | `String` | Exercise-specific notes. |
| `setMode` | `String` | `LOAD`, `BODYWEIGHT`, `BODYWEIGHT_WITH_LOAD`, `TIME`, `TIME_WITH_LOAD`. |
| `restTime` | `Int` | Rest time in seconds between sets. |
| `supersetGroupId` | `String?` | Optional identifier to group supersets. |
| `sets` | `Array` | Sets list. |

### Set Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `load` | `Double` | Weight load (kg/lbs). |
| `reps` | `Int` | Target repetitions count. |
| `elapsedTime` | `Int` | Target set duration in seconds (optional). |
| `rpe` | `String?` | Rated Perceived Exertion (1-10). |
| `rir` | `Int?` | Reps in Reserve. |
| `completed` | `Bool` | Set to `false` for imported templates. |

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

Exercises are imported as a JSON array of custom exercises.

### Fields Description

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique identifier (e.g. `my_custom_exercise`). |
| `name` | `String` | Name of the exercise. |
| `level` | `String` | `BEGINNER`, `INTERMEDIATE`, `ADVANCED`. |
| `category` | `String` | `STRENGTH`, `STRETCHING`, `PLYOMETRICS`, `STRONGMAN`, `POWERLIFTING`, `CARDIO`, `OLYMPIC_WEIGHTLIFTING`. |
| `equipment` | `String?` | `BARBELL`, `DUMBBELL`, `CABLE`, `MACHINE`, `KETTLEBELLS`, `BANDS`, `MEDICINE_BALL`, `BODY_ONLY`, `FOAM_ROLL`, `EXERCISE_BALL`, `E_Z_CURL_BAR`, `OTHER`. |
| `force` | `String?` | `PUSH`, `PULL`, `STATIC`. |
| `mechanic` | `String?` | `COMPOUND`, `ISOLATION`. |
| `primaryMuscles` | `Array` | Muscle names (e.g. `chest`, `triceps`). |
| `secondaryMuscles` | `Array` | Muscle names. |
| `instructions` | `Array` | List of instruction text paragraphs. |
| `images` | `Array` | List of image asset URLs/filenames. |

---

## 3. Meal Plans

Meal plans are imported as a JSON array of templates.

### Meal Plan Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | `String` | Title of the meal plan. |
| `notes` | `String` | Overall plan description. |
| `isTemporal` | `Bool?` | If `true`, auto-deletes when completed. |
| `meals` | `Array` | List of meals within the plan. |

### Meal Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | `String` | Meal name (e.g. Breakfast). |
| `time` | `String` | Time as HH:mm:ss (e.g. 08:00:00). |
| `notes` | `String` | Meal description. |
| `position` | `Int` | Ordering index of the meal. |
| `atHome` | `Bool` | Whether the meal is eaten at home. Default: true. |
| `items` | `Array` | List of meal items. |

### Meal Item Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `String` | PRODUCT or RECIPE. |
| `amount` | `Double` | Portion quantity in the specified unit. |
| `amountUnit` | `String` | GRAMS, ML, or UNITS. Default: GRAMS. |
| `consumed` | `Bool` | Whether it is marked consumed. Default: false. |
| `position` | `Int` | Ordering index of the item. |
| `product` | `Object` | Embedded product (for type=PRODUCT). |
| `recipe` | `Object` | Embedded recipe (for type=RECIPE). |

> Each item must have either a targetId (DB reference) or an embedded product/recipe object.

---

## 4. Products

Products are imported as a JSON array.

### Fields Description

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | `String` | Yes | Product name. |
| `proteins` | `Double` | No | Protein per 100 g. |
| `fats` | `Double` | No | Fat per 100 g. |
| `carbsAvailable` | `Double` | No | Available (net) carbs per 100 g. |
| `carbsByDifference` | `Double` | No | Carbs by difference per 100 g. |
| `dietaryFiber` | `Double` | No | Dietary fiber per 100 g. |
| `kcal` | `Double` | No | Kilocalories per 100 g. |
| `mlToGFactor` | `Int` | No | ml-to-g conversion factor (e.g. 103 for whole milk). If 0, ml unit is hidden. |
| `unitWeight` | `Int` | No | Weight of one unit in grams (e.g. 120 for a banana). If 0, units are hidden. |
| `edibleQtyPerUnit` | `Double` | No | Edible grams per unit. Used with isStockRaw. |
| `defaultUnits` | `String` | No | Default stock unit: g, ml, or units. |
| `isSupplement` | `Bool` | No | true for supplements. Default: false. |
| `isPortable` | `Bool` | No | Whether portable. Default: true. |
| `isStockRaw` | `Bool` | No | true if stock includes non-edible parts (peel, shell, etc.). App uses edibleQtyPerUnit to compute actual consumed grams. Default: false. |

---

## 5. Recipes

Recipes are imported as a JSON array.

### Fields Description

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | `String` | Yes | Recipe name. |
| `instructions` | `String` | No | Preparation instructions. |
| `isPortable` | `Bool` | No | Whether portable. Default: true. |
| `ingredients` | `Array` | No | Ingredient list. |

### Ingredient Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `amount` | `Double` | Quantity in grams. |
| `product` | `Object` | A full Product object (see section 4). |

> All ingredient products must either exist in the database (matched by name) or be provided as embedded objects.
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
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: 'Stock',
            description: 'Import or export your stock inventory and house data. Products must already exist in the database before importing stock.',
            onExport: () async {
              try {
                await backupManager.exportStock();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock exported successfully')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stock export failed: $e')),
                );
              }
            },
            onImport: () => _handleImport(context, backupManager.importStock, 'Stock'),
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
