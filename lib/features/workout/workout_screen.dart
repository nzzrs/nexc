/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/components/exercise_card.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/components/wavy_progress_indicators.dart';
import '../../core/db/enums.dart';
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/integrations/ai_service.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/workout_providers.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/exercise_set_mode_helper.dart';
import '../../core/util/format.dart';
import '../../core/util/rest_alert_audio.dart';
import '../../l10n/app_localizations.dart';
import '../exercises/exercises_screen.dart';
import 'workout_summary_screen.dart';

/// Asks whether the linked routine should copy the completed set values.
///
/// Returns true for "Update", false for "Don't update" or a dismissed dialog.
Future<bool> showUpdateRoutineDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      final l10n = context.l10n;
      return AlertDialog(
        title: Text(l10n.updateRoutineTitle),
        content: Text(l10n.updateRoutineMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.dontUpdate),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.update),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Superset label and accent color for one exercise in the current list.
class SupersetInfo {
  final String? label;
  final Color? color;

  const SupersetInfo({this.label, this.color});
}

/// Derives the group letter and accent for every exercise from the current
/// order, so the normal list and the drag proxy never disagree.
SupersetInfo supersetInfoFor(
  List<ExerciseWithSets> exercises,
  int index,
  ColorScheme scheme,
) {
  if (index < 0 || index >= exercises.length) {
    return const SupersetInfo();
  }
  final int? groupId = exercises[index].exercise.supersetId;
  if (groupId == null) return const SupersetInfo();
  final List<int> groups = <int>[];
  for (final ExerciseWithSets exercise in exercises) {
    final int? id = exercise.exercise.supersetId;
    if (id != null && !groups.contains(id)) groups.add(id);
  }
  final int groupIndex = groups.indexOf(groupId);
  if (groupIndex < 0) return const SupersetInfo();
  final List<Color> colors = <Color>[
    scheme.primary,
    scheme.tertiary,
    scheme.secondary,
    scheme.error,
    scheme.inversePrimary,
    scheme.onTertiaryContainer,
  ];
  return SupersetInfo(
    label: String.fromCharCode(65 + groupIndex),
    color: colors[groupIndex % colors.length],
  );
}

/// Reports the laid-out height of [child] once per frame it changes.
class MeasuredHeight extends StatefulWidget {
  final Widget child;
  final ValueChanged<double> onHeight;

  const MeasuredHeight({
    super.key,
    required this.child,
    required this.onHeight,
  });

  @override
  State<MeasuredHeight> createState() => _MeasuredHeightState();
}

class _MeasuredHeightState extends State<MeasuredHeight> {
  double _lastHeight = -1;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderObject? renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) return;
      final double height = renderObject.size.height;
      if ((height - _lastHeight).abs() < 0.5) return;
      _lastHeight = height;
      widget.onHeight(height);
    });
    return widget.child;
  }
}

class WorkoutScreen extends ConsumerStatefulWidget {
  final int
  workoutId; // 0 if empty, routineId if starting routine, runningWorkoutId if resuming

