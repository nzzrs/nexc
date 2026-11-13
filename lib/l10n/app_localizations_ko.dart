// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Nexc';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aboutTitle => 'About';

  @override
  String get tabWorkout => 'Workout';

  @override
  String get tabMeals => 'Meals';

  @override
  String get tabProfile => 'Profile';

  @override
  String get createRoutine => 'Create routine';

  @override
  String get discardRunningWorkoutTitle => 'Discard running workout?';

  @override
  String get discardWorkoutMessage =>
      'Are you sure you want to discard this unsaved, ongoing workout? This action cannot be undone.';

  @override
  String get discard => 'Discard';

  @override
  String get discardWorkoutAndStartRoutineMessage =>
      'Are you sure you want to discard this unsaved, ongoing workout and start this routine instead? This action cannot be undone.';

  @override
  String get discardAndStart => 'Discard & Start';

  @override
  String get startEmptyWorkout => 'Start empty workout';

  @override
  String get resumeWorkout => 'Resume workout';

  @override
  String elapsedTime(String time) {
    return 'Elapsed time: $time';
  }

  @override
  String errorLoadingActiveWorkout(String error) {
    return 'Error loading active workout: $error';
  }

  @override
  String get yourRoutines => 'Your routines';

  @override
  String get aiWorkoutCreator => 'AI Workout Creator';

  @override
  String get aiWorkoutCreatorDisabled =>
      'AI Workout Creator (Disabled in Settings)';

  @override
  String get aiWorkoutGenerationDisabled =>
      'AI workout generation is disabled in Settings.';

  @override
  String get startByCreatingRoutine => 'Start by creating a new routine';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get startRoutine => 'Start routine';

  @override
  String errorLoadingRoutines(String error) {
    return 'Error loading routines: $error';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get selectTheme => 'Select theme';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get materialYou => 'Material You';

  @override
  String get dynamicColorEnabled => 'Dynamic color enabled';

  @override
  String get dynamicColorDisabled => 'Dynamic color disabled';

  @override
  String get showExerciseImages => 'Show exercise images';

  @override
  String get imagesShown => 'Images shown';

  @override
  String get imagesHidden => 'Images hidden';

  @override
  String get generalSettings => 'General settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get unitSystem => 'Unit system';

  @override
  String get selectUnitSystem => 'Select unit system';

  @override
  String get keepScreenOn => 'Keep screen on';

  @override
  String get screenWillStayOn => 'Screen will stay on';

  @override
  String get screenWillTurnOffNormally => 'Screen will turn off normally';

  @override
  String get restTimerSound => 'Rest timer sound';

  @override
  String get soundEnabled => 'Sound enabled';

  @override
  String get soundDisabled => 'Sound disabled';

  @override
  String get restTimerVibration => 'Rest timer vibration';

  @override
  String get vibrationEnabled => 'Vibration enabled';

  @override
  String get vibrationDisabled => 'Vibration disabled';

  @override
  String get stickyWorkoutStatusBar => 'Sticky workout status bar';

  @override
  String get statusBarIsSticky => 'Status bar is sticky';

  @override
  String get statusBarIsNotSticky => 'Status bar is not sticky';

  @override
  String get intensityScale => 'Intensity scale';

  @override
  String get selectIntensityScale => 'Select intensity scale';

  @override
  String get intensityScalesTitle => 'Intensity Scales (RPE & RIR)';

  @override
  String get intensityScalesDescription =>
      '• RPE (Rate of Perceived Exertion): A 1-10 scale measuring how hard a set felt. 10 is maximum effort (no more reps possible), 9 means you could do 1 more rep, 8 means 2 more, etc.\n\n• RIR (Reps in Reserve): The number of reps you could have performed before hitting failure. 0 RIR is equivalent to 10 RPE.\n\nUse them to monitor and adjust intensity dynamically without always going to absolute muscle failure.';

  @override
  String get intensityScaleNone => 'None (disabled)';

  @override
  String get intensityScaleRpe => 'RPE';

  @override
  String get intensityScaleRir => 'RIR';

  @override
  String get intensityScaleBoth => 'Both';

  @override
  String get updateRoutineAfterWorkout => 'Update routine after workout';

  @override
  String get routineUpdateNever => 'Never';

  @override
  String get routineUpdateAlways => 'Always';

  @override
  String get routineUpdateAsk => 'Ask';

  @override
  String get scrollWheelInput => 'Scroll wheel input';

  @override
  String get tapValueToOpenPicker => 'Tap a value to open the picker';

  @override
  String get inlineTextFields => 'Inline text fields';

  @override
  String get dismissScrollWheelAutomatically =>
      'Dismiss scroll wheel automatically';

  @override
  String get closesAfterShortPause => 'Closes after a short pause';

  @override
  String get confirmWithDone => 'Confirm with Done';

  @override
  String get dataAndConfiguration => 'Data & Configuration';

  @override
  String get measurementsSettings => 'Measurements Settings';

  @override
  String get configureMeasurementsDesc =>
      'Configure which measurements to track';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get backupAndRestoreDesc => 'Backup and restore your data';

  @override
  String get featuresConfiguration => 'Features Configuration';

  @override
  String get mealTracking => 'Meal Tracking';

  @override
  String get mealTrackingEnabled => 'Meal tracking enabled';

  @override
  String get mealTrackingDisabled => 'Meal tracking disabled';

  @override
  String get dayStartHour => 'Day start hour';

  @override
  String newDayStartsAt(String time) {
    return 'New day starts at $time:00';
  }

  @override
  String get defaultMacrosOverridePlans => 'Default macros override plans';

  @override
  String get defaultMacrosOverrideEnabledDesc =>
      'Default target macros always override meal plan targets';

  @override
  String get defaultMacrosOverrideDisabledDesc =>
      'Meal plan targets take precedence when available';

  @override
  String get stockTracking => 'Stock Tracking';

  @override
  String get requiresMealTracking => 'Requires Meal Tracking';

  @override
  String get stockTrackingEnabled => 'Stock tracking enabled';

  @override
  String get stockTrackingDisabled => 'Stock tracking disabled';

  @override
  String get aiIntegrations => 'AI Integrations';

  @override
  String get aiStockLogging => 'AI Stock Logging';

  @override
  String get aiStockLoggingDesc => 'Log stock via receipt photo uploads';

  @override
  String get aiProductCreation => 'AI Product Creation';

  @override
  String get aiProductCreationDesc =>
      'Autofill nutrition details using AI predictions';

  @override
  String get aiFeaturesAndPrivacy => 'AI Features & Privacy';

  @override
  String get aiWorkoutGenerationEnabledDesc =>
      'AI assisted workout generation enabled';

  @override
  String get aiWorkoutGenerationDisabledDesc =>
      'AI assisted workout generation disabled';

  @override
  String get includeUserStatistics => 'Include User Statistics';

  @override
  String get includeUserStatisticsEnabledDesc =>
      'Workout volume, streak & metrics shared';

  @override
  String get includeUserStatisticsDisabledDesc =>
      'User statistics hidden from AI';

  @override
  String get includeMealHistory => 'Include Meal History';

  @override
  String get includeMealHistoryEnabledDesc =>
      'Recent nutrition & logged meals shared';

  @override
  String get includeMealHistoryDisabledDesc => 'Meal history hidden from AI';

  @override
  String get includeWorkoutHistory => 'Include Workout History';

  @override
  String get includeWorkoutHistoryEnabledDesc =>
      'Completed workouts & routine records shared';

  @override
  String get includeWorkoutHistoryDisabledDesc =>
      'Workout history hidden from AI';

  @override
  String get includeUserPreferences => 'Include User Preferences';

  @override
  String get includeUserPreferencesEnabledDesc =>
      'Equipment & personal training notes shared';

  @override
  String get includeUserPreferencesDisabledDesc =>
      'User preferences hidden from AI';

  @override
  String get includeMeasurements => 'Include Measurements';

  @override
  String get includeMeasurementsEnabledDesc =>
      'Weight & body measurements shared';

  @override
  String get includeMeasurementsDisabledDesc => 'Measurements hidden from AI';

  @override
  String get aiApiConfiguration => 'AI API Configuration';

  @override
  String get apiProvider => 'API Provider';

  @override
  String get geminiApi => 'Gemini API (AI Studio)';

  @override
  String get openRouter => 'OpenRouter';

  @override
  String get apiTokenKey => 'API Token / Key';

  @override
  String get modelName => 'Model Name';

  @override
  String get languageSystem => 'System';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageCatalan => 'Catalan';

  @override
  String get languageCzech => 'Czech';

  @override
  String get languageGerman => 'German';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGalician => 'Galician';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageKorean => 'Korean';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get languagePolish => 'Polish';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languagePortugueseBrazil => 'Portuguese (Brazil)';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageSwedish => 'Swedish';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get languageUrdu => 'Urdu';

  @override
  String get languageSimplifiedChinese => 'Simplified Chinese';

  @override
  String get unitSystemMetric => 'Metric';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String versionWithBuild(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get loadingVersion => 'Loading version…';

  @override
  String get info => 'Info';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDescription => 'No data leaves your device. Ever.';

  @override
  String get privacyPolicyBody =>
      'Nexc does not collect, store, or transmit any personal data. All workout and nutrition data is stored exclusively on your device in a local database. No analytics, no crash reporting services, no third-party SDKs that phone home.\n\nYour data is your data.';

  @override
  String get gotIt => 'Got it';

  @override
  String get license => 'License';

  @override
  String get licenseDescription => 'GNU General Public License v3.0';

  @override
  String get licenseLegalese =>
      '© 2026 Nexc Contributors\nBased on LibreFit © IamDg and the LibreFit Contributors\nLicensed under the GNU General Public License v3.0';

  @override
  String get github => 'GitHub';

  @override
  String get githubDescription => 'View source code on GitHub';

  @override
  String get attribution => 'Attribution';

  @override
  String get libreFitName => 'LibreFit';

  @override
  String get libreFitDescription =>
      'The open-source project Nexc is based on — by IamDg and contributors';

  @override
  String get contact => 'Contact';

  @override
  String get reportBug => 'Report a bug';

  @override
  String get reportBugDescription => 'Open an issue on GitHub';

  @override
  String get suggestFeature => 'Suggest a feature';

  @override
  String get suggestFeatureDescription => 'Open a discussion on GitHub';

  @override
  String get madeWithLove => 'Made with ❤️ — built on the shoulders of giants.';

  @override
  String get plateCalculator => 'Plate calculator';

  @override
  String get unlinkSuperset => 'Unlink superset';

  @override
  String get linkSuperset => 'Link superset';

  @override
  String get replaceExercise => 'Replace exercise';

  @override
  String get machineBusy => 'Machine busy';

  @override
  String get notes => 'Notes';

  @override
  String get restTimeLabel => 'Rest time: ';

  @override
  String get type => 'Type';

  @override
  String get setColumn => 'Set';

  @override
  String get previousColumn => 'Previous';

  @override
  String get timeColumn => 'Time';

  @override
  String get weightColumn => 'Weight';

  @override
  String get repsColumn => 'Reps';

  @override
  String get rpe => 'RPE';

  @override
  String get rir => 'RIR';

  @override
  String get addSet => 'Add set';

  @override
  String decreaseBy(String amount) {
    return 'Decrease by $amount';
  }

  @override
  String increaseBy(String amount) {
    return 'Increase by $amount';
  }

  @override
  String get bar => 'Bar';

  @override
  String get targetWeight => 'Target weight';

  @override
  String get includeSmallPlates => 'Include small plates';

  @override
  String get perSide => 'Per side';

  @override
  String get noPlatesNeeded => 'No plates needed';

  @override
  String cannotHitExactly(String remainder) {
    return 'Cannot hit exactly — $remainder left over per side';
  }

  @override
  String closestAchievable(String weight) {
    return 'Closest achievable: $weight';
  }

  @override
  String plateCount(int count) {
    return '× $count';
  }

  @override
  String get updateRoutineTitle => 'Update routine?';

  @override
  String get updateRoutineMessage =>
      'Copy the values of the completed sets into your routine?';

  @override
  String get dontUpdate => 'Don\'t update';

  @override
  String get update => 'Update';

  @override
  String get activeWorkoutChannel => 'Active Workout';

  @override
  String get activeWorkoutChannelDesc =>
      'Keeps workout stopwatch running in background';

  @override
  String get workoutInProgress => 'Workout in Progress';

  @override
  String durationWithTime(String time) {
    return 'Duration: $time';
  }

  @override
  String get restTimerChannel => 'Rest Timer';

  @override
  String get restTimerChannelDesc => 'Notifications for active rest timer';

  @override
  String get resting => 'Resting...';

  @override
  String secondsRemaining(int count) {
    return '$count seconds remaining';
  }

  @override
  String get restTimerFinishedChannel => 'Rest Timer Finished';

  @override
  String get restTimerFinishedChannelDesc =>
      'Notifications when rest timer is done';

  @override
  String get restFinished => 'Rest Finished';

  @override
  String get restFinishedBody => 'Time to start your next set!';

  @override
  String get finishWorkoutTitle => 'Finish Workout?';

  @override
  String completedSetsRatio(int completed, int total) {
    return 'Completed: $completed/$total sets';
  }

  @override
  String get saveAction => 'SAVE';

  @override
  String setsRatio(int completed, int total) {
    return 'Sets: $completed/$total';
  }

  @override
  String get doneAction => 'DONE';

  @override
  String get emptyWorkoutHint =>
      'Your workout is empty. Tap Add Exercise below.';

  @override
  String get doneReordering => 'Done Reordering';

  @override
  String get reorderExercises => 'Reorder Exercises';

  @override
  String pushedExerciseForLater(String name) {
    return 'Pushed \"$name\" for later';
  }

  @override
  String get timerCanceled => 'Timer canceled';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get restTimerBadge => 'REST';

  @override
  String get workoutSummaryTitle => 'Workout Summary';

  @override
  String get workoutCompleted => 'Workout Completed!';

  @override
  String get volumeLabel => 'Volume';

  @override
  String get durationLabel => 'Duration';

  @override
  String get setsCompletedLabel => 'Sets Completed';

  @override
  String get hardSetsSummaryLabel => 'Hard Sets';

  @override
  String get exercisesLabel => 'Exercises';

  @override
  String densityWithValue(String value) {
    return 'Density: $value';
  }

  @override
  String focusWithValue(String value) {
    return 'Focus: $value';
  }

  @override
  String get exerciseBreakdown => 'Exercise Breakdown';

  @override
  String e1rmWithValue(String value) {
    return 'e1RM: $value';
  }

  @override
  String volumeWithValue(String value) {
    return 'Volume: $value';
  }

  @override
  String get detailedSummaryCopied => 'Detailed summary copied to clipboard';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get deleteRoutineTitle => 'Delete Routine?';

  @override
  String get deleteWorkoutTitle => 'Delete Workout?';

  @override
  String get deleteRoutineMessage =>
      'Are you sure you want to delete this routine? This action cannot be undone.';

  @override
  String get deleteWorkoutMessage =>
      'Are you sure you want to delete this workout? This action cannot be undone.';

  @override
  String get unlinkRoutineTitle => 'Unlink Routine?';

  @override
  String get unlinkRoutineMessage =>
      'Are you sure you want to unlink this workout from its routine?';

  @override
  String get unlink => 'Unlink';

  @override
  String get routineLabel => 'Routine';

  @override
  String durationMinutes(int minutes) {
    return 'Duration: $minutes min';
  }

  @override
  String createdWithDate(String date) {
    return 'Created: $date';
  }

  @override
  String completedWithDate(String date) {
    return 'Completed: $date';
  }

  @override
  String exercisesWithCount(int count) {
    return 'Exercises: $count';
  }

  @override
  String totalSetsCount(int count) {
    return 'Total sets: $count';
  }

  @override
  String completedSetsCount(int count) {
    return 'Completed sets: $count';
  }

  @override
  String get linkedRoutine => 'Linked routine';

  @override
  String get openThisRoutine => 'Open this routine';

  @override
  String get performance => 'Performance';

  @override
  String get tonnageLabel => 'Tonnage';

  @override
  String get densityLabel => 'Density';

  @override
  String get hardSetsMetricLabel => 'Hard sets';

  @override
  String get primaryMuscleLabel => 'Primary muscle';

  @override
  String get bestE1rmLabel => 'Best e1RM';

  @override
  String setNumber(int number) {
    return 'Set $number';
  }

  @override
  String repsCount(int count) {
    return '$count reps';
  }

  @override
  String rpeWithValue(String value) {
    return '  (RPE $value)';
  }

  @override
  String rirWithValue(String value) {
    return '  (RIR $value)';
  }

  @override
  String routineSavedToRoutines(String title) {
    return 'Routine \"$title\" saved to your routines!';
  }

  @override
  String get view => 'View';

  @override
  String failedToSaveRoutine(String error) {
    return 'Failed to save routine: $error';
  }

  @override
  String get aiPreferences => 'AI Preferences';

  @override
  String get aiGenerationTurnedOff =>
      'AI assisted workout generation is turned off in Settings.';

  @override
  String get enableAction => 'ENABLE';

  @override
  String exercisesWithList(int count, String list) {
    return '$count Exercises: $list';
  }

  @override
  String get routineSaved => 'Routine Saved';

  @override
  String get saveAsRoutine => 'Save as Routine';

  @override
  String get aiCoachThinking => 'AI coach is thinking...';

  @override
  String get askOrCreateWorkout => 'Ask or create a workout...';

  @override
  String get aiGenerationDisabledHint => 'AI generation disabled in Settings';

  @override
  String get addExercisesTitle => 'Add Exercises';

  @override
  String get replaceExerciseTitle => 'Replace Exercise';

  @override
  String get selectExercise => 'Select Exercise';

  @override
  String addCount(int count) {
    return 'ADD ($count)';
  }

  @override
  String get searchExercise => 'Search exercise...';

  @override
  String get levelLabel => 'Level';

  @override
  String levelWithValue(String value) {
    return 'Level: $value';
  }

  @override
  String get selectLevel => 'Select Level';

  @override
  String get forceLabel => 'Force';

  @override
  String forceWithValue(String value) {
    return 'Force: $value';
  }

  @override
  String get selectForce => 'Select Force';

  @override
  String get mechanicLabel => 'Mechanic';

  @override
  String mechanicWithValue(String value) {
    return 'Mechanic: $value';
  }

  @override
  String get selectMechanic => 'Select Mechanic';

  @override
  String get equipmentLabel => 'Equipment';

  @override
  String equipmentWithValue(String value) {
    return 'Equipment: $value';
  }

  @override
  String get selectEquipment => 'Select Equipment';

  @override
  String get muscleLabel => 'Muscle';

  @override
  String muscleWithValue(String value) {
    return 'Muscle: $value';
  }

  @override
  String get selectMuscle => 'Select Muscle';

  @override
  String get categoryLabel => 'Category';

  @override
  String categoryWithValue(String value) {
    return 'Category: $value';
  }

  @override
  String get selectCategory => 'Select Category';

  @override
  String get customOnly => 'Custom Only';

  @override
  String get reset => 'Reset';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get noExercisesFound => 'No exercises found';

  @override
  String get createExercise => 'Create Exercise';

  @override
  String get createWithAi => 'Create with AI';

  @override
  String get aiMatch => 'AI MATCH';

  @override
  String exerciseSubtitle(String category, String equipment, String muscles) {
    return '$category • $equipment • $muscles';
  }

  @override
  String get noEquipment => 'No Equipment';

  @override
  String get aiSuggestions => 'AI SUGGESTIONS (SIMILAR MUSCLES)';

  @override
  String get allExercises => 'ALL EXERCISES';

  @override
  String get all => 'All';

  @override
  String get createCustomExercise => 'Create Custom Exercise';

  @override
  String get exerciseName => 'Exercise Name';

  @override
  String get primaryMuscleField => 'Primary Muscle';

  @override
  String get cancelAction => 'CANCEL';

  @override
  String get describeExerciseHint =>
      'Describe exercise (e.g. Dumbbell rear delt fly on incline bench)';

  @override
  String get generateAction => 'GENERATE';

  @override
  String get generatingExerciseWithAi => 'Generating exercise with AI...';

  @override
  String get exerciseDetails => 'Exercise Details';

  @override
  String get detailsTab => 'Details';

  @override
  String get instructionsTab => 'Instructions';

  @override
  String get primaryMusclesWorked => 'Primary Muscles Worked';

  @override
  String get secondaryMusclesWorked => 'Secondary Muscles Worked';

  @override
  String get discardChangesTitle => 'Discard Changes?';

  @override
  String get discardChangesMessage =>
      'Do you want to discard your changes or save them?';

  @override
  String get enterRoutineTitle => 'Please enter a routine title';

  @override
  String get createRoutineTitle => 'Create Routine';

  @override
  String get editRoutineTitle => 'Edit Routine';

  @override
  String get routineTitleField => 'Routine title';

  @override
  String get routineNotesField => 'Routine notes';

  @override
  String get noExercisesAdded =>
      'No exercises added yet. Tap Add Exercise below.';

  @override
  String get addExerciseTitle => 'Add Exercise';

  @override
  String get discardAction => 'DISCARD';
}
