/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/dataset_repository.dart';
import '../../core/db/enums.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../l10n/app_localizations.dart';

class InfoExerciseScreen extends ConsumerStatefulWidget {
  final String exerciseId;

  const InfoExerciseScreen({super.key, required this.exerciseId});

  @override
  ConsumerState<InfoExerciseScreen> createState() => _InfoExerciseScreenState();
}

class _InfoExerciseScreenState extends ConsumerState<InfoExerciseScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  ExerciseDataDC? _exercise;
  int _currentImageIndex = 0;
  late final PageController _pageController = PageController();
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  Future<void> _loadExercise() async {
    final DatasetRepository repo = ref.read(datasetRepositoryProvider);
    final ExerciseDataDC? data = await repo.getExerciseFromId(
      widget.exerciseId,
    );
    if (data == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    setState(() {
      _exercise = data;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _humanize(String value) {
    return value
        .split('_')
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  IconData _equipmentIcon(Equipment? equipment) {
    switch (equipment) {
      case Equipment.BARBELL:
      case Equipment.E_Z_CURL_BAR:
        return NexcIcons.workout;
      case Equipment.DUMBBELL:
      case Equipment.KETTLEBELLS:
        return NexcIcons.workoutIdle;
      case Equipment.CABLE:
        return NexcIcons.units;
      case Equipment.MACHINE:
        return NexcIcons.settings;
      case Equipment.BANDS:
        return NexcIcons.expand;
      case Equipment.BODY_ONLY:
        return NexcIcons.profile;
      case Equipment.MEDICINE_BALL:
      case Equipment.EXERCISE_BALL:
        return NexcIcons.streak;
      case Equipment.FOAM_ROLL:
        return NexcIcons.exercises;
      case Equipment.PULL_UP_BAR:
      case Equipment.RINGS:
        return NexcIcons.workout;
      case Equipment.OTHER:
      case null:
        return NexcIcons.workoutIdle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final ColorScheme colors = theme.colorScheme;
    final bool showImages = ref.watch(
      settingsProvider.select((SettingsState s) => s.showExerciseImages),
    );

    if (_isLoading || _exercise == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ExerciseDataDC ex = _exercise!;
    final bool hasImages = showImages && ex.images.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exerciseDetails)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NexcSpacing.lg,
              NexcSpacing.sm,
              NexcSpacing.lg,
              0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: NexcShapes.lgRadius,
                  ),
                  child: hasImages
                      ? Stack(
                          children: <Widget>[
                            PageView.builder(
                              controller: _pageController,
                              itemCount: ex.images.length,
                              onPageChanged: (int index) {
                                setState(() => _currentImageIndex = index);
                              },
                              itemBuilder: (BuildContext context, int index) {
                                return ClipRRect(
                                  borderRadius: NexcShapes.lgRadius,
                                  child: Image.asset(
                                    'assets/exercise_images/'
                                    '${ex.images[index].replaceAll('/', '_')}',
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (
                                          BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace,
                                        ) => Center(
                                          child: Icon(
                                            NexcIcons.workout,
                                            size: 64,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),
                            if (ex.images.length > 1)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: NexcSpacing.sm,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List<Widget>.generate(
                                    ex.images.length,
                                    (int index) {
                                      final bool selected =
                                          _currentImageIndex == index;
                                      return Semantics(
                                        button: true,
                                        selected: selected,
                                        label: '${index + 1}',
                                        child: GestureDetector(
                                          onTap: () {
                                            _pageController.animateToPage(
                                              index,
                                              duration:
                                                  MediaQuery.maybeOf(
                                                        context,
                                                      )?.disableAnimations ??
                                                      false
                                                  ? Duration.zero
                                                  : NexcMotion.short,
                                              curve: NexcMotion.standard,
                                            );
                                          },
                                          child: AnimatedContainer(
                                            duration:
                                                MediaQuery.maybeOf(
                                                      context,
                                                    )?.disableAnimations ??
                                                    false
                                                ? Duration.zero
                                                : NexcMotion.short,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                            width: selected ? 16 : 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? colors.primary
                                                  : colors.onSurfaceVariant
                                                        .withValues(alpha: 0.4),
                                              borderRadius:
                                                  NexcShapes.fullRadius,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Center(
                          child: Icon(
                            NexcIcons.workout,
                            size: 64,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NexcSpacing.lg,
              vertical: NexcSpacing.md,
            ),
            child: Text(
              ex.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Material(
            color: colors.surfaceContainerLow,
            child: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(icon: const Icon(NexcIcons.about), text: l10n.detailsTab),
                Tab(
                  icon: const Icon(NexcIcons.notes),
                  text: l10n.instructionsTab,
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                ListView(
                  padding: const EdgeInsets.all(NexcSpacing.lg),
                  children: <Widget>[
                    _DetailChip(
                      label: l10n.categoryLabel,
                      value: l10n.categoryWithValue(
                        _humanize(ex.category.name),
                      ),
                      icon: NexcIcons.filter,
                    ),
                    const SizedBox(height: NexcSpacing.sm),
                    _DetailChip(
                      label: l10n.equipmentLabel,
                      value: ex.equipment == null
                          ? l10n.noEquipment
                          : l10n.equipmentWithValue(
                              _humanize(ex.equipment!.name),
                            ),
                      icon: _equipmentIcon(ex.equipment),
                    ),
                    const SizedBox(height: NexcSpacing.sm),
                    _DetailChip(
                      label: l10n.levelLabel,
                      value: l10n.levelWithValue(_humanize(ex.level.name)),
                      icon: NexcIcons.intensity,
                    ),
                    const SizedBox(height: NexcSpacing.sm),
                    _DetailChip(
                      label: l10n.forceLabel,
                      value: ex.force == null
                          ? '—'
                          : l10n.forceWithValue(_humanize(ex.force!.name)),
                      icon: NexcIcons.streak,
                    ),
                    const SizedBox(height: NexcSpacing.sm),
                    _DetailChip(
                      label: l10n.mechanicLabel,
                      value: ex.mechanic == null
                          ? '—'
                          : l10n.mechanicWithValue(
                              _humanize(ex.mechanic!.name),
                            ),
                      icon: NexcIcons.exercises,
                    ),
                    if (ex.primaryMuscles.isNotEmpty) ...<Widget>[
                      const SizedBox(height: NexcSpacing.xl),
                      Text(
                        l10n.primaryMusclesWorked,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: NexcSpacing.sm),
                      _MuscleChips(
                        muscles: ex.primaryMuscles,
                        background: colors.secondaryContainer,
                        foreground: colors.onSecondaryContainer,
                      ),
                    ],
                    if (ex.secondaryMuscles.isNotEmpty) ...<Widget>[
                      const SizedBox(height: NexcSpacing.xl),
                      Text(
                        l10n.secondaryMusclesWorked,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: NexcSpacing.sm),
                      _MuscleChips(
                        muscles: ex.secondaryMuscles,
                        background: colors.surfaceContainerHighest,
                        foreground: colors.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(NexcSpacing.lg),
                  itemCount: ex.instructions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: NexcSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: NexcSpacing.md),
                          Expanded(
                            child: Text(
                              ex.instructions[index],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
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
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NexcSpacing.lg,
        vertical: NexcSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: NexcShapes.mdRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: NexcSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleChips extends StatelessWidget {
  final List<Muscle> muscles;
  final Color background;
  final Color foreground;

  const _MuscleChips({
    required this.muscles,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Wrap(
      spacing: NexcSpacing.sm,
      runSpacing: NexcSpacing.sm,
      children: <Widget>[
        for (final Muscle muscle in muscles)
          Chip(
            backgroundColor: background,
            labelStyle: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: foreground),
            label: Text(
              l10n.muscleWithValue(
                muscle.name
                    .split('_')
                    .where((String part) => part.isNotEmpty)
                    .map(
                      (String part) =>
                          part[0].toUpperCase() +
                          part.substring(1).toLowerCase(),
                    )
                    .join(' '),
              ),
            ),
          ),
      ],
    );
  }
}
