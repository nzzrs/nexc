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

class ExercisesScreen extends ConsumerStatefulWidget {
  final bool addExercises; // true if selecting multiple, false if selecting single

  const ExercisesScreen({
    super.key,
    this.addExercises = true,
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

  final Set<ExerciseDC> _selectedExercises = {};

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

  bool _filterExercise(ExerciseDC ex) {
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
    final datasetStream = ref.watch(datasetRepositoryProvider).getDataset();

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
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
            child: StreamBuilder<List<ExerciseDC>>(
              stream: datasetStream,
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

                // Sort by fuzzy score descending
                if (_query.isNotEmpty) {
                  filtered.sort((a, b) {
                    final scoreA = _fuzzyScore(a.name, _query);
                    final scoreB = _fuzzyScore(b.name, _query);
                    return scoreB.compareTo(scoreA);
                  });
                }

                if (filtered.isEmpty) {
                  return const Center(child: Text('No exercises found.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ex = filtered[index];
                    final isSelected = _selectedExercises.contains(ex);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.fitness_center, color: theme.colorScheme.onPrimaryContainer),
                      ),
                      title: Text(
                        ex.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${ex.category.name} • ${ex.equipment?.name ?? "No Equipment"}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: widget.addExercises
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedExercises.add(ex);
                                  } else {
                                    _selectedExercises.remove(ex);
                                  }
                                });
                              },
                            )
                          : null,
                      onTap: () {
                        if (widget.addExercises) {
                          setState(() {
                            if (isSelected) {
                              _selectedExercises.remove(ex);
                            } else {
                              _selectedExercises.add(ex);
                            }
                          });
                        } else {
                          Navigator.pop(context, [ex]);
                        }
                      },
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
}
