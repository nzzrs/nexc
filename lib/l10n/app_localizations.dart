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

  /// No description provided for @updateRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Update routine?'**
  String get updateRoutineTitle;

  /// No description provided for @updateRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy the values of the completed sets into your routine?'**
  String get updateRoutineMessage;

  /// No description provided for @dontUpdate.
  ///
  /// In en, this message translates to:
  /// **'Don\'t update'**
  String get dontUpdate;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @activeWorkoutChannel.
  ///
  /// In en, this message translates to:
  /// **'Active Workout'**
  String get activeWorkoutChannel;

  /// No description provided for @activeWorkoutChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Keeps workout stopwatch running in background'**
  String get activeWorkoutChannelDesc;

  /// No description provided for @workoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout in Progress'**
  String get workoutInProgress;

  /// No description provided for @durationWithTime.
  ///
  /// In en, this message translates to:
  /// **'Duration: {time}'**
  String durationWithTime(String time);

  /// No description provided for @restTimerChannel.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get restTimerChannel;

  /// No description provided for @restTimerChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications for active rest timer'**
  String get restTimerChannelDesc;

  /// No description provided for @resting.
  ///
  /// In en, this message translates to:
  /// **'Resting...'**
  String get resting;

  /// No description provided for @secondsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds remaining'**
  String secondsRemaining(int count);

  /// No description provided for @restTimerFinishedChannel.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer Finished'**
  String get restTimerFinishedChannel;

  /// No description provided for @restTimerFinishedChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications when rest timer is done'**
  String get restTimerFinishedChannelDesc;

  /// No description provided for @restFinished.
  ///
  /// In en, this message translates to:
  /// **'Rest Finished'**
  String get restFinished;

  /// No description provided for @restFinishedBody.
  ///
  /// In en, this message translates to:
  /// **'Time to start your next set!'**
  String get restFinishedBody;

  /// No description provided for @finishWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout?'**
  String get finishWorkoutTitle;

  /// No description provided for @completedSetsRatio.
  ///
  /// In en, this message translates to:
  /// **'Completed: {completed}/{total} sets'**
  String completedSetsRatio(int completed, int total);

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveAction;

  /// No description provided for @setsRatio.
  ///
  /// In en, this message translates to:
  /// **'Sets: {completed}/{total}'**
  String setsRatio(int completed, int total);

  /// No description provided for @doneAction.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get doneAction;

  /// No description provided for @emptyWorkoutHint.
  ///
  /// In en, this message translates to:
  /// **'Your workout is empty. Tap Add Exercise below.'**
  String get emptyWorkoutHint;

  /// No description provided for @doneReordering.
  ///
  /// In en, this message translates to:
  /// **'Done Reordering'**
  String get doneReordering;

  /// No description provided for @reorderExercises.
  ///
  /// In en, this message translates to:
  /// **'Reorder Exercises'**
  String get reorderExercises;

  /// No description provided for @pushedExerciseForLater.
  ///
  /// In en, this message translates to:
  /// **'Pushed \"{name}\" for later'**
  String pushedExerciseForLater(String name);

  /// No description provided for @timerCanceled.
  ///
  /// In en, this message translates to:
  /// **'Timer canceled'**
  String get timerCanceled;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// No description provided for @restTimerBadge.
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get restTimerBadge;

  /// No description provided for @workoutSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Summary'**
  String get workoutSummaryTitle;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout Completed!'**
  String get workoutCompleted;

  /// No description provided for @volumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volumeLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @setsCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets Completed'**
  String get setsCompletedLabel;

  /// No description provided for @hardSetsSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Hard Sets'**
  String get hardSetsSummaryLabel;

  /// No description provided for @exercisesLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercisesLabel;

  /// No description provided for @densityWithValue.
  ///
  /// In en, this message translates to:
  /// **'Density: {value}'**
  String densityWithValue(String value);

  /// No description provided for @focusWithValue.
  ///
  /// In en, this message translates to:
  /// **'Focus: {value}'**
  String focusWithValue(String value);

  /// No description provided for @exerciseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Exercise Breakdown'**
  String get exerciseBreakdown;

  /// No description provided for @e1rmWithValue.
  ///
  /// In en, this message translates to:
  /// **'e1RM: {value}'**
  String e1rmWithValue(String value);

  /// No description provided for @volumeWithValue.
  ///
  /// In en, this message translates to:
  /// **'Volume: {value}'**
  String volumeWithValue(String value);

  /// No description provided for @detailedSummaryCopied.
  ///
  /// In en, this message translates to:
  /// **'Detailed summary copied to clipboard'**
  String get detailedSummaryCopied;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @deleteRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Routine?'**
  String get deleteRoutineTitle;

  /// No description provided for @deleteWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Workout?'**
  String get deleteWorkoutTitle;

  /// No description provided for @deleteRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this routine? This action cannot be undone.'**
  String get deleteRoutineMessage;

  /// No description provided for @deleteWorkoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this workout? This action cannot be undone.'**
  String get deleteWorkoutMessage;

  /// No description provided for @unlinkRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink Routine?'**
  String get unlinkRoutineTitle;

  /// No description provided for @unlinkRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlink this workout from its routine?'**
  String get unlinkRoutineMessage;

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlink;

  /// No description provided for @routineLabel.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routineLabel;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @createdWithDate.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdWithDate(String date);

  /// No description provided for @completedWithDate.
  ///
  /// In en, this message translates to:
  /// **'Completed: {date}'**
  String completedWithDate(String date);

  /// No description provided for @exercisesWithCount.
  ///
  /// In en, this message translates to:
  /// **'Exercises: {count}'**
  String exercisesWithCount(int count);

  /// No description provided for @totalSetsCount.
  ///
  /// In en, this message translates to:
  /// **'Total sets: {count}'**
  String totalSetsCount(int count);

  /// No description provided for @completedSetsCount.
  ///
  /// In en, this message translates to:
  /// **'Completed sets: {count}'**
  String completedSetsCount(int count);

  /// No description provided for @linkedRoutine.
  ///
  /// In en, this message translates to:
  /// **'Linked routine'**
  String get linkedRoutine;

  /// No description provided for @openThisRoutine.
  ///
  /// In en, this message translates to:
  /// **'Open this routine'**
  String get openThisRoutine;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @tonnageLabel.
  ///
  /// In en, this message translates to:
  /// **'Tonnage'**
  String get tonnageLabel;

  /// No description provided for @densityLabel.
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get densityLabel;

  /// No description provided for @hardSetsMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'Hard sets'**
  String get hardSetsMetricLabel;

  /// No description provided for @primaryMuscleLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary muscle'**
  String get primaryMuscleLabel;

  /// No description provided for @bestE1rmLabel.
  ///
  /// In en, this message translates to:
  /// **'Best e1RM'**
  String get bestE1rmLabel;

  /// No description provided for @setNumber.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String setNumber(int number);

  /// No description provided for @repsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reps'**
  String repsCount(int count);

  /// No description provided for @rpeWithValue.
  ///
  /// In en, this message translates to:
  /// **'  (RPE {value})'**
  String rpeWithValue(String value);

  /// No description provided for @rirWithValue.
  ///
  /// In en, this message translates to:
  /// **'  (RIR {value})'**
  String rirWithValue(String value);

  /// No description provided for @routineSavedToRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routine \"{title}\" saved to your routines!'**
  String routineSavedToRoutines(String title);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @failedToSaveRoutine.
  ///
  /// In en, this message translates to:
  /// **'Failed to save routine: {error}'**
  String failedToSaveRoutine(String error);

  /// No description provided for @aiPreferences.
  ///
  /// In en, this message translates to:
  /// **'AI Preferences'**
  String get aiPreferences;

  /// No description provided for @aiGenerationTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'AI assisted workout generation is turned off in Settings.'**
  String get aiGenerationTurnedOff;

  /// No description provided for @enableAction.
  ///
  /// In en, this message translates to:
  /// **'ENABLE'**
  String get enableAction;

  /// No description provided for @exercisesWithList.
  ///
  /// In en, this message translates to:
  /// **'{count} Exercises: {list}'**
  String exercisesWithList(int count, String list);

  /// No description provided for @routineSaved.
  ///
  /// In en, this message translates to:
  /// **'Routine Saved'**
  String get routineSaved;

  /// No description provided for @saveAsRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save as Routine'**
  String get saveAsRoutine;

  /// No description provided for @aiCoachThinking.
  ///
  /// In en, this message translates to:
  /// **'AI coach is thinking...'**
  String get aiCoachThinking;

  /// No description provided for @askOrCreateWorkout.
  ///
  /// In en, this message translates to:
  /// **'Ask or create a workout...'**
  String get askOrCreateWorkout;

  /// No description provided for @aiGenerationDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'AI generation disabled in Settings'**
  String get aiGenerationDisabledHint;

  /// No description provided for @addExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Exercises'**
  String get addExercisesTitle;

  /// No description provided for @replaceExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace Exercise'**
  String get replaceExerciseTitle;

  /// No description provided for @selectExercise.
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get selectExercise;

  /// No description provided for @addCount.
  ///
  /// In en, this message translates to:
  /// **'ADD ({count})'**
  String addCount(int count);

  /// No description provided for @searchExercise.
  ///
  /// In en, this message translates to:
  /// **'Search exercise...'**
  String get searchExercise;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// No description provided for @levelWithValue.
  ///
  /// In en, this message translates to:
  /// **'Level: {value}'**
  String levelWithValue(String value);

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get selectLevel;

  /// No description provided for @forceLabel.
  ///
  /// In en, this message translates to:
  /// **'Force'**
  String get forceLabel;

  /// No description provided for @forceWithValue.
  ///
  /// In en, this message translates to:
  /// **'Force: {value}'**
  String forceWithValue(String value);

  /// No description provided for @selectForce.
  ///
  /// In en, this message translates to:
  /// **'Select Force'**
  String get selectForce;

  /// No description provided for @mechanicLabel.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get mechanicLabel;

  /// No description provided for @mechanicWithValue.
  ///
  /// In en, this message translates to:
  /// **'Mechanic: {value}'**
  String mechanicWithValue(String value);

  /// No description provided for @selectMechanic.
  ///
  /// In en, this message translates to:
  /// **'Select Mechanic'**
  String get selectMechanic;

  /// No description provided for @equipmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipmentLabel;

  /// No description provided for @equipmentWithValue.
  ///
  /// In en, this message translates to:
  /// **'Equipment: {value}'**
  String equipmentWithValue(String value);

  /// No description provided for @selectEquipment.
  ///
  /// In en, this message translates to:
  /// **'Select Equipment'**
  String get selectEquipment;

  /// No description provided for @muscleLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle'**
  String get muscleLabel;

  /// No description provided for @muscleWithValue.
  ///
  /// In en, this message translates to:
  /// **'Muscle: {value}'**
  String muscleWithValue(String value);

  /// No description provided for @selectMuscle.
  ///
  /// In en, this message translates to:
  /// **'Select Muscle'**
  String get selectMuscle;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryWithValue.
  ///
  /// In en, this message translates to:
  /// **'Category: {value}'**
  String categoryWithValue(String value);

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @customOnly.
  ///
  /// In en, this message translates to:
  /// **'Custom Only'**
  String get customOnly;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noExercisesFound;

  /// No description provided for @createExercise.
  ///
  /// In en, this message translates to:
  /// **'Create Exercise'**
  String get createExercise;

  /// No description provided for @createWithAi.
  ///
  /// In en, this message translates to:
  /// **'Create with AI'**
  String get createWithAi;

  /// No description provided for @aiMatch.
  ///
  /// In en, this message translates to:
  /// **'AI MATCH'**
  String get aiMatch;

  /// No description provided for @exerciseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{category} • {equipment} • {muscles}'**
  String exerciseSubtitle(String category, String equipment, String muscles);

  /// No description provided for @noEquipment.
  ///
  /// In en, this message translates to:
  /// **'No Equipment'**
  String get noEquipment;

  /// No description provided for @aiSuggestions.
  ///
  /// In en, this message translates to:
  /// **'AI SUGGESTIONS (SIMILAR MUSCLES)'**
  String get aiSuggestions;

  /// No description provided for @allExercises.
  ///
  /// In en, this message translates to:
  /// **'ALL EXERCISES'**
  String get allExercises;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @createCustomExercise.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Exercise'**
  String get createCustomExercise;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseName;

  /// No description provided for @primaryMuscleField.
  ///
  /// In en, this message translates to:
  /// **'Primary Muscle'**
  String get primaryMuscleField;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelAction;

  /// No description provided for @describeExerciseHint.
  ///
  /// In en, this message translates to:
  /// **'Describe exercise (e.g. Dumbbell rear delt fly on incline bench)'**
  String get describeExerciseHint;

  /// No description provided for @generateAction.
  ///
  /// In en, this message translates to:
  /// **'GENERATE'**
  String get generateAction;

  /// No description provided for @generatingExerciseWithAi.
  ///
  /// In en, this message translates to:
  /// **'Generating exercise with AI...'**
  String get generatingExerciseWithAi;

  /// No description provided for @exerciseDetails.
  ///
  /// In en, this message translates to:
  /// **'Exercise Details'**
  String get exerciseDetails;

  /// No description provided for @detailsTab.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsTab;

  /// No description provided for @instructionsTab.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsTab;

  /// No description provided for @primaryMusclesWorked.
  ///
  /// In en, this message translates to:
  /// **'Primary Muscles Worked'**
  String get primaryMusclesWorked;

  /// No description provided for @secondaryMusclesWorked.
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscles Worked'**
  String get secondaryMusclesWorked;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to discard your changes or save them?'**
  String get discardChangesMessage;

  /// No description provided for @enterRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a routine title'**
  String get enterRoutineTitle;

  /// No description provided for @createRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get createRoutineTitle;

  /// No description provided for @editRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get editRoutineTitle;

  /// No description provided for @routineTitleField.
  ///
  /// In en, this message translates to:
  /// **'Routine title'**
  String get routineTitleField;

  /// No description provided for @routineNotesField.
  ///
  /// In en, this message translates to:
  /// **'Routine notes'**
  String get routineNotesField;

  /// No description provided for @noExercisesAdded.
  ///
  /// In en, this message translates to:
  /// **'No exercises added yet. Tap Add Exercise below.'**
  String get noExercisesAdded;

  /// No description provided for @addExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExerciseTitle;

  /// No description provided for @discardAction.
  ///
  /// In en, this message translates to:
  /// **'DISCARD'**
  String get discardAction;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on Track'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Nexc needs notification permission to alert you when your rest timer finishes, keeping your workouts focused and efficient.'**
  String get notificationPermissionMessage;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @selectDayHint.
  ///
  /// In en, this message translates to:
  /// **'Select a day to view workouts'**
  String get selectDayHint;

  /// No description provided for @workoutNoun.
  ///
  /// In en, this message translates to:
  /// **'workout'**
  String get workoutNoun;

  /// No description provided for @workoutsNoun.
  ///
  /// In en, this message translates to:
  /// **'workouts'**
  String get workoutsNoun;

  /// No description provided for @restDayNoWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Rest day — no workouts logged'**
  String get restDayNoWorkouts;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @calendarDate.
  ///
  /// In en, this message translates to:
  /// **'{weekday}, {month} {day}'**
  String calendarDate(String weekday, String month, int day);

  /// No description provided for @setsCompletedRatio.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} sets completed'**
  String setsCompletedRatio(int completed, int total);

  /// No description provided for @exerciseNoun.
  ///
  /// In en, this message translates to:
  /// **'exercise'**
  String get exerciseNoun;

  /// No description provided for @exercisesNoun.
  ///
  /// In en, this message translates to:
  /// **'exercises'**
  String get exercisesNoun;

  /// No description provided for @moreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreCount(int count);

  /// No description provided for @replaceMealItem.
  ///
  /// In en, this message translates to:
  /// **'Replace Meal Item'**
  String get replaceMealItem;

  /// No description provided for @addItemToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Item to Meal'**
  String get addItemToMeal;

  /// No description provided for @addItemsSelected.
  ///
  /// In en, this message translates to:
  /// **'Add Items ({count} selected)'**
  String addItemsSelected(int count);

  /// No description provided for @productsTab.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTab;

  /// No description provided for @recipesTab.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTab;

  /// No description provided for @createProduct.
  ///
  /// In en, this message translates to:
  /// **'Create Product'**
  String get createProduct;

  /// No description provided for @createRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create Recipe'**
  String get createRecipe;

  /// No description provided for @searchFoodOrProduct.
  ///
  /// In en, this message translates to:
  /// **'Search food or product...'**
  String get searchFoodOrProduct;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchRecipes;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get noRecipesFound;

  /// No description provided for @ingredientsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients'**
  String ingredientsCount(int count);

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get editRecipe;

  /// No description provided for @gramsLabel.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get gramsLabel;

  /// No description provided for @unitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsLabel;

  /// No description provided for @portionAmount.
  ///
  /// In en, this message translates to:
  /// **'Portion Amount'**
  String get portionAmount;

  /// No description provided for @replaceAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replaceAction;

  /// No description provided for @addAllCount.
  ///
  /// In en, this message translates to:
  /// **'Add All ({count})'**
  String addAllCount(int count);

  /// No description provided for @addToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal'**
  String get addToMeal;

  /// No description provided for @macrosCompact.
  ///
  /// In en, this message translates to:
  /// **'{protein}g P | {carbs}g C | {fats}g F'**
  String macrosCompact(String protein, String carbs, String fats);

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @autofillWithAi.
  ///
  /// In en, this message translates to:
  /// **'Autofill with AI'**
  String get autofillWithAi;

  /// No description provided for @enterProductNameFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter a product name first'**
  String get enterProductNameFirst;

  /// No description provided for @autofilledProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Autofilled product details!'**
  String get autofilledProductDetails;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'AI Error: {error}'**
  String aiError(String error);

  /// No description provided for @defaultUnitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Units'**
  String get defaultUnitsLabel;

  /// No description provided for @mlToGFactorRequired.
  ///
  /// In en, this message translates to:
  /// **'ml to g factor *'**
  String get mlToGFactorRequired;

  /// No description provided for @mlToGFactorLabel.
  ///
  /// In en, this message translates to:
  /// **'ml to g factor'**
  String get mlToGFactorLabel;

  /// No description provided for @requiredForMlProducts.
  ///
  /// In en, this message translates to:
  /// **'Required for ml-based products'**
  String get requiredForMlProducts;

  /// No description provided for @unitWeightGRequired.
  ///
  /// In en, this message translates to:
  /// **'Unit weight (g) *'**
  String get unitWeightGRequired;

  /// No description provided for @unitWeightGLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit weight (g)'**
  String get unitWeightGLabel;

  /// No description provided for @requiredForUnitsProducts.
  ///
  /// In en, this message translates to:
  /// **'Required for products measured in units'**
  String get requiredForUnitsProducts;

  /// No description provided for @ediblePercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Edible %'**
  String get ediblePercentLabel;

  /// No description provided for @macrosEnergyPer100g.
  ///
  /// In en, this message translates to:
  /// **'Macros & Energy (per 100g)'**
  String get macrosEnergyPer100g;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcal;

  /// No description provided for @proteinsG.
  ///
  /// In en, this message translates to:
  /// **'Proteins (g)'**
  String get proteinsG;

  /// No description provided for @carbsAvailableG.
  ///
  /// In en, this message translates to:
  /// **'Carbs Available (g)'**
  String get carbsAvailableG;

  /// No description provided for @carbsByDiffG.
  ///
  /// In en, this message translates to:
  /// **'Carbs By Diff (g)'**
  String get carbsByDiffG;

  /// No description provided for @fatsG.
  ///
  /// In en, this message translates to:
  /// **'Fats (g)'**
  String get fatsG;

  /// No description provided for @dietaryFiberG.
  ///
  /// In en, this message translates to:
  /// **'Dietary Fiber (g)'**
  String get dietaryFiberG;

  /// No description provided for @isSupplementLabel.
  ///
  /// In en, this message translates to:
  /// **'Is Supplement'**
  String get isSupplementLabel;

  /// No description provided for @isPortableLabel.
  ///
  /// In en, this message translates to:
  /// **'Is Portable'**
  String get isPortableLabel;

  /// No description provided for @isStockRawLabel.
  ///
  /// In en, this message translates to:
  /// **'Is Stock Raw'**
  String get isStockRawLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @validationMlFactor.
  ///
  /// In en, this message translates to:
  /// **'Add a positive \"ml to g factor\" so portions measured in ml can be converted to grams.'**
  String get validationMlFactor;

  /// No description provided for @validationUnitWeight.
  ///
  /// In en, this message translates to:
  /// **'Add a positive \"Unit weight (g)\" so portions measured in units can be converted to grams.'**
  String get validationUnitWeight;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipe;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @instructionsProcess.
  ///
  /// In en, this message translates to:
  /// **'Instructions/Process'**
  String get instructionsProcess;

  /// No description provided for @isPortableNonPortable.
  ///
  /// In en, this message translates to:
  /// **'Is Portable (Contains non-portable ingredients)'**
  String get isPortableNonPortable;

  /// No description provided for @composition.
  ///
  /// In en, this message translates to:
  /// **'Composition'**
  String get composition;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @searchIngredient.
  ///
  /// In en, this message translates to:
  /// **'Search Ingredient...'**
  String get searchIngredient;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @ingredientLine.
  ///
  /// In en, this message translates to:
  /// **'{name}: {amount}'**
  String ingredientLine(String name, String amount);

  /// No description provided for @removeIngredient.
  ///
  /// In en, this message translates to:
  /// **'Remove ingredient'**
  String get removeIngredient;

  /// No description provided for @enterRecipeName.
  ///
  /// In en, this message translates to:
  /// **'Enter a recipe name'**
  String get enterRecipeName;

  /// No description provided for @titleCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty'**
  String get titleCannotBeEmpty;

  /// No description provided for @mealPlanSaved.
  ///
  /// In en, this message translates to:
  /// **'Meal plan saved'**
  String get mealPlanSaved;

  /// No description provided for @createMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Meal Plan'**
  String get createMealPlan;

  /// No description provided for @editMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal Plan'**
  String get editMealPlan;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Title'**
  String get planTitle;

  /// No description provided for @notesGoal.
  ///
  /// In en, this message translates to:
  /// **'Notes/Goal'**
  String get notesGoal;

  /// No description provided for @targetMacros.
  ///
  /// In en, this message translates to:
  /// **'Target Macros'**
  String get targetMacros;

  /// No description provided for @proteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @carbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsG;

  /// No description provided for @sumGrams.
  ///
  /// In en, this message translates to:
  /// **'Sum: {value}g'**
  String sumGrams(String value);

  /// No description provided for @mealsLabel.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get mealsLabel;

  /// No description provided for @mealNumber.
  ///
  /// In en, this message translates to:
  /// **'Meal {number}'**
  String mealNumber(int number);

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @deleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal'**
  String get deleteMeal;

  /// No description provided for @deleteMealConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{name}\'?'**
  String deleteMealConfirm(String name);

  /// No description provided for @unknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown Product'**
  String get unknownProduct;

  /// No description provided for @unknownRecipe.
  ///
  /// In en, this message translates to:
  /// **'Unknown Recipe'**
  String get unknownRecipe;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @selectActionForItem.
  ///
  /// In en, this message translates to:
  /// **'Select an action for this item.'**
  String get selectActionForItem;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @mealItemFallback.
  ///
  /// In en, this message translates to:
  /// **'Meal Item'**
  String get mealItemFallback;

  /// No description provided for @chooseActionForItem.
  ///
  /// In en, this message translates to:
  /// **'Choose an action for this item in today\'s meal log:'**
  String get chooseActionForItem;

  /// No description provided for @addSnack.
  ///
  /// In en, this message translates to:
  /// **'Add Snack'**
  String get addSnack;

  /// No description provided for @todayPlanTab.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get todayPlanTab;

  /// No description provided for @mealPlansTab.
  ///
  /// In en, this message translates to:
  /// **'Meal plans'**
  String get mealPlansTab;

  /// No description provided for @selectMealPlanForToday.
  ///
  /// In en, this message translates to:
  /// **'Select a meal plan for today'**
  String get selectMealPlanForToday;

  /// No description provided for @goToMealPlans.
  ///
  /// In en, this message translates to:
  /// **'Go to Meal Plans'**
  String get goToMealPlans;

  /// No description provided for @startLogging.
  ///
  /// In en, this message translates to:
  /// **'Start Logging'**
  String get startLogging;

  /// No description provided for @discardTodayMeals.
  ///
  /// In en, this message translates to:
  /// **'Discard Today\'s Meals'**
  String get discardTodayMeals;

  /// No description provided for @discardTodayMealsMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard today\'s meals log? This cannot be undone.'**
  String get discardTodayMealsMessage;

  /// No description provided for @saveTodayMeals.
  ///
  /// In en, this message translates to:
  /// **'Save Today\'s Meals'**
  String get saveTodayMeals;

  /// No description provided for @saveTodayMealsMessage.
  ///
  /// In en, this message translates to:
  /// **'This will save all items marked as eaten to your logs and remove any uneaten items. Proceed?'**
  String get saveTodayMealsMessage;

  /// No description provided for @todayMealsLogged.
  ///
  /// In en, this message translates to:
  /// **'Today\'s meals logged successfully!'**
  String get todayMealsLogged;

  /// No description provided for @noMealPlansYet.
  ///
  /// In en, this message translates to:
  /// **'No meal plans yet'**
  String get noMealPlansYet;

  /// No description provided for @deleteMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal Plan'**
  String get deleteMealPlan;

  /// No description provided for @deleteMealPlanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{title}\'?'**
  String deleteMealPlanConfirm(String title);

  /// No description provided for @changeMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Change Meal Plan?'**
  String get changeMealPlan;

  /// No description provided for @changeMealPlanMessage.
  ///
  /// In en, this message translates to:
  /// **'Changing today\'s plan will discard all food currently logged for today. Proceed?'**
  String get changeMealPlanMessage;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @todaysMacros.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Macros'**
  String get todaysMacros;

  /// No description provided for @proteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get proteinLabel;

  /// No description provided for @carbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbsLabel;

  /// No description provided for @fatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get fatsLabel;

  /// No description provided for @portable.
  ///
  /// In en, this message translates to:
  /// **'Portable'**
  String get portable;

  /// No description provided for @homeOnly.
  ///
  /// In en, this message translates to:
  /// **'Home only'**
  String get homeOnly;

  /// No description provided for @atHome.
  ///
  /// In en, this message translates to:
  /// **'At Home'**
  String get atHome;

  /// No description provided for @outside.
  ///
  /// In en, this message translates to:
  /// **'Outside'**
  String get outside;

  /// No description provided for @edibleEquivalent.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount}g edible'**
  String edibleEquivalent(String amount);

  /// No description provided for @editDailyMacroGoals.
  ///
  /// In en, this message translates to:
  /// **'Edit Daily Macro Goals'**
  String get editDailyMacroGoals;

  /// No description provided for @scheduledMeals.
  ///
  /// In en, this message translates to:
  /// **'{count} scheduled meals ({names})'**
  String scheduledMeals(int count, String names);

  /// No description provided for @selectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedLabel;

  /// No description provided for @selectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectLabel;

  /// No description provided for @macroChip.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String macroChip(String label, String value);

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add note...'**
  String get addNoteHint;

  /// No description provided for @addItemToMealLower.
  ///
  /// In en, this message translates to:
  /// **'Add item to meal'**
  String get addItemToMealLower;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{name}\'?'**
  String deleteProductConfirm(String name);

  /// No description provided for @supplement.
  ///
  /// In en, this message translates to:
  /// **'Supplement'**
  String get supplement;

  /// No description provided for @protGrams.
  ///
  /// In en, this message translates to:
  /// **'Prot: {value}g'**
  String protGrams(String value);

  /// No description provided for @carbGrams.
  ///
  /// In en, this message translates to:
  /// **'Carb: {value}g'**
  String carbGrams(String value);

  /// No description provided for @fatGrams.
  ///
  /// In en, this message translates to:
  /// **'Fat: {value}g'**
  String fatGrams(String value);

  /// No description provided for @defaultWithValue.
  ///
  /// In en, this message translates to:
  /// **'Default: {value}'**
  String defaultWithValue(String value);

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get deleteRecipe;

  /// No description provided for @deleteRecipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{name}\'?'**
  String deleteRecipeConfirm(String name);

  /// No description provided for @macrosPrefixLine.
  ///
  /// In en, this message translates to:
  /// **'Macros: P {protein}g | C {carbs}g | F {fats}g'**
  String macrosPrefixLine(String protein, String carbs, String fats);

  /// No description provided for @ingredientWithAmount.
  ///
  /// In en, this message translates to:
  /// **'{name} ({amount})'**
  String ingredientWithAmount(String name, String amount);

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProduct;

  /// No description provided for @usedCount.
  ///
  /// In en, this message translates to:
  /// **'Used {count}x'**
  String usedCount(int count);

  /// No description provided for @unitWithValue.
  ///
  /// In en, this message translates to:
  /// **'Unit: {value}'**
  String unitWithValue(String value);

  /// No description provided for @macrosShort.
  ///
  /// In en, this message translates to:
  /// **'P {protein}g | C {carbs}g | F {fats}g'**
  String macrosShort(String protein, String carbs, String fats);

  /// No description provided for @inStockBadge.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStockBadge;

  /// No description provided for @mealPlanDetails.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan Details'**
  String get mealPlanDetails;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @mealPlanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Meal plan not found'**
  String get mealPlanNotFound;

  /// No description provided for @measurementsMenu.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurementsMenu;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @statisticsMenu.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsMenu;

  /// No description provided for @stockTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockTitle;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @errorLoadingChart.
  ///
  /// In en, this message translates to:
  /// **'Error loading chart: {error}'**
  String errorLoadingChart(String error);

  /// No description provided for @yourWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Your workouts'**
  String get yourWorkouts;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @startCompletingWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Start completing workouts to see your history here.'**
  String get startCompletingWorkouts;

  /// No description provided for @finishedOnDuration.
  ///
  /// In en, this message translates to:
  /// **'Finished on: {date}\nDuration: {duration}'**
  String finishedOnDuration(String date, String duration);

  /// No description provided for @yourMeals.
  ///
  /// In en, this message translates to:
  /// **'Your meals'**
  String get yourMeals;

  /// No description provided for @noMealLogHistory.
  ///
  /// In en, this message translates to:
  /// **'No meal log history yet'**
  String get noMealLogHistory;

  /// No description provided for @eatenOn.
  ///
  /// In en, this message translates to:
  /// **'Eaten on: {date}'**
  String eatenOn(String date);

  /// No description provided for @progressItemsEaten.
  ///
  /// In en, this message translates to:
  /// **'Progress: {consumed} / {total} items eaten'**
  String progressItemsEaten(int consumed, int total);

  /// No description provided for @deleteMealLog.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal Log'**
  String get deleteMealLog;

  /// No description provided for @deleteMealLogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this meal log?'**
  String get deleteMealLogConfirm;

  /// No description provided for @weekStreak.
  ///
  /// In en, this message translates to:
  /// **'Week Streak: {count}'**
  String weekStreak(int count);

  /// No description provided for @superActive.
  ///
  /// In en, this message translates to:
  /// **'🔥 Super Active!'**
  String get superActive;

  /// No description provided for @keepMoving.
  ///
  /// In en, this message translates to:
  /// **'Keep moving!'**
  String get keepMoving;

  /// No description provided for @workoutPerformance.
  ///
  /// In en, this message translates to:
  /// **'Workout Performance'**
  String get workoutPerformance;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @errorLoadingWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Error loading workouts: {error}'**
  String errorLoadingWorkouts(String error);

  /// No description provided for @workoutMetrics.
  ///
  /// In en, this message translates to:
  /// **'Workout Metrics'**
  String get workoutMetrics;

  /// No description provided for @totalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get totalWorkouts;

  /// No description provided for @totalActiveTime.
  ///
  /// In en, this message translates to:
  /// **'Total Active Time'**
  String get totalActiveTime;

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins'**
  String minutesValue(String minutes);

  /// No description provided for @averageSession.
  ///
  /// In en, this message translates to:
  /// **'Average Session'**
  String get averageSession;

  /// No description provided for @targetedMusclesHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Targeted Muscles Heatmap'**
  String get targetedMusclesHeatmap;

  /// No description provided for @topTargetMuscles.
  ///
  /// In en, this message translates to:
  /// **'Top Target Muscles'**
  String get topTargetMuscles;

  /// No description provided for @noMuscleData.
  ///
  /// In en, this message translates to:
  /// **'No muscle targeting data yet. Start tracking sets!'**
  String get noMuscleData;

  /// No description provided for @timesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String timesCount(int count);

  /// No description provided for @errorLoadingNutrition.
  ///
  /// In en, this message translates to:
  /// **'Error loading nutrition: {error}'**
  String errorLoadingNutrition(String error);

  /// No description provided for @nutritionInsights.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Insights (Last {days} logs)'**
  String nutritionInsights(int days);

  /// No description provided for @avgCalories.
  ///
  /// In en, this message translates to:
  /// **'Avg. Calories'**
  String get avgCalories;

  /// No description provided for @avgProtein.
  ///
  /// In en, this message translates to:
  /// **'Avg. Protein'**
  String get avgProtein;

  /// No description provided for @avgCarbs.
  ///
  /// In en, this message translates to:
  /// **'Avg. Carbs'**
  String get avgCarbs;

  /// No description provided for @avgFats.
  ///
  /// In en, this message translates to:
  /// **'Avg. Fats'**
  String get avgFats;

  /// No description provided for @macrosDistribution.
  ///
  /// In en, this message translates to:
  /// **'Macros Distribution'**
  String get macrosDistribution;

  /// No description provided for @noMacroData.
  ///
  /// In en, this message translates to:
  /// **'No macro data available'**
  String get noMacroData;

  /// No description provided for @gramsPercent.
  ///
  /// In en, this message translates to:
  /// **'{grams} ({percent})'**
  String gramsPercent(String grams, String percent);

  /// No description provided for @logMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Log Measurement'**
  String get logMeasurement;

  /// No description provided for @bodyWeightWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Body Weight ({unit})'**
  String bodyWeightWithUnit(String unit);

  /// No description provided for @advancedBodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Body Metrics'**
  String get advancedBodyMetrics;

  /// No description provided for @bodyFatPercent.
  ///
  /// In en, this message translates to:
  /// **'Body Fat %'**
  String get bodyFatPercent;

  /// No description provided for @muscleMassPercent.
  ///
  /// In en, this message translates to:
  /// **'Muscle Mass %'**
  String get muscleMassPercent;

  /// No description provided for @waistCm.
  ///
  /// In en, this message translates to:
  /// **'Waist (cm)'**
  String get waistCm;

  /// No description provided for @sleepMetrics.
  ///
  /// In en, this message translates to:
  /// **'Sleep Metrics'**
  String get sleepMetrics;

  /// No description provided for @sleepDuration.
  ///
  /// In en, this message translates to:
  /// **'Sleep Duration'**
  String get sleepDuration;

  /// No description provided for @sleepingRhr.
  ///
  /// In en, this message translates to:
  /// **'Sleeping RHR'**
  String get sleepingRhr;

  /// No description provided for @sleepingHrvMs.
  ///
  /// In en, this message translates to:
  /// **'Sleeping HRV (ms)'**
  String get sleepingHrvMs;

  /// No description provided for @advancedSleepMetrics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Sleep Metrics'**
  String get advancedSleepMetrics;

  /// No description provided for @timeInBed.
  ///
  /// In en, this message translates to:
  /// **'Time in Bed'**
  String get timeInBed;

  /// No description provided for @totalAwakeTime.
  ///
  /// In en, this message translates to:
  /// **'Total Awake Time'**
  String get totalAwakeTime;

  /// No description provided for @longestAwakePeriod.
  ///
  /// In en, this message translates to:
  /// **'Longest Awake Period'**
  String get longestAwakePeriod;

  /// No description provided for @numberOfAwakenings.
  ///
  /// In en, this message translates to:
  /// **'Number of Awakenings'**
  String get numberOfAwakenings;

  /// No description provided for @activityMetrics.
  ///
  /// In en, this message translates to:
  /// **'Activity Metrics'**
  String get activityMetrics;

  /// No description provided for @dailySteps.
  ///
  /// In en, this message translates to:
  /// **'Daily Steps'**
  String get dailySteps;

  /// No description provided for @vo2Max.
  ///
  /// In en, this message translates to:
  /// **'VO2 Max'**
  String get vo2Max;

  /// No description provided for @wakingRhr.
  ///
  /// In en, this message translates to:
  /// **'Waking RHR'**
  String get wakingRhr;

  /// No description provided for @wakingHrvMs.
  ///
  /// In en, this message translates to:
  /// **'Waking HRV (ms)'**
  String get wakingHrvMs;

  /// No description provided for @saveMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Save Measurement'**
  String get saveMeasurement;

  /// No description provided for @hrsShort.
  ///
  /// In en, this message translates to:
  /// **'Hrs'**
  String get hrsShort;

  /// No description provided for @minShort.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minShort;

  /// No description provided for @weightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get weightProgress;

  /// No description provided for @waistCircumference.
  ///
  /// In en, this message translates to:
  /// **'Waist Circumference'**
  String get waistCircumference;

  /// No description provided for @bodyHistory.
  ///
  /// In en, this message translates to:
  /// **'Body History'**
  String get bodyHistory;

  /// No description provided for @noBodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No body measurements recorded yet.'**
  String get noBodyMeasurements;

  /// No description provided for @weightWithValue.
  ///
  /// In en, this message translates to:
  /// **'Weight: {value}'**
  String weightWithValue(String value);

  /// No description provided for @dateWithValue.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateWithValue(String date);

  /// No description provided for @deleteLog.
  ///
  /// In en, this message translates to:
  /// **'Delete log?'**
  String get deleteLog;

  /// No description provided for @deleteWeightConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this weight measurement?'**
  String get deleteWeightConfirm;

  /// No description provided for @deleteAdvancedBodyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this advanced body log?'**
  String get deleteAdvancedBodyConfirm;

  /// No description provided for @deleteSleepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this sleep log?'**
  String get deleteSleepConfirm;

  /// No description provided for @deleteAdvancedSleepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this advanced sleep log?'**
  String get deleteAdvancedSleepConfirm;

  /// No description provided for @deleteActivityConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this activity log?'**
  String get deleteActivityConfirm;

  /// No description provided for @advancedEntry.
  ///
  /// In en, this message translates to:
  /// **'Advanced Entry'**
  String get advancedEntry;

  /// No description provided for @sleepHistory.
  ///
  /// In en, this message translates to:
  /// **'Sleep History'**
  String get sleepHistory;

  /// No description provided for @noSleepLogs.
  ///
  /// In en, this message translates to:
  /// **'No sleep logs recorded yet.'**
  String get noSleepLogs;

  /// No description provided for @sleepEntry.
  ///
  /// In en, this message translates to:
  /// **'Sleep Entry'**
  String get sleepEntry;

  /// No description provided for @advSleepEntry.
  ///
  /// In en, this message translates to:
  /// **'Adv Sleep Entry'**
  String get advSleepEntry;

  /// No description provided for @noActivityLogs.
  ///
  /// In en, this message translates to:
  /// **'No activity logs recorded yet.'**
  String get noActivityLogs;

  /// No description provided for @caloriesActive.
  ///
  /// In en, this message translates to:
  /// **'Calories Active'**
  String get caloriesActive;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistory;

  /// No description provided for @activityEntry.
  ///
  /// In en, this message translates to:
  /// **'Activity Entry'**
  String get activityEntry;

  /// No description provided for @latestLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latestLabel;

  /// No description provided for @averageLabel.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get averageLabel;

  /// No description provided for @minMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Min/Max'**
  String get minMaxLabel;

  /// No description provided for @measurementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurementsTitle;

  /// No description provided for @addLog.
  ///
  /// In en, this message translates to:
  /// **'Add Log'**
  String get addLog;

  /// No description provided for @sleepMetricBed.
  ///
  /// In en, this message translates to:
  /// **'{value} Bed'**
  String sleepMetricBed(String value);

  /// No description provided for @sleepMetricAwake.
  ///
  /// In en, this message translates to:
  /// **'{value} Awake'**
  String sleepMetricAwake(String value);

  /// No description provided for @sleepMetricLongestAwake.
  ///
  /// In en, this message translates to:
  /// **'{value} Longest Awake'**
  String sleepMetricLongestAwake(String value);

  /// No description provided for @awakeningsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} awakenings'**
  String awakeningsCount(int count);

  /// No description provided for @stepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String stepsCount(String count);

  /// No description provided for @kcalValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String kcalValue(String value);

  /// No description provided for @personalInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Personal information saved successfully'**
  String get personalInfoSaved;

  /// No description provided for @preferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved successfully'**
  String get preferencesSaved;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @yourProfileMetrics.
  ///
  /// In en, this message translates to:
  /// **'Your Profile Metrics'**
  String get yourProfileMetrics;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @birthdayWithDate.
  ///
  /// In en, this message translates to:
  /// **'Birthday: {date}'**
  String birthdayWithDate(String date);

  /// No description provided for @selectBirthday.
  ///
  /// In en, this message translates to:
  /// **'Select Birthday'**
  String get selectBirthday;

  /// No description provided for @calculatedAge.
  ///
  /// In en, this message translates to:
  /// **'Calculated Age: {age} years old'**
  String calculatedAge(int age);

  /// No description provided for @saveDetails.
  ///
  /// In en, this message translates to:
  /// **'Save Details'**
  String get saveDetails;

  /// No description provided for @userPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'User Preferences'**
  String get userPreferencesTitle;

  /// No description provided for @aiPreferencesContext.
  ///
  /// In en, this message translates to:
  /// **'AI uses this context to tailor workouts and meal plans'**
  String get aiPreferencesContext;

  /// No description provided for @preferencesHint.
  ///
  /// In en, this message translates to:
  /// **'Paste or write your detailed preferences, schedule constraints, fitness goals, or dietary requirements here...'**
  String get preferencesHint;

  /// No description provided for @savePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferences;

  /// No description provided for @allMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Meals'**
  String get allMealsTitle;

  /// No description provided for @allWorkoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Workouts'**
  String get allWorkoutsTitle;

  /// No description provided for @noWorkoutsCompleted.
  ///
  /// In en, this message translates to:
  /// **'No workouts completed yet'**
  String get noWorkoutsCompleted;

  /// No description provided for @measurementsSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which measurement categories to track. Disabled categories won\'t appear in the Measurements view.'**
  String get measurementsSettingsDesc;

  /// No description provided for @sleepMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Sleep Measurements'**
  String get sleepMeasurements;

  /// No description provided for @sleepMeasurementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Sleep duration, sleeping RHR & HRV'**
  String get sleepMeasurementsDesc;

  /// No description provided for @advancedSleepMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Advanced Sleep Measurements'**
  String get advancedSleepMeasurements;

  /// No description provided for @advancedSleepMeasurementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Time in bed, awake time, number of awakenings'**
  String get advancedSleepMeasurementsDesc;

  /// No description provided for @activityMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Activity Measurements'**
  String get activityMeasurements;

  /// No description provided for @activityMeasurementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Steps, active energy, VO2 max, waking RHR/HRV'**
  String get activityMeasurementsDesc;

  /// No description provided for @advancedBodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Advanced Body Measurements'**
  String get advancedBodyMeasurements;

  /// No description provided for @advancedBodyMeasurementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Body fat %, muscle mass %, circumferences'**
  String get advancedBodyMeasurementsDesc;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @bodyFatValue.
  ///
  /// In en, this message translates to:
  /// **'{value}% BF'**
  String bodyFatValue(String value);

  /// No description provided for @muscleMassValue.
  ///
  /// In en, this message translates to:
  /// **'{value}% Muscle'**
  String muscleMassValue(String value);

  /// No description provided for @waistValue.
  ///
  /// In en, this message translates to:
  /// **'{value}cm Waist'**
  String waistValue(String value);

  /// No description provided for @sleepingRhrValue.
  ///
  /// In en, this message translates to:
  /// **'{value} bpm RHR'**
  String sleepingRhrValue(String value);

  /// No description provided for @sleepingHrvValue.
  ///
  /// In en, this message translates to:
  /// **'{value} ms HRV'**
  String sleepingHrvValue(String value);

  /// No description provided for @wakingRhrValue.
  ///
  /// In en, this message translates to:
  /// **'{value} bpm RHR'**
  String wakingRhrValue(String value);

  /// No description provided for @wakingHrvValue.
  ///
  /// In en, this message translates to:
  /// **'{value} ms HRV'**
  String wakingHrvValue(String value);

  /// No description provided for @vo2WithValue.
  ///
  /// In en, this message translates to:
  /// **'VO2: {value}'**
  String vo2WithValue(String value);

  /// No description provided for @timeAwake.
  ///
  /// In en, this message translates to:
  /// **'Time Awake'**
  String get timeAwake;

  /// No description provided for @wakingHrv.
  ///
  /// In en, this message translates to:
  /// **'Waking HRV'**
  String get wakingHrv;

  /// No description provided for @sleepingHrv.
  ///
  /// In en, this message translates to:
  /// **'Sleeping HRV'**
  String get sleepingHrv;

  /// No description provided for @addHouse.
  ///
  /// In en, this message translates to:
  /// **'Add House'**
  String get addHouse;

  /// No description provided for @houseName.
  ///
  /// In en, this message translates to:
  /// **'House Name'**
  String get houseName;

  /// No description provided for @renameHouse.
  ///
  /// In en, this message translates to:
  /// **'Rename House'**
  String get renameHouse;

  /// No description provided for @deleteHouse.
  ///
  /// In en, this message translates to:
  /// **'Delete House'**
  String get deleteHouse;

  /// No description provided for @deleteHouseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{name}\'? This deletes all associated stock records.'**
  String deleteHouseConfirm(String name);

  /// No description provided for @addProductToStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product to Stock'**
  String get addProductToStockTitle;

  /// No description provided for @mapToTitle.
  ///
  /// In en, this message translates to:
  /// **'Map \'{name}\' to...'**
  String mapToTitle(String name);

  /// No description provided for @manageHouses.
  ///
  /// In en, this message translates to:
  /// **'Manage Houses'**
  String get manageHouses;

  /// No description provided for @noHousesDefined.
  ///
  /// In en, this message translates to:
  /// **'No houses defined'**
  String get noHousesDefined;

  /// No description provided for @operationError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during operation:'**
  String get operationError;

  /// No description provided for @copyError.
  ///
  /// In en, this message translates to:
  /// **'Copy Error'**
  String get copyError;

  /// No description provided for @errorCopied.
  ///
  /// In en, this message translates to:
  /// **'Error copied to clipboard'**
  String get errorCopied;

  /// No description provided for @aiTokenNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI API Token not configured. Set it in Settings.'**
  String get aiTokenNotConfigured;

  /// No description provided for @takePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo (Camera)'**
  String get takePhotoCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @noItemsParsed.
  ///
  /// In en, this message translates to:
  /// **'No items parsed from receipt.'**
  String get noItemsParsed;

  /// No description provided for @receiptImportError.
  ///
  /// In en, this message translates to:
  /// **'Receipt Import Error'**
  String get receiptImportError;

  /// No description provided for @aiLogConfirmation.
  ///
  /// In en, this message translates to:
  /// **'AI Log Confirmation'**
  String get aiLogConfirmation;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @perfectMatch.
  ///
  /// In en, this message translates to:
  /// **'Perfect Match'**
  String get perfectMatch;

  /// No description provided for @fuzzyMatch.
  ///
  /// In en, this message translates to:
  /// **'Fuzzy Match'**
  String get fuzzyMatch;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @productEditError.
  ///
  /// In en, this message translates to:
  /// **'Product Edit Error'**
  String get productEditError;

  /// No description provided for @productCreationError.
  ///
  /// In en, this message translates to:
  /// **'Product Creation Error'**
  String get productCreationError;

  /// No description provided for @createAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @loggedReceiptItems.
  ///
  /// In en, this message translates to:
  /// **'Logged receipt items to stock!'**
  String get loggedReceiptItems;

  /// No description provided for @stockLoggingError.
  ///
  /// In en, this message translates to:
  /// **'Stock Logging Error'**
  String get stockLoggingError;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add Stock'**
  String get addStock;

  /// No description provided for @restockItems.
  ///
  /// In en, this message translates to:
  /// **'Restock Items'**
  String get restockItems;

  /// No description provided for @restockedItems.
  ///
  /// In en, this message translates to:
  /// **'Restocked {count} items successfully!'**
  String restockedItems(int count);

  /// No description provided for @housePrefix.
  ///
  /// In en, this message translates to:
  /// **'House: '**
  String get housePrefix;

  /// No description provided for @aiImportReceipt.
  ///
  /// In en, this message translates to:
  /// **'AI Import Receipt'**
  String get aiImportReceipt;

  /// No description provided for @currentStockTab.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStockTab;

  /// No description provided for @shoppingListTab.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingListTab;

  /// No description provided for @selectOrAddHouse.
  ///
  /// In en, this message translates to:
  /// **'Select or add a house'**
  String get selectOrAddHouse;

  /// No description provided for @searchStock.
  ///
  /// In en, this message translates to:
  /// **'Search stock...'**
  String get searchStock;

  /// No description provided for @noProductsInStock.
  ///
  /// In en, this message translates to:
  /// **'No products in stock'**
  String get noProductsInStock;

  /// No description provided for @edibleEquivalentValue.
  ///
  /// In en, this message translates to:
  /// **'≈ {value} {unit} edible equivalent'**
  String edibleEquivalentValue(String value, String unit);

  /// No description provided for @unitPrefix.
  ///
  /// In en, this message translates to:
  /// **'Unit: '**
  String get unitPrefix;

  /// No description provided for @noMinimum.
  ///
  /// In en, this message translates to:
  /// **'No minimum'**
  String get noMinimum;

  /// No description provided for @minimumWithValue.
  ///
  /// In en, this message translates to:
  /// **'Minimum: {value} {unit}'**
  String minimumWithValue(String value, String unit);

  /// No description provided for @setTriggerFor.
  ///
  /// In en, this message translates to:
  /// **'Set Trigger for {name}'**
  String setTriggerFor(String name);

  /// No description provided for @minimumThresholdWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Minimum Threshold ({unit})'**
  String minimumThresholdWithUnit(String unit);

  /// No description provided for @leaveEmptyToDisableTrigger.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to disable trigger'**
  String get leaveEmptyToDisableTrigger;

  /// No description provided for @noItemsNeedRestocking.
  ///
  /// In en, this message translates to:
  /// **'No items need restocking'**
  String get noItemsNeedRestocking;

  /// No description provided for @stockWithValue.
  ///
  /// In en, this message translates to:
  /// **'Stock: {value}'**
  String stockWithValue(String value);

  /// No description provided for @stockEdibleSuffix.
  ///
  /// In en, this message translates to:
  /// **' (≈ {value} edible)'**
  String stockEdibleSuffix(String value);

  /// No description provided for @minimumSuffix.
  ///
  /// In en, this message translates to:
  /// **' / Minimum: {value} {unit}'**
  String minimumSuffix(String value, String unit);

  /// No description provided for @optionsForItem.
  ///
  /// In en, this message translates to:
  /// **'Options for {name}'**
  String optionsForItem(String name);

  /// No description provided for @whatToDoWithItem.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do with this stock item?'**
  String get whatToDoWithItem;

  /// No description provided for @replaceWith.
  ///
  /// In en, this message translates to:
  /// **'Replace with...'**
  String get replaceWith;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import Failed'**
  String get importFailed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @importedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{entity} imported successfully'**
  String importedSuccessfully(String entity);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestoreTitle;

  /// No description provided for @importFormatDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Import Format Documentation'**
  String get importFormatDocumentation;

  /// No description provided for @importFormatDocumentationDesc.
  ///
  /// In en, this message translates to:
  /// **'Download Markdown import specifications (fields, types, JSON templates) or the active exercise ID list.'**
  String get importFormatDocumentationDesc;

  /// No description provided for @formatShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Nexc Import Format Specifications'**
  String get formatShareSubject;

  /// No description provided for @formatDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download format file: {error}'**
  String formatDownloadFailed(String error);

  /// No description provided for @formatMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Format (.md)'**
  String get formatMarkdown;

  /// No description provided for @exerciseListGenerated.
  ///
  /// In en, this message translates to:
  /// **'Exercise list generated'**
  String get exerciseListGenerated;

  /// No description provided for @exerciseListExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export exercises list: {error}'**
  String exerciseListExportFailed(String error);

  /// No description provided for @exercisesMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Exercises (.md)'**
  String get exercisesMarkdown;

  /// No description provided for @databaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get databaseTitle;

  /// No description provided for @databaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Export or import the full SQLite database containing all workouts, routines, measurements, and foods.'**
  String get databaseDesc;

  /// No description provided for @databaseExported.
  ///
  /// In en, this message translates to:
  /// **'Database exported successfully'**
  String get databaseExported;

  /// No description provided for @databaseExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Database export failed: {error}'**
  String databaseExportFailed(String error);

  /// No description provided for @importSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Import Successful'**
  String get importSuccessful;

  /// No description provided for @importSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'The database was imported. Please restart Nexc to load the new data.'**
  String get importSuccessBody;

  /// No description provided for @databaseImportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Database import cancelled'**
  String get databaseImportCancelled;

  /// No description provided for @workoutPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout plans'**
  String get workoutPlansTitle;

  /// No description provided for @workoutPlansDesc.
  ///
  /// In en, this message translates to:
  /// **'Import or export your workout plan templates as portable JSON files.'**
  String get workoutPlansDesc;

  /// No description provided for @workoutPlansExported.
  ///
  /// In en, this message translates to:
  /// **'Workout plans exported'**
  String get workoutPlansExported;

  /// No description provided for @workoutPlansExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Workout plans export failed: {error}'**
  String workoutPlansExportFailed(String error);

  /// No description provided for @workoutHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout history'**
  String get workoutHistoryTitle;

  /// No description provided for @workoutHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Import or export your completed workouts history including exercises, weights, reps, and timestamps.'**
  String get workoutHistoryDesc;

  /// No description provided for @workoutHistoryExported.
  ///
  /// In en, this message translates to:
  /// **'Workout history exported'**
  String get workoutHistoryExported;

  /// No description provided for @workoutHistoryExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Workout history export failed: {error}'**
  String workoutHistoryExportFailed(String error);

  /// No description provided for @exercisesBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Import or export your exercises database as portable JSON files.'**
  String get exercisesBackupDesc;

  /// No description provided for @exercisesExported.
  ///
  /// In en, this message translates to:
  /// **'Exercises exported'**
  String get exercisesExported;

  /// No description provided for @exercisesExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Exercises export failed: {error}'**
  String exercisesExportFailed(String error);

  /// No description provided for @mealPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal plans'**
  String get mealPlansTitle;

  /// No description provided for @mealPlansDesc.
  ///
  /// In en, this message translates to:
  /// **'Import or export your meal plan templates as portable JSON files.'**
  String get mealPlansDesc;

  /// No description provided for @mealPlansExported.
  ///
  /// In en, this message translates to:
  /// **'Meal plans exported'**
  String get mealPlansExported;

  /// No description provided for @mealPlansExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Meal plans export failed: {error}'**
  String mealPlansExportFailed(String error);

  /// No description provided for @mealHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal history'**
  String get mealHistoryTitle;

  /// No description provided for @mealHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Import or export your logged meal history and consumed food items.'**
  String get mealHistoryDesc;

  /// No description provided for @mealHistoryExported.
  ///
  /// In en, this message translates to:
  /// **'Meal history exported'**
  String get mealHistoryExported;

  /// No description provided for @mealHistoryExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Meal history export failed: {error}'**
  String mealHistoryExportFailed(String error);

  /// No description provided for @productsBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Import or export your products/foods database.'**
  String get productsBackupDesc;

  /// No description provided for @productsExported.
  ///
  /// In en, this message translates to:
  /// **'Products exported'**
  String get productsExported;

  /// No description provided for @productsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Products export failed: {error}'**
  String productsExportFailed(String error);

  /// No description provided for @recipesBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Import or export your custom recipes database.'**
  String get recipesBackupDesc;

  /// No description provided for @recipesExported.
  ///
  /// In en, this message translates to:
  /// **'Recipes exported'**
  String get recipesExported;

  /// No description provided for @recipesExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Recipes export failed: {error}'**
  String recipesExportFailed(String error);

  /// No description provided for @stockBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Import or export your stock inventory and house data. Products must already exist in the database before importing stock.'**
  String get stockBackupDesc;

  /// No description provided for @stockExported.
  ///
  /// In en, this message translates to:
  /// **'Stock exported successfully'**
  String get stockExported;

  /// No description provided for @stockExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Stock export failed: {error}'**
  String stockExportFailed(String error);

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @exportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportAction;

  /// No description provided for @frontView.
  ///
  /// In en, this message translates to:
  /// **'Front View'**
  String get frontView;

  /// No description provided for @backView.
  ///
  /// In en, this message translates to:
  /// **'Back View'**
  String get backView;
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