  const WorkoutScreen({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  late Workout _workout;
  List<ExerciseWithSets> _exercises = <ExerciseWithSets>[];
  final Map<String, List<WorkoutSet>> _previousPerformances =
      <String, List<WorkoutSet>>{};
  final Set<int> _startedSetIds = <int>{};
  bool _isReordering = false;
  late final ScrollController _scrollController;
  double _headerHeight = 0;
  double _restBarHeight = 0;
  String _emptyWorkoutTitle = 'Workout';

  // Timers
  Timer? _stopwatchTimer;
  int _elapsedSeconds = 0;

  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _initialRestTime = 0;

  int? _idSetWithRunningStopwatch;
  Timer? _setStopwatchTimer;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _emptyWorkoutTitle = context.l10n.tabWorkout;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: ref.read(activeWorkoutScrollOffsetProvider),
    );
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        ref.read(activeWorkoutScrollOffsetProvider.notifier).state =
            _scrollController.offset;
      }
    });
    WidgetsBinding.instance.addObserver(this);
    _loadWorkout();
    _initNotifications();
    unawaited(_configureAudioMixing());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ref.read(settingsProvider).workoutScreenOn) {
        WakelockPlus.enable();
      }
      if (!kIsWeb) {
        await Permission.notification.request();
        _updateWorkoutForegroundService();
      }
    });
  }

  Future<void> _updateWorkoutForegroundService() async {
    if (!mounted) return;
    final l10n = context.l10n;
    final androidDetails = AndroidNotificationDetails(
      'workout_session_channel',
      l10n.activeWorkoutChannel,
      channelDescription: l10n.activeWorkoutChannelDesc,
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false,
      onlyAlertOnce: true,
      ongoing: true,
    );
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.startForegroundService(
            id: 888,
            title: l10n.workoutInProgress,
            body: l10n.durationWithTime(_formatTime(_elapsedSeconds)),
            notificationDetails: androidDetails,
          );
    } catch (_) {
      // Notifications are optional on platforms without the plugin.
    }
  }

  Future<void> _stopWorkoutForegroundService() async {
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.stopForegroundService();
    } catch (_) {
      // Ignore platforms without a foreground service.
    }
  }

  Future<void> _configureAudioMixing() async {
    try {
      await applyRestAlertAudioContext(_audioPlayer);
    } catch (_) {
      // audio configuration failure is non-fatal
    }
  }

  Future<void> _initNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _notificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );
  }

  Future<void> _updateRestNotification(int remaining, int initial) async {
    final l10n = context.l10n;
    final elapsed = initial - remaining;
    final androidDetails = AndroidNotificationDetails(
      'rest_timer_channel',
      l10n.restTimerChannel,
      channelDescription: l10n.restTimerChannelDesc,
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false,
      onlyAlertOnce: true,
      ongoing: true,
      showProgress: true,
      maxProgress: initial,
      progress: elapsed,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: 999,
      title: l10n.resting,
      body: l10n.secondsRemaining(remaining),
      notificationDetails: notificationDetails,
    );
  }

  Future<void> _cancelRestNotification() async {
    await _notificationsPlugin.cancel(id: 999);
  }

  Future<void> _showRestFinishedNotification() async {
    final l10n = context.l10n;
    final androidDetails = AndroidNotificationDetails(
      'rest_timer_channel_finished',
      l10n.restTimerFinishedChannel,
      channelDescription: l10n.restTimerFinishedChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: 999,
      title: l10n.restFinished,
      body: l10n.restFinishedBody,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> _loadWorkout() async {
    final repo = ref.read(workoutRepositoryProvider);

    if (widget.workoutId == 0) {
      ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
      _initNewEmpty();
    } else {
      final potential = await repo.getWorkoutWithExercisesAndSets(
        widget.workoutId,
      );
      if (potential != null) {
        if (potential.workout.state == WorkoutState.RUNNING) {
          _workout = potential.workout;
          _exercises = List<ExerciseWithSets>.from(potential.exercisesWithSets);
          _elapsedSeconds = _workout.timeElapsed;
          _startStopwatch();
        } else if (potential.workout.state == WorkoutState.ROUTINE) {
          ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
          final DateTime now = DateTime.now();
          _workout = Workout(
            id: 0,
            routineId: potential.workout.id,
            notes: potential.workout.notes,
            title: potential.workout.title,
            state: WorkoutState.RUNNING,
            timeElapsed: 0,
            position: 0,
            created: now,
            completed: now,
            isTemporal: potential.workout.isTemporal,
          );
          int tempExId = -1;
          int tempSetId = -1;
          _exercises = potential.exercisesWithSets.map((ExerciseWithSets eWs) {
            final Exercise clonedEx = eWs.exercise.copyWith(
              id: tempExId--,
              workoutId: 0,
            );
            final List<WorkoutSet> clonedSets = eWs.sets
                .map(
                  (WorkoutSet s) => s.copyWith(
                    id: tempSetId--,
                    exerciseId: clonedEx.id,
                    completed: false,
                    elapsedTime: 0,
                  ),
                )
                .toList();
            return ExerciseWithSets(
              exercise: clonedEx,
              exerciseDC: eWs.exerciseDC,
              sets: clonedSets,
            );
          }).toList();
          _elapsedSeconds = 0;
          _startStopwatch();
        }
      } else {
        _initNewEmpty();
      }
    }

    for (final ExerciseWithSets eWs in _exercises) {
      final List<WorkoutSet> lastSets = await repo.getLastPerformanceSets(
        eWs.exerciseDC.id,
      );
      _previousPerformances[eWs.exerciseDC.id] = lastSets;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    final double savedOffset = ref.read(activeWorkoutScrollOffsetProvider);
    if (savedOffset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(
            savedOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      });
    }

    _saveProgressToDb();
  }

  void _initNewEmpty() {
    ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
    _workout = Workout(
      id: 0,
      routineId: 0,
      notes: '',
      title: '',
      state: WorkoutState.RUNNING,
      timeElapsed: 0,
      position: 0,
      created: DateTime.now(),
      completed: DateTime.now(),
      isTemporal: false,
    );
    _exercises = <ExerciseWithSets>[];
    _elapsedSeconds = 0;
    _startStopwatch();
  }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });
      if (_elapsedSeconds % 10 == 0) {
        _saveProgressToDb();
      }
      _updateWorkoutForegroundService();
    });
  }

  Future<void> _onRestTimerDone() async {
    if (!kIsWeb) {
      await _cancelRestNotification();
      await _showRestFinishedNotification();
    }
    if (!mounted) return;
    final SettingsState settings = ref.read(settingsProvider);

    if (settings.restTimerVibrationOn) {
      if (!kIsWeb) {
        final bool hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator) {
          Vibration.vibrate(pattern: <int>[0, 400, 100, 400, 100, 400]);
        } else {
          HapticFeedback.heavyImpact();
        }
      } else {
        HapticFeedback.heavyImpact();
      }
    }

    if (settings.restTimerSoundOn) {
      try {
        await playRestAlert(_audioPlayer, AssetSource(restAlertSoundAsset));
      } catch (_) {
        // audio failure is non-fatal
      }
    }
  }

  void _startRestTimer(int seconds) {
    if (seconds <= 0) return;
    _restTimer?.cancel();
    setState(() {
      _initialRestTime = seconds;
      _restSecondsRemaining = seconds;
    });
    _updateRestNotification(seconds, seconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_restSecondsRemaining <= 1) {
        _restTimer?.cancel();
        setState(() {
          _restSecondsRemaining = 0;
          _initialRestTime = 0;
        });
        _onRestTimerDone();
      } else {
        setState(() {
          _restSecondsRemaining--;
        });
        _updateRestNotification(_restSecondsRemaining, _initialRestTime);
      }
    });
  }

  void _modifyRestTime(int secondsToAdd) {
    if (_restSecondsRemaining <= 0) return;
    setState(() {
      _restSecondsRemaining += secondsToAdd;
      if (_restSecondsRemaining > _initialRestTime) {
        _initialRestTime = _restSecondsRemaining;
      }
    });
    _updateRestNotification(_restSecondsRemaining, _initialRestTime);
  }

  void _cancelRestTimer() {
    _restTimer?.cancel();
    _cancelRestNotification();
    setState(() {
      _restSecondsRemaining = 0;
      _initialRestTime = 0;
    });
    NexcSnack.show(context, context.l10n.timerCanceled);
  }

  void _startSetStopwatch(int setId) {
    _setStopwatchTimer?.cancel();
    setState(() {
      _idSetWithRunningStopwatch = setId;
      if (!_startedSetIds.contains(setId)) {
        _startedSetIds.add(setId);
        for (int i = 0; i < _exercises.length; i++) {
          final ExerciseWithSets eWs = _exercises[i];
          final List<WorkoutSet> setsList = List<WorkoutSet>.from(eWs.sets);
          final int idx = setsList.indexWhere((WorkoutSet s) => s.id == setId);
          if (idx != -1) {
            setsList[idx] = setsList[idx].copyWith(elapsedTime: 0);
            _exercises[i] = eWs.copyWith(sets: setsList);
            break;
          }
        }
      }
    });
    _setStopwatchTimer = Timer.periodic(const Duration(seconds: 1), (
      Timer timer,
    ) {
      bool found = false;
      for (int i = 0; i < _exercises.length; i++) {
        final ExerciseWithSets eWs = _exercises[i];
        final List<WorkoutSet> setsList = List<WorkoutSet>.from(eWs.sets);
        final int idx = setsList.indexWhere((WorkoutSet s) => s.id == setId);
        if (idx != -1) {
          setsList[idx] = setsList[idx].copyWith(
            elapsedTime: setsList[idx].elapsedTime + 1,
          );
          _exercises[i] = eWs.copyWith(sets: setsList);
          found = true;
          break;
        }
      }
      if (!found) {
        _setStopwatchTimer?.cancel();
        if (mounted) {
          setState(() {
            _idSetWithRunningStopwatch = null;
          });
        }
      } else if (mounted) {
        setState(() {});
      }
    });
  }

  void _stopSetStopwatch() {
    _setStopwatchTimer?.cancel();
    setState(() {
      _idSetWithRunningStopwatch = null;
    });
  }

  List<ExerciseWithSets> _sanitizedExercises() {
    final IntensityScale intensityScale = ref
        .read(settingsProvider)
        .intensityScale;
    return _exercises.map((ExerciseWithSets eWs) {
      final List<WorkoutSet> updatedSets = eWs.sets.map((WorkoutSet s) {
        double? rpe = s.rpe;
        int? rir = s.rir;
        if (intensityScale == IntensityScale.none) {
          rpe = null;
          rir = null;
        } else if (intensityScale == IntensityScale.rpe) {
          rir = null;
        } else if (intensityScale == IntensityScale.rir) {
          rpe = null;
        }
        return s.copyWith(rpe: Value<double?>(rpe), rir: Value<int?>(rir));
      }).toList();
      return eWs.copyWith(sets: updatedSets);
    }).toList();
  }

  String _displayTitle(AppLocalizations l10n) {
    final String raw = _workout.title.trim();
    if (raw.isEmpty || raw == 'Empty Workout') return l10n.tabWorkout;
    return raw;
  }

  /// Title stored with the workout; does not touch [BuildContext] so it is
  /// safe during the initial synchronous load.
  String get _titleForStorage {
    final String raw = _workout.title.trim();
    if (raw.isEmpty || raw == 'Empty Workout') return _emptyWorkoutTitle;
    return raw;
  }

  Future<void> _saveProgressToDb() async {
    if (!mounted) return;
    final repo = ref.read(workoutRepositoryProvider);
    final Workout currentWorkout = _workout.copyWith(
      timeElapsed: _elapsedSeconds,
      state: WorkoutState.RUNNING,
      title: _titleForStorage,
    );

    final int id = await repo.addWorkoutWithExercisesAndSets(
      WorkoutWithExercisesAndSets(
        workout: currentWorkout,
        exercisesWithSets: _sanitizedExercises(),
      ),
    );

    if (_workout.id != id) {
      _workout = _workout.copyWith(id: id);
    }

    final WorkoutWithExercisesAndSets? updated = await repo
        .getWorkoutWithExercisesAndSets(id);
    if (updated != null && mounted) {
      setState(() {
        _exercises = List<ExerciseWithSets>.from(updated.exercisesWithSets);
      });
    }
  }

  Future<void> _pickExercises() async {
    final dynamic result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) =>
            const ExercisesScreen(addExercises: true),
      ),
    );
    if (!mounted) return;
    if (result is List<ExerciseDataDC>) {
      for (final ExerciseDataDC dc in result) {
        await _addExercise(dc);
      }
    }
  }

  Future<void> _addExercise(ExerciseDataDC dc) async {
    final repo = ref.read(workoutRepositoryProvider);
    final List<WorkoutSet> lastSets = await repo.getLastPerformanceSets(dc.id);
    final SetMode? storedMode = await repo.getLastSetModeForExercise(dc.id);
    final SetMode initialSetMode = storedMode ?? _defaultSetMode(dc);
    if (!mounted) return;
    setState(() {
      _previousPerformances[dc.id] = lastSets;
      final Exercise newEx = Exercise(
        id: DateTime.now().millisecondsSinceEpoch + _exercises.length,
        exerciseDataId: dc.id,
        notes: '',
        setMode: initialSetMode,
        restTime: 90,
        position: _exercises.length,
        workoutId: _workout.id,
      );
      final WorkoutSet newSet = WorkoutSet(
        id: DateTime.now().millisecondsSinceEpoch + _exercises.length + 1000,
        load: 0.0,
        weightUnit: WeightUnit.kg,
        reps: 0,
        elapsedTime: 0,
        completed: false,
        setType: SetType.NORMAL,
        exerciseId: newEx.id,
      );
      _exercises.add(
        ExerciseWithSets(
          exercise: newEx,
          exerciseDC: dc,
          sets: <WorkoutSet>[newSet],
        ),
      );
    });
    _saveProgressToDb();
  }

  SetMode _defaultSetMode(ExerciseDataDC dc) => defaultSetModeForExercise(dc);

  void _deleteExercise(int index) {
    if (index < 0 || index >= _exercises.length) return;
    setState(() {
      _exercises.removeAt(index);
      for (int i = 0; i < _exercises.length; i++) {
        _exercises[i] = _exercises[i].copyWith(
          exercise: _exercises[i].exercise.copyWith(position: i),
        );
      }
    });
    _saveProgressToDb();
  }

  void _deleteSet(int exerciseIndex, int setId) {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) return;
    final ExerciseWithSets target = _exercises[exerciseIndex];
    setState(() {
      _exercises[exerciseIndex] = target.copyWith(
        sets: target.sets.where((WorkoutSet s) => s.id != setId).toList(),
      );
    });
    _saveProgressToDb();
  }

  void _applyPreviousPerformance(int exerciseIndex, int setId) {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) return;
    final ExerciseWithSets target = _exercises[exerciseIndex];
    final List<WorkoutSet>? previous =
        _previousPerformances[target.exerciseDC.id];
    if (previous == null) return;
    final int setIndex = target.sets.indexWhere(
      (WorkoutSet s) => s.id == setId,
    );
    if (setIndex < 0 || setIndex >= previous.length) return;
    final WorkoutSet source = previous[setIndex];
    setState(() {
      _exercises[exerciseIndex] = target.copyWith(
        sets: target.sets
            .map(
              (WorkoutSet s) => s.id == setId
                  ? s.copyWith(
                      load: source.load,
                      reps: source.reps,
                      elapsedTime: source.elapsedTime,
                    )
                  : s,
            )
            .toList(),
      );
    });
    _saveProgressToDb();
  }

  Future<void> _finishWorkout() async {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    _setStopwatchTimer?.cancel();

    final int completedSets = _exercises.fold(
      0,
      (int sum, ExerciseWithSets item) =>
          sum + item.sets.where((WorkoutSet s) => s.completed).length,
    );
    final int totalSets = _exercises.fold(
      0,
      (int sum, ExerciseWithSets item) => sum + item.sets.length,
    );
    final String timeStr = _formatTime(_elapsedSeconds);

    if (!mounted) return;

    final String? confirmed = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        final AppLocalizations dialogL10n = context.l10n;
        return AlertDialog(
          scrollable: true,
          title: Text(
            dialogL10n.finishWorkoutTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _FinishSummaryRow(
                icon: NexcIcons.timer,
                text: dialogL10n.durationWithTime(timeStr),
              ),
              const SizedBox(height: NexcSpacing.sm),
              _FinishSummaryRow(
                icon: NexcIcons.check,
                text: dialogL10n.completedSetsRatio(completedSets, totalSets),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () => Navigator.pop(context, 'discard'),
              child: Text(dialogL10n.discardAction),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'save'),
              child: Text(dialogL10n.saveAction),
            ),
          ],
        );
      },
    );

    if (confirmed == 'save') {
      final repo = ref.read(workoutRepositoryProvider);
      final Workout completedWorkout = _workout.copyWith(
        title: _titleForStorage,
        timeElapsed: _elapsedSeconds,
        state: WorkoutState.COMPLETED,
        completed: DateTime.now(),
      );
      final SettingsState settings = ref.read(settingsProvider);
      final List<ExerciseWithSets> sanitized = _sanitizedExercises();
      final WorkoutWithExercisesAndSets workoutData =
          WorkoutWithExercisesAndSets(
            workout: completedWorkout,
            exercisesWithSets: sanitized,
          );
      await repo.addWorkoutWithExercisesAndSets(workoutData);

      if (_workout.routineId != 0) {
        bool updateRoutine =
            settings.routineUpdateMode == RoutineUpdateMode.always;
        if (settings.routineUpdateMode == RoutineUpdateMode.ask) {
          if (!mounted) return;
          updateRoutine = await showUpdateRoutineDialog(context);
        }
        if (updateRoutine) {
          await repo.updateRoutineWithCompletedSetValues(
            routineId: _workout.routineId,
            workoutExercises: sanitized,
          );
        }
      }

      ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                WorkoutSummaryScreen(workoutData: workoutData),
          ),
        );
      }
    } else if (confirmed == 'discard') {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.deleteWorkout(_workout);
      ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      // Dismissing the dialog is the single cancel path: resume everything.
      _startStopwatch();
      if (_idSetWithRunningStopwatch != null) {
        _startSetStopwatch(_idSetWithRunningStopwatch!);
      }
      if (_restSecondsRemaining > 0) {
        _startRestTimer(_restSecondsRemaining);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    _setStopwatchTimer?.cancel();
    _audioPlayer.dispose();
    _cancelRestNotification();
    _stopWorkoutForegroundService();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  String _formatTime(int seconds) => formatClock(seconds);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final SettingsState settings = ref.watch(settingsProvider);

    ref.listen<bool>(
      settingsProvider.select((SettingsState s) => s.workoutScreenOn),
      (bool? previous, bool next) {
        if (next) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }
      },
    );

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final int completedSets = _exercises.fold(
      0,
      (int sum, ExerciseWithSets item) =>
          sum + item.sets.where((WorkoutSet s) => s.completed).length,
    );
    final int totalSets = _exercises.fold(
      0,
      (int sum, ExerciseWithSets item) => sum + item.sets.length,
    );

    final Widget headerCard = _WorkoutProgressCard(
      completedSets: completedSets,
      totalSets: totalSets,
      elapsed: _formatTime(_elapsedSeconds),
      elevated: settings.isWorkoutHeaderSticky,
    );

    Future<void> handlePop() async {
      _stopwatchTimer?.cancel();
      _restTimer?.cancel();
      _setStopwatchTimer?.cancel();
      _cancelRestNotification();
      final repo = ref.read(workoutRepositoryProvider);
      await repo.addWorkoutWithExercisesAndSets(
        WorkoutWithExercisesAndSets(
          workout: _workout.copyWith(
            title: _titleForStorage,
            timeElapsed: _elapsedSeconds,
          ),
          exercisesWithSets: _exercises,
        ),
      );
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    final bool sticky = settings.isWorkoutHeaderSticky;
    final double bottomInset =
        (_restSecondsRemaining > 0 ? _restBarHeight : 0) + NexcSpacing.lg;

    Widget buildList() {
      final EdgeInsets padding = EdgeInsets.fromLTRB(
        NexcSpacing.lg,
        sticky ? _headerHeight + NexcSpacing.sm : NexcSpacing.sm,
        NexcSpacing.lg,
        bottomInset,
      );

      if (_exercises.isEmpty) {
        return SingleChildScrollView(
          padding: padding,
          child: NexcEmptyState(
            icon: NexcIcons.workoutIdle,
            title: l10n.noExercisesAdded,
          ),
        );
      }

      return ReorderableListView.builder(
        key: const PageStorageKey<String>('active_workout_reorderable_list'),
        scrollController: _scrollController,
        buildDefaultDragHandles: false,
        padding: padding,
        itemCount: _exercises.length + (sticky ? 0 : 1),
        onReorderStart: (int index) {},
        onReorderEnd: (int index) {},
        onReorder: (int oldIndex, int newIndex) {
          if (!sticky) {
            if (oldIndex == 0 || newIndex == 0) return;
          }
          final int offset = sticky ? 0 : 1;
          int from = oldIndex - offset;
          int to = newIndex - offset;
          if (to < 0) return;
          if (to > from) to -= 1;
          if (from < 0 || from >= _exercises.length) return;
          to = to.clamp(0, _exercises.length - 1);
          setState(() {
            final ExerciseWithSets item = _exercises.removeAt(from);
            _exercises.insert(to, item);
            for (int i = 0; i < _exercises.length; i++) {
              _exercises[i] = _exercises[i].copyWith(
                exercise: _exercises[i].exercise.copyWith(position: i),
              );
            }
          });
          _saveProgressToDb();
        },
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          final int exerciseIndex = sticky ? index : index - 1;
          final SupersetInfo info = supersetInfoFor(
            _exercises,
            exerciseIndex,
            theme.colorScheme,
          );
          final ExerciseWithSets eWs = _exercises[exerciseIndex];
          return Material(
            color: theme.colorScheme.surfaceContainerHigh,
            elevation: 8,
            borderRadius: NexcShapes.lgRadius,
            child: ExerciseCard(
              key: ValueKey<String>('ex_drag_${eWs.exercise.id}'),
              index: exerciseIndex,
              exerciseWithSets: eWs,
              workout: true,
              isReordering: true,
              previousPerformances: _previousPerformances[eWs.exerciseDC.id],
              idSetWithRunningStopwatch: _idSetWithRunningStopwatch,
              showRpe: settings.intensityScale != IntensityScale.none,
              intensityScale: settings.intensityScale,
              supersetLabel: info.label,
              supersetColor: info.color,
              addSet: (int id) {},
              onDetail: (int id, String dcId) {},
              onDelete: (int id) {},
              deleteSet: (int id) {},
              updateExerciseNotes: (String text, int id) {},
              updateExerciseRestTime: (int val, int id) {},
              updateExerciseSetMode: (SetMode mode, int id) {},
              updateSetTime: (int t, int id) {},
              updateSetReps: (int r, int id) {},
              updateSetLoad: (double l, int id) {},
              updateSetCompleted: (bool c, int id) {},
            ),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          if (!sticky && index == 0) {
            return Padding(
              key: const ValueKey<String>('header_card_wrapper'),
              padding: const EdgeInsets.only(bottom: NexcSpacing.md),
              child: headerCard,
            );
          }
          final int exIndex = sticky ? index : index - 1;
          final ExerciseWithSets eWs = _exercises[exIndex];
          final SupersetInfo info = supersetInfoFor(
            _exercises,
            exIndex,
            theme.colorScheme,
          );
          return _buildExerciseCard(
            context,
            eWs: eWs,
            exIndex: exIndex,
            info: info,
            settings: settings,
          );
        },
      );
    }

    final Widget body;
    if (sticky) {
      body = Stack(
        children: <Widget>[
          buildList(),
          Positioned(
            top: NexcSpacing.sm,
            left: NexcSpacing.lg,
            right: NexcSpacing.lg,
            child: MeasuredHeight(
              onHeight: (double height) {
                if ((height - _headerHeight).abs() < 0.5) return;
                setState(() => _headerHeight = height);
              },
              child: headerCard,
            ),
          ),
          if (_restSecondsRemaining > 0)
            Positioned(
              left: NexcSpacing.lg,
              right: NexcSpacing.lg,
              bottom: NexcSpacing.md,
              child: MeasuredHeight(
                onHeight: (double height) {
                  if ((height - _restBarHeight).abs() < 0.5) return;
                  setState(() => _restBarHeight = height);
                },
                child: RestTimerBar(
                  remainingSeconds: _restSecondsRemaining,
                  initialSeconds: _initialRestTime,
                  onCancel: _cancelRestTimer,
                  onAddTime: () => _modifyRestTime(10),
                ),
              ),
            ),
        ],
      );
    } else {
      body = Stack(
        children: <Widget>[
          buildList(),
          if (_restSecondsRemaining > 0)
            Positioned(
              left: NexcSpacing.lg,
              right: NexcSpacing.lg,
              bottom: NexcSpacing.md,
              child: MeasuredHeight(
                onHeight: (double height) {
                  if ((height - _restBarHeight).abs() < 0.5) return;
                  setState(() => _restBarHeight = height);
                },
                child: RestTimerBar(
                  remainingSeconds: _restSecondsRemaining,
                  initialSeconds: _initialRestTime,
                  onCancel: _cancelRestTimer,
                  onAddTime: () => _modifyRestTime(10),
                ),
              ),
            ),
        ],
      );
    }

    final bool aiEnabled = settings.aiWorkoutGenerationEnabled;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        await handlePop();
      },
      child: NexcPage(
        title: _displayTitle(l10n),
        subtitle: l10n.exercisesWithCount(_exercises.length),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: l10n.moreOptions,
            icon: const Icon(NexcIcons.more),
            onSelected: (String value) {
              switch (value) {
                case 'reorder':
                  setState(() => _isReordering = !_isReordering);
                  break;
                case 'ai':
                  if (aiEnabled) {
                    Navigator.pushNamed(context, '/workout/ai-chat');
                  } else {
                    NexcSnack.show(
                      context,
                      l10n.aiWorkoutGenerationDisabled,
                      actionLabel: l10n.settingsTitle,
                      onAction: () => Navigator.pushNamed(context, '/settings'),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (_exercises.isNotEmpty)
                PopupMenuItem<String>(
                  value: 'reorder',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _isReordering ? NexcIcons.check : NexcIcons.sort,
                    ),
                    title: Text(
                      _isReordering
                          ? l10n.doneReordering
                          : l10n.reorderExercises,
                    ),
                  ),
                ),
              PopupMenuItem<String>(
                value: 'ai',
                enabled: aiEnabled,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    NexcIcons.ai,
                    color: aiEnabled
                        ? null
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  title: Text(
                    aiEnabled
                        ? l10n.aiWorkoutCreator
                        : l10n.aiWorkoutCreatorDisabled,
                  ),
                ),
              ),
            ],
          ),
        ],
        body: SafeArea(top: false, child: body),
        bottomBar: Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: _pickExercises,
                child: Text(
                  l10n.addExercise,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: NexcSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: _finishWorkout,
                child: Text(
                  l10n.doneAction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required ExerciseWithSets eWs,
    required int exIndex,
    required SupersetInfo info,
    required SettingsState settings,
  }) {
    return ExerciseCard(
      key: ValueKey<String>('ex_${eWs.exercise.id}'),
      index: exIndex,
      exerciseWithSets: eWs,
      workout: true,
      isReordering: _isReordering,
      previousPerformances: _previousPerformances[eWs.exerciseDC.id],
      idSetWithRunningStopwatch: _idSetWithRunningStopwatch,
      showRpe: settings.intensityScale != IntensityScale.none,
      intensityScale: settings.intensityScale,
      supersetLabel: info.label,
      supersetColor: info.color,
      applyPreviousSetPerformance: (int setId) =>
          _applyPreviousPerformance(exIndex, setId),
      updateSetRpe: (String val, int setId) {
        final double? rpe = double.tryParse(val);
        setState(() {
          _exercises[exIndex] = eWs.copyWith(
            sets: eWs.sets
                .map(
                  (WorkoutSet s) =>
                      s.id == setId ? s.copyWith(rpe: Value<double?>(rpe)) : s,
                )
                .toList(),
          );
        });
        _saveProgressToDb();
      },
      updateSetRir: (String val, int setId) {
        final int? rir = int.tryParse(val);
        setState(() {
          _exercises[exIndex] = eWs.copyWith(
            sets: eWs.sets
                .map(
                  (WorkoutSet s) =>
                      s.id == setId ? s.copyWith(rir: Value<int?>(rir)) : s,
                )
                .toList(),
          );
        });
        _saveProgressToDb();
      },
      addSet: (int exId) {
        setState(() {
          final List<WorkoutSet> setList = List<WorkoutSet>.from(eWs.sets);
          final WorkoutSet? lastSet = setList.lastOrNull;
          setList.add(
            WorkoutSet(
              id: DateTime.now().millisecondsSinceEpoch,
              load: lastSet?.load ?? 0.0,
              weightUnit: WeightUnit.kg,
              reps: lastSet?.reps ?? 0,
              elapsedTime: 0,
              completed: false,
              setType: lastSet?.setType ?? SetType.NORMAL,
              exerciseId: exId,
            ),
          );
          _exercises[exIndex] = eWs.copyWith(sets: setList);
        });
        _saveProgressToDb();
      },
      onDetail: (int exId, String dcId) {
        Navigator.pushNamed(context, '/exercises/info', arguments: dcId);
      },
      onDelete: (int exId) => _deleteExercise(exIndex),
      deleteSet: (int setId) => _deleteSet(exIndex, setId),
      updateExerciseNotes: (String text, int exId) {
        setState(() {
          _exercises[exIndex] = eWs.copyWith(
            exercise: eWs.exercise.copyWith(notes: text),
          );
        });
        _saveProgressToDb();
      },
      updateExerciseRestTime: (int restTime, int exId) {
        setState(() {
          _exercises[exIndex] = eWs.copyWith(
            exercise: eWs.exercise.copyWith(restTime: restTime),
          );
        });
        _saveProgressToDb();
      },
      updateExerciseSetMode: (SetMode setMode, int exId) {
        setState(() {
          _exercises[exIndex] = eWs.copyWith(
            exercise: eWs.exercise.copyWith(setMode: setMode),
          );
        });
        _saveProgressToDb();
      },
      updateSetTime: (int time, int setId) {
        setState(() {
          _exercises[exIndex] = eWs.copyWith(
            sets: eWs.sets
                .map(
                  (WorkoutSet s) =>
                      s.id == setId ? s.copyWith(elapsedTime: time) : s,
                )
                .toList(),
          );
        });
        _saveProgressToDb();
      },
      updateSetReps: (int reps, int setId) {
        setState(() {
          _exercises[exIndex] = eWs.copyWith(
            sets: eWs.sets
                .map(
                  (WorkoutSet s) => s.id == setId ? s.copyWith(reps: reps) : s,
                )
                .toList(),
          );
        });
        _saveProgressToDb();
      },
      updateSetLoad: (double load, int setId) {
        setState(() {
          _exercises[exIndex] = eWs.copyWith(
            sets: eWs.sets
                .map(
                  (WorkoutSet s) => s.id == setId ? s.copyWith(load: load) : s,
                )
                .toList(),
          );
        });
        _saveProgressToDb();
      },
      updateSetCompleted: (bool completed, int setId) {
        setState(() {
          _exercises[exIndex] = eWs.copyWith(
            sets: eWs.sets
                .map(
                  (WorkoutSet s) =>
                      s.id == setId ? s.copyWith(completed: completed) : s,
                )
                .toList(),
          );
        });
        if (completed && eWs.exercise.restTime > 0) {
          _startRestTimer(eWs.exercise.restTime);
        }
        _saveProgressToDb();
      },
      updateIdSetWithRunningStopwatch: (int setId) {
        if (setId == 0) {
          _stopSetStopwatch();
        } else {
          _startSetStopwatch(setId);
        }
      },
      onMachineBusy: (int exId) {
        if (_exercises.length <= 1) return;
        final List<int> newOrder = AIService.reorderMachineBusy(
          busyIndex: exIndex,
          totalExercises: _exercises.length,
        );
        setState(() {
          final List<ExerciseWithSets> reordered = newOrder
              .map((int idx) => _exercises[idx])
              .toList();
          for (int i = 0; i < reordered.length; i++) {
            reordered[i] = reordered[i].copyWith(
              exercise: reordered[i].exercise.copyWith(position: i),
            );
          }
          _exercises = reordered;
        });
        _saveProgressToDb();
        NexcSnack.show(
          context,
          context.l10n.pushedExerciseForLater(eWs.exerciseDC.name),
        );
      },
      onReplace: (int exId) async {
        final dynamic result = await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => ExercisesScreen(
              addExercises: false,
              targetExerciseToReplace: eWs.exerciseDC,
            ),
          ),
        );
        if (!mounted) return;
        if (result is List<ExerciseDataDC> && result.isNotEmpty) {
          final ExerciseDataDC newDC = result.first;
          final SetMode? storedMode = await ref
              .read(workoutRepositoryProvider)
              .getLastSetModeForExercise(newDC.id);
          final SetMode initialSetMode = storedMode ?? _defaultSetMode(newDC);
          if (!mounted) return;
          setState(() {
            _exercises[exIndex] = _exercises[exIndex].copyWith(
              exerciseDC: newDC,
              exercise: _exercises[exIndex].exercise.copyWith(
                exerciseDataId: newDC.id,
                setMode: initialSetMode,
              ),
            );
          });
          _saveProgressToDb();
        }
      },
      onSupersetToggle: (int exId) {
        setState(() {
          final int? currentSupersetId = eWs.exercise.supersetId;
          if (currentSupersetId != null) {
            _exercises[exIndex] = eWs.copyWith(
              exercise: eWs.exercise.copyWith(
                supersetId: const Value<int?>(null),
              ),
            );
          } else if (exIndex > 0) {
            final ExerciseWithSets previous = _exercises[exIndex - 1];
            final int? previousSupersetId = previous.exercise.supersetId;
            if (previousSupersetId != null) {
              _exercises[exIndex] = eWs.copyWith(
                exercise: eWs.exercise.copyWith(
                  supersetId: Value<int?>(previousSupersetId),
                ),
              );
            } else {
              final int maxId = _exercises
                  .map((ExerciseWithSets e) => e.exercise.supersetId)
                  .whereType<int>()
                  .fold<int>(
                    0,
                    (int max, int value) => value > max ? value : max,
                  );
              final int newId = maxId + 1;
              _exercises[exIndex - 1] = previous.copyWith(
                exercise: previous.exercise.copyWith(
                  supersetId: Value<int?>(newId),
                ),
              );
              _exercises[exIndex] = eWs.copyWith(
                exercise: eWs.exercise.copyWith(supersetId: Value<int?>(newId)),
              );
            }
          }
        });
        _saveProgressToDb();
      },
    );
  }
}

