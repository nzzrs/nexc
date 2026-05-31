/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

enum WorkoutState { RUNNING, COMPLETED, ROUTINE, ARCHIVED, LIBRARY }

enum SetMode { LOAD, BODYWEIGHT, BODYWEIGHT_WITH_LOAD, DURATION, DURATION_WITH_LOAD }

enum MealPlanState { TEMPLATE, LOGGED, ARCHIVED }

enum MealItemType { PRODUCT, RECIPE }

enum Force { STATIC, PULL, PUSH }

enum Level { BEGINNER, INTERMEDIATE, EXPERT }

enum Mechanic { ISOLATION, COMPOUND }

enum Equipment {
  MEDICINE_BALL,
  DUMBBELL,
  BODY_ONLY,
  BANDS,
  KETTLEBELLS,
  FOAM_ROLL,
  CABLE,
  MACHINE,
  BARBELL,
  EXERCISE_BALL,
  E_Z_CURL_BAR,
  OTHER
}

enum Muscle {
  ABDOMINALS,
  ABDUCTORS,
  ADDUCTORS,
  BICEPS,
  CALVES,
  CHEST,
  FOREARMS,
  GLUTES,
  HAMSTRINGS,
  LATS,
  LOWER_BACK,
  MIDDLE_BACK,
  NECK,
  QUADRICEPS,
  SHOULDERS,
  TRAPS,
  TRICEPS
}

enum Category {
  POWERLIFTING,
  STRENGTH,
  STRETCHING,
  CARDIO,
  OLYMPIC_WEIGHTLIFTING,
  STRONGMAN,
  PLYOMETRICS
}

// Extensions for JSON serialization matching Kotlin `@SerialName`
extension ForceExt on Force {
  String toJson() {
    switch (this) {
      case Force.STATIC: return 'static';
      case Force.PULL: return 'pull';
      case Force.PUSH: return 'push';
    }
  }

  static Force fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'static': return Force.STATIC;
      case 'pull': return Force.PULL;
      case 'push': return Force.PUSH;
      default: throw ArgumentError('Unknown Force value: $value');
    }
  }
}

extension LevelExt on Level {
  String toJson() {
    switch (this) {
      case Level.BEGINNER: return 'beginner';
      case Level.INTERMEDIATE: return 'intermediate';
      case Level.EXPERT: return 'expert';
    }
  }

  static Level fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'beginner': return Level.BEGINNER;
      case 'intermediate': return Level.INTERMEDIATE;
      case 'expert': return Level.EXPERT;
      default: throw ArgumentError('Unknown Level value: $value');
    }
  }
}

extension MechanicExt on Mechanic {
  String toJson() {
    switch (this) {
      case Mechanic.ISOLATION: return 'isolation';
      case Mechanic.COMPOUND: return 'compound';
    }
  }

  static Mechanic fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'isolation': return Mechanic.ISOLATION;
      case 'compound': return Mechanic.COMPOUND;
      default: throw ArgumentError('Unknown Mechanic value: $value');
    }
  }
}

extension EquipmentExt on Equipment {
  String toJson() {
    switch (this) {
      case Equipment.MEDICINE_BALL: return 'medicine ball';
      case Equipment.DUMBBELL: return 'dumbbell';
      case Equipment.BODY_ONLY: return 'body only';
      case Equipment.BANDS: return 'bands';
      case Equipment.KETTLEBELLS: return 'kettlebells';
      case Equipment.FOAM_ROLL: return 'foam roll';
      case Equipment.CABLE: return 'cable';
      case Equipment.MACHINE: return 'machine';
      case Equipment.BARBELL: return 'barbell';
      case Equipment.EXERCISE_BALL: return 'exercise ball';
      case Equipment.E_Z_CURL_BAR: return 'e-z curl bar';
      case Equipment.OTHER: return 'other';
    }
  }

  static Equipment fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'medicine ball': return Equipment.MEDICINE_BALL;
      case 'dumbbell': return Equipment.DUMBBELL;
      case 'body only': return Equipment.BODY_ONLY;
      case 'bands': return Equipment.BANDS;
      case 'kettlebells': return Equipment.KETTLEBELLS;
      case 'foam roll': return Equipment.FOAM_ROLL;
      case 'cable': return Equipment.CABLE;
      case 'machine': return Equipment.MACHINE;
      case 'barbell': return Equipment.BARBELL;
      case 'exercise ball': return Equipment.EXERCISE_BALL;
      case 'e-z curl bar': return Equipment.E_Z_CURL_BAR;
      case 'other': return Equipment.OTHER;
      default: throw ArgumentError('Unknown Equipment value: $value');
    }
  }
}

