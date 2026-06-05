/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:string_similarity/string_similarity.dart';

import 'enums.dart';
import 'relations.dart';

part 'app_database.g.dart';

// Type Converters
class EnumNameConverter<T extends Enum> extends TypeConverter<T, String> {
  final List<T> values;
  const EnumNameConverter(this.values);

  @override
  T fromSql(String fromDb) {
    return values.firstWhere((v) => v.name.toUpperCase() == fromDb.toUpperCase());
  }

  @override
  String toSql(T value) {
    return value.name.toUpperCase();
  }
}

class IsoDateTimeConverter extends TypeConverter<DateTime, String> {
  const IsoDateTimeConverter();

  @override
  DateTime fromSql(String fromDb) {
    return DateTime.parse(fromDb);
  }

  @override
  String toSql(DateTime value) {
    return value.toIso8601String();
  }
}

class LocalTime {
  final int hour;
  final int minute;
  final int second;

  const LocalTime(this.hour, this.minute, [this.second = 0]);

  static const noon = LocalTime(12, 0, 0);

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  static LocalTime parse(String value) {
    final parts = value.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final s = parts.length > 2 ? int.parse(parts[2].split('.')[0]) : 0;
    return LocalTime(h, m, s);
  }
}

class LocalTimeConverter extends TypeConverter<LocalTime, String> {
  const LocalTimeConverter();

  @override
  LocalTime fromSql(String fromDb) {
    return LocalTime.parse(fromDb);
  }

  @override
  String toSql(LocalTime value) {
    return value.toString();
  }
}

class MuscleListConverter extends TypeConverter<List<Muscle>, String> {
  const MuscleListConverter();

  @override
  List<Muscle> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> decoded = json.decode(fromDb);
    return decoded.map((e) => MuscleExt.fromJson(e as String)).toList();
  }

  @override
  String toSql(List<Muscle> value) {
    return json.encode(value.map((e) => e.toJson()).toList());
  }
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> decoded = json.decode(fromDb);
    return decoded.map((e) => e as String).toList();
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

// Tables
@DataClassName('Workout')
class Workouts extends Table {
  @override
  String get tableName => 'workouts';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().named('routineId')();
  TextColumn get notes => text()();
  TextColumn get title => text()();
  TextColumn get state => text().map(const EnumNameConverter<WorkoutState>(WorkoutState.values))();
  IntColumn get timeElapsed => integer().named('timeElapsed')();
  TextColumn get created => text().map(const IsoDateTimeConverter())();
  TextColumn get completed => text().map(const IsoDateTimeConverter())();
  BoolColumn get isTemporal => boolean().named('isTemporal').withDefault(const Constant(false))();
}

