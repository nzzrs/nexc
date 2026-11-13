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

import '../../l10n/app_localizations.dart';
import '../../features/workout/barbell_calculator_sheet.dart';
import '../db/enums.dart';
import '../db/relations.dart';
import '../l10n/l10n.dart';
import '../providers/settings_provider.dart';
import '../theme/iconography.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../util/input_sheet_state.dart';
import '../util/unit_system.dart';
import 'input_modal_bottom_sheet.dart';
import 'nexc_confirm_sheet.dart';

/// Localized label for a [SetMode] using the existing string keys.
///
/// The l10n bundle has no dedicated set-mode keys, so the label is composed
/// from the localized column names instead of showing the raw enum name.
String localizedSetModeLabel(BuildContext context, SetMode mode) {
  final l10n = context.l10n;
  switch (mode) {
    case SetMode.LOAD:
      return l10n.weightColumn;
    case SetMode.BODYWEIGHT:
      return l10n.bodyWeightWithUnit(l10n.unitKg);
    case SetMode.BODYWEIGHT_WITH_LOAD:
      return '${l10n.bodyWeightWithUnit(l10n.unitKg)} + ${l10n.weightColumn}';
    case SetMode.DURATION:
      return l10n.durationLabel;
    case SetMode.DURATION_WITH_LOAD:
      return '${l10n.durationLabel} + ${l10n.weightColumn}';
  }
}

class ExerciseCard extends ConsumerStatefulWidget {
  const ExerciseCard({
    super.key,
    required this.index,
    required this.exerciseWithSets,
    this.previousPerformances,
    this.idSetWithRunningStopwatch,
    this.workout = false,
    required this.addSet,
    required this.onDetail,
    required this.onDelete,
    required this.deleteSet,
    required this.updateExerciseNotes,
    required this.updateExerciseRestTime,
    required this.updateExerciseSetMode,
    required this.updateSetTime,
    required this.updateSetReps,
    required this.updateSetLoad,
    required this.updateSetCompleted,
    this.showInfo,
    this.showRpe = false,
    this.intensityScale = IntensityScale.rpe,
    this.updateSetRpe,
    this.updateSetRir,
    this.updateIdSetWithRunningStopwatch,
    this.applyPreviousSetPerformance,
    this.onSupersetToggle,
    this.onReplace,
    this.onMachineBusy,
    this.supersetLabel,
    this.supersetColor,
    this.isReordering = false,
  });

  final int index;
  final ExerciseWithSets exerciseWithSets;
  final List<dynamic>? previousPerformances;
  final int? idSetWithRunningStopwatch;
  final bool workout;
  final Function(int) addSet;
  final Function(int, String) onDetail;
  final Function(int) onDelete;
  final Function(int) deleteSet;
  final Function(String, int) updateExerciseNotes;
  final Function(int, int) updateExerciseRestTime;
  final Function(SetMode, int) updateExerciseSetMode;
  final Function(int, int) updateSetTime;
  final Function(int, int) updateSetReps;
  final Function(double, int) updateSetLoad;
  final Function(bool, int) updateSetCompleted;

  /// Retained for source compatibility with older call sites; the card now
  /// surfaces information inline and no longer opens a generic info dialog.
  final Function(String)? showInfo;

