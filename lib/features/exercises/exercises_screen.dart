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
import '../../core/providers/settings_provider.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  final bool addExercises; // true if selecting multiple, false if selecting single
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

  @override
  void initState() {
    super.initState();
    _datasetStream = ref.read(datasetRepositoryProvider).getDataset();
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
    if (_selectedMechanic != null && ex.mechanic != _selectedMechanic) return false;
    if (_selectedEquipment != null && ex.equipment != _selectedEquipment) return false;
    if (_selectedCategory != null && ex.category != _selectedCategory) return false;
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


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.addExercises ? 'Add Exercises' : 'Select Exercise'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
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
                'ADD (${_selectedExercises.length})',
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercise...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(_selectedLevel == null ? 'Level' : 'Level: ${_selectedLevel!.name}'),
                      selected: _selectedLevel != null,
                      onSelected: (selected) {
                        _showFilterSelector<Level>(
                          title: 'Select Level',
                          values: Level.values,
                          current: _selectedLevel,
                          onSelected: (val) => setState(() => _selectedLevel = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(_selectedForce == null ? 'Force' : 'Force: ${_selectedForce!.name}'),
                      selected: _selectedForce != null,
                      onSelected: (selected) {
                        _showFilterSelector<Force>(
                          title: 'Select Force',
                          values: Force.values,
                          current: _selectedForce,
                          onSelected: (val) => setState(() => _selectedForce = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(_selectedMechanic == null ? 'Mechanic' : 'Mechanic: ${_selectedMechanic!.name}'),
                      selected: _selectedMechanic != null,
                      onSelected: (selected) {
                        _showFilterSelector<Mechanic>(
                          title: 'Select Mechanic',
                          values: Mechanic.values,
                          current: _selectedMechanic,
                          onSelected: (val) => setState(() => _selectedMechanic = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(_selectedEquipment == null ? 'Equipment' : 'Equipment: ${_selectedEquipment!.name}'),
                      selected: _selectedEquipment != null,
                      onSelected: (selected) {
                        _showFilterSelector<Equipment>(
                          title: 'Select Equipment',
                          values: Equipment.values,
                          current: _selectedEquipment,
                          onSelected: (val) => setState(() => _selectedEquipment = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(_selectedMuscle == null ? 'Muscle' : 'Muscle: ${_selectedMuscle!.name}'),
                      selected: _selectedMuscle != null,
                      onSelected: (selected) {
                        _showFilterSelector<Muscle>(
                          title: 'Select Muscle',
                          values: Muscle.values,
                          current: _selectedMuscle,
                          onSelected: (val) => setState(() => _selectedMuscle = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(_selectedCategory == null ? 'Category' : 'Category: ${_selectedCategory!.name}'),
                      selected: _selectedCategory != null,
                      onSelected: (selected) {
                        _showFilterSelector<Category>(
                          title: 'Select Category',
                          values: Category.values,
                          current: _selectedCategory,
                          onSelected: (val) => setState(() => _selectedCategory = val),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Custom Only'),
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
                        child: const Text('Reset'),
                      ),
                    ]
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final list = snapshot.data ?? [];

                // Filter & Search
                final filtered = list.where((ex) {
                  if (!_filterExercise(ex)) return false;
                  return _fuzzyScore(ex.name, _query) > 60;
                }).toList();

                // Sort: Selected first, then AI/muscle similarity replacements first if replacing, then query
                final sorted = List<ExerciseDataDC>.from(filtered);
                final targetMuscles = widget.targetExerciseToReplace?.primaryMuscles.toSet() ?? {};

                sorted.sort((a, b) {
                  final aSelected = _selectedExercises.contains(a);
                  final bSelected = _selectedExercises.contains(b);
                  if (aSelected && !bSelected) return -1;
                  if (!aSelected && bSelected) return 1;

                  if (widget.targetExerciseToReplace != null && _query.isEmpty) {
                    final aMatches = a.primaryMuscles.any((m) => targetMuscles.contains(m));
                    final bMatches = b.primaryMuscles.any((m) => targetMuscles.contains(m));
                    if (aMatches && !bMatches) return -1;
                    if (!aMatches && bMatches) return 1;
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
                          Icon(Icons.search_off, size: 48, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text('No exercises found', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Create Exercise'),
                            onPressed: () => _openCreateExerciseDialog(initialName: _query),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Create with AI'),
                            onPressed: () => _createWithAi(initialName: _query),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final ex = sorted[index];
                    final isSelected = _selectedExercises.any((e) => e.id == ex.id);

                    return Container(
                      color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.24) : null,
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
                            child: ex.images.isNotEmpty
                                ? Image.asset(
                                    'assets/exercise_images/${ex.images.first.replaceAll('/', '_')}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.fitness_center,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  )
                                : Icon(
                                    Icons.fitness_center,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                          ),
                        ),
                        title: Text(
                          ex.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${ex.category.name} • ${ex.equipment?.name ?? "No Equipment"}',
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
                                          _selectedExercises.removeWhere((e) => e.id == ex.id);
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }  void _showFilterSelector<T>({
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('All'),
                      trailing: current == null ? const Icon(Icons.check) : null,
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
    final nameController = TextEditingController(text: initialName);
    final categoryNotifier = ValueNotifier<Category>(Category.STRENGTH);
    final muscleNotifier = ValueNotifier<Muscle>(widget.targetExerciseToReplace?.primaryMuscles.firstOrNull ?? Muscle.CHEST);

    final created = await showDialog<ExerciseDataDC>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Custom Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Exercise Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<Category>(
                valueListenable: categoryNotifier,
                builder: (context, cat, _) => DropdownButtonFormField<Category>(
                  initialValue: cat,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: Category.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
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
                  decoration: const InputDecoration(labelText: 'Primary Muscle', border: OutlineInputBorder()),
                  items: Muscle.values.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: (val) {
                    if (val != null) muscleNotifier.value = val;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
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
            child: const Text('SAVE'),
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
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber),
            SizedBox(width: 8),
            Text('Create with AI'),
          ],
        ),
        content: TextField(
          controller: promptController,
          decoration: const InputDecoration(
            hintText: 'Describe exercise (e.g. Dumbbell rear delt fly on incline bench)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, promptController.text.trim()),
            child: const Text('GENERATE'),
          ),
        ],
      ),
    );

    if (confirmed == null || confirmed.isEmpty || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating exercise with AI...')));

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
          widget.targetExerciseToReplace?.primaryMuscles.firstOrNull ?? Muscle.CHEST,
        ],
        secondaryMuscles: const [],
        instructions: (result['instructions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
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