extension MuscleExt on Muscle {
  String toJson() {
    switch (this) {
      case Muscle.ABDOMINALS: return 'abdominals';
      case Muscle.ABDUCTORS: return 'abductors';
      case Muscle.ADDUCTORS: return 'adductors';
      case Muscle.BICEPS: return 'biceps';
      case Muscle.CALVES: return 'calves';
      case Muscle.CHEST: return 'chest';
      case Muscle.FOREARMS: return 'forearms';
      case Muscle.GLUTES: return 'glutes';
      case Muscle.HAMSTRINGS: return 'hamstrings';
      case Muscle.LATS: return 'lats';
      case Muscle.LOWER_BACK: return 'lower back';
      case Muscle.MIDDLE_BACK: return 'middle back';
      case Muscle.NECK: return 'neck';
      case Muscle.QUADRICEPS: return 'quadriceps';
      case Muscle.SHOULDERS: return 'shoulders';
      case Muscle.TRAPS: return 'traps';
      case Muscle.TRICEPS: return 'triceps';
    }
  }

  static Muscle fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'abdominals': return Muscle.ABDOMINALS;
      case 'abductors': return Muscle.ABDUCTORS;
      case 'adductors': return Muscle.ADDUCTORS;
      case 'biceps': return Muscle.BICEPS;
      case 'calves': return Muscle.CALVES;
      case 'chest': return Muscle.CHEST;
      case 'forearms': return Muscle.FOREARMS;
      case 'glutes': return Muscle.GLUTES;
      case 'hamstrings': return Muscle.HAMSTRINGS;
      case 'lats': return Muscle.LATS;
      case 'lower back': return Muscle.LOWER_BACK;
      case 'middle back': return Muscle.MIDDLE_BACK;
      case 'neck': return Muscle.NECK;
      case 'quadriceps': return Muscle.QUADRICEPS;
      case 'shoulders': return Muscle.SHOULDERS;
      case 'traps': return Muscle.TRAPS;
      case 'triceps': return Muscle.TRICEPS;
      default: throw ArgumentError('Unknown Muscle value: $value');
    }
  }
}

extension CategoryExt on Category {
  String toJson() {
    switch (this) {
      case Category.POWERLIFTING: return 'powerlifting';
      case Category.STRENGTH: return 'strength';
      case Category.STRETCHING: return 'stretching';
      case Category.CARDIO: return 'cardio';
      case Category.OLYMPIC_WEIGHTLIFTING: return 'olympic weightlifting';
      case Category.STRONGMAN: return 'strongman';
      case Category.PLYOMETRICS: return 'plyometrics';
    }
  }

  static Category fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'powerlifting': return Category.POWERLIFTING;
      case 'strength': return Category.STRENGTH;
      case 'stretching': return Category.STRETCHING;
      case 'cardio': return Category.CARDIO;
      case 'olympic weightlifting': return Category.OLYMPIC_WEIGHTLIFTING;
      case 'strongman': return Category.STRONGMAN;
      case 'plyometrics': return Category.PLYOMETRICS;
      default: throw ArgumentError('Unknown Category value: $value');
    }
  }
}

enum OneRepMaxFormula {
  balanced(0),
  epley(1),
  brzycki(2),
  mcglothin(3),
  lombardi(4),
  mayhew(5),
  oConner(6),
  wathen(7);

  final int value;
  const OneRepMaxFormula(this.value);
}

enum IntensityScale {
  rpe(0),
  rir(1),
  both(2);

  final int value;
  const IntensityScale(this.value);
}

enum Language {
  system(''),
  english('en'),
  italian('it'),
  german('de'),
  dutch('nl'),
  czech('cs'),
  simplifiedChinese('zh-rCN'),
  spanish('es');

  final String code;
  const Language(this.code);
}

/// Whether a meal item amount is expressed in grams or discrete units (e.g. 1 banana).
enum AmountUnit { GRAMS, UNITS }