class _WorkoutProgressCard extends StatelessWidget {
  final int completedSets;
  final int totalSets;
  final String elapsed;
  final bool elevated;

  const _WorkoutProgressCard({
    required this.completedSets,
    required this.totalSets,
    required this.elapsed,
    required this.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    return Material(
      color: theme.colorScheme.primaryContainer,
      elevation: elevated ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: NexcShapes.lgRadius,
        side: BorderSide(
          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NexcSpacing.lg,
          NexcSpacing.md,
          NexcSpacing.lg,
          NexcSpacing.md,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.setsRatio(completedSets, totalSets),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Text(
                  elapsed,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ),
            if (totalSets > 0) ...[
              const SizedBox(height: NexcSpacing.sm),
              ClipRRect(
                borderRadius: NexcShapes.fullRadius,
                child: LinearProgressIndicator(
                  value: completedSets / totalSets,
                  minHeight: 4,
                  color: theme.colorScheme.onPrimaryContainer,
                  backgroundColor: theme.colorScheme.onPrimaryContainer
                      .withValues(alpha: 0.2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FinishSummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FinishSummaryRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(NexcSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: NexcShapes.mdRadius,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: NexcSpacing.md),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact rest timer with one progress ring and explicit actions.
class RestTimerBar extends StatelessWidget {
  final int remainingSeconds;
  final int initialSeconds;
  final VoidCallback onCancel;
  final VoidCallback onAddTime;

  const RestTimerBar({
    super.key,
    required this.remainingSeconds,
    required this.initialSeconds,
    required this.onCancel,
    required this.onAddTime,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Material(
      color: theme.colorScheme.tertiaryContainer,
      elevation: 3,
      borderRadius: NexcShapes.lgRadius,
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.md),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 44,
              height: 44,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: initialSeconds > 0
                      ? remainingSeconds / initialSeconds
                      : 0,
                ),
                duration: reduceMotion ? Duration.zero : NexcMotion.short,
                builder: (BuildContext context, double value, Widget? child) {
                  return CircularWavyProgressIndicator(
                    key: const ValueKey<String>('rest_timer_indicator'),
                    value: value,
                    color: theme.colorScheme.onTertiaryContainer,
                    backgroundColor: theme.colorScheme.onTertiaryContainer
                        .withValues(alpha: 0.18),
                    strokeWidth: 4,
                    waveHeight: 1.5,
                    waveCount: 9,
                  );
                },
              ),
            ),
            const SizedBox(width: NexcSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.restTimerBadge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer.withValues(
                        alpha: 0.8,
                      ),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    formatClock(remainingSeconds),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: l10n.increaseBy('10s'),
              child: TextButton(
                onPressed: onAddTime,
                child: const Text('+10s'),
              ),
            ),
            TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
          ],
        ),
      ),
    );
  }
}

extension CoerceInt on int {
  int coerceAtLeast(int minVal) => this < minVal ? minVal : this;
}
