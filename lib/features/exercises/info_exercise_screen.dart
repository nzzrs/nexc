/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_database.dart';
import '../../core/db/dataset_repository.dart';

class InfoExerciseScreen extends ConsumerStatefulWidget {
  final String exerciseId;

  const InfoExerciseScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  ConsumerState<InfoExerciseScreen> createState() => _InfoExerciseScreenState();
}

class _InfoExerciseScreenState extends ConsumerState<InfoExerciseScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  ExerciseDC? _exercise;
  int _currentImageIndex = 0;
  Timer? _imageTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExercise();
  }

  Future<void> _loadExercise() async {
    final repo = ref.read(datasetRepositoryProvider);
    final data = await repo.getExerciseFromId(widget.exerciseId);
    if (data == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    setState(() {
      _exercise = data;
      _isLoading = false;
    });

    if (data.images.isNotEmpty) {
      _startImageTimer();
    }
  }

  void _startImageTimer() {
    _imageTimer?.cancel();
    _imageTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_exercise != null && _exercise!.images.isNotEmpty && mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _exercise!.images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  String _formatEnum(String? val) {
    if (val == null) return '-';
    return val.replaceAll('_', ' ').toUpperCase();
  }

  Widget _buildDetailChip(String label, String value, IconData icon, ColorScheme colors) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      color: colors.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading || _exercise == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ex = _exercise!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
        backgroundColor: colors.surfaceContainerLow,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Image / Visual Representation Panel
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (ex.images.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/exercise_images/${ex.images[_currentImageIndex].replaceAll('/', '_')}',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 80,
                            color: colors.primary.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                  // Dots indicator
                  if (ex.images.length > 1)
                    Positioned(
                      bottom: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(ex.images.length, (idx) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: _currentImageIndex == idx ? 12.0 : 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == idx ? colors.primary : colors.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          );
                        }),
                      ),
                    ),
                ] else
                  Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: colors.primary.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          // Exercise Name below the image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Text(
              ex.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
          ),
          // Tab Bar Header
          Container(
            color: colors.surfaceContainerLow,
            child: TabBar(
              controller: _tabController,
              labelColor: colors.primary,
              unselectedLabelColor: colors.onSurfaceVariant,
              indicatorColor: colors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  icon: Icon(Icons.info_outline),
                  text: 'Details',
                ),
                Tab(
                  icon: Icon(Icons.list_alt),
                  text: 'Instructions',
                ),
              ],
            ),
          ),

          // Tab View Content
          Expanded(
            child: Container(
              color: colors.surface,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Details
                  ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildDetailChip('Category', _formatEnum(ex.category.name), Icons.category_outlined, colors),
                      const SizedBox(height: 8),
                      _buildDetailChip('Equipment', _formatEnum(ex.equipment?.name), Icons.construction_outlined, colors),
                      const SizedBox(height: 8),
                      _buildDetailChip('Level', _formatEnum(ex.level.name), Icons.speed_outlined, colors),
                      const SizedBox(height: 8),
                      _buildDetailChip('Force', _formatEnum(ex.force?.name), Icons.flash_on_outlined, colors),
                      const SizedBox(height: 8),
                      _buildDetailChip('Mechanic', _formatEnum(ex.mechanic?.name), Icons.settings_accessibility_outlined, colors),
                      const SizedBox(height: 16),
                      if (ex.primaryMuscles.isNotEmpty) ...[
                        Text(
                          'Primary Muscles Worked',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ex.primaryMuscles.map((muscle) {
                            return Chip(
                              label: Text(_formatEnum(muscle.name)),
                              backgroundColor: colors.primaryContainer.withOpacity(0.5),
                              labelStyle: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.w600),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (ex.secondaryMuscles.isNotEmpty) ...[
                        Text(
                          'Secondary Muscles Worked',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ex.secondaryMuscles.map((muscle) {
                            return Chip(
                              label: Text(_formatEnum(muscle.name)),
                              backgroundColor: colors.secondaryContainer.withOpacity(0.5),
                              labelStyle: TextStyle(color: colors.onSecondaryContainer, fontWeight: FontWeight.w600),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),

                  // Tab 2: Instructions
                  ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: ex.instructions.length,
                    itemBuilder: (context, idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                ex.instructions[idx],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.4,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
