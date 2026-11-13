// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

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

  @override
  String get notificationPermissionTitle => 'Stay on Track';

  @override
  String get notificationPermissionMessage =>
      'Nexc needs notification permission to alert you when your rest timer finishes, keeping your workouts focused and efficient.';

  @override
  String get notNow => 'Not now';

  @override
  String get allow => 'Allow';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get selectDayHint => 'Select a day to view workouts';

  @override
  String get workoutNoun => 'workout';

  @override
  String get workoutsNoun => 'workouts';

  @override
  String get restDayNoWorkouts => 'Rest day — no workouts logged';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String calendarDate(String weekday, String month, int day) {
    return '$weekday, $month $day';
  }

  @override
  String setsCompletedRatio(int completed, int total) {
    return '$completed/$total sets completed';
  }

  @override
  String get exerciseNoun => 'exercise';

  @override
  String get exercisesNoun => 'exercises';

  @override
  String moreCount(int count) {
    return '+$count more';
  }

  @override
  String get replaceMealItem => 'Replace Meal Item';

  @override
  String get addItemToMeal => 'Add Item to Meal';

  @override
  String addItemsSelected(int count) {
    return 'Add Items ($count selected)';
  }

  @override
  String get productsTab => 'Products';

  @override
  String get recipesTab => 'Recipes';

  @override
  String get createProduct => 'Create Product';

  @override
  String get createRecipe => 'Create Recipe';

  @override
  String get searchFoodOrProduct => 'Search food or product...';

  @override
  String get searchRecipes => 'Search recipes...';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get inStock => 'In Stock';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get noRecipesFound => 'No recipes found';

  @override
  String ingredientsCount(int count) {
    return '$count ingredients';
  }

  @override
  String get editRecipe => 'Edit Recipe';

  @override
  String get gramsLabel => 'Grams';

  @override
  String get unitsLabel => 'Units';

  @override
  String get portionAmount => 'Portion Amount';

  @override
  String get replaceAction => 'Replace';

  @override
  String addAllCount(int count) {
    return 'Add All ($count)';
  }

  @override
  String get addToMeal => 'Add to Meal';

  @override
  String macrosCompact(String protein, String carbs, String fats) {
    return '${protein}g P | ${carbs}g C | ${fats}g F';
  }

  @override
  String get addProduct => 'Add Product';

  @override
  String get nameLabel => 'Name';

  @override
  String get autofillWithAi => 'Autofill with AI';

  @override
  String get enterProductNameFirst => 'Enter a product name first';

  @override
  String get autofilledProductDetails => 'Autofilled product details!';

  @override
  String aiError(String error) {
    return 'AI Error: $error';
  }

  @override
  String get defaultUnitsLabel => 'Default Units';

  @override
  String get mlToGFactorRequired => 'ml to g factor *';

  @override
  String get mlToGFactorLabel => 'ml to g factor';

  @override
  String get requiredForMlProducts => 'Required for ml-based products';

  @override
  String get unitWeightGRequired => 'Unit weight (g) *';

  @override
  String get unitWeightGLabel => 'Unit weight (g)';

  @override
  String get requiredForUnitsProducts =>
      'Required for products measured in units';

  @override
  String get ediblePercentLabel => 'Edible %';

  @override
  String get macrosEnergyPer100g => 'Macros & Energy (per 100g)';

  @override
  String get caloriesKcal => 'Calories (kcal)';

  @override
  String get proteinsG => 'Proteins (g)';

  @override
  String get carbsAvailableG => 'Carbs Available (g)';

  @override
  String get carbsByDiffG => 'Carbs By Diff (g)';

  @override
  String get fatsG => 'Fats (g)';

  @override
  String get dietaryFiberG => 'Dietary Fiber (g)';

  @override
  String get isSupplementLabel => 'Is Supplement';

  @override
  String get isPortableLabel => 'Is Portable';

  @override
  String get isStockRawLabel => 'Is Stock Raw';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get validationMlFactor =>
      'Add a positive \"ml to g factor\" so portions measured in ml can be converted to grams.';

  @override
  String get validationUnitWeight =>
      'Add a positive \"Unit weight (g)\" so portions measured in units can be converted to grams.';

  @override
  String get addRecipe => 'Add Recipe';

  @override
  String get save => 'Save';

  @override
  String get instructionsProcess => 'Instructions/Process';

  @override
  String get isPortableNonPortable =>
      'Is Portable (Contains non-portable ingredients)';

  @override
  String get composition => 'Composition';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get searchIngredient => 'Search Ingredient...';

  @override
  String get amountLabel => 'Amount';

  @override
  String get addAction => 'Add';

  @override
  String ingredientLine(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String get removeIngredient => 'Remove ingredient';

  @override
  String get enterRecipeName => 'Enter a recipe name';

  @override
  String get titleCannotBeEmpty => 'Title cannot be empty';

  @override
  String get mealPlanSaved => 'Meal plan saved';

  @override
  String get createMealPlan => 'Create Meal Plan';

  @override
  String get editMealPlan => 'Edit Meal Plan';

  @override
  String get planTitle => 'Plan Title';

  @override
  String get notesGoal => 'Notes/Goal';

  @override
  String get targetMacros => 'Target Macros';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String get carbsG => 'Carbs (g)';

  @override
  String sumGrams(String value) {
    return 'Sum: ${value}g';
  }

  @override
  String get mealsLabel => 'Meals';

  @override
  String mealNumber(int number) {
    return 'Meal $number';
  }

  @override
  String get addMeal => 'Add Meal';

  @override
  String get deleteMeal => 'Delete Meal';

  @override
  String deleteMealConfirm(String name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String get unknownProduct => 'Unknown Product';

  @override
  String get unknownRecipe => 'Unknown Recipe';

  @override
  String get editItem => 'Edit Item';

  @override
  String get selectActionForItem => 'Select an action for this item.';

  @override
  String get addItem => 'Add Item';

  @override
  String get mealItemFallback => 'Meal Item';

  @override
  String get chooseActionForItem =>
      'Choose an action for this item in today\'s meal log:';

  @override
  String get addSnack => 'Add Snack';

  @override
  String get todayPlanTab => 'Today\'s plan';

  @override
  String get mealPlansTab => 'Meal plans';

  @override
  String get selectMealPlanForToday => 'Select a meal plan for today';

  @override
  String get goToMealPlans => 'Go to Meal Plans';

  @override
  String get startLogging => 'Start Logging';

  @override
  String get discardTodayMeals => 'Discard Today\'s Meals';

  @override
  String get discardTodayMealsMessage =>
      'Are you sure you want to discard today\'s meals log? This cannot be undone.';

  @override
  String get saveTodayMeals => 'Save Today\'s Meals';

  @override
  String get saveTodayMealsMessage =>
      'This will save all items marked as eaten to your logs and remove any uneaten items. Proceed?';

  @override
  String get todayMealsLogged => 'Today\'s meals logged successfully!';

  @override
  String get noMealPlansYet => 'No meal plans yet';

  @override
  String get deleteMealPlan => 'Delete Meal Plan';

  @override
  String deleteMealPlanConfirm(String title) {
    return 'Are you sure you want to delete \'$title\'?';
  }

  @override
  String get changeMealPlan => 'Change Meal Plan?';

  @override
  String get changeMealPlanMessage =>
      'Changing today\'s plan will discard all food currently logged for today. Proceed?';

  @override
  String get proceed => 'Proceed';

  @override
  String get todaysMacros => 'Today\'s Macros';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get carbsLabel => 'Carbs';

  @override
  String get fatsLabel => 'Fats';

  @override
  String get portable => 'Portable';

  @override
  String get homeOnly => 'Home only';

  @override
  String get atHome => 'At Home';

  @override
  String get outside => 'Outside';

  @override
  String edibleEquivalent(String amount) {
    return '≈ ${amount}g edible';
  }

  @override
  String get editDailyMacroGoals => 'Edit Daily Macro Goals';

  @override
  String scheduledMeals(int count, String names) {
    return '$count scheduled meals ($names)';
  }

  @override
  String get selectedLabel => 'Selected';

  @override
  String get selectLabel => 'Select';

  @override
  String macroChip(String label, String value) {
    return '$label: $value';
  }

  @override
  String get addNoteHint => 'Add note...';

  @override
  String get addItemToMealLower => 'Add item to meal';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String deleteProductConfirm(String name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String get supplement => 'Supplement';

  @override
  String protGrams(String value) {
    return 'Prot: ${value}g';
  }

  @override
  String carbGrams(String value) {
    return 'Carb: ${value}g';
  }

  @override
  String fatGrams(String value) {
    return 'Fat: ${value}g';
  }

  @override
  String defaultWithValue(String value) {
    return 'Default: $value';
  }

  @override
  String get deleteRecipe => 'Delete Recipe';

  @override
  String deleteRecipeConfirm(String name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String macrosPrefixLine(String protein, String carbs, String fats) {
    return 'Macros: P ${protein}g | C ${carbs}g | F ${fats}g';
  }

  @override
  String ingredientWithAmount(String name, String amount) {
    return '$name ($amount)';
  }

  @override
  String get selectProduct => 'Select Product';

  @override
  String usedCount(int count) {
    return 'Used ${count}x';
  }

  @override
  String unitWithValue(String value) {
    return 'Unit: $value';
  }

  @override
  String macrosShort(String protein, String carbs, String fats) {
    return 'P ${protein}g | C ${carbs}g | F ${fats}g';
  }

  @override
  String get inStockBadge => 'In stock';

  @override
  String get mealPlanDetails => 'Meal Plan Details';

  @override
  String get edit => 'Edit';

  @override
  String get mealPlanNotFound => 'Meal plan not found';

  @override
  String get measurementsMenu => 'Measurements';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get statisticsMenu => 'Statistics';

  @override
  String get stockTitle => 'Stock';

  @override
  String get overview => 'Overview';

  @override
  String errorLoadingChart(String error) {
    return 'Error loading chart: $error';
  }

  @override
  String get yourWorkouts => 'Your workouts';

  @override
  String get viewAll => 'View all';

  @override
  String get startCompletingWorkouts =>
      'Start completing workouts to see your history here.';

  @override
  String finishedOnDuration(String date, String duration) {
    return 'Finished on: $date\nDuration: $duration';
  }

  @override
  String get yourMeals => 'Your meals';

  @override
  String get noMealLogHistory => 'No meal log history yet';

  @override
  String eatenOn(String date) {
    return 'Eaten on: $date';
  }

  @override
  String progressItemsEaten(int consumed, int total) {
    return 'Progress: $consumed / $total items eaten';
  }

  @override
  String get deleteMealLog => 'Delete Meal Log';

  @override
  String get deleteMealLogConfirm =>
      'Are you sure you want to delete this meal log?';

  @override
  String weekStreak(int count) {
    return 'Week Streak: $count';
  }

  @override
  String get superActive => '🔥 Super Active!';

  @override
  String get keepMoving => 'Keep moving!';

  @override
  String get workoutPerformance => 'Workout Performance';

  @override
  String get repsLabel => 'Reps';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String errorLoadingWorkouts(String error) {
    return 'Error loading workouts: $error';
  }

  @override
  String get workoutMetrics => 'Workout Metrics';

  @override
  String get totalWorkouts => 'Total Workouts';

  @override
  String get totalActiveTime => 'Total Active Time';

  @override
  String minutesValue(String minutes) {
    return '$minutes mins';
  }

  @override
  String get averageSession => 'Average Session';

  @override
  String get targetedMusclesHeatmap => 'Targeted Muscles Heatmap';

  @override
  String get topTargetMuscles => 'Top Target Muscles';

  @override
  String get noMuscleData =>
      'No muscle targeting data yet. Start tracking sets!';

  @override
  String timesCount(int count) {
    return '$count times';
  }

  @override
  String errorLoadingNutrition(String error) {
    return 'Error loading nutrition: $error';
  }

  @override
  String nutritionInsights(int days) {
    return 'Nutrition Insights (Last $days logs)';
  }

  @override
  String get avgCalories => 'Avg. Calories';

  @override
  String get avgProtein => 'Avg. Protein';

  @override
  String get avgCarbs => 'Avg. Carbs';

  @override
  String get avgFats => 'Avg. Fats';

  @override
  String get macrosDistribution => 'Macros Distribution';

  @override
  String get noMacroData => 'No macro data available';

  @override
  String gramsPercent(String grams, String percent) {
    return '$grams ($percent)';
  }

  @override
  String get logMeasurement => 'Log Measurement';

  @override
  String bodyWeightWithUnit(String unit) {
    return 'Body Weight ($unit)';
  }

  @override
  String get advancedBodyMetrics => 'Advanced Body Metrics';

  @override
  String get bodyFatPercent => 'Body Fat %';

  @override
  String get muscleMassPercent => 'Muscle Mass %';

  @override
  String get waistCm => 'Waist (cm)';

  @override
  String get sleepMetrics => 'Sleep Metrics';

  @override
  String get sleepDuration => 'Sleep Duration';

  @override
  String get sleepingRhr => 'Sleeping RHR';

  @override
  String get sleepingHrvMs => 'Sleeping HRV (ms)';

  @override
  String get advancedSleepMetrics => 'Advanced Sleep Metrics';

  @override
  String get timeInBed => 'Time in Bed';

  @override
  String get totalAwakeTime => 'Total Awake Time';

  @override
  String get longestAwakePeriod => 'Longest Awake Period';

  @override
  String get numberOfAwakenings => 'Number of Awakenings';

  @override
  String get activityMetrics => 'Activity Metrics';

  @override
  String get dailySteps => 'Daily Steps';

  @override
  String get vo2Max => 'VO2 Max';

  @override
  String get wakingRhr => 'Waking RHR';

  @override
  String get wakingHrvMs => 'Waking HRV (ms)';

  @override
  String get saveMeasurement => 'Save Measurement';

  @override
  String get hrsShort => 'Hrs';

  @override
  String get minShort => 'Min';

  @override
  String get weightProgress => 'Weight Progress';

  @override
  String get waistCircumference => 'Waist Circumference';

  @override
  String get bodyHistory => 'Body History';

  @override
  String get noBodyMeasurements => 'No body measurements recorded yet.';

  @override
  String weightWithValue(String value) {
    return 'Weight: $value';
  }

  @override
  String dateWithValue(String date) {
    return 'Date: $date';
  }

  @override
  String get deleteLog => 'Delete log?';

  @override
  String get deleteWeightConfirm =>
      'Are you sure you want to delete this weight measurement?';

  @override
  String get deleteAdvancedBodyConfirm =>
      'Are you sure you want to delete this advanced body log?';

  @override
  String get deleteSleepConfirm =>
      'Are you sure you want to delete this sleep log?';

  @override
  String get deleteAdvancedSleepConfirm =>
      'Are you sure you want to delete this advanced sleep log?';

  @override
  String get deleteActivityConfirm =>
      'Are you sure you want to delete this activity log?';

  @override
  String get advancedEntry => 'Advanced Entry';

  @override
  String get sleepHistory => 'Sleep History';

  @override
  String get noSleepLogs => 'No sleep logs recorded yet.';

  @override
  String get sleepEntry => 'Sleep Entry';

  @override
  String get advSleepEntry => 'Adv Sleep Entry';

  @override
  String get noActivityLogs => 'No activity logs recorded yet.';

  @override
  String get caloriesActive => 'Calories Active';

  @override
  String get activityHistory => 'Activity History';

  @override
  String get activityEntry => 'Activity Entry';

  @override
  String get latestLabel => 'Latest';

  @override
  String get averageLabel => 'Average';

  @override
  String get minMaxLabel => 'Min/Max';

  @override
  String get measurementsTitle => 'Measurements';

  @override
  String get addLog => 'Add Log';

  @override
  String sleepMetricBed(String value) {
    return '$value Bed';
  }

  @override
  String sleepMetricAwake(String value) {
    return '$value Awake';
  }

  @override
  String sleepMetricLongestAwake(String value) {
    return '$value Longest Awake';
  }

  @override
  String awakeningsCount(int count) {
    return '$count awakenings';
  }

  @override
  String stepsCount(String count) {
    return '$count steps';
  }

  @override
  String kcalValue(String value) {
    return '$value kcal';
  }

  @override
  String get personalInfoSaved => 'Personal information saved successfully';

  @override
  String get preferencesSaved => 'Preferences saved successfully';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get yourProfileMetrics => 'Your Profile Metrics';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String birthdayWithDate(String date) {
    return 'Birthday: $date';
  }

  @override
  String get selectBirthday => 'Select Birthday';

  @override
  String calculatedAge(int age) {
    return 'Calculated Age: $age years old';
  }

  @override
  String get saveDetails => 'Save Details';

  @override
  String get userPreferencesTitle => 'User Preferences';

  @override
  String get aiPreferencesContext =>
      'AI uses this context to tailor workouts and meal plans';

  @override
  String get preferencesHint =>
      'Paste or write your detailed preferences, schedule constraints, fitness goals, or dietary requirements here...';

  @override
  String get savePreferences => 'Save Preferences';

  @override
  String get allMealsTitle => 'All Meals';

  @override
  String get allWorkoutsTitle => 'All Workouts';

  @override
  String get noWorkoutsCompleted => 'No workouts completed yet';

  @override
  String get measurementsSettingsDesc =>
      'Choose which measurement categories to track. Disabled categories won\'t appear in the Measurements view.';

  @override
  String get sleepMeasurements => 'Sleep Measurements';

  @override
  String get sleepMeasurementsDesc => 'Sleep duration, sleeping RHR & HRV';

  @override
  String get advancedSleepMeasurements => 'Advanced Sleep Measurements';

  @override
  String get advancedSleepMeasurementsDesc =>
      'Time in bed, awake time, number of awakenings';

  @override
  String get activityMeasurements => 'Activity Measurements';

  @override
  String get activityMeasurementsDesc =>
      'Steps, active energy, VO2 max, waking RHR/HRV';

  @override
  String get advancedBodyMeasurements => 'Advanced Body Measurements';

  @override
  String get advancedBodyMeasurementsDesc =>
      'Body fat %, muscle mass %, circumferences';

  @override
  String get searchProducts => 'Search products...';

  @override
  String bodyFatValue(String value) {
    return '$value% BF';
  }

  @override
  String muscleMassValue(String value) {
    return '$value% Muscle';
  }

  @override
  String waistValue(String value) {
    return '${value}cm Waist';
  }

  @override
  String sleepingRhrValue(String value) {
    return '$value bpm RHR';
  }

  @override
  String sleepingHrvValue(String value) {
    return '$value ms HRV';
  }

  @override
  String wakingRhrValue(String value) {
    return '$value bpm RHR';
  }

  @override
  String wakingHrvValue(String value) {
    return '$value ms HRV';
  }

  @override
  String vo2WithValue(String value) {
    return 'VO2: $value';
  }

  @override
  String get timeAwake => 'Time Awake';

  @override
  String get wakingHrv => 'Waking HRV';

  @override
  String get sleepingHrv => 'Sleeping HRV';

  @override
  String get addHouse => 'Add House';

  @override
  String get houseName => 'House Name';

  @override
  String get renameHouse => 'Rename House';

  @override
  String get deleteHouse => 'Delete House';

  @override
  String deleteHouseConfirm(String name) {
    return 'Are you sure you want to delete \'$name\'? This deletes all associated stock records.';
  }

  @override
  String get addProductToStockTitle => 'Add Product to Stock';

  @override
  String mapToTitle(String name) {
    return 'Map \'$name\' to...';
  }

  @override
  String get manageHouses => 'Manage Houses';

  @override
  String get noHousesDefined => 'No houses defined';

  @override
  String get operationError => 'An error occurred during operation:';

  @override
  String get copyError => 'Copy Error';

  @override
  String get errorCopied => 'Error copied to clipboard';

  @override
  String get aiTokenNotConfigured =>
      'AI API Token not configured. Set it in Settings.';

  @override
  String get takePhotoCamera => 'Take Photo (Camera)';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get noItemsParsed => 'No items parsed from receipt.';

  @override
  String get receiptImportError => 'Receipt Import Error';

  @override
  String get aiLogConfirmation => 'AI Log Confirmation';

  @override
  String get notFound => 'Not found';

  @override
  String get perfectMatch => 'Perfect Match';

  @override
  String get fuzzyMatch => 'Fuzzy Match';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get unitLabel => 'Unit';

  @override
  String get productEditError => 'Product Edit Error';

  @override
  String get productCreationError => 'Product Creation Error';

  @override
  String get createAction => 'Create';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get loggedReceiptItems => 'Logged receipt items to stock!';

  @override
  String get stockLoggingError => 'Stock Logging Error';

  @override
  String get addStock => 'Add Stock';

  @override
  String get restockItems => 'Restock Items';

  @override
  String restockedItems(int count) {
    return 'Restocked $count items successfully!';
  }

  @override
  String get housePrefix => 'House: ';

  @override
  String get aiImportReceipt => 'AI Import Receipt';

  @override
  String get currentStockTab => 'Current Stock';

  @override
  String get shoppingListTab => 'Shopping List';

  @override
  String get selectOrAddHouse => 'Select or add a house';

  @override
  String get searchStock => 'Search stock...';

  @override
  String get noProductsInStock => 'No products in stock';

  @override
  String edibleEquivalentValue(String value, String unit) {
    return '≈ $value $unit edible equivalent';
  }

  @override
  String get unitPrefix => 'Unit: ';

  @override
  String get noMinimum => 'No minimum';

  @override
  String minimumWithValue(String value, String unit) {
    return 'Minimum: $value $unit';
  }

  @override
  String setTriggerFor(String name) {
    return 'Set Trigger for $name';
  }

  @override
  String minimumThresholdWithUnit(String unit) {
    return 'Minimum Threshold ($unit)';
  }

  @override
  String get leaveEmptyToDisableTrigger => 'Leave empty to disable trigger';

  @override
  String get noItemsNeedRestocking => 'No items need restocking';

  @override
  String stockWithValue(String value) {
    return 'Stock: $value';
  }

  @override
  String stockEdibleSuffix(String value) {
    return ' (≈ $value edible)';
  }

  @override
  String minimumSuffix(String value, String unit) {
    return ' / Minimum: $value $unit';
  }

  @override
  String optionsForItem(String name) {
    return 'Options for $name';
  }

  @override
  String get whatToDoWithItem =>
      'What would you like to do with this stock item?';

  @override
  String get replaceWith => 'Replace with...';

  @override
  String get importFailed => 'Import Failed';

  @override
  String get ok => 'OK';

  @override
  String importedSuccessfully(String entity) {
    return '$entity imported successfully';
  }

  @override
  String get unknownError => 'Unknown error';

  @override
  String get backupRestoreTitle => 'Backup & Restore';

  @override
  String get importFormatDocumentation => 'Import Format Documentation';

  @override
  String get importFormatDocumentationDesc =>
      'Download Markdown import specifications (fields, types, JSON templates) or the active exercise ID list.';

  @override
  String get formatShareSubject => 'Nexc Import Format Specifications';

  @override
  String formatDownloadFailed(String error) {
    return 'Failed to download format file: $error';
  }

  @override
  String get formatMarkdown => 'Format (.md)';

  @override
  String get exerciseListGenerated => 'Exercise list generated';

  @override
  String exerciseListExportFailed(String error) {
    return 'Failed to export exercises list: $error';
  }

  @override
  String get exercisesMarkdown => 'Exercises (.md)';

  @override
  String get databaseTitle => 'Database';

  @override
  String get databaseDesc =>
      'Export or import the full SQLite database containing all workouts, routines, measurements, and foods.';

  @override
  String get databaseExported => 'Database exported successfully';

  @override
  String databaseExportFailed(String error) {
    return 'Database export failed: $error';
  }

  @override
  String get importSuccessful => 'Import Successful';

  @override
  String get importSuccessBody =>
      'The database was imported. Please restart Nexc to load the new data.';

  @override
  String get databaseImportCancelled => 'Database import cancelled';

  @override
  String get workoutPlansTitle => 'Workout plans';

  @override
  String get workoutPlansDesc =>
      'Import or export your workout plan templates as portable JSON files.';

  @override
  String get workoutPlansExported => 'Workout plans exported';

  @override
  String workoutPlansExportFailed(String error) {
    return 'Workout plans export failed: $error';
  }

  @override
  String get workoutHistoryTitle => 'Workout history';

  @override
  String get workoutHistoryDesc =>
      'Import or export your completed workouts history including exercises, weights, reps, and timestamps.';

  @override
  String get workoutHistoryExported => 'Workout history exported';

  @override
  String workoutHistoryExportFailed(String error) {
    return 'Workout history export failed: $error';
  }

  @override
  String get exercisesBackupDesc =>
      'Import or export your exercises database as portable JSON files.';

  @override
  String get exercisesExported => 'Exercises exported';

  @override
  String exercisesExportFailed(String error) {
    return 'Exercises export failed: $error';
  }

  @override
  String get mealPlansTitle => 'Meal plans';

  @override
  String get mealPlansDesc =>
      'Import or export your meal plan templates as portable JSON files.';

  @override
  String get mealPlansExported => 'Meal plans exported';

  @override
  String mealPlansExportFailed(String error) {
    return 'Meal plans export failed: $error';
  }

  @override
  String get mealHistoryTitle => 'Meal history';

  @override
  String get mealHistoryDesc =>
      'Import or export your logged meal history and consumed food items.';

  @override
  String get mealHistoryExported => 'Meal history exported';

  @override
  String mealHistoryExportFailed(String error) {
    return 'Meal history export failed: $error';
  }

  @override
  String get productsBackupDesc =>
      'Import or export your products/foods database.';

  @override
  String get productsExported => 'Products exported';

  @override
  String productsExportFailed(String error) {
    return 'Products export failed: $error';
  }

  @override
  String get recipesBackupDesc =>
      'Import or export your custom recipes database.';

  @override
  String get recipesExported => 'Recipes exported';

  @override
  String recipesExportFailed(String error) {
    return 'Recipes export failed: $error';
  }

  @override
  String get stockBackupDesc =>
      'Import or export your stock inventory and house data. Products must already exist in the database before importing stock.';

  @override
  String get stockExported => 'Stock exported successfully';

  @override
  String stockExportFailed(String error) {
    return 'Stock export failed: $error';
  }

  @override
  String get importAction => 'Import';

  @override
  String get exportAction => 'Export';

  @override
  String get frontView => 'Front View';

  @override
  String get backView => 'Back View';

  @override
  String get sectionProgress => 'Progress';

  @override
  String get sectionBody => 'Body';

  @override
  String get sectionLibrary => 'Library';

  @override
  String get sectionInventory => 'Inventory';

  @override
  String get settingsWorkout => 'Workout';

  @override
  String get settingsNutrition => 'Nutrition';

  @override
  String get settingsHealth => 'Health';

  @override
  String get settingsAi => 'AI';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutDesc => 'Version, licenses and sources';

  @override
  String get moreOptions => 'More options';

  @override
  String get apply => 'Apply';

  @override
  String get retry => 'Retry';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortName => 'Name';

  @override
  String get sortRecent => 'Recent';

  @override
  String get sortMostUsed => 'Most used';

  @override
  String get sortStock => 'In stock first';

  @override
  String get newRoutine => 'New routine';

  @override
  String get addFood => 'Add food';

  @override
  String get newPlan => 'New plan';

  @override
  String get emptyRoutinesTitle => 'No routines yet';

  @override
  String get emptyRoutinesMessage => 'Create a routine to plan your training.';

  @override
  String get emptyHistoryTitle => 'Nothing here yet';

  @override
  String get emptyHistoryMessage => 'Completed sessions will appear here.';

  @override
  String get restAlerts => 'Rest timer alerts';

  @override
  String get restAlertsDesc => 'Sound and vibration when a rest timer ends';

  @override
  String get testAlert => 'Test alert';

  @override
  String get showToken => 'Show key';

  @override
  String get hideToken => 'Hide key';

  @override
  String get testConnection => 'Test connection';

  @override
  String get apiPrivacyNote =>
      'The key stays on this device and is only sent to the provider you choose.';

  @override
  String get mealTrackingDesc => 'Plan meals and track macros';

  @override
  String get stockTrackingDesc => 'Track quantities and shopping needs';

  @override
  String get workoutAlerts => 'Workout alerts';

  @override
  String get aiPermissions => 'What AI can use';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitG => 'g';

  @override
  String get unitMl => 'ml';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLb => 'lb';

  @override
  String get unitCm => 'cm';

  @override
  String get unitBpm => 'bpm';

  @override
  String get unitMs => 'ms';

  @override
  String get unitSteps => 'steps';

  @override
  String get addToLog => 'Add to log';

  @override
  String get logFood => 'Log food';

  @override
  String get remove => 'Remove';

  @override
  String get viewRecipe => 'View recipe';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get instructions => 'Instructions';

  @override
  String get recipePortable => 'Portable';

  @override
  String get recipeHomeOnly => 'Home only';

  @override
  String get history => 'History';

  @override
  String get chartType => 'Chart';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get backupExportFirst => 'Export a backup before importing.';

  @override
  String get aiTryAsking => 'Try asking';

  @override
  String get aiClearChat => 'Clear chat';

  @override
  String get aiRetry => 'Retry';
}
