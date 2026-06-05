/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/enums.dart';
import '../db/relations.dart';
import '../db/app_database.dart';

class ExerciseCard extends StatefulWidget {
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
    required this.showInfo,
    this.showRpe = false,
    this.intensityScale = IntensityScale.rpe,
    this.updateSetRpe,
    this.updateSetRir,
    this.updateIdSetWithRunningStopwatch,
    this.applyPreviousSetPerformance,
    this.onSupersetToggle,
    this.onReplace,
    this.onMoveUp,
    this.onMoveDown,
    this.isFirst = false,
    this.isLast = false,
    this.supersetLabel,
    this.supersetColor,
    this.isReordering = false,
  });

  final int index;
  final ExerciseWithSets exerciseWithSets;
  final List<dynamic>? previousPerformances; // Matches Compose previous performances
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
  final Function(String) showInfo;
  final bool showRpe;
  final IntensityScale intensityScale;
  final Function(String, int)? updateSetRpe;
  final Function(String, int)? updateSetRir;
  final Function(int)? updateIdSetWithRunningStopwatch;
  final Function(int)? applyPreviousSetPerformance;
  final Function(int)? onSupersetToggle;
  final Function(int)? onReplace;
  final Function(int)? onMoveUp;
  final Function(int)? onMoveDown;
  final bool isFirst;
  final bool isLast;
  final String? supersetLabel;
  final Color? supersetColor;
  final bool isReordering;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _showSlider = false;
  bool _isNotesExpanded = false;
  late TextEditingController _notesController;
  late TextEditingController _restTimeController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.exerciseWithSets.exercise.notes);
    _restTimeController = TextEditingController(text: widget.exerciseWithSets.exercise.restTime.toString());
  }

  @override
  void didUpdateWidget(covariant ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseWithSets.exercise.notes != widget.exerciseWithSets.exercise.notes) {
      _notesController.text = widget.exerciseWithSets.exercise.notes;
    }
    if (oldWidget.exerciseWithSets.exercise.restTime != widget.exerciseWithSets.exercise.restTime) {
      _restTimeController.text = widget.exerciseWithSets.exercise.restTime.toString();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _restTimeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ex = widget.exerciseWithSets.exercise;
    final dc = widget.exerciseWithSets.exerciseDC;
    final sets = widget.exerciseWithSets.sets;

    return Card(
      color: theme.colorScheme.surfaceVariant,
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: ex.supersetId != null
            ? BorderSide(color: widget.supersetColor ?? theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.supersetLabel != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                widget.supersetLabel!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: widget.supersetColor ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: Icon(
                    Icons.drag_handle,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onDetail(ex.id, dc.id),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: dc.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/exercise_images/${dc.images.first.replaceAll('/', '_')}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.fitness_center,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.fitness_center,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dc.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Options menu button
                 PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'superset':
                        widget.onSupersetToggle?.call(ex.id);
                        break;
                      case 'replace':
                        widget.onReplace?.call(ex.id);
                        break;
                      case 'delete':
                        widget.onDelete(ex.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (widget.index > 0 || ex.supersetId != null)
                      PopupMenuItem(
                        value: 'superset',
                        child: Row(
                          children: [
                            Icon(ex.supersetId != null ? Icons.link_off : Icons.link),
                            const SizedBox(width: 8),
                            Text(ex.supersetId != null ? 'Unlink superset' : 'Link superset'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'replace',
                      child: Row(
                        children: const [
                          Icon(Icons.swap_horiz),
                          const SizedBox(width: 8),
                          Text('Replace exercise'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Notes TextField
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _notesController,
              maxLines: _isNotesExpanded ? null : 1,
              minLines: _isNotesExpanded ? 3 : 1,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isNotesExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isNotesExpanded = !_isNotesExpanded;
                    });
                  },
                ),
              ),
              onChanged: (text) => widget.updateExerciseNotes(text, ex.id),
            ),
          ),
          const SizedBox(height: 12),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: widget.isReordering
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () => widget.showInfo('REST_TIME'),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rest time: ',
                              style: theme.textTheme.bodyMedium,
                            ),
                            SizedBox(
                              width: 60,
                              child: TextFormField(
                                controller: _restTimeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                ),
                                onFieldSubmitted: (val) {
                                  final parsed = int.tryParse(val) ?? ex.restTime;
                                  widget.updateExerciseRestTime(parsed, ex.id);
                                },
                                onTapOutside: (_) {
                                  final parsed = int.tryParse(_restTimeController.text) ?? ex.restTime;
                                  widget.updateExerciseRestTime(parsed, ex.id);
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              's',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => widget.showInfo('TYPE_OF_SET'),
                                    child: const Icon(Icons.info_outline, size: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Type of set',
                                      style: theme.textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DropdownButton<SetMode>(
                              value: ex.setMode,
                              underline: const SizedBox(),
                              onChanged: (mode) {
                                if (mode != null) {
                                  widget.updateExerciseSetMode(mode, ex.id);
                                }
                              },
                              items: SetMode.values.map((mode) {
                                return DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode.name.replaceAll('_', ' ').toUpperCase()),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Sets Table (Header + Rows)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          color: theme.colorScheme.surfaceContainerHighest,
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                ),
                                child: Row(
                                  children: [
                                    if (!widget.workout)
                                      const SizedBox(
                                        width: 30,
                                        child: Text('Set', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    if (widget.previousPerformances != null)
                                      const SizedBox(
                                        width: 70,
                                        child: Text('Previous', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    if (ex.setMode == SetMode.DURATION)
                                      const Expanded(
                                        child: Text('Time', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                      )
                                    else if (ex.setMode == SetMode.DURATION_WITH_LOAD) ...[
                                      const Expanded(
                                        child: Text('Weight', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text('Time', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ] else ...[
                                      if (ex.setMode == SetMode.LOAD || ex.setMode == SetMode.BODYWEIGHT_WITH_LOAD)
                                        const Expanded(
                                          child: Text('Weight', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text('Reps', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    if (widget.showRpe) ...[
                                      const SizedBox(width: 8),
                                      if (widget.intensityScale == IntensityScale.both) ...[
                                        const Expanded(child: Text('RPE', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                        const SizedBox(width: 8),
                                        const Expanded(child: Text('RIR', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                      ] else
                                        Expanded(
                                          child: Text(
                                            widget.intensityScale == IntensityScale.rir ? 'RIR' : 'RPE',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                    if (widget.workout) ...[
                                      const SizedBox(width: 8),
                                      const SizedBox(width: 45, child: Text('Done', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...List.generate(sets.length, (idx) {
                                final set = sets[idx];
                                final isThisRunning = widget.idSetWithRunningStopwatch == set.id;

                                return _SetRow(
                                  key: ValueKey(set.id),
                                  set: set,
                                  index: idx,
                                  setMode: ex.setMode,
                                  workout: widget.workout,
                                  previousPerformances: widget.previousPerformances,
                                  showRpe: widget.showRpe,
                                  intensityScale: widget.intensityScale,
                                  isThisRunning: isThisRunning,
                                  updateSetTime: widget.updateSetTime,
                                  updateSetLoad: widget.updateSetLoad,
                                  updateSetReps: widget.updateSetReps,
                                  updateSetRpe: widget.updateSetRpe,
                                  updateSetRir: widget.updateSetRir,
                                  updateSetCompleted: widget.updateSetCompleted,
                                  deleteSet: widget.deleteSet,
                                  updateIdSetWithRunningStopwatch: widget.updateIdSetWithRunningStopwatch,
                                  applyPreviousSetPerformance: widget.applyPreviousSetPerformance,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Add Set Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            foregroundColor: theme.colorScheme.onSecondaryContainer,
                            elevation: 0,
                          ),
                          onPressed: () => widget.addSet(ex.id),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add set'),
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

class _SetRow extends StatefulWidget {
  final WorkoutSet set;
  final int index;
  final SetMode setMode;
  final bool workout;
  final List<dynamic>? previousPerformances;
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
  final Function(int)? applyPreviousSetPerformance;

  const _SetRow({
    Key? key,
    required this.set,
    required this.index,
    required this.setMode,
    required this.workout,
    this.previousPerformances,
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
    this.applyPreviousSetPerformance,
  }) : super(key: key);

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _loadController;
  late TextEditingController _repsController;
  late TextEditingController _timeController;
  late TextEditingController _rpeController;
  late TextEditingController _rirController;

  @override
  void initState() {
    super.initState();
    _loadController = TextEditingController(text: widget.set.load == 0.0 ? '' : widget.set.load.toString().replaceAll(RegExp(r'\.0$'), ''));
    _repsController = TextEditingController(text: widget.set.reps == 0 ? '' : widget.set.reps.toString());
    _timeController = TextEditingController(text: _formatDuration(widget.set.elapsedTime));
    _rpeController = TextEditingController(text: widget.set.rpe == null ? '' : widget.set.rpe.toString().replaceAll(RegExp(r'\.0$'), ''));
    _rirController = TextEditingController(text: widget.set.rir == null ? '' : widget.set.rir.toString().replaceAll(RegExp(r'\.0$'), ''));
  }

  @override
  void didUpdateWidget(covariant _SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final double? currentLoad = double.tryParse(_loadController.text);
    if (widget.set.load != currentLoad) {
      _loadController.text = widget.set.load == 0.0 ? '' : widget.set.load.toString().replaceAll(RegExp(r'\.0$'), '');
    }
    final int? currentReps = int.tryParse(_repsController.text);
    if (widget.set.reps != currentReps) {
      _repsController.text = widget.set.reps == 0 ? '' : widget.set.reps.toString();
    }
    if (oldWidget.set.elapsedTime != widget.set.elapsedTime) {
      _timeController.text = _formatDuration(widget.set.elapsedTime);
    }
    if (oldWidget.set.rpe != widget.set.rpe) {
      _rpeController.text = widget.set.rpe == null ? '' : widget.set.rpe.toString().replaceAll(RegExp(r'\.0$'), '');
    }
    if (oldWidget.set.rir != widget.set.rir) {
      _rirController.text = widget.set.rir == null ? '' : widget.set.rir.toString().replaceAll(RegExp(r'\.0$'), '');
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
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int _parseDuration(String value) {
    final parts = value.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final s = int.tryParse(parts[1]) ?? 0;
      return m * 60 + s;
    }
    return int.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final set = widget.set;
    return Dismissible(
      key: ValueKey(set.id),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.75,
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (dir) => widget.deleteSet(set.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: set.completed
              ? theme.colorScheme.primaryContainer.withOpacity(0.25)
              : Colors.transparent,
          border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
        ),
        child: Builder(
          builder: (context) {
            final contentColor = set.completed
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface;

            final inputDeco = InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
            );
            final inputStyle = TextStyle(color: contentColor, fontSize: 14, fontWeight: FontWeight.w600);

            Widget buildCell(Widget child) {
              return Expanded(
                child: Container(
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: set.completed
                        ? theme.colorScheme.surface.withOpacity(0.6)
                        : theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: set.completed
                          ? theme.colorScheme.primary.withOpacity(0.3)
                          : theme.colorScheme.outlineVariant.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                  child: child,
                ),
              );
            }

            return Row(
              children: [
                if (!widget.workout)
                  SizedBox(
                    width: 30,
                    child: Text('${widget.index + 1}', textAlign: TextAlign.center, style: TextStyle(color: contentColor, fontWeight: FontWeight.bold)),
                  ),
                if (widget.previousPerformances != null && widget.previousPerformances!.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final prevSets = widget.previousPerformances!;
                      if (widget.index < prevSets.length) {
                        final prevSet = prevSets[widget.index] as WorkoutSet;
                        final String displayVal;
                        if (widget.setMode == SetMode.DURATION) {
                          displayVal = "${prevSet.elapsedTime}s";
                        } else if (widget.setMode == SetMode.DURATION_WITH_LOAD) {
                          displayVal = "${prevSet.load.toString().replaceAll(RegExp(r'\.0$'), '')} - ${prevSet.elapsedTime}s";
                        } else {
                          displayVal = "${prevSet.load.toString().replaceAll(RegExp(r'\.0$'), '')}x${prevSet.reps}";
                        }
                        return SizedBox(
                          width: 70,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => widget.applyPreviousSetPerformance?.call(set.id),
                            child: Text(
                              displayVal,
                              style: TextStyle(fontSize: 11, color: set.completed ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8) : theme.colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(width: 70, child: Text('-', textAlign: TextAlign.center, style: TextStyle(color: contentColor)));
                      }
                    },
                  ),
                ] else if (widget.previousPerformances != null) ...[
                  SizedBox(width: 70, child: Text('-', textAlign: TextAlign.center, style: TextStyle(color: contentColor))),
                ],
                if (widget.setMode == SetMode.DURATION) ...[
                  if (widget.workout)
                    IconButton(
                      icon: Icon(widget.isThisRunning ? Icons.pause : Icons.play_arrow, color: contentColor),
                      onPressed: () {
                        widget.updateIdSetWithRunningStopwatch?.call(widget.isThisRunning ? 0 : set.id);
                      },
                    ),
                  buildCell(
                    TextField(
                      keyboardType: TextInputType.datetime,
                      textAlign: TextAlign.center,
                      controller: _timeController,
                      style: inputStyle,
                      decoration: inputDeco,
                      onSubmitted: (val) {
                        final secs = _parseDuration(val);
                        widget.updateSetTime(secs, set.id);
                      },
                    ),
                  ),
                ] else if (widget.setMode == SetMode.DURATION_WITH_LOAD) ...[
                  buildCell(
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      controller: _loadController,
                      style: inputStyle,
                      decoration: inputDeco,
                      onChanged: (val) {
                        final load = double.tryParse(val) ?? 0.0;
                        widget.updateSetLoad(load, set.id);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.workout)
                    IconButton(
                      icon: Icon(widget.isThisRunning ? Icons.pause : Icons.play_arrow, color: contentColor),
                      onPressed: () {
                        widget.updateIdSetWithRunningStopwatch?.call(widget.isThisRunning ? 0 : set.id);
                      },
                    ),
                  buildCell(
                    TextField(
                      keyboardType: TextInputType.datetime,
                      textAlign: TextAlign.center,
                      controller: _timeController,
                      style: inputStyle,
                      decoration: inputDeco,
                      onSubmitted: (val) {
                        final secs = _parseDuration(val);
                        widget.updateSetTime(secs, set.id);
                      },
                    ),
                  ),
                ] else ...[
                  if (widget.setMode == SetMode.LOAD || widget.setMode == SetMode.BODYWEIGHT_WITH_LOAD)
                    buildCell(
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        controller: _loadController,
                        style: inputStyle,
                        decoration: inputDeco,
                        onChanged: (val) {
                          final load = double.tryParse(val) ?? 0.0;
                          widget.updateSetLoad(load, set.id);
                        },
                      ),
                    ),
                  const SizedBox(width: 8),
                  buildCell(
                    TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      controller: _repsController,
                      style: inputStyle,
                      decoration: inputDeco,
                      onChanged: (val) {
                        final reps = int.tryParse(val) ?? 0;
                        widget.updateSetReps(reps, set.id);
                      },
                    ),
                  ),
                ],
                if (widget.showRpe) ...[
                  const SizedBox(width: 8),
                  if (widget.intensityScale == IntensityScale.both) ...[
                    buildCell(
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        controller: _rpeController,
                        style: inputStyle,
                        decoration: inputDeco,
                        onChanged: (val) => widget.updateSetRpe?.call(val, set.id),
                      ),
                    ),
                    const SizedBox(width: 8),
                    buildCell(
                      TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        controller: _rirController,
                        style: inputStyle,
                        decoration: inputDeco,
                        onChanged: (val) => widget.updateSetRir?.call(val, set.id),
                      ),
                    ),
                  ] else
                    buildCell(
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        controller: widget.intensityScale == IntensityScale.rir ? _rirController : _rpeController,
                        style: inputStyle,
                        decoration: inputDeco,
                        onChanged: (val) {
                          if (widget.intensityScale == IntensityScale.rir) {
                            widget.updateSetRir?.call(val, set.id);
                          } else {
                            widget.updateSetRpe?.call(val, set.id);
                          }
                        },
                      ),
                    ),
                ],
                if (widget.workout) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 45,
                    child: Checkbox(
                      value: set.completed,
                      activeColor: theme.colorScheme.primary,
                      checkColor: theme.colorScheme.onPrimary,
                      onChanged: (val) {
                        if (val != null) {
                          widget.updateSetCompleted(val, set.id);
                        }
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
