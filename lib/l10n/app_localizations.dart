import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gl.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ca'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('gl'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('sv'),
    Locale('uk'),
    Locale('ur'),
    Locale('zh'),
    Locale('zh', 'CN'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nexc'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @tabWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get tabWorkout;

  /// No description provided for @tabMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get tabMeals;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @createRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create routine'**
  String get createRoutine;

  /// No description provided for @discardRunningWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard running workout?'**
  String get discardRunningWorkoutTitle;

  /// No description provided for @discardWorkoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard this unsaved, ongoing workout? This action cannot be undone.'**
  String get discardWorkoutMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @discardWorkoutAndStartRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard this unsaved, ongoing workout and start this routine instead? This action cannot be undone.'**
  String get discardWorkoutAndStartRoutineMessage;

  /// No description provided for @discardAndStart.
  ///
  /// In en, this message translates to:
  /// **'Discard & Start'**
  String get discardAndStart;

  /// No description provided for @startEmptyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start empty workout'**
  String get startEmptyWorkout;

  /// No description provided for @resumeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Resume workout'**
  String get resumeWorkout;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed time: {time}'**
  String elapsedTime(String time);

  /// No description provided for @errorLoadingActiveWorkout.
  ///
  /// In en, this message translates to:
  /// **'Error loading active workout: {error}'**
  String errorLoadingActiveWorkout(String error);

  /// No description provided for @yourRoutines.
  ///
  /// In en, this message translates to:
  /// **'Your routines'**
  String get yourRoutines;

  /// No description provided for @aiWorkoutCreator.
  ///
  /// In en, this message translates to:
  /// **'AI Workout Creator'**
  String get aiWorkoutCreator;

  /// No description provided for @aiWorkoutCreatorDisabled.
  ///
  /// In en, this message translates to:
  /// **'AI Workout Creator (Disabled in Settings)'**
  String get aiWorkoutCreatorDisabled;

  /// No description provided for @aiWorkoutGenerationDisabled.
  ///
  /// In en, this message translates to:
  /// **'AI workout generation is disabled in Settings.'**
  String get aiWorkoutGenerationDisabled;

  /// No description provided for @startByCreatingRoutine.
  ///
  /// In en, this message translates to:
  /// **'Start by creating a new routine'**
  String get startByCreatingRoutine;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @startRoutine.
  ///
  /// In en, this message translates to:
  /// **'Start routine'**
  String get startRoutine;

  /// No description provided for @errorLoadingRoutines.
  ///
  /// In en, this message translates to:
  /// **'Error loading routines: {error}'**
  String errorLoadingRoutines(String error);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get selectTheme;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @materialYou.
  ///
  /// In en, this message translates to:
  /// **'Material You'**
  String get materialYou;

  /// No description provided for @dynamicColorEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dynamic color enabled'**
  String get dynamicColorEnabled;

  /// No description provided for @dynamicColorDisabled.
  ///
  /// In en, this message translates to:
  /// **'Dynamic color disabled'**
  String get dynamicColorDisabled;

  /// No description provided for @showExerciseImages.
  ///
  /// In en, this message translates to:
  /// **'Show exercise images'**
  String get showExerciseImages;

  /// No description provided for @imagesShown.
  ///
  /// In en, this message translates to:
  /// **'Images shown'**
  String get imagesShown;

  /// No description provided for @imagesHidden.
  ///
  /// In en, this message translates to:
  /// **'Images hidden'**
  String get imagesHidden;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get generalSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @unitSystem.
  ///
  /// In en, this message translates to:
  /// **'Unit system'**
  String get unitSystem;

  /// No description provided for @selectUnitSystem.
  ///
  /// In en, this message translates to:
  /// **'Select unit system'**
  String get selectUnitSystem;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepScreenOn;

  /// No description provided for @screenWillStayOn.
  ///
  /// In en, this message translates to:
  /// **'Screen will stay on'**
  String get screenWillStayOn;

  /// No description provided for @screenWillTurnOffNormally.
  ///
  /// In en, this message translates to:
  /// **'Screen will turn off normally'**
  String get screenWillTurnOffNormally;

  /// No description provided for @restTimerSound.
  ///
  /// In en, this message translates to:
  /// **'Rest timer sound'**
  String get restTimerSound;

  /// No description provided for @soundEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sound enabled'**
  String get soundEnabled;

  /// No description provided for @soundDisabled.
  ///
  /// In en, this message translates to:
  /// **'Sound disabled'**
  String get soundDisabled;

  /// No description provided for @restTimerVibration.
  ///
  /// In en, this message translates to:
  /// **'Rest timer vibration'**
  String get restTimerVibration;

  /// No description provided for @vibrationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Vibration enabled'**
  String get vibrationEnabled;

  /// No description provided for @vibrationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Vibration disabled'**
  String get vibrationDisabled;

  /// No description provided for @stickyWorkoutStatusBar.
  ///
  /// In en, this message translates to:
  /// **'Sticky workout status bar'**
  String get stickyWorkoutStatusBar;

  /// No description provided for @statusBarIsSticky.
  ///
  /// In en, this message translates to:
  /// **'Status bar is sticky'**
  String get statusBarIsSticky;

  /// No description provided for @statusBarIsNotSticky.
  ///
  /// In en, this message translates to:
  /// **'Status bar is not sticky'**
  String get statusBarIsNotSticky;

  /// No description provided for @intensityScale.
  ///
  /// In en, this message translates to:
  /// **'Intensity scale'**
  String get intensityScale;

  /// No description provided for @selectIntensityScale.
  ///
  /// In en, this message translates to:
  /// **'Select intensity scale'**
  String get selectIntensityScale;

  /// No description provided for @intensityScalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensity Scales (RPE & RIR)'**
  String get intensityScalesTitle;

  /// No description provided for @intensityScalesDescription.
  ///
  /// In en, this message translates to:
  /// **'• RPE (Rate of Perceived Exertion): A 1-10 scale measuring how hard a set felt. 10 is maximum effort (no more reps possible), 9 means you could do 1 more rep, 8 means 2 more, etc.\n\n• RIR (Reps in Reserve): The number of reps you could have performed before hitting failure. 0 RIR is equivalent to 10 RPE.\n\nUse them to monitor and adjust intensity dynamically without always going to absolute muscle failure.'**
  String get intensityScalesDescription;

  /// No description provided for @intensityScaleNone.
  ///
  /// In en, this message translates to:
  /// **'None (disabled)'**
  String get intensityScaleNone;

  /// No description provided for @intensityScaleRpe.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get intensityScaleRpe;

  /// No description provided for @intensityScaleRir.
  ///
  /// In en, this message translates to:
  /// **'RIR'**
  String get intensityScaleRir;

  /// No description provided for @intensityScaleBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get intensityScaleBoth;

  /// No description provided for @updateRoutineAfterWorkout.
  ///
  /// In en, this message translates to:
  /// **'Update routine after workout'**
  String get updateRoutineAfterWorkout;

  /// No description provided for @routineUpdateNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get routineUpdateNever;

  /// No description provided for @routineUpdateAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get routineUpdateAlways;

  /// No description provided for @routineUpdateAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get routineUpdateAsk;

  /// No description provided for @scrollWheelInput.
  ///
  /// In en, this message translates to:
  /// **'Scroll wheel input'**
  String get scrollWheelInput;

  /// No description provided for @tapValueToOpenPicker.
  ///
  /// In en, this message translates to:
  /// **'Tap a value to open the picker'**
  String get tapValueToOpenPicker;

  /// No description provided for @inlineTextFields.
  ///
  /// In en, this message translates to:
  /// **'Inline text fields'**
  String get inlineTextFields;

  /// No description provided for @dismissScrollWheelAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Dismiss scroll wheel automatically'**
  String get dismissScrollWheelAutomatically;

  /// No description provided for @closesAfterShortPause.
  ///
  /// In en, this message translates to:
  /// **'Closes after a short pause'**
  String get closesAfterShortPause;

  /// No description provided for @confirmWithDone.
  ///
  /// In en, this message translates to:
  /// **'Confirm with Done'**
  String get confirmWithDone;

  /// No description provided for @dataAndConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Data & Configuration'**
  String get dataAndConfiguration;

  /// No description provided for @measurementsSettings.
  ///
  /// In en, this message translates to:
  /// **'Measurements Settings'**
  String get measurementsSettings;

  /// No description provided for @configureMeasurementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure which measurements to track'**
  String get configureMeasurementsDesc;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @backupAndRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore your data'**
  String get backupAndRestoreDesc;

  /// No description provided for @featuresConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Features Configuration'**
  String get featuresConfiguration;

  /// No description provided for @mealTracking.
  ///
  /// In en, this message translates to:
  /// **'Meal Tracking'**
  String get mealTracking;

  /// No description provided for @mealTrackingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Meal tracking enabled'**
  String get mealTrackingEnabled;

  /// No description provided for @mealTrackingDisabled.
  ///
  /// In en, this message translates to:
  /// **'Meal tracking disabled'**
  String get mealTrackingDisabled;

  /// No description provided for @dayStartHour.
  ///
  /// In en, this message translates to:
  /// **'Day start hour'**
  String get dayStartHour;

  /// No description provided for @newDayStartsAt.
  ///
  /// In en, this message translates to:
  /// **'New day starts at {time}:00'**
  String newDayStartsAt(String time);

  /// No description provided for @defaultMacrosOverridePlans.
  ///
  /// In en, this message translates to:
  /// **'Default macros override plans'**
  String get defaultMacrosOverridePlans;

  /// No description provided for @defaultMacrosOverrideEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Default target macros always override meal plan targets'**
  String get defaultMacrosOverrideEnabledDesc;

  /// No description provided for @defaultMacrosOverrideDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Meal plan targets take precedence when available'**
  String get defaultMacrosOverrideDisabledDesc;

  /// No description provided for @stockTracking.
  ///
  /// In en, this message translates to:
  /// **'Stock Tracking'**
  String get stockTracking;

  /// No description provided for @requiresMealTracking.
  ///
  /// In en, this message translates to:
  /// **'Requires Meal Tracking'**
  String get requiresMealTracking;

  /// No description provided for @stockTrackingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Stock tracking enabled'**
  String get stockTrackingEnabled;

  /// No description provided for @stockTrackingDisabled.
  ///
  /// In en, this message translates to:
  /// **'Stock tracking disabled'**
  String get stockTrackingDisabled;

  /// No description provided for @aiIntegrations.
  ///
  /// In en, this message translates to:
  /// **'AI Integrations'**
  String get aiIntegrations;

  /// No description provided for @aiStockLogging.
  ///
  /// In en, this message translates to:
  /// **'AI Stock Logging'**
  String get aiStockLogging;

  /// No description provided for @aiStockLoggingDesc.
  ///
  /// In en, this message translates to:
  /// **'Log stock via receipt photo uploads'**
  String get aiStockLoggingDesc;

  /// No description provided for @aiProductCreation.
  ///
  /// In en, this message translates to:
  /// **'AI Product Creation'**
  String get aiProductCreation;

  /// No description provided for @aiProductCreationDesc.
  ///
  /// In en, this message translates to:
  /// **'Autofill nutrition details using AI predictions'**
  String get aiProductCreationDesc;

  /// No description provided for @aiFeaturesAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'AI Features & Privacy'**
  String get aiFeaturesAndPrivacy;

  /// No description provided for @aiWorkoutGenerationEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'AI assisted workout generation enabled'**
  String get aiWorkoutGenerationEnabledDesc;

  /// No description provided for @aiWorkoutGenerationDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'AI assisted workout generation disabled'**
  String get aiWorkoutGenerationDisabledDesc;

  /// No description provided for @includeUserStatistics.
  ///
  /// In en, this message translates to:
  /// **'Include User Statistics'**
  String get includeUserStatistics;

  /// No description provided for @includeUserStatisticsEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Workout volume, streak & metrics shared'**
  String get includeUserStatisticsEnabledDesc;

  /// No description provided for @includeUserStatisticsDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'User statistics hidden from AI'**
  String get includeUserStatisticsDisabledDesc;

  /// No description provided for @includeMealHistory.
  ///
  /// In en, this message translates to:
  /// **'Include Meal History'**
  String get includeMealHistory;

  /// No description provided for @includeMealHistoryEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Recent nutrition & logged meals shared'**
  String get includeMealHistoryEnabledDesc;

  /// No description provided for @includeMealHistoryDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Meal history hidden from AI'**
  String get includeMealHistoryDisabledDesc;

  /// No description provided for @includeWorkoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Include Workout History'**
  String get includeWorkoutHistory;

  /// No description provided for @includeWorkoutHistoryEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed workouts & routine records shared'**
  String get includeWorkoutHistoryEnabledDesc;

  /// No description provided for @includeWorkoutHistoryDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Workout history hidden from AI'**
  String get includeWorkoutHistoryDisabledDesc;

  /// No description provided for @includeUserPreferences.
  ///
  /// In en, this message translates to:
  /// **'Include User Preferences'**
  String get includeUserPreferences;

  /// No description provided for @includeUserPreferencesEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Equipment & personal training notes shared'**
  String get includeUserPreferencesEnabledDesc;

  /// No description provided for @includeUserPreferencesDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'User preferences hidden from AI'**
  String get includeUserPreferencesDisabledDesc;

  /// No description provided for @includeMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Include Measurements'**
  String get includeMeasurements;

  /// No description provided for @includeMeasurementsEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Weight & body measurements shared'**
  String get includeMeasurementsEnabledDesc;

  /// No description provided for @includeMeasurementsDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Measurements hidden from AI'**
  String get includeMeasurementsDisabledDesc;

  /// No description provided for @aiApiConfiguration.
  ///
  /// In en, this message translates to:
  /// **'AI API Configuration'**
  String get aiApiConfiguration;

  /// No description provided for @apiProvider.
  ///
  /// In en, this message translates to:
  /// **'API Provider'**
  String get apiProvider;

  /// No description provided for @geminiApi.
  ///
  /// In en, this message translates to:
  /// **'Gemini API (AI Studio)'**
  String get geminiApi;

  /// No description provided for @openRouter.
  ///
  /// In en, this message translates to:
  /// **'OpenRouter'**
  String get openRouter;

  /// No description provided for @apiTokenKey.
  ///
  /// In en, this message translates to:
  /// **'API Token / Key'**
  String get apiTokenKey;

  /// No description provided for @modelName.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelName;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageCatalan.
  ///
  /// In en, this message translates to:
  /// **'Catalan'**
  String get languageCatalan;

  /// No description provided for @languageCzech.
  ///
  /// In en, this message translates to:
  /// **'Czech'**
  String get languageCzech;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageGalician.
  ///
  /// In en, this message translates to:
  /// **'Galician'**
  String get languageGalician;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get languageIndonesian;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// No description provided for @languageDutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get languagePolish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languagePortugueseBrazil.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get languagePortugueseBrazil;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageSwedish.
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get languageSwedish;

  /// No description provided for @languageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get languageUkrainian;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// No description provided for @languageSimplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get languageSimplifiedChinese;

  /// No description provided for @unitSystemMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitSystemMetric;

  /// No description provided for @unitSystemImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitSystemImperial;

  /// No description provided for @couldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(String url);

  /// No description provided for @versionWithBuild.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String versionWithBuild(String version, String build);

  /// No description provided for @loadingVersion.
  ///
  /// In en, this message translates to:
  /// **'Loading version…'**
  String get loadingVersion;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'No data leaves your device. Ever.'**
  String get privacyPolicyDescription;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'Nexc does not collect, store, or transmit any personal data. All workout and nutrition data is stored exclusively on your device in a local database. No analytics, no crash reporting services, no third-party SDKs that phone home.\n\nYour data is your data.'**
  String get privacyPolicyBody;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @licenseDescription.
  ///
  /// In en, this message translates to:
  /// **'GNU General Public License v3.0'**
  String get licenseDescription;

  /// No description provided for @licenseLegalese.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Nexc Contributors\nBased on LibreFit © IamDg and the LibreFit Contributors\nLicensed under the GNU General Public License v3.0'**
  String get licenseLegalese;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @githubDescription.
  ///
  /// In en, this message translates to:
  /// **'View source code on GitHub'**
  String get githubDescription;

  /// No description provided for @attribution.
  ///
  /// In en, this message translates to:
  /// **'Attribution'**
  String get attribution;

  /// No description provided for @libreFitName.
  ///
  /// In en, this message translates to:
  /// **'LibreFit'**
  String get libreFitName;

  /// No description provided for @libreFitDescription.
  ///
  /// In en, this message translates to:
  /// **'The open-source project Nexc is based on — by IamDg and contributors'**
  String get libreFitDescription;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportBug;

  /// No description provided for @reportBugDescription.
  ///
  /// In en, this message translates to:
  /// **'Open an issue on GitHub'**
  String get reportBugDescription;

  /// No description provided for @suggestFeature.
  ///
  /// In en, this message translates to:
  /// **'Suggest a feature'**
  String get suggestFeature;

  /// No description provided for @suggestFeatureDescription.
  ///
  /// In en, this message translates to:
  /// **'Open a discussion on GitHub'**
  String get suggestFeatureDescription;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ — built on the shoulders of giants.'**
  String get madeWithLove;

  /// No description provided for @plateCalculator.
  ///
  /// In en, this message translates to:
  /// **'Plate calculator'**
  String get plateCalculator;

  /// No description provided for @unlinkSuperset.
  ///
  /// In en, this message translates to:
  /// **'Unlink superset'**
  String get unlinkSuperset;

  /// No description provided for @linkSuperset.
  ///
  /// In en, this message translates to:
  /// **'Link superset'**
  String get linkSuperset;

  /// No description provided for @replaceExercise.
  ///
  /// In en, this message translates to:
  /// **'Replace exercise'**
  String get replaceExercise;

  /// No description provided for @machineBusy.
  ///
  /// In en, this message translates to:
  /// **'Machine busy'**
  String get machineBusy;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @restTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest time: '**
  String get restTimeLabel;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @setColumn.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setColumn;

  /// No description provided for @previousColumn.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousColumn;

  /// No description provided for @timeColumn.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeColumn;

  /// No description provided for @weightColumn.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightColumn;

  /// No description provided for @repsColumn.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsColumn;

  /// No description provided for @rpe.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get rpe;

  /// No description provided for @rir.
  ///
  /// In en, this message translates to:
  /// **'RIR'**
  String get rir;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get addSet;

  /// No description provided for @decreaseBy.
  ///
  /// In en, this message translates to:
  /// **'Decrease by {amount}'**
  String decreaseBy(String amount);

  /// No description provided for @increaseBy.
  ///
  /// In en, this message translates to:
  /// **'Increase by {amount}'**
  String increaseBy(String amount);

  /// No description provided for @bar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get bar;

  /// No description provided for @targetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get targetWeight;

  /// No description provided for @includeSmallPlates.
  ///
  /// In en, this message translates to:
  /// **'Include small plates'**
  String get includeSmallPlates;

  /// No description provided for @perSide.
  ///
  /// In en, this message translates to:
  /// **'Per side'**
  String get perSide;

  /// No description provided for @noPlatesNeeded.
  ///
  /// In en, this message translates to:
  /// **'No plates needed'**
  String get noPlatesNeeded;

  /// No description provided for @cannotHitExactly.
  ///
  /// In en, this message translates to:
  /// **'Cannot hit exactly — {remainder} left over per side'**
  String cannotHitExactly(String remainder);

  /// No description provided for @closestAchievable.
  ///
  /// In en, this message translates to:
  /// **'Closest achievable: {weight}'**
  String closestAchievable(String weight);

  /// No description provided for @plateCount.
  ///
  /// In en, this message translates to:
  /// **'× {count}'**
  String plateCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'ca',
    'cs',
    'de',
    'en',
    'es',
    'fr',
    'gl',
    'hi',
    'id',
    'it',
    'ko',
    'nl',
    'pl',
    'pt',
    'ru',
    'sv',
    'uk',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'gl':
      return AppLocalizationsGl();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
