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
import '../../core/integrations/ai_service.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/db/workout_repository.dart';
import '../../core/db/meal_repository.dart';
import '../../core/db/measurement_repository.dart';
import '../../core/db/enums.dart';

class WorkoutAiChatScreen extends ConsumerStatefulWidget {
  const WorkoutAiChatScreen({super.key});

  @override
  ConsumerState<WorkoutAiChatScreen> createState() => _WorkoutAiChatScreenState();
}

class _WorkoutAiChatScreenState extends ConsumerState<WorkoutAiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'model',
      'content': 'Hi! I am your AI Workout Assistant. Tell me what kind of workout routine or guidance you need today, and I will tailor it based on your fitness preferences and history.',
    }
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _scrollToBottom();

    final settings = ref.read(settingsProvider);
    final repo = ref.read(workoutRepositoryProvider);

    // Fetch context according to user settings
    String? workoutSummary;
    if (settings.aiAllowWorkoutHistory) {
      final workouts = await repo.getCompletedWorkoutsWithExercisesAndSetsFromRoutine(0);
      if (workouts.isNotEmpty) {
        workoutSummary = '${workouts.length} past workouts recorded. Recent workout: ${workouts.first.workout.title} with ${workouts.first.exercisesWithSets.length} exercises.';
      }
    }

    String? mealSummary;
    if (settings.aiAllowMealHistory) {
      final mealPlans = await ref.read(mealRepositoryProvider).getMealPlansWithMealsAndItemsByState(MealPlanState.LOGGED).first;
      if (mealPlans.isNotEmpty) {
        final recentPlan = mealPlans.first;
        mealSummary = '${mealPlans.length} logged meal plans. Recent: ${recentPlan.mealPlan.title} (${recentPlan.meals.length} meals).';
      }
    }

    String? statsSummary;
    if (settings.aiAllowUserStats) {
      final allCompleted = await repo.watchWorkoutsWithExercisesAndSetsByState(WorkoutState.COMPLETED).first;
      statsSummary = 'Total completed workouts: ${allCompleted.length}.';
    }

    String? measurementsSummary;
    if (settings.aiAllowMeasurements) {
      final measurements = await ref.read(measurementRepositoryProvider).getAllMeasurements().first;
      if (measurements.isNotEmpty) {
        final last = measurements.first;
        measurementsSummary = 'Latest body weight: ${last.bodyWeight} kg on ${last.date.month}/${last.date.day}/${last.date.year}.';
      }
    }

    final contextPrompt = AIService.assembleWorkoutAiPrompt(
      aiWorkoutGenerationEnabled: settings.aiWorkoutGenerationEnabled,
      aiAllowUserPreferences: settings.aiAllowUserPreferences,
      userPreferences: settings.userPreferences,
      aiAllowWorkoutHistory: settings.aiAllowWorkoutHistory,
      workoutHistorySummary: workoutSummary,
      aiAllowMealHistory: settings.aiAllowMealHistory,
      mealHistorySummary: mealSummary,
      aiAllowUserStats: settings.aiAllowUserStats,
      statisticsSummary: statsSummary,
      aiAllowMeasurements: settings.aiAllowMeasurements,
      measurementsSummary: measurementsSummary,
    );

    final historyForApi = _messages.sublist(0, _messages.length - 1);

    final response = await AIService.chatWithWorkoutAssistant(
      provider: settings.aiProvider,
      apiKey: settings.aiToken,
      model: settings.aiModel,
      userContext: contextPrompt,
      conversationHistory: historyForApi,
      userMessage: text,
    );

    if (!mounted) return;

    setState(() {
      _messages.add({'role': 'model', 'content': response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Workout Creator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'AI Preferences',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!settings.enableAiWorkoutAssistant)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.errorContainer,
              child: Text(
                'AI assisted workout generation is turned off in Settings.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      message['content'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Ask or create a workout...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
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
