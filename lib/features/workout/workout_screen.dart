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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/db/enums.dart';
import 'workout_summary_screen.dart';
import '../../core/db/relations.dart';
import '../../core/db/workout_repository.dart';
import '../../core/integrations/ai_service.dart';
import '../../core/components/exercise_card.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/workout_providers.dart';
import '../exercises/exercises_screen.dart';
import '../../core/components/wavy_progress_indicators.dart';
import '../../core/util/exercise_set_mode_helper.dart';
import '../../core/util/rest_alert_audio.dart';
import '../meals/edit_meal_plan_screen.dart';

/// Asks whether the linked routine should copy the completed set values.
///
/// Returns true for "Update", false for "Don't update" or a dismissed dialog.
Future<bool> showUpdateRoutineDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text('Update routine?'),
        content: const Text(
          'Copy the values of the completed sets into your routine?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Don't update"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
  return result ?? false;
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
  List<ExerciseWithSets> _exercises = [];
  final Map<String, List<WorkoutSet>> _previousPerformances = {};
  final Set<int> _startedSetIds = {};
  bool _isReordering = false;
  late final ScrollController _scrollController;

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
    final androidDetails = AndroidNotificationDetails(
      'workout_session_channel',
      'Active Workout',
      channelDescription: 'Keeps workout stopwatch running in background',
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
            title: 'Workout in Progress',
            body: 'Duration: ${_formatTime(_elapsedSeconds)}',
            notificationDetails: androidDetails,
          );
    } catch (_) {}
  }

  Future<void> _stopWorkoutForegroundService() async {
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.stopForegroundService();
    } catch (_) {}
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
    final elapsed = initial - remaining;
    final androidDetails = AndroidNotificationDetails(
      'rest_timer_channel',
      'Rest Timer',
      channelDescription: 'Notifications for active rest timer',
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
      title: 'Resting...',
      body: '$remaining seconds remaining',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> _cancelRestNotification() async {
    await _notificationsPlugin.cancel(id: 999);
  }

  Future<void> _showRestFinishedNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'rest_timer_channel_finished',
      'Rest Timer Finished',
      channelDescription: 'Notifications when rest timer is done',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: 999,
      title: 'Rest Finished',
      body: 'Time to start your next set!',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> _loadWorkout() async {
    final repo = ref.read(workoutRepositoryProvider);

    if (widget.workoutId == 0) {
      // 1. Empty Workout
      ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
      _workout = Workout(
        id: 0,
        routineId: 0,
        notes: '',
        title: 'Empty Workout',
        state: WorkoutState.RUNNING,
        timeElapsed: 0,
        position: 0,
        created: DateTime.now(),
        completed: DateTime.now(),
        isTemporal: false,
      );
      _exercises = [];
      _elapsedSeconds = 0;
      _startStopwatch();
    } else {
      final potential = await repo.getWorkoutWithExercisesAndSets(
        widget.workoutId,
      );
      if (potential != null) {
        if (potential.workout.state == WorkoutState.RUNNING) {
          // 2. Resuming running workout
          _workout = potential.workout;
          _exercises = List.from(potential.exercisesWithSets);
          _elapsedSeconds = _workout.timeElapsed;
          _startStopwatch();
        } else if (potential.workout.state == WorkoutState.ROUTINE) {
          // 3. Starting new workout from routine
          ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
          final now = DateTime.now();
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
          // Clone exercises & sets
          int tempExId = -1;
          int tempSetId = -1;
          _exercises = potential.exercisesWithSets.map((eWs) {
            final clonedEx = eWs.exercise.copyWith(
              id: tempExId--,
              workoutId: 0,
            );
            final clonedSets = eWs.sets
                .map(
                  (s) => s.copyWith(
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

    // Fetch previous performances
    for (final eWs in _exercises) {
      final lastSets = await repo.getLastPerformanceSets(eWs.exerciseDC.id);
      _previousPerformances[eWs.exerciseDC.id] = lastSets;
    }

    setState(() {
      _isLoading = false;
    });

    final savedOffset = ref.read(activeWorkoutScrollOffsetProvider);
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
      title: 'Empty Workout',
      state: WorkoutState.RUNNING,
      timeElapsed: 0,
      position: 0,
      created: DateTime.now(),
      completed: DateTime.now(),
      isTemporal: false,
    );
    _exercises = [];
    _elapsedSeconds = 0;
    _startStopwatch();
  }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    final settings = ref.read(settingsProvider);

    // Vibration
    if (settings.restTimerVibrationOn) {
      if (!kIsWeb) {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator) {
          Vibration.vibrate(pattern: [0, 400, 100, 400, 100, 400]);
        } else {
          HapticFeedback.heavyImpact();
        }
      } else {
        HapticFeedback.heavyImpact();
      }
    }

    // Sound
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
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  void _modifyRestTime(bool addTenSeconds) {
    if (_restSecondsRemaining <= 0) return;
    setState(() {
      if (addTenSeconds) {
        _restSecondsRemaining += 10;
        if (_restSecondsRemaining > _initialRestTime) {
          _initialRestTime = _restSecondsRemaining;
        }
      } else {
        if (_restSecondsRemaining > 10) {
          _restSecondsRemaining -= 10;
        } else {
          _restSecondsRemaining = 0;
          _initialRestTime = 0;
          _restTimer?.cancel();
          _cancelRestNotification();
        }
      }
    });
    if (_restSecondsRemaining > 0) {
      _updateRestNotification(_restSecondsRemaining, _initialRestTime);
    }
  }

  void _startSetStopwatch(int setId) {
    _setStopwatchTimer?.cancel();
    setState(() {
      _idSetWithRunningStopwatch = setId;
      if (!_startedSetIds.contains(setId)) {
        _startedSetIds.add(setId);
        for (int i = 0; i < _exercises.length; i++) {
          final eWs = _exercises[i];
          final setsList = List<WorkoutSet>.from(eWs.sets);
          final idx = setsList.indexWhere((s) => s.id == setId);
          if (idx != -1) {
            setsList[idx] = setsList[idx].copyWith(elapsedTime: 0);
            _exercises[i] = eWs.copyWith(sets: setsList);
            break;
          }
        }
      }
    });
    _setStopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool found = false;
      for (int i = 0; i < _exercises.length; i++) {
        final eWs = _exercises[i];
        final setsList = List<WorkoutSet>.from(eWs.sets);
        final idx = setsList.indexWhere((s) => s.id == setId);
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
        setState(() {
          _idSetWithRunningStopwatch = null;
        });
      } else {
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

  Future<void> _saveProgressToDb() async {
    if (!mounted) return;
    final repo = ref.read(workoutRepositoryProvider);
    final currentWorkout = _workout.copyWith(
      timeElapsed: _elapsedSeconds,
      state: WorkoutState.RUNNING,
    );

    final settings = ref.read(settingsProvider);
    final intensityScale = settings.intensityScale;

    final sanitizedExercises = _exercises.map((eWs) {
      final updatedSets = eWs.sets.map((s) {
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
        return s.copyWith(rpe: Value(rpe), rir: Value(rir));
      }).toList();
      return eWs.copyWith(sets: updatedSets);
    }).toList();

    final id = await repo.addWorkoutWithExercisesAndSets(
      WorkoutWithExercisesAndSets(
        workout: currentWorkout,
        exercisesWithSets: sanitizedExercises,
      ),
    );

    if (_workout.id != id) {
      _workout = _workout.copyWith(id: id);
    }

    final updated = await repo.getWorkoutWithExercisesAndSets(id);
    if (updated != null && mounted) {
      setState(() {
        _exercises = List.from(updated.exercisesWithSets);
      });
    }
  }

  Future<void> _finishWorkout() async {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    _setStopwatchTimer?.cancel();

    final completedSets = _exercises.fold(
      0,
      (sum, item) => sum + item.sets.where((s) => s.completed).length,
    );
    final totalSets = _exercises.fold(0, (sum, item) => sum + item.sets.length);
    final timeStr = _formatTime(_elapsedSeconds);

    if (!mounted) return;

    final confirmed = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Finish Workout?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context, 'cancel'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Duration: $timeStr',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Completed: $completedSets/$totalSets sets',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(color: theme.colorScheme.error),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, 'discard'),
                            child: const Text(
                              'DISCARD',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, 'save'),
                            child: const Text(
                              'SAVE',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == 'save') {
      final repo = ref.read(workoutRepositoryProvider);
      final completedWorkout = _workout.copyWith(
        timeElapsed: _elapsedSeconds,
        state: WorkoutState.COMPLETED,
        completed: DateTime.now(),
      );

      final settings = ref.read(settingsProvider);
      final intensityScale = settings.intensityScale;
      final sanitizedExercises = _exercises.map((eWs) {
        final updatedSets = eWs.sets.map((s) {
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
          return s.copyWith(rpe: Value(rpe), rir: Value(rir));
        }).toList();
        return eWs.copyWith(sets: updatedSets);
      }).toList();

      final workoutData = WorkoutWithExercisesAndSets(
        workout: completedWorkout,
        exercisesWithSets: sanitizedExercises,
      );
      await repo.addWorkoutWithExercisesAndSets(workoutData);

      if (_workout.routineId != 0) {
        var updateRoutine =
            settings.routineUpdateMode == RoutineUpdateMode.always;
        if (settings.routineUpdateMode == RoutineUpdateMode.ask) {
          if (!mounted) return;
          updateRoutine = await showUpdateRoutineDialog(context);
        }
        if (updateRoutine) {
          await repo.updateRoutineWithCompletedSetValues(
            routineId: _workout.routineId,
            workoutExercises: sanitizedExercises,
          );
        }
      }

      ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
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
      // cancel / resume
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

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _addExercise(ExerciseDataDC dc) async {
    final repo = ref.read(workoutRepositoryProvider);
    final lastSets = await repo.getLastPerformanceSets(dc.id);
    final storedMode = await repo.getLastSetModeForExercise(dc.id);
    final initialSetMode = storedMode ?? _defaultSetMode(dc);
    if (!mounted) return;
    setState(() {
      _previousPerformances[dc.id] = lastSets;
      final newEx = Exercise(
        id: DateTime.now().millisecondsSinceEpoch + _exercises.length,
        exerciseDataId: dc.id,
        notes: '',
        setMode: initialSetMode,
        restTime: 90,
        position: _exercises.length,
        workoutId: _workout.id,
      );
      final newSet = WorkoutSet(
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
        ExerciseWithSets(exercise: newEx, exerciseDC: dc, sets: [newSet]),
      );
    });
    _saveProgressToDb();
  }

  SetMode _defaultSetMode(ExerciseDataDC dc) => defaultSetModeForExercise(dc);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    ref.listen<bool>(settingsProvider.select((s) => s.workoutScreenOn), (
      previous,
      next,
    ) {
      if (next) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    });

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final int completedSets = _exercises.fold(
      0,
      (sum, item) => sum + item.sets.where((s) => s.completed).length,
    );
    final int totalSets = _exercises.fold(
      0,
      (sum, item) => sum + item.sets.length,
    );

    final headerCard = Card(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: settings.isWorkoutHeaderSticky ? 6 : 0,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sets: $completedSets/$totalSets',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  _formatTime(_elapsedSeconds),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearWavyProgressIndicator(
              value: totalSets > 0 ? (completedSets / totalSets) : 0.0,
              color: theme.colorScheme.onPrimaryContainer,
              backgroundColor: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.2,
              ),
            ),
          ],
        ),
      ),
    );

    Future<void> handlePop() async {
      _stopwatchTimer?.cancel();
      _restTimer?.cancel();
      _setStopwatchTimer?.cancel();
      _cancelRestNotification();
      final repo = ref.read(workoutRepositoryProvider);
      await repo.addWorkoutWithExercisesAndSets(
        WorkoutWithExercisesAndSets(
          workout: _workout.copyWith(timeElapsed: _elapsedSeconds),
          exercisesWithSets: _exercises,
        ),
      );
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await handlePop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: handlePop,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.auto_awesome,
                color: settings.aiWorkoutGenerationEnabled
                    ? null
                    : theme.disabledColor,
              ),
              tooltip: settings.aiWorkoutGenerationEnabled
                  ? "AI Workout Creator"
                  : "AI Workout Creator (Disabled in Settings)",
              onPressed: () {
                if (settings.aiWorkoutGenerationEnabled) {
                  Navigator.pushNamed(context, '/workout/ai-chat');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'AI workout generation is disabled in Settings.',
                      ),
                      action: SnackBarAction(
                        label: 'Settings',
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                      ),
                    ),
                  );
                }
              },
            ),
            if (_exercises.isNotEmpty) ...[
              IconButton(
                icon: Icon(_isReordering ? Icons.check : Icons.swap_vert),
                tooltip: _isReordering
                    ? "Done Reordering"
                    : "Reorder Exercises",
                onPressed: () {
                  setState(() {
                    _isReordering = !_isReordering;
                  });
                },
              ),
              TextButton(
                onPressed: _finishWorkout,
                child: const Text(
                  'DONE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        body: Stack(
          children: [
            _exercises.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.0),
                      child: Text(
                        'Your workout is empty. Tap Add Exercise below.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    key: const PageStorageKey(
                      'active_workout_reorderable_list',
                    ),
                    scrollController: _scrollController,
                    buildDefaultDragHandles: false,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      settings.isWorkoutHeaderSticky ? 120 : 16,
                      16,
                      100,
                    ),
                    itemCount: settings.isWorkoutHeaderSticky
                        ? _exercises.length
                        : _exercises.length + 1,
                    onReorderStart: (index) {},
                    onReorderEnd: (index) {},
                    onReorder: (oldIndex, newIndex) {
                      final isSticky = settings.isWorkoutHeaderSticky;
                      if (!isSticky) {
                        if (oldIndex == 0 || newIndex == 0) return;
                        oldIndex -= 1;
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                      }
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = _exercises.removeAt(oldIndex);
                        _exercises.insert(newIndex, item);
                        for (int i = 0; i < _exercises.length; i++) {
                          _exercises[i] = _exercises[i].copyWith(
                            exercise: _exercises[i].exercise.copyWith(
                              position: i,
                            ),
                          );
                        }
                      });
                      _saveProgressToDb();
                    },
                    proxyDecorator:
                        (Widget child, int index, Animation<double> animation) {
                          final settings = ref.read(settingsProvider);
                          final eWs = _exercises[index];
                          final List<Color> supersetColors = [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                            theme.colorScheme.secondary,
                            theme.colorScheme.error,
                            theme.colorScheme.inversePrimary,
                            theme.colorScheme.tertiaryContainer,
                          ];
                          final uniqueSupersets = _exercises
                              .map((e) => e.exercise.supersetId)
                              .where((id) => id != null)
                              .toSet()
                              .toList();
                          final sId = eWs.exercise.supersetId;
                          String? supersetLabel;
                          Color? supersetColor;
                          if (sId != null) {
                            final sIndex = uniqueSupersets.indexOf(sId);
                            if (sIndex != -1) {
                              final letter = String.fromCharCode(65 + sIndex);
                              supersetLabel = letter;
                              supersetColor =
                                  supersetColors[sIndex %
                                      supersetColors.length];
                            }
                          }
                          return Material(
                            color: Colors.transparent,
                            elevation: 8,
                            child: ExerciseCard(
                              key: ValueKey('ex_drag_${eWs.exercise.id}'),
                              index: index,
                              exerciseWithSets: eWs,
                              workout: true,
                              isReordering: true,
                              previousPerformances:
                                  _previousPerformances[eWs.exerciseDC.id],
                              idSetWithRunningStopwatch:
                                  _idSetWithRunningStopwatch,
                              showRpe:
                                  settings.intensityScale !=
                                  IntensityScale.none,
                              intensityScale: settings.intensityScale,
                              supersetLabel: supersetLabel,
                              supersetColor: supersetColor,
                              addSet: (id) {},
                              onDetail: (id, dcId) {},
                              onDelete: (id) {},
                              deleteSet: (id) {},
                              updateExerciseNotes: (text, id) {},
                              updateExerciseRestTime: (val, id) {},
                              updateExerciseSetMode: (mode, id) {},
                              updateSetTime: (t, id) {},
                              updateSetReps: (r, id) {},
                              updateSetLoad: (l, id) {},
                              updateSetCompleted: (c, id) {},
                              showInfo: (info) {},
                            ),
                          );
                        },
                    itemBuilder: (context, index) {
                      final isSticky = settings.isWorkoutHeaderSticky;
                      if (!isSticky && index == 0) {
                        return Padding(
                          key: const ValueKey('header_card_wrapper'),
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: headerCard,
                        );
                      }
                      final exIndex = isSticky ? index : index - 1;
                      final eWs = _exercises[exIndex];
                      final List<Color> supersetColors = [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                        theme.colorScheme.secondary,
                        theme.colorScheme.error,
                        theme.colorScheme.inversePrimary,
                        theme.colorScheme.tertiaryContainer,
                      ];
                      final uniqueSupersets = _exercises
                          .map((e) => e.exercise.supersetId)
                          .where((id) => id != null)
                          .toSet()
                          .toList();
                      final sId = eWs.exercise.supersetId;
                      String? supersetLabel;
                      Color? supersetColor;
                      if (sId != null) {
                        final sIndex = uniqueSupersets.indexOf(sId);
                        if (sIndex != -1) {
                          final letter = String.fromCharCode(65 + sIndex);
                          supersetLabel = letter;
                          supersetColor =
                              supersetColors[sIndex % supersetColors.length];
                        }
                      }

                      return ExerciseCard(
                        key: ValueKey('ex_${eWs.exercise.id}'),
                        index: exIndex,
                        exerciseWithSets: eWs,
                        workout: true,
                        isReordering: _isReordering,
                        previousPerformances:
                            _previousPerformances[eWs.exerciseDC.id],
                        idSetWithRunningStopwatch: _idSetWithRunningStopwatch,
                        showRpe: settings.intensityScale != IntensityScale.none,
                        intensityScale: settings.intensityScale,
                        supersetLabel: supersetLabel,
                        supersetColor: supersetColor,
                        updateSetRpe: (val, setId) {
                          final rpe = double.tryParse(val);
                          setState(() {
                            _exercises[exIndex] = eWs.copyWith(
                              sets: eWs.sets
                                  .map(
                                    (s) => s.id == setId
                                        ? s.copyWith(rpe: Value(rpe))
                                        : s,
                                  )
                                  .toList(),
                            );
                          });
                          _saveProgressToDb();
                        },
                        updateSetRir: (val, setId) {
                          final rir = int.tryParse(val);
                          setState(() {
                            _exercises[exIndex] = eWs.copyWith(
                              sets: eWs.sets
                                  .map(
                                    (s) => s.id == setId
                                        ? s.copyWith(rir: Value(rir))
                                        : s,
                                  )
                                  .toList(),
                            );
                          });
                          _saveProgressToDb();
                        },
                        addSet: (exId) {
                          setState(() {
                            final setList = List<WorkoutSet>.from(eWs.sets);
                            final lastSet = setList.lastOrNull;
                            setList.add(
                              WorkoutSet(
                                id: DateTime.now().millisecondsSinceEpoch,
                                // Loads stay canonical kilograms; the card
                                // converts them for display and input.
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
                        onDetail: (exId, dcId) {
                          Navigator.pushNamed(
                            context,
                            '/exercises/info',
                            arguments: dcId,
                          );
                        },
                        onDelete: (exId) {
                          setState(() {
                            _exercises.removeAt(exIndex);
                          });
                          _saveProgressToDb();
                        },
                        deleteSet: (setId) {
                          setState(() {
                            final setList = eWs.sets
                                .where((s) => s.id != setId)
                                .toList();
                            _exercises[exIndex] = eWs.copyWith(sets: setList);
                          });
                          _saveProgressToDb();
                        },
                        updateExerciseNotes: (text, exId) {
                          setState(() {
                            _exercises[exIndex] = eWs.copyWith(
                              exercise: eWs.exercise.copyWith(notes: text),
                            );
                          });
                          _saveProgressToDb();
                        },
                        updateExerciseRestTime: (restTime, exId) {
                          setState(() {
                            _exercises[exIndex] = eWs.copyWith(
                              exercise: eWs.exercise.copyWith(
                                restTime: restTime,
                              ),
                            );
                          });
                          _saveProgressToDb();
                        },
                        updateExerciseSetMode: (setMode, exId) {
                          setState(() {
                            _exercises[exIndex] = eWs.copyWith(
                              exercise: eWs.exercise.copyWith(setMode: setMode),
                            );
                          });
                          _saveProgressToDb();
                        },
                        updateSetTime: (time, setId) {
                          setState(() {
                            _exercises[exIndex] = eWs.copyWith(
                              sets: eWs.sets
                                  .map(
                                    (s) => s.id == setId
                                        ? s.copyWith(elapsedTime: time)
                                        : s,
                                  )
                                  .toList(),
                            );
                          });
                          _saveProgressToDb();
                        },
                        updateSetReps: (reps, setId) {
                          setState(() {
                            _exercises[exIndex] = eWs.copyWith(
                              sets: eWs.sets
                                  .map(
                                    (s) => s.id == setId
                                        ? s.copyWith(reps: reps)
                                        : s,
                                  )
                                  .toList(),
                            );
                          });
                          _saveProgressToDb();
                        },
                        updateSetLoad: (load, setId) {
                          setState(() {
                            _exercises[exIndex] = eWs.copyWith(
                              sets: eWs.sets
                                  .map(
                                    (s) => s.id == setId
                                        ? s.copyWith(load: load)
                                        : s,
                                  )
                                  .toList(),
                            );
                          });
                          _saveProgressToDb();
                        },
                        updateSetCompleted: (completed, setId) {
                          setState(() {
                            _exercises[exIndex] = eWs.copyWith(
                              sets: eWs.sets
                                  .map(
                                    (s) => s.id == setId
                                        ? s.copyWith(completed: completed)
                                        : s,
                                  )
                                  .toList(),
                            );
                          });
                          if (completed && eWs.exercise.restTime > 0) {
                            _startRestTimer(eWs.exercise.restTime);
                          }
                          _saveProgressToDb();
                        },
                        showInfo: (info) {},
                        updateIdSetWithRunningStopwatch: (setId) {
                          if (setId == 0) {
                            _stopSetStopwatch();
                          } else {
                            _startSetStopwatch(setId);
                          }
                        },
                        isFirst: exIndex == 0,
                        onMachineBusy: (exId) {
                          if (_exercises.length <= 1) return;
                          final newOrder = AIService.reorderMachineBusy(
                            busyIndex: exIndex,
                            totalExercises: _exercises.length,
                          );
                          setState(() {
                            final reordered = newOrder
                                .map((idx) => _exercises[idx])
                                .toList();
                            for (int i = 0; i < reordered.length; i++) {
                              reordered[i] = reordered[i].copyWith(
                                exercise: reordered[i].exercise.copyWith(
                                  position: i,
                                ),
                              );
                            }
                            _exercises = reordered;
                          });
                          _saveProgressToDb();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Pushed "${eWs.exerciseDC.name}" for later',
                              ),
                            ),
                          );
                        },
                        onReplace: (exId) async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExercisesScreen(
                                addExercises: false,
                                targetExerciseToReplace: eWs.exerciseDC,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          if (result != null &&
                              result is List<ExerciseDataDC> &&
                              result.isNotEmpty) {
                            final newDC = result.first;
                            final storedMode = await ref
                                .read(workoutRepositoryProvider)
                                .getLastSetModeForExercise(newDC.id);
                            final initialSetMode =
                                storedMode ?? _defaultSetMode(newDC);
                            if (!mounted) return;
                            setState(() {
                              final replaced = _exercises[exIndex].copyWith(
                                exerciseDC: newDC,
                                exercise: _exercises[exIndex].exercise.copyWith(
                                  exerciseDataId: newDC.id,
                                  setMode: initialSetMode,
                                ),
                              );
                              _exercises[exIndex] = replaced;
                            });
                            _saveProgressToDb();
                          }
                        },
                        onSupersetToggle: (exId) {
                          setState(() {
                            final currentSupersetId = eWs.exercise.supersetId;
                            if (currentSupersetId != null) {
                              // Unlink
                              _exercises[exIndex] = eWs.copyWith(
                                exercise: eWs.exercise.copyWith(
                                  supersetId: const Value(null),
                                ),
                              );
                            } else {
                              // Link
                              if (exIndex > 0) {
                                final prevEx = _exercises[exIndex - 1];
                                final prevSupersetId =
                                    prevEx.exercise.supersetId;
                                if (prevSupersetId != null) {
                                  _exercises[exIndex] = eWs.copyWith(
                                    exercise: eWs.exercise.copyWith(
                                      supersetId: Value(prevSupersetId),
                                    ),
                                  );
                                } else {
                                  final maxId = _exercises
                                      .map((e) => e.exercise.supersetId)
                                      .whereType<int>()
                                      .fold<int>(
                                        0,
                                        (m, val) => val > m ? val : m,
                                      );
                                  final newId = maxId + 1;
                                  _exercises[exIndex - 1] = prevEx.copyWith(
                                    exercise: prevEx.exercise.copyWith(
                                      supersetId: Value(newId),
                                    ),
                                  );
                                  _exercises[exIndex] = eWs.copyWith(
                                    exercise: eWs.exercise.copyWith(
                                      supersetId: Value(newId),
                                    ),
                                  );
                                }
                              }
                            }
                          });
                          _saveProgressToDb();
                        },
                      );
                    },
                  ),
            if (settings.isWorkoutHeaderSticky)
              Positioned(top: 16, left: 0, right: 0, child: headerCard),

            // Floating Action Bar / Rest timer bar at bottom
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_restSecondsRemaining > 0) ...[
                    _RestTimerPanel(
                      restSecondsRemaining: _restSecondsRemaining,
                      initialRestTime: _initialRestTime,
                      onIncrement: () => _modifyRestTime(true),
                      onDecrement: () => _modifyRestTime(false),
                      onCancel: () {
                        _restTimer?.cancel();
                        _cancelRestNotification();
                        setState(() {
                          _restSecondsRemaining = 0;
                          _initialRestTime = 0;
                        });
                        showFloatingToast(context, 'Timer canceled');
                      },
                    ),
                  ],

                  // + button (big)
                  FloatingActionButton.extended(
                    heroTag: 'btn_add_ex_workout',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ExercisesScreen(addExercises: true),
                        ),
                      );
                      if (!mounted) return;
                      if (result != null && result is List<ExerciseDataDC>) {
                        for (final dc in result) {
                          await _addExercise(dc);
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add exercise'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension CoerceInt on int {
  int coerceAtLeast(int minVal) => this < minVal ? minVal : this;
}

class _RestTimerPanel extends StatefulWidget {
  final int restSecondsRemaining;
  final int initialRestTime;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onCancel;

  const _RestTimerPanel({
    required this.restSecondsRemaining,
    required this.initialRestTime,
    required this.onIncrement,
    required this.onDecrement,
    required this.onCancel,
  });

  @override
  State<_RestTimerPanel> createState() => _RestTimerPanelState();
}

class _RestTimerPanelState extends State<_RestTimerPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Horizontal adjustment buttons row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'btn_dec_rest',
              shape: const CircleBorder(),
              elevation: 2,
              backgroundColor: theme.colorScheme.tertiaryContainer,
              foregroundColor: theme.colorScheme.onTertiaryContainer,
              onPressed: widget.onDecrement,
              child: const Icon(Icons.remove, size: 18),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: 'btn_inc_rest',
              shape: const CircleBorder(),
              elevation: 2,
              backgroundColor: theme.colorScheme.tertiaryContainer,
              foregroundColor: theme.colorScheme.onTertiaryContainer,
              onPressed: widget.onIncrement,
              child: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Rest timer container — Pentagon background + wavy ring
        GestureDetector(
          onDoubleTap: widget.onCancel,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pentagon fills the full box via Positioned.fill
                Positioned.fill(
                  child: RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        shape: const StarBorder(
                          points: 5,
                          innerRadiusRatio: 0.85,
                          pointRounding: 0.25,
                        ),
                      ),
                    ),
                  ),
                ),

                // Wavy progress ring — change 100 to resize relative to the 150px pentagon
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularWavyProgressIndicator(
                    key: const ValueKey('rest_timer_indicator'),
                    value: widget.initialRestTime > 0
                        ? widget.restSecondsRemaining / widget.initialRestTime
                        : 0.0,
                    color: theme.colorScheme.onTertiaryContainer,
                    backgroundColor: theme.colorScheme.onTertiaryContainer
                        .withValues(alpha: 0.15),
                    strokeWidth: 4.5,
                    waveHeight: 1.5,
                    waveCount: 9,
                  ),
                ),

                // Centered text (non-rotating)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'REST',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onTertiaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.restSecondsRemaining}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