@DataClassName('Exercise')
@TableIndex(name: 'index_exercises_workoutId', columns: {#workoutId})
@TableIndex(name: 'index_exercises_workoutId_position', columns: {#workoutId, #position})
@TableIndex(name: 'index_exercises_exerciseDataId', columns: {#exerciseDataId})
class Exercises extends Table {
  @override
  String get tableName => 'exercises';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseDataId => text().named('exerciseDataId')();
  TextColumn get notes => text()();
  TextColumn get setMode => text().named('setMode').map(const EnumNameConverter<SetMode>(SetMode.values))();
  IntColumn get restTime => integer().named('restTime')();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get supersetId => integer().named('supersetId').nullable()();
  IntColumn get workoutId => integer().named('workoutId')();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(workoutId) REFERENCES workouts(id) ON UPDATE NO ACTION ON DELETE CASCADE',
    'FOREIGN KEY(exerciseDataId) REFERENCES exercise_data(id) ON UPDATE NO ACTION ON DELETE CASCADE',
  ];
}

@DataClassName('WorkoutSet')
@TableIndex(name: 'index_sets_exerciseId', columns: {#exerciseId})
class Sets extends Table {
  @override
  String get tableName => 'sets';

  IntColumn get id => integer().autoIncrement()();
  RealColumn get load => real()();
  IntColumn get reps => integer()();
  IntColumn get elapsedTime => integer().named('elapsedTime')();
  BoolColumn get completed => boolean()();
  RealColumn get rpe => real().nullable()();
  IntColumn get rir => integer().nullable()();
  IntColumn get exerciseId => integer().named('exerciseId')();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(exerciseId) REFERENCES exercises(id) ON UPDATE NO ACTION ON DELETE CASCADE',
  ];
}

@DataClassName('BodyMeasurement')
class BodyMeasurements extends Table {
  @override
  String get tableName => 'body_measurements';

  IntColumn get id => integer().autoIncrement()();
  RealColumn get bodyWeight => real().named('bodyWeight')();
  TextColumn get date => text().map(const IsoDateTimeConverter())();
}

@DataClassName('AdvancedBodyMeasurement')
class AdvancedBodyMeasurements extends Table {
  @override
  String get tableName => 'advanced_body_measurements';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get bodyFatPercentage => integer().named('bodyFatPercentage').nullable()();
  IntColumn get muscleMassPercentage => integer().named('muscleMassPercentage').nullable()();
  RealColumn get neckCircumference => real().named('neckCircumference').nullable()();
  RealColumn get chestCircumference => real().named('chestCircumference').nullable()();
  RealColumn get waistCircumference => real().named('waistCircumference').nullable()();
  RealColumn get hipCircumference => real().named('hipCircumference').nullable()();
  RealColumn get bicepLeft => real().named('bicepLeft').nullable()();
  RealColumn get bicepRight => real().named('bicepRight').nullable()();
  RealColumn get thighLeft => real().named('thighLeft').nullable()();
  RealColumn get thighRight => real().named('thighRight').nullable()();
  RealColumn get calfLeft => real().named('calfLeft').nullable()();
  RealColumn get calfRight => real().named('calfRight').nullable()();
  TextColumn get date => text().map(const IsoDateTimeConverter())();
}

@DataClassName('ActivityMeasurement')
class ActivityMeasurements extends Table {
  @override
  String get tableName => 'activity_measurements';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get wakingRHR => integer().named('wakingRHR').nullable()();
  IntColumn get wakingHRV => integer().named('wakingHRV').nullable()();
  IntColumn get dailySteps => integer().named('dailySteps').nullable()();
  RealColumn get activeEnergyBurned => real().named('activeEnergyBurned').nullable()();
  RealColumn get vo2Max => real().named('vo2Max').nullable()();
  TextColumn get date => text().map(const IsoDateTimeConverter())();
}

@DataClassName('SleepMeasurement')
class SleepMeasurements extends Table {
  @override
  String get tableName => 'sleep_measurements';

  IntColumn get id => integer().autoIncrement()();
  RealColumn get sleepDuration => real().named('sleepDuration').nullable()();
  RealColumn get deepSleepDuration => real().named('deepSleepDuration').nullable()();
  RealColumn get lightSleepDuration => real().named('lightSleepDuration').nullable()();
  RealColumn get remSleepDuration => real().named('remSleepDuration').nullable()();
  IntColumn get sleepingRHR => integer().named('sleepingRHR').nullable()();
  IntColumn get sleepingHRV => integer().named('sleepingHRV').nullable()();
  TextColumn get date => text().map(const IsoDateTimeConverter())();
}

@DataClassName('AdvancedSleepMeasurement')
class AdvancedSleepMeasurements extends Table {
  @override
  String get tableName => 'advanced_sleep_measurements';

  IntColumn get id => integer().autoIncrement()();
  RealColumn get timeInBed => real().named('timeInBed').nullable()();
  RealColumn get totalAwakeTime => real().named('totalAwakeTime').nullable()();
  IntColumn get numberOfAwakenings => integer().named('numberOfAwakenings').nullable()();
  RealColumn get longestAwakePeriod => real().named('longestAwakePeriod').nullable()();
  RealColumn get sleepLatency => real().named('sleepLatency').nullable()();
  RealColumn get deepSleepLatency => real().named('deepSleepLatency').nullable()();
  RealColumn get remSleepLatency => real().named('remSleepLatency').nullable()();
  RealColumn get deepSleepFragmentation => real().named('deepSleepFragmentation').nullable()();
  RealColumn get lightSleepFragmentation => real().named('lightSleepFragmentation').nullable()();
  RealColumn get remSleepFragmentation => real().named('remSleepFragmentation').nullable()();
  TextColumn get date => text().map(const IsoDateTimeConverter())();
  TextColumn get notes => text().nullable()();
}

@DataClassName('ExerciseDataDC')
class ExerciseData extends Table {
  @override
  String get tableName => 'exercise_data';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get force => text().map(const EnumNameConverter<Force>(Force.values)).nullable()();
  TextColumn get level => text().map(const EnumNameConverter<Level>(Level.values))();
  TextColumn get mechanic => text().map(const EnumNameConverter<Mechanic>(Mechanic.values)).nullable()();
  TextColumn get equipment => text().map(const EnumNameConverter<Equipment>(Equipment.values)).nullable()();
  TextColumn get primaryMuscles => text().named('primaryMuscles').map(const MuscleListConverter())();
  TextColumn get secondaryMuscles => text().named('secondaryMuscles').map(const MuscleListConverter())();
  TextColumn get instructions => text().map(const StringListConverter())();
  TextColumn get category => text().map(const EnumNameConverter<Category>(Category.values))();
  TextColumn get images => text().map(const StringListConverter())();
  BoolColumn get isCustomExercise => boolean().named('isCustomExercise')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Product')
class Products extends Table {
  @override
  String get tableName => 'products';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get mlToGFactor => integer().named('mlToGFactor').nullable()();
  TextColumn get defaultUnits => text().named('defaultUnits').nullable()();
  RealColumn get edibleQtyPerUnit => real().named('edibleQtyPerUnit').nullable()();
  RealColumn get kcal => real().nullable()();
  RealColumn get proteins => real()();
  RealColumn get carbsByDifference => real().named('carbsByDifference').nullable()();
  RealColumn get carbsAvailable => real().named('carbsAvailable').nullable()();
  RealColumn get dietaryFiber => real().named('dietaryFiber').nullable()();
  RealColumn get fats => real()();
  BoolColumn get isSupplement => boolean().named('isSupplement')();
  BoolColumn get isPortable => boolean().named('isPortable').withDefault(const Constant(true))();
  IntColumn get unitWeight => integer().named('unitWeight').nullable()();
  BoolColumn get isStockRaw => boolean().named('isStockRaw').withDefault(const Constant(false))();
}

@DataClassName('House')
class Houses extends Table {
  @override
  String get tableName => 'houses';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

@DataClassName('ProductStock')
class ProductStocks extends Table {
  @override
  String get tableName => 'product_stocks';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().named('productId')();
  IntColumn get houseId => integer().named('houseId')();
  RealColumn get quantity => real()();
  RealColumn get minTriggerQuantity => real().named('minTriggerQuantity').nullable()();
  RealColumn get quantityGrams => real().named('quantityGrams').withDefault(const Constant(0.0))();
  RealColumn get quantityMl => real().named('quantityMl').withDefault(const Constant(0.0))();
  RealColumn get quantityUnits => real().named('quantityUnits').withDefault(const Constant(0.0))();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(productId) REFERENCES products(id) ON UPDATE NO ACTION ON DELETE CASCADE',
    'FOREIGN KEY(houseId) REFERENCES houses(id) ON UPDATE NO ACTION ON DELETE CASCADE',
    'UNIQUE(productId, houseId)',
  ];
}

@DataClassName('ReceiptMapping')
class ReceiptMappings extends Table {
  @override
  String get tableName => 'receipt_mappings';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get receiptName => text()();
  IntColumn get productId => integer().named('productId')();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(productId) REFERENCES products(id) ON UPDATE NO ACTION ON DELETE CASCADE',
    'UNIQUE(receipt_name)',
  ];
}

@DataClassName('Recipe')
class Recipes extends Table {
  @override
  String get tableName => 'recipes';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get instructions => text()();
  BoolColumn get isPortable => boolean().named('isPortable')();
}

@DataClassName('RecipeIngredient')
@TableIndex(name: 'index_recipe_ingredients_recipeId', columns: {#recipeId})
@TableIndex(name: 'index_recipe_ingredients_productId', columns: {#productId})
class RecipeIngredients extends Table {
  @override
  String get tableName => 'recipe_ingredients';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId => integer().named('recipeId')();
  IntColumn get productId => integer().named('productId')();
  RealColumn get amount => real()();
  TextColumn get amountUnits => text().named('amountUnits').nullable()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(recipeId) REFERENCES recipes(id) ON UPDATE NO ACTION ON DELETE CASCADE',
    'FOREIGN KEY(productId) REFERENCES products(id) ON UPDATE NO ACTION ON DELETE CASCADE',
  ];
}

@DataClassName('MealPlan')
class MealPlans extends Table {
  @override
  String get tableName => 'meal_plans';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentPlanId => integer().named('parentPlanId')();
  TextColumn get title => text()();
  TextColumn get notes => text()();
  TextColumn get state => text().map(const EnumNameConverter<MealPlanState>(MealPlanState.values))();
  TextColumn get created => text().map(const IsoDateTimeConverter())();
  TextColumn get completed => text().map(const IsoDateTimeConverter())();
  RealColumn get targetProtein => real().nullable()();
  RealColumn get targetCarbs => real().nullable()();
  RealColumn get targetFats => real().nullable()();
  BoolColumn get isTemporal => boolean().named('isTemporal').withDefault(const Constant(false))();
}

@DataClassName('Meal')
@TableIndex(name: 'index_meals_mealPlanId', columns: {#mealPlanId})
@TableIndex(name: 'index_meals_mealPlanId_position', columns: {#mealPlanId, #position})
class Meals extends Table {
  @override
  String get tableName => 'meals';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealPlanId => integer().named('mealPlanId')();
  TextColumn get name => text()();
  TextColumn get time => text().map(const LocalTimeConverter())();
  TextColumn get notes => text()();
  IntColumn get position => integer()();
  BoolColumn get atHome => boolean().named('atHome').withDefault(const Constant(true))();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(mealPlanId) REFERENCES meal_plans(id) ON UPDATE NO ACTION ON DELETE CASCADE',
  ];
}

@DataClassName('MealItem')
@TableIndex(name: 'index_meal_items_mealId', columns: {#mealId})
@TableIndex(name: 'index_meal_items_mealId_position', columns: {#mealId, #position})
class MealItems extends Table {
  @override
  String get tableName => 'meal_items';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealId => integer().named('mealId')();
  TextColumn get type => text().map(const EnumNameConverter<MealItemType>(MealItemType.values))();
  IntColumn get targetId => integer().named('targetId')();
  RealColumn get amount => real()();
  /// Unit for amount: GRAMS (default) or UNITS (e.g. 1 banana).
  TextColumn get amountUnit => text()
      .named('amountUnit')
      .map(const EnumNameConverter<AmountUnit>(AmountUnit.values))
      .withDefault(const Constant('GRAMS'))();
  BoolColumn get consumed => boolean()();
  IntColumn get position => integer()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(mealId) REFERENCES meals(id) ON UPDATE NO ACTION ON DELETE CASCADE',
  ];
}

@DataClassName('UserData')
class Users extends Table {
  @override
  String get tableName => 'users';

  IntColumn get id => integer().autoIncrement()();
  RealColumn get height => real().nullable()();
  TextColumn get birthDate => text().map(const IsoDateTimeConverter()).nullable()();
}

@DriftDatabase(tables: [
  Workouts,
  Exercises,
  Sets,
  BodyMeasurements,
  AdvancedBodyMeasurements,
  ActivityMeasurements,
  SleepMeasurements,
  AdvancedSleepMeasurements,
  ExerciseData,
  Products,
  Recipes,
  RecipeIngredients,
  MealPlans,
  Meals,
  MealItems,
  Users,
  Houses,
  ProductStocks,
  ReceiptMappings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.executor(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 19;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 10) {
            await m.createTable(products);
            await m.createTable(recipes);
            await m.createTable(recipeIngredients);
            await m.createTable(mealPlans);
            await m.createTable(meals);
            await m.createTable(mealItems);
          }
          if (from < 11) {
            await m.addColumn(products, products.isPortable);
          }
          if (from < 12) {
            await m.addColumn(mealItems, mealItems.amountUnit);
          }
          if (from < 13) {
            await m.addColumn(mealPlans, mealPlans.targetProtein);
            await m.addColumn(mealPlans, mealPlans.targetCarbs);
            await m.addColumn(mealPlans, mealPlans.targetFats);
          }
          if (from < 14) {
            // Version 14 Migration:
            // 1. Rename dataset to exercise_data
            await m.issueCustomQuery('ALTER TABLE dataset RENAME TO exercise_data;');
            
            // 2. Add columns to exercises: exerciseDataId, drop idExerciseDC.
            await m.issueCustomQuery('ALTER TABLE exercises RENAME COLUMN idExerciseDC TO exerciseDataId;');
            
            // 3. Sets: drop intensityScale column.
            await m.issueCustomQuery('ALTER TABLE sets DROP COLUMN intensityScale;');
            
            // 4. Products migration (recreate table, map columns)
            await m.issueCustomQuery('''
              CREATE TABLE products_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                weight REAL NOT NULL,
                mlToGFactor INTEGER,
                unitWeight INTEGER,
                defaultUnits TEXT,
                edibleQtyPerUnit REAL,
                kcal REAL,
                proteins REAL NOT NULL,
                carbsByDifference REAL,
                carbsAvailable REAL,
                dietaryFiber REAL,
                fats REAL NOT NULL,
                isSupplement BOOLEAN NOT NULL,
                isPortable BOOLEAN NOT NULL DEFAULT 1
              );
            ''');
            await m.issueCustomQuery('''
              INSERT INTO products_new (id, name, weight, defaultUnits, edibleQtyPerUnit, proteins, carbsAvailable, fats, isSupplement, isPortable)
              SELECT id, name, weight, units, edibleQtyPerUnit, proteins, carbs, fats, isSupplement, isPortable FROM products;
            ''');
            await m.issueCustomQuery('DROP TABLE products;');
            await m.issueCustomQuery('ALTER TABLE products_new RENAME TO products;');
            
            // 5. RecipeIngredients: add amountUnits
            await m.issueCustomQuery('ALTER TABLE recipe_ingredients ADD COLUMN amountUnits TEXT;');
            
            // 6. MealPlans: add isTemporal
            await m.issueCustomQuery('ALTER TABLE meal_plans ADD COLUMN isTemporal BOOLEAN NOT NULL DEFAULT 0;');
            
            // 7. Split measurements table into body_measurements and advanced_body_measurements
            await m.createTable(bodyMeasurements);
            await m.createTable(advancedBodyMeasurements);
            await m.createTable(activityMeasurements);
            await m.createTable(sleepMeasurements);
            await m.createTable(advancedSleepMeasurements);
            
            // Copy existing measurements
            await m.issueCustomQuery('''
              INSERT INTO body_measurements (id, bodyWeight, date)
              SELECT id, bodyWeight, date FROM measurements;
            ''');
            await m.issueCustomQuery('''
              INSERT INTO advanced_body_measurements (bodyFatPercentage, muscleMassPercentage, date)
              SELECT bodyFatPercentage, muscleMassPercentage, date FROM measurements;
            ''');
            await m.issueCustomQuery('DROP TABLE measurements;');
          }
          if (from < 15) {
            await m.createTable(users);
            await m.addColumn(workouts, workouts.isTemporal);
          }
          if (from < 16) {
            try {
              await m.addColumn(products, products.unitWeight);
            } catch (_) {}
            await m.createTable(houses);
            await m.createTable(productStocks);
          }
          if (from < 17) {
            await m.createTable(receiptMappings);
          }
          if (from < 18) {
            try {
              await m.addColumn(products, products.isStockRaw);
            } catch (_) {}
          }
          if (from < 19) {
            try {
              await m.addColumn(productStocks, productStocks.quantityGrams);
              await m.addColumn(productStocks, productStocks.quantityMl);
              await m.addColumn(productStocks, productStocks.quantityUnits);
              await m.addColumn(meals, meals.atHome);
            } catch (_) {}
          }
        },
      );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nexc_database'));
    
    // On Android, if the Room database already exists, we must use it.
    if (Platform.isAndroid) {
      // Room databases on Android are located at: /data/data/org.nexc/databases/nexc_database
      final androidDbFile = File('/data/data/org.nexc/databases/nexc_database');
      if (await androidDbFile.exists()) {
        return NativeDatabase(androidDbFile);
      }
    }
    
    return NativeDatabase(file);
  });
}

extension ProductExtension on Product {
  double get carbs => carbsAvailable ?? carbsByDifference ?? 0.0;
  String get units => defaultUnits ?? 'g';
  int get quantity => 0;
  double get ediblePercent => edibleQtyPerUnit != null ? (edibleQtyPerUnit! * 100.0) : 100.0;
  double get weight => 0.0;
}

List<String> getSearchStems(String query) {
  final queryLower = query.toLowerCase().trim();
  if (queryLower.isEmpty) return [];
  final stems = {queryLower};
  
  if (queryLower.endsWith('ies') && queryLower.length > 3) {
    stems.add(queryLower.substring(0, queryLower.length - 3) + 'y');
  } else if (queryLower.endsWith('s') && queryLower.length > 3) {
    stems.add(queryLower.substring(0, queryLower.length - 1));
  }
  
  for (final s in List<String>.from(stems)) {
    if (s.endsWith('y') && s.length > 1) {
      stems.add(s.substring(0, s.length - 1) + 'ies');
    } else if (!s.endsWith('s')) {
      stems.add(s + 's');
    }
  }
  
  final Map<String, List<String>> synonymMap = {
    'oatmeal': ['oat', 'oats'],
    'oatmeals': ['oat', 'oats'],
    'potato': ['potatoes', 'potato'],
    'tomato': ['tomatoes', 'tomato'],
  };
  
  for (final stem in List<String>.from(stems)) {
    if (synonymMap.containsKey(stem)) {
      stems.addAll(synonymMap[stem]!);
    }
  }
  
  return stems.toList();
}

extension ProductSearchExtension on Iterable<Product> {
  List<Product> searchAndSort(String query) {
    if (query.isEmpty) return toList();
    
    final queryLower = query.toLowerCase().trim();
    final stems = getSearchStems(query);
    
    final scored = map((p) {
      final nameLower = p.name.toLowerCase();
      double score = 0.0;
      
      if (stems.any((s) => nameLower == s)) {
        score += 10.0;
      }
      
      if (stems.any((s) => nameLower.startsWith(s))) {
        score += 5.0;
      } else if (stems.any((s) => nameLower.contains(s))) {
        score += 2.0;
      }
      
      final words = nameLower.split(RegExp(r'[^a-zA-Z0-9]'));
      if (words.any((w) => stems.contains(w))) {
        score += 3.0;
      } else if (words.any((w) => stems.any((s) => w.startsWith(s)))) {
        score += 1.5;
      }
      
      final similarity = StringSimilarity.compareTwoStrings(nameLower, queryLower);
      score += similarity * 3.0;
      
      score -= p.name.length * 0.001;
      
      if (nameLower.contains('babyfood')) {
        score -= 1.0;
      }
      
      if (words.contains('raw') && !queryLower.contains('raw')) {
        score += 1.0;
      }
      
      return _ScoredProduct(p, score);
    }).toList();

    final filtered = scored.where((sp) {
      final nameLower = sp.product.name.toLowerCase();
      final similarity = StringSimilarity.compareTwoStrings(nameLower, queryLower);
      return stems.any((s) => nameLower.contains(s)) || similarity > 0.2;
    }).toList();
    
    filtered.sort((a, b) => b.score.compareTo(a.score));
    return filtered.map((sp) => sp.product).toList();
  }
}

class _ScoredProduct {
  final Product product;
  final double score;
  _ScoredProduct(this.product, this.score);
}

extension RecipeSearchExtension on Iterable<RecipeWithIngredients> {
  List<RecipeWithIngredients> searchAndSort(String query) {
    if (query.isEmpty) return toList();
    
    final queryLower = query.toLowerCase().trim();
    final stems = getSearchStems(query);
    
    final scored = map((r) {
      final nameLower = r.recipe.name.toLowerCase();
      double score = 0.0;
      
      if (stems.any((s) => nameLower == s)) {
        score += 10.0;
      }
      
      if (stems.any((s) => nameLower.startsWith(s))) {
        score += 5.0;
      } else if (stems.any((s) => nameLower.contains(s))) {
        score += 2.0;
      }
      
      for (final ing in r.ingredients) {
        final ingNameLower = ing.product.name.toLowerCase();
        if (stems.any((s) => ingNameLower == s)) {
          score += 4.0;
        } else if (stems.any((s) => ingNameLower.startsWith(s))) {
          score += 2.0;
        } else if (stems.any((s) => ingNameLower.contains(s))) {
          score += 1.0;
        }
      }
      
      final similarity = StringSimilarity.compareTwoStrings(nameLower, queryLower);
      score += similarity * 3.0;
      
      score -= r.recipe.name.length * 0.001;
      
      return _ScoredRecipe(r, score);
    }).toList();
    
    final filtered = scored.where((sr) {
      final nameLower = sr.recipe.recipe.name.toLowerCase();
      final similarity = StringSimilarity.compareTwoStrings(nameLower, queryLower);
      final ingMatch = sr.recipe.ingredients.any((ing) {
        final ingNameLower = ing.product.name.toLowerCase();
        return stems.any((s) => ingNameLower.contains(s)) || 
               StringSimilarity.compareTwoStrings(ingNameLower, queryLower) > 0.3;
      });
      return stems.any((s) => nameLower.contains(s)) || similarity > 0.2 || ingMatch;
    }).toList();
    
    filtered.sort((a, b) => b.score.compareTo(a.score));
    return filtered.map((sr) => sr.recipe).toList();
  }
}

class _ScoredRecipe {
  final RecipeWithIngredients recipe;
  final double score;
  _ScoredRecipe(this.recipe, this.score);
}
