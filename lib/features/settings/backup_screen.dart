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
import '../../core/l10n/l10n.dart';
import '../../core/util/backup_manager.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  void _showImportError(BuildContext context, String error) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 40),
        title: Text(l10n.importFailed),
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.errorCopied)));
            },
            icon: const Icon(Icons.copy, size: 18),
            label: Text(l10n.copyError),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
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
    final l10n = context.l10n;
    try {
      final result = await importFn();
      if (!context.mounted) return;
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importedSuccessfully(entityName))),
        );
      } else {
        _showImportError(context, result.error ?? l10n.unknownError);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showImportError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupManager = ref.read(backupManagerProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupRestoreTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.importFormatDocumentation,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.importFormatDocumentationDesc),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            try {
                              const formatDoc =
                                  r'''# Nexc Import Formats Specification

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
''';
                              await Share.shareXFiles([
                                XFile.fromData(
                                  utf8.encode(formatDoc),
                                  name: 'nexc_import_format.md',
                                  mimeType: 'text/markdown',
                                ),
                              ], subject: l10n.formatShareSubject);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.formatDownloadFailed('$e'),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.description_outlined),
                          label: Text(l10n.formatMarkdown),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            try {
                              await backupManager
                                  .exportAvailableExercisesDocumentation();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.exerciseListGenerated),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.exerciseListExportFailed('$e'),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.format_list_bulleted),
                          label: Text(l10n.exercisesMarkdown),
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
            title: l10n.databaseTitle,
            description: l10n.databaseDesc,
            onExport: () async {
              try {
                await backupManager.exportDatabase();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.databaseExported)));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.databaseExportFailed('$e'))),
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
                      title: Text(l10n.importSuccessful),
                      content: Text(l10n.importSuccessBody),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.ok),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.databaseImportCancelled)),
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
            title: l10n.workoutPlansTitle,
            description: l10n.workoutPlansDesc,
            onExport: () async {
              try {
                await backupManager.exportWorkoutPlans();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.workoutPlansExported)),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.workoutPlansExportFailed('$e'))),
                );
              }
            },
            onImport: () => _handleImport(
              context,
              backupManager.importWorkoutPlans,
              l10n.workoutPlansTitle,
            ),
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: l10n.workoutHistoryTitle,
            description: l10n.workoutHistoryDesc,
            onExport: () async {
              try {
                await backupManager.exportWorkoutHistory();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.workoutHistoryExported)),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.workoutHistoryExportFailed('$e')),
                  ),
                );
              }
            },
            onImport: () => _handleImport(
              context,
              backupManager.importWorkoutHistory,
              l10n.workoutHistoryTitle,
            ),
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: l10n.exercisesLabel,
            description: l10n.exercisesBackupDesc,
            onExport: () async {
              try {
                await backupManager.exportExercises();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.exercisesExported)));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.exercisesExportFailed('$e'))),
                );
              }
            },
            onImport: () => _handleImport(
              context,
              backupManager.importExercises,
              l10n.exercisesLabel,
            ),
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: l10n.mealPlansTitle,
            description: l10n.mealPlansDesc,
            onExport: () async {
              try {
                await backupManager.exportMealPlans();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.mealPlansExported)));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.mealPlansExportFailed('$e'))),
                );
              }
            },
            onImport: () => _handleImport(
              context,
              backupManager.importMealPlans,
              l10n.mealPlansTitle,
            ),
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: l10n.mealHistoryTitle,
            description: l10n.mealHistoryDesc,
            onExport: () async {
              try {
                await backupManager.exportMealHistory();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.mealHistoryExported)),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.mealHistoryExportFailed('$e'))),
                );
              }
            },
            onImport: () => _handleImport(
              context,
              backupManager.importMealHistory,
              l10n.mealHistoryTitle,
            ),
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: l10n.productsTab,
            description: l10n.productsBackupDesc,
            onExport: () async {
              try {
                await backupManager.exportProducts();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.productsExported)));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.productsExportFailed('$e'))),
                );
              }
            },
            onImport: () => _handleImport(
              context,
              backupManager.importProducts,
              l10n.productsTab,
            ),
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: l10n.recipesTab,
            description: l10n.recipesBackupDesc,
            onExport: () async {
              try {
                await backupManager.exportRecipes();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.recipesExported)));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.recipesExportFailed('$e'))),
                );
              }
            },
            onImport: () => _handleImport(
              context,
              backupManager.importRecipes,
              l10n.recipesTab,
            ),
          ),
          const Divider(height: 32),
          _buildBackupSection(
            context,
            title: l10n.stockTitle,
            description: l10n.stockBackupDesc,
            onExport: () async {
              try {
                await backupManager.exportStock();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.stockExported)));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.stockExportFailed('$e'))),
                );
              }
            },
            onImport: () => _handleImport(
              context,
              backupManager.importStock,
              l10n.stockTitle,
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
              label: Text(context.l10n.importAction),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.upload),
              label: Text(context.l10n.exportAction),
            ),
          ],
        ),
      ],
    );
  }
}
