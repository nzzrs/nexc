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
import '../../core/db/app_database.dart';
import '../../core/db/enums.dart';
import '../../core/db/dataset_repository.dart';
import '../../core/integrations/ai_service.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/components/clearable_search_field.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  final bool
  addExercises; // true if selecting multiple, false if selecting single
  final bool isSelectionMode; // true if selecting, false if browsing
  final ExerciseDataDC? targetExerciseToReplace;

  const ExercisesScreen({
    super.key,
    this.addExercises = true,
    this.isSelectionMode = true,
    this.targetExerciseToReplace,
  });

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _showFilters = false;

  // Filters State
  Level? _selectedLevel;
  Force? _selectedForce;
  Mechanic? _selectedMechanic;
  Equipment? _selectedEquipment;
  Muscle? _selectedMuscle;
  Category? _selectedCategory;
  bool _onlyCustom = false;

  final Set<ExerciseDataDC> _selectedExercises = {};
  late final Stream<List<ExerciseDataDC>> _datasetStream;
  List<ExerciseDataDC> _aiSuggestions = [];
  bool _aiSuggestionsLoading = false;

  @override
  void initState() {
    super.initState();
    _datasetStream = ref.read(datasetRepositoryProvider).getDataset();
    _loadAiSuggestions();
  }

  Future<void> _loadAiSuggestions() async {
    final target = widget.targetExerciseToReplace;
    if (target == null) return;

    setState(() {
      _aiSuggestionsLoading = true;
    });

    try {
      final allExercises = await ref
          .read(datasetRepositoryProvider)
          .getExercises();
      final targetPrimary = target.primaryMuscles.toSet();
      final targetSecondary = target.secondaryMuscles.toSet();

      int similarityScore(ExerciseDataDC ex) {
        int score = 0;
        for (final muscle in ex.primaryMuscles) {
          if (targetPrimary.contains(muscle)) score += 5;
          if (targetSecondary.contains(muscle)) score += 2;
        }
        for (final muscle in ex.secondaryMuscles) {
          if (targetPrimary.contains(muscle)) score += 2;
          if (targetSecondary.contains(muscle)) score += 1;
        }
        return score;
      }

      final candidates =
          allExercises
              .where((ex) => ex.id != target.id && similarityScore(ex) > 0)
              .map(
                (ex) => <String, dynamic>{
                  'id': ex.id,
                  'name': ex.name,
                  'commonMuscles': similarityScore(ex),
                },
              )
              .toList()
            ..sort(
              (a, b) => (b['commonMuscles'] as int).compareTo(
                a['commonMuscles'] as int,
              ),
            );

      final settings = ref.read(settingsProvider);
      final ids = await AIService.getReplacementSuggestions(
        provider: settings.aiProvider,
        apiKey: settings.aiToken,
        model: settings.aiModel,
        targetExerciseName: target.name,
        targetMuscles: {
          ...target.primaryMuscles.map((m) => m.name),
          ...target.secondaryMuscles.map((m) => m.name),
        }.toList(),
        availableExercises: candidates.take(80).toList(),
      );

      final byId = {for (final ex in allExercises) ex.id: ex};
      final suggestions = <ExerciseDataDC>[];
      for (final id in ids) {
        final exercise = byId[id];
        if (exercise != null && exercise.id != target.id) {
          suggestions.add(exercise);
        }
        if (suggestions.length >= 5) break;
      }

      if (!mounted) return;
      setState(() {
        _aiSuggestions = suggestions;
      });
    } finally {
      if (mounted) {
        setState(() {
          _aiSuggestionsLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _fuzzyScore(String name, String query) {
    if (query.isEmpty) return 100;
    final n = name.toLowerCase();
    final q = query.toLowerCase().trim();
    if (n.contains(q)) return 100;
    final queryWords = q.split(RegExp(r'\s+'));
    int matches = 0;
    for (final word in queryWords) {
      if (n.contains(word)) {
        matches++;
      }
    }
    if (matches == queryWords.length) {
      return 90;
    } else if (matches > 0) {
      return 60 + ((matches / queryWords.length) * 20).round();
    }
    return 0;
  }

  bool _filterExercise(ExerciseDataDC ex) {
    if (_selectedLevel != null && ex.level != _selectedLevel) return false;
    if (_selectedForce != null && ex.force != _selectedForce) return false;
    if (_selectedMechanic != null && ex.mechanic != _selectedMechanic) {
      return false;
    }
    if (_selectedEquipment != null && ex.equipment != _selectedEquipment) {
      return false;
    }
    if (_selectedCategory != null && ex.category != _selectedCategory) {
      return false;
    }
    if (_selectedMuscle != null) {
      final hasPrimary = ex.primaryMuscles.contains(_selectedMuscle);
      final hasSecondary = ex.secondaryMuscles.contains(_selectedMuscle);
      if (!hasPrimary && !hasSecondary) return false;
    }
    if (_onlyCustom && !ex.isCustomExercise) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final showImages = ref.watch(
      settingsProvider.select((s) => s.showExerciseImages),
    );

    final isReplacing = widget.targetExerciseToReplace != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.addExercises
              ? l10n.addExercisesTitle
              : (isReplacing ? l10n.replaceExerciseTitle : l10n.selectExercise),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          if (widget.addExercises && _selectedExercises.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context, _selectedExercises.toList());
              },
              child: Text(
                l10n.addCount(_selectedExercises.length),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClearableSearchField(
              controller: _searchController,
              hintText: l10n.searchExercise,
              onChanged: (val) {
                setState(() {
                  _query = val;
                });
              },
            ),
          ),

          // Filters Drawer/Panel
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(
                        _selectedLevel == null
                            ? l10n.levelLabel
                            : l10n.levelWithValue(_selectedLevel!.name),
                      ),
                      selected: _selectedLevel != null,
                      onSelected: (selected) {
                        _showFilterSelector<Level>(
                          title: l10n.selectLevel,
                          values: Level.values,
                          current: _selectedLevel,
                          onSelected: (val) =>
                              setState(() => _selectedLevel = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(
                        _selectedForce == null
                            ? l10n.forceLabel
                            : l10n.forceWithValue(_selectedForce!.name),
                      ),
                      selected: _selectedForce != null,
                      onSelected: (selected) {
                        _showFilterSelector<Force>(
                          title: l10n.selectForce,
                          values: Force.values,
                          current: _selectedForce,
                          onSelected: (val) =>
                              setState(() => _selectedForce = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(
                        _selectedMechanic == null
                            ? l10n.mechanicLabel
                            : l10n.mechanicWithValue(_selectedMechanic!.name),
                      ),
                      selected: _selectedMechanic != null,
                      onSelected: (selected) {
                        _showFilterSelector<Mechanic>(
                          title: l10n.selectMechanic,
                          values: Mechanic.values,
                          current: _selectedMechanic,
                          onSelected: (val) =>
                              setState(() => _selectedMechanic = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(
                        _selectedEquipment == null
                            ? l10n.equipmentLabel
                            : l10n.equipmentWithValue(_selectedEquipment!.name),
                      ),
                      selected: _selectedEquipment != null,
                      onSelected: (selected) {
                        _showFilterSelector<Equipment>(
                          title: l10n.selectEquipment,
                          values: Equipment.values,
                          current: _selectedEquipment,
                          onSelected: (val) =>
                              setState(() => _selectedEquipment = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(
                        _selectedMuscle == null
                            ? l10n.muscleLabel
                            : l10n.muscleWithValue(_selectedMuscle!.name),
                      ),
                      selected: _selectedMuscle != null,
                      onSelected: (selected) {
                        _showFilterSelector<Muscle>(
                          title: l10n.selectMuscle,
                          values: Muscle.values,
                          current: _selectedMuscle,
                          onSelected: (val) =>
                              setState(() => _selectedMuscle = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(
                        _selectedCategory == null
                            ? l10n.categoryLabel
                            : l10n.categoryWithValue(_selectedCategory!.name),
                      ),
                      selected: _selectedCategory != null,
                      onSelected: (selected) {
                        _showFilterSelector<Category>(
                          title: l10n.selectCategory,
                          values: Category.values,
                          current: _selectedCategory,
                          onSelected: (val) =>
                              setState(() => _selectedCategory = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(l10n.customOnly),
                      selected: _onlyCustom,
                      onSelected: (selected) {
                        setState(() {
                          _onlyCustom = selected;
                        });
                      },
                    ),
                    if (_selectedLevel != null ||
                        _selectedForce != null ||
                        _selectedMechanic != null ||
                        _selectedEquipment != null ||
                        _selectedMuscle != null ||
                        _selectedCategory != null ||
                        _onlyCustom) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedLevel = null;
                            _selectedForce = null;
                            _selectedMechanic = null;
                            _selectedEquipment = null;
                            _selectedMuscle = null;
                            _selectedCategory = null;
                            _onlyCustom = false;
                          });
                        },
                        child: Text(l10n.reset),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Exercise List
          Expanded(
            child: StreamBuilder<List<ExerciseDataDC>>(
              stream: _datasetStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(l10n.errorWithMessage('${snapshot.error}')),
                  );
                }
                final list = snapshot.data ?? [];

                // Filter & Search
                final filtered = list.where((ex) {
                  if (!_filterExercise(ex)) return false;
                  return _fuzzyScore(ex.name, _query) > 60;
                }).toList();

                final targetMuscles =
                    widget.targetExerciseToReplace?.primaryMuscles.toSet() ??
                    {};
                final targetSecondary =
                    widget.targetExerciseToReplace?.secondaryMuscles.toSet() ??
                    {};

                int computeSimilarity(ExerciseDataDC ex) {
                  if (widget.targetExerciseToReplace == null ||
                      ex.id == widget.targetExerciseToReplace!.id) {
                    return 0;
                  }
                  int score = 0;
                  for (final m in ex.primaryMuscles) {
                    if (targetMuscles.contains(m)) score += 5;
                    if (targetSecondary.contains(m)) score += 2;
                  }
                  for (final m in ex.secondaryMuscles) {
                    if (targetMuscles.contains(m)) score += 2;
                    if (targetSecondary.contains(m)) score += 1;
                  }
                  return score;
                }

                // AI suggestions when in replace mode and not searching with query
                final List<ExerciseDataDC> aiSuggestions = [];
                if (widget.targetExerciseToReplace != null && _query.isEmpty) {
                  final filteredIds = filtered.map((ex) => ex.id).toSet();
                  aiSuggestions.addAll(
                    _aiSuggestions.where((ex) => filteredIds.contains(ex.id)),
                  );
                  if (aiSuggestions.isEmpty) {
                    // Deterministic local fallback until the AI ranking arrives.
                    final candidates = filtered
                        .where(
                          (ex) => ex.id != widget.targetExerciseToReplace!.id,
                        )
                        .map((ex) => MapEntry(ex, computeSimilarity(ex)))
                        .where((entry) => entry.value > 0)
                        .toList();
                    candidates.sort((a, b) => b.value.compareTo(a.value));
                    aiSuggestions.addAll(candidates.take(5).map((e) => e.key));
                  }
                }

                // Sort full catalog list
                final sorted = List<ExerciseDataDC>.from(filtered);
                sorted.sort((a, b) {
                  final aSelected = _selectedExercises.contains(a);
                  final bSelected = _selectedExercises.contains(b);
                  if (aSelected && !bSelected) return -1;
                  if (!aSelected && bSelected) return 1;

                  if (widget.targetExerciseToReplace != null &&
                      _query.isEmpty) {
                    final aScore = computeSimilarity(a);
                    final bScore = computeSimilarity(b);
                    if (aScore != bScore) return bScore.compareTo(aScore);
                  }

                  if (_query.isNotEmpty) {
                    final scoreA = _fuzzyScore(a.name, _query);
                    final scoreB = _fuzzyScore(b.name, _query);
                    return scoreB.compareTo(scoreA);
                  }
                  return 0;
                });

                if (sorted.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noExercisesFound,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text(l10n.createExercise),
                            onPressed: () =>
                                _openCreateExerciseDialog(initialName: _query),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(l10n.createWithAi),
                            onPressed: () => _createWithAi(initialName: _query),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                Widget buildExerciseTile(
                  ExerciseDataDC ex, {
                  bool isAiSuggestion = false,
                }) {
                  final isSelected = _selectedExercises.any(
                    (e) => e.id == ex.id,
                  );

                  return Container(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.24,
                          )
                        : (isAiSuggestion
                              ? theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.08,
                                )
                              : null),
                    child: ListTile(
                      selected: isSelected,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: showImages && ex.images.isNotEmpty
                              ? Image.asset(
                                  'assets/exercise_images/${ex.images.first.replaceAll('/', '_')}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.fitness_center,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                )
                              : Icon(
                                  Icons.fitness_center,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ex.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isAiSuggestion)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.aiMatch,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        l10n.exerciseSubtitle(
                          ex.category.name,
                          ex.equipment?.name ?? l10n.noEquipment,
                          ex.primaryMuscles.map((m) => m.name).join(', '),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: widget.isSelectionMode
                          ? (widget.addExercises
                                ? Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedExercises.add(ex);
                                        } else {
                                          _selectedExercises.removeWhere(
                                            (e) => e.id == ex.id,
                                          );
                                        }
                                      });
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: () {
                                      Navigator.pop(context, [ex]);
                                    },
                                  ))
                          : null,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/exercises/info',
                          arguments: ex.id,
                        );
                      },
                    ),
                  );
                }

                if (aiSuggestions.isNotEmpty) {
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.aiSuggestions,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (_aiSuggestionsLoading) ...[
                              const SizedBox(width: 10),
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ...aiSuggestions.map(
                        (ex) => buildExerciseTile(ex, isAiSuggestion: true),
                      ),
                      const Divider(height: 24),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Text(
                          l10n.allExercises,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...sorted.map(
                        (ex) => buildExerciseTile(ex, isAiSuggestion: false),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    return buildExerciseTile(
                      sorted[index],
                      isAiSuggestion: false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSelector<T>({
    required String title,
    required List<T> values,
    required T? current,
    required Function(T?) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text(context.l10n.all),
                      trailing: current == null
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        onSelected(null);
                        Navigator.pop(context);
                      },
                    ),
                    ...values.map((v) {
                      final name = v.toString().split('.').last;
                      return ListTile(
                        title: Text(name),
                        trailing: current == v ? const Icon(Icons.check) : null,
                        onTap: () {
                          onSelected(v);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCreateExerciseDialog({String initialName = ''}) async {
    final l10n = context.l10n;
    final nameController = TextEditingController(text: initialName);
    final categoryNotifier = ValueNotifier<Category>(Category.STRENGTH);
    final muscleNotifier = ValueNotifier<Muscle>(
      widget.targetExerciseToReplace?.primaryMuscles.firstOrNull ??
          Muscle.CHEST,
    );

    final created = await showDialog<ExerciseDataDC>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.createCustomExercise),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.exerciseName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<Category>(
                valueListenable: categoryNotifier,
                builder: (context, cat, _) => DropdownButtonFormField<Category>(
                  initialValue: cat,
                  decoration: InputDecoration(
                    labelText: l10n.categoryLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: Category.values
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) categoryNotifier.value = val;
                  },
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<Muscle>(
                valueListenable: muscleNotifier,
                builder: (context, mus, _) => DropdownButtonFormField<Muscle>(
                  initialValue: mus,
                  decoration: InputDecoration(
                    labelText: l10n.primaryMuscleField,
                    border: const OutlineInputBorder(),
                  ),
                  items: Muscle.values
                      .map(
                        (m) => DropdownMenuItem(value: m, child: Text(m.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) muscleNotifier.value = val;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
              final ex = ExerciseDataDC(
                id: newId,
                name: name,
                level: Level.BEGINNER,
                category: categoryNotifier.value,
                primaryMuscles: [muscleNotifier.value],
                secondaryMuscles: const [],
                instructions: const [],
                images: const [],
                isCustomExercise: true,
              );
              await ref.read(datasetRepositoryProvider).upsertExercise(ex);
              if (ctx.mounted) Navigator.pop(ctx, ex);
            },
            child: Text(l10n.saveAction),
          ),
        ],
      ),
    );

    if (created != null && mounted) {
      if (widget.isSelectionMode) {
        Navigator.of(context).pop([created]);
      }
    }
  }

  Future<void> _createWithAi({String initialName = ''}) async {
    final promptController = TextEditingController(text: initialName);

    final confirmed = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            const SizedBox(width: 8),
            Text(context.l10n.createWithAi),
          ],
        ),
        content: TextField(
          controller: promptController,
          decoration: InputDecoration(
            hintText: context.l10n.describeExerciseHint,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, promptController.text.trim()),
            child: Text(context.l10n.generateAction),
          ),
        ],
      ),
    );

    if (confirmed == null || confirmed.isEmpty || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generatingExerciseWithAi)),
    );

    final settings = ref.read(settingsProvider);
    final result = await AIService.generateCustomExercise(
      provider: settings.aiProvider,
      apiKey: settings.aiToken,
      model: settings.aiModel,
      exerciseDescription: confirmed,
    );

    if (result != null && mounted) {
      final name = result['name'] as String? ?? confirmed;
      final newId = 'custom_ai_${DateTime.now().millisecondsSinceEpoch}';
      final ex = ExerciseDataDC(
        id: newId,
        name: name,
        level: Level.BEGINNER,
        category: Category.values.firstWhere(
          (c) => c.name == result['category'],
          orElse: () => Category.STRENGTH,
        ),
        primaryMuscles: [
          widget.targetExerciseToReplace?.primaryMuscles.firstOrNull ??
              Muscle.CHEST,
        ],
        secondaryMuscles: const [],
        instructions:
            (result['instructions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        images: const [],
        isCustomExercise: true,
      );
      await ref.read(datasetRepositoryProvider).upsertExercise(ex);
      if (mounted && widget.isSelectionMode) {
        Navigator.of(context).pop([ex]);
      }
    }
  }
}