  final bool showRpe;
  final IntensityScale intensityScale;
  final Function(String, int)? updateSetRpe;
  final Function(String, int)? updateSetRir;
  final Function(int)? updateIdSetWithRunningStopwatch;
  final Function(int)? applyPreviousSetPerformance;
  final Function(int)? onSupersetToggle;
  final Function(int)? onReplace;
  final Function(int)? onMachineBusy;
  final String? supersetLabel;
  final Color? supersetColor;
  final bool isReordering;

  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  bool _isNotesExpanded = false;
  late TextEditingController _notesController;
  late TextEditingController _restTimeController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.exerciseWithSets.exercise.notes,
    );
    _restTimeController = TextEditingController(
      text: widget.exerciseWithSets.exercise.restTime.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseWithSets.exercise.notes !=
        widget.exerciseWithSets.exercise.notes) {
      _notesController.text = widget.exerciseWithSets.exercise.notes;
    }
    if (oldWidget.exerciseWithSets.exercise.restTime !=
        widget.exerciseWithSets.exercise.restTime) {
      _restTimeController.text = widget.exerciseWithSets.exercise.restTime
          .toString();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _restTimeController.dispose();
    super.dispose();
  }

  /// Set modes whose rows carry a barbell load.
  static bool _setModeCarriesLoad(SetMode mode) {
    return mode == SetMode.LOAD ||
        mode == SetMode.BODYWEIGHT_WITH_LOAD ||
        mode == SetMode.DURATION_WITH_LOAD;
  }

  /// Load of the exercise's last set in kilograms, or zero when unset.
  double _lastSetLoadKg() {
    final List<WorkoutSet> sets = widget.exerciseWithSets.sets;
    if (sets.isEmpty) return 0.0;
    return sets.last.load;
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: l10n.delete,
      message: widget.exerciseWithSets.exerciseDC.name,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed == true && mounted) {
      widget.onDelete(widget.exerciseWithSets.exercise.id);
    }
  }

  void _submitRestTime() {
    final int parsed =
        int.tryParse(_restTimeController.text) ??
        widget.exerciseWithSets.exercise.restTime;
    widget.updateExerciseRestTime(parsed, widget.exerciseWithSets.exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final Exercise ex = widget.exerciseWithSets.exercise;
    final ExerciseDataDC dc = widget.exerciseWithSets.exerciseDC;
    final List<WorkoutSet> sets = widget.exerciseWithSets.sets;
    final bool showImages = ref.watch(
      settingsProvider.select((SettingsState s) => s.showExerciseImages),
    );
    final UnitSystem unitSystem = ref.watch(
      settingsProvider.select((SettingsState s) => s.unitSystem),
    );
    final bool useScrollWheelForInput = ref.watch(
      settingsProvider.select((SettingsState s) => s.useScrollWheelForInput),
    );
    final bool dismissScrollWheelInputAutomatically = ref.watch(
      settingsProvider.select(
        (SettingsState s) => s.dismissScrollWheelInputAutomatically,
      ),
    );

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: NexcSpacing.lg),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: NexcShapes.lgRadius,
        side: ex.supersetId != null
            ? BorderSide(
                color: widget.supersetColor ?? theme.colorScheme.primary,
                width: 2,
              )
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.supersetLabel != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: _SupersetChip(
                  label: widget.supersetLabel!,
                  color: widget.supersetColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: NexcSpacing.sm),
            ],
            _buildHeader(
              context,
              ex: ex,
              dc: dc,
              showImages: showImages,
              theme: theme,
              l10n: l10n,
            ),
            if (_isNotesExpanded) ...[
              const SizedBox(height: NexcSpacing.sm),
              TextField(
                key: ValueKey<String>('exercise-notes-${ex.id}'),
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  hintText: l10n.addNoteHint,
                ),
                onChanged: (String text) =>
                    widget.updateExerciseNotes(text, ex.id),
              ),
            ],
            if (!widget.isReordering) ...[
              const SizedBox(height: NexcSpacing.sm),
              _buildSettingsRow(context, ex: ex, theme: theme, l10n: l10n),
              const SizedBox(height: NexcSpacing.sm),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: NexcSpacing.sm),
              ...List<Widget>.generate(sets.length, (int idx) {
                final WorkoutSet set = sets[idx];
                return _SetRow(
                  key: ValueKey<int>(set.id),
                  set: set,
                  index: idx,
                  setMode: ex.setMode,
                  unitSystem: unitSystem,
                  useScrollWheelForInput: useScrollWheelForInput,
                  dismissScrollWheelInputAutomatically:
                      dismissScrollWheelInputAutomatically,
                  workout: widget.workout,
                  previousSet: _previousSetAt(idx),
                  onApplyPrevious: widget.applyPreviousSetPerformance == null
                      ? null
                      : () => widget.applyPreviousSetPerformance!(set.id),
                  showRpe: widget.showRpe,
                  intensityScale: widget.intensityScale,
                  isThisRunning: widget.idSetWithRunningStopwatch == set.id,
                  updateSetTime: widget.updateSetTime,
                  updateSetLoad: widget.updateSetLoad,
                  updateSetReps: widget.updateSetReps,
                  updateSetRpe: widget.updateSetRpe,
                  updateSetRir: widget.updateSetRir,
                  updateSetCompleted: widget.updateSetCompleted,
                  deleteSet: widget.deleteSet,
                  updateIdSetWithRunningStopwatch:
                      widget.updateIdSetWithRunningStopwatch,
                );
              }),
              const SizedBox(height: NexcSpacing.sm),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                  side: BorderSide.none,
                ),
                onPressed: () => widget.addSet(ex.id),
                icon: const Icon(NexcIcons.add, size: 18),
                label: Text(l10n.addSet),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Previous set matching the row index, when one was recorded.
  WorkoutSet? _previousSetAt(int index) {
    final List<dynamic>? previous = widget.previousPerformances;
    if (previous == null || index >= previous.length) return null;
    final dynamic candidate = previous[index];
    return candidate is WorkoutSet ? candidate : null;
  }

  Widget _buildHeader(
    BuildContext context, {
    required Exercise ex,
    required ExerciseDataDC dc,
    required bool showImages,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
    final String notes = ex.notes.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReorderableDragStartListener(
          index: widget.index,
          child: Padding(
            padding: const EdgeInsets.only(top: NexcSpacing.sm),
            child: Icon(
              NexcIcons.drag,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: NexcSpacing.sm),
        GestureDetector(
          onTap: () => widget.onDetail(ex.id, dc.id),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: NexcShapes.smRadius,
            ),
            child: ClipRRect(
              borderRadius: NexcShapes.smRadius,
              child: showImages && dc.images.isNotEmpty
                  ? Image.asset(
                      'assets/exercise_images/${dc.images.first.replaceAll('/', '_')}',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stack,
                          ) => Icon(
                            NexcIcons.workout,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                    )
                  : Icon(
                      NexcIcons.workout,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
        const SizedBox(width: NexcSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dc.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (notes.isNotEmpty && !_isNotesExpanded)
                Text(
                  notes,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (_setModeCarriesLoad(ex.setMode))
          IconButton(
            tooltip: l10n.plateCalculator,
            icon: const Icon(Icons.calculate, size: 20),
            onPressed: () => showBarbellCalculatorSheet(
              context,
              initialTargetWeightKg: _lastSetLoadKg(),
            ),
          ),
        IconButton(
          tooltip: l10n.notes,
          icon: Icon(
            _isNotesExpanded ? NexcIcons.expand : NexcIcons.notes,
            size: 20,
          ),
          onPressed: () {
            setState(() => _isNotesExpanded = !_isNotesExpanded);
          },
        ),
        PopupMenuButton<String>(
          tooltip: l10n.moreOptions,
          icon: const Icon(NexcIcons.more, size: 20),
          onSelected: (String value) {
            switch (value) {
              case 'superset':
                widget.onSupersetToggle?.call(ex.id);
                break;
              case 'replace':
                widget.onReplace?.call(ex.id);
                break;
              case 'machine_busy':
                widget.onMachineBusy?.call(ex.id);
                break;
              case 'delete':
                _confirmDelete();
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            if (widget.index > 0 || ex.supersetId != null)
              PopupMenuItem<String>(
                value: 'superset',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    ex.supersetId != null ? Icons.link_off : Icons.link,
                  ),
                  title: Text(
                    ex.supersetId != null
                        ? l10n.unlinkSuperset
                        : l10n.linkSuperset,
                  ),
                ),
              ),
            PopupMenuItem<String>(
              value: 'replace',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.swap_horiz),
                title: Text(l10n.replaceExercise),
              ),
            ),
            PopupMenuItem<String>(
              value: 'machine_busy',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: Text(l10n.machineBusy),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(NexcIcons.delete, color: theme.colorScheme.error),
                title: Text(
                  l10n.delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required Exercise ex,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
    return Wrap(
      spacing: NexcSpacing.sm,
      runSpacing: NexcSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.restTimeLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: NexcSpacing.xs),
            SizedBox(
              width: 64,
              child: TextFormField(
                controller: _restTimeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: NexcSpacing.xs,
                    vertical: NexcSpacing.sm,
                  ),
                  suffixText: 's',
                ),
                onFieldSubmitted: (_) => _submitRestTime(),
                onTapOutside: (_) {
                  _submitRestTime();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.type,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: NexcSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 168),
              child: DropdownButton<SetMode>(
                value: ex.setMode,
                underline: const SizedBox.shrink(),
                isDense: true,
                isExpanded: true,
                borderRadius: NexcShapes.smRadius,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                selectedItemBuilder: (BuildContext context) => SetMode.values
                    .map(
                      (SetMode mode) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          localizedSetModeLabel(context, mode),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (SetMode? mode) {
                  if (mode != null) widget.updateExerciseSetMode(mode, ex.id);
                },
                items: SetMode.values
                    .map(
                      (SetMode mode) => DropdownMenuItem<SetMode>(
                        value: mode,
                        child: Text(
                          localizedSetModeLabel(context, mode),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SupersetChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SupersetChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NexcSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: NexcShapes.xsRadius,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final WorkoutSet set;
  final int index;
  final SetMode setMode;
  final UnitSystem unitSystem;
  final bool useScrollWheelForInput;
  final bool dismissScrollWheelInputAutomatically;
  final bool workout;
  final WorkoutSet? previousSet;
  final VoidCallback? onApplyPrevious;
  final bool showRpe;
  final IntensityScale intensityScale;
  final bool isThisRunning;
  final Function(int, int) updateSetTime;
  final Function(double, int) updateSetLoad;
  final Function(int, int) updateSetReps;
  final Function(String, int)? updateSetRpe;
  final Function(String, int)? updateSetRir;
  final Function(bool, int) updateSetCompleted;
  final Function(int) deleteSet;
  final Function(int)? updateIdSetWithRunningStopwatch;

  const _SetRow({
    super.key,
    required this.set,
    required this.index,
    required this.setMode,
    required this.unitSystem,
    required this.useScrollWheelForInput,
    required this.dismissScrollWheelInputAutomatically,
    required this.workout,
    this.previousSet,
    this.onApplyPrevious,
    required this.showRpe,
    required this.intensityScale,
    required this.isThisRunning,
    required this.updateSetTime,
    required this.updateSetLoad,
    required this.updateSetReps,
    this.updateSetRpe,
    this.updateSetRir,
    required this.updateSetCompleted,
    required this.deleteSet,
    this.updateIdSetWithRunningStopwatch,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _loadController;
  late TextEditingController _repsController;
  late TextEditingController _timeController;
  late TextEditingController _rpeController;
  late TextEditingController _rirController;

  /// Formats a stored kilogram load for the user's unit system.
  String _formatLoad(double load) {
    return load == 0.0 ? '' : formatWeight(load, widget.unitSystem);
  }

  @override
  void initState() {
    super.initState();
    _loadController = TextEditingController(text: _formatLoad(widget.set.load));
    _repsController = TextEditingController(
      text: widget.set.reps == 0 ? '' : widget.set.reps.toString(),
    );
    _timeController = TextEditingController(
      text: _formatDuration(widget.set.elapsedTime),
    );
    _rpeController = TextEditingController(text: _formatRpe(widget.set.rpe));
    _rirController = TextEditingController(
      text: widget.set.rir == null ? '' : widget.set.rir.toString(),
    );
  }

  String _formatRpe(double? value) {
    if (value == null) return '';
    return value.toString().replaceAll(RegExp(r'\.0$'), '');
  }

  @override
  void didUpdateWidget(covariant _SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The field shows the user's unit system while the stored load stays in
    // kilograms. Compare in kilograms with a tolerance of one hundredth of
    // the displayed unit so rounding does not rewrite text while typing.
    final bool unitChanged = oldWidget.unitSystem != widget.unitSystem;
    final double? currentLoad = parseWeight(
      _loadController.text,
      widget.unitSystem,
    );
    final double toleranceKg = toKilograms(0.01, widget.unitSystem);
    final bool loadInSync =
        currentLoad != null &&
        (currentLoad - widget.set.load).abs() <= toleranceKg;
    if (unitChanged || !loadInSync) {
      _loadController.text = _formatLoad(widget.set.load);
    }
    final int? currentReps = int.tryParse(_repsController.text);
    if (widget.set.reps != currentReps) {
      _repsController.text = widget.set.reps == 0
          ? ''
          : widget.set.reps.toString();
    }
    if (oldWidget.set.elapsedTime != widget.set.elapsedTime) {
      _timeController.text = _formatDuration(widget.set.elapsedTime);
    }
    if (oldWidget.set.rpe != widget.set.rpe) {
      _rpeController.text = _formatRpe(widget.set.rpe);
    }
    if (oldWidget.set.rir != widget.set.rir) {
      _rirController.text = widget.set.rir == null
          ? ''
          : widget.set.rir.toString();
    }
  }

  @override
  void dispose() {
    _loadController.dispose();
    _repsController.dispose();
    _timeController.dispose();
    _rpeController.dispose();
    _rirController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final String remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  int _parseDuration(String value) {
    final List<String> parts = value.split(':');
    if (parts.length == 2) {
      final int minutes = int.tryParse(parts[0]) ?? 0;
      final int seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
    return int.tryParse(value) ?? 0;
  }

  Future<void> _editLoad() async {
    final num? result = await showInputModalBottomSheet(
      context,
      state: InputSheetState.load(
        kilograms: widget.set.load,
        unitSystem: widget.unitSystem,
      ),
      dismissAutomatically: widget.dismissScrollWheelInputAutomatically,
    );
    if (result != null) {
      widget.updateSetLoad(result.toDouble(), widget.set.id);
    }
  }

  Future<void> _editReps() async {
    final num? result = await showInputModalBottomSheet(
      context,
      state: InputSheetState.reps(reps: widget.set.reps),
      dismissAutomatically: widget.dismissScrollWheelInputAutomatically,
    );
    if (result != null) {
      widget.updateSetReps(result.toInt(), widget.set.id);
    }
  }

  Future<void> _editTime() async {
    final num? result = await showInputModalBottomSheet(
      context,
      state: InputSheetState.time(seconds: widget.set.elapsedTime),
      dismissAutomatically: widget.dismissScrollWheelInputAutomatically,
    );
    if (result != null) {
      widget.updateSetTime(result.toInt(), widget.set.id);
    }
  }

  Future<bool> _confirmDismiss(DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) return false;
    final l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: l10n.delete,
      message: l10n.setNumber(widget.index + 1),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final WorkoutSet set = widget.set;
    final Color contentColor = set.completed
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return Dismissible(
      key: ValueKey<int>(set.id),
      direction: DismissDirection.endToStart,
      dismissThresholds: const <DismissDirection, double>{
        DismissDirection.endToStart: 0.75,
      },
      confirmDismiss: _confirmDismiss,
      background: _deleteBackground(theme, Alignment.centerLeft),
      secondaryBackground: _deleteBackground(theme, Alignment.centerRight),
      onDismissed: (DismissDirection direction) => widget.deleteSet(set.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: NexcSpacing.xs),
        padding: const EdgeInsets.symmetric(
          vertical: NexcSpacing.sm,
          horizontal: NexcSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: set.completed
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: NexcShapes.mdRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SetIndex(number: widget.index + 1, completed: set.completed),
                const SizedBox(width: NexcSpacing.sm),
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final List<Widget> fields = _buildFields(
                            context,
                            theme: theme,
                            l10n: l10n,
                            contentColor: contentColor,
                          );
                          return _fieldWrap(constraints.maxWidth, fields);
                        },
                  ),
                ),
                if (widget.workout) ...[
                  const SizedBox(width: NexcSpacing.xs),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Checkbox(
                      key: ValueKey<String>('set-done-${set.id}'),
                      value: set.completed,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (bool? value) {
                        if (value != null) {
                          widget.updateSetCompleted(value, set.id);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
            if (widget.previousSet != null) ...[
              const SizedBox(height: NexcSpacing.xs),
              _PreviousPerformance(
                label: _previousLabel(context),
                onApply: widget.onApplyPrevious,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _deleteBackground(ThemeData theme, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: NexcShapes.mdRadius,
      ),
      child: Icon(NexcIcons.delete, color: theme.colorScheme.onErrorContainer),
    );
  }

  /// Fields wrap instead of sharing a fixed six-column row, so a 360dp phone
  /// with 1.3 text scale never has to squeeze or overflow them.
  Widget _fieldWrap(double maxWidth, List<Widget> fields) {
    if (fields.isEmpty) return const SizedBox.shrink();
    const double gap = NexcSpacing.sm;
    final bool canUseTwoColumns = maxWidth >= 2 * 72 + gap;
    final double rawWidth = canUseTwoColumns ? (maxWidth - gap) / 2 : maxWidth;
    final double fieldWidth = rawWidth.clamp(72.0, 148.0);
    return Wrap(
      spacing: gap,
      runSpacing: NexcSpacing.xs,
      children: [
        for (final Widget field in fields)
          SizedBox(width: fieldWidth, child: field),
      ],
    );
  }

  List<Widget> _buildFields(
    BuildContext context, {
    required ThemeData theme,
    required AppLocalizations l10n,
    required Color contentColor,
  }) {
    final List<Widget> fields = <Widget>[];
    final InputDecoration decoration = InputDecoration(
      isDense: true,
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    );
    final TextStyle style =
        theme.textTheme.titleSmall?.copyWith(
          color: contentColor,
          fontWeight: FontWeight.w700,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ) ??
        TextStyle(color: contentColor);

    Widget numberField({
      required TextEditingController controller,
      required String label,
      required ValueChanged<String> onChanged,
      String? suffix,
      TextInputType? keyboardType,
      Key? wheelKey,
      VoidCallback? onWheelTap,
      ValueChanged<String>? onSubmitted,
    }) {
      final Widget field = TextField(
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        controller: controller,
        style: style,
        decoration: decoration.copyWith(
          suffixText: suffix,
          suffixStyle: theme.textTheme.labelSmall?.copyWith(
            color: contentColor.withValues(alpha: 0.7),
          ),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      );
      final bool wheelEnabled =
          widget.useScrollWheelForInput &&
          wheelKey != null &&
          onWheelTap != null;
      return _SetInputField(
        label: label,
        child: !wheelEnabled
            ? field
            : GestureDetector(
                key: wheelKey,
                behavior: HitTestBehavior.opaque,
                onTap: onWheelTap,
                child: IgnorePointer(child: field),
              ),
      );
    }

    if (widget.setMode == SetMode.DURATION) {
      fields.add(
        numberField(
          controller: _timeController,
          label: l10n.timeColumn,
          keyboardType: TextInputType.datetime,
          wheelKey: ValueKey<String>('time-cell-${widget.set.id}'),
          onWheelTap: _editTime,
          onChanged: (String value) =>
              widget.updateSetTime(_parseDuration(value), widget.set.id),
          onSubmitted: (String value) =>
              widget.updateSetTime(_parseDuration(value), widget.set.id),
        ),
      );
      if (widget.workout) fields.add(_stopwatchButton(context, l10n));
    } else if (widget.setMode == SetMode.DURATION_WITH_LOAD) {
      fields.add(
        numberField(
          controller: _loadController,
          label: l10n.weightColumn,
          suffix: widget.unitSystem.suffix,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          wheelKey: ValueKey<String>('load-cell-${widget.set.id}'),
          onWheelTap: _editLoad,
          onChanged: (String value) => widget.updateSetLoad(
            parseWeight(value, widget.unitSystem) ?? 0.0,
            widget.set.id,
          ),
        ),
      );
      fields.add(
        numberField(
          controller: _timeController,
          label: l10n.timeColumn,
          keyboardType: TextInputType.datetime,
          wheelKey: ValueKey<String>('time-cell-${widget.set.id}'),
          onWheelTap: _editTime,
          onChanged: (String value) =>
              widget.updateSetTime(_parseDuration(value), widget.set.id),
        ),
      );
      if (widget.workout) fields.add(_stopwatchButton(context, l10n));
    } else {
      if (widget.setMode == SetMode.LOAD ||
          widget.setMode == SetMode.BODYWEIGHT_WITH_LOAD) {
        fields.add(
          numberField(
            controller: _loadController,
            label: l10n.weightColumn,
            suffix: widget.unitSystem.suffix,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            wheelKey: ValueKey<String>('load-cell-${widget.set.id}'),
            onWheelTap: _editLoad,
            onChanged: (String value) => widget.updateSetLoad(
              parseWeight(value, widget.unitSystem) ?? 0.0,
              widget.set.id,
            ),
          ),
        );
      }
      fields.add(
        numberField(
          controller: _repsController,
          label: l10n.repsColumn,
          keyboardType: TextInputType.number,
          wheelKey: ValueKey<String>('reps-cell-${widget.set.id}'),
          onWheelTap: _editReps,
          onChanged: (String value) =>
              widget.updateSetReps(int.tryParse(value) ?? 0, widget.set.id),
        ),
      );
    }

    if (widget.showRpe) {
      final bool showRpeValue =
          widget.intensityScale == IntensityScale.rpe ||
          widget.intensityScale == IntensityScale.both;
      final bool showRirValue =
          widget.intensityScale == IntensityScale.rir ||
          widget.intensityScale == IntensityScale.both;
      if (showRpeValue) {
        fields.add(
          numberField(
            controller: _rpeController,
            label: l10n.rpe,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (String value) =>
                widget.updateSetRpe?.call(value, widget.set.id),
          ),
        );
      }
      if (showRirValue) {
        fields.add(
          numberField(
            controller: _rirController,
            label: l10n.rir,
            keyboardType: TextInputType.number,
            onChanged: (String value) =>
                widget.updateSetRir?.call(value, widget.set.id),
          ),
        );
      }
    }
    return fields;
  }

  Widget _stopwatchButton(BuildContext context, AppLocalizations l10n) {
    return IconButton.filledTonal(
      tooltip: l10n.timeColumn,
      onPressed: () {
        widget.updateIdSetWithRunningStopwatch?.call(
          widget.isThisRunning ? 0 : widget.set.id,
        );
      },
      icon: Icon(widget.isThisRunning ? Icons.pause : NexcIcons.play, size: 18),
    );
  }

  String _previousLabel(BuildContext context) {
    final WorkoutSet previous = widget.previousSet!;
    final String value;
    switch (widget.setMode) {
      case SetMode.DURATION:
        value = _formatDuration(previous.elapsedTime);
        break;
      case SetMode.DURATION_WITH_LOAD:
        value =
            '${formatWeight(previous.load, widget.unitSystem)} × '
            '${_formatDuration(previous.elapsedTime)}';
        break;
      default:
        value =
            '${formatWeight(previous.load, widget.unitSystem)} × '
            '${previous.reps}';
    }
    return '${context.l10n.previousColumn}: $value';
  }
}

class _SetInputField extends StatelessWidget {
  final String label;
  final Widget child;

  const _SetInputField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NexcSpacing.sm,
        vertical: NexcSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: NexcShapes.xsRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SetIndex extends StatelessWidget {
  final int number;
  final bool completed;

  const _SetIndex({required this.number, required this.completed});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: completed
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelMedium?.copyWith(
          color: completed
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PreviousPerformance extends StatelessWidget {
  final String label;
  final VoidCallback? onApply;

  const _PreviousPerformance({required this.label, this.onApply});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    if (onApply == null) {
      return Text(label, style: style);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.xs),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onApply,
        icon: const Icon(NexcIcons.check, size: 14),
        label: Text(label, style: style),
      ),
    );
  }
}
